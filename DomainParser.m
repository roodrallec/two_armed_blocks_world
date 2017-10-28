classdef DomainParser
    % DomainParser, a text file containing the domain description:
    %  Parses a text file containing a description of the world which
    %  consists of the max columns, blocks description, initial and final
    %  state description respectively, and provides getter methods
    %  for the different world properties derived from them.
    properties
        maxColLine
        blocksLine
        initialStateLine
        finalStateLine
        arms = {"L", "R"}
        delimiter = "."        
        weightToken = "*"
        predicateBracket = ")"
    end

    methods
        function obj = DomainParser(fileName, delimiter, weightToken, predicateBracket)
            % DomainParser Constructs an instance of this class
            %  Opens the filename and stores the relevant lines as
            %  properties. optional delimiter, weight and predicateBracket
            %  modify how it parses the world description.
            if exist('delimiter','var')
                obj.delimiter = delimiter;
            end

            if exist('weightToken','var')
                obj.weightToken = weightToken;
            end
            
            if exist('predicateBracket','var')
                obj.predicateBracket = predicateBracket;
            end
            
            fid = fopen(fileName,'r');
            obj.maxColLine = obj.parseValue(fgetl(fid));
            obj.blocksLine = obj.parseValue(fgetl(fid));
            obj.initialStateLine = obj.parseValue(fgetl(fid));
            obj.finalStateLine = obj.parseValue(fgetl(fid));            
            fclose(fid);
        end

        function strVal = parseValue(~, line)
            % Parses a string with an equal sign and extracts the value to the
            % right as a string
            strVal = strsplit(line, '=');
            strVal = erase(strVal{2}, ";");
        end

        function maxColumns = getMaxCols(obj)
            % Parses a string containing the max number of columns and
            % returns a number.
            maxColumns = regexp(obj.maxColLine, '\d+', 'match');
            maxColumns = str2double(maxColumns{1});
        end

        function blocksMap = getBlocksMap(obj)
            % Parses a string description of the blocks and returns a block
            % map.
            blocksMap = strsplit(obj.blocksLine, obj.delimiter);
            blocksMap = cellfun(@obj.parseBlock, blocksMap);
        end

        function block = parseBlock(obj, blockStr)
            % Parses block string and instantiates a block with extracted
            % label and weight properties.
            [label, weights] = strsplit(blockStr, obj.weightToken);
            block = Block(label{1}, count(weights{1}, obj.weightToken));
        end

        function initialState = getInitialState(obj)
            % Parses the predicates of the intial state description
            initialState = State(obj.parsePredicates(obj.initialStateLine));
        end

        function finalState = getFinalState(obj)
            % Parses the predicates of the final state description
            finalState = State(obj.parsePredicates(obj.finalStateLine));
        end

        function predicates = parsePredicates(obj, stateDesc)
            % Parses a state description and returns a sorted list of predicates            
            regex = obj.predicateBracket + obj.delimiter;            
            predicates = regexp(stateDesc, regex, 'split');
            predicates = cellfun(@obj.parsePredicate, predicates);
        end        
        
        function predicate = parsePredicate(obj, predStr)
            predStr = regexp(predStr, "[a-zA-Z\-\_]*", 'match');
            predicate = Predicate(predStr{1}, predStr(1, 2:end));
        end
        
        function arms = getArms(obj)
            arms = obj.arms;
        end
    end
end