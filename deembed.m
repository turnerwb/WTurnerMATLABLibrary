function [S_Corrected] = deembed(S_Meas,S_Open,S_Short)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
Y1 = yparameters(S_Meas);
Y2 = yparameters(S_Open);
Z_Corrected = zparameters(S_Meas);
Y_Meas = yparameters(S_Meas);
Y_Open = yparameters(S_Open);
Y_Short = yparameters(S_Short);
Y1.Parameters = Y_Meas.Parameters - Y_Open.Parameters;
Y2.Parameters = Y_Short.Parameters - Y_Open.Parameters;
Z1 = zparameters(Y1);
Z2 = zparameters(Y2);
Z_Corrected.Parameters = Z1.Parameters - Z2.Parameters;
S_Corrected = sparameters(Z_Corrected);
end