a = dir(strcat(resultdir,'*.txt'));
beg_ = 0;
end_ = 999999;
dataSize = length(load(a(1).name));
X = zeros(dataSize, length(a) + 1);

for i = 1: length(a)
    x = load(a(i).name);
    if strcmp(a(i).name,'crosszero.txt') ~= 1
        for i1 = 1: dataSize
            if x(i1) ~= 0  %去除头上无效的标记，下同
                beg_ = max(beg_,i1);
                break;
            end
        end
        for i1 = 0 : dataSize - 1
            if x(dataSize - i1) ~= 0
                end_ = min(end_,dataSize - i1);
                break;
            end
        end
    end
    X(:,i) = x;
end

x = load('markedres.res');
X(:,length(a)+1) = x;

X = X(beg_:end_,:);
%统计不同类别的标记数
class1_cnt = 0;
for i = 1:length(X)
    if X(i,end) == 1
        class1_cnt = class1_cnt + 1;
    end
end
class2_cnt = length(X) - class1_cnt;

validNum = min(class1_cnt, class2_cnt);
validX = zeros(2 * validNum,length(a) + 1);
if class1_cnt > class2_cnt
    %删掉一些标记为1的数据 
    selectedItem = sort(randperm(class1_cnt, class2_cnt));

    validX_cnt = 1;
    for i = 1 : length(X)
        if X(i,end) == 1
            selectedItem = selectedItem - 1;
            if length(selectedItem) ~= 0 & selectedItem(1) == 0
                validX(validX_cnt,:) = X(i,:);
                validX_cnt = validX_cnt + 1;
                selectedItem = selectedItem(2:end);
            end
        else
            validX(validX_cnt,:) = X(i,:);
            validX_cnt = validX_cnt + 1;
        end
    end
else
   %删掉一些标记为2的数据 
    selectedItem = sort(randperm(class2_cnt, class1_cnt));

    validX_cnt = 1;
    for i = 1 : length(X)
        if X(i,end) == 2
            selectedItem = selectedItem - 1;
            if length(selectedItem) ~= 0 & selectedItem(1) == 0
                validX(validX_cnt,:) = X(i,:);
                validX_cnt = validX_cnt + 1;
                selectedItem = selectedItem(2:end);
            end
        else
            validX(validX_cnt,:) = X(i,:);
            validX_cnt = validX_cnt + 1;
        end
    end
end

filename = strcat(resultdir,'trainingdata.dat');
fileExist = dir(filename);
if isempty(fileExist)
    fp = fopen(filename,'w');
else
    fp = fopen(filename,'a');
end

for i = 1 : length(validX)
    for j = 1 : length(validX(1,:)) - 1
        fprintf(fp,'%f, ',validX(i,j));
    end
    fprintf(fp,'%d',validX(i,length(validX(1,:))));
    fprintf(fp,'\r\n');
end
fclose(fp);
