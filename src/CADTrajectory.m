classdef CADTrajectory < handle
    %CADTRAJECTORY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        sTrajType % Trajectory type
    end
    
    properties (SetAccess = protected)
        problem % a problem struct that contains the input settings
        nPieces % number of time intervals
        DOF % degrees of freedom
        trapRatio % ratio t_acc/t_tot (trap)
    end
   
    
    methods
        function obj = CADTrajectory(problem)
            %CADTRAJECTORY Construct an instance of this class and check
            %input.
            %   Detailed explanation goes here
            obj.problem = validateProblem(problem);
        end
    end
    
    methods(Access = private)
        function updatePieces(obj)
            switch obj.sTrajType
                case {'poly5','poly','cheb','cheb2','custom'}
                    obj.nPieces = 1;
                case {'trap'}
                    obj.nPieces = 3;
                case {'spline'}
                    obj.nPieces = obj.DOF + 3;
            end
            
        end
    end
end

