

set FLAG=-v -PALL_LIB --syn-binding --ieee=synopsys --std=93c -fexplicit

ghdl -a --work=WORK --workdir=ALL_LIB %FLAG% ..\VHDL\heapsort.vhd
ghdl -a --work=RAM_LIB --workdir=ALL_LIB %FLAG% ..\VHDL\dp256x8.vhd
ghdl -a --work=WORK --workdir=ALL_LIB %FLAG% ..\TEST\tb_heapsort.vhd


ghdl -e --work=WORK --workdir=ALL_LIB %FLAG% tb_heapsort
ghdl -r --work=WORK --workdir=ALL_LIB %FLAG% tb_heapsort --wave=tb_heapsort.ghw
