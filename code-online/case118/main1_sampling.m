% Using DC-PF to obtain the initial value of active power
% Using AC-PF solver to obtain the initial value of active power

%% Pre-Set
clc;clear;warning('off')
addpath('case','lib');

casename = {'case118m1','case118m2','case118m3'};
savename = casename;

NK = 50;

% Data Sampling
for i = 3
    load(casename{i});
    main_sample(mpc,savename{i},NK);
end

rmpath('case','lib');














