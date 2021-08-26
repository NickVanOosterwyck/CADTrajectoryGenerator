%% init
clear; clc; close all;
addpath(genpath([fileparts(matlab.desktop.editor.getActiveFilename),'\..']))

%%
syms timeB timeC timeD posA posB posD speedB simTime tsample
% forward
clear input
input.sMechanism = 'BallJuggler';
input.sTrajType = 'poly';
input.timeA = 0;
input.timeB = timeB;
input.posA = 0;
input.posB = posB;
input.speedA = 0;
input.speedB = speedB;

poly5throw = CADTraj(input);
poly5throw.defineTrajectory();

% backward
clear input
input.sMechanism = 'BallJuggler';
input.sTrajType = 'poly';
input.timeA = timeC;
input.timeB = timeD;
input.posA = posB;
input.posB = posD;
input.speedA = 0;
input.speedB = 0;

poly5catch = CADTraj(input);
poly5catch.defineTrajectory();


%% print to driver with CADTraj tool
problem.sTrajType = 'custom';
problem.trajFun = [simplify(poly5throw.traj.q); posB; simplify(poly5catch.traj.q); posD];
problem.trajFunBreaks = [0 timeB timeC timeD simTime];

custom = CADTraj(problem);
custom.defineTrajectory();
custom.printTrajectory();
