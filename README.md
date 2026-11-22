# CS F301 Principles of Programming Languages: Assignment 2

**Group 4** (single-member group)

| Name | ID |
|------|----|
| Manan Mengi | 2024A7PS0156H |

Logic and functional programming: two Prolog problems (SWI-Prolog 9.x) and
two Scheme problems (Racket 8.x, `#lang racket/base` with the restricted
built-ins).

## Layout

```
4/
  code/      4_q1.pl 4_q2.pl 4_q3.rkt 4_q4.rkt
  tests/     test_q1.pl test_q2.pl test_q3.rkt test_q4.rkt
  skills/    prolog-dev/SKILL.md scheme-dev/SKILL.md
  prompts/   P1.md P2.md S1.md S2.md (plus SETUP.md for the skill files)
  P1_REPORT.md
```

## Running

From the `4/` folder:

```
swipl -q -f code/4_q1.pl -g main -t halt
swipl -q -f code/4_q2.pl -g "all_equations([4,2,5,3],Es), print(Es), nl" -t halt
racket code/4_q3.rkt          # definitions only; prints nothing
racket code/4_q4.rkt          # definitions only; prints nothing
```

Tests:

```
swipl -g run_tests -t halt tests/test_q1.pl
swipl -g run_tests -t halt tests/test_q2.pl
racket tests/test_q3.rkt
racket tests/test_q4.rkt
```
