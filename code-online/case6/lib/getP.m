function P = getP(pg,pd,mpc)
[~,N,NG,NL] = loadinfo(mpc);

% Const Parameters 
id_gen = mpc.gen(:,1); id_lineF = mpc.branch(:,1); id_lineT = mpc.branch(:,2);

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

P = Gen2Bus * pg - pd;

end