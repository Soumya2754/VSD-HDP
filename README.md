# VSD-HDP Status

Progress Quick-Link:<br />
[Day 1](#Day_1)<br />
[Day 2](#Day_2)<br />
[Day 3](#Day_3)<br />
[Day 4](#Day_4)<br />
[Day 5](#Day_5)<br />
[Day 6](#Day_6)<br />
[Day 7](#Day_7)<br />
[Day 8](#Day_8)<br />
[Day 9](#Day_9)<br />


## Day 0: Installation
*Before installing run the command below*
```
$ sudo apt update && upgrade
```
Tools needed:
- [x] Yosys
- [x] OpenSTA
- [x] ngspice
- [x] iverilog
- [x] gtkwave
- [x] magic

### Yosys
```
$ mkdir yosys
$ git clone https://github.com/YosysHQ/yosys.git
$ cd yosys
$ sudo apt-get install build-essential clang bison flex \
    libreadline-dev gawk tcl-dev libffi-dev git \
    graphviz xdot pkg-config python3 libboost-system-dev \
    libboost-python-dev libboost-filesystem-dev zlib1g-dev
$ make 
$ sudo make install
```
![Screenshot from 2023-02-18 09-51-15](https://user-images.githubusercontent.com/83526493/219851718-059c8120-a14f-41fa-a86a-e9054f8a23ba.png)

### OpenSTA
*To install cmake for 18.04 (if not present)*
```
$ wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | sudo apt-key add -
$ sudo apt-add-repository 'deb https://apt.kitware.com/ubuntu/ bionic main'
$ sudo apt-get update
$ sudo apt-get upgrade
```
*Dependency*
```
$ sudo apt install swig
```
*For OpenSTA*
```
$ git clone https://github.com/The-OpenROAD-Project/OpenSTA.git
$ cd OpenSTA
$ mkdir build
$ cd build
$ cmake ..
$ make
```
![Screenshot from 2023-02-18 10-24-48](https://user-images.githubusercontent.com/83526493/219851603-8e197286-ee63-43bd-8067-5c58f93f95f8.png)

### ngspice
* Download ngspice-37.tar.gz from old releases parent folder from
(https://sourceforge.net/projects/ngspice/files/)
```
$ tar -zxvf ngspice-37.tar.gz
$ cd ngspice-37
$ mkdir release
$ cd release
$ ../configure  --with-x --with-readline=yes --disable-debug
$ make
$ sudo make install
```
![Screenshot from 2023-02-18 09-51-56](https://user-images.githubusercontent.com/83526493/219851683-58c7479c-eba6-4b24-89dd-c0f3dcaebbca.png)

### iverilog
```
$ sudo apt-get install iverilog
```
### gtkwave
```
$ sudo apt install gtkwave
```
### magic
```
$   sudo apt-get install m4
$   sudo apt-get install tcsh
$   sudo apt-get install csh
$   sudo apt-get install libx11-dev
$   sudo apt-get install tcl-dev tk-dev
$   sudo apt-get install libcairo2-dev
$   sudo apt-get install mesa-common-dev libglu1-mesa-dev
$   sudo apt-get install libncurses-dev
```
## Day 1
Simulation of a 2x1 mux using iverilog

*verilog code*
```
module good_mux (input i0 , input i1 , input sel , output reg y);
always @ (*)
begin
	if(sel)
		y <= i1;
	else 
		y <= i0;
end
endmodule
```
*testbench*
```
`timescale 1ns / 1ps
module tb_good_mux;
	// Inputs
	reg i0,i1,sel;
	// Outputs
	wire y;

        // Instantiate the Unit Under Test (UUT)
	good_mux uut (
		.sel(sel),
		.i0(i0),
		.i1(i1),
		.y(y)
	);

	initial begin
	$dumpfile("tb_good_mux.vcd");
	$dumpvars(0,tb_good_mux);
	// Initialize Inputs
	sel = 0;
	i0 = 0;
	i1 = 0;
	#300 $finish;
	end

always #75 sel = ~sel;
always #10 i0 = ~i0;
always #55 i1 = ~i1;
endmodule
```
### Procedure
```
$ iverilog good_mux.v tb_good_mux.v
$ ./a.out
$ gtkwave tb_good_mux.vcd
```

*gtkwave*
![Screenshot from 2023-02-18 14-10-15](https://user-images.githubusercontent.com/83526493/219851835-da895ae8-02d1-4522-81a4-d1d62359d97a.png)

### Synthesis using yosys
Go to the directory with verilog files
```
$ yosys
> read_liberty -lib *<your lib file address>*
> read_verilog *<verilog files>*
> synth_top *<top_module_name>*
> abc -liberty *<your lib file address>*
> show
```
Synthesis of good_mux
![Screenshot from 2023-02-18 14-57-18](https://user-images.githubusercontent.com/83526493/219853142-ea378a37-ea05-47c4-b09d-5a484ff2ba93.png)

*To generate netlist*
```
> write_verilog file_name_netlist.v
> write_verilog -nostr file_name_netlist.v
> !gedit file_name_netlist.v
```

*Generated netlist*
```
/* Generated by Yosys 0.26+4 (git sha1 5ea2c290a, clang 10.0.0-4ubuntu1 -fPIC -Os) */

module good_mux(i0, i1, sel, y);
  wire _0_;
  wire _1_;
  wire _2_;
  wire _3_;
  input i0;
  wire i0;
  input i1;
  wire i1;
  input sel;
  wire sel;
  output y;
  wire y;
  sky130_fd_sc_hd__mux2_1 _4_ (
    .A0(_0_),
    .A1(_1_),
    .S(_2_),
    .X(_3_)
  );
  assign _0_ = i0;
  assign _1_ = i1;
  assign _2_ = sel;
  assign y = _3_;
endmodule
```
## Day 2

### Important notes
- Standard Cell Library files will contain details of all types of individual cells with different parameters of area, power and delay.
- We need both fast and slow cells for performace and hold time respectively.
- Wider area gives faster cells
- PVT corners different for different .lib files
- Hierarchical v/s Flat Synthesis.
- To aviod glitch propagation in multiple combinational blocks, flip flops are used to stabilize data before each combinational block.
- Asynchronous and synchronous reset/set with D_FF explored.

### Procedure
~~~
$ yosys
> read_liberty -lib ../lib/sky130_fd_sc_hd__tt_025C_1v80.lib
> read_verilog multiple_modules.v
> synth -top multiple_modules
> abc -liberty ../lib/sky130_fd_sc_hd__tt_025C_1v80.lib
> show multiple_modules
> write_verilog -noattr multiple_modules_hier.v
> flatten
> write_verilog -noattr multiple_modules_flat.v
~~~

### Synthesis Schematic and netlist for multiple modules:
![3](https://user-images.githubusercontent.com/112770970/219856449-00bdabd6-3f8f-4382-858a-7b7b5cb828cb.JPG)

![1](https://user-images.githubusercontent.com/112770970/219856497-04ea6607-1bfd-4571-8a71-248c019176ad.JPG)

![4](https://user-images.githubusercontent.com/112770970/219856455-dc79ae75-d879-4c20-8e4a-ba3fec07ea69.JPG)

### Flat Synthesis
![5](https://user-images.githubusercontent.com/112770970/219856481-5616038e-c92f-4155-89f6-c5da338a5e95.JPG)

### Inferences
- PMOS in series is bad because it has low mobility

### D-Flip Flop Synthesis

Use addtional command:
~~~
dfflibmap -liberty <.lib file path>
~~~
*this will only for D-FF already present in library*

Asynchronous reset:
![asynch_reset syn](https://user-images.githubusercontent.com/112770970/219856560-2ec3e92e-3407-4c05-bf1a-228b95236cfa.JPG)

Synchronous reset:
![synch_reset synthesis](https://user-images.githubusercontent.com/112770970/219856579-7368ea1f-cb77-47e5-8e94-3f54eeb614de.JPG)

### D-Flip FLop Simulation
Asynchronous reset:

![asynch_reset wave](https://user-images.githubusercontent.com/112770970/219856663-2603d11c-efe8-4f17-ac1a-627dc94a15e0.JPG)

Synchronous reset:

![synch_reset](https://user-images.githubusercontent.com/112770970/219856669-6514e587-a19c-40c8-84df-4bd1635636a4.JPG)

### Interesting Optimizations:

#### Synthesis of some special functions:

- mult_2.v : y = 2 * a; where y is 4 bit and a is 3 bit number
- But if you closely observe, you can obtain y by right shifting a by 1 bit
- Likewise if you want to multiply a number by 4, you right shift 2 bits and for 8, you right shift 3 times

![opt1](https://user-images.githubusercontent.com/112770970/219856933-8d6e4b57-3f85-4f09-b9cf-c1c55640e13d.JPG)
![6](https://user-images.githubusercontent.com/112770970/219856940-bd3dff20-d47d-4409-a761-02d4034cfd5b.JPG)

- mult_8.v : y = 9 * a; where y is 6 bit and a is 3 bit number
- (multiplication by nine can also be written as ax8 + a and hence y is just a appended with a)

![opt2](https://user-images.githubusercontent.com/112770970/219857110-11a15a81-a286-4986-af93-a03f5cae29da.JPG)
![7](https://user-images.githubusercontent.com/112770970/219857004-f9c586ba-d3b2-4f4b-acea-63524538e85e.JPG)

- *In these cases, no cells are synthesised*
## Day 3

### Logic Optimizations
- Combinational Logic Optimization
  * Constant Propagation - when effectively the combination is just propagating a constant 
  * Boolean Logic Optimization - De-Morgan's laws and other Boolean rules.
 
- Sequential Logic Optimisation
  * Sequential Constant Propagation - This is different from combinational constant propagation because clock is involved
  	- DFF with D input grounded and reset is equivalent to Q = 0 and DFF is useless
  	- but DFF with D grounded and set is not equivalent to Q = set and FF is to be retained
  * State Optimization - unused states are removed
  * Retiming - the combinational blocks between different flops are shifted such that their effective clock frequency of the whole circuit increases without violating setup and hold, thereby, increasing performance
  * Sequential logic cloning - additional flops are added whichever has positive slack when the other flops in the design are placed far apart in the floorplan to meet their timing requirements and utilise this positive time slack as propagation delay

*Command to use for optimisation:
~~~
$ opt_clean -purge
~~~


### Combinational Logic Optimisations

*opt_check4.v* :
~~~
 assign y = a ? (b ? (a & c) : c) : (!c);
~~~

![opt_check_4](https://user-images.githubusercontent.com/112770970/219863972-5bd9f48a-c1ab-4741-a335-8d17e4fa553e.JPG)
![opt_check_4_cells](https://user-images.githubusercontent.com/112770970/219863977-574f6e43-0a48-4efe-824a-cfb8daff07e4.JPG)

*multiple_modules_opt file*:
~~~
 assign y = c|(a&b);
~~~

![multiple_modules_opt](https://user-images.githubusercontent.com/112770970/219864034-3b9e57d2-6528-4dca-9755-fe2f206682ac.JPG)

### Synthesis Illustrating Sequential Constant Propagation:
- In this case, the flip flop is redundant.

![dff_const4_syn](https://user-images.githubusercontent.com/112770970/219862146-472e3e1a-8f37-4141-ad9c-41887ef9b774.JPG)

- but here the FF is not redundant

![dff_const5_syn](https://user-images.githubusercontent.com/112770970/219862301-bb179eda-0dd5-4ddf-ab25-c005795ecf7a.JPG)

### Simulation Illustrating Sequential Constant Propagation:
- In this case, the output q always remains 1, therefore flip flop is not needed.
 
![dff_const4_wave](https://user-images.githubusercontent.com/112770970/219862898-284bc9b5-bc93-489f-a125-9eea03a87526.JPG)

- But here we can observe that Q is not equal to !reset
![dff_const5_wave](https://user-images.githubusercontent.com/112770970/219862976-c340e657-6fef-402b-b7d9-00516d301660.JPG)

### Synthesis of unused output (3-bit Counter example) :

![counter_opt1](https://user-images.githubusercontent.com/112770970/219864111-d46d1829-467a-468f-9b26-f77ab72cf9a9.JPG)

### Synthesis if all output ports are used (3-bit Counter example) :

![counter_opt2](https://user-images.githubusercontent.com/112770970/219864154-864adb26-e33a-4abb-9647-8415fd40ecb7.JPG)


## Day_4

### Bad Mux Example
- Simulation of bad_mux

![bad_mux sim](https://user-images.githubusercontent.com/112770970/221162808-0cbf452d-4b55-4915-a101-bf1cecc028c5.JPG)


- Synthesis of bad_mux

![bad_mux synth](https://user-images.githubusercontent.com/112770970/221163038-f39f861b-60d5-4ed8-a888-2006b6cdee5c.JPG)


- Simulation of the gate level netlist generated

![bad_mux _netlist_sim](https://user-images.githubusercontent.com/112770970/221163175-f4eb136e-20b1-4f3d-92ce-f75b7156ecb5.JPG)

- It can be seen above that there clearly exists a simulation synthesis mismatch.
- Synthesis gave the correct waveform and no latch was inferred.
- Simulation indicates the behaviour of a latch.

### Blocking Assignment Caveats
- Simulation

![BA sim](https://user-images.githubusercontent.com/112770970/221163838-b6063b1c-b192-4fdd-9928-1a76642e510f.JPG)


- Synthesis

![BA synth](https://user-images.githubusercontent.com/112770970/221163927-37720a22-213c-46a2-a705-5cad774c4cf9.JPG)


- Simulation of the gate level netlist generated

![BA netlist sim](https://user-images.githubusercontent.com/112770970/221163993-3e7f7f23-e216-4db9-813c-f27e9a275072.JPG)

- A delay/flop behaviour can be observed in the simulation waveform.
- This design also results in a simulation synthesis mismatch.


## Day_5

### Incomplete If statements
- Simulation

![incomp if sim](https://user-images.githubusercontent.com/112770970/221235513-28a617ec-2217-452d-aa18-8230dea43691.JPG)


- Synthesis

![incomp if synth](https://user-images.githubusercontent.com/112770970/221235733-9426a6fe-b288-4430-9b38-e4e33bf6943b.JPG)

- It can be seen that a latch is inferred as shown above.

### Incomplete Case statements
- Simulation

![incomp case sim](https://user-images.githubusercontent.com/112770970/221245695-f79c6153-4a55-47a4-9aba-230700f5080b.JPG)


- Synthesis

![incomp case synth](https://user-images.githubusercontent.com/112770970/221245793-50a20891-670b-4868-b1ba-96087b354c85.JPG)

- It can be seen that a latch is inferred as shown above.

- The solution for the above problem is specifiying the default case.

- The simulation and synthesis of case with default is shown below:

![case with default sim](https://user-images.githubusercontent.com/112770970/221246682-7f36c4e3-bd66-4f9d-ab7c-2abba9e2f100.JPG)

![case with default synth](https://user-images.githubusercontent.com/112770970/221246740-f4472080-c4a9-499c-a439-2c2d57002295.JPG)


### Output register not assigned in a particular subcase
- Simulation

![bad case sim](https://user-images.githubusercontent.com/112770970/221247206-472daa5f-7639-4549-b40e-5964dc563941.JPG)


- Simulation of the generated netlist (GLS)

![bad case netlist sim](https://user-images.githubusercontent.com/112770970/221247470-a7563c7c-7c9a-4c9f-9ff2-a4a709a9f606.JPG)


- It can be seen that there exists a simulation synthesis mismatch in this case as output in a particular subcase is not specified.


### Loop and Generate Constructs
- Loops are used to reduce the size of the RTL code in any complex situation.
- Generate blocks are used to instantiate modules many times, in other words, it replicates hardware.

### 1 x 8 Demux using for statements
- Simulation

![demux for loop sim](https://user-images.githubusercontent.com/112770970/221248795-322a358b-99f7-483f-9dc9-485b2cfab4f1.JPG)


- Synthesis

![demux for loop synthJPG](https://user-images.githubusercontent.com/112770970/221248861-b544f89e-a1d7-486b-af74-c6aa24d935a3.JPG)


- Simulation of gate level netlist

![demux for loop netlist sim](https://user-images.githubusercontent.com/112770970/221249009-791bbc62-7271-4ad1-8efb-2321d9fcee95.JPG)

- It can be observed that there is no simulation synthesis mismatch arising in this case.

### Ripple carry adder using generate loop
- Simulation

![rca sim](https://user-images.githubusercontent.com/112770970/221249549-a1500b22-11fa-434a-bda6-f42a118a4bf8.JPG)


- Synthesis

![rca synth](https://user-images.githubusercontent.com/112770970/221249636-2c05ba2b-bde2-43bd-8865-56d57f9ec640.JPG)


- Simulation of gate level netlist

![rca netlist sim](https://user-images.githubusercontent.com/112770970/221249716-cd59ad25-789d-4929-a82e-c8c3633d360d.JPG)

- It can be noted that there is no simulation synthesis mismatch arising in this case.

### Final Observations
- Both if and case statements infer muxes but if statements have priority logic.
- Incomplete if and case statements infer an unwanted latch.
- All the outputs must be specified inside all the sub-cases else latches are inferred.
- Overlapping cases in the case statements leads to ambiguous output.


## Day_6

### Universal shift Register
- Simulation
![WhatsApp Image 2023-03-10 at 15 22 24](https://user-images.githubusercontent.com/83526493/224351419-173c716b-5bc8-49bd-8b66-6639a152bcac.jpg)

- Synthesis (Flattened)
![WhatsApp Image 2023-03-10 at 15 22 25](https://user-images.githubusercontent.com/83526493/224351486-92a1113d-1fde-454a-8a6a-0eab87e1b3e3.jpg)

- Simulation of generated netlist (GLS)
![WhatsApp Image 2023-03-10 at 15 40 46](https://user-images.githubusercontent.com/83526493/224351542-165127b9-98e6-4eb5-b79b-4971a42a5f74.jpg)

- Synthesis of top module
![WhatsApp Image 2023-03-10 at 15 44 34](https://user-images.githubusercontent.com/83526493/224351578-36701c0b-3ed6-431b-971e-ef1bce9df00a.jpg)

- It can be observed from the above images that there is no simulation synthesis mismatch occuring

## Day_7

### Basics of STA
#### Max delay constraints
*T <sub>clk</sub> >= T <sub>CQ</sub> + T <sub>comb</sub> + T <sub>setup</sub>*

#### Min delay constraints
*T <sub>clk</sub> + T <sub>hold<sub> <= T <sub>CQ</sub> + T <sub>comb</sub>*
	
Note : The above equations are used in calculating maximum frequency of clock and modelling combinational delay. 
       Input external delay and output external delay are also similarly specified.

- **Basic concepts**
  * Delay of a cell is a function of input transition and output load.
  * Timing arcs -> combinational and sequential
  * Setup and hold time for a latch and flip flop is around the sampling point.
  * In positive level triggered latch, setup time is before the falling edge (last sampled point).
  * In negative level triggered latch, setup time is before the rising edge (last sampled point).


- **Timing paths**
  * There are 4 types of timing paths based on the data flow between start and end points:	
  * Clock to D pin (register to register)
  * Clock to output (register to out)
  * Input to D pin  (input to register)
  * Input to output 
  

- **Constraints**
  * Modeling of load capacitance (max value must be specified).
  * Using buffers to reduce fanout, thereby, decreasing the max load capacitance.


- **Lookup table**
  * 2D table consisting of corresponding output load and input transistion values.
  * Values in between not specified are calculated through interpolation.
  

- **Unateness**
  * Positive unateness -> AND OR
  * Negative unateness -> NAND NOR NOT
  * Non-unateness -> XOR XNOR

- Note: All the above considerations are specified in the .lib file.

## Day 8: STA analysis
	
**Lab8_circuit timing report**

![lab8_circuit](https://user-images.githubusercontent.com/112770970/230723695-38337455-fc9e-486b-abb7-6753a7a1ddca.JPG)

## Day 9: SDC file writing
Constraints file
![Screenshot from 2023-04-08 18-28-46](https://user-images.githubusercontent.com/83526493/230722458-f2bd09d9-75e6-4cfe-a7f9-9ad1ed5c3dfd.png)

### Timing reports
```OpenSTA> report_checks
Startpoint: reset (input port clocked by MYCLK)
Endpoint: d1/_4_ (recovery check against rising-edge clock MYCLK)
Path Group: **async_default**
Path Type: max

  Delay    Time   Description
---------------------------------------------------------
   0.00    0.00   clock MYCLK (rise edge)
   3.00    3.00   clock network delay (ideal)
   5.00    8.00 v input external delay
   0.00    8.00 v reset (in)
   0.13    8.13 ^ d1/_3_/Y (sky130_fd_sc_hd__clkinv_1)
   0.00    8.13 ^ d1/_4_/RESET_B (sky130_fd_sc_hd__dfrtp_1)
           8.13   data arrival time

  10.00   10.00   clock MYCLK (rise edge)
   3.00   13.00   clock network delay (ideal)
  -0.50   12.50   clock uncertainty
   0.00   12.50   clock reconvergence pessimism
          12.50 ^ d1/_4_/CLK (sky130_fd_sc_hd__dfrtp_1)
   0.20   12.70   library recovery time
          12.70   data required time
---------------------------------------------------------
          12.70   data required time
          -8.13   data arrival time
---------------------------------------------------------
           4.58   slack (MET)


Startpoint: d2/_4_ (rising edge-triggered flip-flop clocked by MYCLK)
Endpoint: q[1] (output port clocked by MYCLK)
Path Group: MYCLK
Path Type: max

  Delay    Time   Description
---------------------------------------------------------
   0.00    0.00   clock MYCLK (rise edge)
   3.00    3.00   clock network delay (ideal)
   0.00    3.00 ^ d2/_4_/CLK (sky130_fd_sc_hd__dfrtp_1)
   2.70    5.70 ^ d2/_4_/Q (sky130_fd_sc_hd__dfrtp_1)
   0.00    5.70 ^ q[1] (out)
           5.70   data arrival time

  10.00   10.00   clock MYCLK (rise edge)
   3.00   13.00   clock network delay (ideal)
  -0.50   12.50   clock uncertainty
   0.00   12.50   clock reconvergence pessimism
  -5.00    7.50   output external delay
           7.50   data required time
---------------------------------------------------------
           7.50   data required time
          -5.70   data arrival time
---------------------------------------------------------
           1.80   slack (MET)
```
