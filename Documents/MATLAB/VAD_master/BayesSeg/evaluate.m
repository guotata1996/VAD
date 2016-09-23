%segres = load('segresult.txt');
realres = load('..\testingOutput\markedres.res');

len = length(realres);
specend = 10000;

%做长度截取
%segres = segres(specstart:specend);
realres = realres(1:specend);
len1 = specend;

figure(1);
hold on;
% R矩阵图
% image(exp(partgraph),'CDataMapping','scaled');
% plot(src(1:10000))'


% R矩阵期望图
max_runlen = 3000;
expectation_R = zeros(len1,1);
for i = 1 : len1
    %概率归一化
    ori1 = exp(partgraph(1:min(i,max_runlen),i));
    ori1 = ori1 / sum(ori1);
    for j = 1 : min(i, max_runlen)
        expectation_R(i) = expectation_R(i) + j * ori1(j,1);
    end
    
end
plot(expectation_R,'r');

lastrealcp = 1;
for i = 1 : len1
    if i > 1 && realres(i) ~= realres(i - 1)
        plot([i i], [0 1000], 'g');
        lastrealcp = i;
        text(i,470,num2str(i));
    end
end