---
name: prolog-dev
description: Conventions, run/test commands, self-review checklist and known AI failure modes for writing SWI-Prolog 9.x code for CS F301 Assignment 2 (P1 logic puzzle, P2 arithmetic equations). Use for any Prolog predicate, test or review in this repo.
---

# Prolog development skill (SWI-Prolog 9.x)

## 1. Language and environment
- SWI-Prolog 9.x only. Standard ISO Prolog plus SWI built-ins.
- Allowed libraries: `lists`, `apply`, `yall`, `aggregate`. Nothing else
  (no `clpfd`, no `dcg/basics`, no `strings`, no `format_atom` tricks from other libs).
- Forbidden everywhere: `assert/1`, `asserta/1`, `assertz/1`, `retract/1`,
  `b_setval/2`, `nb_setval/2`, `b_getval/2`, `nb_getval/2`, any global variable.
- Forbidden in files: `:- initialization(...)`, calls to `halt/0` or `halt/1`.
- Files contain only definitions (and `:- use_module(library(...))` for allowed libraries).
- P2 only: never build a string and parse it back to evaluate it
  (no `term_string/2`, `term_to_atom/2`, `read_term_from_atom/3`, `number_codes` on
  expressions, etc. for evaluation). Evaluate the expression tree directly.
- P2 output equations are SWI-Prolog **strings** (`"4*2=5+3"`), not atoms, not code lists.

## 2. How code is run
```
swipl -q -f id_qN.pl -g main -t halt
swipl -q -f id_qN.pl -g "<goal>" -t halt
```
To print a result for a non-printing goal while testing:
```
swipl -q -f id_q1.pl -g "count_solutions([1,2,3,4,5,6,7,8],N), print(N), nl" -t halt
swipl -q -f id_q2.pl -g "all_equations([4,2,5,3],Es), print(Es), nl" -t halt
```
Load must be silent: no warnings (singleton variables, discontiguous clauses,
clauses not together). Check with `swipl -q -f file.pl -g true -t halt` and
confirm there is no output at all.

## 3. Coding conventions
- Predicate names: `snake_case`. Variable names: `CamelCase`, meaningful
  (`Solution`, `Dept`, `LeftExpr`), never single letters except in tiny helpers.
- Every predicate gets a header comment:
  ```
  %% name(+In, -Out)
  %  Declarative reading: "name(In, Out) holds when ..."
  %  Modes / determinism: det | semidet | nondet
  ```
  The declarative reading is mandatory: one sentence saying what relation the
  predicate states, not how it executes.
- Mode notation: `+` input (bound), `-` output (unbound), `?` either.
- Keep all clauses of one predicate together (avoid discontiguous warnings).
- Use `_` or `_Name` for unused variables (no singleton warnings).
- Prefer pure, declarative code. Use cuts (`!`) only when needed for determinism
  and comment every cut with why it is safe (green cut vs red cut).
- Use `\+` for negation, only on goals whose variables are already bound.
- Quoted atoms where required: `'Alex'`, `'Ben'`, `'Carla'`, `'Dana'`, `'c++'`, `'AI'`.
- Comparisons: `=:=` / `=\=` for arithmetic, `==` / `\==` for term identity,
  `=` for unification. Never mix them up.
- Integer arithmetic: use `//` or check `X mod Y =:= 0` before dividing;
  `/` in SWI may return a float or rational depending on flags.

## 4. Problem-specific patterns
### P1 (puzzle)
- Represent a solution as `[p('Alex',D1,L1,P1), p('Ben',...), p('Carla',...), p('Dana',...)]`.
- Generate with `permutation/2` over each attribute's value list so every value
  is used exactly once.
- Each clue is its own clause `clue(N, Solution)` that is only a **test** on a
  fully filled-in solution (no generation inside clues).
- Count with `findall/3` + `length/2` or `aggregate_all(count, ...)`.
  `count_solutions(Active, N)` checks exactly the clues in `Active`
  (use `forall(member(C, Active), clue(C, S))` or `maplist`).
- `main/0` output format exactly: `Alex = [research, python, AI]` (no quotes,
  comma+space separators). Use `format/2` with `~w`, not `print/1` or `writeq/1`
  (those add quotes around `'c++'` and `'AI'`).
- Do not hard-code the answer.

### P2 (equations)
- Generate all ways to split the list into a non-empty prefix and suffix.
- Generate all expression trees for a sublist (split recursively, choose
  operator), keeping numbers in order.
- Evaluate while building; reject division when divisor is 0 or remainder ≠ 0
  at **every** division node.
- Print with the canonical parenthesization rule:
  - precedence: `* /` = 2, `+ -` = 1, number = 3 (never parenthesized)
  - left operand parenthesized iff its precedence < parent's
  - right operand parenthesized iff its precedence =< parent's
- Build strings with `format(string(S), ...)` or `atomics_to_string/2` /
  `string_concat/3`. Final result must satisfy `string(S)`.
- `all_equations/2`: `findall` then `sort/2` (removes duplicates, standard order).
  Empty result is `[]`, never failure.
- `generate_equation/2` must fail cleanly for `[]`, `[_]`, or no solution.

## 5. How to test
- Tests live in `tests/` as `.pl` files that load the solution with
  `:- consult('../code/id_qN.pl').` (or are run with `-f`), and define a
  `run_tests_pN/0` predicate that prints `PASS name` / `FAIL name` per case.
- SWI's `plunit` is acceptable in test files only (not in solution files).
- Always include: every example from the assignment, empty and single-element
  inputs, zeros (division by zero), negative intermediates (`3-5`), duplicates.
- Verify termination: every goal from the spec must finish quickly and must not
  leave a choice point that loops on backtracking.

## 6. Self-review checklist (apply before every answer)
1. Does the file load with zero output and zero warnings?
2. No `assert`/`retract`/global variables/initialization/`halt`?
3. Only allowed libraries used?
4. Every predicate has a mode header and a declarative reading?
5. Output format matches the spec character for character (spaces, commas,
   quotes, newline at end)?
6. Does it fail (not error, not loop) on edge inputs?
7. Are `\+` goals called only with bound variables?
8. Are cuts justified and not removing valid solutions?
9. P2: results are strings, sorted, duplicate-free; every division checked.
10. Did I actually run the code (or trace it by hand) on the spec examples?

## 7. Known failure modes of AI tools for Prolog
- Writing imperative-style code with `assert` for counters or memoization.
- Using `print/1` / `writeq/1` for output, producing `'c++'` with quotes.
- Confusing `=` with `=:=` or `is`; writing `X = Y + 1` and expecting arithmetic.
- Using `/` and getting floats (`4/3` → `1.333`) instead of rejecting inexact division.
- Placing negation `\+` before its variables are bound, silently changing meaning.
- Putting generation inside clue clauses, so `count_solutions` miscounts.
- Forgetting that `findall` with free variables does not behave like `bagof`.
- Returning atoms or code lists instead of SWI strings.
- Adding `:- initialization(main).` out of habit.
- Discontiguous clauses and singleton-variable warnings that print on load.
- Infinite left recursion in expression generators (recursing on the same list
  without shrinking it).
- Inventing library predicates that don't exist or come from disallowed libraries
  (e.g. `clpfd`'s `all_different/1`, `sumlist` vs `sum_list` confusion).
- Claiming code was tested when it was not: always show the actual command and output.
