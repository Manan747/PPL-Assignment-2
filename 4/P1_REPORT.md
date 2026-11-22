# P1 Report: Department Assignment Puzzle

## P1.b: number of solutions of clues 1 to 8

```
?- count_solutions([1,2,3,4,5,6,7,8], N).
N = 3.
```

**N = 3.** Out of the 13,824 possible assignments (24 × 24 × 24: one
permutation for departments, one for languages, one for projects), exactly
three satisfy all eight clues:

| # | Alex | Ben | Carla | Dana |
|---|------|-----|-------|------|
| 1 | design, java, AI | development, javascript, web | research, c++, data | testing, python, embedded |
| 2 | design, java, embedded | development, javascript, web | testing, python, AI | research, c++, data |
| 3 | testing, python, embedded | development, javascript, web | design, java, AI | research, c++, data |

### What this tells us about the puzzle

- **The puzzle is under-constrained.** A well-formed logic puzzle has exactly
  one solution. With N = 3 the clues are consistent (N > 0, so they do not
  contradict each other), but they do not determine who does what. Only Ben
  is fully determined (development, javascript, web in every solution).
- **No clue is redundant.** Dropping any single clue raises the count, so
  each clue removes at least one assignment that the others allow:

  | Clue left out | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
  |---|---|---|---|---|---|---|---|---|
  | N | 4 | 6 | 13 | 12 | 9 | 7 | 5 | 16 |

  Clues 8 and 3 do the most work (16 and 13 solutions without them).
- **The ambiguity has a structure.** Solutions 1 and 3 contain the same
  four (department, language, project) combinations, only assigned to
  different people: design/java/AI, development/javascript/web,
  research/c++/data and testing/python/embedded. Solution 2 is the only one
  with a different set of combinations (design/java/embedded and
  testing/python/AI). This matters for the repair below.

`main/0` must use clues 1 to 8 only, so it prints the first of the three
solutions it finds (solution 1). That is a valid answer for P1.a, but it is
not the solution that clue 9 keeps.

## P1.c: the repair (clue 9)

```prolog
% CLUE 9: The friend who works in the testing department prefers the AI project.
clue(9, Solution) :-
    memberchk(p(_, testing, _, Project), Solution),
    Project == 'AI'.
```

```
?- count_solutions([1,2,3,4,5,6,7,8,9], N).
N = 1.
```

**Why this clue.** Clue 9 may refer to friends only through attribute values,
not names. Because solutions 1 and 3 use exactly the same attribute
combinations, any clue of that kind is either true in both of them or false
in both. So no name-free clue can single out solution 1 or solution 3; the
only solution a clue 9 can keep is **solution 2**. In solution 2 the testing
friend prefers AI; in solutions 1 and 3 the testing friend prefers
embedded. So clue 9 is true in solution 2 and false in the other two.

The unique solution of clues 1 to 9:

```
Alex  = [design, java, embedded]
Ben   = [development, javascript, web]
Carla = [testing, python, AI]
Dana  = [research, c++, data]
```

## How this was checked

All numbers above are produced by the code and checked by
`tests/test_q1.pl` (69 plunit tests: domain size, every clue alone,
leave-one-out counts, N = 3, N = 1, clue 9's comment position and wording,
`main/0`'s exact output, and the file constraints).

```
swipl -q -f code/4_q1.pl -g "count_solutions([1,2,3,4,5,6,7,8],N), print(N), nl" -t halt
swipl -q -f code/4_q1.pl -g "count_solutions([1,2,3,4,5,6,7,8,9],N), print(N), nl" -t halt
swipl -g run_tests -t halt tests/test_q1.pl
```
