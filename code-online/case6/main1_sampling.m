% Using DC-PF to obtain the initial value of active power
% Using AC-PF solver to obtain the initial value of active power

%% Pre-Set
clc;clear;warning('off')
addpath('case','lib');

casename = 'case6m';
savename = {'case6m_GP3','case6m_GP4','case6m_GP5'};
NK = 3;
G_P = [3 4 5];
% Data Sampling
for i = 1:3
    mpc = loadcase(casename);
    mpc.cost_k = [mpc.cost_k;0.8*mpc.cost_k(1)];
    mpc.cost_b = [mpc.cost_b;0.8*mpc.cost_b(1)];
    mpc.gen = [mpc.gen;mpc.gen(3,:)];
    mpc.gen(4,1) = G_P(i);
    mpc.gencost = [mpc.gencost;mpc.gencost(3,:)];
    main_sample(mpc,savename{i},NK);
end

rmpath('case','lib');














