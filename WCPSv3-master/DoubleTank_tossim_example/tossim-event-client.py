#!/usr/bin/env python
from TOSSIM import Tossim
from random import *
from TestNetworkMsg import *
import sys
import socket

enable_main=0;
if enable_main:
	def main():
		#Event_flag=sys.argv[2]
		rssi_level=sys.argv[1]

		return {'y0':rssi_level}
		rssi_level=int(main()['y0'])
		#Event_flag=int(main()['y1'])


else:
	noise_offset = 7

Event_flag = float(sys.argv[1])
Event_flag2 = float(sys.argv[2])
#rssi_level=float(sys.argv[1])
#print("rssi_level:",rssi_level)
#Event_falg= sys.argv[2]
#print("Event_flag",Event_flag)
payload = [float(sys.argv[1]), float(sys.argv[2]),float(sys.argv[3])]		##***

# Create a TCP/IP socket
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
#server_address = ('localhost', 10032)
server_address = ('127.0.0.1', 10035)
sock.connect(server_address)
try:
	#message = '0';
	#message = str(Event_flag);
	message = str(payload)
	sock.sendall(message)
	amount_received = 0
	amount_expected = len(message)
	while amount_received < amount_expected:

		data = sock.recv(90)
		if data:
			amount_received += len(data) + 5
			print data
finally:
    sock.close()
