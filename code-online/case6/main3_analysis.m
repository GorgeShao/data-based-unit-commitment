

%% ��ʼ��
addpath('case','lib','data');
clc; clear;

casename = {'case6m'};
%% ��������
N_case = size(casename,2);
N_type = 4; % LS H DC No-Tran

COST_UC = zeros(N_case,N_type); % LPF-UC�ķ��ý��
COST_AC = zeros(N_case,N_type); % AC-UC �ķ��ý��
RES_UC = cell(N_case,N_type);   % LPF-UC���
RES_AC = cell(N_case,N_type);   % AC-PF ��ֵ

%% ʵ�����
for caseID = 1
mpc = loadcase(casename{caseID});
%% Լ������
Constraints_Set.trn = 1; % Transimission
Constraints_Set.rp = 1;  % Ramping
Constraints_Set.minmax = 0; % minmun up/down
Constraints_Set.verbose_crtl = 1; % ��ӡ���

%% ����UC
r_ls = TCUC_LS(casename{caseID},Constraints_Set);
r_h = TCUC_H(casename{caseID},Constraints_Set);
r_dc = TCUC_DC(casename{caseID},Constraints_Set);

Constraints_Set.trn = 0; % Transimission-off
r_dc0 = TCUC_DC(casename{caseID},Constraints_Set);

% �洢LPF-UC�ķ��ý��
COST_UC(caseID,1) = r_ls.obj;
COST_UC(caseID,2) = r_h.obj;
COST_UC(caseID,3) = r_dc.obj;
COST_UC(caseID,4) = r_dc0.obj;

% ��UC���
RES_UC{caseID,1} = r_ls;
RES_UC{caseID,2} = r_h;
RES_UC{caseID,3} = r_dc;
RES_UC{caseID,4} = r_dc0;

%% �����Ӧ��AC-UC��
ac_ls  = getAC(r_ls,casename{caseID},Constraints_Set.verbose_crtl);
ac_h   = getAC(r_h,casename{caseID},Constraints_Set.verbose_crtl);
ac_dc  = getAC(r_dc,casename{caseID},Constraints_Set.verbose_crtl);
ac_dc0 = getAC(r_dc0,casename{caseID},Constraints_Set.verbose_crtl);

% �洢AC-UC�ķ��ý��
COST_AC(caseID,1) = ac_ls.sum_cost;
COST_AC(caseID,2) = ac_h.sum_cost;
COST_AC(caseID,3) = ac_dc.sum_cost;
COST_AC(caseID,4) = ac_dc0.sum_cost;

% �洢AC-UC�Ľ��
RES_AC{caseID,1} = ac_ls;
RES_AC{caseID,2} = ac_h;
RES_AC{caseID,3} = ac_dc;
RES_AC{caseID,4} = ac_dc0;

end

%% �ͷ�Ŀ¼
rmpath('case','lib','data');


















