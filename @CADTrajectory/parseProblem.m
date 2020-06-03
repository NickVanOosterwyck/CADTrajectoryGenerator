function [] = parseProblem(obj,prob)
%PARSEPROBLEM runs through the problem struct and parses the input. The
%validated inputs are set to the class properties. If a mandatory field is 
%missing or not valid, then it throws an error.
%
% INPUTS:
%   prob = a problem struct
%
% OUTPUTS:
%   
% Copyright (C) 2020 Nick Van Oosterwyck <nick.vanoosterwyck@uantwerp.be>
% All rights reserved.
%
% This software may be modified & distributed under the terms
% of the GNU license. See LICENSE file in repo for details.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check and validate required fields
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% sTrajType
% check input
if ~isfield(prob, 'sTrajType')
    error('Field ''sTrajType'' cannot be ommitted from ''problem'''); end
validTrajTypes = {'trap','poly5','poly','cheb','cheb2','spline','custom'};
validatestring(prob.sTrajType,validTrajTypes)
% assign to property
obj.sTrajType = prob.sTrajType; 

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check optional fields (and assign default values if empty)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% DOF
% check input and assign default if empty
if ~isfield(prob,'DOF'), prob.DOF = 0; end
mustBeNonnegative(prob.DOF);
mustBeInteger(prob.DOF)

% extra checks
switch obj.sTrajType
    case {'trap','poly5'}
        if prob.DOF ~= 0
            error(['The selected trajectory',...
                'type does not allow any DOF.'])
        end
    case {'poly','cheb','cheb2','spline','custom'}
        if DOF == 0
            warning('The selected trajectory is not optimisable.')
        end
end
obj.DOF = prob.DOF; % assign to property

%% trapRatio
% check input and assign default if empty
if ~isfield(prob,'trapRatio'), prob.trapRatio = []; end
mustBeNonnegative(prob.trapRatio);
mustBeLessThanOrEqual(prob.trapRatio,0.5)

% extra checks
switch obj.sTrajType
    case {'poly5','poly','cheb','cheb2','spline','custom'}
        if ~isempty(prob.trapRatio)
        error(['The selected trajectory type ''%s'' does not allow a',...
            'field ''trapRatio.'''],prob.sTrajType)
        end
end
obj.trapRatio = prob.trapRatio; % assign to property

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% assign dependent properties
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% nPieces
switch obj.sTrajType
    case {'poly5','poly','cheb','cheb2','custom'}
        obj.nPieces = 1;
    case {'trap'}
        obj.nPieces = 3;
    case {'spline'}
        obj.nPieces = obj.DOF + 3;
end

end

