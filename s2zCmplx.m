function [z] = s2zCmplx(S,Z0)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
denom = ((1-squeeze(S(1,1,:))).*(1-squeeze(S(2,2,:)))-squeeze(S(1,2,:)).*squeeze(S(2,1,:)));
z(1,1,:)=((conj(Z0)+squeeze(S(1,1,:)).*Z0).*(1-squeeze(S(2,2,:)))+squeeze(S(1,2,:)).*squeeze(S(2,1,:)).*Z0)./denom;
z(2,2,:)=((conj(Z0)+squeeze(S(2,2,:)).*Z0).*(1-squeeze(S(1,1,:)))+squeeze(S(1,2,:)).*squeeze(S(2,1,:)).*Z0)./denom;
z(1,2,:)=(2*squeeze(S(1,2,:))).*(real(Z0))./denom;
z(2,1,:)=(2*squeeze(S(2,1,:))).*(real(Z0))./denom;
end