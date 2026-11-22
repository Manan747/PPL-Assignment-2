#lang racket/base

;;; S1: Binary Tree Traversals
;;; A tree is '() or (value left right).

;; (my-reverse lst) -> list
;; Recursive reading: the reverse of '() is acc; otherwise move the first
;;   element of lst onto acc and reverse the rest.
;; Tail recursive: yes (named let, acc carries the partial result).
(define (my-reverse lst)
  (let loop ((remaining lst) (acc '()))
    (if (null? remaining)
        acc
        (loop (cdr remaining) (cons (car remaining) acc)))))

;; (my-append a b) -> list
;; Recursive reading: appending '() to b gives b; otherwise it is the first
;;   element of a consed onto (a's rest appended to b).
;; Tail recursive: yes. a is reversed once, then its elements are pushed
;;   onto b one by one, so b is never copied.
(define (my-append a b)
  (let loop ((rev-a (my-reverse a)) (acc b))
    (if (null? rev-a)
        acc
        (loop (cdr rev-a) (cons (car rev-a) acc)))))

;; (inorder tree) -> list of values (left subtree, node, right subtree)
;; Recursive reading: walk the tree in REVERSE inorder (right, node, left)
;;   and cons each value onto acc; the last value consed is the leftmost,
;;   so acc ends up in inorder. `stack` holds nodes whose right side is done
;;   but whose own value and left subtree are still pending.
;;   - node is a real node: push it, continue into its right subtree.
;;   - node is '() and stack is empty: everything visited, return acc.
;;   - node is '(): pop the top node, add its value to acc, continue
;;     into its left subtree.
;; Tail recursive: yes (every call to loop is in tail position), and no
;;   append is needed.
(define (inorder tree)
  (let loop ((node tree) (stack '()) (acc '()))
    (cond ((pair? node)
           (loop (caddr node) (cons node stack) acc))
          ((null? stack)
           acc)
          (else
           (loop (cadr (car stack))
                 (cdr stack)
                 (cons (car (car stack)) acc))))))

;; (preorder tree) -> list of values (node, left subtree, right subtree)
;; Recursive reading: keep a stack of subtrees still to visit, starting with
;;   the whole tree.
;;   - stack empty: done; acc holds the values in reverse preorder, so
;;     reverse it once.
;;   - top is '(): drop it.
;;   - top is a node: record its value, then push right and left so that
;;     left ends up on top and is visited next (node, left, right).
;; Tail recursive: yes (every call to loop is in tail position).
(define (preorder tree)
  (let loop ((stack (list tree)) (acc '()))
    (cond ((null? stack)
           (my-reverse acc))
          ((null? (car stack))
           (loop (cdr stack) acc))
          (else
           (let ((node (car stack)))
             (loop (cons (cadr node) (cons (caddr node) (cdr stack)))
                   (cons (car node) acc)))))))

;; (postorder tree) -> list of values (left subtree, right subtree, node)
;; Recursive reading: same stack walk, but push left first and right on top,
;;   so subtrees are visited in the order node, right, left. That order is
;;   exactly postorder backwards, and consing each value onto acc reverses
;;   it again, so acc is already in postorder: no final reverse needed.
;; Tail recursive: yes (every call to loop is in tail position).
(define (postorder tree)
  (let loop ((stack (list tree)) (acc '()))
    (cond ((null? stack)
           acc)
          ((null? (car stack))
           (loop (cdr stack) acc))
          (else
           (let ((node (car stack)))
             (loop (cons (caddr node) (cons (cadr node) (cdr stack)))
                   (cons (car node) acc)))))))

;; (height tree) -> number
;; Recursive reading: the height of '() is 0; the height of a node is 1 plus
;;   the larger of its subtrees' heights. Computed as the deepest level seen:
;;   the stack holds pairs (subtree . its-depth), and best is the largest
;;   depth of any real node visited so far.
;;   - stack empty: return best.
;;   - top subtree is '(): drop it.
;;   - top subtree is a node at depth d: best becomes (max best d), and
;;     both children are pushed at depth d + 1.
;; Tail recursive: yes (every call to loop is in tail position).
(define (height tree)
  (let loop ((stack (list (cons tree 1))) (best 0))
    (cond ((null? stack)
           best)
          ((null? (car (car stack)))
           (loop (cdr stack) best))
          (else
           (let ((node (car (car stack)))
                 (depth (cdr (car stack))))
             (loop (cons (cons (cadr node) (+ depth 1))
                         (cons (cons (caddr node) (+ depth 1))
                               (cdr stack)))
                   (max best depth)))))))

;; (leaf-count tree) -> number
;; Recursive reading: '() has 0 leaves; a node whose children are both '()
;;   is one leaf; any other node has as many leaves as its two subtrees
;;   together. Computed with a stack of subtrees and a running count.
;;   - stack empty: return count.
;;   - top is '(): drop it.
;;   - top is a leaf: count + 1.
;;   - top is an inner node: push both children.
;; Tail recursive: yes (every call to loop is in tail position).
(define (leaf-count tree)
  (let loop ((stack (list tree)) (count 0))
    (cond ((null? stack)
           count)
          ((null? (car stack))
           (loop (cdr stack) count))
          ((and (null? (cadr (car stack))) (null? (caddr (car stack))))
           (loop (cdr stack) (+ count 1)))
          (else
           (let ((node (car stack)))
             (loop (cons (cadr node) (cons (caddr node) (cdr stack)))
                   count))))))

;; (print-inorder tree) -> prints the inorder list on one line.
(define (print-inorder tree)
  (display (inorder tree))
  (newline))

;; (print-all-traversals tree) -> prints inorder, preorder and postorder
;;   lists, one per line.
(define (print-all-traversals tree)
  (display (inorder tree))
  (newline)
  (display (preorder tree))
  (newline)
  (display (postorder tree))
  (newline))

;; (print-height-and-leaves tree) -> prints the list (height leaf-count).
(define (print-height-and-leaves tree)
  (display (list (height tree) (leaf-count tree)))
  (newline))
