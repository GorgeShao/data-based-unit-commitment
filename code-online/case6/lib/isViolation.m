function [VOL,maxVOL] = isViolation(mpc,ac)
Gap = 0.6;
%% ���鷢�������(��Slack ����)

SLACK_BUS = find(mpc.bus(:,2) == 3);
SLACK_GEN = find(mpc.gen(:,1) == SLACK_BUS);

Pmax = mpc.gen(SLACK_GEN,9);

pg = ac.pg(SLACK_GEN,:);

VL_pg = -(Pmax - pg);
VL_pg(VL_pg<Gap) = 0;

%% ��������Լ��
ramp = pg(:,2:end) - pg(:,1:end-1);
RAMP_MAX = mpc.gen(SLACK_GEN,19);
VL_rp = -(RAMP_MAX - ramp);
VL_rp(VL_rp<Gap) = 0;

%% ���鴫�䰲ȫԼ��

Fmax = mpc.branch(:,6);
VL_tr = -(Fmax - max(abs(ac.plf),abs(ac.plt)));
VL_tr(VL_tr<Gap) = 0;

tt = sum(sum(VL_pg)) + sum(sum(VL_rp)) + sum(sum(VL_tr));

maxVOL = max([max(max(VL_pg)),max(max(VL_rp)),max(max(VL_tr))]);
if tt == 0 
    VOL = 0;
else
    VOL = 1;
end










end



























