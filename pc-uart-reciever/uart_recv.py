import serial
import pyaudio
import numpy as np
import wave
import scipy.signal as signal
import warnings
from bitstring import BitArray

def serial_init(speed):
    dev = serial.Serial(
        port='/dev/ttyUSB0', 
        baudrate=speed,
        parity=serial.PARITY_NONE,
        stopbits=serial.STOPBITS_ONE,
        bytesize=serial.EIGHTBITS
    )
    return dev

def serial_recv(dev):
    string = dev.read(1)
    return string

if __name__ == '__main__':
	dev = serial_init(240000)

	inputStr = ""
	while True:
		instr = serial_recv(dev)
		hex_string = instr.hex()
		binary_data = BitArray(hex=hex_string)

		print(binary_data.bin)