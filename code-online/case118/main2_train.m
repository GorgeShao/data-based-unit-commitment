
clc;clear
addpath('case','data','lib');
%% Basic

dataname = {'case118m2','case118m3'};     
Data_R = 0.5; % =0.5��ʾ���ģʽ��ʹ��һ������

for i = 1
    TRAIN_H2(dataname,makePTDF(loadcase(dataname{1})),Data_R);
end

rmpath('case','data','lib');



















