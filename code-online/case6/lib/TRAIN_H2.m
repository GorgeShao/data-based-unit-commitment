function TRAIN_H2(dataname,PTDF,Data_R)

% Load Data
DATA0 = data_load(dataname{1});
DATA1 = data_load(dataname{2});
DATA2 = data_load(dataname{3});
DATA3 = data_load(dataname{4});
P = [DATA0.P,DATA1.P,DATA2.P,DATA3.P];
PLA = [DATA0.PLA,DATA1.PLA,DATA2.PLA,DATA3.PLA];
PLB = [DATA0.PLB,DATA1.PLB,DATA2.PLB,DATA3.PLB];
% 截取数据
% K = size(P,2);
% K_this = round(K*Data_R); % 截取的样本数目
% random_num = randperm(K,K_this);
% random_num = sort(random_num);
%
% XP = P(:,random_num);
% YP  = [PLA(:,random_num);PLB(:,random_num)] - [PTDF*XP;-PTDF*XP]; 
XP = P;
YP  = [PLA;PLB] - [PTDF*XP;-PTDF*XP]; 


%% 
tic;
[Xp,~,~,~] = obtainLS(XP,YP);
t0 = toc;
Xp = Xp';

res.Xp = [PTDF;-PTDF] + Xp(:,2:end);
res.c  = Xp(:,1);
res.time = t0;

if ~exist('data\RESULTS_H','file')
    mkdir('data\RESULTS_H');
end

save(['data\RESULTS_H\',dataname{4},'.mat'],'res');
fprintf('TRAIN_H of %s is COMPLETED. \n',dataname{4})
end
















