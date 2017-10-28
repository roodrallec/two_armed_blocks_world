classdef State
    %STATE Summary of this class goes here
    %   Detailed explanation goes here

    properties
        predicates
        from        
        expanded = false
    end

    methods
        function obj = State(predicates)
            % STATE Construct an instance of this class
            %   Detailed explanation goes here
            obj.predicates = predicates;            
        end        
        
        function bool = isequal(obj, state)
            % Checks whether it contains the same conditions
            % as the state passed in and returns true or false
           bool = true;
        end
    end
end
