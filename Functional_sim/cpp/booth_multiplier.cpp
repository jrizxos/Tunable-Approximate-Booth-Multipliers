#include "booth_multiplier.hpp"

pair<BitArray, BitArray> transition_detect(const BitArray &A, int size) {
    // Detects all transitions in A, returns two bitarrays with positive (0->1) and negative (1->0) trasitions.
    BitArray plus_t(size, false);
    BitArray minus_t(size, false);

    for (int i = 1; i < size; ++i) {
        minus_t[i] = A[i] && !A[i - 1];
    }
    minus_t[0] = A[0];
    for (int i = 1; i < size; ++i) {
        plus_t[i] = !A[i] && A[i - 1];
    }
    plus_t[0] = false;
    return {plus_t, minus_t};
}

long long priority_encoder(const BitArray &A, int size, const BitArray &mask) {
    // Returns the index of the first bit of A that is not set in the mask.
    BitArray masked_A(size);
    for (int i = 0; i < size; ++i) {
        masked_A[i] = A[i] && !mask[i];
    }
    for (int i = size - 1; i >= 0; --i) {
        if (masked_A[i]) {
            return (long long)i;
        }
    }
    return -1;
}

long long axc_booth(const BitArray &A, int size_a, const BitArray &B, int size_b, int cycles, int flip_pm) {
    // Does the approximate booth operation with skip skipped bits and the A and B bitarrays as input.
    auto [plus_t_A, minus_t_A] = transition_detect(A, size_a);
    long long int_b = int_BT(B, size_b);
    long long sum = 0;
    BitArray priority_mask(size_a, false);
    bool p_done = false, m_done = false, p_flag;
    long long shift_amount;

    for (int t = 0; t < cycles; ++t) {
        p_flag = false;

        if (!p_done && (t+flip_pm) % 2 == 0) {
            shift_amount = priority_encoder(plus_t_A, size_a, priority_mask);
            if (shift_amount >= 0) {
                sum += int_b << shift_amount;
                priority_mask[shift_amount] = true;
                p_flag = true;
            } else {
                p_done = true;
            }
        }

        if (!m_done && !p_flag) {
            shift_amount = priority_encoder(minus_t_A, size_a, priority_mask);
            if (shift_amount >= 0) {
                sum -= int_b << shift_amount;
                priority_mask[shift_amount] = true;
            } else {
                m_done = true;
            }
        }
        
        if (p_done && m_done) {
            break;
        }
    }
    return sum;
}