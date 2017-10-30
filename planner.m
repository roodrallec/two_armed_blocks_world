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

            while length(obj.statesLeft(tree)) > 0
                states = obj.statesLeft(tree);                
                state = states(1);                
                children = obj.applyOperators(state);                
                tree = [tree, children];

                if ismember(initialState.toString(), arrayfun(@(c) c.toString(), children))
                    finished = true;
                    plan = tree;
                end                
            end

            if finished == false
                error('No way could be found to reach Ei from Ef');
            end
        end        

        function states = statesLeft(obj, tree)
            states = tree(arrayfun(@(c) ~c.expanded, tree));
        end

        function children = applyOperators(obj, state)
            % build the possible children states.
            % this consists of a valid operators preconditions
            % plus any conditions returned from the regression function            
            children = [];
            for o = 1:length(obj.operators)
                operator = obj.operators(o);
                [accepted, conditions] = obj.regression(operator, state.predicates);

                if (accepted)
                    % Create a new child state with the preConditions and regression
                    % conditions
                    newState = State([operator.preConditions, conditions]);
                    disp(operator.label + " ==> " + newState.toString());
                    children = [children, newState];
                end                
            end
            state.expanded = true;
        end

        function [accepted, conditions] = regression(obj, operator, predicates)
            accepted = true;
            % check if predicates in operator delete block
            if (any(ismember([predicates.string], [operator.del.string])))
                accepted = false;
            end
            conditions = setdiff(predicates, operator.add);
        end
    end
end
