function ParseMDM(file)
%ReadMDM: Reads all '.mdm' files in the provided directory and saves the
%extracted data to the workspace
%   Reads all '.mdm' files in the provided directory and saves the
%   extracted data to the workspace as matrices
%   VARIABLES:
%   direc - String, file path to folder containing .mdm files to be read

%% Experimental Auto Processing:
%Splitting Files
test = textscan(fileID, 'BEGIN_DB','CollectOutput',1);
%Extract Varable Name/Value Pairs
    str = fileread(FilePath);
    xpr = 'ICCAP_VAR\s*\S*\s*-?\d+';
    Variables= regexp(str, xpr, 'match');
    xpr = '\s\S*\s';
    VarNames = regexp(Variables,xpr,'match');
    xpr = '\s-?\d*';
    VarVals = regexp(Variables,xpr,'match');
    for i = 1:length(VarNames)
        temp = VarNames{i};
        temp = cell2mat(temp);
        VarNames{i} = temp(2:(end-1));
        temp = VarVals{i};
        temp = cell2mat(temp);
        VarVals{i} = str2double(temp(2:(end)));
    end
    %% 
%%
    temp = textscan(fileID,'%f %f %f %f %f %f %f %f %f','HeaderLines',15,'CollectOutput',1);
    fclose(fileID);%...Close File...%
    %...Strip the '.mdm' from the name for MATLAB usability...
    NameNoExtension = erase(Name(1:end),'.mdm');
    assignin('base', NameNoExtension, cell2mat(temp)) %...Rename Variables...
end

