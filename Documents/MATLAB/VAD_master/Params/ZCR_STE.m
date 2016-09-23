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
N = WL;

H2 = hamming(N);
[f, t, w] = enframe(y, H2, offset);
len = length(f);

%%perform calculation
crossZero = zeros(len,1);
short_energy = zeros(len,1);

for i = 1 : len
    frame = f(i,:)';
    signs = (frame(2:N).*frame(1:N-1))<0;
    diffs = (frame(2:N)-frame(1:N-1) > 0.02);
    crossZero(i) = sum(signs.*diffs);
    short_energy(i) = 10 * log10(frame' * frame / N);
end

%%
%写文件
csvwrite(strcat(resultdir,'crosszero.txt'),crossZero)
csvwrite(strcat(resultdir,'shortenergy.txt'),short_energy)