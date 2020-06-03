%% init
clear; clc; close all;
addpath(genpath([fileparts(matlab.desktop.editor.getActiveFilename),'\..']))


% example poly5
problem.sTrajType = 'poly5';
%problem.DOF = 2;

CADTraj = CADTrajectory(problem);
CADTraj.calculateTrajectory();
CADTraj.printTrajectory();
