function [HR1, HR0] = VAD_Evaluation(lbefilename, SND, frame_time_length, frame_time)
%   VAD_EVALUATION(lbefilename, SND, frame_time_length, frame_time)
%   Intro: Calculate HR1(rate of speech detected as speech), HR0(rate of nonspeech detected as nonspeech)
%   Input
%       lbefilename: format file of labeling
%       SND: algorithm decision of VAD
%       frame_time_length: length of one frame (sec)
%       frame_time: time of the beginning of each frame (sec)
%   Output
%       HR1: speech hit rate
%       HR0: non-speech hit rate
%
%   Last Modified: 2012/3/15
%   Author: 祁芮中台 / Qi Ruizhongtai
%   Contact: charlesq34@gmail.com
%
%   Version: 1.0


[begt,endt,segnum]=lbe2data(lbefilename);

th_time = frame_time_length*1000 * 0.5; %阈值时间：超过帧头时间多少算作进入语音/或结束语音
f_time = frame_time*1000;
FN = length(SND);
lbe_results = zeros(FN, 1);
speaking = 0;
seg = 1;

for fn = 1 : FN
    if speaking == 0
        if begt(seg) < f_time(fn) + th_time
            lbe_results(fn) = 1; 
            speaking = 1;
        else lbe_results(fn) = 0;
        end
    elseif speaking == 1
        if endt(seg) < f_time(fn) + th_time
            lbe_results(fn) = 0;
            speaking = 0;
            seg = seg + 1;
        else lbe_results(fn) = 1;
        end
        if seg>segnum
            break;
        end
    end
end

figure, 
plot(frame_time, lbe_results*0.6,'g', frame_time,SND*0.5, 'r'), 
xlabel('time/sec'); ylabel('VAD'); legend('Labeled-SND','LTSD-SND'); title(strcat('VAD Results --', lbefilename));

HR1 = sum(SND&lbe_results)/sum(lbe_results);
HR0 = sum((1-SND)&(1-lbe_results))/sum(1-lbe_results);

return