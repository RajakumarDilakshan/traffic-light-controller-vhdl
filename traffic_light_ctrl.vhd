library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Traffic light controller for an intersection between a main road and a side road
entity traffic_light_ctrl is
    port (
        vehicle_sensor  : in STD_LOGIC;  -- Sensor to detect vehicles on the side road
        clk             : in STD_LOGIC;  -- Clock input
        reset_n         : in STD_LOGIC;  -- Active low reset
        main_road_light : out STD_LOGIC_VECTOR(2 downto 0);  -- Main road traffic light (R-Y-G)
        side_road_light : out STD_LOGIC_VECTOR(2 downto 0)   -- Side road traffic light (R-Y-G)
    );
end traffic_light_ctrl;

architecture fsm_arch of traffic_light_ctrl is
    signal counter_1s: std_logic_vector(27 downto 0) := x"0000000";
    signal delay_counter: std_logic_vector(3 downto 0) := x"0";
    signal delay_10s, delay_3s_side, delay_3s_main: std_logic := '0';
    signal red_enable, yellow_main_enable, yellow_side_enable: std_logic := '0';
    signal clk_1s_enable: std_logic;  -- 1-second clock enable
    type state_type is (MAIN_GREEN, MAIN_YELLOW, MAIN_RED_SIDE_GREEN, MAIN_RED_SIDE_YELLOW);
    signal current_state, next_state: state_type;

begin
    -- State transition logic
    process(clk, reset_n)
    begin
        if reset_n = '0' then
            current_state <= MAIN_GREEN;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;

    -- State machine combinational logic
    process(current_state, vehicle_sensor, delay_3s_side, delay_3s_main, delay_10s)
    begin
        case current_state is
            when MAIN_GREEN =>
                red_enable <= '0';
                yellow_main_enable <= '0';
                yellow_side_enable <= '0';
                main_road_light <= "001";  -- Green light on main road
                side_road_light <= "100"; -- Red light on side road
                if vehicle_sensor = '1' then
                    next_state <= MAIN_YELLOW;
                else
                    next_state <= MAIN_GREEN;
                end if;

            when MAIN_YELLOW =>
                main_road_light <= "010";  -- Yellow light on main road
                side_road_light <= "100";  -- Red light on side road
                red_enable <= '0';
                yellow_main_enable <= '1';
                yellow_side_enable <= '0';
                if delay_3s_main = '1' then
                    next_state <= MAIN_RED_SIDE_GREEN;
                else
                    next_state <= MAIN_YELLOW;
                end if;

            when MAIN_RED_SIDE_GREEN =>
                main_road_light <= "100";  -- Red light on main road
                side_road_light <= "001";  -- Green light on side road
                red_enable <= '1';
                yellow_main_enable <= '0';
                yellow_side_enable <= '0';
                if delay_10s = '1' then
                    next_state <= MAIN_RED_SIDE_YELLOW;
                else
                    next_state <= MAIN_RED_SIDE_GREEN;
                end if;

            when MAIN_RED_SIDE_YELLOW =>
                main_road_light <= "100";  -- Red light on main road
                side_road_light <= "010";  -- Yellow light on side road
                red_enable <= '0';
                yellow_main_enable <= '0';
                yellow_side_enable <= '1';
                if delay_3s_side = '1' then
                    next_state <= MAIN_GREEN;
                else
                    next_state <= MAIN_RED_SIDE_YELLOW;
                end if;

            when others =>
                next_state <= MAIN_GREEN;
        end case;
    end process;

    -- Delay counters for yellow and red lights
    process(clk)
    begin
        if rising_edge(clk) then
            if clk_1s_enable = '1' then
                if red_enable = '1' or yellow_main_enable = '1' or yellow_side_enable = '1' then
                    delay_counter <= delay_counter + x"1";
                    if delay_counter = x"9" and red_enable = '1' then
                        delay_10s <= '1';
                        delay_3s_main <= '0';
                        delay_3s_side <= '0';
                        delay_counter <= x"0";
                    elsif delay_counter = x"2" and yellow_main_enable = '1' then
                        delay_10s <= '0';
                        delay_3s_main <= '1';
                        delay_3s_side <= '0';
                        delay_counter <= x"0";
                    elsif delay_counter = x"2" and yellow_side_enable = '1' then
                        delay_10s <= '0';
                        delay_3s_main <= '0';
                        delay_3s_side <= '1';
                        delay_counter <= x"0";
                    else
                        delay_10s <= '0';
                        delay_3s_main <= '0';
                        delay_3s_side <= '0';
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- 1-second clock generation
    process(clk)
    begin
        if rising_edge(clk) then
            counter_1s <= counter_1s + x"0000001";
            if counter_1s >= x"0000003" then -- Use x"2FAF080" for 50 MHz clock on FPGA
                counter_1s <= x"0000000";
            end if;
        end if;
    end process;

    clk_1s_enable <= '1' when counter_1s = x"0003" else '0'; -- Use x"2FAF080" for FPGA clock
end fsm_arch;
