# Some file gymnastics needed for IP defenition
file copy -force ../../board/fasec/component.xml ../../.
#file delete -force ../../board/fasec/component.xml

# Create Vivado project
source ./fasec_ref_design.tcl

# Create block design
source ../../top/fasec_ref_design/system_top.tcl

# Generate the wrapper
set design_name [get_bd_designs]
make_wrapper -files [get_files $design_name.bd] -top -import
