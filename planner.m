classdef Planner
    %PLANNER Implementation of a Non-linear planner with regression
    %   Given an inital state and final state the planner builds a graph of
    %   goal states linked with operators, which can then be traversed with a
    %   search algorithm.
    
    properties
        initialState
        finalState        
        finished
    end
    
    methods
        function obj = Planner(initialState, finalState)
            %Planner 
            %   Builds a plan from the initial to final state using goal
            %   regression
            obj.initialState = initialState;
            obj.finalState = finalState;            
        end
        
        function plan = buildPlan(obj, operators)
            obj.finished = false;            
            tree = {obj.finalState};
            
            while obj.statesLeft(tree) > 0
                state = obj.nextState(tree);
                children = obj.applyOperators(state, operators);
                tree{length(tree) + 1} = children;
                
                if containsState(obj.initialState, children)
                    obj.finished = true;
                    plan = buildPath(obj.initialState, obj.finalState, tree);
                end    
                    
            end
            
            if obj.finished == false
                error('No way could be found to reach Ei from Ef');
            end          
        end
        
        function leftCount = statesLeft(obj, tree)
            % return true if unexpanded states
            leftCount = tree(cellfun(@(c) ~c.expanded, tree));
            leftCount = length(leftCount);
        end
        
        function state = nextState(obj, tree)
            states = tree(cellfun(@(c) ~c.expanded, tree));
            state = states{1};
        end
        
        function children = applyOperators(obj, state, operators)
            children = arrayfun(@(op) obj.applyOperator(op, state), operators);
        end
        
        function modState = applyOperator(obj, op, state)
            modState = true;
            newPredicates = arrayfun(...
                @(pred) obj.regression(op, pred), state.predicates,...
                'UniformOutput', false...
            );
            % add operator preconditions to predicates
            % apply domain knowledge
        end
        
        function conditionAccepted = regression(obj, operator, condition)             
            % 1 check if condition is in operator add            
            if (ismember(condition, operator.add))
                conditionAccepted = true;
            % 2 check that state does not have operator delete conditions
            elseif (ismember(condition, operator.del))
                conditionAccepted = false;
            % 3 return the conditions in the state that are untouched
            else
                conditionAccepted = condition;
            end            
        end
        
        function bool = containsState(state, children)
            bool = cellfun(@(c) state.isequal(c), children);
        end
    end
end
 
