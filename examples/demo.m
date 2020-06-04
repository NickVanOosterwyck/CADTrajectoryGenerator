%% init
clear; clc; close all;
addpath(genpath([fileparts(matlab.desktop.editor.getActiveFilename),'\..']))

% example poly5
problem.sTrajType = 'poly5';
problem.timeA = 0;
problem.timeB = 2;
problem.posA = 0;
problem.posB = 3;

poly5 = CADTraj(problem);
poly5.createTrajectory();
disp(poly5.traj.q)

% example cheb7
clear problem
problem.sTrajType = 'cheb';
problem.DOF = 2;

poly7 = CADTraj(problem);
poly7.createTrajectory();
disp(poly7.traj.q)

% example spline2
clear problem
problem.sTrajType = 'spline';
problem.DOF = 2;

spline = CADTraj(problem);
spline.createTrajectory();
disp(spline.traj.q)

%CADTraj.printTrajectory();
