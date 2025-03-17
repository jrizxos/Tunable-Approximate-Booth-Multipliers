#ifndef _BOOTH_
#define _BOOTH_

#include "twos_complement.hpp"
using namespace std;

pair<BitArray, BitArray> transition_detect(const BitArray &A, int size);
long long priority_encoder(const BitArray &A, int size, const BitArray &mask);
long long axc_booth(const BitArray &A, int size_a, const BitArray &B, int size_b, int cycles, int flip_pm);

#endif