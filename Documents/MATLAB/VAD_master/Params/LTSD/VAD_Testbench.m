%   Intro: Calculate HR1(rate of speech detected as speech), HR0(rate of nonspeech detected as nonspeech)
%   Input
%       LTSD_VAD_ConstThreshold: VAD_Algorithm as a function
%       mydir: directory of the .wav and .lbe files
%   Output
%       ROC of tested data
%   Last Modified: 2012/3/15
%   Author: ∆Ó‹«÷–Ã® / Qi Ruizhongtai
%   Contact: charlesq34@gmail.com
%
%   Version: 1.0
clc;clear all;close all;

mydir = 'C:\Users\guotata\Documents\MATLAB\Params\LTSD\manual_label_results';
if mydir(end)~='\' 
    mydir=[mydir,'\']; 
end
DIRS=dir([mydir,'noisy_volvo_15dB.lbe']);
N = length(DIRS);

for k=1:N
    if ~DIRS(k).isdir
        lbefilename = strcat(mydir, DIRS(k).name);
        wavfilename = strrep(lbefilename, '.lbe', '.wav');
        %------------------------------------
        [SND, frame_time_length, frame_time] = LTSD_VAD_ConstThreshold(wavfilename);
        [HR1(k), HR0(k)] = VAD_Evaluation(lbefilename, SND, frame_time_length, frame_time);
        %------------------------------------
    end
end

FAR0 = 1-HR1;
figure, grid on, plot(FAR0, HR0, 's'); axis([0 1 0 1]); 
xlabel('speech detected as non-speech: FAR0'); ylabel('non-speech correctly detected: HR0'); title('Receiver Operating Curve (ROC)'); 
