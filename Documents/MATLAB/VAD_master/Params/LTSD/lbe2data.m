function [begt, endt, segnum] = lbe2data(filename)
%   LBE2DATA(filename)
%   Info
%       使用MATLAB读取手工标注文件*.lbe中的时间点数据
%   Input
%       filename: name of standard *.lbe file
%   Output
%       begt: begins of speech segments in ms
%       endt: ends of speech segments in ms
%       segnum: num of speech segments
%   Author: 祁芮中台 / Qi Ruizhongtai
%   Version: 1.0
%   Last Modified: 2012/3/15

fidin=fopen(filename,'rt');
tline=fgetl(fidin);
m=regexp(tline,'\d+','match');%用正则表达式读取里面的数字字符
segN = str2double(cell2mat(m(1))); 
k = 1;
while ~feof(fidin) && k<=segN
    tline=fgetl(fidin);
    m=regexp(tline,'\d+','match');
    begt(k) = str2double(cell2mat(m(1)))*60 + str2double(cell2mat(m(2))) + str2double(cell2mat(m(3)))*0.001; %以秒为单位
    endt(k) = str2double(cell2mat(m(4)))*60 + str2double(cell2mat(m(5))) + str2double(cell2mat(m(6)))*0.001;
    k = k+1;
end
segnum = k-1;
fclose(fidin);