function [fT,fM,Id,Vd,Vg] = IngestAurigaData(SPFilePath,PIVFilePath)
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
        if floor((i-1)/(PIV_PPT)) == PIV_TraceNum(ActiveEntry)
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

%INGEST S-PARAMETERS
[SP, SPNames] = ReadSparams(SPFilePath,false);
temp = cell(MaxPts,1);
tempnames = cell(MaxPts,1);
    ActiveEntry = 1;
for i = 1:MaxPts
    if ~isnan(Id(i))
        temp{i} = SP{ActiveEntry};
        tempnames{i} = SPNames{ActiveEntry};
        ActiveEntry = ActiveEntry + 1;
    else
        temp{i} = "NONE";
        tempnames{i} = "NONE";
    end
end
SP = temp;
%SP = reshape(SP,PIV_PPT,max(PIV_TraceNum)+1);
SPNames = tempnames;

%%PARAMETER CONVERSION
%Memory Preallocation
h = cell(MaxPts,1);
VgVdExt = cell(MaxPts,1);
VgExt = zeros(MaxPts,1);
VdExt = zeros(MaxPts,1);
%Begin reordering code :) i.e. "Regex hell"
%Extract the numeric vals for gate and drain voltages from the file name.
%The opening _ is just a useful seperator, maybe a - any number of digits
%(should be 1 in this voltage range, but it could be higher and, tbh I
%don't really care if it is.) the decimal point (if there) and then any
%number of precision after the decimal point (because Auriga omits trailing
%zeros as a rule). Then it's the text 'Vin_'. We also want to extract the
%Vout string, but since that's at the end of the filename, I don't have to
%be so picky with my regex matches. From there, split the string on the
%Vin, Vout, or underscore. This produces a bunch of empty cells and two
%with the numeric values of Vin and Vout. I've hardcoded the appropriate
%cells for those and save those off
for i=1:MaxPts
    if strcmp(SPNames{i},"NONE")
        VgExt(i) = NaN;
        VdExt(i) = NaN;
    else
        VgVd = regexp(SPNames{i},'_-?\d*\.?\d*Vin_.*Vout','match');
        VgVdExt{i} = regexp(VgVd, '_|Vin|Vout','split');
        VgExt(i) = str2double(VgVdExt{i}{1}{2});
        VdExt(i) = str2double(VgVdExt{i}{1}{4});
    end
end
%Build a table and get the correct index order
VgVdExtTbl = [VgExt, VdExt];
Vg_NoNaN = Vg(~isnan(Vg));
if(Vg_NoNaN(1)>Vg_NoNaN(end))
    [~,idx] = sortrows(VgVdExtTbl,[1,2],{'descend' 'ascend' });
else
    [~,idx] = sortrows(VgVdExtTbl,[1,2]);
end
%We're going to do these to temp variables because of how cells work. I
%hate cells. Why am I using them, because I'm stashing objects :(. While
%I'm at it, I'm going to do the deembedding here because it is the first
%time every S Parameter is iterated over in a loop.
%NB 3/17/25: These FETS Don't have deembedding standards (that we're aware
%of...) Going to comment out the deembedding... The temp variables were
%already commented out............????? Curse whomever wrote this (me) for
%keeping insufficent notes. I'm going to uncomment and see why it's broken
%NB 3/20/25: Should get optional deembedding at some point... TODO
temp1 = cell(MaxPts,1);
temp2 = cell(MaxPts,1);
for i=1:MaxPts
     % temp1{i} = deembed(SD12{idx(i)},SOpen12,SShort12);
     % temp2{i} = deembed(SD21{idx(i)},SOpen12,SShort21);
temp1{i} = SP{idx(i)};
temp2{i} = SPNames{idx(i)};
end
%Reassign and reformat
SP = temp1;
SP = reshape(SP,PIV_PPT,max(PIV_TraceNum)+1);
freqs = NaN;
%End Reordering code
for i=1:MaxPts
    if ~isstring(SP{i})
        h{i} = hparameters(SP{i});
        if isnan(freqs)
            freqs = h{i}.Frequencies;
        end
    else
        h{i} = "NONE";
    end
end

h = reshape(h,PIV_PPT,max(PIV_TraceNum)+1)';


%%Calculate h21, fT
h21 = zeros(PIV_PPT,max(PIV_TraceNum)+1,length(freqs)-1);
temp1 = zeros(length(freqs),1);
temp2= zeros(length(freqs),1);
grad = zeros(PIV_PPT,max(PIV_TraceNum)+1);
int = zeros(PIV_PPT,max(PIV_TraceNum)+1);
fT = zeros(PIV_PPT,max(PIV_TraceNum)+1);
fidx_end=35;
%First freq is outside of SHF Tee HF Passband, drop it.
%NB 3/17/25 Now using Auriga tees, but first point is still funny, dropping
for i=1:PIV_PPT
    for j=1:max(PIV_TraceNum)+1
        if isstring(h{j,i})
            fT(i,j)=NaN;
        else
        temp1(:) = 20*log10(abs(rfparam(h{j,i},2,1)));
        h21(i,j,:) = temp1(2:end);
%        semilogx(freqs(2:fidx_end),squeeze(h21(i,j,1:fidx_end-1)))
        h21_Fits{i,j} = fit(log10(freqs(2:fidx_end)),squeeze(h21(i,j,1:(fidx_end-1))),'poly1','Lower',[-inf,-inf],'Upper',[inf,inf]);
        mh(i,j) = h21_Fits{i,j}.p1;
        bh(i,j) = h21_Fits{i,j}.p2; 
        if (min(h21(i,j,:)) <= 0)
            if(max(h21(i,j,:))>=0)
               [~,index] = min(abs(squeeze(h21(i,j,:))));
               %fT12(i,j) = freqs(index+1)
               fT(i,j) = 10^(-bh(i,j)/mh(i,j));
            else
                fT(i,j) = 0;
            end
        else
            if(abs(mh(i,j) + 20) < 10000)
                fT(i,j) = 10^(-bh(i,j)/mh(i,j));
            else
                fT(i,j) = NaN;
            end
        end
        % temp2(:) = 20*log10(abs(rfparam(h_SD21{j,i},2,1)));
        % h21_21(i,j,:) = temp2(2:end);
        % grad21(i,j) = mean(RelativeGradient(log10(freqs(2:fidx_end)),squeeze(h21_21(i,j,1:(fidx_end-1)))));
        % int(i,j) = mean(squeeze(h21_21(i,j,1:(fidx_end-1))) - grad(i,j) .* log10(freqs(2:fidx_end)));
        end
    end
end
%Y = m*X + b, Y=0 -> X = -b/m. X = log10(Freq) igitur Freq = 10^(-b/m)
fT=fT(~isnan(fT));

%FMax
z = cell(MaxPts,1);
for i=1:MaxPts
    if ~isstring(SP{i})
        z{i} = zparameters(SP{i});
    else
        z{i} = "NONE";
    end
end

%%TODO: VALIDATE THAT FMAX EXTRACTION IS KOSHER :)
z = reshape(z,PIV_PPT,max(PIV_TraceNum)+1);
U = zeros(max(PIV_TraceNum)+1,PIV_PPT,length(freqs));
for i=1:max(PIV_TraceNum)+1
    for j=1:PIV_PPT
        if isstring(z{j,i})
            fM(i,j) = NaN;
        else
            z11 = rfparam(z{j,i},1,1);
            z12 = rfparam(z{j,i},1,2);
            z21 = rfparam(z{j,i},2,1);
            z22 = rfparam(z{j,i},2,2);
            U(i,j,:) = 10*log10((abs(z21-z12).^2) ./ (4*(real(z11).*real(z22) - real(z12).*real(z21))));
            U_Fits{i,j} = fit(log10(freqs(2:fidx_end)),squeeze(real(U(i,j,2:fidx_end))),'poly1','Lower',[-inf,-inf],'Upper',[inf,inf]);
            m(i,j) = U_Fits{i,j}.p1;
            b(i,j) = U_Fits{i,j}.p2;    
            if ( abs(m(i,j) + 20) > 8)
                   fM(i,j) = 0;
            else
                fM(i,j) = 10^(-b(i,j)/m(i,j));
            end
        end
    end
end
fM=fM(~isnan(fM));

if(length(fT)~=length(Vd))
    ActiveEntry = 1;
    fTTemp = zeros(length(Vd),1);
    fMTemp = zeros(length(Vd),1);
    for i=1:length(Vd)
        if ~isnan(Vd(i))
            fTTemp(i) = fT(ActiveEntry);
            fMTemp(i) = fM(ActiveEntry);
            ActiveEntry = ActiveEntry + 1;
        else
            fTTemp(i) = NaN;
            fMTemp(i) = NaN;
        end
    end
    fT = reshape(fTTemp,PIV_PPT,max(PIV_TraceNum)+1)';
    fM = reshape(fMTemp,PIV_PPT,max(PIV_TraceNum)+1)';
else
    fT = reshape(fT,max(PIV_TraceNum)+1,PIV_PPT);
    fM = reshape(fM,max(PIV_TraceNum)+1,PIV_PPT);
end


end
