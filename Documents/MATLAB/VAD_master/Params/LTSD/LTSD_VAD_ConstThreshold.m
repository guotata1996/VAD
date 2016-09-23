%   Long-Term Spectral Deviation VAD 
%   使用注意：前面Inital_FN = 20帧(约250ms)用于噪声参数估计！！
%   Reversion: 1.4  Date:2011/8/11
%   Author: 祁芮中台 / QI Ruizhongtai / Charles Q

%clear all;clc;close all;
function [SND, frame_time_length, frame_time] = LTSD_VAD_ConstThreshold(wavfilename,resultdir)
%------------------------------------------------------------------------------------------------------打开文件
[sound, fs, Nbits] = wavread(wavfilename); %可以使用任意采样频率和声道数的.wav文件作为输入
y = sound(:,1);                                       %取单声道
%ywgn = wgn(length(y),1,-21);                 %生成白噪声
%y = y+0*ywgn;                                     %加白噪声
y = y/max(abs(y));                                  %输入语音归一化
%------------------------------------------------------------------------------------------------------基本参数设置
L = length(y);                                          %信号总点数
frame_time_length = .045;
WL = ceil( frame_time_length*fs);                       %窗长度 45ms*fs
FL = ceil( .01*fs);                                     %窗重叠长度/帧长
FN = 1 + floor( (L-WL)/FL);                             %总帧数（每帧一窗）
N = 9;                                                     %LTSE参数
NK = 6;                                                   %噪声更新参数
alpha = 0.95;                                           %噪声更新参数
N1 = 16; N0 = 16;                                  %decision smoothing 参数
TH_PARAM = 5;                                       %LTSD阈值参数：babble noise和leopard适合 TH_PARAM=5
Initial_FN = 20;                                        %起始的20帧默认为噪声，进行初始化
SND_BEG_N = Initial_FN + 2*N;              %（为了方便定义的）真正语音开始的帧数
%------------------------------------------------------------------------------------------------------变量定义
y_time = [1 : L]/fs;                                           %y_time是原信号下标对应的时间
frame_time = (([1 : FN]' - 1) * FL + 1)/fs;         %frame_time是各帧序号对应的时间（帧开始的时间点）
hw = hamming(WL);                                        %汉明窗
wx = zeros(WL, 1);                                           %wx用来存每帧的语音信号
K = 2^(ceil(log2(WL)));                                     %FFT的点数
cur_wx_fft = zeros(K,1);                                    %过渡变量
wx_fft = zeros(K/2, FN);                                    %每帧的FFT系数1~K/2
fn = 1; k =1;                                                     %fn是帧序号, k 是临时用的计数序号
energy = zeros(FN,1);                                       %归一化短时能量(dB)
LTSE = zeros(K/2, 1);                                         %Long-Term Spectral Envelope
NOISE = LTSE;                                                  %噪声对应的LTSE值
LTSD = zeros(FN, 1);                                         %Long-Term Spectral Deviation
noise_fft = zeros(K/2, FN);                                %噪声的频谱，在非语音区慢慢更新
SND = zeros(FN,1);                                           %最后的Speech/Non-speech Decision
UV = SND;                                                       %自相关波形给出的浊音判决
threshold = zeros(FN,1);                                    %动态LTSD阈值
noise_energy = zeros(FN,1);                               %噪声能量(未用)
%------------------------------------------------------------------------------------------------------分帧计算
for fn = 1:FN
    tmpindex = (fn-1)*FL;
    wx =  y(1+ tmpindex : WL + tmpindex);
    %----------------开始--本帧加窗信号wx(1:WL)的统计参数计算--------
    %--------------------------------------------------------------------
    %nomarlized short-time energy
    energy(fn) = 10*log10( wx' * wx / WL );
    %Compute FFT of the noisy signal with a hamming window
    cur_wx_fft = abs(fft(wx.*hw, K));
    wx_fft(:,fn) = cur_wx_fft(1:K/2);
    %Initialization
    if fn == Initial_FN
        noise_fft(:,fn) = mean( wx_fft(:,1:fn), 2 ); %时域平均
        noise_fft_std = std( wx_fft(:,1:fn), 0, 2 ); %噪声各频段的标准差
        NOISE = noise_fft(:, fn);
        noise_energy(fn)= mean(energy(1:Initial_FN)); %energy in dB（always<0）  <-40dB very clean speech, >-20dB very noisy speech
        %TH_PARAM = 3;
        threshold(fn) = 10*log10( mean( ((NOISE+TH_PARAM*noise_fft_std).^2) ./ (NOISE.*NOISE) ) );
        THRESHOLD = threshold(fn);
    end
    %Initialization Completed
    %CURRENT decision frame index = fn-N !!
    if fn>SND_BEG_N %SDN_BEG_N = Initial_FN + 2*N;
        snd_fn = fn-N;
    end
    %Compute LTSE(k,fn)
    if fn>SND_BEG_N && fn>2*N && fn<=FN-N
        LTSE = max( wx_fft(:, snd_fn-N:snd_fn+N), [], 2 ); 
    end
    %Compute LTSD(fn)
    if fn>SND_BEG_N
        LTSD(fn) = 10*log10( mean( (LTSE.*LTSE) ./ (NOISE.*NOISE) ) );
    end
    %Decision rule
    if fn>SND_BEG_N && fn>2*N && LTSD(snd_fn) > THRESHOLD
        SND(snd_fn) = 1;
    end
    %Noise updating
    if fn>Initial_FN
        noise_fft(:,fn) = noise_fft(:,fn-1);
        threshold(fn) = threshold(fn-1);
        noise_energy(fn) = noise_energy(fn-1);
    end
    if fn>SND_BEG_N
        if  any( SND(snd_fn-NK:snd_fn) ) == 0 %确认当前及之前帧是non-speech 
            noise_fft_snd_fn = mean( noise_fft(:,snd_fn-NK:snd_fn), 2 );
            noise_fft(:,snd_fn) = alpha*noise_fft(:,snd_fn-1) + (1-alpha)*noise_fft_snd_fn;
            NOISE = noise_fft(:,snd_fn);
        end
    end

    
    %自相关->U/V判决 ：原理是语音的自相关函数波形不同于非babble噪声的自相关函数波形。仅对浊音可行！
    ds_wx = resample(wx, 2000, fs);%down-sampling to 2000Hz
    WL2 = length(ds_wx); RR = ds_wx' * ds_wx;
    for m = 1 : 40
        R(m) = ds_wx(1:WL2-m)' * ds_wx(m+1:WL2) / RR;
    end
    if ( max(R(7:40)) > 0.5 && min(R(1:10)) < 0 ) %这样写会出现连续的误判！|| ( fn>1 && UV(fn-1) && energy(fn)>0.12 ) %Decision Rule！！
        UV(fn) = 1;
    end
    
    %防止频谱突然变化的非响度噪声造成误判
    if fn>SND_BEG_N+3
        if SND(snd_fn-1)==0 && SND(snd_fn) == 1
            if sum(SND(snd_fn-N0:snd_fn-2))==0 && sum( UV(snd_fn-1:snd_fn+N) ) <2 %宁拖尾，不漏音
                SND(snd_fn) = 0;
            end
            if energy(snd_fn) < mean(noise_energy(snd_fn-2:snd_fn)) + 3 %3dB能量条件
                SND(snd_fn) = 0;
            end
        end
    end
    %decision smoothing
    %N1 = 16; N0 = 16;
    if fn>SND_BEG_N+20
        if SND(snd_fn-N1)==0 && SND(snd_fn) == 0 && any(SND(snd_fn-N1+1:snd_fn-1))
            SND(snd_fn-N1+1:snd_fn-1) = zeros(N1-1,1);
        end
        if SND(snd_fn-N0)==1 && SND(snd_fn) == 1 && sum(SND(snd_fn-N0+1:snd_fn-1)) < N0-1
            SND(snd_fn-N0+1:snd_fn-1) = ones(N0-1,1);
        end
    end
    %------------------------------------------------------------------------
    %--------------------结束--本帧加窗信号参数计算------------------------
end
%写文件
csvwrite(strcat(resultdir,'LTSD.txt'), LTSD);

return
