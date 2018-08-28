# LED-Flicker-Research
The data collection and data processing programs that were written for Summer 2018's LED Flicker Research.

# LabVIEW VI:
This Virtual Instrument collects data from a Data Aquisition (DAQ) segment of the NI Elvis II Development Board. It simultaneously grabs a 
capture from a neighboring Oscilloscope. The Oscilloscope should be measuring the current running through the LED Driver Circuit. The DAQ is measuring the signal that comes from the Light sensor at the other end of the box.

# MATLAB Script:
This script takes two sets of data, the first being the data from the sensor, the second being the data from the current probe. It adjusts the current to what the projected light output should be. Then it calculates the average Flicker Index and Percent Flicker throught a user defined number of cycles from the waveform. The average is taken to ensure accuracy. It displays all of the results from the calculations as well as a few graphs to ensure that the program ran correctly.
