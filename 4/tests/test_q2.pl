% Tests for P2 (code/4_q2.pl).
% Run:  swipl -g run_tests -t halt tests/test_q2.pl
% Test files may use any library and may parse strings (here: to check the
% answers independently); the solution file itself never parses strings.

:- use_module(library(plunit)).
:- use_module(library(readutil)).
:- consult('../code/4_q2.pl').   % resolved relative to this file

% ---------------------------------------------------------------------------
% Independent checker: parse an equation string with Prolog's own reader and
% re-evaluate it, with the exact-division rule applied at every node.
% ---------------------------------------------------------------------------
valid_equation(List, String) :-
    string(String),
    \+ sub_string(String, _, _, _, " "),
    term_string(L = R, String),
    numbers_in_order(L, LNums), numbers_in_order(R, RNums),
    append(LNums, RNums, List), LNums \== [], RNums \== [],
    exact_value(L, V), exact_value(R, V).

exact_value(N, N) :- integer(N), N >= 0.
exact_value(A + B, V) :- exact_value(A, X), exact_value(B, Y), V is X + Y.
exact_value(A - B, V) :- exact_value(A, X), exact_value(B, Y), V is X - Y.
exact_value(A * B, V) :- exact_value(A, X), exact_value(B, Y), V is X * Y.
exact_value(A / B, V) :- exact_value(A, X), exact_value(B, Y),
                         Y =\= 0, X mod Y =:= 0, V is X // Y.

numbers_in_order(N, [N]) :- integer(N).
numbers_in_order(T, Ns) :-
    compound(T), T =.. [_, A, B],
    numbers_in_order(A, As), numbers_in_order(B, Bs), append(As, Bs, Ns).

% Convert a parsed Prolog term to the solution's tree format, so that the
% canonical printer can be checked by a round trip.
to_tree(N, n(N)) :- integer(N).
to_tree(T, t(Op, LT, RT)) :- compound(T), T =.. [Op, A, B],
    to_tree(A, LT), to_tree(B, RT).

expected(1, [4,2,5,3], ["4*2-5=3", "4*2=5+3", "4-2=5-3", "4/2=5-3",
                        "4=2*(5-3)", "4=2+(5-3)", "4=2+5-3"]).
expected(2, [2,3,4],   []).
expected(3, [2,4,8],   ["2*4=8"]).

% ===========================================================================
:- begin_tests(spec_examples).

test(all_4253) :- expected(1, L, E), all_equations(L, Es), Es == E.
test(generate_4253, [true(memberchk(Eq, E))]) :-
    expected(1, L, E), generate_equation(L, Eq).
test(generate_234_fails, [fail]) :- generate_equation([2,3,4], _).
test(all_234_empty) :- all_equations([2,3,4], Es), Es == [].
test(all_248) :- expected(3, L, E), all_equations(L, Es), Es == E.
test(count_4253) :- count_equations([4,2,5,3], N), N =:= 7.
test(count_234) :- count_equations([2,3,4], N), N =:= 0.

:- end_tests(spec_examples).

% ===========================================================================
:- begin_tests(lengths_0_and_1).

test(generate_empty_fails, [fail]) :- generate_equation([], _).
test(generate_single_fails, [fail]) :- generate_equation([5], _).
test(generate_single_zero_fails, [fail]) :- generate_equation([0], _).
test(all_empty) :- all_equations([], Es), Es == [].
test(all_single) :- all_equations([7], Es), Es == [].
test(count_empty) :- count_equations([], N), N =:= 0.
test(count_single) :- count_equations([7], N), N =:= 0.
test(two_equal_numbers) :- all_equations([1,1], Es), Es == ["1=1"].
test(two_different_numbers) :- all_equations([1,2], Es), Es == [].

:- end_tests(lengths_0_and_1).

% ===========================================================================
:- begin_tests(zeros_and_division).

test(zero_zero) :- all_equations([0,0], Es), Es == ["0=0"].
% 5/0 is never allowed, and 5 = 0 is false.
test(divide_by_zero_rejected) :- all_equations([5,0], Es), Es == [].
% 6/0 rejected; no other equation balances.
test(six_zero_three) :- all_equations([6,0,3], Es), Es == [].
% 0/5 = 0 is allowed (zero numerator is fine); 5/0 is not.
test(zero_numerator_ok) :-
    all_equations([0,5,0], Es), Es == ["0*5=0", "0/5=0", "0=5*0"].
% 0/0 is never allowed.
test(zero_over_zero_rejected) :-
    all_equations([0,0,0], Es),
    Es == ["0*0=0", "0+0=0", "0-0=0", "0=0*0", "0=0+0", "0=0-0"].
test(three_zero_three) :-
    all_equations([3,0,3], Es), Es == ["3+0=3", "3-0=3", "3=0+3"].
% Inexact division is rejected: 1=2/3 must not appear.
test(inexact_division_rejected) :- all_equations([1,2,3], Es), Es == ["1+2=3"].
test(exact_division_accepted) :-
    all_equations([12,3,4], Es), Es == ["12/3=4", "12=3*4"].
% Exactness is checked inside, not only at the top: (7/2)*2 = 7 is invalid.
test(inner_division_checked) :-
    all_equations([7,2,2,7], Es),
    \+ memberchk("7/2*2=7", Es).
% Negative intermediate values are allowed: 3-5 = -2.
test(negative_intermediate) :-
    all_equations([3,5,1,3], Es), memberchk("3-5=1-3", Es).

:- end_tests(zeros_and_division).

% ===========================================================================
:- begin_tests(properties).

test(results_are_strings, [forall(member(L, [[4,2,5,3], [2,4,8], [0,0,0]]))]) :-
    all_equations(L, Es), forall(member(E, Es), string(E)),
    generate_equation(L, G), string(G).

test(sorted_and_unique, [forall(member(L, [[4,2,5,3], [1,1,1,1], [2,2,2,2,2]]))]) :-
    all_equations(L, Es), sort(Es, Sorted), Es == Sorted.

test(every_equation_independently_valid,
     [forall(member(L, [[4,2,5,3], [1,2,3,4], [6,3,2,1], [0,5,0], [2,2,2,2,2]]))]) :-
    all_equations(L, Es),
    forall(member(E, Es), valid_equation(L, E)).

% The printer is canonical: re-printing a parsed equation gives the same text.
test(canonical_round_trip, [forall(member(L, [[4,2,5,3], [1,2,3,4], [2,2,2,2,2]]))]) :-
    all_equations(L, Es),
    forall(member(E, Es),
           ( term_string(A = B, E), to_tree(A, TA), to_tree(B, TB),
             tree_string(TA, SA), tree_string(TB, SB),
             format(string(E2), "~w=~w", [SA, SB]), E2 == E )).

test(generate_is_one_of_all, [forall(member(L, [[4,2,5,3], [1,2,3,4], [12,3,4]]))]) :-
    generate_equation(L, G), all_equations(L, Es), memberchk(G, Es).

test(count_matches_all, [forall(member(L, [[4,2,5,3], [1,2,3,4], [2,3,4], []]))]) :-
    all_equations(L, Es), length(Es, Len), count_equations(L, N), N =:= Len.

test(generate_is_semidet) :- generate_equation([4,2,5,3], _).

% Different trees never print the same (needed for "no duplicates").
test(printer_injective) :-
    findall(T, expr([2,2,2,2,2], T, _), Ts), length(Ts, N),
    findall(S, (member(T, Ts), tree_string(T, S)), Ss), sort(Ss, U), length(U, N).

test(seven_numbers_fast) :-
    statistics(cputime, T0),
    count_equations([1,2,3,4,5,6,7], N),
    statistics(cputime, T1),
    N =:= 529, T1 - T0 < 10.

:- end_tests(properties).

% ===========================================================================
:- begin_tests(printer_rule).

p(T, S) :- tree_string(T, X), X == S.

test(spec_1) :- p(t(*, t(+,n(4),n(2)), n(3)), "(4+2)*3").
test(spec_2) :- p(t(+, n(4), t(*,n(2),n(3))), "4+2*3").
test(spec_3) :- p(t(*, t(/,n(8),n(4)), n(2)), "8/4*2").
test(spec_4) :- p(t(/, n(8), t(*,n(4),n(2))), "8/(4*2)").
test(spec_5) :- p(t(-, t(-,n(1),n(2)), n(3)), "1-2-3").
test(spec_6) :- p(t(-, n(1), t(-,n(2),n(3))), "1-(2-3)").
test(spec_7) :- p(t(+, n(1), t(+,n(2),n(3))), "1+(2+3)").
test(spec_8) :- p(t(+, t(+,n(1),n(2)), n(3)), "1+2+3").
test(number_alone) :- p(n(10), "10").

:- end_tests(printer_rule).

% ===========================================================================
:- begin_tests(constraints).

source_text(Text) :-
    source_file(user:generate_equation(_, _), Path),
    read_file_to_string(Path, Text, []).

test(no_forbidden_predicates) :-
    source_text(Text),
    forall(member(Bad, ["assert", "retract", "b_setval", "nb_setval",
                        "initialization", "halt", "term_string",
                        "term_to_atom", "read_term", "atom_to_term",
                        "number_codes", "string_to_atom"]),
           \+ sub_string(Text, _, _, _, Bad)).

test(silent_load) :-
    source_file(user:generate_equation(_, _), Path),
    with_output_to(string(Out), user:load_files(Path, [if(true), silent(true)])),
    Out == "".

:- end_tests(constraints).
