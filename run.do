vlib work
vlog ALSU.v tb.v
vsim -voptargs=+acc work.ALSU_tb
add wave *
run -all
#quit -sim
