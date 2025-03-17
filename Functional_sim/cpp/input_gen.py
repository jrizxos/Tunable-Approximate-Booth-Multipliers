import numpy as np

def inp_gen():
    '''Generates a binary file with input pairs for cppsim/evaluator.cpp
        Creates a file "inp.bin" with the input pairs, every four bytes is a new input
        !!! Beware that the endianess is depended on your system architecture !!!
    '''

    np.random.seed(42)
    num_numbers = 20000000

    # Generate unique random integers in the range [0, 2^64 - 1]
    random_numbers = np.random.randint(0, 2**64, num_numbers, dtype=np.uint64)

    # Save the unique positive random numbers to binary file
    output_file = "inp.bin"
    with open(output_file, 'wb') as file:
        num_bytes = bytearray(random_numbers)
        file.write(num_bytes)

    # print first few 
    print('first few:')
    for i in range(10):
        print(random_numbers[i])

if __name__=="__main__":
    inp_gen()
