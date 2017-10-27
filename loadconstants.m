%% Predicate Names
ONTABLE = "ON-TABLE";
ON = "ON";
CLEAR = "CLEAR";
EMPTYARM = "EMPTY-ARM";
HOLDING = "HOLDING";
USEDCOLSNUM = "USED-COLS-NUM";
HEAVIER = "HEAVIER";
LIGHTBLOCK = "LIGHT-BLOCK";

%% Operator Names
PICKUPLEFT = "PICK-UP-LEFT";    % with arm left, pickup block X
PICKUPRIGHT = "PICK-UP-RIGHT";  % with arm right, pickup block X
%STACKLEFT = "STACK-LEFT";       % with arm left, stack block X, on block Y
%STACKRIGHT = "STACK-RIGHT";     % with arm right, stack block X, on block Y
STACK = "STACK";
UNSTACKLEFT = "UNSTACK-LEFT";   % with arm left, un-stack block X, from block Y
UNSTACKRIGHT = "UNSTACK-RIGHT"; % with arm right, un-stack block X, from block Y
%LEAVELEFT = "LEAVE-LEFT";       % with arm left, leave block X on the table
%LEAVERIGHT = "LEAVE-RIGHT";     % with arm right, leave block X on the table
LEAVE = "LEAVE";

%OPERATORLIST = [PICKUPLEFT PICKUPRIGHT STACKLEFT STACKRIGHT UNSTACKLEFT ...
%    UNSTACKRIGHT LEAVELEFT LEAVERIGHT];

OPERATORLIST = [PICKUPLEFT PICKUPRIGHT STACK UNSTACKLEFT ...
    UNSTACKRIGHT LEAVE];


%% Parameters
LEFTARM = "L";
RIGHTARM = "R";
MAXLIGHTWEIGHT = 1;
