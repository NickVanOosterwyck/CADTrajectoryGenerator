function [problem] = validateProblem(obj,problem)
%INPUTVALIDATION runs through the problem struct and sets any missing 
%fields to the default value. If a mandatory field is missing or not valid,
%then it throws an error.
%
% INPUTS:
%   problem = a partially completed problem struct
%
% OUTPUTS:
%   problem = a complete problem struct, with validated fields
%
% Copyright (C) 2020 Nick Van Oosterwyck <nick.vanoosterwyck@uantwerp.be>
% All rights reserved.
%
% This software may be modified & distributed under the terms
% of the GNU license. See LICENSE file in repo for details.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% list of possible trajectory types
validTrajTypes = {'trap','poly5','poly','cheb','cheb2','spline','custom'};

% check required fields
if ~isfield(problem, 'sTrajType')
    error('Field ''sTrajType'' cannot be ommitted from ''problem'''); end
validatestring(problem.sTrajType,validTrajTypes)

% check optional fields and assign default values if empty
if ~isfield(problem.traj, 'DOF'), problem.DOF = 0; end
if ~isfield(problem.traj, 'nInt'), problem.traj.nInt = 1; end
if ~isfield(problem.traj, 'trapRatio'), problem.trapRatio = 1/3; end
if ~isfield(problem.traj, 'trajFun'), problem.trajFun = []; end
if ~isfield(problem.traj, 'timeA'), problem.timeA = sym('timeA'); end
if ~isfield(problem.traj, 'timeB'), problem.timeA = sym('timeB'); end
if ~isfield(problem.traj, 'posA'), problem.timeA = sym('posA'); end
if ~isfield(problem.traj, 'posB'), problem.timeA = sym('posB'); end

% assign validated struct to class property
obj.problem = problem;

end

