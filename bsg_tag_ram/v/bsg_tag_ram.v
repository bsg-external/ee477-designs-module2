/**
 * BSG Tag with RAM Chip
 *
 * This is the toplevel module file. All input and output
 * ports will become inputs and outputs to the whole chip.
 */
module bsg_tag_ram

  import bsg_tag_ram_pkg::*;
  import bsg_tag_pkg::*;

  (input tck_i  // tag clock
  ,input tdi_i  // tag data
  ,input tms_i  // tag enable
   
  ,input         clk_i    // Core clock
  ,input         reset_i  // Core reset
  ,output [15:0] data_o   // Output data
  );

  // An array of bsg_tag_s structs. Each bsg_tag_s represents
  // a collection of wires between the bsg_tag_master and a
  // bsg_tag_client.
  bsg_tag_s [bsg_tag_client_num_lp-1:0] tag_lines;

  // The BSG Tag Master
  bsg_tag_master #(.els_p(bsg_tag_client_num_lp)
                  ,.lg_width_p(bsg_tag_lg_max_payload_width_lp )
                  ,.debug_level_lp(0)
                  )
    btm
      (.clk_i       ( tck_i )
      ,.data_i      ( tdi_i )
      ,.en_i        ( tms_i )
      ,.clients_r_o ( tag_lines )
      );


  // TODO: Create the tag-ram design shown in the module document. Use
  // bsg_tag_incr to help you out! When using bsg_mem_1rw_sync, set the
  // parameter 'latch_last_read_p' to 0


endmodule

