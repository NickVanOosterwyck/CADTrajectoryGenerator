classdef CADTraj < handle
    %CADTRAJECTORY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = protected)
        input   % validated input struct
        traj    % trajectory struct
        print   % print struct
    end
    
    
    methods
        function obj = CADTraj(input)
            %CADTRAJECTORY Construct an instance of this class and checks
            %the input struct.
            %   Detailed explanation goes here
            obj.parseInput(input);
        end
    end
    
end

