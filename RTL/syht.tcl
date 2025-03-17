set_db init_lib_search_path {.} -quiet
read_lib gf180mcu.lib 

set_db init_hdl_search_path {.} -quiet 
read_hdl -language sv {axc_booth.v barrel_shifter.v lookahead_priority_enforcer.v transition_detect.v}                          
                           
elaborate
vcd design:axc_booth

set_time_unit -nanoseconds
create_clock [get_ports CLK] -name main_clk -period 10

set_db syn_generic_effort high -quiet 
set_db syn_map_effort high -quiet 
set_db syn_opt_effort high -quiet 

syn_generic
syn_map
syn_opt

report_timing > axc_booth_timing.rpt
report_power > axc_booth_power.rpt
report_area > axc_booth_area.rpt

puts "RUNTIME : [get_db real_runtime]"

exit