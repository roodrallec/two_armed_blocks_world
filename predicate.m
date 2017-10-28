classdef Predicate
    % PREDICATE Summary of this class goes here
    %   Detailed explanation goes here

    properties
        label
        args        
    end
    
    methods
        function obj = Predicate(label, args)
            % PREDICATE Construct an instance of this class
            %   Detailed explanation goes here
            obj.label = label;
            obj.args = args;            
        end
    end
end