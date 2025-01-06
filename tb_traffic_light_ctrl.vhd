library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Testbench for the traffic light controller
entity tb_traffic_light_ctrl is
end tb_traffic_light_ctrl;

architecture sim of tb_traffic_light_ctrl is

    -- Component declaration
    component traffic_light_ctrl
        port (
            vehicle_sensor  : in STD_LOGIC;
            clk             : in STD_LOGIC;
            reset_n         : in STD_LOGIC;
            main_road_light : out STD_LOGIC_VECTOR(2 downto 0);
            side_road_light : out STD_LOGIC_VECTOR(2 downto 0)
        );
    end component;

    -- Testbench signals
    signal vehicle_sensor  : STD_LOGIC := '0';
    signal clk             : STD_LOGIC := '0';
    signal reset_n         : STD_LOGIC := '0';
    signal main_road_light : STD_LOGIC_VECTOR(2 downto 0);
    signal side_road_light : STD_LOGIC_VECTOR(2 downto 0);

    constant CLK_PERIOD : time := 10 ns; -- Clock period for simulation

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: traffic_light_ctrl
        port map (
            vehicle_sensor  => vehicle_sensor,
            clk             => clk,
            reset_n         => reset_n,
            main_road_light => main_road_light,
            side_road_light => side_road_light
        );

    -- Clock generation
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- Testbench stimulus
    stimulus: process
    begin
        -- Reset the system
        reset_n <= '0';
        wait for 20 ns;
        reset_n <= '1';

        -- Case 1: No vehicle detected on the side road
        vehicle_sensor <= '0';
        wait for 100 ns;

        -- Case 2: Vehicle detected on the side road
        vehicle_sensor <= '1';
        wait for 200 ns;

        -- Case 3: No vehicle detected again
        vehicle_sensor <= '0';
        wait for 100 ns;

        -- End simulation
        wait;
    end process;

end sim;
