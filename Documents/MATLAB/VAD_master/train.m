%%
%生成训练数据
addpath(genpath(pwd));

datadir = 'F:\guojk\matlab\trainingdata';
resultdir = 'F:\guojk\matlab\trainingOutput\';

if datadir(end)~='\' 
    datadir=[datadir,'\']; 
end
DIRS=dir(strcat(datadir,'*.lbe'));
N = length(DIRS);

delete(strcat(resultdir,'trainingdata.dat'));

for k=1:N
    if ~DIRS(k).isdir
        lbefilename = strcat(datadir, DIRS(k).name);
        wavfilename = strrep(lbefilename, '.lbe', '.wav');
        %------------------------------------
        eu09
        LTSD_VAD_ConstThreshold(wavfilename,resultdir);
        eu05
        eu09_simplified
        ZCR_STE
        writeMarkedResult
        
        accumtrainingdata
        %------------------------------------
    end
end

%%
%训练PLDA
ECCV06