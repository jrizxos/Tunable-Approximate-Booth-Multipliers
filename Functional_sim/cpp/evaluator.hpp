#ifndef _EVAL_
#define _EVAL_

#include <array>
#include <fstream>
#include <unistd.h> 
#include <filesystem>
#include "twos_complement.hpp"
#include "booth_multiplier.hpp"
using namespace std;

#define MUL_NUM 10000000

string getExecutablePath();
array<double, 4> scan_sizes_evaluator(int size_a, int size_b, int cycles);
array<double, 4> scan_random_evaluator(int size_a, int size_b, int cycles);

#endif