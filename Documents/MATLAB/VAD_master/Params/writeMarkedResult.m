[t_start, t_end, ~] = lbe2data(lbefilename);

[sound, fs, Nbits] = wavread(wavfilename); %可以使用任意采样频率和声道数的.wav文件作为输入
y = sound(:,1);                                       %取单声道
y = y/max(abs(y)); 
L = length(y);                                          %信号总点数
t_total = L / fs;
frame_time_length = .045;
WL = ceil( frame_time_length*fs);                       %窗长度 45ms*fs
FL = ceil( .01*fs);                                     %窗重叠长度/帧长
FN = 1 + floor( (L-WL)/FL);                             %总帧数（每帧一窗）
frame_len = WL;
offset = FL;
res = ones(FN, 1);
for i = 1:FN
    step = (i - 1) * offset + frame_len / 2;
    real_time = step / L * t_total;
    for i1 = 1:length(t_start)
        if t_start(i1) <= real_time & real_time < t_end(i1)
            res(i) = 2;
        end
    end
end

%写文件
csvwrite(strcat(resultdir,'markedres.res'),res)