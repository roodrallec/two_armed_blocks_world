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
        function obj = Operator(label, preConditions, add, del)
            obj.label = label;
            obj.preConditions = preConditions;
            obj.add = add;
            obj.del = del;
        end        
        
        function state = apply(obj, state)
            [operator.preConditions{:}] 
            [state.predicates.label]
        end
    end
end
