
clc;clear
addpath('case','data','lib');
%% Basic

dataname = {'case6m','case6m_GP3','case6m_GP4','case6m_GP5'};     
Data_R = 0.5; % =0.5��ʾ���ģʽ��ʹ��һ������

for i = 1
    TRAIN_H2(dataname,makePTDF(loadcase(dataname{1})),Data_R);
end

rmpath('case','data','lib');



















