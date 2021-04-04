%% 
% 根据的指定负荷修正比例R
% 执行opf采样

function main_sample(mpc,savename,NK)
Constraints_Set.trn = 1; % Transimission
Constraints_Set.rp = 1;  % Ramping
Constraints_Set.minmax = 1; % minmun up/down
Constraints_Set.verbose_crtl = 1; % 打印结果
%% BASIC CASE INFO

PG_INDEX = mpc.gen(:,1);            
NG    = size(mpc.gen,1);  % The total number of generation buses
N = size(mpc.bus,1);
L = size(mpc.branch,1);
T = 24;
K = NK*T;

A_G   = zeros(N,NG);      % Generation incidence matrix 
%##   ##
for j = 1:NG
    A_G(PG_INDEX(j),j) = 1;
end
%##   ##

Sample_adjust_Factor = repmat(mpc.dailyload,NK,1);
rnd_factor = 0.95 + rand(K,1)*0.05;
rnd_factor(1:T) = 1;
Sample_adjust_Factor = Sample_adjust_Factor.*rnd_factor;

%% PARALLEL SAMPLING

%## FOR PARALLEL ##
DATA_P = zeros(N,K); DATA_Q = zeros(N,K); DATA_PLA = zeros(L,K); 
DATA_PLB = zeros(L,K); DATA_QLA = zeros(L,K); DATA_QLB = zeros(L,K);
DATA_V = zeros(N,K); DATA_A = zeros(N,K); DATA_PG = zeros(NG,K);DATA_QG = zeros(NG,K);
%## FOR PARALLEL ##
FAIL_NUM = 0;
ID_FAIL = false(1,K);

for i = 1:NK
%% SAMPLES
F_num = (i-1)*T + 1; T_num = i*T;
mF = Sample_adjust_Factor(F_num:T_num);

r_dc = TCUC_DC(mpc,Constraints_Set,mF);

%% 获得相应的AC-UC解
ac_dc = getAC(r_dc,mpc,Constraints_Set.verbose_crtl,mF);

P = -ac_dc.pd + A_G*ac_dc.pg; % Nodal P injections
Q = -ac_dc.qd + A_G*ac_dc.qg; % Nodal Q injections
%% 
t = 0;
for nk = F_num:T_num
    t = t+1;
    if ac_dc.success(t)
        DATA_P(:,nk) = P(:,t);
        DATA_Q(:,nk) = Q(:,t);
        DATA_PG(:,nk) = ac_dc.pg(:,t);
        DATA_QG(:,nk) = ac_dc.qg(:,t);
        DATA_V(:,nk) = ac_dc.v(:,t);
        DATA_A(:,nk) = ac_dc.a(:,t);
        DATA_PLA(:,nk) = ac_dc.plf(:,t);
        DATA_QLA(:,nk) = ac_dc.qlf(:,t);
        DATA_PLB(:,nk) = ac_dc.plt(:,t);
        DATA_QLB(:,nk) = ac_dc.qlt(:,t);  
    else
        ID_FAIL(k) = true;
        FAIL_NUM = FAIL_NUM + 1 ;
    end
end
end % END for

if FAIL_NUM ~= 0 
    fprintf('%s R = %.1f -- FAILED num = %d ! \n',savename,R,FAIL_NUM);
    DATA_P(:,ID_FAIL)=[];
    DATA_Q(:,ID_FAIL)=[];
    DATA_V(:,ID_FAIL)=[];
    DATA_A(:,ID_FAIL)=[];
    DATA_PLA(:,ID_FAIL)=[];
    DATA_PLB(:,ID_FAIL)=[];
    DATA_QLA(:,ID_FAIL)=[];
    DATA_QLB(:,ID_FAIL)=[];
    DATA_PG(:,ID_FAIL) = [];
    DATA_QG(:,ID_FAIL) = [];
else
    fprintf('%s ALL SUCCESS! \n',savename);
end

DATA.P = DATA_P; clear DATA_P;
DATA.Q = DATA_Q; clear DATA_Q;
DATA.V = DATA_V; clear DATA_V;
DATA.A = DATA_A; clear DATA_A;
DATA.PLA = DATA_PLA; clear DATA_PLA;
DATA.PLB = DATA_PLB; clear DATA_PLB;
DATA.QLA = DATA_QLA; clear DATA_QLA;
DATA.QLB = DATA_QLB; clear DATA_QLB;
DATA.PG = DATA_PG; clear DATA_PG;
DATA.QG = DATA_QG; clear DATA_QG;

file = ['data\TRAIN\',savename];
if ~exist(file,'file')
    mkdir(file);
end

if N >= 1888 
    save([file,'\data.mat'],'DATA','-v7.3');
else
    save([file,'\data.mat'],'DATA');
end

end












