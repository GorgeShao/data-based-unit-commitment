function [x,t0,t1,t2] = obtainLS(X,Y)
%
tic;
K = size(X,2);
X = [ones(1,K);X];
A = X*X';
B = X*Y';
t0 = toc;

MAX_ROW_A = max(A,[],2);
tic;
if rank(MAX_ROW_A) == max(size(MAX_ROW_A))
MAX_ROW_A = diag(MAX_ROW_A)^-1;
A = MAX_ROW_A*A;
B = MAX_ROW_A*B;
end
t1 = toc;

tic;
x = lsqminnorm(A,B); % 输出系数第一列为常数项
t2 = toc;

end