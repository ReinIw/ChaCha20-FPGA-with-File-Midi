library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity UnitControl is
    port (
        clock, enable, reset : in std_logic;
        is_smaller : in std_logic;
        cu_done : out std_logic;
        en_out, en_reg : out std_logic
    );
end entity;

architecture rtl of UnitControl is
    type states is (idle, subtract, finish);
    signal curr_state, next_state : states;
begin
    change_state : process(clock, reset)
    begin
        if (reset = '1') then
            curr_state <= idle;
        elsif (rising_edge(clock)) then
            curr_state <= next_state;
        end if;
    end process change_state;

    -- mealy implemented
    control_fsm : process(curr_state, enable, is_smaller)
    begin
        case curr_state is
            when idle =>
                if (enable = '1') then
                    -- mealy output
                    cu_done <= '0';
                    en_reg <= '1';
                    en_out <= '0';

                    -- next state
                    next_state <= subtract;
                else 
                    -- mealy output
                    cu_done <= '0';
                    en_reg <= '0';
                    en_out <= '0';

                    -- next state
                    next_state <= idle;
                end if;

            when subtract =>
                if (is_smaller = '0') then 
                    -- mealy output
                    cu_done <= '0';
                    en_reg <= '0';
                    en_out <= '0';
                    
                    -- next state
                    next_state <= finish;
                else 
                    -- mealy output
                    cu_done <= '1';
                    en_reg <= '1';
                    en_out <= '0';

                    -- next state
                    next_state <= subtract;
                end if;

            when finish =>
                -- mealy output
                cu_done <= '1';
                en_reg <= '0';
                en_out <= '1';

                -- next state
                next_state <= finish;

        end case;
    end process control_fsm;
end architecture;
