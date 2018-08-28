%--------------------------------------------------
%--------------------------------------------------
%Flicker Metrics
%Authors: Justin Ross, Kory McTague
%Written For SUNY Oswego Summer Research 2018
%Description: This program takes in two separate Excel Spreadsheets (.xlsx)
%And Determines the Average Flicker Index and Percent Flicker for each.
%It gets a frequency from a Pwelch transfrom and uses that frequency to
%determine one cycle. The Flicker Index and Percent Flicker are calculated
%for that individual cycle and stored in a matrix. A predetermined number
%of cycles (The "loop" variable) will run and the average will be taken.
%
%--------------------------------------------------
%--------------------------------------------------
clear
%-------------------------------------------------
%Commonly Changed Variables
%-------------------------
%"loop" is the predefined number of cycles. Will dictate how long a
%for-loop runs
%"fsamp" is the sample rate of the DAQ that was used to obtain the data.
%Make sure that the sample rate for both the sensor and ammeter are the
%same!
%"filename" is intended for the waveform coming from a Light sensor.
%"filename2" is intended for the waveform coming from an ammeter or
%oscillosope
%-------------------------
%Number of Cycles%
loop = 10;
%Sample Rate
fsamp = 3000;
%Sensor File Name
filename = 'C:\Users\jross5\Desktop\WAVE1.xlsx';
%Current (Amps) File Name
filename2 = 'C:\Users\jross5\Desktop\current3.xlsx';
%-------------------------
%Obtain Data from spreadsheet
%-------------------------
%Get Time and Voltage from Excel Spreadsheet
%Fair Warning, These Lines of code take a minute to execute.
time = xlsread(filename, 'A:A');
voltage = xlsread(filename, 'B:B');
%-------------------------
ampTime = xlsread(filename2,'A:A');
current= xlsread(filename2, 'B:B');
%Convert the current readings to a Light reading with the use of a linear
%regression from the 250 mA to 400mA on the current vs relative luminous
%flux curve that was give by the manufaturer.
%The Linear Equation was found to be:
%y=02.38x+16.808
%y = -0.0001x² + 0.3234x
sizeOfCurrent = size(current);
temporaryCurrent = zeros(sizeOfCurrent);
for index = 1:sizeOfCurrent
    temporaryCurrent(index) = (-.0001*(current(index))^2 + 0.3234*(current(index)));
end
current = temporaryCurrent;
%--------------------------------------------------
%Get one period
%--------------------------------------------------
%Sensor Calculations
%
% Choose FFT size and calculate spectrum-Sensor
Nfft = 2048;
%Same Rate
[Pxx,f] = pwelch(voltage,gausswin(Nfft),Nfft/2,Nfft,fsamp);
%Clean up 0 Hz frequency mound.
Pxx(1) = 0;
Pxx(2) = 0;
Pxx(3) = 0;
% Get frequency estimate (spectral peak)
[~,loc] = max(Pxx);
frequency = f(loc);
%Calculate Period
period = 1/frequency;
% 
%Current (A) calculations
%
[Pxx1,f1] = pwelch(voltage,gausswin(Nfft),Nfft/2,Nfft,fsamp);
%Clean up 0 Hz frequency mound.
Pxx1(1) = 0;
Pxx1(2) = 0;
Pxx1(3) = 0;
% Get frequency estimate (spectral peak)
[~,loc] = max(Pxx1);
frequency2 = f1(loc);
%Calculate Period
period2 = 1/frequency2;

%-------------------------
%Isolate Period and Iterate through nth Cycles -Sensor
%-------------------------
%Instantiate Variables
%
%The arrays containing all of the Flicker Indexes and Percent Flickers for
%the Sensor Calculations
arrayFI = zeros(1,loop);
arrayPF = zeros(1,loop);
%The time and data used to display the first cycle
time1 = [];
volts = [];
%Temporary variables to keep track of where in the data we are processing
tempvolts =[];
previousSize2 =0;
%Iterate through each 
for index = 1:loop
    %Determine Time
    temptime1 = time;
    currentPeriod = index*period;
    lastPeriod = (index -1) * period;
    temptime1(temptime1 > (currentPeriod)) = [];
    temptime1(temptime1 < (lastPeriod)) = []; 
    if index == 1
       time1 = temptime1;
    end
    %Determine Signal
    sz = size(temptime1);
    sz = sz(1);
    sz2 = size(voltage);
    sz2 = sz2(1);
    currentSize1 = previousSize2 + sz + 1;
    currentSize2 = currentSize1 + sz2;
    tempvolts = voltage;
    tempvolts(currentSize1: sz2) = [];
    previousSize2 = currentSize2;
    if index == 1
       volts = tempvolts;
    end
%---------------------------------------------------------------------------
%Percent Flicker
%---------------------------------------------------------------------------
%Determine max and Min
    inMax = max(tempvolts);
    inMin = min(tempvolts);
%Computer Percent Flicker. In percent
    pf1 = ((inMax-inMin)/(inMax+inMin))*100;
    arrayPF(1,index) = pf1;
    disp(['Cycle # ' num2str(index) ' Sensor Percent Flicker: ' num2str(pf1,'%.5f') '%'])
%---------------------------------------------------------------------------
%Flicker Index
%----------------------------------------------------------------------------
%Determine average
    average = mean(tempvolts);
%Cut off values below average and shift down to 0.
    tempvolts2 = tempvolts;
    tempvolts2(tempvolts2 < average) = average;
    tempvolts2 = tempvolts2 - average;
    if index == 1
       volts2 = tempvolts2;
    end
%Determine area above average. Using the Trapezoidal sum
    area1 = trapz(tempvolts2);
%Determine total area of 1 period
    totalArea = trapz(tempvolts);
%Compute Flicker Index
    fi1 = area1/totalArea;
    arrayFI(1,index) = fi1;
    disp(['Cycle # ' num2str(index) ' Sensor Flicker Index : ' num2str(fi1,'%.5f')])
end
disp('----------------------------------------------------')
%-------------------------
%-------------------------
%Isolate Period and Iterate through nth Cycles -Current
%-------------------------
%Instantiate Variables
%
%The arrays containing all of the Flicker Indexes and Percent Flickers for
%the Current (A) Calculations
arrayFI2 = zeros(1,loop);
arrayPF2 = zeros(1,loop);
%The time and values used to display the first cycle
time2 = [];
amps = [];
%Temporary variables to keep track of where in the data we are processing
tempamps =[];
previousSize2 =0;
%Iterate through each 
for index = 1:loop
    %Determine Time
    temptime2 = time;
    currentPeriod = index*period;
    lastPeriod = (index -1) * period;
    temptime2(temptime2 > (currentPeriod)) = [];
    temptime2(temptime2 < (lastPeriod)) = []; 
    if index == 1
       time2 = temptime2;
    end
    %Determine Signal
    sz = size(temptime2);
    sz = sz(1);
    sz2 = size(current);
    sz2 = sz2(1);
    currentSize1 = previousSize2 + sz + 1;
    currentSize2 = currentSize1 + sz2;
    tempamps= current;
    tempamps(currentSize1: sz2) = [];
    previousSize2 = currentSize2;
    if index == 1
       amps = tempamps;
    end
%---------------------------------------------------------------------------
%Percent Flicker
%---------------------------------------------------------------------------
%Determine max and Min
    inMax1 = max(tempamps);
    inMin1 = min(tempamps);
%Computer Percent Flicker. In percent
    pf1 = ((inMax1-inMin1)/(inMax1+inMin1))*100;
    arrayPF2(1,index) = pf1;
    disp(['Cycle # ' num2str(index) ' Current Percent Flicker: ' num2str(pf1,'%.5f') '%'])
%---------------------------------------------------------------------------
%Flicker Index
%----------------------------------------------------------------------------
%Determine average
    average = mean(tempamps);
%Cut off values below average and shift down to 0.
    tempamps2 = tempamps;
    tempamps2(tempamps2 < average) = average;
    tempamps2 = tempamps2 - average;
    if index == 1
       amps2 = tempamps2;
    end
%Determine area above average. Using the Trapezoidal sum
    area1 = trapz(tempamps2);
%Determine total area of 1 period
    totalArea = trapz(tempamps);
%Compute Flicker Index
    fi1 = area1/totalArea;
    arrayFI2(1,index) = fi1;
    disp(['Cycle # ' num2str(index) ' Current Flicker Index : ' num2str(fi1,'%.5f')])
end

disp('----------------------------------------------------')
%Calculate the Sensor Averages
avgFI = mean(arrayFI);
avgPF = mean(arrayPF);
%Calculate the Current Averages
avgFI2 = mean(arrayFI2);
avgPF2 = mean(arrayPF2);
%Display calculations
disp(['Average Sensor Percent Flicker with ' num2str(loop) ' Cycles : ' num2str(avgPF,'%.5f')])
disp(['Average Sensor Flicker Index with ' num2str(loop) ' Cycles : ' num2str(avgFI,'%.5f')])
disp(['Average Current Percent Flicker with ' num2str(loop) ' Cycles : ' num2str(avgPF2,'%.5f')])
disp(['Average Current Flicker Index with ' num2str(loop) ' Cycles : ' num2str(avgFI2,'%.5f')])    
%Sensor
%This plot have 4 waveforms. The first one is the raw data that was
%obtained from the file. The second is the frequency chart that shows the
%calculated frequency. The third is the first cycle of the wave from. The
%last is what that waveform looks when the values below the average are
%taken away and the graph is shifted down.
figure(1)
subplot(4,1,1)
plot(time,voltage)
title('Input Waveform')
grid on;
subplot(4,1,2)
plot(f,Pxx);
ylabel('PSD'); xlabel('Frequency (Hz)');
title('Frequency Chart')
grid on;
subplot(4,1,3)
plot(time1,volts)
title('1st Cycle of Original Waveform')
grid on;
subplot(4,1,4)
plot(time1,volts2)
title('1st Cycle of Above the Average Waveform')
grid on;
%Current
%This plot have 4 waveforms. The first one is the raw data that was
%obtained from the file. The second is the frequency chart that shows the
%calculated frequency. The third is the first cycle of the wave from. The
%last is what that waveform looks when the values below the average are
%taken away and the graph is shifted down.
figure(2)
subplot(4,1,1)
plot(ampTime,current)
title('Input Current Waveform')
grid on;
subplot(4,1,2)
plot(f1,Pxx1);
ylabel('PSD'); xlabel('Frequency (Hz)');
title('Frequency Chart')
grid on;
subplot(4,1,3)
plot(time2, amps)
title('1st Cycle of Original Waveform')
grid on;
subplot(4,1,4)
plot(time2,amps2)
title('1st Cycle of Above the Average Waveform')
grid on;