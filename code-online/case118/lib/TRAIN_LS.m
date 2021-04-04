function TRAIN_LS(casename)

% Load Data
DATA = data_load(casename);
%
XP = DATA.P;
YP  = [DATA.PLA;DATA.PLB]; 


%% 

tic;
[Xp,~,~,~] = obtainLS(XP,YP);
t0 = toc;

Xp = Xp';
res.Xp = Xp(:,2:end);
res.c  = Xp(:,1);
res.time = t0;

if ~exist('data\RESULTS_LS','file')
    mkdir('data\RESULTS_LS');
end

save(['data\RESULTS_LS\',casename,'.mat'],'res');
fprintf('TRAIN_LS of %s is COMPLETED. \n',casename)
end
















