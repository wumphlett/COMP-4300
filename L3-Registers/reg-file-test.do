vsim reg_file
add wave -position insertpoint sim:/reg_file/*

run 50
force -freeze sim:/reg_file/reg_number 5'h0A 0
force -freeze sim:/reg_file/data_in 32'h11111111 0
run 50
force -freeze sim:/reg_file/clock 1 0
run 50
force -freeze sim:/reg_file/reg_number 5'h0A 0
force -freeze sim:/reg_file/data_in 32'h22222222 0
run 50
force -freeze sim:/reg_file/readnotwrite 1
run 50
force -freeze sim:/reg_file/reg_number 5'h0A 0 5'h0F 0
run 50
