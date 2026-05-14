set_property SRC_FILE_INFO {cfile:{G:/Faculty/Third year/Micro/Pipelined_Processor.srcs/constrs_1/new/Constraints.xdc} rfile:../Pipelined_Processor.srcs/constrs_1/new/Constraints.xdc id:1} [current_design]
set_property src_info {type:XDC file:1 line:51 export:INPUT save:INPUT read:READ} [current_design]
set_multicycle_path -setup 2 -from [get_pins -hierarchical -filter {NAME =~ "*Von_Neumann_Mem/*"}] -to [get_pins -hierarchical -filter {NAME =~ "*MWB/*"}]
set_property src_info {type:XDC file:1 line:52 export:INPUT save:INPUT read:READ} [current_design]
set_multicycle_path -hold 1 -from [get_pins -hierarchical -filter {NAME =~ "*Von_Neumann_Mem/*"}] -to [get_pins -hierarchical -filter {NAME =~ "*MWB/*"}]
set_property src_info {type:XDC file:1 line:56 export:INPUT save:INPUT read:READ} [current_design]
set_multicycle_path -hold 1 -from [get_pins -hierarchical -filter {NAME =~ "*DEX/*"}] -to [get_pins -hierarchical -filter {NAME =~ "*EXM/*"}]
set_property src_info {type:XDC file:1 line:62 export:INPUT save:INPUT read:READ} [current_design]
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ "*RF/*"}] -to [get_pins -hierarchical -filter {NAME =~ "*ALU_unit/*"}] 12.0
set_property src_info {type:XDC file:1 line:65 export:INPUT save:INPUT read:READ} [current_design]
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ "*ALU_unit/*"}] -to [get_pins -hierarchical -filter {NAME =~ "*Von_Neumann_Mem/*"}] 12.0
set_property src_info {type:XDC file:1 line:68 export:INPUT save:INPUT read:READ} [current_design]
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ "*FU/*"}] 10.0
set_property src_info {type:XDC file:1 line:117 export:INPUT save:INPUT read:READ} [current_design]
set_property RAM_STYLE block [get_cells -hierarchical -filter {NAME =~ "*Von_Neumann_Mem/memory_reg*"}]
set_property src_info {type:XDC file:1 line:120 export:INPUT save:INPUT read:READ} [current_design]
set_property KEEP true [get_nets -hierarchical -filter {NAME =~ "*valid_out*"}]
set_property src_info {type:XDC file:1 line:121 export:INPUT save:INPUT read:READ} [current_design]
set_property KEEP true [get_nets -hierarchical -filter {NAME =~ "*jump_now*"}]
set_property src_info {type:XDC file:1 line:122 export:INPUT save:INPUT read:READ} [current_design]
set_property KEEP true [get_nets -hierarchical -filter {NAME =~ "*pcEnable*"}]
set_property src_info {type:XDC file:1 line:123 export:INPUT save:INPUT read:READ} [current_design]
set_property KEEP true [get_nets -hierarchical -filter {NAME =~ "*Flush*"}]
set_property src_info {type:XDC file:1 line:164 export:INPUT save:INPUT read:READ} [current_design]
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ "*HU/*"}] 8.0
set_property src_info {type:XDC file:1 line:167 export:INPUT save:INPUT read:READ} [current_design]
set_max_delay -datapath_only -from [get_pins -hierarchical -filter {NAME =~ "*JU/*"}] -to [get_pins -hierarchical -filter {NAME =~ "*PC_unit/*"}] 10.0
set_property src_info {type:XDC file:1 line:181 export:INPUT save:INPUT read:READ} [current_design]
set_property CLOCK_GATING true [get_cells -hierarchical -filter {NAME =~ "*"}]
