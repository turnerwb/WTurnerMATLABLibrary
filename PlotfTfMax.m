function PlotfTfMax(Vd,Vg,Id,d,fT,fM,CurvesfT,CurvesfMax)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

if nargin < 5
    error("Not Enough Imput Arguments")
elseif nargin < 8
    if nargin == 5
        fM = NaN;
        CurvesfMax = 0;
    else
        CurvesfMax = 10;
    end
    if nargin <7
        CurvesfT = 10;
    end
end

Vd(isnan(Vd)) = 0;
Vg(isnan(Vg)) = 0;
Id(isnan(Id)) = 0;
fT(isnan(fT)) = 0;
fM(isnan(fM)) = 0;

figure
VdMin = round(min(Vd));
VdMax = round(max(Vd));
NP_Drain = length(Vd);
VgMin = round(min(Vg));
VgMax = round(max(Vg));
NP_Gate = length(Vg);
VgPerf = linspace(VgMin,VgMax,NP_Gate);
VdPerf = linspace(VdMin,VdMax,NP_Drain);
VdCont = repmat(VdPerf', NP_Gate);
VdCont = VdCont(:,1);
VgCont = zeros(NP_Gate*NP_Drain,1);
for i = 1:NP_Gate
    for j = 1:NP_Drain
        VgCont(j + (i-1)*NP_Drain) = VgPerf(i);
    end
end
VdPlot = reshape(VdCont, NP_Drain, NP_Gate)';
VgPlot = reshape(VgCont, NP_Gate, NP_Drain);

IdInt = scatteredInterpolant(Vd,Vg,Id,'linear','none');

IdPlot = IdInt(VdCont,VgCont);
fTInt = scatteredInterpolant(Vd,Vg,reshape(fT',[],1),'linear','none');
fTEval = fTInt(VdCont,VgCont);
fTPlot = reshape(fTEval,NP_Drain,NP_Gate)';
IdPlot = reshape(IdPlot,NP_Drain,NP_Gate).*1000./d;
IdPlot = IdPlot';

contourf(VdPlot,IdPlot,fTPlot./1e9,CurvesfT,'ShowText','on')
title("f_T Contours","FontSize",20)
xlabel("V_d (V)", "FontSize",20)
ylabel("I_d (mA/mm)","FontSize",20)
cb = colorbar;
cb.Label.String = 'f_T (GHz)';
cb.FontSize = 16;
cb.Limits = [0 max(CurvesfT)];
ax = gca;
ax.FontSize=16;
if length(fM) ~= 1
    figure
    fM12Int = scatteredInterpolant(Vd,Vg,reshape(fM',[],1),'linear','none');
    fMEval = fM12Int(VdCont,VgCont);
    fMPlot = reshape(fMEval,NP_Drain,NP_Gate)';
    
    contourf(VdPlot,IdPlot,fMPlot./1e9,CurvesfMax,'ShowText','on')
    title("f_{Max} Contours","FontSize",20)
    xlabel("V_d (V)", "FontSize",20)
    ylabel("I_d (mA/mm)","FontSize",20)
    cb = colorbar;
    cb.Label.String = 'f_{Max} (GHz)';
    cb.FontSize = 16;
    cb.Limits = [0 max(CurvesfMax)];
    
    ax = gca;
    ax.FontSize=16;
end
end