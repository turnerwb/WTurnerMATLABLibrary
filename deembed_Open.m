function [S_Corrected] = deembed_Open(S_Meas,S_Open)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
Y1 = yparameters(S_Meas);
Z_Corrected = zparameters(S_Meas);
Y_Meas = yparameters(S_Meas);
Y_Open = yparameters(S_Open);
Y1.Parameters = Y_Meas.Parameters - Y_Open.Parameters;
Z1 = zparameters(Y1);
Z_Corrected.Parameters = Z1.Parameters;
S_Corrected = sparameters(Z_Corrected);
end