#!/usr/bin/env python
from TOSSIM import Tossim
from random import *
from TestNetworkMsg import *
import sys
import socket

def squared(x):
    y = x * x
    return y

if __name__ == '__main__':
    x = float(sys.argv[1])
    #rssi_level = float(sys.argv[1])
    Event_flag = float(sys.argv[2])


    sys.stdout.write(str(squared(x)))
