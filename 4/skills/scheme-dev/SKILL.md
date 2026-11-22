---
name: scheme-dev
description: Conventions, allowed built-ins, run/test commands, self-review checklist and known AI failure modes for writing restricted Racket 8.x (#lang racket/base) code for CS F301 Assignment 2 (S1 tree traversals, S2 nested-list insert). Use for any Scheme function, test or review in this repo.
---

# Scheme development skill (Racket 8.x, restricted racket/base)

## 1. Language and environment
- Racket 8.x. Every solution file starts with exactly `#lang racket/base`.
- Files contain **only definitions**. No top-level calls, no top-level `display`,
  nothing printed when the file is loaded. The grader appends its own calls.
- No `(provide ...)`, no `(require ...)`, no `module+ test` in solution files.

## 2. Allowed built-ins (the complete list, nothing else)
```
define  lambda  let  let*  letrec  named let  if  cond (with else)
and  or  not  begin  quote (')
cons  car  cdr  list  c[ad]{2,4}r  (cadr, cddr, caddr, cdddr, cadddr, cddddr, caar, ...)
null?  pair?  eq?  assq  assoc
+  -  *  <  >  <=  >=  =  max
display  newline
read            ; S2 only
```

## 3. Forbidden (common things that are NOT on the list)
- Mutation: `set!`, `set-car!`, `set-cdr!`, boxes, `define-values` tricks.
- Data structures: vectors, hash tables, strings, characters, structs.
- Loops: `do`, `for`, `for/list`, `for-each`, `when`, `unless`, `case`.
- List library: `length`, `append`, `reverse`, `map`, `filter`, `foldl`, `foldr`,
  `apply`, `member`, `memq`, `list-ref`, `list-tail`, `first`, `rest`, `last`,
  `empty?`, `empty`, `null` (use `'()`), `list?`.
- Predicates/arith not listed: `equal?`, `eqv?`, `symbol?`, `number?`, `atom?`,
  `zero?`, `add1`, `sub1`, `quotient`, `remainder`, `modulo`, `abs`, `min`.
- Output: `printf`, `write`, `print`, `displayln`, `format`.
- If a needed function is missing, write a helper with a `my-` prefix
  (`my-append`, `my-reverse`, `my-length`, `my-map`) from allowed primitives only.

Useful substitutes:
| want            | write instead                              |
|-----------------|--------------------------------------------|
| `(list? x)`     | `(or (null? x) (pair? x))` (no dotted pairs in input) |
| atom test       | `(not (or (null? x) (pair? x)))`           |
| `(zero? n)`     | `(= n 0)`                                  |
| `(add1 n)`      | `(+ n 1)`                                  |
| `(when c e)`    | `(if c e '())` or `cond`                   |
| `(displayln x)` | `(begin (display x) (newline))`            |

## 4. Coding conventions
- Names: `kebab-case`; predicates end in `?`; helpers start with `my-` or are
  local (`letrec` / named `let`) when only one function uses them.
- Every function gets a header comment:
  ```
  ;; (name arg1 arg2) -> result-type
  ;; Recursive reading: "<what it returns for the base case>; otherwise <how the
  ;;   result is built from the result on the smaller input>."
  ;; Tail recursive: yes/no (and why).
  ```
- Pass all state through arguments (accumulators), never through mutation.
- Prefer tail recursion where natural: accumulate, then `my-reverse` once at the
  end rather than calling `my-append` inside a loop (quadratic).
- `if` must have both branches. Use `cond` with `else` for 3+ cases.
- Data definitions used in this assignment:
  - Binary tree: `'()` or `(value left right)`; accessors `car` = value,
    `cadr` = left, `caddr` = right. Leaf = node with both children `'()`.
  - Nested list (S2): elements are atoms or lists, no dotted pairs.
- Every printing function ends its output with `(newline)`.

## 5. Problem-specific notes
### S1 (trees)
- Traversal returns a list; the `print-*` functions only `display` + `newline`.
- Inorder/preorder/postorder via an accumulator walking right-to-left
  (e.g. inorder: `(walk left (cons value (walk right acc)))`) avoids `append`.
- Height of `'()` is 0; `(max h-left h-right)` + 1. Leaves of `'()` is 0.
- `(print-height-and-leaves t)` displays a two-element list `(height leaves)`.
- Empty tree prints `()` (display of `'()` shows `()`).

### S2 (insert-if-short)
- Length is measured on the **original** list, before inserting `x`.
- Insert at every level, including the top level and empty lists.
- Recurse into an element only if it is a list (`null?` or `pair?`).
- Hidden tests: depth 100 and 10,000-element lists. Write `my-length` and
  `my-map` tail-recursively (accumulator + `my-reverse`) so wide lists are safe.
- Final file has exactly one `insert-if-short`, defined via `make-inserter`:
  `(define (insert-if-short x lst n) ((make-inserter x (lambda (len) (< len n))) lst))`.
- `print-insert-result` reads `x`, `lst`, `n` with three `(read)` calls in order
  (use `let*` to force the order), prints nothing else.

## 6. How to run and test
```
racket code/4_q3.rkt                 # must print nothing
racket code/4_q4.rkt                 # must print nothing
echo "42 ((1 2) (3 4 5) (6) ()) 3" | racket tests/run_q4_read.rkt
```
- Test files live in `tests/` and do `(require (file "../code/4_qN.rkt"))`
  **only if** the solution provides its names; simpler and grader-like: a test
  script that concatenates the solution file with test calls, e.g.
  `cat code/4_q3.rkt tests/calls_q3.rkt > /tmp/t.rkt && racket /tmp/t.rkt`,
  then `diff` against an expected-output file.
- Test files may use anything (e.g. `rackunit`, `equal?`); solution files may not.
- Always cover: every spec example, the empty tree / empty list, `n = 0`,
  single node, skewed trees, deep nesting (100), long lists (10,000).

## 7. Self-review checklist (apply before every answer)
1. First line is `#lang racket/base`; file prints nothing when run alone?
2. Every identifier used is on the allowed list or defined in the file?
   (Grep for `length`, `append`, `reverse`, `map`, `equal?`, `else` in `if`,
   `when`, `set!`, `list?`, `null` without `?`, `first`, `rest`, `add1`.)
3. Every `if` has two branches; every `cond` ends in `else`?
4. No mutation, all state in arguments?
5. Output exactly matches the spec (parentheses, spaces, one newline at end)?
6. Edge cases: `'()`, `n = 0`, single element, deep and wide inputs?
7. Tail recursion used where natural; no quadratic `my-append` in loops?
8. Each function has a header comment with its recursive reading?
9. S2: single `insert-if-short` definition, built from `make-inserter`?
10. Did I actually run it (show command and output) on the spec examples?

## 8. Known failure modes of AI tools for Scheme/Racket
- Reaching for `length`, `append`, `map`, `reverse`, `filter`, `foldl` by habit.
- Using `equal?` or `list?`/`symbol?`/`number?`, which are not allowed.
- Using `first`/`rest`/`empty?` (these are `racket/list`, not even in `racket/base`).
- Using `when`/`unless`/`displayln`/`printf`.
- Writing `#lang racket` instead of `#lang racket/base`.
- Leaving test calls or `(display ...)` at the top level of the solution file.
- `(if c x)` with no else branch.
- Measuring length after inserting `x` (S2), or skipping the top-level list or `()`.
- Treating `()` as an atom (it is a list: `null?` is true, `pair?` is false).
- Quadratic `append` inside recursion; non-tail recursion that is fine in Racket
  but slow/ugly on 10,000 elements.
- Forgetting the final `(newline)`, or printing extra spaces/labels.
- Evaluating `(read)` calls in an unspecified order (use `let*`).
- Claiming the code was run when it was not.
