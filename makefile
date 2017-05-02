
.PHONY: all test clean sim list

list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | xargs

all:
# types and funs
	ghdl -a defs.vhd
	ghdl -a util.vhd
	ghdl -a --ieee=synopsys rand.vhd # dependency for [usb,gfx,cpu,memory,uart].vhd
	ghdl -a --ieee=synopsys test.vhd # Test configuration
# data structs
	ghdl -a arbiter.vhd
	ghdl -a arbiter2.vhd
	ghdl -a arbiter2_ack.vhd
#	ghdl -a arbiter3.vhd # not used
	ghdl -a fifo.vhd # dependency for [pwr,cache,ic].vhd
# modules
#	ghdl -a gfx.vhd
	ghdl -a pwr.vhd # uses fifo
	ghdl -a --ieee=synopsys mem.vhd
	ghdl -a -fexplicit cache.vhd # uses fifo, arbiter2
	ghdl -a --ieee=synopsys cpu.vhd
	ghdl -a pwr.vhd
	ghdl -a arbiter6.vhd
	ghdl -a arbiter6_ack.vhd
	ghdl -a arbiter61.vhd
	ghdl -a arbiter7.vhd
	ghdl -a --ieee=synopsys ic.vhd # uses fifo, arbiter2,6,61,7
#	ghdl -a --ieee=synopsys gfx.vhd
#	ghdl -a audio.vhd
#	ghdl -a usb.vhd
#	ghdl -a uart.vhd
	ghdl -a --ieee=synopsys peripheral.vhd # generic peripheral
# simulation
	ghdl -a --ieee=synopsys top.vhd
	ghdl -e --ieee=synopsys top
topnsim:
	ghdl -a --ieee=synopsys top.vhd
	ghdl -e --ieee=synopsys top
	./top --vcd=top.vcd
clean:
	rm *.o *.vcd
rand:
#	python rand.py -c 15 -o "rand_ints4b.txt" # use opts -n and -c to set count and max
#	python rand.py -c 63 -o "rand_ints7b.txt" # 2^6 - 1
	python rand.py -c 127 -o "rand_ints8b.txt" # 2^7 - 1
#	python rand.py -c 511 -o "rand_ints10b.txt" # 2^9 - 1
#	python rand.py -c 2147483648 -o "rand_ints32b.txt" # 2^31 - 1
showtree:
	./top --no-run --disp-tree
sim:
#	./top --stop-time=100ps --vcd=top.vcd
	./top --stop-time=10ns --vcd=top.vcd
# TODO need to adjust parameters here
# see http://ghdl.readthedocs.io/en/latest/Simulation_and_runtime.html#simulation-and-runtime
wave:
	gtkwave top.vcd
html_docs:
	vhdocl *.vhd
sm_docs: # generate state machines
	graph-easy --input=doc/arbiter2_sm.txt --output=doc/arbiter2.ascii
	graph-easy --input=doc/arbiter2_ack_sm.txt --output=doc/arbiter2_ack.ascii
	graph-easy --input=doc/cpu_sm.txt --output=doc/cpu.ascii
flow_docs:
	graph-easy --input=doc/flow/pwr.txt --output=doc/flow/pwr.ascii
	graph-easy --input=doc/flow/upr.txt --output=doc/flow/upr.ascii
	graph-easy --input=doc/flow/dnr.txt --output=doc/flow/dnr.ascii
deps_docs:
	graph-easy --input=doc/deps.txt --output=doc/deps.ascii
test_docs:
	graph-easy --input=doc/test/cpu1r.txt --output=doc/test/cpu1r.ascii
	sed -i.old '1s;^;#cpu1_r_test\n\n;' doc/test/cpu1r.ascii
	graph-easy --input=doc/test/cpu2w.txt --output=doc/test/cpu2w.ascii
	sed -i.old '1s;^;#cpu2_w_test\n\n;' doc/test/cpu2w.ascii
	graph-easy --input=doc/test/ureq.txt --output=doc/test/ureq.ascii
	sed -i.old '1s;^;#gfx_r_test\n\n;' doc/test/ureq.ascii
	graph-easy --input=doc/test/pwr.txt --output=doc/test/pwr.ascii
	sed -i.old '1s;^;#ic_pwr_test\n\n;' doc/test/pwr.ascii
	rm doc/test/*.old
block_docs:
	graph-easy --input=doc/block/cpu.txt --output=doc/block/cpu.ascii
	sed -i.old '1s;^;#cpu_block\n\n;' doc/block/cpu.ascii
	graph-easy --input=doc/block/top.txt --output=doc/block/top.ascii
	sed -i.old '1s;^;#top_block\n\n;' doc/block/top.ascii
	graph-easy --input=doc/block/cache.txt --output=doc/block/cache.ascii
	sed -i.old '1s;^;#cache_block\n\n;' doc/block/cache.ascii
	graph-easy --input=doc/block/ic.txt --output=doc/block/ic.ascii
	sed -i.old '1s;^;#ic_block\n\n;' doc/block/ic.ascii
	rm doc/block/*.old
