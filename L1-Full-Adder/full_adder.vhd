entity full_adder is
    generic(prop_delay: Time := 10 ns);
    port(
        a_in,
        b_in,
        carry_in : in bit;
        result,
        carry_out : out bit
    );
end entity full_adder;

architecture logic of full_adder is
begin
    result <= a_in XOR b_in XOR carry_in after prop_delay;
    carry_out <= (a_in AND b_in) OR (a_in AND carry_in) OR (b_in AND carry_in) after prop_delay;
end architecture logic;
