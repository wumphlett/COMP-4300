USE work.dlx_types.ALL;
USE work.bv_arithmetic.ALL;


entity dlx_register is
    generic(prop_delay: time := 10 ns);
    port(
        in_val : in dlx_word;
        clock : in bit;
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
