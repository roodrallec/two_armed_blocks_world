%% Read Input
clc, clear all;
% TODO: Function read Input.txt returns 4 vars as follows (once teachers provides correct file):
% https://moodle.urv.cat/moodle/mod/forum/discuss.php?d=371854#p683742
% https://www.youtube.com/watch?v=yOunULLOxu0

MaxColumns = 3;
%Blocks = 'A*,B**,C**,D***,F*';
%InitialState = 'ON-TABLE(C),ON(B,C),ON(A,B),CLEAR(A),ON-TABLE(D),ON(F,D),CLEAR(D),EMPTY-ARM(L),EMPTY-ARM(R)';
%GoalState = 'ON-TABLE(B),ON(C,B),CLEAR(C),ON-TABLE(D),ON(A,D),ON(F,A),CLEAR(F),EMPTY-ARM(L),EMPTY-ARM(R)';

Blocks = 'A*,B*,C*';
InitialState = 'ON-TABLE(C),ON-TABLE(A),ON(B,A),CLEAR(B),CLEAR(C),EMPTY-ARM(L),EMPTY-ARM(R)';
GoalState = 'ON-TABLE(C),ON(B,C),ON(A,B),CLEAR(A),EMPTY-ARM(L),EMPTY-ARM(R)';

%% Main
loadconstants

% Parse blocks
blockWeight = parseBlocks(Blocks);
%isheavier(blockWeight,'A','B')

ei = parseState(InitialState);
ef = parseState(GoalState);

% ei(3)
% [n, a] = decompose(ei(3));
% compose(n,a)

%[pre, add, del] = action("STACK", ["A", "B"]);
% Adding HEAVIER, LIGHT-BLOCK, USE-COLS-NUM?

%% Solver
maxIter = 100;
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
            disp("      FALSE in regout");
            continue
        else
            % NextState = [ActionPrec + RegFunOutput]
            nextState = sort(unique([prec regoutput(not(regoutput == "TRUE"))]));
            disp("      Next State: " + join(nextState,','));
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

            %plan = [actDesc plan]; %TODO: improve as search
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
            checkEmptyArm = any(contains(state, "EMPTY-ARM"));
            checkOn = any(contains(state(contains(state, "ON(")), args(1) + ")"));
            if checkEmptyArm && not(checkOn)
                actions = compose(LEAVE, args);
            end
        case ON
            checkHeavier = isheavier(blockWeight,args(2), args(1));
            % Check if state contains ON(p,X). Incompatible with HOLDING(X)
            % [precondition incompatible with state]
            checkOn = any(contains(state(contains(state, "ON(")), args(1) + ")"));
            if checkHeavier && not(checkOn)
                actions = compose(STACK, args);
            end
        case CLEAR
            % FIND 
            %  CLEAR(Y) + HOLDING(X,L) <= UNSTACK-LEFT(X,Y)
            %  CLEAR(Y) + HOLDING(X,R) <= UNSTACK-RIGHT(X,Y)
            for p = state
                [n, a] = decompose(p);
                if n == HOLDING && not(a(1) == args)
                    if a(2) == LEFTARM
                        actions = compose(UNSTACKLEFT, [a(1) args]);
                    elseif a(2) == RIGHTARM
                        actions = compose(UNSTACKRIGHT, [a(1) args]);
                    end
                end
            end
        case EMPTYARM
            % FIND 
            %  CLEAR(X) and ON(X,Y) <= STACK(X,Y)
            %  CLEAR(X) and ON-TABLE(X) <= LEAVE(X)
            clearArgs = [];
            for p = state
                [n, a] = decompose(p);
                if n == CLEAR
                    clearArgs = [clearArgs a];
                elseif n == ON && ismember(a(1), clearArgs)  % and the X of ON(X,Y) is CLEAR
                    actions = [actions compose(STACK, a)];
                elseif n == ONTABLE && ismember(a, clearArgs)  % CHECK USED-COLS-NUM ?
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
            % Or If CLEAR(Y), could be from UNSTACK
            % FIND
            %  CLEAR(Y) + HOLDING(X,L) <= UNSTACK-LEFT(X,Y)
            %  CLEAR(Y) + HOLDING(X,R) <= UNSTACK-RIGHT(X,Y)
            % TODO: covered in the CLEAR statement? 
%             for p = state
%                 [n, a] = decompose(p);
%                 if n == CLEAR
%                     if args(2) == LEFTARM
%                         actions = [actions compose(UNSTACKLEFT, [args(1) a])]; % CHECK PRECONDITIONS? LEFT with lightblock
%                     elseif args(2) == RIGHTARM
%                         actions = [actions compose(UNSTACKRIGHT, [args(1) a])];
%                     end
%                 end
%             end
    end
end

function check = iscolavailable(state)
    loadconstants
    MaxColumns = 3; % TODO: global isn't workin!
    check = sum(count(state, ONTABLE)) < MaxColumns;
end

function state = parseState(stateDesc)
    stateDescElems = regexp(stateDesc, '(?<=\)),', 'split');
    state = sort(cellfun(@(p) string(p), stateDescElems));
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
    %checkHeavier = isheavier(blockWeight, Y, X);
    checkLight = islightblock(blockWeight, X);
    checkEmptyLeft = any(contains(state, compose(EMPTYARM, LEFTARM)));
    checkEmptyRight = any(contains(state, compose(EMPTYARM, RIGHTARM)));
    if(checkEmptyLeft && checkLight)
        inferedArm = LEFTARM;
    elseif(checkEmptyRight)
        inferedArm = RIGHTARM;
    end
    
    switch actName
        case PICKUPLEFT
            precond = [
                compose(ONTABLE, X) ...
                compose(EMPTYARM, LEFTARM) ...
                compose(CLEAR, X) ...
                %compose(LIGHTBLOCK, X)
            ];
            add = [
                compose(HOLDING, [X LEFTARM])% ...
                % compose(USEDCOLSNUM, true) % is a column available?
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
                compose(HOLDING, [X, RIGHTARM]) %, ...
                % compose(USEDCOLSNUM, true) % is a column available?
            ];
            del = [
                compose(ONTABLE, X) ...
                compose(EMPTYARM, RIGHTARM)
            ];
        case STACK
          
            precond = [
                compose(HOLDING, [X inferedArm]) ...
                compose(CLEAR, Y) ...
                % compose(HEAVIER, [Y, X])
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
                compose(EMPTYARM, LEFTARM) ...
                %compose(LIGHTBLOCK, X)
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
                compose(HOLDING, [X, inferedArm]) ...
                % compose(USEDCOLSNUM, true)
            ];
            add = [
                compose(ONTABLE, X) ...
                compose(EMPTYARM, inferedArm)
                % compose(USEDCOLSNUM, true) ...
            ];
            del = [
                compose(HOLDING, [X, inferedArm])
            ];
        otherwise
            error("Unknown action")
    end
end

% Parsing Functions
function blockMap = parseBlocks(blockDesc)
    blocksDefElems = strsplit(blockDesc, ',');
    blockMap = containers.Map( ...
        cellfun(@(e) {e(1)}, blocksDefElems), ...
        cellfun(@(e) count(e(2:end), '*'), blocksDefElems));
end

% Utility Functions
function check = isheavier(blockWeight,blockX,blockY)
    check = (blockWeight(char(blockX)) >= blockWeight(char(blockY)));
end

function check = islightblock(blockWeight,blockX)
    loadconstants
    check = (blockWeight(char(blockX)) == MAXLIGHTWEIGHT);
end
