function [Id,Vd,Vg] = IngestAurigaDataDCOnly(PIVFilePath)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

%INGEST PIV DATA
PIV = readmatrix(...
    PIVFilePath,...
    'NumHeaderLines',119);

PIV_PPT = max(PIV(:,3)); %Should be a constant
PIV_TraceNum = PIV(:,2);
PIV_ID = PIV(:,7);
PIV_Vd = PIV(:,6);
PIV_Vg = PIV(:,10);

MaxPts = (PIV_PPT)*(max(PIV_TraceNum)+1);

%NORMALIZE MATRIX SIZE (IN CASE OF COMPLIANCE LIMITS)
Id = zeros(MaxPts,1);
Vd = zeros(MaxPts,1);
Vg = zeros(MaxPts,1);
if MaxPts ~= length(PIV_ID)
    ActiveEntry = 1;
    for i = 1:MaxPts
        if ActiveEntry>length(PIV_TraceNum)
            Id(i) = NaN;
            Vd(i) = NaN;
            Vg(i) = NaN;
        elseif floor((i-1)/(PIV_PPT)) == PIV_TraceNum(ActiveEntry)
            Id(i) = PIV_ID(ActiveEntry);
            Vd(i) = PIV_Vd(ActiveEntry);
            Vg(i) = PIV_Vg(ActiveEntry);
            ActiveEntry = ActiveEntry + 1;
        else
            Id(i) = NaN;
            Vd(i) = NaN;
            Vg(i) = NaN;
        end
    end
else
    Id = PIV_ID;
    Vd = PIV_Vd;
    Vg = PIV_Vg;
end


end
