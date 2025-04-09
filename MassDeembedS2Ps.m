function MassDeembedS2Ps(BaseFolder,open,short)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    filelist=dir(fullfile(BaseFolder,'**/*.s2p'));
    status = mkdir(fullfile(BaseFolder,'DeembeddedData'));
    if ~status
        error("Could Not Create Output Folder")
    end
    for i=1:length(filelist)
        tmpfile = fullfile(filelist(i).folder,filelist(i).name);
        tmpdeembed = deembed(tmpfile,open,short);
        rfwrite(tmpdeembed,fullfile(BaseFolder,'DeembeddedData',filelist(i).name));
    end
    disp(strcat('Files Outputted To:',fullfile(BaseFolder,'DeembeddedData')))
end