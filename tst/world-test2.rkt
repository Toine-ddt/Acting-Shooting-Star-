#lang racket

(require rackunit)
(require rackunit/text-ui)
(require raart)
(require "../src/actor.rkt")
(require "../src/runtime.rkt")


(define all-tests
  (test-suite
    "Tests de l'implémentation de la structure world"
     (test-case
	"Fonctions non-spécifiques à une partie en particulier"
        (let*
          (
           [a1 (actor (coord 1 3) (list) #\* 4 "ac1" 5 2)]
           [a2 (actor (coord 3 4) (list) #\# 4 "ac2" 12 1)]
           [La1 (list a1 a2)]
           [Lw1 (Lworlds (list) 10)]
           [fps 10]
           [w1 (world La1 0 Lw1 fps)]
           [a3 (actor (coord 5 7) (list) #\# 3 "ac3" 4 10)]
           [La2 (list a3 a1 a2)]
           [w2 (world La2 0 Lw1 fps)])
          
          (check-equal? (world-search-nature w1 #\*) a1)
          (check-equal? (world-search-name w1 "ac1") a1)
          (check-equal? (world-create-actor (coord 5 7) (list) #\# 3 "ac3" 4 10 w1) w2)
          (check-equal? (world-kill-actor "ac3" w2) w1)
          )
        (test-case
	"Fonctions utilisées dans word-tick"
        (let*
          (
           [a11 (actor (coord 1 3) (list (message (list actor-move 8 8))) #\* 4 "ac1" 5 2)]
           [a12 (actor (coord 9 11) (list) #\* 4 "ac1" 5 2)] 
           [a22 (actor (coord 13 12) (list) #\# 4 "ac2" 12 1)]
           [a21 (actor (coord 3 4) (list (message (list actor-move 10 8))) #\# 4 "ac2" 12 1)]
           [La1 (list a11 a21)]
           [Lw1 (Lworlds (list) 10)]
           [fps 10]
           [w1 (world La1 0 Lw1 fps)]
           [a3 (actor (coord 5 7) (list) #\# 3 "ac3" 4 10)]
           [La2 (list a12 a21)]
           [w2 (world La2 0 Lw1 fps)]
           [La3 (list a22 a12)]
           [w3 (world La3 0 Lw1 fps)]
           )
          (check-equal? (world-update w1 a11) w2)
          (check-equal? (tick-rec w1 La1) w3)
          )

        (test-case
         "Fonction runtime"
         (let*
             (
              [a11 (actor (coord 1 3) (list) #\# 4 "ac1" 5 2)]
              [a12 (actor (coord 1 3) (list (message (list actor-move 0 4))) #\# 4 "ac1" 5 2)] 
              [a21 (actor (coord 13 12) (list) #\# 4 "ac2" 12 1)]
              [a22 (actor (coord 13 12) (list (message (list actor-move 0 4))) #\# 4 "ac2" 12 1)]
              [La1 (list a11 a21)]
              [La2 (list a22 a12)]
              [Lw1 (Lworlds (list) 10)]
              [fps 10]
              [w1 (world La1 0 Lw1 fps)]
              [w2 (world La2 0 Lw1 fps)]
              [w0 (world (list) 0 Lw1 fps)]
              
              )
           (check-equal? (runtime w1 w0) w2)
           )
         
           (test-case
	"Fonctions utilisées pour remonter dans le temps"
        (let*
          (
           [a1 (actor (coord 5 7) (list (message (list actor-move 8 8)) (message (list actor-move 8 8))) #\# 3 "ac1" 4 10)]
           [a0 (actor (coord 2 7) (list (message (list actor-move 8 8)) (message (list actor-move 8 8))) #\> 7 "ac0" 4 10)]
           [La0 (list a1 a0)]
      
           [fps 10]
           [Lw01 (Lworlds (list) 10)]
           
           [w0 (world La0 0 Lw01 fps)]
           [w01 (world La0 0 Lw01 fps)]
           [Lw1 (Lworlds (list w01) 10)]
           [Lw2 (Lworlds (list w01 w01) 10)]
           [w1 (world La0 0 Lw1 fps)]
           [w2 (world La0 0 Lw2 fps)]
           )

          
          (check-equal? (Lworlds-append Lw01 w0) Lw1)
          (check-equal? (world-append w0 w01) w1)
          ;(check-equal? (world-remove w2) w0)
          )))))))
              

          
          
          
         
          

  
          
(printf "Running tests\n")
(run-tests all-tests)

