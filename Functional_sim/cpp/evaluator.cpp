#include "evaluator.hpp"
#include <iostream>

string getExecutablePath() {
    // Get the path to this executable
    char buffer[4096];
    ssize_t len = readlink("/proc/self/exe", buffer, sizeof(buffer) - 1);
    if (len != -1) {
        buffer[len] = '\0';
    }
    return string(buffer);
}

array<double, 4> scan_sizes_evaluator(int size_a, int size_b, int cycles) {
    // Does every possible multiplication for given sizes of A B in given cycles to find MRE.

    double MRE = 0, MAE = 0, MSE = 0, ERR_PROB, delta, rel_delta, sqr_delta;
    int error_count = 0;
    long long int_A, int_B, exp, res, mul_num = 1 << (size_a + size_b);

    for (long long i = 0; i < (1 << size_a); ++i) {
        BitArray A = BT_int(i, size_a);
        int_A = int_BT(A, size_a);
        for (long long j = 0; j < (1 << size_b); ++j) {
            BitArray B = BT_int(j, size_b);
            int_B = int_BT(B, size_b);

            exp = int_A * int_B;
            res = axc_booth(A, size_a, B, size_b, cycles);

            if(exp != res) error_count++;
            delta = abs(exp - res);
            rel_delta = delta/max(1LL,abs(exp));
            sqr_delta = delta*delta;
            MRE += rel_delta / mul_num;
            MAE += delta / mul_num;
            MSE += sqr_delta / mul_num;
        }
    }
    ERR_PROB = ((double)error_count) / mul_num;
    return {MRE, MAE, MSE, ERR_PROB};
}

array<double, 4> scan_random_evaluator(int size_a, int size_b, int cycles) {
    // Does every MUL_NUM random multiplications for given sizes of A B in given cycles to find MRE.

    string exe_path = getExecutablePath();                              // This is needed because somehow C++ thinks that when opening a file
    filesystem::path exe_dir = filesystem::path(exe_path).parent_path();// with ifstream, the file is realative to the CWD of whoever called
    filesystem::path file_path = exe_dir / "inp.bin";                   // the executable instead of relative to the executable's directory.
    ifstream inp_file(file_path, ios::binary );                         // File that contains test values.
    if(!inp_file) {                                                     // check file exists
        printf("[file error] Failed to open inp.bin\n");
        return {-1.0,-1.0,-1.0,-1.0};
    }
    
    double MRE = 0, MAE = 0, MSE = 0, ERR_PROB, delta, rel_delta, sqr_delta;
    int error_count = 0;
    long long int_A,int_B, exp, res; 
    for (int t = 0; t < MUL_NUM; ++t) {
        inp_file.read(reinterpret_cast<char *>(&int_A), 8); 
        inp_file.read(reinterpret_cast<char *>(&int_B), 8);

        BitArray A = BT_int(int_A, size_a);
        int_A = int_BT(A, size_a);
        BitArray B = BT_int(int_B, size_b);
        int_B = int_BT(B, size_b);
        
        exp = (long)int_A * (long)int_B;
        res = axc_booth(A, size_a, B, size_b, cycles);

        if(exp != res) error_count++;
        delta = abs(exp - res);
        rel_delta = delta/max(1LL,abs(exp));
        sqr_delta = delta*delta;
        MRE += rel_delta / MUL_NUM;
        MAE += delta / MUL_NUM;
        MSE += sqr_delta / MUL_NUM;
    }
    ERR_PROB = ((double)error_count) / MUL_NUM;
    return {MRE, MAE, MSE, ERR_PROB};
}