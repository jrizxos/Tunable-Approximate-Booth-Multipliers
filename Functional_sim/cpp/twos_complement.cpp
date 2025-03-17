#include "twos_complement.hpp"

string tc_int(long long A, int size) {
    // Twos complement string of length size from int. 
    if (A >= 0)
        return bitset<128>(A).to_string().substr(128 - size);
    return bitset<128>((1ULL << size) + A).to_string().substr(128 - size);
}

string str_BT(const BitArray &A, int size) {
    // String of length size from bitarray.
    string result;
    for (int i = size - 1; i >= 0; --i) {
        result += (A[i] ? '1' : '0');
    }
    return result;
}

long long int_BT(const BitArray &A, int size) {
    // Integer from bitarray of length size. 
    string str_A = str_BT(A, size);
    long long msb = str_A[0] - '0';
    long long lsb = size > 1 ? stoll(str_A.substr(1), nullptr, 2) : 0;
    return lsb - (1LL << (size - 1)) * msb;
}

BitArray BT_int(long long A, int size) {
    //  Bitarray of length size from int.
    string bin_str = tc_int(A, size);
    reverse(bin_str.begin(), bin_str.end());
    BitArray bitArray;
    for (char bit : bin_str) {
        bitArray.push_back(bit == '1');
    }
    return bitArray;
}