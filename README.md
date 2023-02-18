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
