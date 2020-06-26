function [inputC] = parseInput(obj, input)
%PARSEPROBLEM runs through the input struct and parses the input. The
%validated inputs are set to the class properties. If a mandatory field is 
%missing or not valid, then it throws an error.
%
% INPUTS:
%   input = an input struct, with required field
%       .sTrajType % trajectory type
%   and optional fields:
%       .timeA = start time
%       .timeB = end time
%       .posA = start position
%       .posB = end position 
%       .DOF = degrees of freedom
%       .trapRatio = ratio t_acc/t_tot
%       .trajFun = custom trajectory function
%       .trajFunBreaks = custom breakspoints
%       .digits % # significant digits
%
% OUTPUTS:
%   inputC = a complete input struct, with validated fields:
%       .sTrajType % trajectory type
%       .timeA % start time
%       .timeB % end time
%       .posA % start position
%       .posB % end position
%       .DOF % degrees of freedom
%       .trapRatio % ratio t_acc/t_tot
%       .trajFun % custom trajectory function
%       .trajFunBreaks = custom breakspoints
%       .digits % # significant digits
%   and derived fields:
%       .nPieces % number of time intervals
%   
% Copyright (C) 2020 Nick Van Oosterwyck <nick.vanoosterwyck@uantwerp.be>
% All rights reserved.
%
% This software may be modified & distributed under the terms
% of the GNU license. See LICENSE file in repo for details.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check and validate required fields
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% sTrajType
% validate field
if ~isfield(input, 'sTrajType')
    error('Field ''sTrajType'' cannot be ommitted from ''input''');
else
    validTrajTypes = {'trap','poly5','poly','cheb','cheb2','spline','custom'};
    validatestring(input.sTrajType,validTrajTypes);
end
inputC.sTrajType = input.sTrajType;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check optional fields (and assign default values if empty)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% timeA
% validate field and assign default value if empty
if ~isfield(input,'timeA')
    input.timeA = sym('tA');
elseif ~isa(input.timeA,'sym') && ~isnumeric(input.timeA)
    error('Field ''timeA'' must be numeric or symbolic.')
end
inputC.timeA = input.timeA; 

%%% timeB
% validate field and assign default value if empty
if ~isfield(input,'timeB')
    input.timeB = sym('tB');
elseif ~isa(input.timeB,'sym') && ~isnumeric(input.timeB)
    error('Field ''timeB'' must be numeric or symbolic.')
end
% extra checks
if isnumeric(input.timeA) && isnumeric(input.timeB)
    if input.timeB < input.timeA
        error(['The value of field ''timeB'' must be greater than',...
            'the value of field ''timeB''.'])
    end
end
inputC.timeB = input.timeB;

%%% posA
% validate field and assign default value if empty
if ~isfield(input,'posA')
    input.posA = sym('pA');
elseif ~isa(input.posA,'sym') && ~isnumeric(input.posA)
    error('Field ''posA'' must be numeric or symbolic.')
end
inputC.posA = input.posA; 

%%% posB
% validate field and assign default value if empty
if ~isfield(input,'posB')
    input.posB = sym('pB');
elseif ~isa(input.posB,'sym') && ~isnumeric(input.posB)
    error('Field ''posB'' must be numeric or symbolic.')
end
inputC.posB = input.posB;

%%% DOF
% validate field and assign default value if empty
if ~isfield(input,'DOF')
    input.DOF = 0;
else
    mustBeNonnegative(input.DOF);
    mustBeInteger(input.DOF)
end
% extra checks
switch inputC.sTrajType
    case {'trap','poly5'}
        if input.DOF ~= 0
            error(['The selected trajectory',...
                'type does not allow any DOF.'])
        end
    case {'poly','cheb','cheb2','spline'}
        if input.DOF == 0
            warning('The selected trajectory is not optimisable.')
        end
end
inputC.DOF = input.DOF; 

%%% trapRatio
% validate field and assign default value if empty
if ~isfield(input,'trapRatio')
    input.trapRatio = [];
else
    mustBeNonnegative(input.trapRatio);
    mustBeLessThanOrEqual(input.trapRatio,0.5)
end
% extra checks
switch inputC.sTrajType
    case {'poly5','poly','cheb','cheb2','spline','custom'}
        if ~isempty(input.trapRatio)
            error(['The selected trajectory type ''%s'' does not allow a',...
                'field ''trapRatio.'''],input.sTrajType)
        end
end
inputC.trapRatio = input.trapRatio;

%%% trajFun
% validate field and assign default value if empty
if ~isfield(input,'trajFun')
    input.trajFun = [];
else
    if ~isempty(input.trajFun) && ~isa(input.trajFun,'sym')
        error('Value must be symbolic.')
    end
end
% extra checks
switch inputC.sTrajType
    case {'poly5','trap','poly','cheb','cheb2','spline'}
        if ~isempty(input.trajFun)
        error(['The selected trajectory type ''%s'' does not allow a',...
            'field ''trajFun.'''],input.sTrajType)
        end
end
inputC.trajFun = input.trajFun;

%%% trajFunBreaks
% validate field and assign default value if empty
if ~isfield(input,'trajFunBreaks')
    input.trajFunBreaks = [];
else
    if ~isa(input.trajFunBreaks,'sym') && ~isnumeric(input.trajFunBreaks)
        error('Field ''trajFunBreaks'' must be numeric or symbolic.')
    end
end
% extra checks
switch inputC.sTrajType
    case {'poly5','trap','poly','cheb','cheb2','spline'}
        if ~isempty(input.trajFunBreaks)
        error(['The selected trajectory type ''%s'' does not allow a',...
            'field ''trajFunBreaks'''],input.sTrajType)
        end
end
inputC.trajFunBreaks = input.trajFunBreaks;

%%% digits
% validate field and assign default value if empty
if ~isfield(input,'digits')
    input.digits = [];
else
    mustBeInteger(input.digits);
    mustBeGreaterThanOrEqual(input.digits,2);
end
inputC.digits = input.digits; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% assign dependent properties
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% nPieces
switch inputC.sTrajType
    case {'poly5','poly','cheb','cheb2'}
        inputC.nPieces = 1;
    case {'trap'}
        inputC.nPieces = 3;
    case {'spline'}
        inputC.nPieces = inputC.DOF + 3;
    case {'custom'}
        inputC.nPieces = size(inputC.trajFun,1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% assign validated input to property
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

obj.input = inputC;

end

