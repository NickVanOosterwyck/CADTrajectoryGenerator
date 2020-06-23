%% init
clear; clc; close all;
addpath(genpath([fileparts(matlab.desktop.editor.getActiveFilename),'\..']))

% example poly5
input.sTrajType = 'poly5';
input.timeA = 0;
input.timeB = 2;
input.posA = 0;
input.posB = 3;

poly5 = CADTraj(input);
poly5.createTrajectory();

% example cheb7
clear input
input.sTrajType = 'cheb';
input.DOF = 2;

poly7 = CADTraj(input);
poly7.createTrajectory();

% example spline2
clear input
input.sTrajType = 'spline';
input.DOF = 2;

spline2 = CADTraj(input);
spline2.createTrajectory();

% example spline2
clear input
input.sTrajType = 'custom';
syms a b t
input.trajFun = [a*t^2 + b*t; t];
input.trajFunBreaks = [0 1 2];

custom = CADTraj(input);
custom.createTrajectory();
disp(custom.traj.q)

custom.printTrajectory();
