vsim dlx_register
add wave -position insertpoint sim:/dlx_register/*

run 50
force -freeze sim:/dlx_register/in_val 32'hFFFFFFFF 0
run 50
force -freeze sim:/dlx_register/in_val 32'h00000000 50
run 50
force -freeze sim:/dlx_register/clock 1 0
run 50
force -freeze sim:/dlx_register/in_val 32'hFFFFFFFF 0
run 50
force -freeze sim:/dlx_register/in_val 32'h00000000 50
