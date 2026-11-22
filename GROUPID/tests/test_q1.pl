% Tests for P1 (code/id_q1.pl).
% Run from the repository's GROUPID folder or the tests folder:
%   swipl -q -g run_tests -t halt tests/test_q1.pl
% Test files may use any library (plunit here); the solution file may not.

:- use_module(library(plunit)).
:- use_module(library(readutil)).
:- consult('../code/id_q1.pl').   % resolved relative to this file

all8([1, 2, 3, 4, 5, 6, 7, 8]).
all9([1, 2, 3, 4, 5, 6, 7, 8, 9]).

% The three solutions of clues 1-8, used as fixed test data.
sol(1, [p('Alex',design,java,'AI'), p('Ben',development,javascript,web),
        p('Carla',research,'c++',data), p('Dana',testing,python,embedded)]).
sol(2, [p('Alex',design,java,embedded), p('Ben',development,javascript,web),
        p('Carla',testing,python,'AI'), p('Dana',research,'c++',data)]).
sol(3, [p('Alex',testing,python,embedded), p('Ben',development,javascript,web),
        p('Carla',design,java,'AI'), p('Dana',research,'c++',data)]).

:- begin_tests(domain).

test(candidate_count) :-
    aggregate_all(count, candidate(_), N),
    N =:= 13824.

test(candidates_distinct) :-
    findall(S, candidate(S), L),
    sort(L, U),
    length(U, 13824).

test(names_in_order) :-
    forall(candidate(S),
           S = [p('Alex',_,_,_), p('Ben',_,_,_), p('Carla',_,_,_), p('Dana',_,_,_)]).

test(each_value_once, [nondet]) :-
    candidate(S),
    findall(L, member(p(_,_,L,_), S), Ls),
    msort(Ls, Sorted),
    msort([python, java, 'c++', javascript], Sorted).

:- end_tests(domain).

:- begin_tests(clues).

% Every clue holds in all three solutions of clues 1-8.
test(clues_1_to_8_hold, [forall((between(1,3,I), between(1,8,C)))]) :-
    sol(I, S),
    clue(C, S).

% Single-clue counts (each clue alone, out of 13,824 candidates).
test(clue_alone_counts, [forall(member(C-E, [1-7776, 2-7776, 3-3456, 4-2592,
                                              5-3456, 6-7776, 7-5184, 8-2592]))]) :-
    count_solutions([C], N),
    N =:= E.

% Hand-made violations: change one value in solution 1 and the clue fails.
test(clue1_fails_if_dana_has_ai, [fail]) :-
    clue(1, [p('Alex',design,java,web), p('Ben',development,javascript,embedded),
             p('Carla',research,'c++',data), p('Dana',testing,python,'AI')]).
test(clue3_fails_if_tester_not_python, [fail]) :-
    clue(3, [p('Alex',design,python,'AI'), p('Ben',development,javascript,web),
             p('Carla',research,'c++',data), p('Dana',testing,java,embedded)]).
test(clue7_fails_if_dana_in_design, [fail]) :-
    clue(7, [p('Alex',testing,java,'AI'), p('Ben',development,javascript,web),
             p('Carla',research,'c++',data), p('Dana',design,python,embedded)]).

% Clues are deterministic tests: no choice point is left behind.
test(clues_are_semidet, [forall(between(1,9,C))]) :-
    sol(2, S),
    clue(C, S).

:- end_tests(clues).

:- begin_tests(count_solutions).

test(n_for_clues_1_to_8) :-
    all8(A), count_solutions(A, N), N =:= 3.
test(order_does_not_matter) :-
    count_solutions([8,7,6,5,4,3,2,1], N), N =:= 3.
test(no_clues) :-
    count_solutions([], N), N =:= 13824.
test(leave_one_out, [forall(member(K-E, [1-4, 2-6, 3-13, 4-12,
                                          5-9, 6-7, 7-5, 8-16]))]) :-
    all8(All), exclude(==(K), All, A),
    count_solutions(A, N),
    N =:= E.
test(solutions_of_1_to_8_are_the_three_known_ones) :-
    findall(S, solve(S), L), msort(L, Sorted),
    findall(S, sol(_, S), K), msort(K, Sorted).

:- end_tests(count_solutions).

:- begin_tests(clue9).

test(n_for_clues_1_to_9) :-
    all9(A), count_solutions(A, N), N =:= 1.
test(clue9_keeps_only_solution_2) :-
    findall(I, (sol(I, S), clue(9, S)), [2]).
test(unique_solution_is_solution_2) :-
    all9(A), sol(2, Expected),
    findall(S, (candidate(S), satisfies(A, S)), [Expected]).
test(clue9_comment_directly_above_clause) :-
    source_lines(Lines),
    nth1(I, Lines, Comment), sub_string(Comment, 0, _, _, "% CLUE 9:"), !,
    J is I + 1, nth1(J, Lines, Head),
    sub_string(Head, 0, _, _, "clue(9,").
test(clue9_mentions_no_friend) :-
    source_lines(Lines),
    nth1(I, Lines, Comment), sub_string(Comment, 0, _, _, "% CLUE 9:"), !,
    J is I + 3, findall(L, (between(I, J, K), nth1(K, Lines, L)), Block),
    forall(member(L, Block),
           forall(member(Name, ["Alex", "Ben", "Carla", "Dana"]),
                  \+ sub_string(L, _, _, _, Name))).

:- end_tests(clue9).

:- begin_tests(main).

test(main_output) :-
    with_output_to(string(Out), main),
    Out == "Alex = [design, java, AI]\nBen = [development, javascript, web]\nCarla = [research, c++, data]\nDana = [testing, python, embedded]\n".

test(main_is_a_solution_of_1_to_8) :-
    once(solve(S)), all8(A), satisfies(A, S).

:- end_tests(main).

:- begin_tests(constraints).

test(no_forbidden_predicates) :-
    source_text(Text),
    forall(member(Bad, ["assert", "retract", "b_setval", "nb_setval",
                        "initialization", "halt"]),
           \+ sub_string(Text, _, _, _, Bad)).

test(only_allowed_libraries) :-
    source_text(Text),
    forall(sub_string(Text, B, _, _, "library("),
           ( B1 is B + 8, sub_string(Text, B1, _, 0, Rest),
             once(( member(Lib, ["lists)", "apply)", "yall)", "aggregate)"]),
                    sub_string(Rest, 0, _, _, Lib) )) )).

:- end_tests(constraints).

% --- helpers: read the solution file as text, relative to this test file ---
solution_path(Path) :-
    source_file(clue(_, _), Path), !.
source_text(Text) :-
    solution_path(Path),
    read_file_to_string(Path, Text, []).
source_lines(Lines) :-
    source_text(Text),
    split_string(Text, "\n", "", Lines).
