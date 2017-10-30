classdef Operator < handle
    %OPERATOR Summary of this class goes here
    %   Detailed explanation goes here

    properties
        label
        preConditions
        add
        del
    end

    methods
        function obj = Operator(label)
            obj.label = label;
            obj.preConditions = [];
            obj.add = [];
            obj.del = [];
        end
    end
end
