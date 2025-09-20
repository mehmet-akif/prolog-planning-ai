% Enter the names of your group members below.
% If you only have 2 group members, leave the last space blank
%
%%%%%
%%%%% NAME: Enes Polat
%%%%% NAME: Akif Sipahi
%%%%% NAME: Ekrem Yilmaz
%
% Add the required rules in the corresponding sections. 
% If you put the rules in the wrong sections, you will lose marks.
%
% You may add additional comments as you choose but DO NOT MODIFY the comment lines below
%

%%%%% SECTION: robocup_setup
%%%%%
%%%%% These lines allow you to write statements for a predicate that are not consecutive in your program
%%%%% Doing so enables the specification of an initial state in another file
%%%%% DO NOT MODIFY THE CODE IN THIS SECTION
:- dynamic hasBall/2.
:- dynamic robotLoc/4.
:- dynamic scored/1.

%%%%% This line loads the generic planner code from the file "planner.pl"
%%%%% Just ensure that that the planner.pl file is in the same directory as this one
:- [planner].

%%%%% SECTION: init_robocup
%%%%% Loads the initial state from either robocupInit1.pl or robocupInit2.pl
%%%%% Just leave whichever one uncommented that you want to test on
%%%%% NOTE, you can only uncomment one at a time
%%%%% HINT: You can create other files with other initial states to more easily test individual actions
%%%%%       To do so, just replace the line below with one loading in the file with your initial state
:- [robocupInit1].
%:- [robocupInit2].

%%%%% SECTION: goal_states_robocup
%%%%% Below we define different goal states, each with a different ID
%%%%% HINT: It may be useful to define "easier" goals when starting your program or when debugging
%%%%%       You can do so by adding more goal states below
%%%%% Goal XY should be read as goal Y for problem X

%% Goal states for robocupInit1
goal_state(11, S) :- robotLoc(r1, 0, 1, S).
goal_state(12, S) :- hasBall(r2, S).
goal_state(13, S) :- hasBall(r3, S).
goal_state(14, S) :- scored(S). 
goal_state(15, S) :- robotLoc(r1, 2, 2, S).
goal_state(16, S) :- robotLoc(r1, 3, 2, S).

%% Goal states for robocupInit1
goal_state(21, S) :- scored(S). 
goal_state(22, S) :- robotLoc(r1, 2, 4, S).

%%%%% SECTION: precondition_axioms_robocup
%%%%% Write precondition axioms for all actions in your domain. Recall that to avoid
%%%%% potential problems with negation in Prolog, you should not start bodies of your
%%%%% rules with negated predicates. Make sure that all variables in a predicate 
%%%%% are instantiated by constants before you apply negation to the predicate that 
%%%%% mentions these variables. 

% Checks if there is an opponent blocking in the same row
rowBlockedByOpponent(Row, Col1, Col2) :-
    Col1 < Col2,  % moving right
    opponentBetweenCol(Row, Col1, Col2).

rowBlockedByOpponent(Row, Col1, Col2) :-
    Col1 > Col2,  % moving left
    opponentBetweenCol(Row, Col2, Col1).

% Checks if there is an opponent blocking in the same column
colBlockedByOpponent(Col, Row1, Row2) :-
    Row1 < Row2,  % moving down
    opponentBetweenRow(Col, Row1, Row2).

colBlockedByOpponent(Col, Row1, Row2) :-
    Row1 > Row2,  % moving up
    opponentBetweenRow(Col, Row2, Row1).

% Checks if opponent exists between two columns (same row)
opponentBetweenCol(Row, StartCol, EndCol) :-
    opponentAt(Row, MidCol),
    StartCol < MidCol, MidCol =< EndCol.
    
% Checks if opponent exists between two rows (same column)
opponentBetweenRow(Col, StartRow, EndRow) :-
    opponentAt(MidRow, Col),
    StartRow < MidRow, MidRow =< EndRow.



%% PRECONDITIONS
% move up
poss(move(Robot, Row1, Col1, Row2, Col2), S) :-
    robot(Robot), 
    robotLoc(Robot, Row1, Col1, S), % robot starts at (Row1, Col)
    Row2 is Row1 - 1, % move up
    Col2 is Col1, % same col
    Row2 >= 0, % in bound
    not((robot(Robot2), not(Robot = Robot2), robotLoc(Robot2, Row2, Col2, S))), % no other robot on cell
    not(opponentAt(Row2, Col2)). % no opponent on cell

% move down
poss(move(Robot, Row1, Col1, Row2, Col2), S) :-
    robot(Robot), 
    robotLoc(Robot, Row1, Col1, S), % robot starts at (Row1, Col)
    Row2 is Row1 + 1, % move up
    Col2 is Col1, % same col
    numRows(MaxRows), Row2 < MaxRows, % in bound
    not((robot(Robot2), not(Robot = Robot2), robotLoc(Robot2, Row2, Col2, S))), % no other robot on cell
    not(opponentAt(Row2, Col2)). % no opponent on cell

% move left
poss(move(Robot, Row1, Col1, Row2, Col2), S) :-
    robot(Robot), 
    robotLoc(Robot, Row1, Col1, S), % robot starts at (Row, Col1)
    Col2 is Col1 - 1, % move left
    Row2 is Row1, % same col
    Col2 >= 0, % in bound
    not((robot(Robot2), not(Robot = Robot2), robotLoc(Robot2, Row2, Col2, S))), % no other robot on cell
    not(opponentAt(Row2, Col2)). % no opponent on cell

% move right
poss(move(Robot, Row1, Col1, Row2, Col2), S) :-
    robot(Robot), 
    robotLoc(Robot, Row1, Col1, S), % robot starts at (Row, Col1)
    Col2 is Col1 + 1, % move right
    Row2 is Row1, % same col
    numCols(MaxCols), Col2 < MaxCols, % in bound
    not((robot(Robot2), not(Robot = Robot2), robotLoc(Robot2, Row2, Col2, S))), % no other robot on cell
    not(opponentAt(Row2, Col2)). % no opponent on cell


% pass to teammate in same row
poss(pass(Robot1, Robot2), S) :-
    hasBall(Robot1, S), % robot1 has ball
    robot(Robot1), robot(Robot2), not(Robot1 = Robot2), % ensure distinct, valid players
    robotLoc(Robot1, Row, Col1, S), % location of robot1
    robotLoc(Robot2, Row, Col2, S), % location of robot2 (same row as robot1)
    not(Col1 = Col2), not(rowBlockedByOpponent(Row, Col1, Col2)). % opponent not inbetween robots


% pass to teammate in same col
poss(pass(Robot1, Robot2), S) :-
    hasBall(Robot1, S), % robot1 has ball
    robot(Robot1), robot(Robot2), not(Robot1 = Robot2), % ensure distinct, valid players
    robotLoc(Robot1, Row1, Col, S), % location of robot1
    robotLoc(Robot2, Row2, Col, S), % location of robot2 (same col as robot1)
    not(Row1 = Row2), not(colBlockedByOpponent(Col, Row1, Row2)). % opponent not inbetween robots


% robot shoots into net
poss(shoot(Robot), S) :-
    robot(Robot), hasBall(Robot, S), % robot has ball to shoot
    robotLoc(Robot, RobotRow, Col, S), % location of robot
    goalCol(Col), % robot in same col as goal to shot
    numRows(MaxRows), GoalRow is MaxRows - 1, % get row to check until
    not(colBlockedByOpponent(Col, RobotRow, GoalRow)).


%%%%% SECTION: successor_state_axioms_robocup
%%%%% Write successor-state axioms that characterize how the truth value of all 
%%%%% fluents change from the current situation S to the next situation [A | S]. 
%%%%% You will need two types of rules for each fluent: 
%%%%% 	(a) rules that characterize when a fluent becomes true in the next situation 
%%%%%	as a result of the last action, and
%%%%%	(b) rules that characterize when a fluent remains true in the next situation,
%%%%%	unless the most recent action changes it to false.
%%%%% When you write successor state axioms, you can sometimes start bodies of rules 
%%%%% with negation of a predicate, e.g., with negation of equality. This can help 
%%%%% to make them a bit more efficient.
%%%%%
%%%%% Write your successor state rules here: you have to write brief comments %

%% ROBOTLOC
% POSITIVE EFFECT: robot is at location given current situation 
robotLoc(Robot, Row2, Col2, [move(Robot, Row1, Col1, Row2, Col2) | S]). 
% PERSISTENCE EFFECT: robot remains at same location unless it moved to another place
robotLoc(Robot, Row2, Col2, [A | S]) :- 
    not(A = move(Robot, Row2, Col2, Row1, Col1)), 
    robotLoc(Robot, Row2, Col2, S). % robot was already at this location/doesn't move


%% HASBALL
% POSITIVE EFFECT: robot has ball from pass
hasBall(Robot2, [pass(_, Robot2) | S]). 

% PERSISTENCE EFFECT: robot has ball as long as it doesn't pass after receiving it
hasBall(Robot, [A | S]) :-
    not(A = pass(Robot, _)),  
    hasBall(Robot, S). 


%% SCORED
% POSITIVE EFFECT: goal scored if a robot shoots in the current situation
scored([shoot(Robot) | S]).

% PERSISTENCE EFFECT: goal remains scored 
scored([A | S]) :-
    scored(S).  % once a goal is scored, it is true


%%%%% SECTION: declarative_heuristics_robocup
%%%%% The predicate useless(A,ListOfPastActions) is true if an action A is useless
%%%%% given the list of previously performed actions. The predicate useless(A,ListOfPastActions)
%%%%% helps to solve the planning problem by providing declarative heuristics to 
%%%%% the planner. If this predicate is correctly defined using a few rules, then it 
%%%%% helps to speed-up the search that your program is doing to find a list of actions
%%%%% that solves a planning problem. Write as many rules that define this predicate
%%%%% as you can: think about useless repetitions you would like to avoid, and about 
%%%%% order of execution (i.e., use common sense properties of the application domain). 
%%%%% Your rules have to be general enough to be applicable to any problem in your domain,
%%%%% in other words, they have to help in solving a planning problem for any instance
%%%%% (i.e., any initial and goal states).
%%%%%	
%%%%% write your rules implementing the predicate  useless(Action,History) here. %


% Avoid having symmetrics passes (R1 pass to R2, then R2 pass to R1) 
useless(pass(Robot1, Robot2), [pass(Robot2, Robot1) | _]). 

% Avoid passing the ball to the robot with the ball
useless(pass(Robot, Robot), _) :- hasBall(Robot, _).

% Avoid passing the ball when it's possible to shoot
useless(pass(RobotHasBall, Robot2), S) :-
    hasBall(RobotHasBall, S),
    robotLoc(RobotHasBall, RobotRow, Col, S),
    goalCol(Col),
    numRows(MaxRows), GoalRow is MaxRows - 1,
    not(colBlockedByOpponent(Col, RobotRow, GoalRow)).

% Avoid moving when it's possible to shoot
useless(move(RobotHasBall, RobotRow, Col, Row2, Col2), S) :-
    hasBall(RobotHasBall, S),
    robotLoc(RobotHasBall, RobotRow, Col, S),
    goalCol(Col),
    numRows(MaxRows), GoalRow is MaxRows - 1,
    not(colBlockedByOpponent(Col, RobotRow, GoalRow)).

% Avoid moving back to the same spot
useless(move(Robot, Row1, Col1, Row2, Col2), [move(Robot, Row2, Col2, Row1, Col1) | _]).

% Avoid passing to a robot in the same spot
useless(pass(Robot1, Robot2), [move(Robot2, Row, Col, Row, Col) | _]) :- robotLoc(Robot2, Row, Col, _).

% Avoid passing to robot with the ball (pass to itself)
useless(pass(Robot1, Robot2), S) :- hasBall(Robot1, S), Robot1 = Robot2.

% Avoid moving if the previous action was robot1 passing the ball
useless(move(Robot, Row1, Col1, Row2, Col2), [pass(Robot, _) | _]).

