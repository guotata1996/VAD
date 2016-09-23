function [ C ] = diagDiv( A,B )
%DIAGDIV 对角线上C(i,i) = A(i,i) / B(i,i)，其余为0
%   只适合同维度对角阵
C = zeros(length(A));
for i = 1 : length(A)
     C(i,i) = A(i,i) / B(i,i);
end
end

