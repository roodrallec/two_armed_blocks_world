classdef Predicate
    % PREDICATE Summary of this class goes here
    %   Detailed explanation goes here

    properties
        label
        args        
        string
    end
    
    methods
        function obj = Predicate(label, args)
            % PREDICATE Construct an instance of this class
            %   Detailed explanation goes here            
            obj.label = char(label);
            % type check             
            if (class(args) == "double")
               args = num2str(args); 
            end
            
            if (class(args) ~= "cell" && class(args) ~= "string")
                args = {args};
            end            
            
            obj.args = char(strjoin(args, ";"));
            obj.string = obj.toString();            
        end
        
        function bool = eq(obj, predicate)                       
            bool = any(contains([predicate.string], obj.string));
        end 
        
        function string = toString(obj)
            string = strjoin({obj.label, obj.args}, "=") + ";";
        end
    end
end