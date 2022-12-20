
module incrementer_node #(parameter ring_width_p="inv"
                         ,parameter id_p="inv")
  (input  clk_i
  ,input  reset_i
  ,input  en_i

  ,input                     v_i
  ,input  [ring_width_p-1:0] data_i
  ,output                    ready_o
  
  ,output                    v_o
  ,output [ring_width_p-1:0] data_o
  ,input                     yumi_i
  );
  
  // Signals with _r are registered values
  // of the signals with a _n.
  logic valid_r, valid_n;

  // If we are going to accept new data (which
  // happens if the input data is valid and we
  // are indicating we are ready) then on the
  // next cycle our data will be valid. Otherwise,
  // if we have valid data but it is going to be
  // accepeted by the outside world, then our
  // data is no longer valid. If neither of
  // these cases are true, then our valid
  // signal should remain unchanged.
  //
  always_comb begin
    if (v_i & ready_o) begin
      valid_n = 1'b1;
    end else if (valid_r & yumi_i) begin
      valid_n = 1'b0;
    end else begin
      valid_n = valid_r;
    end
  end

  // Signals with _r are registered values
  // of the signals with a _n.
  logic [ring_width_p-1:0] data_r, data_n, data_i_plus_one;

  // This net is the input data + 1
  //
  assign data_i_plus_one = data_i + 1'b1;

  // If we are indicating that we are ready for
  // new data, and that the input data is valid,
  // then we should store the input data + 1
  // into the register on the next clock edge,
  // otherwise we should just keep the register
  // value unchanged.
  //
  always_comb begin
    if (v_i & ready_o) begin
      data_n = data_i_plus_one;
    end else begin
      data_n = data_r;
    end
  end

  // We should indicate that we are ready for new
  // data if our current data is not valid. Our
  // current data is not valid if we just came
  // out of reset, or our output data was accepted
  // by the outside world. We can also indicate
  // that we are ready if the output data is valid
  // but it will be accepted by the outside world
  // on this cycle (yumi_i).
  //
  assign ready_o = ~valid_r | (valid_r & yumi_i);

    
  // Define our register w/ reset
  //
  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      data_r  <= ring_width_p'(1'b0);
      valid_r <= 1'b0;
    end else begin
      data_r  <= data_n;
      valid_r <= valid_n;
    end
  end

  // connect v_o to valid_r
  //
  assign v_o    = valid_r;

  // connect data_o to data_r
  //
  assign data_o = data_r;

endmodule
