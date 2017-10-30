clc, clear all;

%% Main
loadconstants

%[MaxColumns, blockWeight, ei, ef] = DomainParser('testing1.txt');
[MaxColumns, blockWeight, ei, ef] = DomainParser('testing2.txt');

%% Solver
maxIter = 500;
Q = {{ef}};
visitedStates = {ef};
P = {{}};
done = false;
iter = 1;
while not(done) && not(isempty(Q)) && iter <= maxIter
    disp("Iteration: " + string(iter))
    prevStateSeq = Q{1};    
    prevState = prevStateSeq{1};
    Q = Q(2:end);
    prevPSeq = P{1};
    P = P(2:end);
    disp("prevAction: " + join(prevPSeq,','));
    disp("prevState: " + join(prevState,','));
    
    % Expand Node (Possible actions that lead to the state)
    % Infere valid actions from state
    proposedActionDesc = [];
    for p = prevState
        actions = inferaction(p, prevState, blockWeight);
        proposedActionDesc = [proposedActionDesc actions];
    end
    proposedActionDesc = unique(proposedActionDesc(proposedActionDesc > ""));
    disp("  Proposed Act: " + join(proposedActionDesc,','));
    
    % Generate action predicates
    for actDesc = proposedActionDesc
        disp("    Action: " + actDesc)
        [prec, add, del] = action(actDesc, prevState, blockWeight);
  
        % Apply generation function
        regoutput = arrayfun(@(p) regression(p, add, del), prevState);

        % if FALSE in regoutput, discard operator
        % else Feasible Action, it is a good candidate
        if ismember("FALSE", regoutput)
            continue
        else
            % NextState = [ActionPrec + RegFunOutput]
            regoutput = regoutput(not(regoutput == "TRUE"));
            nextState = sort(unique([prec regoutput]));
            disp("      Next State: " + join(nextState,','));
            
            % Check if already visited state
            if any(cellfun(@(s) isequal(nextState, s), visitedStates))
                disp("        Already visited state");
                continue
            else
                visitedStates = {visitedStates{:}, nextState};
            end
            
            % Add State node
            nextStateSeq = [{nextState} prevStateSeq];
            Q = {Q{:} nextStateSeq};
            % Add Plan node
            nextPSeq = [actDesc prevPSeq];
            P = {P{:} nextPSeq};

            % Check if Goal state is achieved
            if isequal(nextState, ei)
                disp("DONE! Plan: " + join(P{end}, ','));
                done = true;
                break
            end
        end
    end

    iter = iter + 1;
end

%% Functions
function [MaxColumns, Blocks, InitialState, GoalState] = DomainParser(fileName)
    % DomainParser Constructs an instance of this class
    %  Opens the filename and stores the relevant lines as
    %  properties.
    
    delimiter = ".";
    weightToken = "*";

    function strVal = parseValue(line)
            % Parses a string with an equal sign and extracts the value to the
            % right as a string
            strVal = strsplit(line, '=');
            strVal = erase(strVal{2}, ";");
    end

    function state = parseState(stateDesc)
        stateDescElems = strsplit(stateDesc, delimiter);
        state = sort(cellfun(@(p) string(p), stateDescElems));
    end

    function blockMap = parseBlocks(blockDesc)
        blocksDefElems = strsplit(blockDesc, delimiter);
        blockMap = containers.Map( ...
            cellfun(@(e) {e(1)}, blocksDefElems), ...
            cellfun(@(e) count(e(2:end), weightToken), blocksDefElems));
    end

    fid = fopen(fileName,'r');
    maxColLine = parseValue(fgetl(fid));
    blocksLine = parseValue(fgetl(fid));
    initialStateLine = parseValue(fgetl(fid));
    finalStateLine = parseValue(fgetl(fid));           
    fclose(fid);
    
    MaxColumns = str2num(maxColLine);
    Blocks = parseBlocks(blocksLine);
    InitialState = parseState(initialStateLine);
    GoalState = parseState(finalStateLine);
    
end

function regout = regression(pred, add, del)
    if ismember(pred, add)
        regout = "TRUE";
    elseif ismember(pred, del)
        regout = "FALSE";
    else
        regout = pred;
    end
end

function actions = inferaction(pred, state, blockWeight)
    loadconstants
    actions = [""];
    [name, args] = decompose(pred);
    switch name
        case ONTABLE
            checkEmptyArm = ~isempty(infereArm(blockWeight, state, args));
            checkOn = any(contains(state(contains(state, "ON(")), args(1) + ")"));
            if checkEmptyArm && not(checkOn)
                actions = compose(LEAVE, args);
            end
        case ON
            checkHeavier = isheavier(blockWeight,args(2), args(1));
            % Check if state contains ON(p,X). Incompatible with HOLDING(X)
            % [precondition incompatible with state]
            checkOn = not(any(contains(state(contains(state, "ON(")), args(1) + ")")));
            checkArm = not(isempty(infereArm(blockWeight,state,args(1))));
            if checkHeavier && checkOn && checkArm
                actions = compose(STACK, args);
            end
        case CLEAR
            % FIND 
            %  CLEAR(Y) + HOLDING(X,L) + HEAVIER(Y,X) <= UNSTACK-LEFT(X,Y)
            %  CLEAR(Y) + HOLDING(X,R) + HEAVIER(Y,X) <= UNSTACK-RIGHT(X,Y)
            
            % if state contains HOLDING(Y,L) or HOLDING(Y,R) skip
            % avoid stacking on arms
            if not(any(contains(state, compose(HOLDING, [args RIGHTARM]))) ...
                    || any(contains(state, compose(HOLDING, [args LEFTARM]))))     
                for p = state
                    [n, a] = decompose(p);
                    if n == HOLDING && not(a(1) == args) && isheavier(blockWeight, args, a(1))
                        if a(2) == LEFTARM
                            actions = compose(UNSTACKLEFT, [a(1) args]);
                        elseif a(2) == RIGHTARM
                            actions = compose(UNSTACKRIGHT, [a(1) args]);
                        end
                    end
                end
            end
        case EMPTYARM
            % FIND 
            %  CLEAR(X) + ON(X,Y) <= STACK(X,Y)
            %  CLEAR(X) + ON-TABLE(X) + ARM available <= LEAVE(X)
            clearArgs = [];
            for p = state
                [n, a] = decompose(p);
                if n == CLEAR
                    clearArgs = [clearArgs a];
                elseif n == ON && ismember(a(1), clearArgs) && args == infereArm(blockWeight, state, a(1))  % and the X of ON(X,Y) is CLEAR
                    actions = [actions compose(STACK, a)];
                elseif n == ONTABLE && ismember(a, clearArgs) && args == infereArm(blockWeight, state, a)  %
                    actions = [actions compose(LEAVE, a)];
                end
            end
        case HOLDING
            % If columns available, could be from PICKUP
            if iscolavailable(state)
                if args(2) == LEFTARM
                    actions = compose(PICKUPLEFT, args(1));
                elseif args(2) == RIGHTARM
                    actions = compose(PICKUPRIGHT, args(1));
                end
            end
            % Or If CLEAR(Y), could be from UNSTACK. This case in CLEAR
    end
    % disp(pred + " => " + join(actions,','));  % DEBUG
end

function inferedArm = infereArm(blockWeight, state, X)
    loadconstants
    inferedArm = '';
    checkLight = islightblock(blockWeight, X);
    checkEmptyLeft = any(contains(state, compose(EMPTYARM, LEFTARM)));
    checkEmptyRight = any(contains(state, compose(EMPTYARM, RIGHTARM)));
    if(checkEmptyLeft && checkLight)
        inferedArm = LEFTARM;
    elseif(checkEmptyRight)
        inferedArm = RIGHTARM;
    end
end

function [predName, predArgs] = decompose(predDesc)
    predElems = regexp(erase(predDesc, ')'), '\(|,', 'split');
    predString = cellfun(@(p) string(p), predElems);
    predName = predString(1);
    predArgs = predString(2:end);
end

function predDesc = compose(predName, predArgs)
    predDesc = predName + "(" + join(predArgs, ',') + ")";
end

function [precond, add, del] = action(actDesc, state, blockWeight)
    loadconstants
    [actName, actArgs] = decompose(actDesc);
    X = actArgs(1);
    if(size(actArgs, 2) > 1)
        Y = actArgs(2);
    end
    
    % Infere Arm to be used
    inferedArm = infereArm(blockWeight, state, X);
    
    switch actName
        case PICKUPLEFT
            precond = [
                compose(ONTABLE, X) ...
                compose(EMPTYARM, LEFTARM) ...
                compose(CLEAR, X)
            ];
            add = [
                compose(HOLDING, [X LEFTARM])
            ];
            del = [
                compose(ONTABLE, X) ...
                compose(EMPTYARM, LEFTARM)
            ];
        case PICKUPRIGHT
            precond = [
                compose(ONTABLE, X) ...
                compose(EMPTYARM, RIGHTARM) ...
                compose(CLEAR, X)
            ];
            add = [
                compose(HOLDING, [X, RIGHTARM])
            ];
            del = [
                compose(ONTABLE, X) ...
                compose(EMPTYARM, RIGHTARM)
            ];
        case STACK
          
            precond = [
                compose(HOLDING, [X inferedArm]) ...
                compose(CLEAR, Y)
            ];
            add = [
                compose(ON, [X Y]) ...
                compose(EMPTYARM, inferedArm)
            ];
            del = [
                compose(HOLDING, [X inferedArm]) ...
                compose(CLEAR, Y)
            ];
        case UNSTACKLEFT
            precond = [
                compose(ON, [X, Y]) ...
                compose(CLEAR, X) ...
                compose(EMPTYARM, LEFTARM)
            ];
            add = [
                compose(HOLDING, [X, LEFTARM]) ...
                compose(CLEAR, Y)
            ];
            del = [
                compose(ON, [X, Y]) ...
                compose(EMPTYARM, LEFTARM)
            ];
        case UNSTACKRIGHT
            precond = [
                compose(ON, [X, Y]) ...
                compose(CLEAR, X) ...
                compose(EMPTYARM, RIGHTARM)
            ];
            add = [
                compose(HOLDING, [X, RIGHTARM]) ...
                compose(CLEAR, Y)
            ];
            del = [
                compose(ON, [X, Y]) ...
                compose(EMPTYARM, RIGHTARM)
            ];
        case LEAVE
            precond = [
                compose(HOLDING, [X, inferedArm])
            ];
            add = [
                compose(ONTABLE, X) ...
                compose(EMPTYARM, inferedArm)
            ];
            del = [
                compose(HOLDING, [X, inferedArm])
            ];
        otherwise
            error("Unknown action")
    end
end

function check = isheavier(blockWeight,blockX,blockY)
    check = (blockWeight(char(blockX)) >= blockWeight(char(blockY)));
end

function check = islightblock(blockWeight,blockX)
    loadconstants
    check = (blockWeight(char(blockX)) == MAXLIGHTWEIGHT);
end

function check = iscolavailable(state)
    loadconstants
    MaxColumns = 3; % TODO: global isn't workin!
    check = sum(count(state, ONTABLE)) < MaxColumns;
end

