function res = get_ACPF(V,A,PG,QG,PD,QD,mpc,verbose_ctrl)
% ≥ı ºªØV
mpc.bus(:,8) = V;
mpc.gen(:,6) = V(mpc.gen(:,1));
%
mpc.bus(:,9) = A;
mpc.bus(:,3) = PD;
mpc.bus(:,4) = QD;
%
mpc.gen(:,2) = PG;
mpc.gen(:,3) = QG;
%
mpopt = mpoption('out.all',verbose_ctrl,'verbose',verbose_ctrl);
res = runpf(mpc,mpopt);
end