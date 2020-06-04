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

% example poly7
problem.sTrajType = 'poly';
problem.DOF = 2;
% problem.timeA = 0;
% problem.timeB = 2;
% problem.posA = 0;
% problem.posB = 3;

poly7 = CADTraj(problem);
poly7.createTrajectory();
disp(poly7.traj.q)

%CADTraj.printTrajectory();
