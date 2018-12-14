#!/usr/bin/python3

from fixed_params import *;

from bitstring import BitArray
def to_float(val : str) -> float:
    a = BitArray(val)
    return a.int/(2**LSB)
while 1:
    val = input("Value: ")
    try:
        print(to_float(val))
    except Exception as e:
        print(e)
#print(struct.pack('f', 1.5))

