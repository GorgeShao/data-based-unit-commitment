function TRAIN_H(casename,PTDF,Data_R)

% Load Data
DATA = data_load(casename);
% 截取数据
K = size(DATA.P,2);
K_this = round(K*Data_R); % 截取的样本数目
random_num = randperm(K,K_this);
random_num = sort(random_num);
%
XP = DATA.P(:,random_num);
YP  = [DATA.PLA(:,random_num);DATA.PLB(:,random_num)] - [PTDF*XP;-PTDF*XP]; 


%% 
tic;
[Xp,~,~,~] = obtainLS(XP,YP);
t0 = toc;
Xp = Xp';

res.Xp = [PTDF;-PTDF] + Xp(:,2:end);
res.c  = Xp(:,1);
res.random_num  = random_num;
res.time = t0;

if ~exist('data\RESULTS_H','file')
    mkdir('data\RESULTS_H');
end

save(['data\RESULTS_H\',casename,'.mat'],'res');
fprintf('TRAIN_H of %s is COMPLETED. \n',casename)
end
















