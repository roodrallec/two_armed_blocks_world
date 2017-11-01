%% Non-Linear Planner with Regression Implementation script
% The script is divided in the following sections.
% - Cases: executes testing and benchmark cases and generates the outpu files
% - Benchmark 1 and 2: executes benchmark 1 and 2 series for the graphic analysis
% - Solver and Functions: contains the algorithm implementation
% - loadconstants.m: contains the constants definitions

clc, clear all;

%% Cases
inputFiles = [dir('testing*.txt'); dir('benchmark*.txt')];
for filename = {inputFiles.name}
    % Load Input
    [MaxColumns, blockWeight, ei, ef] = DomainParser(filename{:});
    outputFile =  "output_" + filename{:};
    
    % Execute Solver
    [o, i, n, t] = solver(MaxColumns, blockWeight, ei, ef);
    
    % Save output
    fid=fopen(outputFile,'w');
    fprintf(fid, o);
    fclose(fid);
    
end

%% Benchmark 1
% ncols = [3 4 5 6];
% nstates = [1680 2661 3086 3100];
% noperators = [18 12 12 12];

ncols = [];
nstates = [];
noperators = [];
times = [];
[MaxColumns, blockWeight, ei, ef] = DomainParser('Benchmark1.txt');
for nc = [3:6]
    % Execute Solver
    [o, i, n, t] = solver(nc, blockWeight, ei, ef);
    % Accumulate outputs
    ncols = [ncols nc];
    nstates = [nstates i];
    noperators = [noperators n];
    times = [times t];
end

% Plot
fig = figure;
subplot(3,1,1), plot(ncols,nstates), ...
    xticks(ncols), ylabel("Gen. States"), title("Benchmark 1");
subplot(3,1,2), plot(ncols,noperators), ...
    xticks(ncols), ylabel("Operators");
subplot(3,1,3), plot(ncols,times), ...
    xticks(ncols), ylabel("Time [s]"), xlabel("Num. of Columns");
print(fig,'benchmark1','-dpng')


%% Benchmark 2
ncols = [3 4 5 6];
nstates = [9078 23855 23276 24169];
noperators = [32 20 16 16];
times = [178.8401 654.3292 635.7041 662.2644];

% % Warning: takes ~35min to execute
% ncols = [];
% nstates = [];
% noperators = [];
% times = [];
% [MaxColumns, blockWeight, ei, ef] = DomainParser('Benchmark2.txt');
% for nc = [3:6]
%     % Execute Solver
%     [o, i, n, t] = solver(nc, blockWeight, ei, ef);
%     % Accumulate outputs
%     ncols = [ncols nc];
%     nstates = [nstates i];
%     noperators = [noperators n];
%     times = [times t];
% end

% Plot
fig = figure;
subplot(3,1,1), plot(ncols,nstates), ...
    xticks(ncols), ylabel("Gen. States"), title("Benchmark 2");
subplot(3,1,2), plot(ncols,noperators), ...
    xticks(ncols), ylabel("Operators");
subplot(3,1,3), plot(ncols,times/60), ...
    xticks(ncols), ylabel("Time [min]"), xlabel("Num. of Columns");
print(fig,'benchmark2','-dpng')


%% Solver
function [output, ii, nn, tt] = solver(MaxColumns, blockWeight, ei, ef)
    % Solver function implements the Breadth-First Search algorithm for 
    % finding the shortest path from the final state to the initial state.
    
    % Initialisation
    tic;
    maxIter = 50000;
    Q = {{ef}};
    visitedStates = {ef};
    P = {{}};
    done = false;
    output_main = []; output_detail = []; output = "";
    iter = 1; ii = 0; nn = 0;
    
    % Check if Goal state is achieved
    if isequal(ef, ei)
        warning("Final state is the same of initial state")
        done = true;
    end
    
    while not(done) && not(isempty(Q)) && iter <= maxIter
        disp("Iteration: " + string(iter))
        prevStateSeq = Q{1};    
        prevState = prevStateSeq{1};
        Q = Q(2:end);
        prevPSeq = P{1};
        P = P(2:end);
        disp("Previous Actions: " + join(prevPSeq,','));
        disp("Current State: " + join(prevState,','));

        % Expand State: infere all feasible actions which may lead to the 
        % current state
        proposedActionDesc = [];
        for pred = prevState
            actions = inferaction(pred, prevState, blockWeight, MaxColumns);
            proposedActionDesc = [proposedActionDesc actions];
        end
        proposedActionDesc = unique(proposedActionDesc(proposedActionDesc > ""));
        disp("  Proposed Actions: " + join(proposedActionDesc,','));

        % Analise feasible actions 
        for actDesc = proposedActionDesc
            disp("    Analising: " + actDesc)
            [prec, add, del] = action(actDesc, prevState, blockWeight);

            % Apply regression function
            regoutput = arrayfun(@(p) regression(p, add, del), prevState);

            % Discard actions
            % Note that the heuristics used in infereaction function
            % reduces the discarded actions
            if ismember("FALSE", regoutput)
                continue
            else
                % Next state = Action Preconditions + Regression Function
                regoutput = regoutput(not(regoutput == "TRUE"));
                nextState = sort(unique([prec regoutput]));
                ii = ii + 1; 
                disp("      Next State: " + join(nextState,','));

                % Check if next state was previously generated
                if any(cellfun(@(s) isequal(nextState, s), visitedStates))
                    disp("        State already visited");
                    output_detail = [output_detail ...
                        join(nextState,',') ...
                        "repeated state" ...
                        "-------------"];
                    continue
                else
                    visitedStates = {visitedStates{:}, nextState};
                end

                % Add next State to the States queue
                nextStateSeq = [{nextState} prevStateSeq];
                Q = {Q{:} nextStateSeq};
                % Add Action to the plan queue
                nextPSeq = [actDesc prevPSeq];
                P = {P{:} nextPSeq};

                % Check if Goal state is achieved
                if isequal(nextState, ei)
                    disp("DONE!");
                    done = true;
                    break
                end
            end
        end
        iter = iter + 1;
    end
    if done
        nn = length(P{end});
        disp("Number of operators: " + string(nn))
        disp("Number of states generated: " + string(ii))
        if isempty(join(P{end},','))
            P = {["None"]};
            output_detail = "";
        end
        disp("Plan: " + join(P{end}, ','))
        output_main = [string(nn) string(ii) join(P{end}, ',') ...
            "-------------"];
    elseif isempty(Q)
        warning("Plan not found. There is no way to reach the Goal State")
        return
    elseif iter > maxIter
        warning("Max number of iterations reached!")
        return
    end
    
    % Output file content
    EOL = '\r\n';
    output = join(output_main, EOL) + EOL + join(output_detail, EOL);
    % Time
    tt = toc;
end

%% Functions
function [MaxColumns, Blocks, InitialState, GoalState] = DomainParser(fileName)
    % DomainParser function opens the filename and stores the 
    % relevant lines as variables.
    
    delimiter = ".";
    weightToken = "*";

    function strVal = parseValue(line)
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

    % Read file lines
    fid = fopen(fileName,'r');
    maxColLine = parseValue(fgetl(fid));
    blocksLine = parseValue(fgetl(fid));
    initialStateLine = parseValue(fgetl(fid));
    finalStateLine = parseValue(fgetl(fid));           
    fclose(fid);
    
    % Generate variables 
    MaxColumns = str2num(maxColLine);
    Blocks = parseBlocks(blocksLine);
    InitialState = parseState(initialStateLine);
    GoalState = parseState(finalStateLine);
    
end

function regout = regression(pred, add, del)
    % Regression function used in the non-linear planner with regression
    % Returns "TRUE" if the predicate is in the add section of the action,
    % "FALSE" if the predicate is in the delete section or the predicate
    % itself if none of the above conditions are met. 
    if ismember(pred, add)
        regout = "TRUE";
    elseif ismember(pred, del)
        regout = "FALSE";
    else
        regout = pred;
    end
end

function actions = inferaction(pred, state, blockWeight, MaxColumns)
    % Given a predicate of a state, the inferactions returns all feasible
    % actions that could generate the predicate or be compatible with it.
    % It implements the Domain Knowledge as a set of rules that are 
    % It can be seen as a enhanced regression function which uses the
    % context of the state
    loadconstants
    actions = [""];
    [name, args] = decompose(pred);
    switch name
        case ONTABLE
            % ONTABLE(X) + ARM available + Nothing ON X <= LEAVE(X) 
            checkEmptyArm = ~isempty(infereArm(blockWeight, state, args));
            checkOn = any(contains(state(contains(state, "ON(")), args(1) + ")"));
            if checkEmptyArm && not(checkOn)
                actions = compose(LEAVE, args);
            end
        case ON
            % ON(X,Y) + HEAVER(Y,X) + ARM available <= STACK(X,Y)
            % Avoid precondiction incompatibility:
            % ON(p,X) is incompatible with HOLDING(X,a)
            checkHeavier = isheavier(blockWeight,args(2), args(1));
            checkOn = not(any(contains(state(contains(state, "ON(")), args(1) + ")")));
            checkArm = not(isempty(infereArm(blockWeight,state,args(1))));
            if checkHeavier && checkOn && checkArm
                actions = compose(STACK, args);
            end
        case CLEAR
            %  CLEAR(Y) + HOLDING(X,L) + HEAVIER(Y,X) <= UNSTACK-LEFT(X,Y)
            %  CLEAR(Y) + HOLDING(X,R) + HEAVIER(Y,X) <= UNSTACK-RIGHT(X,Y)
            if not(any(contains(state, compose(HOLDING, [args RIGHTARM]))) ...
                    || any(contains(state, compose(HOLDING, [args LEFTARM]))))
                % If state contains HOLDING(Y,L) or HOLDING(Y,R) skip
                % (avoids stacking on arms)
                for p = state
                    [n, a] = decompose(p);
                    if n == HOLDING && not(a(1) == args) ...
                            && isheavier(blockWeight, args, a(1))
                        if a(2) == LEFTARM
                            actions = compose(UNSTACKLEFT, [a(1) args]);
                        elseif a(2) == RIGHTARM
                            actions = compose(UNSTACKRIGHT, [a(1) args]);
                        end
                    end
                end
            end
        case EMPTYARM
            %  EMPTYARM + CLEAR(X) + ON(X,Y) <= STACK(X,Y)
            %  EMPTYARM + CLEAR(X) + ON-TABLE(X) + ARM available <= LEAVE(X)
            clearArgs = [];
            for p = state
                [n, a] = decompose(p);
                if n == CLEAR
                    clearArgs = [clearArgs a];
                elseif n == ON ...
                        && ismember(a(1), clearArgs) ...
                        && args == infereArm(blockWeight, state, a(1))
                    actions = [actions compose(STACK, a)];
                elseif n == ONTABLE ...
                        && ismember(a, clearArgs) ...
                        && args == infereArm(blockWeight, state, a)
                    actions = [actions compose(LEAVE, a)];
                end
            end
        case HOLDING
            % HOLDING(X,L) + COLS available = PICK-UP-LEFT(X)
            % HOLDING(X,R) + COLS available = PICK-UP-RIGHT(X)
            iscolavailable = sum(count(state, ONTABLE)) < MaxColumns;
            if iscolavailable
                if args(2) == LEFTARM
                    actions = compose(PICKUPLEFT, args(1));
                elseif args(2) == RIGHTARM
                    actions = compose(PICKUPRIGHT, args(1));
                end
            end
            % Or if CLEAR(Y), could be from UNSTACK. 
            % That case in the CLEAR section
            
    end
    % disp(pred + " => " + join(actions,','));  % DEBUG
    
end

function inferedArm = infereArm(blockWeight, state, X)
    % Given a block and the state, the function returns what arm to be used
    % It checks if the there is arms available and the weight of the block.
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
    % Utility function to split the Predicate or Operator string into
    % 2 strings: Name and vector of arguments. 
    predElems = regexp(erase(predDesc, ')'), '\(|,', 'split');
    predString = cellfun(@(p) string(p), predElems);
    predName = predString(1);
    predArgs = predString(2:end);
end

function predDesc = compose(predName, predArgs)
    % Inverse of decompose function. Given the Name and the vector of 
    % arguments, it returns the string that defines the predicate/operator
    predDesc = predName + "(" + join(predArgs, ',') + ")";
end

function [precond, add, del] = action(actDesc, state, blockWeight)
    % Given the Action description it returns the preconditions, add and
    % delete predicates. It uses information about the State in order to
    % infere the arm that can do the operation.
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
            precond = [compose(ONTABLE, X) compose(EMPTYARM, LEFTARM) ...
                compose(CLEAR, X)];
            add = [compose(HOLDING, [X LEFTARM])];
            del = [compose(ONTABLE, X) compose(EMPTYARM, LEFTARM)];
        case PICKUPRIGHT
            precond = [compose(ONTABLE, X) compose(EMPTYARM, RIGHTARM) ...
                compose(CLEAR, X)];
            add = [compose(HOLDING, [X, RIGHTARM])];
            del = [compose(ONTABLE, X) compose(EMPTYARM, RIGHTARM)];
        case STACK
            precond = [compose(HOLDING, [X inferedArm]) compose(CLEAR, Y)];
            add = [compose(ON, [X Y]) compose(EMPTYARM, inferedArm)];
            del = [compose(HOLDING, [X inferedArm]) compose(CLEAR, Y)];
        case UNSTACKLEFT
            precond = [compose(ON, [X, Y]) compose(CLEAR, X) ...
                compose(EMPTYARM, LEFTARM)];
            add = [compose(HOLDING, [X, LEFTARM]) compose(CLEAR, Y)];
            del = [compose(ON, [X, Y]) compose(EMPTYARM, LEFTARM)];
        case UNSTACKRIGHT
            precond = [compose(ON, [X, Y]) compose(CLEAR, X) ...
                compose(EMPTYARM, RIGHTARM)];
            add = [compose(HOLDING, [X, RIGHTARM]) compose(CLEAR, Y)];
            del = [compose(ON, [X, Y]) compose(EMPTYARM, RIGHTARM)];
        case LEAVE
            precond = [compose(HOLDING, [X, inferedArm])];
            add = [compose(ONTABLE, X) compose(EMPTYARM, inferedArm)];
            del = [compose(HOLDING, [X, inferedArm])];
        otherwise
            error("Unknown action. Check the constants script")
    end
end

function check = isheavier(blockWeight,blockX,blockY)
    % Function that checks if the weight of Block X is greather or equal
    % to the Block Y.
    check = (blockWeight(char(blockX)) >= blockWeight(char(blockY)));
end

function check = islightblock(blockWeight,blockX)
    % Function that checks if the weight of Block X is equal to the maximum
    % light weight.
    loadconstants
    check = (blockWeight(char(blockX)) == MAXLIGHTWEIGHT);
end
