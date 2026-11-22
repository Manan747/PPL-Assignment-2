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
