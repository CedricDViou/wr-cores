#!/bin/bash

mkdir -p doc
wbgen2 -D ./doc/gen10.html -C gen10_regs.h -V gen10_wishbone_slave.vhd -p gen10_wbgen2_pkg.vhd --cstyle struct --lang vhdl  -H record -K ../../sim/gen10_regs.vh wr_gen_10mhz.wb
