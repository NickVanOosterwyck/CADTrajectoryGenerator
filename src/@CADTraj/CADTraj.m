classdef CADTraj < handle
    %CADTRAJECTORY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        
    end
    
    properties (SetAccess = protected)
        input
        traj
    end
    
    
    methods
        function obj = CADTraj(input)
            %CADTRAJECTORY Construct an instance of this class and checks
            %the input struct.
            %   Detailed explanation goes here
            
           obj.parseInput(input);
        end
    end
    methods (Access = private)
        [inputC] = parseInput(obj, input);
    end



end
