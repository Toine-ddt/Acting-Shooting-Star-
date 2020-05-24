#lang racket

(require rackunit)
(require rackunit/text-ui)
(require raart)
(require "../src/actor.rkt")
(require "../src/runtime.rkt")


(define all-tests
  (test-suite
    "Tests file for time.rkt"
     (test-case
	"Basic Tests"
        (let*
          (
	  [a1 (actor (coord 1 3) (list) #\* 4 "ac1" 5 2)]	
	  [a2 (actor (coord 3 4) (list (message (list actor-move 8 8)) (message (list actor-move 8 8))) #\# 4 "ac2" 12 1)]
	  [a3 (actor (coord 5 7) (list (message (list actor-move 8 8)) (message (list actor-move 8 8))) #\# 3 "ac3" 4 10)]
	  [p (actor (coord 2 7) (list (message (list actor-move 8 8)) (message (list actor-move 8 8))) #\> 7 "ac0" 4 10)]
          [La (list p a1 a2 a3)]
	  [Ld (list a1 a3)]
          [lw (Lworlds (list) 0)]
          [w (world La 3 lw)]
          [p1 (actor (coord 2 7) (list (message (list actor-move 8 8)) (message (list actor-move 8 8)) (message (list actor-move 8 8 ))) #\> 7 "ac0" 4 10)]
          [La1 (list p1 a1 a2 a3)]
          [w1 (world La1 3 lw)]
          [p2 (actor (coord 18 23) (list) #\> 7 "ac0" 4 10)]
          [La2 (list p2 a1 a2 a3)]
          [w2 (world La2 3 lw)]
          [La3 (list p a1)]
          [w3 (world La3 0 lw)]
          [La4 (list a1 p2)]
          [w4 (world La4 0 lw)]
          [p3 (actor (coord 2 7) (list (message (list actor-move 8 8)) (message (list actor-move 8 8))) #\> 7 "ac0" 4 10)]
          [a11 (actor (coord 1 3) (list (message (list actor-move 4 0))) #\* 4 "ac1" 5 2)]
          [La5 (list a11 p3)]
          [w5 (world La5 0 lw)]
          
          
          


          [wcheck (world
                   (list
                    (actor (coord 1 2) (list) #\# 0 "toadd" 1 0)
                    (actor (coord 2 7) (list (message (list actor-move 8 8)) (message (list actor-move 8 8))) #\> 7 "ac0" 4 10)
                    (actor (coord 1 3) (list) #\* 4 "ac1" 5 2)
                    (actor (coord 3 4) (list (message (list actor-move 8 8)) (message (list actor-move 8 8))) #\# 4 "ac2" 12 1)
                    (actor (coord 5 7) (list (message (list actor-move 8 8)) (message (list actor-move 8 8))) #\# 3 "ac3" 4 10))
                   3
                   (Lworlds '() 0))])
          
          
	  

	  
	  (check-equal? (Ldeletea La a1 (list)) (list a3 a2 p))
          (check-equal? (LdeleteL2 La Ld) (list p a2))
          (check-equal? (world-search-nature w #\>) p)
          (check-equal? (world-create-actor (coord 1 2) (list) #\# 0 "toadd" 1 0 w) wcheck)
          (check-equal? (remove-actor "ac3" La) (list
                                                  (actor (coord 2 7) (list (message (list actor-move 8 8)) (message (list actor-move 8 8))) #\> 7 "ac0" 4 10)
                                                  (actor (coord 1 3) (list) #\* 4 "ac1" 5 2)
                                                  (actor (coord 3 4) (list (message (list actor-move 8 8)) (message (list actor-move 8 8))) #\# 4 "ac2" 12 1)))
          (check-equal? (world-kill-actor "ac5" w) w)
          (check-equal? (world-kill-actor "ac2" w) (world
                                                    (list
                                                     (actor (coord 2 7) (list (message (list actor-move 8 8)) (message (list actor-move 8 8))) #\> 7 "ac0" 4 10)
                                                     (actor (coord 1 3) (list) #\* 4 "ac1" 5 2)
                                                     (actor (coord 5 7) (list (message (list actor-move 8 8)) (message (list actor-move 8 8))) #\# 3 "ac3" 4 10))
                                                    3
                                                    (Lworlds '() 0)))
          
          (check-equal? (world-search-name w "ac2") a2)
          (check-equal? (world-send w p (message (list actor-move 8 8)))
                       w1)
          (check-equal? (world-update w p) w2)
          (check-equal? (tick-rec w3 (world-Lactors w3)) w4)
          (check-equal? (actor-msg w3 p) (message (list)))
          (check-equal? (runtime w3 (world (list) (world-tick w3) (world-Lw w3))) w5)
          )
        (test-case
	"Advanced Tests"
        (let*
          (   
           [a3 (actor (coord 5 7) (list (message (list actor-move 8 8)) (message (list actor-move 8 8))) #\# 3 "ac3" 4 10)]
           [p (actor (coord 2 7) (list (message (list actor-move 8 8)) (message (list actor-move 8 8))) #\> 7 "ac0" 4 10)]
           [La (list p)]
           [La2 (list p a3)]
           
           [lw0 (Lworlds (list) 10)]
           [w0 (world La 0 lw0)]
           [lw1 (Lworlds (list w0) 10)]
           [w1 (world La2 1 lw1)]
           [lw12 (Lworlds (list w0 w1) 10)]
           [w12 (world La2 1 lw12)]
           

           )

          (check-equal? (world-remove w12) w0)
          (check-equal? (Lworlds-append lw0 w0) lw1)
          (check-equal? (world-append w1 w1) w12)
           
           )))))
          
(printf "Running tests\n")
(run-tests all-tests)

