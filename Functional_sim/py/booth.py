from bitarray import bitarray as BT
import random
random.seed(42)

def tc_int(A:int, size:int) -> str:
    ''' Twos complement string of length size from int. '''
    if(A >=0):
        return bin(A)[2:].zfill(size)
    return bin((1 << size) + A)[2:]


def str_BT(A:BT, size:int) -> str:
    ''' String of length size from bitarray. '''
    return str(A[::-1])[10:10+size]


def int_BT(A:BT, size:int) -> str:
    ''' Integer from bitarray of length size. '''
    str_A = str_BT(A, size)
    msb = int(str_A[0]) 
    lsb = int(str_A[1:],base=2) if size>1 else 0
    return lsb - 2**(size-1)*msb


def BT_int(A:int, size:int) -> BT:
    ''' Bitarray of length size from int. '''
    bin_str = tc_int(A, size)[::-1]
    return BT(bin_str, endian='little')


def transition_detect(A:BT, size:int) -> tuple[BT,BT]:
    ''' Detects all transitions in A, returns two bitarrays with positive (0->1) and negative (1->0) trasitions. '''
    plus_t = BT(size)
    minus_t = BT(size)

    for i in range(1,size):
        minus_t[i] = A[i] and not A[i-1]
    minus_t[0] = A[0]
    for i in range(1,size):
        plus_t[i] = not A[i] and A[i-1]
    plus_t[0] = 0
    return plus_t, minus_t


def priority_encoder(A:BT, size:int, mask:BT) -> BT:
    ''' Returns the index of the first bit of A that is not set in the mask. '''
    A = A & ~mask
    for i in range(size-1,-1,-1):
        if(A[i]):
            return i
    return -1


def axc_booth(A:BT, size_a:int, B:BT, size_b:int, cycles:int, flip_pm:int) -> int:
    ''' Does the approximate booth operation with skip skipped bits and the A and B bitarrays as input. '''

    plus_t_A, minus_t_A = transition_detect(A, size_a)
    int_b = int_BT(B, size_b)
    sum = 0
    priority_mask = BT(size_a)
    p_done = False
    m_done = False

    for t in range(cycles):
        p_flag = False
        if(not p_done and (t+flip_pm)%2==0):
            shift_ammount = priority_encoder(plus_t_A, size_a, priority_mask)
            if(shift_ammount>=0):
                sum += int_b<<shift_ammount
                priority_mask[shift_ammount] = 1
                p_flag = True
            else:
                p_done = True

        if(not m_done and not p_flag):
            shift_ammount = priority_encoder(minus_t_A, size_a, priority_mask)
            if(shift_ammount>=0):
                sum -= int_b<<shift_ammount
                priority_mask[shift_ammount] = 1
            else:
                m_done = True
            
        if(p_done and m_done):
            break

    return sum


def scan_sizes(size_a:int, size_b:int, cycles:int, flip_pm:int):
    ''' Does every possible multiplication for given sizes of A B in given cycles to find MRE. '''
    MRE = 0
    MUL_NUM = 2**(size_a+size_b)
    for i in range(2**size_a):
        #print(i, '/', 2**size_a, end='\r', flush=True)
        A = BT_int(i, size_a)
        int_A = int_BT(A, size_a)
        for j in range(2**size_b):
            B = BT_int(j, size_b)
            int_B = int_BT(B, size_b)
            exp = int_A*int_B
            res = axc_booth(A, size_a, B, size_b, cycles, flip_pm)
            delta = abs(exp-res)/max(1,exp)
            MRE += delta/MUL_NUM
    #print()
    return MRE


def scan_random(size_a:int, size_b:int, cycles:int, flip_pm:int):
    ''' Does every MUL_NUM random multiplications for given sizes of A B in given cycles to find MRE. '''
    MUL_NUM = 10**7
    MRE = 0
    for t in range(MUL_NUM):
        #print(t, '/', MUL_NUM, end='\r', flush=True)
        A = BT_int(random.randrange(0,2**size_a), size_a)
        int_A = int_BT(A, size_a)
        B = BT_int(random.randrange(0,2**size_b), size_b)
        int_B = int_BT(B, size_b)
        exp = int_A*int_B
        res = axc_booth(A, size_a, B, size_b, cycles, flip_pm)
        delta = abs(exp-res)/max(1,exp)
        MRE += delta/MUL_NUM
    return MRE


if __name__=="__main__":
    size = 8
    A = BT_int(-86, size)
    B = BT_int(-93, size)
    int_A = int_BT(A, size)
    int_B = int_BT(B, size)
    exp = int_A*int_B
    res = axc_booth(A, size, B, size, size, 0)
    print(str_BT(A, size), 'x', str_BT(B, size), '=', BT_int(exp, 26), ':', BT_int(res, 26))
    print(int_A, 'x', int_B, '=', exp, ':', res)

    #scan_sizes_plotting(size,size,size,0)

    print('Done')