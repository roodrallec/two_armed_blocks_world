classdef State
    %STATE Summary of this class goes here
    %   Detailed explanation goes here
    properties
        predicates
        children
        string
        expanded = false
    end

    methods
        function obj = State(predicates)
            % STATE Construct an instance of this class
            %   Detailed explanation goes here
            obj.predicates = predicates;
            obj.string = strjoin([predicates.string]);
        end

        function bool = eq(obj, state)
            bool = any(contains([state.string], obj.string));
        end
    end
end
