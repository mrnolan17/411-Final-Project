transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/EXE {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/EXE/divider.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/EXE {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/EXE/FA.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/EXE {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/EXE/HA.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/EXE {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/EXE/wallace_mul.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cache {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cache/lru_arr.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cacheline_adaptor.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/given_cache {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/given_cache/line_adapter.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/given_cache {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/given_cache/data_array.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/given_cache {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/given_cache/cache_datapath.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/given_cache {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/given_cache/cache_control.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/given_cache {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/given_cache/array.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cache {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cache/data_array_2.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cache {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cache/cache_comparator.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cache {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cache/array_2.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cache {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cache/arbiter.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cache {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cache/addr_decoder.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/IF {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/IF/pc.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/ID {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/ID/regfile.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/rv32i_mux_types.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/register.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/given_cache {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/given_cache/cache.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/rv32i_types.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cache {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cache/l2_datapath.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cache {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cache/l2_control.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/IF {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/IF/decoder.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/EXE {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/EXE/comparator.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/EXE {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/EXE/alu.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/rv32i_regfiles.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/rv32i_control_words.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cache {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cache/l2_cache.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/IF {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/IF/local_bp.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/IF {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/IF/global_bp.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/EXE {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/EXE/forwarder.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/WB {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/WB/wb_top.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/WB {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/WB/wb_datapath.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/WB {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/WB/wb_control.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/MEM {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/MEM/mem_top.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/MEM {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/MEM/mem_datapath.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/MEM {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/MEM/mem_control.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/IF {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/IF/if_top.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/IF {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/IF/if_datapath.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/IF {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/IF/if_control.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/ID {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/ID/id_top.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/ID {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/ID/id_datapath.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/ID {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/ID/id_control.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/EXE {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/EXE/exe_top.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/EXE {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/EXE/exe_control.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/regfiles_top.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/mem_wb_regfile.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/if_id_regfile.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/id_exe_regfile.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/exe_mem_regfile.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/IF {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/IF/branch_predictor_top.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/EXE {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/EXE/exe_datapath.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/cpu/cpu.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hdl {/home/andrewg3/ECE411/Team-ATM/mp4/hdl/mp4.sv}

vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hvl {/home/andrewg3/ECE411/Team-ATM/mp4/hvl/top.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hvl {/home/andrewg3/ECE411/Team-ATM/mp4/hvl/magic_dual_port.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hvl {/home/andrewg3/ECE411/Team-ATM/mp4/hvl/param_memory.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hvl {/home/andrewg3/ECE411/Team-ATM/mp4/hvl/rvfi_itf.sv}
vlog -vlog01compat -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hvl {/home/andrewg3/ECE411/Team-ATM/mp4/hvl/rvfimon.v}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hvl {/home/andrewg3/ECE411/Team-ATM/mp4/hvl/shadow_memory.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hvl {/home/andrewg3/ECE411/Team-ATM/mp4/hvl/source_tb.sv}
vlog -sv -work work +incdir+/home/andrewg3/ECE411/Team-ATM/mp4/hvl {/home/andrewg3/ECE411/Team-ATM/mp4/hvl/tb_itf.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L arriaii_hssi_ver -L arriaii_pcie_hip_ver -L arriaii_ver -L rtl_work -L work -voptargs="+acc"  mp4_tb

add wave *
view structure
view signals
run -all
