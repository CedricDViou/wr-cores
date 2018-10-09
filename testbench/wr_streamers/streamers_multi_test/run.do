# make -f Makefile > /dev/null 2>&1 
vsim -t 1ps -L unisim work.main -novopt -suppress 8684,8683 
#-sv_seed random 


set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do wave.do
run 50us
wave zoomfull
radix -dec

