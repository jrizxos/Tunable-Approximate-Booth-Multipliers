#ifndef _TC_
#define _TC_

#include <vector>
#include <bitset>
#include <string>
#include <algorithm>

using namespace std;

using BitArray = std::vector<bool>;

string tc_int(long long A, int size);
string str_BT(const BitArray &A, int size);
long long int_BT(const BitArray &A, int size);
BitArray BT_int(long long A, int size);

#endif