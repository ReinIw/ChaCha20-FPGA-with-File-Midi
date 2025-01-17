library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cordicphase is
    port(
        i_CLOCK         : in std_logic;                    -- Clock input
        i_RX            : in std_logic;                    -- UART RX input
        o_TX            : out std_logic := '1';            -- UART TX output
        o_RX_BUSY       : out std_logic;                   -- UART RX busy indicator
        o_TX_BUSY       : out std_logic;                   -- UART TX busy indicator
        o_DATA_READY    : out std_logic;                   -- Data ready indicator
        ledout          : out std_logic;                   -- Output for LED indication
		  ledout2		   : out std_logic;                   -- Output for LED indication
        o_sig_CRRP_DATA : out std_logic                    -- Current received data status
    );  
end cordicphase;

architecture behavior of cordicphase is
    -- UART signals
    signal s_RX_BUSY      : std_logic;
    signal s_prev_RX_BUSY : std_logic := '0';
    signal s_rx_data      : std_logic_vector(7 downto 0);
    signal s_TX_START     : std_logic := '0';
    signal s_TX_BUSY      : std_logic;
    signal r_TX_DATA      : std_logic_vector(7 downto 0) := (others => '0');
    
    -- Data handling
    signal r_word_buffer  : std_logic_vector(511 downto 0) := (others => '0'); -- 512-bit buffer
    signal r_byte_index   : integer range 0 to 63 := 0;                         -- Byte index (64 x 8-bit = 512-bit)
    signal r_data_ready   : std_logic := '0';                                   -- Data ready flag
    
    -- State machine
    type t_state is (IDLE, RECEIVE_BYTE, PROCESS_WORD, SEND_BYTE, WAIT_TX);
    signal r_state : t_state := IDLE;

    -- MainQround signals
    signal s_DataOut     : std_logic_vector(511 downto 0);
    signal s_goaround    : std_logic := '0';
    signal s_stoparound  : std_logic := '0';
    signal s_ready       : std_logic; -- Ready signal from MainQround

    -- Components
    component uart1_tx is
        port(
            i_CLOCK   : in std_logic;
            i_START   : in std_logic;
            o_BUSY    : out std_logic;
            i_DATA    : in std_logic_vector(7 downto 0);
            o_TX_LINE : out std_logic := '1'
        );
    end component;
    
    component uart1_rx is
        port(
            i_CLOCK         : in std_logic;
            i_RX            : in std_logic;
            o_DATA          : out std_logic_vector(7 downto 0); 
            o_sig_CRRP_DATA : out std_logic;
            o_BUSY          : out std_logic
        );
    end component;

    component mainQround is 
        port (
            switchA     : in  std_logic_vector(511 downto 0); -- Input switch
            goaround    : in  std_logic;                      -- Start button
            stoparound  : in  std_logic;                      -- Stop button
            keysofclock : in  std_logic;                      -- Clock signal
            counting    : out std_logic_vector(3 downto 0); 
            DataOut     : out std_logic_vector(511 downto 0); -- Output data
            ready       : out std_logic                        -- Processing complete signal
        );
    end component;

begin
    -- UART TX instantiation
    u_TX : uart1_tx port map(
        i_CLOCK   => i_CLOCK,
        i_START   => s_TX_START,
        o_BUSY    => s_TX_BUSY,
        i_DATA    => r_TX_DATA,
        o_TX_LINE => o_TX
    );
    
    -- UART RX instantiation
    u_RX : uart1_rx port map(
        i_CLOCK         => i_CLOCK,
        i_RX            => i_RX,
        o_DATA          => s_rx_data,
        o_sig_CRRP_DATA => o_sig_CRRP_DATA,
        o_BUSY          => s_RX_BUSY
    );

    -- MainQround instantiation
    u_mainQround : mainQround port map(
        switchA     => r_word_buffer,
        goaround    => s_goaround,
        stoparound  => s_stoparound,
        keysofclock => i_CLOCK,
        DataOut     => s_DataOut,
        ready       => s_ready
    );

    -- Main process for state machine
    process(i_CLOCK)
    begin
        if rising_edge(i_CLOCK) then
            -- Synchronize RX busy signal menyimpan sinyal pada clock sebelumnya 
            s_prev_RX_BUSY <= s_RX_BUSY;

            -- Reset TX start when busy
            if s_TX_START = '1' and s_TX_BUSY = '1' then
                s_TX_START <= '0';
            end if;

            -- Default stoparound to '0'
            s_stoparound <= '0';
            ledout <= '0'; -- LED indication reset to 0
				

            case r_state is
                when IDLE =>
                    -- Wait for RX to complete (falling edge of busy)
                    if s_RX_BUSY = '0' and s_prev_RX_BUSY = '1' then
                        -- Move 8-bit data into r_word_buffer
                        r_word_buffer(511 - (r_byte_index * 8) downto 504 - (r_byte_index * 8)) <= s_rx_data;
                        
                        -- Check if we have received all 512 bits
                        if r_byte_index = 63 then
                            r_byte_index <= 0;
                            r_data_ready <= '1';  -- Data is ready for processing
                            s_goaround <= '1';   -- Start Qround
                            s_stoparound <= '0';  -- Do not reset
                            r_state <= PROCESS_WORD; -- Transition to next state
                        else
                            r_byte_index <= r_byte_index + 1; -- Move to the next byte
                        end if;
                    end if;

                when PROCESS_WORD =>
                    -- Wait for Main Qround to finish processing
                    if s_ready = '1' then 
                        s_goaround <= '1';  -- Keep the signal high to collect output data
                        s_stoparound <= '0'; -- Keep the stoparound signal low
                        r_state <= SEND_BYTE; -- Transition to the send state
                    end if;

                when SEND_BYTE =>
                    -- Send 1 byte at each clock cycle
                    if s_TX_BUSY = '0' then 
                        r_TX_DATA <= s_DataOut(511 - (r_byte_index * 8) downto 504 - (r_byte_index * 8));
                        s_TX_START <= '1';
                        r_state <= WAIT_TX;
                    end if;

                when WAIT_TX =>
                    -- Wait for TX to complete
                    if s_TX_BUSY = '0' and s_TX_START = '0' then
                        ledout <= '1';  -- Indicate completion on LED
								
                        
                        -- Return to IDLE or continue sending data
                        if r_byte_index = 63 then
                            r_byte_index <= 0;
                            r_state <= IDLE;
                            s_stoparound <= '0';
                        else
                            r_byte_index <= r_byte_index + 1;
                            r_state <= SEND_BYTE;
                        end if;
                    end if;

                when others =>
                    -- Default case to handle unexpected state values
                    r_state <= IDLE;
            end case;
        end if;
    end process;

    -- Output assignments
    o_RX_BUSY <= s_RX_BUSY;
    o_TX_BUSY <= s_TX_BUSY;
    o_DATA_READY <= r_data_ready;
end behavior;
