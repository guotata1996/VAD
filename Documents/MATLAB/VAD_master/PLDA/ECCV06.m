class_count = 2;

%计算类内和类间均值
data = load(strcat(resultdir,'trainingdata.dat'));
N = length(data);
dim = length(data(1,:)) - 1;
means = zeros(class_count,dim);
total_mean = zeros(1,dim);
for i = 1:N
    label = data(i,dim + 1);
    means(label,:) = means(label,:) + data(i,1:dim);
    total_mean = total_mean + data(i,1:dim);
end
means = means' / (N / class_count);
total_mean = total_mean'/ N;
data = data';

%计算S_w和S_b
s_w = zeros(dim,dim);
s_b = zeros(dim,dim);
for i = 1:N
    s_w = s_w + (data(1:dim,i) - means(:,data(dim+1,i))) * (data(1:dim,i) - means(:,data(dim+1,i)))';
    s_b = s_b + (means(:,data(dim+1,i)) - total_mean) * (means(:,data(dim+1,i)) - total_mean)';
end
s_w = s_w ./ N;
s_b = s_b ./ N;

%广义特征值分解求W
%s_b[w1,w2,w3] = s_w * diag() * [w1,w2,w3]
[W,D] = eig(s_b,s_w);
lambda_b = W'*s_b*W;
lambda_w = W'*s_w*W;

%%
%

n = N / class_count;
m = total_mean
A = inv(W)'* real(sqrt(n/(n - 1)*lambda_w))
phi = max((n - 1) / n * diagDiv(lambda_b, lambda_w) - 1 / n, 0)
invA = inv(A)

save trainedData m phi invA



