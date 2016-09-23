%%
%global parameters

[sound, fs, Nbits] = wavread(wavfilename); %可以使用任意采样频率和声道数的.wav文件作为输入
y = sound(:,1);                                       %取单声道
y = y/max(abs(y)); 
L = length(y);                                          %信号总点数
frame_time_length = .045;
WL = ceil( frame_time_length*fs);                       %窗长度 45ms*fs
FL = ceil( .01*fs);                                     %窗重叠长度/帧长
FN = 1 + floor( (L-WL)/FL);                             %总帧数（每帧一窗）
%%
%local Params
offset = FL;
framelen = WL;
start_delay = 20;
end_ahead = 19;
%%
%data preparation
f1 = melcepst(y,fs,'M',M, 3 * log(fs),framelen, offset)';
len = length(f1);
rec = zeros(length(f1), 1);
rec(1:start_delay) = 0;
rec(len - end_ahead: length(f1)) = 0;

%%
%segmentation
for start = 1:len-K+1
   seg = f1(:,start: start+K-1);
   seg = abs(seg);
   [U,S,V] = svd(seg);
   rec(start + start_delay) = U(1,1);
end
%写文件
csvwrite(strcat(resultdir,'eu09_simplified.txt'),rec);