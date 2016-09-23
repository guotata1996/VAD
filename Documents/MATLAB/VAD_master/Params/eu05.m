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
%local params
B = 128;
T1 = 88;
T2 = 49;

offset = FL;
framelen = WL;
start_delay = T1 + 2;
end_ahead = T2 + 1;

H = hamming(framelen);
[f, t, w] = enframe(y, H, offset);
len = length(f);
f1 = zeros(len, B);
for frame = 1 : len
    f1(frame,:) = abs(fft(f(frame,:),B));
end

%%
%apply smoothing
Y = zeros(len,B);
S = 1/35*[1 1 1 1 1; 1 2 2 2 2; 1 2 3 2 1; 1 2 2 2 1; 1 1 1 1 1];
for frame = 3 : len - 2
   for bin = 3 : B - 2 
       for delta_frame = -2 : 2
           for delta_bin = -2: 2
               Y(frame, bin) = Y(frame, bin) + f1(frame + delta_frame, bin + delta_bin) * S(3 + delta_frame, 3 + delta_bin);
           end
       end
   end
end

%%
%noise subtraction
Y_NoiseSuppressed = zeros(len,1);
for frame = 1 + T1 : len - T2
    for band  = 3 : B - 2
         estimatedNoise = min(Y(frame - T1:frame + T2, band));
         Y_NoiseSuppressed(frame, band) = Y(frame, band) / estimatedNoise;
    end
end

%%
%entrophy calculation
entrophy = zeros(len, 1);
for frame = 1 + T1: len - T2
    sum_for_frame = 0;
    for band = 3:B-2
        sum_for_frame = sum_for_frame + abs(Y_NoiseSuppressed(frame,band))^2;
    end
    for band = 3:B-2
        P = abs(Y_NoiseSuppressed(frame,band))^2 / sum_for_frame;
        entrophy(frame) = entrophy(frame) - P * log2(P);
    end
end

%%
%写文件
entrophy(1:start_delay) = 0;
entrophy(len - end_ahead:len) = 0;
csvwrite(strcat(resultdir,'e05.txt'),entrophy)