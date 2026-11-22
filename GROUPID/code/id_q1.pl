% P1: Department Assignment Puzzle, Reloaded
% A solution is [p('Alex',D,L,P), p('Ben',D,L,P), p('Carla',D,L,P), p('Dana',D,L,P)]
% in that order, where every department, language and project is used
% exactly once.

:- use_module(library(lists)).

%% departments(-Depts), languages(-Langs), projects(-Projects)
%  Declarative reading: these are the four values of each attribute.
departments([research, development, design, testing]).
languages([python, java, 'c++', javascript]).
projects(['AI', web, embedded, data]).

%% solution_template(-Solution)
%  Declarative reading: Solution is the list of the four friends, in the
%  order Alex, Ben, Carla, Dana, with their attributes still unknown.
%  Modes / determinism: det.
solution_template([p('Alex',  _, _, _),
                   p('Ben',   _, _, _),
                   p('Carla', _, _, _),
                   p('Dana',  _, _, _)]).

%% candidate(-Solution)
%  Declarative reading: Solution is a fully filled-in assignment in which
%  each friend has one department, one language and one project, and no
%  two friends share a value of the same attribute (each attribute's
%  column is a permutation of its four values).
%  Modes / determinism: nondet; enumerates all 24 * 24 * 24 = 13,824
%  candidates on backtracking. The clues are checked separately.
candidate(Solution) :-
    solution_template(Solution),
    Solution = [p(_, D1, L1, P1), p(_, D2, L2, P2),
                p(_, D3, L3, P3), p(_, D4, L4, P4)],
    departments(Depts),
    languages(Langs),
    projects(Projects),
    permutation(Depts,    [D1, D2, D3, D4]),
    permutation(Langs,    [L1, L2, L3, L4]),
    permutation(Projects, [P1, P2, P3, P4]).
