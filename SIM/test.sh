#!/bin/bash

FLAG='-v --syn-binding --workdir=ALL_LIB --work=work --ieee=synopsys --std=93c -fexplicit'
FLAG2='-v --syn-binding --workdir=ALL_LIB --work=ram_lib --ieee=synopsys --std=93c -fexplicit'

ghdl -a $FLAG ../VHDL/heapsort.vhd
ghdl -a $FLAG ../VHDL/dp256x8.vhd
ghdl -a $FLAG ../TEST/tb_heapsort.vhd

ghdl -e $FLAG tb_heapsort
ghdl -r $FLAG tb_heapsort --wave=tb_heapsort.ghw
