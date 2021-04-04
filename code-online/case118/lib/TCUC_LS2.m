% 编写data based LPF TCUC
% 包含冗余约束识别
function ot_SCUC = TCUC_LS2(mpc,casename,Constraints_Set)
%% Load Parameters
[T,N,NG,NL,Pmax,Pmin,RU,UT,SU,cost_k,cost_b,...
Pdmax,Qdmax,dailyload,Fmax,~,~] = loadinfo(mpc);

DT = UT; % minimum UP/DOWN time
Daily_Load = dailyload(:,1); load_p = Pdmax*Daily_Load'; % Demand Parameters
reserve_p = sum(load_p,1)'.*0.05; reserve_n = reserve_p; % Reserve Parameters

% Const Parameters 
id_gen = mpc.gen(:,1); id_lineF = mpc.branch(:,1); id_lineT = mpc.branch(:,2);
% LPF #######################
m = matfile('fname','Writable',true);
f_this = m.dir_Xp_LS;
try
    load([f_this,'\',casename,'.mat']);
catch
    disp('LS-LPF! Please import the dir');
    f_this = uigetdir();
    load([f_this,'\',casename,'.mat']);
    m.dir_Xp_H = f_this;
end

Xp = res.Xp;
Xc = res.c;
% ##############################

% 生成关联矩阵
Gen2Bus = zeros(N,NG); 
for i = 1:NG
    Gen2Bus(id_gen(i),i) = 1;
end
Line2bus = zeros(N,2*NL);
for i = 1:NL
    Line2bus(id_lineF(i),i) = 1;
    Line2bus(id_lineT(i),i+NL) = 1;
end
% Settings
verbose_crtl = Constraints_Set.verbose_crtl; % 控制结果输出

%% 
% 优化变量
yalmip('clear');
z = binvar(NG,T,'full');
s = sdpvar(NG,T,'full');
c = sdpvar(NG,T,'full');
p = sdpvar(NG,T,'full');
sum_c = sdpvar(1);

% 目标函数
obj = sum(sum(s)) + sum_c;
% 启停费用
st = ( s >= 0 );
st = st + ( s(:,2:T) >= (SU*ones(1,T-1)).*(z(:,2:T)-z(:,1:T-1)) );
% 费用约束
st = st + (sum_c >= sum(sum(c)));
NP = size(cost_k,2);  
for i_seg = 1:NP
    st = st + (c >= p.*(cost_k(:,i_seg)*ones(1,T)) + cost_b(:,i_seg)*ones(1,T).*z);
end
% 负荷平衡约束
%% 约束
x_inj = Gen2Bus*p - load_p;
%
Xpf = Xp(1:NL,:); Xpt = Xp(NL+1:2*NL,:);
Xpf_c = Xc(1:NL); Xpt_c = Xc(NL+1:2*NL);
plf = Xpf*x_inj + Xpf_c*ones(1,T);
plt = Xpt*x_inj + Xpt_c*ones(1,T);
% 
ploss = plf + plt;
st = st + ( ploss >= -1e-4);

st = st + ( sum(p,1) - sum(load_p,1) - sum(ploss,1) == 0 );
% 发电能力约束
st = st + (z.*(Pmin*ones(1,T)) <= p <= z.*(Pmax*ones(1,T)));

% 传输线安全约束
load('id_a_ls');
if Constraints_Set.trn == 1
    for i = 1:size(ida,1)
        if ida(i,2) == 1
            st = st + ( plf(ida(i,1),:) <= Fmax(ida(i,1),:)*ones(1,T) );
        end
        if ida(i,2) == 2
            st = st + ( plt(ida(i,1),:) <= Fmax(ida(i,1),:)*ones(1,T) );
        end
        if ida(i,2) == 3
            st = st + ( -Fmax(ida(i,1),:)*ones(1,T) <= plf(ida(i,1),:) );
        end
        if ida(i,2) == 4
            st = st + ( -Fmax(ida(i,1),:)*ones(1,T) <= plt(ida(i,1),:) );
        end
    end
end



% 爬坡约束
if Constraints_Set.rp == 1
    t_ramp_l = -(RU*ones(1,T-1).*z(:,2:T) + Pmin*ones(1,T-1).*(z(:,1:T-1)-z(:,2:T)) + Pmax*ones(1,T-1).*(ones(NG,T-1)-z(:,1:T-1)));
    t_ramp_r = RU*ones(1,T-1).*z(:,1:T-1) + Pmin*ones(1,T-1).*(z(:,2:T)-z(:,1:T-1)) + Pmax*ones(1,T-1).*(ones(NG,T-1)-z(:,2:T));
    st = st + (t_ramp_l <= p(:,2:T) - p(:,1:T-1) <= t_ramp_r);
end

%% 是否添加相关约束
if Constraints_Set.minmax == 1
    % 最小开关机
    for i=1:NG
        if UT(i)>1
            for tao=2:T-UT(i)+1
                st=st+(sum(z(i,tao:(tao+UT(i)-1)))>=UT(i)*(z(i,tao)-z(i,tao-1)));
            end
            for tao=T-UT(i)+2:T
                st=st+(sum(z(i,tao:T))-(T-tao+1)*(z(i,tao)-z(i,tao-1)));
            end
        end
        if DT(i)>1
            for tao=2:T-DT(i)+1
                st=st+(DT(i)-sum(z(i,tao:(tao+DT(i)-1)))>=DT(i)*(z(i,tao-1)-z(i,tao)));
            end
            for tao=T-DT(i)+2:T
                st=st+(-sum(z(i,tao:T))-(T-tao+1)*(-1+z(i,tao)-z(i,tao-1)));
            end
        end
    end
    % 备用约束
    st = st + (sum(z.*(Pmax*ones(1,T)),1) >= sum(load_p,1) + reserve_p');
    st = st + (sum(z.*(Pmin*ones(1,T)),1) <= sum(load_p,1) - reserve_n');
    st = st + (sum(z.*(RU*ones(1,T)),1) >= reserve_p');
    st = st + (sum(z.*(RU*ones(1,T)),1) >= reserve_n');
    t_min = min(2*RU,Pmax-Pmin);
    st = st + (sum((z.*(t_min*ones(1,T))),1) >= reserve_p' + reserve_n');
end

%%
opt = sdpsettings; opt.solver = 'gurobi'; opt.verbose = verbose_crtl;
info = optimize(st,obj,opt);

ot_SCUC.info = info;
ot_SCUC.z = value(z);
ot_SCUC.p = value(p);
ot_SCUC.plf = value(plf);
ot_SCUC.plt = value(plt);
ot_SCUC.obj = value(obj);
ot_SCUC.c = value(c);
ot_SCUC.s = value(s);
ot_SCUC.sum_c= value(sum_c);
ot_SCUC.time = info.solvertime;


end