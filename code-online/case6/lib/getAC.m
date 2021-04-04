function re = getAC(res,mpc,verbose_ctrl,load_factor)


if nargin ~= 4
    load_factor = mpc.dailyload;
end

T = 24; NL = size(mpc.branch,1); NG = size(mpc.gen,1); N = size(mpc.bus,1);
G_bus = mpc.gen(:,1);
V0 = mpc.bus(:,8);
V0(G_bus,1) = mpc.gen(:,6);
PD = mpc.bus(:,3);
QD = mpc.bus(:,4);

re.v = zeros(N,T);
re.a = zeros(N,T);
re.pd = zeros(N,T);
re.qd = zeros(N,T);
re.pg = zeros(NG,T);
re.qg = zeros(NG,T);
re.plf = zeros(NL,T);
re.plt = zeros(NL,T);
re.qlf = zeros(NL,T);
re.qlt = zeros(NL,T);
re.cost_f = zeros(NG,T);


for t = 1:T
    res_mid = get_ACPF(V0,zeros(N,1),res.p(:,t),zeros(NG,1),PD.*load_factor(t),QD.*load_factor(t),mpc,verbose_ctrl);
    re.v(:,t) = res_mid.bus(:,8);
    re.a(:,t) = res_mid.bus(:,9);
    re.pd(:,t) = res_mid.bus(:,3);
    re.qd(:,t) = res_mid.bus(:,4);
    re.pg(:,t) = res_mid.gen(:,2);
    re.qg(:,t) = res_mid.gen(:,3);
    re.plf(:,t) = res_mid.branch(:,14);
    re.plt(:,t) = res_mid.branch(:,16);
    re.qlf(:,t) = res_mid.branch(:,15);
    re.qlt(:,t) = res_mid.branch(:,17);
    re.success(:,t) = res_mid.success;
    if size(mpc.cost_k,2) == 2
        mid1 = re.pg(:,t).*mpc.cost_k(:,1) + mpc.cost_b(:,1).*res.z(:,t);
        mid2 = re.pg(:,t).*mpc.cost_k(:,2) + mpc.cost_b(:,2).*res.z(:,t);
        re.cost_f(:,t) = max(mid1,mid2);
    else
        re.cost_f(:,t) = re.pg(:,t).*mpc.cost_k + mpc.cost_b.*res.z(:,t);
    end
end

re.sum_cost = sum(sum(re.cost_f)) + sum(sum(res.s));






end