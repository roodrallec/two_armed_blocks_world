classdef state
    %STATE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        predicates
        blocksMap
    end
    
    methods
        function obj = state(stateDesc, blockDesc)
            %STATE Construct an instance of this class
            %   Detailed explanation goes here
            % Create Blocks
            obj.blocksMap = block.createblockmap(blockDesc);
            
            % Create State
            % Parse the State description string
            stateDescElems = regexp(stateDesc, '(?<=\)),', 'split');
            % The state description is made of Predicates
            obj.predicates = cellfun(@obj.composePredicate, stateDescElems, ...
                'UniformOutput', false);
        end
        
        function pred = composePredicate(obj,predDesc)
            predElems = regexp(erase(predDesc, ')'), '\(|,', 'split');
            predName = predElems{1};
            predArgs = predElems(2:end);
            
            % Return a block if defined, otherwise it is a parameter
            function arg = checkblockorparam(arg)
                if(isKey(obj.blocksMap, arg))
                    arg = obj.blocksMap(arg{1});
                else
                    arg = arg{1};
                end
            end
            
            predArgsParsed = arrayfun(@checkblockorparam, predArgs);
            pred = predicate(predName, predArgsParsed);
        end
        
        function str = tostring(obj)
            str = (cellfun(@(p) p.print, obj.predicates));
        end
        
        function print(obj)
            join(obj.tostring, ',')
        end
    end
end

