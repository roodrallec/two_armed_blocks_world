classdef state
    %STATE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        predicates
        blocksMap
        maxColumns
    end
    
    methods
        function obj = state(stateDesc, blockDesc, maxColumns)
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
            
            obj.maxColumns = maxColumns;
            obj.updatecolumnavailable();
        end
        function pred = composePredicate(obj, predDesc)
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
        function check = containsbyname(obj, name)
            check = cellfun(@(p) isequal(p.name, name), obj.predicates);
        end
        function check = contains(obj, preds)
            % Using nested cellfuns instead of double for loops.
            % For each p in the given predicates, check if p is equal to 
            % any object's predicates. 
            check = cellfun(@(p) ...
                cellfun(@(op) isequal(op,p), obj.predicates), ...
                preds, 'UniformOutput', false);
            check = logical(sum(cell2mat(check'),1));
        end
        function check = ismember(obj, pred)
            check = any(obj.contains(pred));
        end
        function check = isequal(obj, preds)
            check = isequal(obj.predicates, preds);
        end
        function del(obj, preds)
           obj.predicates = obj.predicates(not(obj.contains(preds)));
        end
        function add(obj, preds)
            obj.predicates = [obj.predicates, preds];
        end
        function check = iscolumnavailable(obj)
            usedColsNum = sum( ...
                cellfun(@(p) p.name == predicate.onTable, obj.predicates));
            check = usedColsNum < obj.maxColumns;
        end
        function obj = updatecolumnavailable(obj)
            usedColsNumIdx = obj.containsbyname(predicate.usedColsNum);
            if(any(usedColsNumIdx))
                obj.predicates(usedColsNumIdx).n = obj.iscolumnavailable();
            else
                usedColsNumPred = {
                    predicate(predicate.usedColsNum, obj.iscolumnavailable())
                };
                obj.add(usedColsNumPred)
            end
        end
    end
end

