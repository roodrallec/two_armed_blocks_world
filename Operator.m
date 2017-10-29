classdef Operator
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

        function addPre(obj, preCondition)
          obj.preConditions = [obj.preConditions, preCondition];
        end

        function addAdd(obj, addCondition)
          obj.add = [obj.add, addCondition];
        end

        function addDel(obj, delCondition)
          obj.del = [obj.del, delCondition];
        end
    end
end
