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

%% precedence(+Tree, -P)
%  Declarative reading: P is how tightly the top of Tree binds:
%  + and - are 1, * and / are 2, and a single number is 3 (it is never
%  wrapped in parentheses).
precedence(n(_), 3).
precedence(t(Op, _, _), P) :- op_precedence(Op, P).

op_precedence(+, 1).
op_precedence(-, 1).
op_precedence(*, 2).
op_precedence(/, 2).

%% tree_string(+Tree, -String)
%  Declarative reading: String is the canonical text of Tree, with no spaces:
%  - a number is written in decimal;
%  - a left operand is parenthesized only if its precedence is LOWER than
%    its parent's (operators are left-associative, so 1-2-3 means (1-2)-3);
%  - a right operand is parenthesized if its precedence is the SAME OR
%    LOWER than its parent's (so 1-(2-3) and 1+(2+3) keep their brackets).
%  This gives every different tree a different string.
%  Modes / determinism: det. The string is only built, never parsed.
tree_string(n(N), String) :-
    number_string(N, String).
tree_string(t(Op, L, R), String) :-
    op_precedence(Op, P),
    operand_string(left,  L, P, LS),
    operand_string(right, R, P, RS),
    format(string(String), "~w~w~w", [LS, Op, RS]).

%% operand_string(+Side, +Tree, +ParentPrec, -String)
%  Declarative reading: String is Tree's text, wrapped in parentheses when
%  the rule for its Side (left or right) requires it under a parent of
%  precedence ParentPrec.
operand_string(Side, Tree, ParentPrec, String) :-
    tree_string(Tree, Inner),
    precedence(Tree, P),
    (   needs_parens(Side, P, ParentPrec)
    ->  format(string(String), "(~w)", [Inner])
    ;   String = Inner
    ).

%% needs_parens(+Side, +ChildPrec, +ParentPrec)
%  Declarative reading: an operand of precedence ChildPrec on this Side of a
%  parent of precedence ParentPrec must be written in parentheses.
needs_parens(left,  Child, Parent) :- Child <  Parent.
needs_parens(right, Child, Parent) :- Child =< Parent.
