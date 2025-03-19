#include <stdio.h>
#include <chrono>
#include "evaluator.hpp"
#include <float.h>

int main() {
    array<double, 4> resluts;

    printf("Simulation start...\n");
    
    auto start = chrono::high_resolution_clock::now();

    // 4x4
    for(int i=4; i>=1; i--){
        resluts = scan_sizes_evaluator(4, 4, i);
        printf("\"04-04-%02d\":{\"MRE\":%lf,\"MAE\":%lf,\"MSE\":%lf,\"EP\":%lf},\n", i, resluts[0], resluts[1], resluts[2], resluts[3]);
    }

    // 4x8
    for(int i=4; i>=1; i--){
        resluts = scan_sizes_evaluator(4, 8, i);
        printf("\"04-08-%02d\":{\"MRE\":%lf,\"MAE\":%lf,\"MSE\":%lf,\"EP\":%lf},\n", i, resluts[0], resluts[1], resluts[2], resluts[3]);
    }

    // 8x8
    for(int i=8; i>=1; i--){
        resluts = scan_sizes_evaluator(8, 8, i);
        printf("\"08-08-%02d\":{\"MRE\":%lf,\"MAE\":%lf,\"MSE\":%lf,\"EP\":%lf},\n", i, resluts[0], resluts[1], resluts[2], resluts[3]);
    }

    // 8x16
    for(int i=8; i>=1; i--){
        resluts = scan_sizes_evaluator(8, 16, i);
        printf("\"08-16-%02d\":{\"MRE\":%lf,\"MAE\":%lf,\"MSE\":%lf,\"EP\":%lf},\n", i, resluts[0], resluts[1], resluts[2], resluts[3]);
    }

    // 16x16
    for(int i=16; i>=1; i--){
        resluts = scan_random_evaluator(16, 16, i);
        printf("\"16-16-%02d\":{\"MRE\":%lf,\"MAE\":%lf,\"MSE\":%lf,\"EP\":%lf},\n", i, resluts[0], resluts[1], resluts[2], resluts[3]);
    }

    // 20x20
    for(int i=20; i>=1; i--){
        resluts = scan_random_evaluator(20, 20, i);
        printf("\"20-20-%02d\":{\"MRE\":%lf,\"MAE\":%lf,\"MSE\":%lf,\"EP\":%lf},\n", i, resluts[0], resluts[1], resluts[2], resluts[3]);
    }

    // 24x24
    for(int i=24; i>=1; i--){
        resluts = scan_random_evaluator(24, 24, i);
        printf("\"24-24-%02d\":{\"MRE\":%lf,\"MAE\":%lf,\"MSE\":%lf,\"EP\":%lf},\n", i, resluts[0], resluts[1], resluts[2], resluts[3]);
    }

    // 28x28
    for(int i=28; i>=1; i--){
        resluts = scan_random_evaluator(28, 28, i);
        printf("\"28-28-%02d\":{\"MRE\":%lf,\"MAE\":%lf,\"MSE\":%lf,\"EP\":%lf},\n", i, resluts[0], resluts[1], resluts[2], resluts[3]);
    }

    // 32x32
    for(int i=32; i>=1; i--){
        resluts = scan_random_evaluator(32, 32, i);
        printf("\"32-32-%02d\":{\"MRE\":%lf,\"MAE\":%lf,\"MSE\":%lf,\"EP\":%lf},\n", i, resluts[0], resluts[1], resluts[2], resluts[3]);
    }

    auto end = chrono::high_resolution_clock::now();
    chrono::duration<double> elapsed = end - start;

    printf("Simulation done! (in %lf seconds)\n", elapsed.count());
    return 0;
}