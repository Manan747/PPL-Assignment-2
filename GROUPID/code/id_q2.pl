% P2: Form a Valid Arithmetic Equation
% Expression trees are built and evaluated directly (never as strings):
%   n(N)          a single number N
%   t(Op, L, R)   L Op R, where Op is one of + - * /

:- use_module(library(lists)).

%% split(+List, -Left, -Right)
%  Declarative reading: Left and Right are both non-empty and Left followed
%  by Right is List (so every number stays in its original order).
%  Modes / determinism: nondet; one answer per split point.
split(List, Left, Right) :-
    append(Left, Right, List),
    Left = [_|_],
    Right = [_|_].

%% apply_op(?Op, +A, +B, -Value)
%  Declarative reading: Value is A Op B, where division is allowed only when
%  B is not zero and A is an exact multiple of B (no remainder).
%  Modes / determinism: nondet when Op is unbound (tries + - * / in turn);
%  the / clause simply fails for an inexact or zero divisor.
apply_op(+, A, B, V) :- V is A + B.
apply_op(-, A, B, V) :- V is A - B.
apply_op(*, A, B, V) :- V is A * B.
apply_op(/, A, B, V) :- B =\= 0, A mod B =:= 0, V is A // B.

%% expr(+Numbers, -Tree, -Value)
%  Declarative reading: Tree is an expression that uses every number of the
%  non-empty list Numbers exactly once and in order, and Value is its
%  integer value. A single number is n(N); otherwise the list is split into
%  two non-empty parts, each part is an expression, and they are joined by
%  one operator.
%  Modes / determinism: nondet; enumerates every tree (each exactly once).
%  Terminates because both parts of a split are shorter than Numbers.
%  Every division in the tree is checked when its node is built, so an
%  inexact division anywhere rejects the whole tree.
expr([N], n(N), N).
expr(Numbers, t(Op, L, R), Value) :-
    split(Numbers, LeftNums, RightNums),
    expr(LeftNums, L, LV),
    expr(RightNums, R, RV),
    apply_op(Op, LV, RV, Value).
