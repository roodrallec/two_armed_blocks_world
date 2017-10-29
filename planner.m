classdef Planner
    % PLANNER Implementation of a Non-linear planner with regression
    %   Given an inital state and final state the planner builds a graph of
    %   goal states linked with operators, which can then be traversed with a
    %   search algorithm.
    properties
        operators
    end

    methods
        function obj = Planner(operators)
            % Planner
            %   Builds a plan from the initial to final state using goal
            %   regression with the provided opereators
            obj.operators = operators;
        end

        function plan = buildPlan(obj, initialState, finalState)
            finished = false;
            tree = [finalState];

            while obj.statesLeft(tree) > 0
                state = obj.nextState(tree);
                children = obj.applyOperators(state);
                tree = [tree, children];

                if ismember(initialState, children)
                    finished = true;
                    plan = tree;
                end
            end

            if finished == false
                error('No way could be found to reach Ei from Ef');
            end
        end

        function leftCount = statesLeft(obj, tree)
            % return true if unexpanded states
            leftCount = tree(arrayfun(@(c) ~c.expanded, tree));
            leftCount = length(leftCount);
        end

        function state = nextState(obj, tree)
            states = tree(arrayfun(@(c) ~c.expanded, tree));
            state = states(1);
        end

        function children = applyOperators(obj, state)
            % build the possible children states.
            children = [];
            for o = 1:length(obj.operators)
                operator = obj.operators(o);
                newPredicates = [operator.preConditions];

                for p = 1:length(state.predicates)
                    condition = state.predicates(p);
                    regression = obj.regression(operator, condition);

                    if (class(regression) == "logical" && regression == false)
                        continue
                    end

                    if (class(condition) == "Predicate")
                        newPredicates = [newPredicates, condition];
                    end
                end

                if (class(regression) == "logical" && regression == false)
                    continue
                end

                children = [children, State(newPredicates)];
            end
            state.expanded = true;
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
    end
end
