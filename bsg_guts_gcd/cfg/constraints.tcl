# constraints.tcl
#
# This file is where design timing constraints are defined for Genus and Innovus.
# Many constraints can be written directly into the Hammer config files. However, 
# you may manually define constraints here as well.
#

set CORE_CLOCK_PERIOD      20
set IO_MASTER_CLOCK_PERIOD 20

# Use pre-built constraints generation script
bsg_chip_timing_constraint    \
    ucsd_bsg_332              \
    [get_ports p_reset_i]     \
    [get_ports p_misc_L_4_i]  \
    core_clk                  \
    ${CORE_CLOCK_PERIOD}      \
    [get_ports p_PLL_CLK_i]   \
    master_io_clk             \
    ${IO_MASTER_CLOCK_PERIOD} \
    1                         \
    1                         \
    0                         \
    0                         \
    0                         \
    0                         \
    0 

# bsg_chip_timing_constraint                          \
#     -package ucsd_bsg_332                           \
#     -reset_port [get_ports p_reset_i]               \
#     -core_clk_port [get_ports p_misc_L_4_i]         \
#     -core_clk_name core_clk                         \
#     -core_clk_period ${CORE_CLOCK_PERIOD}           \
#     -master_io_clk_port [get_ports p_PLL_CLK_i]     \
#     -master_io_clk_name master_io_clk               \
#     -master_io_clk_period ${IO_MASTER_CLOCK_PERIOD} \
#     -create_core_clk 1                              \
#     -create_master_clk 1                            \
#     -input_cell_rise_fall_difference    0           \
#     -output_cell_rise_fall_difference_A 0           \
#     -output_cell_rise_fall_difference_B 0           \
#     -output_cell_rise_fall_difference_C 0           \
#     -output_cell_rise_fall_difference_D 0 