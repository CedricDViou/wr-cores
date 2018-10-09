action= "simulation"
target= "xilinx"
syn_device="xc6slx45t"
sim_tool="modelsim"
top_module="main"
sim_top="main"

fetchto="../../../ip_cores"
vlog_opt="+incdir+../../../sim"

modules = { "local" : ["../../..",
                       "../../../modules/wr_streamers",
                       "../../../../general-cores"]}
					  
files = ["main.sv"]

