%%
%生成测试数据
addpath(genpath(pwd));

datadir = 'F:\guojk\matlab\testingdata';
resultdir = 'F:\guojk\matlab\testingOutput\';

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
        
        gettestingdata
        %------------------------------------
    end
end

%%
%PLDA降维
load('PLDA\trainedData');
[bestWcol,~] = find(phi == max(max(phi)));

testX = load(strcat(resultdir ,'testingdata.dat'));
dataSize = length(testX);
testU = invA * (testX(:,1:6)' - m(:,ones(1, dataSize)));
fp = fopen('BayesSeg\bayesinput.txt','w');
for i = 1 : dataSize
    fprintf(fp, '%f\n', testU(bestWcol,i));
end
fclose(fp);