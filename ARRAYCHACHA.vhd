library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ARRAYCHACHA is
    port (
        input : in std_logic_vector(511 downto 0);
        all_out : out std_logic_vector(511 downto 0)
    );
end ARRAYCHACHA;

architecture rtl of ARRAYCHACHA is
    -- Deklarasi komponen QuarterRound
    component QuarterRound is
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
    end component;

    -- Deklarasi sinyal internal untuk menyimpan nilai awal
    signal cons0   : std_logic_vector(127 downto 0);
    signal counter : std_logic_vector(31 downto 0);
    signal nonce0  : std_logic_vector(95 downto 0);
    signal key0    : std_logic_vector(255 downto 0);
    signal q11, q12, q13, q14 : std_logic_vector(31 downto 0);
    signal q21, q22, q23, q24 : std_logic_vector(31 downto 0);
    signal q31, q32, q33, q34 : std_logic_vector(31 downto 0);
    signal q41, q42, q43, q44 : std_logic_vector(31 downto 0);
    signal q51, q52, q53, q54 : std_logic_vector(31 downto 0);
    signal q61, q62, q63, q64 : std_logic_vector(31 downto 0);
    signal q71, q72, q73, q74 : std_logic_vector(31 downto 0);
    signal q81, q82, q83, q84 : std_logic_vector(31 downto 0);

begin
    cons0   <= input(511 downto 384);
    counter <= input(127 downto 96);
    key0    <= input(383 downto 128);
    nonce0  <= input(95 downto 0);

    -- QuarterRound 0 4 8 12
    Qr1: QuarterRound
        port map (
            a_in  => cons0(127 downto 96),
            b_in  => key0(255 downto 224),
            c_in  => key0(127 downto 96),
            d_in  => counter(31 downto 0),
            a_out => q11,
            b_out => q12,
            c_out => q13,
            d_out => q14
        );

    -- QuarterRound 1,5,9,13
    Qr2: QuarterRound
        port map (
            a_in  => cons0(95 downto 64),
            b_in  => key0(223 downto 192),
            c_in  => key0(95 downto 64),
            d_in  => nonce0(95 downto 64),
            a_out => q21,
            b_out => q22,
            c_out => q23,
            d_out => q24
        );

    -- QuarterRound 2,6,10,14
    Qr3: QuarterRound
        port map (
            a_in  => cons0(63 downto 32),
            b_in  => key0(191 downto 160),
            c_in  => key0(63 downto 32),
            d_in  => nonce0(63 downto 32),
            a_out => q31,
            b_out => q32,
            c_out => q33,
            d_out => q34
        );

    -- QuarterRound 3,7,11,15
    Qr4: QuarterRound
        port map (
            a_in  => cons0(31 downto 0),
            b_in  => key0(159 downto 128),
            c_in  => key0(31 downto 0),
            d_in  => nonce0(31 downto 0),
            a_out => q41,
            b_out => q42,
            c_out => q43,
            d_out => q44
        );

    -- QuarterRound 0,5,10,15
    Qr5: QuarterRound
        port map (
            a_in  => q11,
            b_in  => q22,
            c_in  => q33,
            d_in  => q44,
            a_out => q51,
            b_out => q52,
            c_out => q53,
            d_out => q54
        );

    -- QuarterRound 1,6,11,12
    Qr6: QuarterRound
        port map (
            a_in  => q21,
            b_in  => q32,
            c_in  => q43,
            d_in  => q14,
            a_out => q61,
            b_out => q62,
            c_out => q63,
            d_out => q64
        );

    -- QuarterRound 2,7,8,13
    Qr7: QuarterRound
        port map (
            a_in  => q31,
            b_in  => q42,
            c_in  => q13,
            d_in  => q24,
            a_out => q71,
            b_out => q72,
            c_out => q73,
            d_out => q74
        );

    -- QuarterRound 3,4,9,14
    Qr8: QuarterRound
        port map (
            a_in  => q41,
            b_in  => q12,
            c_in  => q23,
            d_in  => q34,
            a_out => q81,
            b_out => q82,
            c_out => q83,
            d_out => q84
        );

    all_out(511 downto 384) <= q51 & q61 & q71 & q81;
    all_out(383 downto 128) <= q82 & q52 & q62 & q72 & q73 & q83 & q53 & q63;
    all_out(127 downto 96) <= q64;
    all_out(95 downto 0) <= q74 & q84 & q54;

end rtl;
