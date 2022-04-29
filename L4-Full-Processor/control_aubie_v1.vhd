USE work.bv_arithmetic.ALL; 
USE work.dlx_types.ALL; 

entity aubie_controller is
    generic(prop_delay: Time := 5 ns);
	port(
        ir_control : in dlx_word;
        alu_out : in dlx_word; 
        alu_error : in error_code; 
        clock : in bit; 
        regfilein_mux : out threeway_muxcode; 
        memaddr_mux : out threeway_muxcode; 
        addr_mux : out bit; 
        pc_mux : out threeway_muxcode;
        alu_func : out alu_operation_code; 
        regfile_index : out register_index;
        regfile_readnotwrite : out bit; 
        regfile_clk : out bit;   
        mem_clk : out bit;
        mem_readnotwrite : out bit;  
        ir_clk : out bit; 
        imm_clk : out bit; 
        addr_clk : out bit;  
        pc_clk : out bit; 
        op1_clk : out bit; 
        op2_clk : out bit; 
        result_clk : out bit
	); 
end aubie_controller; 

architecture logic of aubie_controller is
begin
	behav: process(clock) is 
		type state_type is range 1 to 20; 
		variable state: state_type := 1; 
		variable opcode: byte; 
		variable destination, operand1, operand2 : register_index; 
	begin
		if clock'event and clock = '1' then
            opcode := ir_control(31 downto 24);
            destination := ir_control(23 downto 19);
            operand1 := ir_control(18 downto 14);
            operand2 := ir_control(13 downto 9); 
            case state is
                when 1 =>
                    memaddr_mux <= "00" after prop_delay;
                    regfile_clk <= '0' after prop_delay;
                    mem_clk	<= '1' after prop_delay;
                    mem_readnotwrite <= '1' after prop_delay;
                    ir_clk <= '1' after prop_delay;
                    imm_clk <= '0' after prop_delay;
                    addr_clk <= '0' after prop_delay;
                    addr_mux <= '1' after prop_delay;
                    pc_clk <= '0' after prop_delay;
                    op1_clk	<= '0' after prop_delay;
                    op2_clk	<= '0' after prop_delay;
                    result_clk <= '0' after prop_delay;

                    state := 2; 
                when 2 =>
                    if opcode(7 downto 4) = "0000" then -- ALU op
                        state := 3; 
                    elsif opcode = X"20" then  -- STO
                        state := 9;
                    elsif opcode = X"30" or opcode = X"31" then -- LD or LDI
                        state := 7;
                    elsif opcode = X"22" then -- STOR
                        state := 14;
                    elsif opcode = X"32" then -- LDR
                        state := 12;
                    elsif opcode = X"40" or opcode = X"41" then -- JMP or JZ
                        state := 16;
                    elsif opcode = X"10" then -- NOOP
                        state := 19;
                    else -- error
                    end if; 
                when 3 => 
                    regfile_index <= operand1 after prop_delay;
                    regfile_readnotwrite <= '1' after prop_delay;
                    regfile_clk <= '1' after prop_delay;
                    mem_clk <= '0' after prop_delay;
                    ir_clk <= '0' after prop_delay;
                    imm_clk <= '0' after prop_delay;
                    addr_clk <= '0' after prop_delay;
                    pc_clk <= '0' after prop_delay;
                    op1_clk <= '1' after prop_delay;
                    op2_clk <= '0' after prop_delay;
                    result_clk <= '0' after prop_delay;
                
                    state := 4; 
                when 4 => 
                    regfile_index <= operand2 after prop_delay;
                    regfile_readnotwrite <= '1' after prop_delay;
                    regfile_clk <= '1' after prop_delay;
                    mem_clk <= '0' after prop_delay;
                    ir_clk <= '0' after prop_delay;
                    imm_clk <= '0' after prop_delay;
                    addr_clk <= '0' after prop_delay;
                    pc_clk <= '0' after prop_delay;
                    op1_clk <= '0' after prop_delay;
                    op2_clk <= '1' after prop_delay;
                    result_clk <= '0' after prop_delay;

                    state := 5; 
                when 5 => 
                    alu_func <= opcode(3 downto 0) after prop_delay;
                    regfile_clk <= '0' after prop_delay;
                    mem_clk <= '0' after prop_delay;
                    ir_clk <= '0' after prop_delay;
                    imm_clk <= '0' after prop_delay;
                    addr_clk <= '0' after prop_delay;
                    pc_clk <= '0' after prop_delay;
                    op1_clk <= '0' after prop_delay;
                    op2_clk <= '0' after prop_delay;
                    result_clk <= '1' after prop_delay;
                    
                    state := 6; 
                when 6 => 
                    regfilein_mux <= "00" after prop_delay;
                    pc_mux <= "00" after prop_delay;
                    regfile_index <= destination after prop_delay;
                    regfile_readnotwrite <= '0' after prop_delay;
                    regfile_clk <= '1' after prop_delay;
                    ir_clk <= '0' after prop_delay;
                    imm_clk <= '0' after prop_delay;
                    addr_clk <= '0' after prop_delay;
                    pc_clk <= '1' after prop_delay;
                    op1_clk <= '0' after prop_delay;
                    op2_clk <= '0' after prop_delay;
                    result_clk <= '0' after prop_delay;

                    state := 1; 
                when 7 =>
                    pc_clk <= '1' after prop_delay;
                    pc_mux <= "00" after prop_delay;
                    memaddr_mux <= "00" after prop_delay;

                    if opcode = X"30" then
                        addr_mux <= '1' after prop_delay;
                    end if;

                    regfile_clk <= '0' after prop_delay;
                    mem_clk <= '1' after prop_delay;
                    mem_readnotwrite <= '1' after prop_delay;
                    ir_clk <= '0' after prop_delay;

                    if opcode = x"30" then -- LD
                        imm_clk <= '0' after prop_delay;
                        addr_clk <= '1' after prop_delay;
                    elsif opcode = x"31" then -- LDI
                        imm_clk <= '1' after prop_delay;
                        addr_clk <= '0' after prop_delay;
                    end if;
                    
                    op1_clk <= '0' after prop_delay;
                    op2_clk <= '0' after prop_delay;
                    result_clk <= '0' after prop_delay;

                    state := 8; 
                when 8 =>
                    if opcode = x"30" then -- LD
                        regfilein_mux <= "01" after prop_delay;
                        memaddr_mux <= "01" after prop_delay;
                    elsif opcode = x"31" then -- LDI
                        regfilein_mux <= "10" after prop_delay;
                    end if;

                    regfile_index <= destination after prop_delay;
                    regfile_readnotwrite <= '0' after prop_delay;
                    regfile_clk <= '1' after prop_delay;

                    if opcode = x"30" then -- LD
                        mem_clk <= '1' after prop_delay;
                        mem_readnotwrite <= '1' after prop_delay;
                    elsif opcode = x"31" then -- LDI
                        mem_clk <= '0' after prop_delay;
                    end if;

                    ir_clk <= '0' after prop_delay;

                    if opcode = x"30" then -- LD
                        imm_clk <= '0' after prop_delay;
                    elsif opcode = x"31" then -- LDI
                        imm_clk <= '1' after prop_delay;
                    end if;

                    addr_clk <= '0' after prop_delay;
                    op1_clk <= '0' after prop_delay;
                    op2_clk <= '0' after prop_delay;
                    result_clk <= '0' after prop_delay;
                    pc_clk <= '0' after prop_delay, '1' after prop_delay * 3; 
                    pc_mux <= "00" after prop_delay * 3;

                    state := 1;
                when 9 =>
                    pc_mux <= "00" after prop_delay;
                    pc_clk <= '1' after prop_delay;

                    state := 10;
                when 10 =>
                    memaddr_mux <= "00" after prop_delay;
                    addr_mux <= '1' after prop_delay;
                    regfile_clk <= '0' after prop_delay;
                    mem_clk <= '1' after prop_delay;
                    mem_readnotwrite <= '1' after prop_delay;
                    ir_clk <= '0' after prop_delay;
                    imm_clk <= '0' after prop_delay;
                    addr_clk <= '1' after prop_delay;
                    pc_clk <= '0' after prop_delay;
                    op1_clk <= '0' after prop_delay;
                    op2_clk <= '0' after prop_delay;
                    result_clk <= '0' after prop_delay;

                    state := 11;
                when 11 =>
                    memaddr_mux <= "00" after prop_delay;
                    pc_mux <= "01" after prop_delay, "00" after prop_delay * 3;
                    regfile_index <= operand1 after prop_delay;
                    regfile_readnotwrite <= '1' after prop_delay;
                    regfile_clk <= '1' after prop_delay;
                    mem_clk <= '1' after prop_delay;
                    mem_readnotwrite <= '0' after prop_delay;
                    ir_clk <= '0' after prop_delay;
                    imm_clk <= '0' after prop_delay;
                    addr_clk <= '0' after prop_delay;
                    pc_clk <= '1' after prop_delay;
                    op1_clk <= '0' after prop_delay;
                    op2_clk <= '0' after prop_delay;
                    result_clk <= '0' after prop_delay;

                    state := 1;
                when 12 =>
                    addr_mux <= '0' after prop_delay;
                    regfile_index <= operand1 after prop_delay;
                    regfile_readnotwrite <= '1' after prop_delay;
                    regfile_clk <= '1' after prop_delay;
                    mem_clk <= '0' after prop_delay;
                    ir_clk <= '0' after prop_delay;
                    imm_clk <= '0' after prop_delay;
                    addr_clk <= '1' after prop_delay;
                    pc_clk <= '0' after prop_delay;
                    op1_clk <= '0' after prop_delay;
                    op2_clk <= '0' after prop_delay;
                    result_clk <= '0' after prop_delay;

                    state := 13;
                when 13 =>
                    regfilein_mux <= "01" after prop_delay;
                    memaddr_mux <= "01" after prop_delay;
                    regfile_index <= destination after prop_delay;
                    regfile_readnotwrite <= '0' after prop_delay;
                    regfile_clk <= '1' after prop_delay;
                    mem_clk <= '1' after prop_delay;
                    mem_readnotwrite <= '1' after prop_delay;
                    ir_clk <= '0' after prop_delay;
                    imm_clk <= '0' after prop_delay;
                    addr_clk <= '0' after prop_delay;
                    op1_clk <= '0' after prop_delay;
                    op2_clk <= '0' after prop_delay;
                    result_clk <= '0' after prop_delay;
                    pc_clk <= '0' after prop_delay, '1' after prop_delay * 3;
                    pc_mux <= "00" after prop_delay * 3;

                    state := 1;
                when 14 =>
                    addr_mux <= '0' after prop_delay;
                    regfile_index <= destination after prop_delay;
                    regfile_readnotwrite <= '1' after prop_delay;
                    regfile_clk <= '1' after prop_delay;
                    mem_clk <= '0' after prop_delay;
                    ir_clk <= '0' after prop_delay;
                    imm_clk <= '0' after prop_delay;
                    addr_clk <= '1' after prop_delay;
                    pc_clk <= '0' after prop_delay;
                    op1_clk <= '0' after prop_delay;
                    op2_clk <= '0' after prop_delay;
                    result_clk <= '0' after prop_delay;

                    state := 15;
                when 15 =>
                    memaddr_mux <= "00" after prop_delay;
                    pc_mux <= "01" after prop_delay, "00" after prop_delay * 3;
                    alu_func <= "0111" after prop_delay;
                    regfile_index <= operand1 after prop_delay;
                    regfile_readnotwrite <= '1' after prop_delay;
                    regfile_clk <= '1' after prop_delay;
                    mem_clk <= '1' after prop_delay;
                    mem_readnotwrite <= '0' after prop_delay;
                    ir_clk <= '0' after prop_delay;
                    imm_clk <= '0' after prop_delay;
                    addr_clk <= '0' after prop_delay;
                    pc_clk <= '1' after prop_delay;
                    op1_clk <= '1' after prop_delay;
                    op2_clk <= '1' after prop_delay;
                    result_clk <= '1' after prop_delay;

                    state := 1;
                when 16 =>
                    pc_mux <= "00" after prop_delay;
                    pc_clk <= '1' after prop_delay;

                    state := 17;
                when 17 =>
                    pc_clk <= '0' after prop_delay;
                    memaddr_mux <= "00" after prop_delay;
                    addr_mux <= '1' after prop_delay;
                    regfile_clk <= '0' after prop_delay;
                    mem_clk <= '1' after prop_delay;
                    mem_readnotwrite <= '1' after prop_delay;
                    ir_clk <= '0' after prop_delay;
                    imm_clk <= '0' after prop_delay;
                    addr_clk <= '1' after prop_delay;
                    op1_clk <= '0' after prop_delay;
                    op2_clk <= '0' after prop_delay;
                    result_clk <= '0' after prop_delay;

                    if opcode = x"40" then -- JMP
                        state := 18;
                    else -- JZ
                        state := 20;
                    end if; 
                when 18 =>
                    if opcode = x"40" then -- JMP
                        pc_mux <= "01" after prop_delay;
                        pc_clk <= '1' after prop_delay;
                    end if;

                    if opcode = x"41" then -- JZ
                        if alu_out = x"00000001" then
                            pc_mux <= "01" after prop_delay;
                            pc_clk <= '1' after prop_delay;
                        else
                            pc_clk <= '1' after prop_delay;
                            pc_mux <= "00" after prop_delay;
                        end if;
                    end if;

                    state := 1;
                when 19 =>
                    pc_mux <= "00" after prop_delay;
                    pc_clk <= '1' after prop_delay;

                    state := 1;
                when 20 =>
                    alu_func <= "1100" after prop_delay;
                    regfile_index <= operand1 after prop_delay;
                    regfile_readnotwrite <= '1' after prop_delay;
                    regfile_clk <= '1' after prop_delay;
                    mem_clk <= '0' after prop_delay;
                    ir_clk <= '0' after prop_delay;
                    imm_clk <= '0' after prop_delay;
                    addr_clk <= '0' after prop_delay;
                    pc_clk <= '0' after prop_delay;
                    op1_clk <= '1' after prop_delay;
                    op2_clk <= '1' after prop_delay;
                    result_clk <= '1' after prop_delay;

                    state := 18;
                when others => null; 
            end case; 
		elsif clock'event and clock = '0' then
			regfile_clk <= '0' after prop_delay;
			mem_clk <= '0' after prop_delay;
			ir_clk <= '0' after prop_delay;
			imm_clk <= '0' after prop_delay;
			addr_clk <= '0' after prop_delay;
			pc_clk <= '0' after prop_delay;
			op1_clk <= '0' after prop_delay;
			op2_clk <= '0' after prop_delay;
			result_clk <= '0' after prop_delay;		
		end if; 
	end process behav;
end logic;
