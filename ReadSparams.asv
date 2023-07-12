function [OutputArray, FileNames] = ReadSparams(direc,ToWorkspace)
%ReadMDM: Reads all '.s2p' files in the provided directory and saves the
%extracted data to the workspace
%   Reads all '.s2p' files in the provided directory and saves the
%   extracted data to the workspace as matrices
%   VARIABLES:
%   direc - String, file path to folder containing .mdm files to be read
files = dir(fullfile(direc,"*.s2p")); %Extract s2p Files
if ~ToWorkspace
    OutputArray = cell(length(files),1);
    FileNames = cell(length(files),1);
end
for k=1:length(files) %For Every File in the Folder...
    Name = files(k).name;%...Get the name...
    FilePath = fullfile(direc, Name);%...Pull the File Path...
    temp = sparameters(FilePath);
    %...Strip the '.mdm' from the name for MATLAB usability...
    if ToWorkspace
        NameNoExtension = erase(Name(1:end),'.s2p');
        NameNoExtension = regexprep(NameNoExtension,'\.','p');
        NameNoExtension = regexprep(NameNoExtension,'-','m');
        NameNoExtension = regexprep(NameNoExtension,'PIV_SHF_SParams_0VoutQ_','');
        NameNoExtension = regexprep(NameNoExtension,'4847','Die4847');
        assignin('base', NameNoExtension, temp) %...Rename Variables...
    else
        OutputArray{k} = temp;
        FileNames{k} = FilePath;
    end
end

