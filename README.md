# Tunable-Approximate-Booth-Multiplier

This repository contains code and data used to conduct experiments for our paper: "Tunable Approximate Booth Multiplier." Submitted for ISVLSI 2025.

This research studies an approximate computing method for the Booth Multiplier, where the partial products are generated from the most significant bit to the least. Any bits of the number that are the same as the previous bit are skipped, resulting in compute cycles being equal to or less than the bit width. Approximation is achieved by stopping the circuit before the necessary compute cycles have concluded.

The code in this repository is meant as a proof of concept and not as a self-sufficient tool. Code is provided under the LICENSE attached to this repository.

Repository Authors:
- <ins>Authors anonymized for review process</ins>


## Functional simulator
The Functional_sim directory contains the functional simulator for the Tunable Approximate Booth Multiplier. The simulator has been implemented in Python and C++.

The Python version is intended for easier understanding of the simulator but also works for small multiplication sizes up to 11 bits. The C++ version is intended for efficiency, as it can be compiled and runs fast for multiplication sizes up to 32 bits.

Use the Python simulator as shown in the main function of /Functional_sim/py/booth.py. A multiplication can be done by first creating two bitarrays:
```
size = 8
A = BT_int(-86, size)  // -86 as bitarray of size 8
B = BT_int(-93, size)  // -93 as bitarray of size 8
```
Then you can multiply them using:
```
res = axc_booth(A, size, B, size, 4) // multiply A and B using 4 cycles 
```
The arguments for axc_booth are:
- input bitarray 1
- bit size of input 1
- input bitarray 2
- bit size of input 2
- number of cycles to run (1 up to bit size of input 1)

Alternatively, you can use scan_sizes or scan_random to perform multiple multiplications using axc_booth. 
scan_sizes executes every possible multiplication for the given sizes, while scan_random performs 10^7 random input multiplications.

To use the C++ simulator, you first need to run Functional_sim/cpp/input_gen.py:
```
cd Functional_sim/cpp/
python input_gen.py
```
This file creates the random input binary file that the simulator needs to run scan_random_evaluator.

The code can be run by first compiling it:
```
make
```
Then running the main executable:
```
./main
```
Similarly to the Python version, the C++ simulator supports scan_sizes and scan_random, found as scan_sizes_evaluator and scan_random_evaluator inside Functional_sim/cpp/evaluator.cpp, and normal multiplication found in Functional_sim/cpp/booth_multiplier.cpp as axc_booth. This code works for multiplication sizes up to 32 bits.


## RTL
The Verilog description for the Tunable Approximate Booth Multiplier is provided in this repository as open-source hardware. It can be found under the RTL/ directory. This directory contains four Verilog module files, with axc_booth.v as the top module, the libmerge.py file, a synthesis TCL script, a testbench subdirectory, and the gf180mcu-pdk subdirectory.

You can customize the Tunable Approximate Booth Multiplier circuit by selecting different integer values in the range [2,32] (values above 32 should work theoretically but have not been tested) for NA and NB inside axc_booth.v. These represent the multiplication width of the multiplier. They can be different, but NA must always be less than or equal to NB. You do not need to set NC, as that is done automatically.

A simple testbench is provided inside RTL/test_bench. Inside the testbench, you can try various multiplication sizes by setting the parameters NA and NB (this will not affect synthesis; for synthesis, you must set the parameters inside axc_booth.v). You can run the testbench by executing:
```
cd RTL/
iverilog axc_booth.v axc_booth_tb.v lookahead_priority_enforcer.v transition_detect.v barrel_shifter.v test_bench/axc_booth_tb.v
vvp a.out
```
And check the waveform file using (note: gtkwave.gtkw is a save file for GTKWave that shows the input and output signals):
```
gtkwave test.vcd -a gtkwave.gtkw
```
Sample test.vcd and gtkwave.gtkw files are provided. The gtkwave.gtkw file may not work if you change the multiplication size.

To synthesize the design using the TCL script, you need the gf180mcu-pdk library file and Cadence Genus. First, get the gf180mcu-pdk submodule:
```
git submodule update --init --recursive
```
Then go into RTL/ and run the libmerge.py script. This will create the library file gf180mcu.lib:
```
cd RTL/
python libmerge.py
```
Then you can run Cadence Genus:
```
genus -f synth.tcl
```
After running you can get the results in the files:
- axc_booth_timing.rpt
- axc_booth_power.rpt
- axc_booth_area.rpt

If you want to use a different library, set the correct directory inside synth.tcl on line 1 and the correct file name on line 2.
If you want to use a different synthesis program, synth.tcl might not work. You will need to read it and create an equivalent script/process for your program.


## Results
The Results/ directory contains the results used in the paper.

- accuracy_results.json contains the results from the C++ simulator.
- multiply_results.json contains image multiplication results from a sample image editing application using the Tunable Approximate Booth Multiplier.
- sharpen_results.json contains image sharpening results from a sample image editing application using the Tunable Approximate Booth Multiplier.
