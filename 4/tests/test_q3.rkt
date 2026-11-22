#lang racket/base
;;; Tests for S1 (code/4_q3.rkt).
;;; Run from the tests/ folder:  racket test_q3.rkt
;;; Test files may use anything; the restricted built-ins apply only to code/.

(require rackunit racket/port racket/runtime-path)

;; Load the solution module and reach its (unexported) definitions.
(define-runtime-path solution "../code/4_q3.rkt")
(dynamic-require solution #f)
(define ns (module->namespace solution))
(define (fn name) (eval name ns))

;; Run a print function and capture exactly what it printed.
(define (output-of name tree)
  (with-output-to-string (lambda () ((fn name) tree))))

;; Trees from the assignment.
(define t1 '(4 (2 (1 () ()) (3 () ())) (6 (5 () ()) (7 () ()))))
(define t2 '(1 () (2 () (3 () ()))))
(define t3 '(a (b () ()) (c () ())))
(define empty-tree '())

;; Extra edge cases.
(define single '(9 () ()))
(define left-chain '(3 (2 (1 () ()) ()) ()))
(define (chain n acc) (if (= n 0) acc (chain (- n 1) (list n acc '()))))
(define deep (chain 100000 '()))

;; --- loading prints nothing ------------------------------------------------
(check-equal? (with-output-to-string (lambda () (dynamic-require solution #f))) ""
              "loading the file prints nothing")

;; --- S1.a print-inorder -----------------------------------------------------
(check-equal? (output-of 'print-inorder t1) "(1 2 3 4 5 6 7)\n")
(check-equal? (output-of 'print-inorder t2) "(1 2 3)\n")
(check-equal? (output-of 'print-inorder t3) "(b a c)\n")
(check-equal? (output-of 'print-inorder empty-tree) "()\n")

;; --- S1.b print-all-traversals ----------------------------------------------
(check-equal? (output-of 'print-all-traversals t1)
              "(1 2 3 4 5 6 7)\n(4 2 1 3 6 5 7)\n(1 3 2 5 7 6 4)\n")
(check-equal? (output-of 'print-all-traversals t2) "(1 2 3)\n(1 2 3)\n(3 2 1)\n")
(check-equal? (output-of 'print-all-traversals t3) "(b a c)\n(a b c)\n(b c a)\n")
(check-equal? (output-of 'print-all-traversals empty-tree) "()\n()\n()\n")

;; --- S1.c print-height-and-leaves -------------------------------------------
(check-equal? (output-of 'print-height-and-leaves t1) "(3 4)\n")
(check-equal? (output-of 'print-height-and-leaves t2) "(3 1)\n")
(check-equal? (output-of 'print-height-and-leaves t3) "(2 2)\n")
(check-equal? (output-of 'print-height-and-leaves empty-tree) "(0 0)\n")

;; --- edge cases ---------------------------------------------------------------
(check-equal? (output-of 'print-all-traversals single) "(9)\n(9)\n(9)\n")
(check-equal? (output-of 'print-height-and-leaves single) "(1 1)\n")
(check-equal? (output-of 'print-all-traversals left-chain) "(1 2 3)\n(3 2 1)\n(1 2 3)\n")
(check-equal? (output-of 'print-height-and-leaves left-chain) "(3 1)\n")
(check-equal? (output-of 'print-height-and-leaves deep) "(100000 1)\n"
              "100,000-node chain: no stack overflow")
(check-equal? ((fn 'my-append) '(1 2) '(3 4)) '(1 2 3 4))
(check-equal? ((fn 'my-append) '() '(3)) '(3))
(check-equal? ((fn 'my-reverse) '(1 2 3)) '(3 2 1))

(display "S1 tests finished (rackunit prints only failures).")
(newline)
