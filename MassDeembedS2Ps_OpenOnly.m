function MassDeembedS2Ps_OpenOnly(BaseFolder,open)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    filelist=dir(fullfile(BaseFolder,'**/*.s2p'));
    status = mkdir(fullfile(BaseFolder,'DeembeddedData'));
    if ~status
        error("Could Not Create Output Folder")
    end
    for i=1:length(filelist)
        tmpfile = fullfile(filelist(i).folder,filelist(i).name);
        tmpdeembed = deembed_Open(tmpfile,open);
        if(isnan(tmpdeembed.Parameters(1,1,1)))
            str = fprintf("Data is NaN after deembedding for %s \n" + ...
                "Outputting placeholder file of perfect open\n",tmpfile);
            tmpdeembed = sparameters(ones(size(open.Parameters)),open.Frequencies);
        end
        rfwrite(tmpdeembed,fullfile(BaseFolder,'DeembeddedData',filelist(i).name));
    end
    disp(strcat('Files Outputted To:',fullfile(BaseFolder,'DeembeddedData')))
end