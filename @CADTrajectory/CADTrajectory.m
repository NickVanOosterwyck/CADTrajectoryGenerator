classdef CADTrajectory < handle
    %CADTRAJECTORY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        
    end
    
    properties (SetAccess = protected)
        sTrajType % Trajectory type
        DOF % degrees of freedom
        trapRatio % ratio t_acc/t_tot (trap)
        nPieces % number of time intervals
        
    end
    
    
    methods
        function obj = CADTrajectory(problem)
            %CADTRAJECTORY Construct an instance of this class and checks
            %the problem input.
            %   Detailed explanation goes here
            
            CADTrajectory.parseProblem(problem);
        end
    end
    methods (Access = private)
        [] = parseProblem(obj,prob)
    end



end

