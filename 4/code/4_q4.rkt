#lang racket/base

;;; S2: Conditionally Insert into a Nested List
;;; Elements are atoms or lists (no dotted pairs). A list is '() or a pair.

;; (my-reverse lst) -> list
;; Recursive reading: the reverse of '() is acc; otherwise move the first
;;   element of lst onto acc and reverse the remaining elements.
;; Tail recursive: yes.
(define (my-reverse lst)
  (let loop ((remaining lst) (acc '()))
    (if (null? remaining)
        acc
        (loop (cdr remaining) (cons (car remaining) acc)))))

;; (my-length lst) -> number of top-level elements of lst
;; Recursive reading: the length of '() is 0; otherwise it is 1 plus the
;;   length of the cdr. The count is carried in an accumulator.
;; Tail recursive: yes (safe for 10,000-element lists).
(define (my-length lst)
  (let loop ((remaining lst) (count 0))
    (if (null? remaining)
        count
        (loop (cdr remaining) (+ count 1)))))

;; (my-map f lst) -> list of (f e) for each top-level element e, in order
;; Recursive reading: mapping over '() gives '(); otherwise it is (f first)
;;   consed onto the map of the rest. Results are pushed onto acc (so acc is
;;   reversed) and put back in order with one my-reverse at the end.
;; Tail recursive: yes (safe for 10,000-element lists).
(define (my-map f lst)
  (let loop ((remaining lst) (acc '()))
    (if (null? remaining)
        (my-reverse acc)
        (loop (cdr remaining) (cons (f (car remaining)) acc)))))

;; (is-list? v) -> #t if v is a list ('() or a pair), #f if v is an atom.
;; (list? is not an allowed built-in; the input never has dotted pairs.)
(define (is-list? v)
  (or (null? v) (pair? v)))

;; (make-inserter x len-ok?) -> a function from a list to a list
;; Recursive reading of the returned function on lst:
;;   first transform every element (sublists recursively, atoms unchanged);
;;   then, if the ORIGINAL length of lst satisfies len-ok?, put x in front.
;; The length is taken from lst itself, before anything is inserted.
;; Walking across a list's elements is done by the tail-recursive my-map,
;; so 10,000-element lists are fine; recursion only goes as deep as the
;; nesting (100 in the hidden tests).
(define (make-inserter x len-ok?)
  (letrec ((insert
            (lambda (lst)
              (let ((len (my-length lst))
                    (inner (my-map (lambda (e) (if (is-list? e) (insert e) e))
                                   lst)))
                (if (len-ok? len)
                    (cons x inner)
                    inner)))))
    insert))

;; (insert-if-short x lst n) -> lst with x inserted at the front of every
;;   list (at every level, the top level and '() included) whose original
;;   length is less than n.
(define (insert-if-short x lst n)
  ((make-inserter x (lambda (len) (< len n))) lst))

;; (print-insert-result) reads x, lst and n from standard input, in that
;;   order, and displays (insert-if-short x lst n) followed by a newline.
;;   Nothing else is printed (no prompt).
;; let* evaluates the three reads strictly left to right.
(define (print-insert-result)
  (let* ((x (read))
         (lst (read))
         (n (read)))
    (display (insert-if-short x lst n))
    (newline)))
