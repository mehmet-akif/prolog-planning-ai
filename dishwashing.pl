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

%%%%% SECTION: dishwashing_setup
%%%%%
%%%%% These lines allow you to write statements for a predicate that are not consecutive in your program
%%%%% Doing so enables the specification of an initial state in another file
%%%%% DO NOT MODIFY THE CODE IN THIS SECTION
:- dynamic holding/2.
:- dynamic numHolding/2.
:- dynamic faucetOn/1.
:- dynamic loc/3.
:- dynamic wet/2.
:- dynamic dirty/2.
:- dynamic soapy/2.
:- dynamic plate/1.
:- dynamic glassware/1.

%%%%% This line loads the generic planner code from the file "planner.pl"
%%%%% Just ensure that that the planner.pl file is in the same directory as this one
:- [planner].

%%%%% SECTION: init_dishwashing
%%%%% Loads the initial state from either dishwashingInit1.pl or dishwashingInit2.pl
%%%%% Just leave whichever one uncommented that you want to test on
%%%%% NOTE, you can only uncomment one at a time
%%%%% HINT: You can create other files with other initial states to more easily test individual actions
%%%%%       To do so, just replace the line below with one loading in the file with your initial state
:- [dishwashingInit1].
%:- [dishwashingInit2].
%:- [dishwashingInit3].

%%%%% SECTION: goal_states_dishwashing
%%%%% Below we define different goal states, each with a different ID
%%%%% HINT: It may be useful to define "easier" goals when starting your program or when debugging
%%%%%       You can do so by adding more goal states below

%% Goal states for dishwashingInit1
goal_state(11, S) :- holding(brush, S), soapy(brush, S).
goal_state(12, S) :- loc(brush, dish_rack, S), loc(sponge, counter, S).
goal_state(13, S) :- not dirty(g1, S), not soapy(g1, S).
goal_state(14, S) :- not dirty(g1, S), not soapy(g1, S), loc(g1, dish_rack, S), not faucetOn(S). 
goal_state(15, S) :- not dirty(g1, S), not soapy(g1, S), loc(g1, dish_rack, S), not soapy(brush, S),
                        loc(brush, dish_rack, S), not faucetOn(S). 

%% Goal states for dishwashingInit2
goal_state(21, S) :- not dirty(p1, S), not soapy(p1, S). 
goal_state(22, S) :- not dirty(p1, S), not soapy(p1, S), loc(p1, dish_rack, S), 
                        not dirty(p2, S), not soapy(p2, S), loc(p2, dish_rack, S).  

%% Goal states for dishwashingInit3
goal_state(31, S) :- not dirty(p1, S), not soapy(p1, S), not dirty(g1, S), not soapy(g1, S),
                        loc(p1, dish_rack, S), loc(g1, dish_rack, S).

%%%%% SECTION: aux_dishwashing
%%%%% Add any additional helpers here, including any additional rules needed for the auxiliary predicates
%%%%% DO NOT MODIFY THE CODE IN THIS SECTION
place(counter).
place(dish_rack).

scrubber(sponge).
scrubber(brush).

dish(X) :- glassware(X).
dish(X) :- plate(X).

item(X) :- glassware(X).
item(X) :- plate(X).
item(X) :- scrubber(X).

%%%%% SECTION: precondition_axioms_dishwashing
%%%%% Write precondition axioms for all actions in your domain. Recall that to avoid
%%%%% potential problems with negation in Prolog, you should not start bodies of your
%%%%% rules with negated predicates. Make sure that all variables in a predicate 
%%%%% are instantiated by constants before you apply negation to the predicate that 
%%%%% mentions these variables. 

poss(pickUp(X,P),S) :- item(X), place(P), loc(X,P,S), numHolding(C,S), C < 2.

poss(putDown(X,P),S) :- item(X), holding(X,S), place(P).

poss(turnOnFaucet,S) :- numHolding(C,S), C < 2.

poss(turnOffFaucet,S) :- numHolding(C,S), C < 2.

poss(addSoap(X),S) :- scrubber(X), holding(X,S), numHolding(C,S), C < 2.

poss(scrub(X,Y),S) :- glassware(X), scrubber(Y), Y = brush, holding(X,S), holding(Y,S).
poss(scrub(X,Y),S) :- plate(X), scrubber(Y), Y = sponge, holding(X,S), holding(Y,S).

poss(rinse(X),S) :- item(X), holding(X,S), faucetOn(S).


%%%%% SECTION: successor_state_axioms_dishwashing
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

holding(X,[A | S]) :- A = pickUp(X,P), loc(X,P,S). %rule (a) Holding X in situation [A | S] is true if the most recent action A involves picking up X from place P if it was located in place P in previous situation S
holding(X,[A | S]) :- not A = putDown(X,P), holding(X,S). %rule (b) Holding X in situation [A | S] is true unless the most recent action A involves putting it down in place P. Otherwise if it was held in previous situation S you are still holding it now.

numHolding(C,[A | S]) :- A = pickUp(X, P), numHolding(C1, S), C is C1 + 1, %rule (a) Holding C items in situtation [A | S] if the most recent action A involves picking up some item X from place P that you previously were not holding in situation S where you are now holding 1 additional item than you were in situation S that is now fewer than 2
C =< 2, not holding(X, S).
numHolding(C,[A | S]) :- A = putDown(X, P), numHolding(C1, S), C is C1 - 1,   %rule (a) Holding C items in situtation [A | S] if the most recent action A involves putting down some item X in place P that you previously were holding in situation S where you are now holding 1 fewer items than you were in situation S that is now no less than 0
C >= 0, holding(X, S).
numHolding(C,[A | S]) :- not A = pickUp(X, P), not A = putDown(X, P), numHolding(C, S). %rule (b)  Holding C items in situtation [A | S] unless the most recent action A involves picking up some item X from place P or putting down item X in place P. Otherwise you would be holding the same number of items as you were in situation S

faucetOn([A | S]) :- A = turnOnFaucet. %rule (a) faucet is on in situation [A | S] if most recent action A is turning it on
faucetOn([A | S]) :- not A = turnOffFaucet, faucetOn(S). %rule (b) faucet is on in situation [A | S] unless most recent action A is turning it off. Otherwise it would still be on if it was on previous situation S

loc(X, P, [A | S]) :- A = putDown(X,P). %rule (a) item X is located in place P in situation [A | S] if most recent action is putting it down in place P
loc(X, P, [A | S]) :- not A = pickUp(X,P), loc(X,P,S). %rule (b) item X is located in place P in situation [A | S] unless most recent action A involves picking it up from place P. Otherwise it would still be located in the same place that it was in situation S

wet(X, [A | S]) :- A = rinse(X). %rule (a) X is wet in situation [A | S] if most recent action A involes rinsing X
wet(X, [A | S]) :- not (A = putDown(X,P), place(P), P = dish_rack), wet(X,S). %rule (b) X is wet in situation [A | S] unless recent action A involves putting it down in the dish rack where it would become dry. Otherwise if it would still be wet if it was wet in previous situation S

%no rule (a) because there exists no action that can make an item dirty.
dirty(X, [A | S]) :- item(X), not scrubber(X), not (A = rinse(X), soapy(X,S)), dirty(X,S). %rule (b) X is dirty in situation [A | S] if it is not a scrubber and unless most recent action A involves rinsing using a turned on faucet when it was previously soapy. Otherwise it would still be dirty if it was wet in previous situation S


soapy(X, [A | S]) :- scrubber(X), A = addSoap(X). %rule (a) X is soapy in situation [A | S] if X is a scrubber and most recent action A adds soap to X.
soapy(X, [A | S]) :- A = scrub(X,Y), soapy(Y,S). %rule (a) X is soapy in situation [A | S] if most recent action A is scrubbing X with Y (implying both that Y is a scrubber and X is not a scrubber) and Y was soapy in previous situation S
soapy(X, [A | S]) :- not A = rinse(X), soapy(X,S). %rule (b) X is soapy in situation [A | S] unless most recent action A rinses X. Otherwise if X was soapy in previous situation S it still is.


%%%%% SECTION: declarative_heuristics_dishwashing
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
%%%%% write your rules implementing the predicate  useless(Action, History) here. %

useless(pickUp(X,P),[putDown(X,P) | S]). %It is useless to pick up X from place P if you had just put down X in place P.
useless(putDown(X,P),[pickUp(X,P) | S]). %It is useless to put down X in place P if you had just picked up X from place P.

useless(turnOnFaucet,[turnOffFaucet | S]). %It is useless to turn on the faucet if you had just turned it off.
useless(turnOffFaucet,[turnOnFaucet | S]). %It is usless to turn off the faucet if you had just turned it on.

useless(turnOnFaucet,[turnOnFaucet | S]). %It is useless to turn on the faucet if it was already turned on.
useless(turnOnFaucet,[A | S]) :- useless(turnOnFaucet,S). %It is useless to turn on the faucet if it was already deemed useless to do so in situation S (i.e the faucet should only be turned on once).

useless(turnOffFaucet,[turnOffFaucet | S]). %It is useless to turn off the faucet if it was already turned off.
useless(turnOnFaucet,[A | S]) :- useless(turnOnFaucet,S). %It is useless to turn off the faucet if it was already deemed useless to do so in situation S (i.e the faucet should only be turned off once).

useless(addSoap(X),[addSoap(X) | S]). %It is useless to add soap to X if soap has already been added to it.
useless(addSoap(X),[A | S]) :- useless(addSoap(X),S). %It is useless to add soap to X if it was deemed useless to do so in situation S (i.e soap should only be added to it once).

useless(rinse(X),S) :- dish(X), not soapy(X,S). %It is useless to rinse a dish X if X is not soapy.
useless(rinse(X),S) :- scrubber(X), not soapy(X,S). %It is useless to rinse a non soapy scrubber.

useless(scrub(X,Y),S) :- dish(X), scrubber(Y), not soapy(Y,S). %It is useless to scrub dish X with scrubber Y if Y is not soapy.

