function [SParams] = SSHEMTParams(Cgda, Cpga, Cpda, ...
    Lg, Ld, Ls, gm,...
    Cpgi, Cgdi, Cpdi, Rg, Rd, Rs, Rgdi, Rgsi, Cgs, Cgd, Ri, Rgd, Rds, Cds,f)
%SSHEMTParams Calculates S-Parameters given the Small Signal Parameters of
%a GaN HEMT
%   Computes S Paramters by way of Y Paramters for a GaN HEMT (Absent FE
%   Gating) based on calculated Small-Signal parameters.


w = 2*pi.*f;

ZCgda = 1./(1j*w*Cgda);   
ZCpga = 1./(1j*w*Cpga);
ZCpda = 1./(1j*w*Cpda);

ZLg = 1j*w*Lg;
ZLd = 1j*w*Ld;
ZLs = 1j*w*Ls;

ZCgdi = 1./(1j*w*Cgdi);
ZCpgi = 1./(1j*w*Cpgi);
ZCpdi = 1./(1j*w*Cpdi);

ZCgs = 1./(1j*w*Cgs);
ZCgd = 1./(1j*w*Cgd);
ZCds = 1./(1j*w*Cds);

Z1 = Rgd + (1/Rgdi + 1./ZCgd).^(-1) + (1/Rgsi + 1./ZCgs).^(-1);
Z2 = (1/Rgsi + 1./ZCgs).^(-1) + Ri;
Z3 = (1/Rds + 1/ZCds).^(-1);
%%
YMTX = @(Vgs, Vds,i) [1 0 0 0 0 0 0 0 Vgs;...
    -1./ZLg(i) (1./ZLg(i) + 1./ZCgdi(i) + 1/Rg + 1./ZCpgi(i)) -1/Rg 0 -1/ZCgdi(i) 0 -1/ZCpgi(i) 0 0;...
    0 -1/Rg (1/Rg + 1/Z2(i) + 1/Z1(i)) -1/Z1(i) 0 -1/Z2(i) 0 0 0 ;...
    0 0 (-1/Z1(i) + gm) (1/Z3(i) + 1/Rd + 1/Z1(i)) -1/Rd -1/Z3(i) 0 0 0;...
    0 -1/ZCgdi(i) -1/Rd (1/ZCgdi(i) + 1/ZCpdi(i) + 1/Rd + 1/ZLd(i)) 0 -1/ZCpdi(i) -1/ZLd(i) 0 0;...
    0 0 (-1/Z2(i) - gm) -1/Z3(i) 0 (1/Z2(i) + 1/Z3(i) + 1/Rs) -1/Rs 0 0;...
    0 -1/ZCpgi(i) 0 0 -1/ZCpdi(i) -1/Rs (1/ZLs(i) + 1/Rs + 1/ZCpgi(i) + 1/ZCpdi(i)) 0  0;...
    0 0 0 0 0 0 0 1 Vds];

%Y11 and Y21
Y11 = -99 * ones(1,length(f));
Y21 = -99 * ones(1,length(f));
for i = 1:max(length(f))
    YEVAL = YMTX(1,0,i);
    A = YEVAL(:,1:end-1);
    B = YEVAL(:,end);
    V = pinv(A)*B;
    I1 = (V(1) - V(8))./ZCgda(i) + V(1)./ZCpga(i) + (V(1) - V(2))./ZLg(i);
    I2 = (V(8) - V(1))./ZCgda(i) - V(8)./ZCpda(i) + (V(8) - V(5))./ZLd(i);
    Y11(i) = I1;
    Y21(i) = I2;
    if sum(isnan(Y11)) ~= 0
        print("HERE")
    end
end

%Y12 and Y22
Y12 = -99 * ones(1,length(f));
Y22 = -99 * ones(1,length(f));
for i = 1:max(length(f))
    YEVAL = YMTX(0,1,i);
    A = YEVAL(:,1:end-1);
    B = YEVAL(:,end);
    V = pinv(A)*B;
    I1 = (V(1) - V(8))./ZCgda(i) + V(1)./ZCpga(i) + (V(1) - V(2))./ZLg(i);
    I2 = (V(8) - V(1))./ZCgda(i) - V(8)./ZCpda(i) + (V(8) - V(5))./ZLd(i);
    Y22(i) = I2;
    Y12(i) = I1;
end

YParams = zeros(2,2,length(f));
YParams(1,1,:) = Y11;
YParams(1,2,:) = Y12;
YParams(2,1,:) = Y21;
YParams(2,2,:) = Y22;

YParams = yparameters(YParams,f);
SParams = sparameters(YParams);
