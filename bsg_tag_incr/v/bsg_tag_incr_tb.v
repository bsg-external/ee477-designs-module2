// bsg_tag_incr_tb.v
//
// This file contains the toplevel testbench for testing
// this design. When using the bsg_tag_incr_tb.v files,
// the bsg motherboard (in the board repo) is not used.
// This is mainly used for block level designs or for
// developing toplevel blocks. Toplevel blocks should
// switch to board testing once operational.
//

module bsg_tag_incr_tb
  import bsg_tag_incr_pkg::*;
  import bsg_tag_pkg::*;
  ();

  initial begin
    $vcdpluson;
    $vcdplusmemon;
    $vcdplusautoflushon;
  end

  // BSG Tag setup
  //===============
  
  `include "bsg_tag.vh"
  `declare_bsg_tag_header_s(bsg_tag_client_num_lp, bsg_tag_lg_max_payload_width_lp);
  localparam bsg_tag_header_width_lp = $bits(bsg_tag_header_s);

  // Nonsynth clock and reset generators
  //=====================================

  logic tag_clk_lo;
  bsg_nonsynth_clock_gen #(.cycle_time_p(`BSG_TAG_CLOCK_PERIOD_PS)
                          )
    tag_clk_gen
        (.o( tag_clk_lo )
        );

  logic core_clk_lo;
  bsg_nonsynth_clock_gen #(.cycle_time_p(`BSG_CORE_CLOCK_PERIOD_PS)
                          )
    core_clk_gen
        (.o( core_clk_lo )
        );

  logic reset_lo;
  bsg_nonsynth_reset_gen #(.num_clocks_p(2)
                          ,.reset_cycles_lo_p(25)
                          ,.reset_cycles_hi_p(25)
                          )
  reset_gen
    (.clk_i( {~tag_clk_lo, ~core_clk_lo} )
    ,.async_reset_o( reset_lo )
    );

  // Create the trace rom
  //======================

  localparam rom_data_width_lp = 4 + bsg_tag_header_width_lp + bsg_tag_max_payload_width_lp;
  localparam rom_addr_width_lp = 32;

  wire [rom_addr_width_lp-1:0] rom_addr_n;
  wire [rom_data_width_lp-1:0] rom_data_n;

  trace_rom #(.width_p(rom_data_width_lp)
                 ,.addr_width_p(rom_addr_width_lp)
                 )
    trace_rom
      (.addr_i ( rom_addr_n )
      ,.data_o ( rom_data_n )
      );

  
  wire                                    tag_data_lo;
  wire [bsg_tag_max_payload_width_lp-1:0] dut_data_lo;

  bsg_tag_trace_replay #(.trace_ring_width_p(rom_data_width_lp - 4)
                        ,.rom_addr_width_p(rom_addr_width_lp)
                        ,.rom_data_width_p(rom_data_width_lp)
                        ,.bsg_tag_header_width_p(bsg_tag_header_width_lp)
                        ,.bsg_tag_max_payload_width_p(bsg_tag_max_payload_width_lp))
      tag_trace_replay
        (.clk_i      ( ~tag_clk_lo )
        ,.reset_i    ( reset_lo )
        ,.rom_addr_o ( rom_addr_n )
        ,.rom_data_i ( rom_data_n )
        ,.tr_data_i  ( dut_data_lo )
        ,.tdi_o      ( tag_data_lo )
        );
        

  // Device under test (DUT)
  //=========================
  bsg_tag_incr
    DUT
      (.tck_i   ( tag_clk_lo )
      ,.tdi_i   ( tag_data_lo )
      ,.tms_i   ( 1'b1 )
      ,.clk_i   ( core_clk_lo )
      ,.reset_i ( reset_lo )
      ,.data_o  ( dut_data_lo )
      );

endmodule

