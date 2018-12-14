#!/usr/bin/python3

from fixed_params import *;


from bitstring import Bits
def to_fixed(val : float):
    intval = round(val*(2**LSB))
    b = Bits(int=intval, length=MSB+LSB)
    return b
while 1:
    val = input("Value: ")
    try:
        b = to_fixed(float(val))
        print('bin:', b.bin)
        print('hex:', b.hex)
        print()
    except Exception as e:
        print(e)
#print(struct.pack('f', 1.5))

#(1, 1)
#-2, -1
#-3, -2
#-4, -3
#-5, -4
#-5.03, -5
#-5.2, -5.03
#-5.41, -5.2
#-5.66, -5.41
#-6, -5.66
#-6.53, -6
#-7.6, -6.53
#inf ,-7.6
#1, 2
#2, 3
#3, 4
#4, 5
#5, 5.0218
#5.0218, 5.1890
#5.1890, 5.3890
#5.3890, 5.6380
#5.6380, 5.9700
#5.9700, 6.4700
#6.4700, 7.5500
#7.5500, inf
