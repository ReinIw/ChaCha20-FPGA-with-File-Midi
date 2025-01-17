library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mainQround is
    port (
        switchA     : in  std_logic_vector(511 downto 0); -- Input switch
        goaround    : in  std_logic;                      -- Start button
        stoparound  : in  std_logic;                      -- Stop button
        keysofclock : in  std_logic;                      -- Clock signal
        ready       : out std_logic;                       -- Ready signal
        counting    : out std_logic_vector(3 downto 0);    -- Counting output
        DataOut     : out std_logic_vector(511 downto 0)   -- Output data
    );
end entity;

architecture behavioral of mainQround is

    -- unitcontrol fsm
    component UnitControl is
        port (
            clock, enable, reset : in std_logic;
            is_smaller : in std_logic;
            cu_done : out std_logic;
            en_out, en_reg : out std_logic
        );
    end component;

    -- component register 512 bit
    component register512bit is
        port (
            A    : in  std_logic_vector(511 downto 0); -- Input data A
            En   : in  std_logic;                     -- Enable signal
            Res  : in  std_logic;                     -- Reset signal
            Clk  : in  std_logic;                     -- Clock signal
            Data : out std_logic_vector(511 downto 0) -- Output data
        );
    end component;

    -- counter component
    component counter4bit is
        port (
            En      : in std_logic;                  -- enable signal
            Res     : in std_logic;                  -- reset signal
            Clk     : in std_logic;                  -- clock signal
            Count   : out std_logic_vector(3 downto 0) -- counting result
        );
    end component;

    -- Quarter Round Component
    component ARRAYCHACHA is
        port (
            input   : in std_logic_vector(511 downto 0); 
            all_out : out std_logic_vector(511 downto 0)
        );
    end component;

    -- comparator component
    component comparator4bit is
        port (
            A   : in std_logic_vector (3 downto 0);   -- value A
            Le  : out std_logic                       -- flag if A is smaller than B
        );
    end component;

    -- Mux Component
    component mux2to1_512bit is
        port (
            A   : in std_logic_vector (511 downto 0); -- data A
            B   : in std_logic_vector (511 downto 0); -- data B
            Sel : in std_logic;                        -- selector
            Data : out std_logic_vector (511 downto 0) -- output data
        );
    end component;

    -- Internal signals
    signal input_a : std_logic_vector(511 downto 0);
    signal realclock, STOP, START, Selector : std_logic;
    signal awal : std_logic_vector(511 downto 0);
    signal data_A : std_logic_vector(511 downto 0);
    signal data_Register_A : std_logic_vector(511 downto 0);
    signal enable_A : std_logic;
    signal enable_register : std_logic;
    signal QroundtoMux : std_logic_vector(511 downto 0);
    signal hasilkomparasi, masihlebihkecil : std_logic;
    signal selesai : std_logic;
    signal hasilcounter : std_logic_vector(3 downto 0);
    signal enable_counter : std_logic;
    signal siap : std_logic;
    signal hasiljumlah : std_logic_vector (511 downto 0);
    signal hasilbalik : std_logic_vector(511 downto 0);

begin

    -- Input signal mapping
    awal <= input_a;
    input_a <= switchA;
    Selector <= selesai;
    realclock <= keysofclock;
    STOP <= stoparound;
    START <= goaround;

    -- Multiplexer process
    muxProcess : mux2to1_512bit port map (A => input_a, B => QroundtoMux, Sel => Selector, Data => data_A);

    -- Register process
    reg_a : register512bit port map(A => data_A, En => enable_A, Res => STOP, Clk => realclock, Data => data_Register_A);
    enable_A <= enable_register;
    enable_counter <= enable_register and masihlebihkecil;

    -- Quarter Round process
    procesQround : ARRAYCHACHA port map (input => data_Register_A, all_out => QroundtoMux);

    -- Counter process
    prosescounting : counter4bit port map (En => enable_counter, Res => STOP , Clk => realclock , Count => hasilcounter);
    counting <= hasilcounter;

    -- Comparator process
    prosesperbandingan : comparator4bit port map(A => hasilcounter, Le => hasilkomparasi);
    masihlebihkecil <= hasilkomparasi;

    -- FSM process
    prosesfsm : UnitControl port map(clock => realclock, enable => START, reset => STOP, is_smaller => masihlebihkecil, cu_done => selesai, en_reg => enable_register, en_out => siap);

    -- Addition operation and result assignment
    hasiljumlah(511 downto 480) <= std_logic_vector(unsigned(awal(511 downto 480)) + unsigned(data_Register_A(511 downto 480)));
    hasiljumlah(479 downto 448) <= std_logic_vector(unsigned(awal(479 downto 448)) + unsigned(data_Register_A(479 downto 448)));
    hasiljumlah(447 downto 416) <= std_logic_vector(unsigned(awal(447 downto 416)) + unsigned(data_Register_A(447 downto 416)));
    hasiljumlah(415 downto 384) <= std_logic_vector(unsigned(awal(415 downto 384)) + unsigned(data_Register_A(415 downto 384)));
    hasiljumlah(383 downto 352) <= std_logic_vector(unsigned(awal(383 downto 352)) + unsigned(data_Register_A(383 downto 352)));
    hasiljumlah(351 downto 320) <= std_logic_vector(unsigned(awal(351 downto 320)) + unsigned(data_Register_A(351 downto 320)));
    hasiljumlah(319 downto 288) <= std_logic_vector(unsigned(awal(319 downto 288)) + unsigned(data_Register_A(319 downto 288)));
    hasiljumlah(287 downto 256) <= std_logic_vector(unsigned(awal(287 downto 256)) + unsigned(data_Register_A(287 downto 256)));
    hasiljumlah(255 downto 224) <= std_logic_vector(unsigned(awal(255 downto 224)) + unsigned(data_Register_A(255 downto 224)));
    hasiljumlah(223 downto 192) <= std_logic_vector(unsigned(awal(223 downto 192)) + unsigned(data_Register_A(223 downto 192)));
    hasiljumlah(191 downto 160) <= std_logic_vector(unsigned(awal(191 downto 160)) + unsigned(data_Register_A(191 downto 160)));
    hasiljumlah(159 downto 128) <= std_logic_vector(unsigned(awal(159 downto 128)) + unsigned(data_Register_A(159 downto 128)));
    hasiljumlah(127 downto 96)  <= std_logic_vector(unsigned(awal(127 downto 96)) + unsigned(data_Register_A(127 downto 96)));
    hasiljumlah(95 downto 64)   <= std_logic_vector(unsigned(awal(95 downto 64)) + unsigned(data_Register_A(95 downto 64)));
    hasiljumlah(63 downto 32)   <= std_logic_vector(unsigned(awal(63 downto 32)) + unsigned(data_Register_A(63 downto 32)));
    hasiljumlah(31 downto 0)    <= std_logic_vector(unsigned(awal(31 downto 0)) + unsigned(data_Register_A(31 downto 0)));

    

    -- Final result assignment
    DataOut <= hasiljumlah;
    ready <= siap; 
end behavioral;

