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

%% clue(+N, +Solution)
%  Declarative reading: clue(N, Solution) holds when clue number N of the
%  puzzle is true in the fully filled-in Solution.
%  Modes / determinism: semidet for a ground Solution. Each clue is only a
%  test: it never generates values. Because every value of an attribute
%  belongs to exactly one friend, memberchk/2 finds "the friend with value
%  X" deterministically. \== is safe here because Solution is ground.

% CLUE 1: The friend who prefers the AI project does not work in research
% and is not Dana.
clue(1, Solution) :-
    memberchk(p(Name, Dept, _, 'AI'), Solution),
    Dept \== research,
    Name \== 'Dana'.

% CLUE 2: Alex does not work in development and does not prefer C++.
clue(2, Solution) :-
    memberchk(p('Alex', Dept, Lang, _), Solution),
    Dept \== development,
    Lang \== 'c++'.

% CLUE 3: The friend working in the testing department likes Python.
clue(3, Solution) :-
    memberchk(p(_, testing, Lang, _), Solution),
    Lang == python.

% CLUE 4: Ben prefers web projects and does not work in testing.
clue(4, Solution) :-
    memberchk(p('Ben', Dept, _, Project), Solution),
    Project == web,
    Dept \== testing.

% CLUE 5: The friend whose favorite language is Java works in the design
% department.
clue(5, Solution) :-
    memberchk(p(_, Dept, java, _), Solution),
    Dept == design.

% CLUE 6: Carla's project preference is not embedded, and her department
% is not development.
clue(6, Solution) :-
    memberchk(p('Carla', Dept, _, Project), Solution),
    Project \== embedded,
    Dept \== development.

% CLUE 7: Dana's favorite language is not Java, and she works in research
% or testing.
clue(7, Solution) :-
    memberchk(p('Dana', Dept, Lang, _), Solution),
    Lang \== java,
    memberchk(Dept, [research, testing]).

% CLUE 8: The friend who prefers data projects works in research and does
% not use JavaScript.
clue(8, Solution) :-
    memberchk(p(_, Dept, Lang, data), Solution),
    Dept == research,
    Lang \== javascript.
