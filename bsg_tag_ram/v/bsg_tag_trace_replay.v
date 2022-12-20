module bsg_tag_trace_replay

    import bsg_tag_ram_pkg::*;
    import bsg_tag_pkg::*;

#(parameter trace_ring_width_p="inv"
 ,parameter rom_addr_width_p="inv"
 ,parameter rom_data_width_p="inv"
 ,parameter bsg_tag_header_width_p="inv"
 ,parameter bsg_tag_max_payload_width_p="inv")

(input clk_i
,input reset_i

,output [rom_addr_width_p-1:0]   rom_addr_o
,input  [rom_data_width_p-1:0]   rom_data_i

,input [bsg_tag_max_payload_width_p-1:0]  tr_data_i
,output                                   tdi_o
);

    wire                                    tr_valid_o_n;
    wire                                    tr_yumi_i_n;
    wire [trace_ring_width_p-1:0]           tr_data_o_n;

    // Create a trace_replay
    //
    bsg_fsb_node_trace_replay #( .ring_width_p(trace_ring_width_p), .rom_addr_width_p(rom_addr_width_p) )
      trace_replay
        (.clk_i   (clk_i)
        ,.reset_i (reset_i)
        ,.en_i    (1'b1)
        /* input channel */
        ,.v_i     (1'b1)
        ,.data_i  (trace_ring_width_p ' (tr_data_i))
        ,.ready_o ()
        /* output channel */
        ,.v_o     (tr_valid_o_n)
        ,.data_o  (tr_data_o_n)
        ,.yumi_i  (tr_yumi_i_n)
        /* rom connections */
        ,.rom_addr_o (rom_addr_o)
        ,.rom_data_i (rom_data_i)
        /* signals */
        ,.done_o  ()
        ,.error_o ()
        );

    // Reform the data between the trace-replay and the piso
    // to properly act like a bsg_tag packet. This includes adding
    // a 1-bit to the beginning of the data and a 0-bit to the
    // end. Furthermore, swap the header and payload order. These
    // could be done in the trace file but I think the current trace
    // file format is more intuitive and this is a simple fix.
    //
    wire [bsg_tag_header_width_p-1:0]      tag_header_n  = tr_data_o_n[bsg_tag_max_payload_width_p+:bsg_tag_header_width_p];
    wire [bsg_tag_max_payload_width_p-1:0] tag_payload_n = tr_data_o_n[0+:bsg_tag_max_payload_width_p];
    wire [trace_ring_width_p + 2 - 1:0]    tag_data_n    = {1'b0, tag_payload_n, tag_header_n, 1'b1};

    // Create a parallel-in, serial-out converter
    //
    bsg_piso #( .width_p(trace_ring_width_p+2) )
      trace_serializer
        (.clk_i   (clk_i)
        ,.reset_i (reset_i)
   
        // Data Input Channel (Valid then Yumi)
        ,.valid_i (tr_valid_o_n)
        ,.yumi_o  (tr_yumi_i_n)
        ,.data_i  (tag_data_n)
   
        // Data Output Channel (Valid then Yumi)
        ,.valid_o ()
        ,.yumi_i  (1'b1)
        ,.data_o  (tdi_o)
        );

endmodule
