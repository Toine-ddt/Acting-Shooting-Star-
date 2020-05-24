#lang racket

(require rackunit)
(require rackunit/text-ui)
(require raart)
(require "../src/actor.rkt")
(require "../src/runtime.rkt")

(define ac1 (actor (coord 0 0) (list) #\* 5 "1" 1 1))
(define ac1-1 (actor-send ac1 (message (list actor-move 12 0))))
(define ac2 (actor (coord 5 0) (list) #\* 3 "2" 1 1))
(define ac2-1 (actor-send ac2 (message (list actor-move 7 0))))
(define ac2-2 (actor-send ac2 (message (list actor-move 16 0))))
(define ac3 (actor (coord 3 3) (list) #\* 0 "1" 1 1))
(define ac3-1 (actor-send ac1 (message (list actor-move 12 0))))
(define ac4 (actor (coord 3 10) (list) #\* 0 "1" 1 1))
(define ac4-1 (actor-send ac1 (message (list actor-move 0 0))))
(define ac5 (actor (coord 3 1) (list) #\* 3 "1" 1 1))
(define ac5-1 (actor-send ac1 (message (list actor-move 0 14))))
(define La1-1 (list ac1-1 ac2-1))
(define Lw1-1 (Lworlds (list) 10))
(define w1-1 (world La1-1 0 Lw1-1 60))

(define La1-2 (list ac1-1 ac2-2))
(define Lw1-2 (Lworlds (list) 10))
(define w1-2 (world La1-2 0 Lw1-2 60))

(define test "-------------------test---------------------------")
test
(collision-point ac1-1 ac2-1)
test
(collision-point ac2-1 ac1-1)
test
(collision-point ac1-1 ac2-2)
test
(collision-point ac5-1 ac4-1)
test
(collision-point ac3-1 ac4-1); collision
test
(collision-point ac1-1 ac3-1)
