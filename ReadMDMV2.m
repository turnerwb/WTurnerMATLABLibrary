function [data,ColHeaderMtx, VarValues, VarNames, Headers] = ReadMDMV2(FilePath)
%ReadMDMV2: Reads the '.mdm' file specified in FilePath and exports the
%data and relevent metadata
%   Reads all '.mdm' files in the provided directory and outputs the
%   extracted data and metadata
%   INPUTS:
%   FilePath - String, file path to SINGLE* .mdm file
%   *Change from V1
%   OUTPUTS:
%   data: 3D Matrix containing measured data from '.mdm' file located at
%   FilePath. Each different IC-CAP parameter set is stored along the third
%   dimension. Variables are stored as columns.
%   ColHeaderMtx: String Matrix. Contains the variable names collected for a set of IC-CAP
%   parameters. Each IC-CAP parameters set is stored in a new row
%   VarValues: Numeric Matrix. Numeric values for the IC-CAP parameters.
%   New Parameter sets are stored in new rows.
%   VarNames: Cell Array of IC-CAP parameter names.
%   Headers: Header data from the file

% NOTE: To get list of all mdm files in folder: files = dir(fullfile("direc","*.mdm"));
% NOTE: This may break with files generated on Macs. I have it set up for
% for Linux/Windows created files (LF and CRLF EOL Char). For Macs (CR EOL Character)
% see applicable comment

str = fileread(FilePath);
xpr = 'BEGIN_DB';
file = regexp(str,xpr,"split");
Headers = file{1};
xpr = 'ICCAP_VAR\s*\S*\s*-?\d+\.?\d*';
RawVars= regexp(str, xpr, 'match');
    for j = 1:length(RawVars)
        VarNamesTemp = regexp(RawVars{j},'ICCAP_VAR\s*','split');
        VarNamesTemp = regexp(VarNamesTemp{2},'\D*','match');
        VarNamesTemp = regexp(VarNamesTemp{1},'\S*','match');
        VarNamesAll{j} = cell2mat(VarNamesTemp);
    end
for i=1:length(file)-1
    RawVars= regexp(file{i+1}, xpr, 'match');
    for j = 1:length(RawVars)
        VarValuesTemp = regexp(RawVars{j},'ICCAP_VAR\s*\S*\s*','split');
        VarValuesTemp = VarValuesTemp{2};
        VarValues(i,j) = str2double(regexp(VarValuesTemp,'-?\d+\.?\d*','match'));
    end
    DataTemp = regexp(file{i+1},append(xpr,'\n*'),'split');
    DataTemp = DataTemp{end};
    SingleLines = regexp(DataTemp,'\n','split');
    NumEntries = length(regexp(SingleLines{4},'\s*','split'))-2;
    formatstr = '%f';
    formatstr_Header = '%s';
    for j=1:NumEntries-1
        formatstr = append(formatstr,' %f');
        formatstr_Header = append(formatstr_Header, ' %s');
    end
    %FOR FILES CREATED ON A MAC: You may need to change '\r?\n\r?\n' to'\r\r'
    %Don't c'ha love line ending standards :) This works for Linux
    %(LF)/Windows (CRLF)
    DataTemp = regexp(DataTemp, '\r?\n\r?\n','split');
    DataTemp = DataTemp{2};
    ColHeaders = regexp(DataTemp, '\n','split');
    ColHeaders = regexp(ColHeaders{1}, '\s*','split');
    for count=2:length(ColHeaders)-1
        ColHeaderMtx(i,count-1) = string(ColHeaders{count});
    end
    temp = textscan(DataTemp,formatstr,'HeaderLines',1,'CollectOutput',1);
    try
        data(:,:,i) = temp{1};
    catch ME
        switch ME.identifier
            case 'MATLAB:subsassigndimmismatch'
                warning('Data of inconsistent size!')
            otherwise
                rethrow(ME)
        end
    end
end
NumVars = size(VarValues,2);
for i =1:NumVars
    VarNames{i} = VarNamesAll{i};
end
end
