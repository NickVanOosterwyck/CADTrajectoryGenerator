%% init
clear; clc; close all;
addpath(genpath([fileparts(matlab.desktop.editor.getActiveFilename),'\..']))

%% create motionprofile
syms tA tB tC pA pB pC
% forward
input.sTrajType = 'poly5';
input.timeA = tA;
input.timeB = tB;
input.posA = pA;
input.posB = pB;

poly5F = CADTraj(input);
poly5F.createTrajectory();

% backward
input.sTrajType = 'poly5';
input.timeA = tB;
input.timeB = tC;
input.posA = pB;
input.posB = pA;

poly5B = CADTraj(input);
poly5B.createTrajectory();


%% print to driver with CADTraj tool
problem.sTrajType = 'custom';
problem.trajFun = [poly5F.traj.q; poly5B.traj.q];
problem.trajFunBreaks = [tA tB tC];

custom = CADTraj(problem);
custom.createTrajectory();
custom.printTrajectory();