classdef State < handle
    %STATE Summary of this class goes here
    %   Detailed explanation goes here
    properties
        predicates                
        expanded = false
    end

    methods
        function obj = State(predicates)
            % STATE Construct an instance of this class
            %   Detailed explanation goes here
            obj.predicates = predicates;
        end

        function string = toString(obj)
            string = strjoin(sort([obj.predicates.string]));
        end
    end
end
