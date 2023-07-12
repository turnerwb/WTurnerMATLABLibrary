function [s] = z2sCmplx(z,Z0)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
z11 = squeeze(z(1,1,:));
z12 = squeeze(z(1,2,:));
z21 = squeeze(z(2,1,:));
z22 = squeeze(z(2,2,:));
s11 = ((z11-conj(Z0)).*(z22+Z0)-z12.*z21)./((z11+Z0).*(z22+Z0)-z12.*z21);
s22 = ((z11+Z0).*(z22-conj(Z0))-z12.*z21)./((z11+Z0).*(z22+Z0)-z12.*z21);
s12 = 2*z12.*real(Z0)./((z11+Z0).*(z22+Z0)-z12.*z21);
s21 = 2*z21.*real(Z0)./((z11+Z0).*(z22+Z0)-z12.*z21);
s(1,1,:) = s11;
s(1,2,:) = s12;
s(2,1,:) = s21;
s(2,2,:) = s22;
end