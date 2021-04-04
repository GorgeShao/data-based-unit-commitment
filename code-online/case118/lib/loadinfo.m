function [T,N,NG,NL,Pmax,Pmin,Ramp,UpTime,Start_Cost,Cost_k,Cost_b,...
          Pdmax,Qdmax,dailyload,FlowMax,gammaG,gammaD] = loadinfo(mpc)

% Const Parameters
T = 24; 
NG = size(mpc.gen,1); 
NL = size(mpc.branch,1);
N  = size(mpc.bus,1);
% Generation Parameters
Pmax = mpc.gen(:,9); 
Pmin = mpc.gen(:,10);
Ramp = mpc.gen(:,19); % 爬坡速率
UpTime = mpc.gen(:,20);
% Cost Parameters
Start_Cost = mpc.gencost(:,2); % 启动费用
Cost_k = mpc.cost_k; Cost_b = mpc.cost_b; % 费用函数分段线性系数
% Load Parameters
Pdmax = mpc.bus(:,3);
Qdmax = mpc.bus(:,4);
dailyload = mpc.dailyload;
% Tansmission Parameters
FlowMax = mpc.branch(:,6);
id_load = mpc.bus(:,1); id_gen = mpc.gen(:,1);
gamma = makePTDF(mpc); 
gammaD = gamma(:,id_load); gammaG = gamma(:,id_gen);

end















