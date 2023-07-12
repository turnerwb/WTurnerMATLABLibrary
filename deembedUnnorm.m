function [S_Corrected,Z_Corrected] = deembedUnnorm(S_Meas,S_Open,S_Short,Z0Meas,Z0Open,Z0Short)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if nargin<6
    Z0Short = 50;
    if nargin<5
        Z0Open = 50;
        if nargin<4
            Z0Meas = 50;
        end
    end
end
S1 = sparameters(S_Meas);
S2 = sparameters(S_Open);
f = S1.Frequencies;
s1 = S1.Parameters;
s2 = S2.Parameters;
z1 = s2zCmplx(s1,Z0Meas);
z2 = s2zCmplx(s2,Z0Open);
y1 = z2y(z1);
y2 = z2y(z2);
Y1 = yparameters(y1, f);
Y2 = yparameters(y2, f);
zcorrected = s2zCmplx(s1,Z0Meas);
Z_Corrected = zparameters(zcorrected, f);
Y_Meas = yparameters(y1,f);
Y_Open = yparameters(y2,f);
Sshort = sparameters(S_Short);
sshort = Sshort.Parameters;
zshort = s2zCmplx(sshort,Z0Short);
yshort = z2y(zshort);
Y_Short = yparameters(yshort,f);
Y1.Parameters = Y_Meas.Parameters - Y_Open.Parameters;
Y2.Parameters = Y_Short.Parameters - Y_Open.Parameters;
Z1 = zparameters(Y1);
Z2 = zparameters(Y2);
Z_Corrected.Parameters = Z1.Parameters - Z2.Parameters;
S_Corrected = sparameters(Z_Corrected);
end