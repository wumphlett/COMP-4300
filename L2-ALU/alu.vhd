USE work.dlx_types.ALL;
USE work.bv_arithmetic.ALL;


entity alu is
    generic(prop_delay: time := 15 ns);
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
    alu: process(operand1, operand2, operation) is
        variable overflow : boolean := false;
        variable operation_result : dlx_word;
        variable divide_by_zero: boolean;
    begin
        error <= "0000";
        case(operation) is
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
                    error <= "0011" after prop_delay;
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
    end process alu;
end architecture logic;
