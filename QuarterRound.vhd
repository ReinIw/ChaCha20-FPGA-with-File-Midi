library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity QuarterRound is
    port (
        a_in  : in  std_logic_vector(31 downto 0);
        b_in  : in  std_logic_vector(31 downto 0);
        c_in  : in  std_logic_vector(31 downto 0);
        d_in  : in  std_logic_vector(31 downto 0);
        a_out : out std_logic_vector(31 downto 0);
        b_out : out std_logic_vector(31 downto 0);
        c_out : out std_logic_vector(31 downto 0);
        d_out : out std_logic_vector(31 downto 0)
    );
end QuarterRound;

architecture Behavioral of QuarterRound is
    function rotate_left(x : std_logic_vector(31 downto 0); n : integer) return std_logic_vector is
        variable temp : std_logic_vector(31 downto 0);
    begin
        temp := std_logic_vector(shift_left(unsigned(x), n) or shift_right(unsigned(x), 32 - n));
        return temp;
    end rotate_left;

begin
    process(a_in, b_in, c_in, d_in)
        variable a, b, c, d : std_logic_vector(31 downto 0);
    begin
        a := a_in;
        b := b_in;
        c := c_in;
        d := d_in;

        
        a := std_logic_vector(unsigned(a) + unsigned(b)); -- a = a + b
        d := d xor a;                                     -- d = d â a
        d := rotate_left(d, 16);                         -- d = d <<< 16
 
        
        c := std_logic_vector(unsigned(c) + unsigned(d)); -- c = c + d
        b := b xor c;                                     -- b = b â c
        b := rotate_left(b, 12);                         -- b = b <<< 12

        
        a := std_logic_vector(unsigned(a) + unsigned(b)); -- a = a + b
        d := d xor a;                                     -- d = d â a
        d := rotate_left(d, 8);                          -- d = d <<< 8

        
        c := std_logic_vector(unsigned(c) + unsigned(d)); -- c = c + d
        b := b xor c;                                     -- b = b â c
        b := rotate_left(b, 7);                          -- b = b <<< 7

        
        a_out <= a;
        b_out <= b;
        c_out <= c;
        d_out <= d;
    end process;

end Behavioral;