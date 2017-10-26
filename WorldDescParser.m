classdef WorldDescParser
    %WorldDescParser a text file world description parser
    % Parses a text file containing a description of the world which
    % consists of the max columns, blocks description, initial and final
    % state description respectively, and provides getter methods 
    % for the different world properties derived from them.
    properties
        maxColLine
        blocksLine
        initialStateLine
        finalStateLine
        delimiter = '.'
        weightToken = '*'
    end
    
    methods
        function obj = WorldDescParser(fileName, delimiter, weightToken)
            % WorldDescParser Constructs an instance of this class
            %  Opens the filename and stores the relevant lines as
            %  properties. optional delimiter and weight modify how it
            %  parses the world description.
            if (delimiter) 
                obj.delimiter = delimiter;
            end
            
            if (weightToken) 
                obj.weightToken = weightToken;
            end
            
            fid = fopen(fileName,'r');
            obj.maxColLine = fgetl(fid);
            obj.blocksLine = fgetl(fid);
            obj.initialStateLine = fgetl(fid);
            obj.finalStateLine = fgetl(fid);
            fclose(fid);
        end
        
        function maxColumns = getMaxCols()
            % parses a string containing the max number of columns and 
            % returns a number.            
            digitCell = regexp(obj.maxColLine, '\d+', 'match');
            maxColumns = str2num(digitCell{1});
        end
        
        function blocksMap = getBlocksMap()                        
            % parses a string description of the blocks and returns a block
            % map.
            blocksDesc = strsplit(obj.blocksLine,'=');
            blocksDesc = strsplit(blocksDesc{2}, obj.delimiter);
            blocksMap = cellfun(obj.parseBlock, blocksDesc);            
        end
        
        function block = parseBlock(blockStr)
            % parses block string and instantiates a block with extracted 
            % label and weight properties.
            [label, weights] = strsplit(block, obj.weightToken);            
            block = Block(label{1}, count(weights{1}, obj.weightToken));
        end
        
        function initialPredicates = getInitialPredicates()
            stateDesc = strsplit(obj.initialStateLine, '=');
            initialPredicates = obj.parsePredicates(stateDesc);
        end
        
        function finalPredicates = getFinalPredicates()
            stateDesc = strsplit(obj.finalStateLine, '=');
            finalPredicates = obj.parsePredicates(stateDesc);
        end
        
        function predicates = parsePredicates(stateDesc)
            % Create State
            % Parse the State description string and return predicates
            % array
            stateDescElems = regexp(stateDesc, '(?<=\)),', 'split');            
            predicates = cellfun(obj.composePredicate, stateDescElems);
        end
        
        function pred = composePredicate(predDesc)
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
    end
end

