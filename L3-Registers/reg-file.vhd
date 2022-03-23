USE work.dlx_types.ALL;
USE work.bv_arithmetic.ALL;


entity reg_file is
    generic(prop_delay: time := 10 ns);
    port(
        data_in : in dlx_word;
        readnotwrite,
        clock : in bit;
        data_out : out dlx_word;
        reg_number : in register_index
    );
end entity reg_file;

architecture logic of reg_file is
    type reg_type is array (0 to 31) of dlx_word;
    signal registers : reg_type;
begin
    reg_file: process(data_in, readnotwrite, clock, reg_number) is
    begin
        if clock = '1' then
            if readnotwrite = '1' then -- read
                data_out <= registers(bv_to_integer(reg_number)) after prop_delay;
            else -- write
                registers(bv_to_integer(reg_number)) <= data_in after prop_delay;
            end if;
        end if;
    end process reg_file;
end architecture logic;
