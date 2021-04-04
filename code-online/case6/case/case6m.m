function mpc = case6m()
% CASE6 From FU et al.: SECURITY-CONSTRAINED UNIT COMMITMENT WITH AC CONSTRAINTS
% mpc.branch(:,19) is ramping rate
% mpc.branch(:,20) is minimum up/down time

%% MATPOWER Case Format : Version 2
mpc.version = '2';

%%-----  Power Flow Data  -----%%
%% system MVA base
mpc.baseMVA = 100;

%% Daily Load
Pday = [175.19	165.15	158.67	154.73	155.06	160.48	173.39	177.6	186.81	206.96	228.61	236.1	242.18	243.6	248.86	255.79	256	246.74	245.97	237.35	237.31	232.67	195.93	195.6]';
mpc.dailyload = Pday./max(Pday);

%% bus data
%	bus_i	type	Pd	Qd	Gs	Bs	area	Vm	Va	baseKV	zone	Vmax	Vmin
mpc.bus = [
	1	3	0	0	0	0	1	1.05	0	230	1	1.05	0.95;
	2	2	0	0	0	0	1	1.05	0	230	1	1.15	0.85;
	3	1	76.8	22.08	0	0	1	1	0	230	1	1.15	0.85;
	4	1	102.4	29.44	0	0	1	1	0	230	1	1.05	0.91;
	5	1	76.8	22.08	0	0	1	1	0	230	1	1.15	0.85;
	6	2	0	0	0	0	1	1.07	0	230	1	1.15	0.85;
];

%% generator data
%	bus	Pg	Qg	Qmax	Qmin	Vg	mBase	status	Pmax	Pmin	Pc1	Pc2	Qc1min	Qc1max	Qc2min	Qc2max	ramp_agc	ramp_10	ramp_30	ramp_q	apf
mpc.gen = [
	1	105	0	50	-40	1.05	100	1	220	100	0	0	0	0	0	0	0	0	55	4	0;
	2	80	0	50	-40	1.05	100	1	100	10	0	0	0	0	0	0	0	0	50	2	0;
	6	80	0	50	-40	1.07	100	1	20	10	0	0	0	0	0	0	0	0	20	2	0;
];

%% branch data
%	fbus	tbus	r	x	b	rateA	rateB	rateC	ratio	angle	status	angmin	angmax
mpc.branch = [
	1	2	0.005	0.17	0	119	200	200	0	0	1	-360	360;
	1	4	0.003	0.258	0	100	100	100	0	0	1	-360	360;
	2	4	0.007	0.197	0	100	100	100	0	0	1	-360	360;
	5	6	0.002	0.14	0	100	100	100	0	0	1	-360	360;
	3	6	0.0005	0.018	0	100	100	100	0	0	1	-360	360;
	2	3	0.0001	0.037	0	100	0	0	0	0	1	-360	360; %  Transformer
	4	5	0.0001	0.037	0	100	0	0	0	0	1	-360	360; %  Transformer
];

%%-----  OPF Data  -----%%
%% generator cost data
%	1	startup	shutdown	n	x1	y1	...	xn	yn
%	2	startup	shutdown	n	c(n-1)	...	c0
mpc.gencost = [
	2	100	0	2	0.1 13.5	176.9;
	2	200	0	2	0.1 32.6	129.9;
	2	0	0	2	0.1 17.6	137.4;
];

%% generator piecewise cost data y = kx + b
%   k1 k2 k3 ... 	
% mpc.cost_k = [24.5,46.5;
%               37.6,47.6;
%               18.6,20.6];
mpc.cost_k = [13.5;32.6;17.6];
%   b1 b2 b3 ...	
% mpc.cost_b = [176.90,-2243.1;
%               129.90,-370.10;
%               137.40,117.40];
mpc.cost_b = [176.9;129.9;137.4];











end
