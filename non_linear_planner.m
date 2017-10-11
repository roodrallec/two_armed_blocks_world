% NON-LINEAR PLANNER WITH GOAL REGRESSION

% Input params
% MaxColumns=3;
% Blocks=A*,B**,C**,D***, F*;
% InitialState=ON-TABLE(C),ON(B,C),ON(A,B),CLEAR(A);ON-TABLE(D),ON(F,D)
% CLEAR(D),EMPTY-ARM(L),EMPTY-ARM(R);
% GoalState=ON-TABLE(B),ON(C,B),CLEAR(C),ON-TABLE(D),ON(A,D),ON(F,A),CLEAR(R),
% EMTPY-ARM(L),EMTPY-ARM(R);

% Output params
% nn // number of operators of the plan
% ii // number of states generated to solve the problem
% op1, op2, op3, ? // plan defined as a sequence of operators from initial to final state
% -------------
% // details of the states that were cancelled (not continued) reason with format:
% p1,p2,p3 ? //predicates that define the state
% repeated state, contradictory predicates,  ? // reason for cancelling the exploration
% ------------- //a line will separate each state

% Predicates
% On-table(x): x is placed on the table
% On(x,y): x is placed on y
% Clear(x): x does not have any object on it
% Empty-arm(a): the robotic arm a is not holding any object
% Holding(x,a): the object x is being held by the robotic arm a
% Used-cols-num(n): n block columns are being used
% Heavier(x,y): the object x weights more or the same than y
% Light-block(x): the weight of the object x is 1 kg

% NLP (initial-state, goals)
% ? state = initial-state; plan = []; goalset = goals; opstack = []
% ? Repeat until goalset is empty
% ? Choose a goal g from the goalset
% ? If g does not match state, then
% ? Choose an operator o whose add-list matches goal g
% ? Push o on the opstack
% ? Add the preconditions of o to the goalset
% ? While all preconditions of operator on top of opstack
% are met in state
% ? Pop operator o from top of opstack
% ? state = apply(o, state)
% ? plan = [plan; o]
function plan = non_linear_planner(initial_state, goal_state, operators)
    plan = [];
    remaining_goals = initial_state(~ismember(initial_state, goal_state));
    
    while (all(remaining_goals))
        goal = pickGoal(remaining_goals());
        operator = operators(ismember(operator.add, goal));
        remaining_goals = [remaining_goals, operator.preconditions];
        inital_state = [initial_state, apply(operator, inital_state)];
        plan = [plan, operator];
    end
    