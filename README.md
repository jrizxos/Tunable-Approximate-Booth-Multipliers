# Tunable-Approximate-Booth-Multiplier

This repository contains code and data used to conduct experiments for our paper: I. Rizos, G. Papatheodorou, A. Efthymiou "Tunable Approximate Booth Multiplier". Submitted for ISVLSI 2025. 

The code in this repository is meant as a proof of concept and not as a self-sufficient tool. Code provided under the LISCENCE attached to this repository.

Repository Authors:
- Ioannis Rizos

## Functional simulator
The functional simulator directory contains the functional simulator for the Tunable Approximate Booth Multiplier. 
The simulator has been implemented in Python and C++. 
The Python version is intended for easier understanding of the simulator, but also works for small multiplication sizes up to 11-bits. 
The C++ version is intended for efficiency as it can be compiled and runs fast for mutliplication sizes up to 32-bits. 

Use the Python simulator as can be seen in the main of /Functional_sim/py/booth.py. 
A multiplication can be done by first creating two bitarrays:
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

Alternativelly you can use scan_sizes or scan_random to do a lot of multiplications using axc_booth.
scan_sizes does every possible multiplication for the given sizes, while scan_random does 10^7 random input multiplications.

To use the C++ simulator you first need to run Functional_sim/cpp/input_gen.py:
```
cd Functional_sim/cpp/
python input_gen.py
```
This file will create the random input binary file that the simulator needs to run scan_random_evaluator.

The code can be run by first compiling it:
```
make
```
Then running main:


## RTL

## Results
