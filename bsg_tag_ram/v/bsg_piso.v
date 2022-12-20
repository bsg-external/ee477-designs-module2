/**
 * BSG Parallel In Serial Out (PISO)
 *
 * This module takes a multi-bit data input and serializes it
 * by bit banging it on the output.
 *
 * Both the input and output channels use the valid-then-yumi
 * handshake. This makes the input signals a "demanding"
 * interface and the output signals a "helpful" interface.
 */
module bsg_piso #( parameter width_p="inv" )
(
    input                  clk_i,
    input                  reset_i,

    // Data Input Channel
    input                  valid_i,
    output                 yumi_o,
    input  [width_p-1:0]   data_i,

    // Data Output Channel
    output                 valid_o,
    input                  yumi_i,
    output                 data_o
);


    /**
     * Enumeration of all statemachine states
     *
     *      eRX -- recieving state
     *      eTX -- transmission state
     */
    typedef enum logic [0:0] {eRX, eTX} state_e;


    // Keeps track of piso state
    state_e state_r, state_n;

    // Registered input data
    logic [width_p-1:0] data_r;

    // Shift counter for TX
    logic [$clog2(width_p)-1:0] shift_ctr_r, shift_ctr_n;

    // Signal if we are done with TX
    logic done_tx_n;
    

    /**
     * Done TX Signal
     *
     * The done_tx_n signals that we are done with our current transmission.
     * This occurs when we are in the eTX state, we are sending the last bit
     * of data, and the outside world is accepting the data (yumi_i). This
     * signal indicates that we should return to the eRX state or we should
     * accept the next data and continue transmission.
     */
    assign done_tx_n = (state_r == eTX) && (shift_ctr_r == (width_p-1)) && yumi_i;


    /**
     * Yumi Out Signal
     *
     * The yumi_o signal means that we are accepting the input data. This is
     * a demanding interface, so we need to know if the input data is valid
     * first. If the input data is valid, and we are in the eRX state, then
     * we are going to accept the data. If we are not in the eRX state (ie.
     * we are in the eTX state) then we need done_tx_n to be asserted. This
     * means that on the next cycle we would be going back to the eRX state.
     * We can save a cycle by just accepting the next data and staying in the
     * eTX state.
     */
    assign yumi_o = valid_i && ((state_r == eRX) || done_tx_n);


    /**
     * State Machine Logic
     *
     * There are two states to this state machine: eRX (or recieve) and
     * eTX (or transmission). We start in the eRX state and move to the
     * eTX state whenever we accept new data. From the eTX state, we move
     * back to the eRX state when we are done tranmitting (done_tx_n).
     *
     * Note: yumi_o may be asserted when in the eTX state if done_tx_n is
     *       also assert which saves us a cycle. Therefore, the order of
     *       the 'if' statement is important and should not be changed.
     */
    always_comb
      begin
        if (yumi_o) begin
          state_n = eTX;
        end else if (done_tx_n) begin
          state_n = eRX;
        end else begin
          state_n = state_r;
        end
      end

    always_ff @(posedge clk_i)
      begin
        if (reset_i) begin
          state_r <= eRX;
        end else begin
          state_r <= state_n;
        end
      end


    /**
     * Input Data Logic
     *
     * Whenever we decide to accept new data (ie. yumi_o) we will take
     * data_i and store it in data_r. On reset, we clear the register
     * but this isn't strictly necessary.
     */
    always_ff @(posedge clk_i)
      begin
        if (reset_i) begin
          data_r <= '0;
        end else if (yumi_o) begin
          data_r <= data_i;
        end
      end


    /**
     * Shift Counter Logic
     *
     * The shift_ctr_r register stores the bit we are transmitting. Whenever
     * we reset or accept new data (yumi_o) we clear the shift_ctr_r register.
     * While in the eTX state, we will increment the register if the outside
     * world is going to accept our data (ie. yumi_i). If we are done 
     * transmitting data, we should stall the counter on the last bit. 
     */
    assign shift_ctr_n = ((state_r == eTX) && yumi_i && ~done_tx_n)
                       ? shift_ctr_r + 1'b1
                       : shift_ctr_r;

    always_ff @(posedge clk_i)
      begin
        if (reset_i || yumi_o) begin
          shift_ctr_r <= '0;
        end else begin
          shift_ctr_r <= shift_ctr_n;
        end
      end


    /**
     * Valid Output Signal
     *
     * The valid_o signal means the output data is valid. For this
     * module, the output is valid iff we are in the eTX state.
     */
    assign valid_o = (state_r == eTX);


    /**
     * Data Output Signal
     *
     * The data_o signal is our bit-banged output data. We output
     * the registered input data one bit at a time, using the
     * shift_ctr_r register to determine which bit we should be
     * transmitting at any given time.
     */
    assign data_o = data_r[shift_ctr_r];


endmodule
