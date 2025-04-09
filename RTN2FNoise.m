function [FNoise] = RTN2FNoise(RTN_Path)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
[data,~,~,~,~]=ReadMDMV2(RTN_Path);
%Assuming Ts (and L) is consistent for each bias... You might be able to
%force this to fail, but not sure how with the LFNA
time=data(:,1,:);
Ts = time(2,1,1)-time(1,1,1);
Fs = 1/Ts;
FNoise = zeros(size(data,1)/2+1,size(data,2)/2+1,size(data,3));
NoiseData = squeeze(data(:,2,:));
L = size(time,1);
FFTdata = fft(NoiseData,size(NoiseData,1),1);
P2 = abs(FFTdata/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f=Fs/L*(0:L/2);
f = repmat(f,1,1,size(FNoise,3));
FNoise(:,1,:) = f;
FNoise(:,2,:) = P1;
end