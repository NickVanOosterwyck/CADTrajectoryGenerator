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
            obj.parseInput(input);
        end
    end
    
end

