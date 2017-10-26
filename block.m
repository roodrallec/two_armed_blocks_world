classdef Block
    %BLOCK Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        label
        weight
    end
    
    properties (Constant, Hidden = true)        
        maxWeight = 4;
        minWeight = 1;
    end
    
    methods
        function obj = block(label, weight)
            %BLOCK Construct an instance of this class
            %   Detailed explanation goes here            
            if (weight < obj.minWeight) || (weight > obj.maxWeight)
                error("Block weight out of range")
            end     
            obj.label = label;
            obj.weight = weight;            
        end
    end
end

