clc; clear all;
ARMS = ["L", "R"];
BLOCKS = ["A", "B", "C", "D", "F"];

operators = [];
for a = 1:length(ARMS)
    arm = ARMS(a);
    for b1 = 1:length(BLOCKS)
        block1 = BLOCKS(b1);
        for b2 = 1:length(BLOCKS)
            block2 = BLOCKS(b2);
            if (block2 == block1)
              continue;
            end
            %% PickupOperator
            pickupOperator = {};
            pickupOperator.label = "pickup " + block1 + " with " + arm;
            pickupOperator.pre = predToMat("ON-TABLE", "Block1", block1)...
                               + predToMat("EMPTY-ARM", "Arm", arm)...
                               + predToMat("CLEAR", "Block1", block1);

            pickupOperator.add = predToMat("HOLDING", "Block1", block1)...
                               + predToMat("HOLDING", "Arm", arm);

            pickupOperator.del = predToMat("ON-TABLE", "Block1", block1)...
                               + predToMat("EMPTY-ARM", "Arm", arm);
            %% StackOperator
            stackOperator = {};
            stackOperator.label = "stack " + block1 + " on " + block2 + " with " + arm;
            stackOperator.pre = predToMat("HOLDING", "Block1", block1)...
                               + predToMat("HOLDING", "Arm", arm)...
                               + predToMat("CLEAR", "Block2", block2);

            stackOperator.add = predToMat("ON", "Block1", block1)...
                              + predToMat("ON", "Block2", block2)...
                              + predToMat("EMPTY-ARM", "Arm", arm);

            stackOperator.del = predToMat("HOLDING", "Block1", block1)...
                              + predToMat("HOLDING", "Arm", arm)...
                              + predToMat("CLEAR", "Block2", block2);
            %% Un-Stack Operator
            unStackOperator = {};
            unStackOperator.label = "unStack " + block1 + " from " + block2 + " with " + arm;
            unStackOperator.pre = predToMat("ON", "Block1", block1)...
                                + predToMat("ON", "Block2", block2)...
                                + predToMat("CLEAR", "Block1", block1)...
                                + predToMat("EMPTY-ARM", "Arm", arm);

            unStackOperator.add = predToMat("HOLDING", "Block1", block1)...
                                + predToMat("HOLDING", "Arm", arm)...
                                + predToMat("CLEAR", "Block2", block2);

            unStackOperator.del = predToMat("ON", "Block1", block1)...
                                + predToMat("ON", "Block2", block2)...
                                + predToMat("EMPTY-ARM", "Arm", arm);
            %% Leave
            leaveOperator = {};
            leaveOperator.label = "leave " + block1 + " with " + arm;
            leaveOperator.pre = predToMat("HOLDING", "Block1", block1)...
                              + predToMat("HOLDING", "Arm", arm);

            leaveOperator.add = predToMat("ON-TABLE", "Block1", block1)...
                              + predToMat("EMPTY-ARM", "Arm", arm);

            leaveOperator.del = predToMat("HOLDING", "Block1", block1)...
                              + predToMat("HOLDING", "Arm", arm);
            %% Join operators
            operators = [operators, pickupOperator, stackOperator, unStackOperator, leaveOperator];
        end
    end
end

uniqueOperators = operators(1);
for idx=1:length(operators)
  operator = operators(idx);
  if ismember([operator.label], [uniqueOperators.label])
    continue;
  else
    uniqueOperators = [uniqueOperators, operator];
  end
end

InitialState = predToMat("ON-TABLE", "Block1", "C")
             + predToMat("ON", "Block1", "B")
             + predToMat("ON", "Block2", "C")
             + predToMat("ON", "Block1", "A")
             + predToMat("ON", "Block2", "B")
             + predToMat("CLEAR", "Block1", "A")
             + predToMat("ON-TABLE", "Block1", "D")
             + predToMat("ON", "Block1", "F")
             + predToMat("ON", "Block2", "D")
             + predToMat("CLEAR", "Block1", "F")
             + predToMat("EMPTY-ARM", "Arm", "L")
             + predToMat("EMPTY-ARM", "Arm", "R");

GoalState = predToMat("ON-TABLE", "Block1", "B")
          + predToMat("ON", "Block1", "C")
          + predToMat("ON", "Block2", "B")
          + predToMat("CLEAR", "Block1", "C")
          + predToMat("ON-TABLE", "Block1", "D")
          + predToMat("ON", "Block1", "A")
          + predToMat("ON", "Block2", "D")
          + predToMat("ON", "Block1", "F")
          + predToMat("ON", "Block2", "A")
          + predToMat("CLEAR", "Block1", "F")
          + predToMat("EMPTY-ARM", "Arm", "L")
          + predToMat("EMPTY-ARM", "Arm", "R");

state = GoalState;
finished = false;
iteration = 0;
children = {};

while (finished == false)
  disp("Level iteration:")
  disp(iteration);

  for op_id = 1:length(operators)
    operator = operators(op_id);
    disp(operator.label);

    if ((state + operator.del) > 1)
      continue;
    end
    state = state + operator.pre;
    state = state > 0;
    difference = state - InitialState;
    disp("Difference:")
    disp(sum(difference(:)));

    if (state == InitialState)
      disp("Complete");
      finished = true;
    end
    children = [children, state];
  end
  state = children{1};
  children(1) = [];
  iteration = iteration + 1;
  pause(1);
end

function matrix = predToMat(label, arg, value)
  PREDS = [ "ON-TABLE", "ON", "CLEAR", "EMPTY-ARM", "HOLDING"];
  ARGS = [ "Arm", "Block1", "Block2", "Column"];
  VALS = ["L", "R", "A", "B", "C", "D", "F"];
  matrix = zeros(length(PREDS), length(ARGS), length(VALS));
  p_idx = find(strcmp(PREDS, label));
  a_idx = find(strcmp(ARGS, arg));
  v_idx = find(strcmp(VALS, value));
  matrix(p_idx,a_idx,v_idx) = 1;
end
