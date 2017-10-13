classdef block
    %BLOCK Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        label
        weight
    end
    
    properties (Constant, Hidden = true)
        weightRange = [1, 4]
    end
    
    methods
        function obj = block(symbol)
            %BLOCK Construct an instance of this class
            %   Detailed explanation goes here
            
            %disp(symbol);
            obj.label = string(symbol(1));
            obj.weight = count(symbol(2:end), '*');
            if ((obj.weight < obj.weightRange(1)) ... 
                    && (obj.weight > obj.weightRange(2)))
                error("Block weight out of range")
            end     
        end
    end
    methods(Static)
        function blockMap = createblockmap(blocksDef)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            blocksDefElems = strsplit(blocksDef, ',');
            blockMap = containers.Map( ...
                cellfun(@(e) {e(1)}, blocksDefElems), ...
                cellfun(@(e) {block(e)}, blocksDefElems));
        end
    end
end

