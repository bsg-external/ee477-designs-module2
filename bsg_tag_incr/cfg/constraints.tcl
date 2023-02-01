# constraints.tcl
#
# This file is where design timing constraints are defined for Genus and Innovus.
# Many constraints can be written directly into the Hammer config files. However, 
# you may manually define constraints here as well.
#

create_clock -name core_clk -period 10 [get_ports clk_i]
set_clock_uncertainty 0.276 [get_clocks core_clk]
set_input_delay  0.000 -clock core_clk [get_ports reset_i]
set_output_delay 0.000 -clock core_clk [get_ports data_o]

# Tag clock constraints script
bsg_tag_clock_create tag_clk tck_i tdi_i tms_i 20.0 1.0
# CDC Constraints script
bsg_tag_add_client_cdc_timing_constraints tag_clk core_clk


