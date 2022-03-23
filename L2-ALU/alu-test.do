vsim alu
add wave -position insertpoint sim:/alu/*

# Test for unsigned addition 
# Show that addition works for nominal operands
# 	operand1 = 0xff(255)
#	operand2 = 0x15(21)
#	expectedResult = 0x144(276)
#	expectedError = 0x0
force -freeze sim:/alu/operation 4'h0 0
force -freeze sim:/alu/operand1 32'h000000ff 0
force -freeze sim:/alu/operand2 32'h00000015 0
run
# Show that overflow returns proper error
#	operand1 = 0xffffffff
#	operand2 = 0x1(1)
#	expectedResult = 0x0
#	expectedError = 0x1 (overflow)
force -freeze sim:/alu/operand1 32'hffffffff 0
force -freeze sim:/alu/operand2 32'h00000001 0
run
pause
# Test for unsigned subtraction
# Show that subtraction works for nominal operands
#	operand1 = 0xff (255)
#	operand2 = 0x1 (1)
#	expectedResult = 0xfe (254)
#	expectedError = 0x0
resume
force -freeze sim:/alu/operand1 32'h000000ff 0
force -freeze sim:/alu/operand2 32'h00000001 0
force -freeze sim:/alu/operation 4'h1 0
run

# Show that underflow returns proper error
# 	operand1 = 0x0 
#	operand2 = 0xffffffff
#	expectedResult = 0x1
#	expectedError = 0x2 (underflow)
force -freeze sim:/alu/operand1 32'h00000000 0
force -freeze sim:/alu/operand2 32'hffffffff 0
run
pause

# Test for signed addition
# Show that signed addition works for nominal operands
#	operand1 = 0xffffffff
#	operand2 = 0x1
#	expectedResult = 0x0
#	expectedError = 0x0
force -freeze sim:/alu/operand1 32'hffffffff 0
force -freeze sim:/alu/operand2 32'h00000001 0
force -freeze sim:/alu/operation 4'h2 0
run
# Show that operation returns proper under/overflow
#	operand1 = 0x7fffffff
#	operand2 = 0xf
#	expectedResult = 0x8000000e
#	expectedError = 0x1 (overflow)
force -freeze sim:/alu/operand1 32'h7fffffff 0
force -freeze sim:/alu/operand2 32'h0000000f 0
run
pause
# Test for signed subtraction
# Show that signed subtraction works for nominal operands
#	operand1 = 0x0
#	operand2 = 0x1
#	expectedResult = 0xffffffff
#	expectedError = 0x0
force -freeze sim:/alu/operand1 32'h00000000 0
force -freeze sim:/alu/operand2 32'h00000001 0
force -freeze sim:/alu/operation 4'h3 0
run

# Show that operation returns proper under/overflow
#	operand1 = 0x7fffffff
#	operand2 = 0x80000000
#	expectedResult = 
#	expectedError = 0x1 (overflow)
force -freeze sim:/alu/operand1 32'h7fffffff 0
force -freeze sim:/alu/operand2 32'h80000000 0
run
pause

# Test for signed multiplication
# Show that signed multiplication workds for nominal operands
#	operand1 = 0x5
#	operand2 = 0x3
#	expectedResult = 0xf
#	expectedError = 0x0
force -freeze sim:/alu/operand1 32'h00000003 0
force -freeze sim:/alu/operand2 32'h00000005 0
force -freeze sim:/alu/operation 4'h4 0
run
# Show proper error
#	operand1 = 0x80000000
#	operand2 = 0x7fffffff
#	expectedResult =
#	expectedError = 0x2 (underflow)
force -freeze sim:/alu/operand1 32'h80000000 0
force -freeze sim:/alu/operand2 32'h7fffffff 0
run
pause
# Test for signed division
# Show that signed division works for nominal operands
#	operand1 = 0x4
#	operand2 = 0x2
#	expectedResult = 0x2
#	expectedError = 0x0
force -freeze sim:/alu/operand1 32'h00000004 0
force -freeze sim:/alu/operand2 32'h00000002 0
force -freeze sim:/alu/operation 4'h5 0
run
pause

# Test for Logical AND (&&)
# Show that operation works for only case that returns TRUE
#	operand1 = 0x10000000
#	operand2 = 0x10101011
#	expectedResult = 0x00000001
#	expectedError = 0x0
force -freeze sim:/alu/operand1 32'h10000000 0
force -freeze sim:/alu/operand2 32'h10101011 0
force -freeze sim:/alu/operation 4'h6
run
pause
# Test for Bitwise AND (&)
# Show that operation properly performs bitwise and
# 	operand1 = 0x10101010
#	operand2 = 0x01010101
#	expectedResult = 0x00000000
#	expectedError = 0x0
force -freeze sim:/alu/operand1 32'h10101010 0
force -freeze sim:/alu/operand2 32'h01010101 0
force -freeze sim:/alu/operation 4'h7 0
run
pause

# Test for Logical OR (||)
# Show that operation properly returns 0 for only case
#	operand1 = 0x00000000
#	operand2 = 0x00000000
#	expectedResult = 0x0
#	expectedError = 0x0
force -freeze sim:/alu/operand1 32'h00000000 0
force -freeze sim:/alu/operand2 32'h00000000 0
force -freeze sim:/alu/operation 4'h8 0
run
pause
# Test for Bitwise OR (|)
# Show that operation properly performs bitwise or
# 	operand1 = 0xf0f0f0f0
#	operand2 = 0x0f0f0f0f
#	expectedResult = 0xffffffff
#	expectedError = 0x0
force -freeze sim:/alu/operand1 32'hf0f0f0f0 0
force -freeze sim:/alu/operand2 32'h0f0f0f0f 0
force -freeze sim:/alu/operation 4'h9 0
run
pause

# Test for Logical NOT (!)
# Show that operation properly performs logical not
# 	operand1 = 0x00000000
#	expectedResult = 0x00000001
#	expectedError = 0x0
force -freeze sim:/alu/operand1 32'h00000000 0
force -freeze sim:/alu/operation 4'ha 0
run
pause

# Test for Bitwise NOT (~)
# Show that operation properly performs bitwise not
# 	operand1 = 0xf0f0f0f0
#	expectedResult = 0x0f0f0f0f
#	expectedError = 0x0
force -freeze sim:/alu/operand1 32'hf0f0f0f0 0
force -freeze sim:/alu/operation 4'hb 0
run
pause

# Test for non-existant operation
#	expectedResult = 0x00000000
force -freeze sim:/alu/operation 4'hc 0
run
