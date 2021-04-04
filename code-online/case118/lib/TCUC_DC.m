%  Conventional TCUC based on DC-PF

function output_SCUC = TCUC_DC(mpc,Constraints_Set,load_factor)
%% Load Parameters

[T,N,NG,NL,Pmax,Pmin,RU,UT,SU,cost_k,cost_b,...
Pdmax,~,dailyload,Fmax,GP,GD] = loadinfo(mpc);

DT = UT; % minimum UP/DOWN time

if nargin == 3 
    load_p = Pdmax*load_factor'; % Demand Parameters
else
    load_p = Pdmax*dailyload';% Demand Parameters
end

reserve_p = sum(load_p,1)'.*0.05; reserve_n = reserve_p; % Reserve Parameters
verbose_crtl = Constraints_Set.verbose_crtl; % Settings ���ƽ�����

%% Programming
% �Ż�����
yalmip('clear');
z = binvar(NG,T,'full');
s = sdpvar(NG,T,'full');
c = sdpvar(NG,T,'full');
p = sdpvar(NG,T,'full');
sum_c = sdpvar(1);

% Ŀ�꺯��
obj = sum_c + sum(sum(s));

% ��ͣ����
ST = ( s >= 0 );
ST = ST + ( s(:,2:T) >= (SU*ones(1,T-1)).*(z(:,2:T)-z(:,1:T-1)) );

% ��������Լ��
% ����Լ��
NP = size(cost_k,2);  
ST = ST + (sum_c >= sum(sum(c)));
for i_seg = 1:NP
    ST = ST + (c >= p.*(cost_k(:,i_seg)*ones(1,T)) + cost_b(:,i_seg)*ones(1,T).*z);
end

% ����ƽ��Լ��
ST = ST + (sum(p,1)-sum(load_p,1)==0);
% ST = ST + (sum(p,1)-1.02*sum(load_p,1)==0); % ����һ���ٷֱ�����

% ��������Լ��
ST = ST + (z.*(Pmin*ones(1,T)) <= p <= z.*(Pmax*ones(1,T)));

% �����߰�ȫԼ��
t_flow = GP*p - GD*load_p;
if Constraints_Set.trn == 1
    ST = ST + (-Fmax*ones(1,T) <= t_flow <= Fmax*ones(1,T));
end

% ����Լ��
if Constraints_Set.rp == 1
    t_ramp_l = -(RU*ones(1,T-1).*z(:,2:T) + Pmin*ones(1,T-1).*(z(:,1:T-1)-z(:,2:T)) + Pmax*ones(1,T-1).*(ones(NG,T-1)-z(:,1:T-1)));
    t_ramp_r = RU*ones(1,T-1).*z(:,1:T-1) + Pmin*ones(1,T-1).*(z(:,2:T)-z(:,1:T-1)) + Pmax*ones(1,T-1).*(ones(NG,T-1)-z(:,2:T));
    ST = ST + (t_ramp_l <= p(:,2:T) - p(:,1:T-1) <= t_ramp_r);
end

%% �Ƿ�������Լ��
if Constraints_Set.minmax == 1
    % ��С���ػ�
    for i=1:NG
        if UT(i)>1
            for tao=2:T-UT(i)+1
                ST=ST+(sum(z(i,tao:(tao+UT(i)-1)))>=UT(i)*(z(i,tao)-z(i,tao-1)));
            end
            for tao=T-UT(i)+2:T
                ST=ST+(sum(z(i,tao:T))-(T-tao+1)*(z(i,tao)-z(i,tao-1)));
            end
        end
        if DT(i)>1
            for tao=2:T-DT(i)+1
                ST=ST+(DT(i)-sum(z(i,tao:(tao+DT(i)-1)))>=DT(i)*(z(i,tao-1)-z(i,tao)));
            end
            for tao=T-DT(i)+2:T
                ST=ST+(-sum(z(i,tao:T))-(T-tao+1)*(-1+z(i,tao)-z(i,tao-1)));
            end
        end
    end
    % ����Լ��
    ST = ST + (sum(z.*(Pmax*ones(1,T)),1) >= sum(load_p,1) + reserve_p');
    ST = ST + (sum(z.*(Pmin*ones(1,T)),1) <= sum(load_p,1) - reserve_n');
    ST = ST + (sum(z.*(RU*ones(1,T)),1) >= reserve_p');
    ST = ST + (sum(z.*(RU*ones(1,T)),1) >= reserve_n');
    t_min = min(2*RU,Pmax-Pmin);
    ST = ST + (sum((z.*(t_min*ones(1,T))),1) >= reserve_p' + reserve_n');
end

%%
opt = sdpsettings; opt.solver = 'gurobi'; opt.verbose = verbose_crtl;
info = optimize(ST,obj,opt);

output_SCUC.info = info;
output_SCUC.z = value(z);
output_SCUC.p = value(p);
output_SCUC.pl = value(t_flow);
output_SCUC.obj = value(obj);
output_SCUC.time = info.solvertime;
output_SCUC.c = value(c);
output_SCUC.s = value(s);
output_SCUC.sum_c= value(sum_c);
end