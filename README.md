# VSD-HDP Status
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

## Day 7
### Advanced synthesis and STA using Design compiler
#### Max delay constraints
