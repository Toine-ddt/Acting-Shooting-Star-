#lang racket

(require rackunit)
(require rackunit/text-ui)
(require "../src/actor.rkt")

(define all-tests
  (test-suite
   "Tests file for actor project"
     (test-case
      "Basic-use of actor's functions"
       (let* ( 
              [a1 (actor (coord 1 3) (list) "player" 4 "p1" 5 2)]
              [a1-1 (actor-send a1 (message (list actor-move 1 0)))]
              [a1-2 (actor-remove-msg a1-1)]
              [a1-3 (actor-move a1 2 0)]
              [a1-4 (actor-move a1 -2 -120)]
              [a1-5 (actor-hit a1 3)]
              [a1-6 (actor-hit a1 -5)]
              [a1-7 (actor-send a1 (message (list actor-hit -5)))]
              [a1-8 (actor-send a1-7 (message (list actor-move 4 4)))]
              [a1-9 (actor-execute-msg a1-8)]
              [a1-9 (actor-execute-msg a1-8)]
              [a1-10 (actor-send a1 (message (list actor-move 3 4)))]
              [a1-11 (actor-send a1-10 (message (list actor-create
                                                       (list (coord 3 4))
                                                       (list (list))
                                                       (list "wall")
                                                       (list 4)
                                                       (list "ac2")
                                                       (list 12)
                                                       (list 1))))]
              [res1 (response a1-11 (list) (list))]
              [res1-1 (actor-update res1)])
         
         (check-equal? (actor-location a1) (coord 1 3))
         (check-equal? (actor-mail-box a1-2) (actor-mail-box a1))
         (check-equal? (actor-location a1-3) (coord 3 3))
         (check-equal? (actor-location a1-4) (coord -1 -117))
         (check-equal? (actor-life a1-5) 2)
         (check-equal? (actor-life a1-6) 10)
         (check-equal? (actor-location a1-9) (coord 5 7))
         (check-equal? (actor-location (response-main res1-1)) (coord 4 7))
         (check-equal? (actor-life (car (response-Lactors res1-1))) 12)
         )
       )
     )
  )

(run-tests all-tests)