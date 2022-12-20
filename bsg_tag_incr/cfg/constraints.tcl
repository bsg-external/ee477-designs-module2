# constraints.tcl
#
# This file is where design timing constraints are defined for Genus and Innovus.
# Many constraints can be written directly into the Hammer config files. However, 
# you may manually define constraints here as well.
#

create_clock -name core_clk -period 10 [get_ports clk_i]
set_clock_uncertainty 0.050 [get_clocks core_clk]
set_input_delay  0.000 -clock core_clk [get_ports reset_i]
set_output_delay 0.000 -clock core_clk [get_ports data_o]

create_clock -name tag_clk -period 40 [get_ports tck_i]
set_clock_uncertainty 1.000 [get_clocks tag_clk]
set_input_delay 20 -clock tag_clk [get_ports tdi_i]
set_input_delay 20 -clock tag_clk [get_ports tms_i]

# CDC Constraints script TODO: Is this needed?
bsg_tag_add_client_cdc_timing_constraints tag_clk core_clk


