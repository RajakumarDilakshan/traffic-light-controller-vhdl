
# Traffic Light Controller in VHDL
This project implements a traffic light controller for an intersection of a highway and a side road. It features:
- Traffic light sequencing with priority for the highway unless a vehicle is detected on the side road.
- Timing for yellow and red lights.
- A VHDL testbench to simulate and verify functionality.

## Project Structure
- `traffic_light_controller.vhd`: VHDL code for the traffic light controller.
- `traffic_light_tb.vhd`: VHDL testbench to verify the controller functionality.

## Simulation
To simulate the design:
1. Use any VHDL-compatible simulator like ModelSim, Xilinx Vivado, or GHDL. I have used Questa
2. Compile `traffic_light_controller.vhd` and `traffic_light_tb.vhd`.
3. Run the simulation and observe the outputs.

### Simulation Results
Below is the waveform showing the simulation results:

![Simulation Result](SimulationResult.png)

