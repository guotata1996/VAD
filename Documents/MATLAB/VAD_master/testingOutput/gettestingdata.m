a = dir(strcat(resultdir,'*.txt'));
valid_beg = 0;
valid_end = 999999;
dataSize = length(load(a(1).name));
X = zeros(dataSize, length(a));

for i = 1: length(a)
    x = load(a(i).name);
    if strcmp(a(i).name,'crosszero.txt') ~= 1
        for i1 = 1: dataSize
            if x(i1) ~= 0  %去除头上无效的标记，下同
                valid_beg = max(valid_beg,i1);
                break;
            end
        end
        for i1 = 0 : dataSize - 1
            if x(dataSize - i1) ~= 0
                valid_end = min(valid_end,dataSize - i1);
                break;
            end
        end
    end
    X(:,i) = x;
end

filename = strcat(resultdir,'testingdata.dat');
fp = fopen(filename,'w');


for i = 1 : length(X)
    for j = 1 : length(X(1,:)) - 1
        fprintf(fp,'%f, ',X(i,j));
    end
    fprintf(fp,'%f',X(i,length(X(1,:))));
    fprintf(fp,'\r\n');
end
fclose(fp);
