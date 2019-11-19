#!/bin/bash

FLAG='-v --syn-binding --workdir=ALL_LIB --work=work --ieee=synopsys --std=93c -fexplicit'

ghdl -a $FLAG ../VHDL/heapsort.vhd
# ghdl -a $FLAG tb_timer.vhd
ghdl -e $FLAG heapsort
# ghdl -r $FLAG TB_TIMER --vcd=timer.vcd
