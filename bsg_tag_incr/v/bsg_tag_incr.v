/**
 * BSG Tag Incrimenter Chip
 *
 * This is the toplevel module file. All input and output
 * ports will become inputs and outputs to the whole chip.
 */
module bsg_tag_incr
    import bsg_tag_incr_pkg::*;
    import bsg_tag_pkg::*;
(
    input tck_i,      // tag clock
    input tdi_i,      // tag data
    input tms_i,      // tag enable

    input              clk_i,      // core clock
    input              reset_i,    // core reset
    output logic [7:0] data_o      // core output data
);

    // An array of bsg_tag_s structs. Each bsg_tag_s represents
    // a collection of wires between the bsg_tag_master and a
    // bsg_tag_client.
    bsg_tag_s [bsg_tag_client_num_lp-1:0] tag_line;

    // The BSG Tag Master
    bsg_tag_master #( .els_p(bsg_tag_client_num_lp), .lg_width_p(bsg_tag_lg_max_payload_width_lp) )
      btm
        (.clk_i       ( tck_i )
        ,.data_i      ( tdi_i )
        ,.en_i        ( tms_i )
        ,.clients_r_o ( tag_line )
        );

    // The data recieved by the client
    incr_payload_s tag_data;
    logic          tag_new;

    // BSG Tag Client module
    bsg_tag_client #(.width_p(8))
      btc
        (.bsg_tag_i     ( tag_line[0] )
        ,.recv_clk_i    ( clk_i )
        ,.recv_new_r_o  ( tag_new )
        ,.recv_data_r_o ( tag_data )
        );

    wire [7:0] tag_data_plus_1 = tag_data.data + 1'b1;

    // We sequentially assign the tag data to a register if the data
    // at bsg_tag_client is new. Reset the register to 0 on reset.
    always_ff @(posedge clk_i)
      begin
        if (reset_i) begin
          data_o <= '0;
        end else if (tag_new) begin
          data_o <= tag_data_plus_1;
        end
      end

endmodule

