

%% ��ʼ��
addpath('case','lib','data');
clc; clear;

casename = {'case118m'};
%% ��������
N_case = size(casename,2);
N_type = 4; % LS H DC No-Tran

COST_UC = zeros(N_case,N_type); % LPF-UC�ķ��ý��
SOL_TimeA = zeros(N_case,N_type); % LPF-UC�ķ��ý��
COST_AC = zeros(N_case,N_type); % AC-UC �ķ��ý��
RES_UC = cell(N_case,N_type);   % LPF-UC���
RES_AC = cell(N_case,N_type);   % AC-PF ��ֵ
VOL_AC =  zeros(N_case,N_type); % 6�ַ���ģʽ�£�H DC
maxVOL_AC =  zeros(N_case,N_type); % 6�ַ���ģʽ�£�H DC
avgVOL_AC =  zeros(N_case,N_type);
VOL_maxT = zeros(N_case,N_type); % 6�ַ���ģʽ�£�H DC
%% ʵ�����
for sID = 1
mpc = loadcase(casename{sID});
%% Լ������
Constraints_Set.trn = 1; % Transimission
Constraints_Set.rp = 1;  % Ramping
Constraints_Set.minmax = 0; % minmun up/down
Constraints_Set.verbose_crtl = 1; % ��ӡ���

%% ����UC
% r_ls = TCUC_LS(mpc,casename{sID},Constraints_Set);
r_h = TCUC_H(mpc,casename{sID},Constraints_Set);
% r_dc = TCUC_DC(mpc,Constraints_Set);


% Constraints_Set.trn = 0; % Transimission-off
% r_dc0 = TCUC_DC(mpc,Constraints_Set);

% �洢LPF-UC�ķ��ý��
COST_UC(sID,1) = r_ls.obj;
COST_UC(sID,2) = r_h.obj;
COST_UC(sID,3) = r_dc.obj;
% COST_UC(sID,4) = r_dc0.obj;

% �������ʱ��
SOL_TimeA(sID,1) = r_ls.time;
SOL_TimeA(sID,2) = r_h.time;
SOL_TimeA(sID,3) = r_dc.time;
% ��UC���
RES_UC{sID,1} = r_ls;
RES_UC{sID,2} = r_h;
RES_UC{sID,3} = r_dc;
% RES_UC{sID,4} = r_dc0;

%% �����Ӧ��AC-UC��
ac_ls  = getAC(r_ls,mpc,Constraints_Set.verbose_crtl);
ac_h   = getAC(r_h,mpc,Constraints_Set.verbose_crtl);
ac_dc  = getAC(r_dc,mpc,Constraints_Set.verbose_crtl);
% ac_dc0 = getAC(r_dc0,mpc,Constraints_Set.verbose_crtl);

% �洢AC-UC�ķ��ý��
COST_AC(sID,1) = ac_ls.sum_cost;
COST_AC(sID,2) = ac_h.sum_cost;
COST_AC(sID,3) = ac_dc.sum_cost;
% COST_AC(sID,4) = ac_dc0.sum_cost;

% �洢AC-UC�Ľ��
RES_AC{sID,1} = ac_ls;
RES_AC{sID,2} = ac_h;
RES_AC{sID,3} = ac_dc;
% RES_AC{sID,4} = ac_dc0;

% ����AC����Ƿ�ΥԼ
[VOL_AC(sID,1),maxVOL_AC(sID,1),avgVOL_AC(sID,1),VOL_maxT(sID,1)] = isViolation(mpc,ac_ls);
[VOL_AC(sID,2),maxVOL_AC(sID,2),avgVOL_AC(sID,2),VOL_maxT(sID,2)] = isViolation(mpc,ac_h);
[VOL_AC(sID,3),maxVOL_AC(sID,3),avgVOL_AC(sID,3),VOL_maxT(sID,3)] = isViolation(mpc,ac_dc);
% [VOL_AC(sID,4),maxVOL_AC(sID,4),avgVOL_AC(sID,4),VOL_maxT(sID,4)] = isViolation(mpc,ac_dc0);


end

%% �ͷ�Ŀ¼
% rmpath('case','lib','data');


















