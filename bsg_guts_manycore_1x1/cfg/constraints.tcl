# constraints.tcl
#
# This file is where design timing constraints are defined for Genus and Innovus.
# Many constraints can be written directly into the Hammer config files. However, 
# you may manually define constraints here as well.
#

set CORE_CLOCK_PERIOD      25
set IO_MASTER_CLOCK_PERIOD 40

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
