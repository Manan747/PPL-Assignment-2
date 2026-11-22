#lang racket/base
;;; Tests for S2 (code/4_q4.rkt).
;;; Run from the tests/ folder:  racket test_q4.rkt
;;; Test files may use anything; the restricted built-ins apply only to code/.

(require rackunit racket/port racket/string racket/file racket/runtime-path)

;; Load the solution module and reach its (unexported) definitions.
(define-runtime-path solution "../code/4_q4.rkt")
(dynamic-require solution #f)
(define ns (module->namespace solution))
(define (fn name) (eval name ns))

;; Feed text to standard input, run print-insert-result, capture its output.
(define (run-with-input text)
  (with-output-to-string
    (lambda ()
      (with-input-from-string text (lambda () ((fn 'print-insert-result)))))))

(define (insert x lst n) ((fn 'insert-if-short) x lst n))

;; --- loading prints nothing ------------------------------------------------
(check-equal? (with-output-to-string (lambda () (dynamic-require solution #f))) ""
              "loading the file prints nothing")

;; --- S2.a: the four examples from the assignment, through standard input ----
(check-equal? (run-with-input "42 ((1 2) (3 4 5) (6) ()) 3")
              "((42 1 2) (3 4 5) (42 6) (42))\n")
(check-equal? (run-with-input "0 (((1) 2) (3) ((4 5 6) ())) 3")
              "((0 (0 1) 2) (0 3) (0 (4 5 6) (0)))\n")
(check-equal? (run-with-input "7 () 3") "(7)\n")
(check-equal? (run-with-input "7 () 0") "()\n")

;; Input spread over several lines is read the same way.
(check-equal? (run-with-input "42\n((1 2)\n (3 4 5) (6) ())\n3\n")
              "((42 1 2) (3 4 5) (42 6) (42))\n")

;; --- edge cases for insert-if-short -----------------------------------------
;; n = 0: nothing is ever shorter than 0, so the list is unchanged.
(check-equal? (insert 'x '((1) () (2 3)) 0) '((1) () (2 3)))
;; n = 1: only empty lists get x.
(check-equal? (insert 'x '((1) () (2 3)) 1) '((1) (x) (2 3)))
;; Large n: every list, at every level, gets x.
(check-equal? (insert 'x '(a (b (c))) 100) '(x a (x b (x c))))
;; Length is measured BEFORE inserting: (1 2) has length 2 < 3, so it gets x
;; once, even though the result (x 1 2) has length 3.
(check-equal? (insert 'x '((1 2)) 3) '(x (x 1 2)))
;; Top level is treated like every other list.
(check-equal? (insert 'x '(a b) 3) '(x a b))
(check-equal? (insert 'x '(a b c) 3) '(a b c))
;; Atoms (numbers and symbols) are never touched.
(check-equal? (insert 0 '(1 a 2 b) 2) '(1 a 2 b))
;; Nested empty lists.
(check-equal? (insert 'x '(() (()) ((()))) 2) '((x) (x (x)) (x (x (x)))))

;; --- stress: nesting depth 100 and 10,000 elements --------------------------
(define (nest d) (if (= d 0) '() (list (nest (- d 1)))))
(define (depth l) (if (null? l) 0 (+ 1 (depth (car l)))))
(define (count-x l)
  (cond ((null? l) 0)
        ((pair? l) (+ (count-x (car l)) (count-x (cdr l))))
        ((eq? l 'x) 1)
        (else 0)))
(define deep (nest 100))
(check-equal? (insert 'x deep 0) deep "depth 100, n = 0: unchanged")
(check-equal? (count-x (insert 'x deep 2)) 101 "depth 100: x at all 101 levels")

(define wide (for/list ((i (in-range 10000))) i))
(define wide-result (insert 'x wide 10001))
(check-equal? (length wide-result) 10001 "10,000 elements: one x added")
(check-equal? (car wide-result) 'x)
(check-equal? (cdr wide-result) wide "10,000 elements: order kept")
(define wide-sub (for/list ((i (in-range 10000))) (list i)))
(check-equal? (insert 'x wide-sub 2)
              (for/list ((i (in-range 10000))) (list 'x i))
              "10,000 sublists: each gets x, top level does not")

;; --- helpers and make-inserter ----------------------------------------------
(check-equal? ((fn 'my-length) '(1 (2 3) () 4)) 4)
(check-equal? ((fn 'my-length) '()) 0)
(check-equal? ((fn 'my-map) (lambda (v) (* v v)) '(1 2 3)) '(1 4 9))
(check-equal? ((fn 'my-map) (lambda (v) v) '()) '())
;; make-inserter with a different length rule: lists of length exactly 2.
(check-equal? (((fn 'make-inserter) 'e (lambda (len) (= len 2))) '(1 (2 3) (4)))
              '(1 (e 2 3) (4)))

;; --- file structure ----------------------------------------------------------
(define source (file->string solution))
(check-true (string-prefix? source "#lang racket/base") "starts with #lang racket/base")
(check-equal? (length (regexp-match* #rx"\\(define \\(insert-if-short" source)) 1
              "exactly one definition of insert-if-short")
(check-true (regexp-match? #rx"make-inserter" source) "insert-if-short uses make-inserter")

(display "S2 tests finished (rackunit prints only failures).")
(newline)
