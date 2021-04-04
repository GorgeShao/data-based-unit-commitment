

function t_flow = test_uc_tran(p,UCtype,mpc,casename)

switch UCtype
    case 'DC'
    
    [T,N,NG,NL,Pmax,Pmin,RU,UT,SU,cost_k,cost_b,...
    Pdmax,~,dailyload,Fmax,GP,GD] = loadinfo(mpc);

    DT = UT; % minimum UP/DOWN time

    load_p = Pdmax*dailyload';% Demand Parameters

    reserve_p = sum(load_p,1)'.*0.05; reserve_n = reserve_p; % Reserve Parameters
    
    t_flow = GP*p - GD*load_p;
    
    case 'LS'
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
            m.dir_Xp_LS = f_this;
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
        
        x_inj = Gen2Bus*p - load_p;
        %
        Xpf = Xp(1:NL,:); Xpt = Xp(NL+1:2*NL,:);
        Xpf_c = Xc(1:NL); Xpt_c = Xc(NL+1:2*NL);
        plf = Xpf*x_inj + Xpf_c*ones(1,T);
        plt = Xpt*x_inj + Xpt_c*ones(1,T);
        % 
        ploss = plf + plt;

        t_flow = [plf;plt];

end




end