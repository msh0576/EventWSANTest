clc; clear all; close all;

delta_t_moter = 10;
delta_t = 10;
th1_initial = 0.01;
th2_initial = 0.01;
th3_initial = 0.01;

%% Plant 

A=[1.38 -0.2077 6.715 -5.676;-0.5814 -4.29 0 0.675;1.067 4.273 -6.654 5.893;0.048 4.273 1.343 -2.104];
B=[0 0;5.679 0;1.136 -3.146;1.136 0];
C=[1 0 1 -1;0 1 0 0];
D=[0 0;0 0];

%% Controller

Ac=[0 0;0 0];
Bc=[0 1;1 0];
Cc=[2 0;0 -8];
Dc=[0 2;-5 0];

%% Ops

Tau=0.08;