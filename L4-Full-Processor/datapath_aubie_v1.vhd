-- datapath_aubie.vhd
USE work.dlx_types.ALL;
USE work.bv_arithmetic.ALL;


entity alu is
    generic(prop_delay: Time := 5 ns);
    port(
        operand1,
        operand2 : in dlx_word;
        operation : in alu_operation_code;
        result : out dlx_word;
        error : out error_code
    );
end entity alu;

architecture logic of alu is
begin
    alu_operation: process(operand1, operand2, operation) is
        variable overflow : boolean := false;
        variable operation_result : dlx_word;
        variable divide_by_zero: boolean;
    begin
        error <= "0000";
        case operation is
            when "0000" => -- unsigned add
                bv_addu(operand1, operand2, operation_result, overflow);
                if overflow then
                    error <= "0001" after prop_delay;
                end if;
                result <= operation_result after prop_delay;
            when "0001" => -- unsigned subtract
                bv_subu(operand1, operand2, operation_result, overflow);
                if overflow then
                    error <= "0010" after prop_delay;
                end if;
                result <= operation_result after prop_delay;
            when "0010" => -- two's complement add
                bv_add(operand1, operand2, operation_result, overflow);
                if overflow then
                    if operand1(31) = '0' AND operand2(31) = '0' then
                        error <= "0001" after prop_delay;
                    else
                        error <= "0010" after prop_delay;
                    end if;
                end if;
                result <= operation_result after prop_delay;
            when "0011" => -- two's complement subtract
                bv_sub(operand1, operand2, operation_result, overflow);
                if overflow then
                    if operand1(31) = '0' then
                        error <= "0001" after prop_delay;
                    else
                        error <= "0010" after prop_delay;
                    end if;
                end if;
                result <= operation_result after prop_delay;
            when "0100" => -- two's complement multiply
                bv_mult(operand1, operand2, operation_result, overflow);
                if overflow then
                    if operand1(31) = operand2(31) then
                        error <= "0001" after prop_delay;
                    else
                        error <= "0010" after prop_delay;
                    end if;
                end if;
                result <= operation_result after prop_delay;
            when "0101" => -- two's complement divide
                bv_div(operand1, operand2, operation_result, divide_by_zero, overflow);
                if divide_by_zero then
                    error <= "0101" after prop_delay;
                end if;
                result <= operation_result after prop_delay;
            when "0110" => -- logical AND
                if operand1 /= x"00000000" AND operand2 /= x"00000000" then
                    result <= x"00000001" after prop_delay;
                else
                    result <= x"00000000" after prop_delay;
                end if;
            when "0111" => -- bitwise AND
                result <= operand1 AND operand2 after prop_delay;
            when "1000" => -- logical OR
                if operand1 /= x"00000000" OR operand2 /= x"00000000" then
                    result <= x"00000001" after prop_delay;
                else
                    result <= x"00000000" after prop_delay;
                end if;
            when "1001" => -- bitwise OR
                result <= operand1 OR operand2 after prop_delay;
            when "1010" => -- logical NOT of operand1
                if operand1 /= x"00000000" then
                    result <= x"00000001" after prop_delay;
                else
                    result <= x"00000000" after prop_delay;
                end if;
            when "1011" => -- bitwise NOT of operand1
                result <= NOT operand1 after prop_delay;
            when others =>
                result <= x"00000000";
        end case;
    end process alu_operation;
end architecture logic;


USE work.dlx_types.ALL;

entity dlx_register is
    generic(prop_delay: Time := 5 ns);
    port(
        clock : in bit;
        in_val : in dlx_word;
        out_val : out dlx_word
    );
end entity dlx_register;

architecture logic of dlx_register is
begin
    dlx_register: process(in_val, clock) is
    begin
        if clock = '1' then
            out_val <= in_val after prop_delay;
        end if;
    end process dlx_register;
end architecture logic;


USE work.dlx_types.ALL;
USE work.bv_arithmetic.ALL;

entity reg_file is
    generic(prop_delay: Time := 5 ns);
    port(
        clock,
        readnotwrite : in bit;
        reg_number : in register_index;
        data_in : in dlx_word;
        data_out : out dlx_word
    );
end entity reg_file;

architecture logic of reg_file is
    type reg_type is array (0 to 31) of dlx_word;
begin
    reg_file: process(clock, readnotwrite, reg_number, data_in) is
        variable registers : reg_type;
    begin
        if clock = '1' then
            if readnotwrite = '1' then -- read
                data_out <= registers(bv_to_integer(reg_number)) after prop_delay;
            else -- write
                registers(bv_to_integer(reg_number)) := data_in;
            end if;
        end if;
    end process reg_file;
end architecture logic;


USE work.dlx_types.ALL;
USE work.bv_arithmetic.ALL;

entity pcplusone is
	generic(prop_delay: Time := 5 ns); 
	port(
        clock : in bit;
        input : in dlx_word;
        output : out dlx_word
    ); 
end entity pcplusone; 

architecture logic of pcplusone is 
begin
	plusone: process(input, clock) is  -- add clock input to make it execute
		variable newpc: dlx_word;
		variable error: boolean; 
	begin
	    if clock'event and clock = '1' then
            bv_addu(input, "00000000000000000000000000000001", newpc, error);
            output <= newpc after prop_delay;
	    end if; 
	end process plusone;
end architecture logic; 


USE work.dlx_types.ALL; 

entity mux is
    generic(prop_delay: Time := 5 ns);
    port(
        which : in bit;
        input_1,
        input_0 : in dlx_word;
        output : out dlx_word
    );
end entity mux;

architecture logic of mux is
begin
    mux_process: process(input_1, input_0, which) is
    begin
        if which = '1' then
            output <= input_1 after prop_delay;
        else
            output <= input_0 after prop_delay;
        end if;
    end process mux_process;
end architecture logic;



USE work.dlx_types.ALL; 

entity threeway_mux is
    generic(prop_delay: Time := 5 ns);
    port(
        input_2,
        input_1,
        input_0 : in dlx_word;
        which : in threeway_muxcode;
        output : out dlx_word
    );
end entity threeway_mux;

architecture logic of threeway_mux is
begin
    mux_process: process(input_1, input_0, which) is
    begin
        if which = "10" or which = "11" then
            output <= input_2 after prop_delay;
        elsif which = "01" then 
            output <= input_1 after prop_delay; 
        else
            output <= input_0 after prop_delay;
        end if;
    end process mux_process;
end architecture logic;


USE work.dlx_types.ALL;
USE work.bv_arithmetic.ALL;

entity memory is
    port (
        clock,
        readnotwrite : in bit;
        address,
        data_in : in dlx_word;
        data_out : out dlx_word
    ); 
end memory;

architecture logic of memory is
begin
    mem_behav: process(address,clock) is
        type memtype is array (0 to 1024) of dlx_word;
        variable data_memory : memtype;
    begin
        data_memory(0) :=  X"30200000"; --LD R4, 256
        data_memory(1) :=  X"00000100"; -- address 0x100

        data_memory(2) :=  X"30080000"; -- LD R1, 257
        data_memory(3) :=  X"00000101"; -- address 0x101

        
        data_memory(4) :=  X"30100000"; -- LD R2, 258
        data_memory(5) :=  X"00000102"; -- address 0x102

        data_memory(6) :=  "00000000000110000100010000000000"; -- ADDU R3, R1, R2

        data_memory(7) :=  "00100000000000001100000000000000"; -- STO R3, 0x103
        data_memory(8) :=  x"00000103"; -- address 0x103
        
        data_memory(9) :=  "00110001000000000000000000000000"; -- LDI R0, 0x104
        data_memory(10) := x"00000104"; -- 0x104

        data_memory(11) := "00100010000000001100000000000000"; -- STOR (R0), R3
        
        data_memory(12) := "00110010001010000000000000000000"; -- LDR R5, (R0)
        
        data_memory(13) := x"40000000"; -- JMP to 261
        data_memory(14) := x"00000105";

        data_memory(256) := "01010101000000001111111100000000"; -- 256
        data_memory(257) := "10101010000000001111111100000000"; -- 257
        data_memory(258) := "00000000000000000000000000000001"; -- 258
        
        data_memory(261) :=  x"00584400"; -- ADDU R11, R1, R2
        
        data_memory(262) := x"4101C000"; -- JZ R7, 267 If R7 == 0, GOTO Addr 267
        data_memory(263) := x"0000010B";

        data_memory(267) := x"00604400"; -- ADDU R12, R1, R2
        
        data_memory(268) := x"10000000"; -- NOOP

        if clock = '1' then
            if readnotwrite = '1' then
                data_out <= data_memory(bv_to_natural(address)) after 5 ns;
            else
                data_memory(bv_to_natural(address)) := data_in; 
            end if;
        end if;
    end process mem_behav; 
end logic;
