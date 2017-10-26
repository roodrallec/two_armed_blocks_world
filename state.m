classdef state < handle
    %STATE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        predicates
        blocksMap
        maxColumns
    end
    
    methods
        function obj = state(predicates, blocksMap, maxColumns)
            %STATE Construct an instance of this class
            %   Detailed explanation goes here            
            
            
            obj.maxColumns = maxColumns;
            obj.updatecolumnavailable();
            obj.addheavierpred();
            obj.addlightblockpred();
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
        function obj = addheavierpred(obj)
            function pred = createheavierpred(b1, b2)
                if(b1.weight == b2.weight)
                    pred = {
                        predicate(predicate.heavier, [b1, b2]), ...
                        predicate(predicate.heavier, [b2, b1]), ...
                        };
                elseif(b1.weight > b2.weight)
                    pred = {predicate(predicate.heavier, [b1, b2])};
                else
                    pred = {predicate(predicate.heavier, [b2, b1])};
                end
            end
            blockPairs = combnk(obj.blocksMap.values,2);
            heavierPreds = cellfun(@createheavierpred, blockPairs(:,1), ...
                blockPairs(:,2), 'UniformOutput', false);
            cellfun(@obj.add, heavierPreds)    
        end
        function obj = addlightblockpred(obj)
            function pred = createlightblockpred(b)
                if(b.weight <= predicate.maxLightWeight)
                    pred = {predicate(predicate.lightBlock, b)};
                else
                    pred = {};
                end
            end
            lightBlockPreds = cellfun(@createlightblockpred, ...
                obj.blocksMap.values, 'UniformOutput', false);
            cellfun(@obj.add, lightBlockPreds)
        end
        
    end
end

