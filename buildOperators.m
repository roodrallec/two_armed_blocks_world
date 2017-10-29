function operators = buildOperators(arms, blocks, maxCols, weakArm)
    %% BUILD DOMAIN OPERATORS:
    % Operators:
    % "PICK-UP", A, X
    % "LEAVE", A, X, C
    % "STACK", A, X, Y
    % "UNSTACK", A, X, Y, C
    %% POSSIBLE PREDICATES
    % ON-TABLE(domain.blocksMap.label)
    % ON(domain.blocksMap.label, domain.blocksMap.label)
    % CLEAR(domain.blocksMap.label)
    % EMPTY-ARM(arms)
    % HOLDING(domain.blocksMap.label, arms)
    % USED-COLS-NUM(range(1..maxCols))
    % HEAVIER(domain.blocksMap.label, domain.blocksMap.label)
    % LIGHT-BLOCK(domain.blocksMap.label)
    operators = [];
    for a = 1:length(arms)
        % Every operator must use an arm and therefore every arm iteration
        % generates an operator variation
        arm = arms{a};
        for b1 = 1:length(blocks)
            % Every operator must operate on a first block
            % so an opeartor is build for each arm block combination
            block1 = blocks(b1).label;
            for c = 1:maxCols
                % Some operators depend on the columns too, we apply
                % those conditions here
                %% "PICK-UP" operators are built
                % The relevant preconditions added
                % Weak arm rule check
                % The relevent add conditions added
                % The relevant del conditions added
                % The operator is built and is added to the Operators array
                pickupOperator = BlockOperator("PICK-UP", arm, block1, "", c);
                pickupOperator.preConditions = [Predicate("ON-TABLE", block1), Predicate("CLEAR", block1), Predicate("EMPTY-ARM", arm), Predicate("USED-COLS-NUM", c)];
                if (arm == weakArm)
                    pickupOperator.preConditions = [pickupOperator.preConditions, Predicate("LIGHT-BLOCK", block1)];
                end
                pickupOperator.add = [Predicate("HOLDING", [block1, arm]), Predicate("USED-COLS-NUM", c-1)];
                pickupOperator.del = [Predicate("ON-TABLE", block1), Predicate("CLEAR", block1), Predicate("EMPTY-ARM", arm)];
                operators = [operators, pickupOperator];
                %% "LEAVE" operators are built
                % Here rule 2 is applied to ensure the max col limit
                % The relevant preconditions added
                % The relevent add conditions added
                % The relevant del conditions added
                % Once the operator is built it's added to the Operators array
                if (c == maxCols)
                    continue
                end
                leaveOperator = BlockOperator("LEAVE", arm, block1, "", c+1);
                leaveOperator.preConditions = [Predicate("HOLDING", [block1, arm]), Predicate("USED-COLS-NUM", c)];
                leaveOperator.add = [Predicate("ON-TABLE", block1), Predicate("EMPTY-ARM", arm), Predicate("USED-COLS-NUM", c+1), Predicate("CLEAR", block1)];
                leaveOperator.del = [Predicate("HOLDING", [block1, arm])];
                operators = [operators, leaveOperator];
            end

            for b2 = 1:length(blocks)
                % Some operators operate on a second block, build those here
                block2 = blocks(b2).label;
                % Ignore operations of the same block
                if block1 == block2
                    continue
                end
                %% Here the "STACK" operators are built
                % The relevant preconditions added
                % The relevent add conditions added
                % The relevant del conditions added
                % Once the operator is build its added to the Operators array
                stackOperator = BlockOperator("STACK", arm, block1, block2, "");
                stackOperator.preConditions = [Predicate("HOLDING", [block1, arm]), Predicate("CLEAR", block2), Predicate("HEAVIER", {block2, block1})];
                stackOperator.add = [Predicate("ON", {block1, block2}), Predicate("EMPTY-ARM", arm), Predicate("CLEAR", block1)];
                stackOperator.del = [Predicate("HOLDING", [block1, arm]), Predicate("CLEAR", block2)];
                operators = [operators, stackOperator];
                %% Here the "UN-STACK" operators are built
                % The relevant preconditions added
                % Weak arm rule check
                % The relevent add conditions added
                % The relevant del conditions added
                % Once the operator is build its added to the Operators array
                unStackOperator = BlockOperator("UN-STACK", arm, block1, block2, "");
                unStackOperator.preConditions = [Predicate("ON", {block1, block2}), Predicate("CLEAR", block1), Predicate("EMPTY-ARM", arm)];
                if (arm == weakArm)
                    unStackOperator.preConditions = [unStackOperator.preConditions, Predicate("LIGHT-BLOCK", block1)];
                end
                unStackOperator.add = [Predicate("HOLDING", [block1, arm]), Predicate("CLEAR", block2)];
                unStackOperator.del = [Predicate("ON", {block1, block2}), Predicate("EMPTY-ARM", arm), Predicate("CLEAR", block1)];
                operators = [operators, unStackOperator];
            end
        end
    end
end
