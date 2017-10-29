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
                pickupOperator = BlockOperator("PICK-UP", arm, block1, "", c);
                % The relevant preconditions added
                pickupOperator.addPre(Predicate("ON-TABLE", block1));
                pickupOperator.addPre(Predicate("CLEAR", block1));
                pickupOperator.addPre(Predicate("EMPTY-ARM", arm));
                pickupOperator.addPre(Predicate("USED-COLS-NUM", c));
                % Weak arm rule check
                if (arm == weakArm)
                    pickupOperator.addPre(Predicate("LIGHT-BLOCK", block1));
                end
                % The relevent add conditions added
                pickupOperator.addAdd(Predicate("HOLDING", [block1, arm]));
                pickupOperator.addAdd(Predicate("USED-COLS-NUM", c-1));
                % The relevant del conditions added
                pickupOperator.addDel(Predicate("ON-TABLE", block1));
                pickupOperator.addDel(Predicate("CLEAR", block1));
                pickupOperator.addDel(Predicate("EMPTY-ARM", arm));
                % Once the operator is build its added to the Operators array
                operators = [operators, pickupOperator];
                %% "LEAVE" operators are built
                % Here rule 2 is applied to ensure the max col limit
                if (c == maxCols)
                    continue
                end
                leaveOperator = BlockOperator("LEAVE", arm, block1, "", c+1);
                % The relevant preconditions added
                leaveOperator.addPre(Predicate("HOLDING", [block1, arm]));
                leaveOperator.addPre(Predicate("USED-COLS-NUM", c));
                % The relevent add conditions added
                leaveOperator.addAdd(Predicate("ON-TABLE", block1));
                leaveOperator.addAdd(Predicate("EMPTY-ARM", arm));
                leaveOperator.addAdd(Predicate("USED-COLS-NUM", c+1));
                leaveOperator.addAdd(Predicate("CLEAR", block1));
                % The relevant del conditions added
                leaveOperator.addDel(Predicate("HOLDING", [block1, arm]));
                % Once the operator is build its added to the Operators array
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
                stackOperator = BlockOperator("STACK", arm, block1, block2, []);
                % The relevant preconditions added
                stackOperator.addPre(Predicate("HOLDING", [block1, arm]));
                stackOperator.addPre(Predicate("CLEAR", block2));
                stackOperator.addPre(Predicate("HEAVIER", {block2, block1}));
                % The relevent add conditions added
                stackOperator.addAdd(Predicate("ON", {block1, block2}));
                stackOperator.addAdd(Predicate("EMPTY-ARM", arm));
                stackOperator.addAdd(Predicate("CLEAR", block1));
                % The relevant del conditions added
                stackOperator.addDel(Predicate("HOLDING", [block1, arm]));
                stackOperator.addDel(Predicate("CLEAR", block2));
                % Once the operator is build its added to the Operators array
                operators = [operators, stackOperator];
                %% Here the "UN-STACK" operators are built
                unStackOperator = BlockOperator("UN-STACK", arm, block1, block2, []);
                % The relevant preconditions added
                unStackOperator.addPre(Predicate("ON", {block1, block2}));
                unStackOperator.addPre(Predicate("CLEAR", block1));
                unStackOperator.addPre(Predicate("EMPTY-ARM", arm));
                % Weak arm rule check
                if (arm == weakArm)
                    unStackOperator.addPre(Predicate("LIGHT-BLOCK", block1));
                end
                % The relevent add conditions added
                unStackOperator.addAdd(Predicate("HOLDING", [block1, arm]));
                unStackOperator.addAdd(Predicate("CLEAR", block2));
                % The relevant del conditions added
                unStackOperator.addDel(Predicate("ON", {block1, block2}));
                unStackOperator.addDel(Predicate("EMPTY-ARM", arm));
                unStackOperator.addDel(Predicate("CLEAR", block1));
                % Once the operator is build its added to the Operators array
                operators = [operators, unStackOperator];
            end
        end
    end
end
