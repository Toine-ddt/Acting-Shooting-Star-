#lang racket

(require "actor.rkt")

(require racket/flonum)

(require
  (prefix-in lux: lux)
  (prefix-in raart: raart))


(struct Lworlds (list len)#:transparent)
;list : liste de world de longueur maximale len, du world le plus ancien au plus récent de gauche à droite

(struct world (Lactors tick Lw fps) ;Lactors  -> liste des acteurs que contient le world, tick:temps, player: actor joueur, Lw : structure qui contient les n derniers worlds
  #:transparent
  #:methods lux:gen:word
  [(define (word-fps w)      ;; FPS desired rate
     (world-fps w))
   (define (word-label s ft) ;; Window label of the application
     "JUST ASCII IT!")
   (define (word-event w e)  ;; Event Handler
     ;(let* ((tmpw (world-append w w))
     ;(nw
     (match e
       ["m" (if (zero? (modulo (world-tick w) 2))
                (let ((player (world-search-nature w #\>)))
                  (world-create-actor (coord (coord-x (actor-location player)) (+ 2 (coord-y (actor-location player))))
                                      (list)
                                      #\-
                                      1
                                      (number->string (- (world-tick w)))
                                      1
                                      1
                                      w))
                w)]
       ["j" (world-remove w)]
       ["z" (let ((player (world-search-nature w #\>)))
              (world-send w player (message (list actor-move (- (actor-speed player)) 0))))]
       ["s" (let ((player (world-search-nature w #\>)))
              (world-send w player (message (list actor-move (actor-speed player) 0))))]
       ["q" (let ((player (world-search-nature w #\>)))
              (world-send w player (message (list actor-move 0 (- (actor-speed player))))))]
       ["d" (let ((player (world-search-nature w #\>)))
              (world-send w player (message (list actor-move 0 (actor-speed player)))))]
       ["p" #f]  ;; Quit the application
       [_ w]
       ))
       ;(runtime-collide (runtime nw (world (list) (world-tick w) (world-Lw w))) (world-Lactors w))
   
   ;print the world in parameter
   (define (word-output w)
     (match-define (world Lactors tick Lw fps) w)
     ;(raart:draw-here
     (raart:matte 20 20
                  (raart:fg 'green 
                            (raart:frame (raart:bg 'yellow                           
                                                   (raart:fg 'red
                                                             (foldl place-at-reverse (raart:blank 1 1) (world-decompose w))))))))
     

   (define (word-tick w)   ;; Update function after one tick of time
     (let* ((w1 (run w))
            (w2 (tick-rec w1 (world-Lactors w1)))
            (w3 (world (world-Lactors w2) (+ 1 (world-tick w2)) (world-Lw w2) (world-fps w2))))
       (world-append w3 w3)))])

;Renvoie le premier acteur dans la pile d'acteur qui correspond au parametres de recherche
;world * char -> actor
(define (world-search-nature old-world val-nature)
  (if (null? (world-Lactors old-world))
      #f
      (if (char=? val-nature (actor-nature (car (world-Lactors old-world))))
          (car (world-Lactors old-world))
          (world-search-nature (world (cdr (world-Lactors old-world)) (world-tick old-world) (world-Lw old-world) (world-fps old-world))
                               val-nature))))

;Renvoie le premier acteur dans la pile d'acteur qui correspond au parametres de recherche
;world * string -> actor
(define (world-search-name old-world val-name)
  (if (null? (world-Lactors old-world))
      #f
      (if (string=? val-name (actor-name (car (world-Lactors old-world))))
          (car (world-Lactors old-world))
          (world-search-name (world (cdr (world-Lactors old-world)) (world-tick old-world) (world-Lw old-world) (world-fps old-world))
                        val-name))))   


(define (world-create-actor location mail-box nature speed name life damage old-world) ;Créer un acteur et l'ajoute au monde : parametres * world -> world
  (world (cons (actor location mail-box nature speed name life damage)
               (world-Lactors old-world))
         (world-tick old-world)
         (world-Lw old-world)
         (world-fps old-world)))

(define (world-kill-actor dead old-world);Supprime un acteur du monde : string * world->world
  (world (remove-actor dead (world-Lactors old-world))
         (world-tick old-world)
         (world-Lw old-world)
         (world-fps old-world)))

(define (world-send old-world old-actor msg);Le monde envoie un message à un acteur. Cet acteur muni d'un nouveau message remplace l'ancien dans le monde world * actor * message -> world
	(if (world-search-name old-world (actor-name old-actor))
     	    (world (cons (actor-send old-actor msg) (world-Lactors (world-kill-actor (actor-name old-actor) old-world)))
            (world-tick old-world)
            (world-Lw old-world)
            (world-fps old-world))
	    old-world))

(define (world-collision Ltouch old-world);Fonction finale de traitement de collision qui calcule le "number" et "damage-total" puis applique collide liste-actor * world -> world
  (collide-actor Ltouch old-world (length Ltouch) (apply + (map actor-damage Ltouch))))

;Utilisee dans world-kill-actor
;enlève un acteur fixé d'une liste sur le modèle d'une pile
; string * liste-actor -> liste-actor
(define (remove-actor dead pile)
(if (null? pile)
    pile
    (if (string=? dead (actor-name (car pile)))
    	  (cdr pile)
      	  (cons (car pile) (remove-actor dead (cdr pile))))))

;Utilisee dans world-collision
;Gère la collision entre une liste acteurs et en tue ceux qui
;n'ont plus de vie pour un nombre de d'acteur et un dégât total fixés
; Liste-actors * world * int * int -> world
(define (collide-actor Ltouch old-world number total-damage)
  (if (or (null? Ltouch) (= number 1))
      old-world
      (collide-actor (cdr Ltouch)
                     (world-send old-world (car Ltouch) (message (list actor-hit (if (char=? #\# (actor-nature (car Ltouch)))
                                                                                     0
                                                                                     (- (/ total-damage
                                                                                           (sub1 number));(sub1 number)->number
                                                                                        (/ (actor-damage (car Ltouch))
                                                                                           (sub1 number)))))));(sub1 number)->number
                     number
                     total-damage)))
  

;----------------------------------------------


;----------------------------------------------
;fonctions utilisées dans world-tick

;(define (world-update old-world old-actor);Le monde tous les messages d'un acteur. Cet acteur remplace l'ancien dans le monde world * actor * message -> world
;  (world (cons (actor-update old-actor) (world-Lactors (world-kill-actor (actor-name old-actor) old-world)))
;         (world-tick old-world)
;         (world-Lw old-world)
;         (world-fps old-world)))

(define (world-update old-world old-actor);Le monde tous les messages d'un acteur. Cet acteur remplace l'ancien dans le monde world * actor * message -> world
  (let ((nw-res (actor-update (response old-actor (list) (list)))))
    (world (if (> (actor-life (response-main nw-res)) 0)
               (cons (response-main nw-res)
                     (append (response-Lactors nw-res) (world-Lactors (world-kill-actor (actor-name old-actor) old-world))))
               (append (response-Lactors nw-res) (world-Lactors (world-kill-actor (actor-name old-actor) old-world))))
           (world-tick old-world)
           (world-Lw old-world)
           (world-fps old-world))))

;retourne un nouveau monde les mail-box des acteurs vidées
(define (tick-rec w La)
  (if (null? La) ; longeur La =1
      w
      (tick-rec (world-update w (car La))
                (cdr La))))

      
      

;----------------------------------------------


;----------------------------------------------
;fonctions utiles pour collide-detect
;;retourne le temps juste pour que l'actor arrive au point z
(define (time-before-collide actor z)
  (define v (actor-speed actor))
  (define a (car (test-move actor)))
  (define b (last (test-move actor)))
  (define tf (time a b v))
  (define x (coord-x (actor-location actor)))
  (define y (coord-y (actor-location actor)))
  (define fz (- (+ y (* z (/ b a))) (* x (/ b a))))

  (cond
    [ (and (< a 0) (< b 0))
      (let(( t1 (* tf (/ (- (+ (floor z) 1) x) a)))
        (t2 (* tf (/ (- (+ (floor fz) 1) y) b))))
        (min t1 t2))]
        
        
    [ (and (> a 0) (> b 0))
      (let(( t1 (* tf (/ (- (floor z) x) a)))
        (t2 (* tf (/ (- (floor z) y) b))))
        (min t1 t2))]
        
        
    [ (and (< a 0) (> b 0))
      (let(( t1 (* tf (/ (- (+ (floor z) 1) x) a)))
        (t2 (* tf (/ (- (floor z) y) b))))
        (min t1 t2))]

    [ (and (> a 0) (< b 0))
      (let(( t1 (* tf (/ (- (floor z) x) a)))
        (t2 (* tf (/ (- (+ (floor fz) 1) y) b))))
        (min t1 t2))]
    [ (and (> a 0) (= b 0))
      (let(( t1 (* tf (/ (- (floor z) x) a))))
        t1)]

    [ (and (< a 0) (= b 0))
      (let(( t1 (* tf (/ (- (+ (floor z) 1) x) a))))
        t1)]
     
    ))
;;retourne le temps juste pour que l'actor arrive au point z
;;(sert à calculer l'intervalle de temps pendant lequel actor reste au point collision

(define (time-after-collide actor z)
  (define v (actor-speed actor))
  (define a (car (test-move actor)))
  (define b (last (test-move actor)))
  (define tf (time a b v))
  (define x (coord-x (actor-location actor)))
  (define y (coord-y (actor-location actor)))
  (define fz (- (+ y (* z (/ b a))) (* x (/ b a))))

  (cond
    [ (and (< a 0) (< b 0))
      (let(( t1 (* tf (/ (- (floor z) x) a)))
        (t2 (* tf (/ (- (floor z) y) b))))
        (min t1 t2))]
        
        
    [ (and (> a 0) (> b 0))
      (let((t1 (* tf (/ (- (+ (floor z) 1) x) a)))
        (t2 (* tf (/ (- (+ (floor fz) 1) y) b))))
        (min t1 t2))]
        
        
    [ (and (< a 0) (> b 0))
      (let(( t1 (* tf (/ (- (floor z) x) a)))
        (t2 (* tf (/ (- (+ (floor fz) 1) y) b))))
        (min t1 t2))]

    [ (and (> a 0) (< b 0))
      (let(( t1 (* tf (/ (- (+ (floor z) 1) x) a)))
        (t2 (* tf (/ (- (floor z) y) b))))
        (min t1 t2))]
    [ (and (> a 0) (= b 0))
      (let(( t1 (* tf (/ (- (+ (floor z) 1) x) a))))
        t1)]
    [ (and (< a 0) (= b 0))
      (let(( t1 (* tf (/ (- (floor z) x) a))))
        t1)]
     
    ))



;verifie si deux intervalles se rencontrent ->1 si oui 0 sinon
(define (intersection-interval tav1 tap1 tav2 tap2)
  (cond
    [ (and (<= tap2 tap1) (>= tap2 tav1))
       1]
    [ (and (<= tap1 tap2) (>= tap1 tav2))
       1]
    [else
     0]
    ))

(define (time x y v)
  (if (not (= 0 v))
      (/ (sqrt (+ (* x x) (* y y))) v)
      0))

(define (test-move a)
  (if (null? (actor-mail-box a))
      (list 0 0)
      (if (eq? (car (message-Lpara (car (actor-mail-box a)))) actor-move)
          (cdr (message-Lpara (car (actor-mail-box a))))
          (list 0 0))))

;decider s'il y a collision entre 2 actors
;; 1 si oui 0 sinon


(define (collision-point actor1 actor2)
  (define v1 (actor-speed actor1))
  (define v2 (actor-speed actor2))
  ;(define a (coord-x (cdr ( message-Lpara (car (actor-mail-box actor1))))))
  ;(define b (coord-y (cdr ( message-Lpara (car (actor-mail-box actor1))))))
  ;(define c (coord-x (cdr ( message-Lpara (car (actor-mail-box actor2))))))
  ;(define d (coord-y (cdr ( message-Lpara (car (actor-mail-box actor2))))))
  (define x1 (coord-x (actor-location actor1)))
  (define x2 (coord-x (actor-location actor2)))
  (define y1 (coord-y (actor-location actor1)))
  (define y2 (coord-y (actor-location actor2)))
  
  (define a (car (test-move actor1)))
  (define b (last (test-move actor1)))
  (define c (car (test-move actor2)))
  (define d (last (test-move actor2)))
  (define tf1 (time a b v1))
  (define tf2 (time c d v2))
      
  ;(define tf1 (/ (sqrt (+ (* a a) (* b b))) v1)) ;division par zéro si v1=0
  ;(define tf2 (/ (sqrt (+ (* c c) (* d d))) v2)) ;de meme ici
  
  (if (and (not (zero? a)) (not (zero? c)) (or (not (= 0 b))  (not (= 0 d))))
      (cond
        [ (zero? (- (/ b a) (/ d c))) 0]
        [else (let( (z (/ (+ (- y2 y1) (- (* (x1 (/ b a))) (* (x2 (/ d c))))) (- (/ b a) (/ d c)))))
                   (cond
                     [ ( and (and (<= z (max (+ x1 a) x1)) (>= z (min (+ x1 a) x1))))  (and (<= z (max (+ x2 c) x2)) (>= z (min (+ x2 c) x2)))
                           (let*( (ta1 ( time-before-collide actor1 z))
                           (tb1 ( time-after-collide actor1 z))
                           (ta2 ( time-before-collide actor2 z))
                           (tb2 ( time-after-collide actor2 z)))
                             (intersection-interval ta1 tb1 ta2 tb2))]
                     [else 0]
                   
                             )
                )]
                     
                   
              )
      
        
      (if (and (not (zero? a)) (not (zero? c)) (and (= 0 b) (= 0 d)))
          (cond
            [(and (= y1 y2) (> (* a c) 0) (< x1 x2) (> v1 v2) (<= (/ (- x2 x1) (- v1 v2)) (min tf1 tf2))) 1]
            [(and (= y1 y2) (> (* a c) 0) (< x2 x1) (> v2 v1) (<= (/ (- x2 x1) (- v1 v2)) (min tf1 tf2))) 1]
            [(and (< (* a c) 0)  (= y1 y2) (>= (+ (abs a) (abs c)) (abs (- x1 x2)))) 1]
            [else 0])

          (if (and (not (zero? a)) (zero? c) (and (= 0 b) (= 0 d)))
          (cond
            [(and (>= x1 x2) (< a 0) (= y1 y2) (>= (abs a) (abs (- x1 x2)))) 1]
            [(and (>= x2 x1) (> a 0) (= y1 y2) (>= (abs a) (abs (- x1 x2)))) 1]
            [else 0])
          (if (and (not (zero? c)) (zero? a) (and (= 0 b) (= 0 d)))
          (cond
            [(and (>= x2 x1) (< c 0) (= y2 y1) (>= (abs c) (abs (- x1 x2)))) 1]
            [(and (>= x1 x2) (> c 0) (= y2 y1) (>= (abs c) (abs (- x1 x2)))) 1]
            [else 0])

          


          
          (if (and (zero? a) (zero? c))
              (cond
                [(not (zero? (- x1 x2)))
                     0]
                [else
                 (cond
                   [(and (zero? b) (> d 0) (< y2 y1) (>= (+ y2 d) y1))
                    1]
                   [(and (zero? b) (< d 0) (> y2 y1) (<= (+ y2 d) y1))
                    1]
                   [(and (zero? d) (> b 0) (< y1 y2) (>= (+ y1 b) y2))
                    1]
                   [(and (zero? d) (< b 0) (> y1 y2) (<= (+ y1 b) y2))
                    1]
                   [ ( and (not (zero? (abs (- y1 y2)))) (< (* b d) 0) (>= (+ (abs b) (abs d)) (abs (- y1 y2))))
                     1]
                   
                   [else 0]
                   )
                 ]
                )
              
              
              (if (and (not (zero? a)) (zero? c))
                  (let( (f  (- (+ y1 (* x2 (/ b a))) (* x1 (/ b a)))))
                    (cond
                      [ ( and (<= x2 (max x1 (+ x1 a))) (>= x2 (min x1 (+ x1 a))) (<= f (max y2 (+ y2 d))) (>= f (min y2 (+ y2 d))))
                        (let* ( (t1 ( time-before-collide actor1 x2))
                                (t2 ( time-after-collide actor1 x2)))
                          (cond
                            [ (> d 0)
                              (let* ( (t1s (* tf2 (/ (- (floor f) y2) d)))
                                      (t2s (* tf2 (/ (- (+ (floor f) 1) y2) d))))
                                (intersection-interval t1 t2 t1s t2s))
                              
                              
                              ]
                            [ (< d 0)
                              (let* ( (t1s (* tf2 (/ (- (+ (floor f) 1) y2) d)))
                                      (t2s (* tf2 (/ (- (floor f) y2) d))))
                                (intersection-interval t1 t2 t1s t2s))
                              
                              ]))]
                      
                      
                      
                      [else 0]
                      ))
                  
                  
                  (if (and (not (zero? c)) (zero? a))
                      (let( (f2  (- (+ y2 (* x1 (/ d c))) (* x2 (/ d c)))))
                        (cond
                          [ ( and (<= x1 (max x2 (+ x2 c))) (>= x1 (min x2 (+ x2 c))) (<= f2 (max y1 (+ y1 b))) (>= f2 (min y1 (+ y1 b))))
                            (let* ( (tt1 ( time-before-collide actor2 x1))
                                    (tt2 ( time-after-collide actor2 x1)))
                              (cond
                                [ (> b 0)
                                  (let* ( (tt1s (* tf1 (/ (- (floor f2) y1) b)))
                                          (tt2s (* tf1 (/ (- (+ (floor f2) 1) y1) b))))
                                    (intersection-interval tt1 tt2 tt1s tt2s))
                                  
                                  
                                  ]
                                [ (< b 0)
                                  (let* ( (t1s (* tf1 (/ (- (+ (floor f2) 1) y1) b)))
                                          (t2s (* tf1 (/ (- (floor f2) y1) b))))
                                    (intersection-interval tt1 tt2 t1s t2s))
                                  
                                  ]
                                ))]
                          
                          
                          
                          [else 0]
                          )
                        )
                      0
                      ))))))))



         
  

                   
;detecter s'il y a collision entre un actor et une list d'actors
;;retourne une liste des actors qui sont entrés en collision avec un certain actor
(define (collide-detect actor Lactors Lfinals)
  ;ajout de cette condition qui teste que lactors n'est pas vide
  (if (null? Lactors)
      Lfinals
      (if (zero? (collision-point actor (car Lactors)))
          (collide-detect actor (cdr Lactors) Lfinals)
          (collide-detect actor (cdr Lactors) (cons (car Lactors) Lfinals)))))


;----------------------------------------------
;fonctions utilisées dans world-event


;(define (collid-detect a La)
 ; (list))

(define (LdeleteL2 La Ld) ;retourne La\Ld
  (if (null? Ld)
      La
      (LdeleteL2 (Ldeletea La (car Ld) (list)) (cdr Ld))))

(define (Ldeletea La a Lres) ; retourne La\a
  (if (null? La)
      Lres
      (if (string=? (actor-name (car La)) (actor-name a))
          (Ldeletea (cdr La) a Lres)
          (Ldeletea (cdr La) a (cons (car La) Lres)))))

(define (runtime-collide w La) ; fonction recursive qui renvoie le monde avec la liste d'acteurs remplie d'un message indiquant si il y a eu collision
  (if (null? La)
      w
      (let* ((a (car La))
             (colL (collide-detect (car La) (cdr La) (list)))
             (Lcol (cons a colL))
             (tmpLa (LdeleteL2 La Lcol)))
        (runtime-collide
         (world-collision Lcol w)
         (cdr La)))))
         ;tmpLa))))



(define (runtime oldworld newworld) ;renvoie un nouveau monde avec les mail-box des acteurs actualisée avec les déplacements à faire
  (if (null? (world-Lactors oldworld))
      newworld
      (runtime (world (cdr (world-Lactors oldworld)) (world-tick oldworld) (world-Lw oldworld) (world-fps oldworld))
               (world (cons
                       (if ( char=? (actor-nature (car (world-Lactors oldworld))) #\>)
                           (car (world-Lactors oldworld))
                           (world-msg (actor-msg
                                        newworld   
                                        (car (world-Lactors oldworld))) ;renvoie le premier acteur
                                      (car (world-Lactors oldworld)))) ;renvoie un nouvel acteur avec sa mail-box actualisé                
                       (world-Lactors newworld))
                      (world-tick oldworld)
                      (world-Lw oldworld)
                      (world-fps oldworld))))) ;renvoie le message à envoyer à l'acteur

(define (actor-msg w a) ;fonction qui renvoie sous forme d'un message l'instruction que l'actor a doit faire avant le prochai tick
  (cond [(char=? (actor-nature a) #\#)
         (list (message (list actor-move 0 (actor-speed a))))]
        [(char=? (actor-nature a) #\-)
         (list (message (list actor-move 0 (actor-speed a))))]
        [(char=? (actor-nature a) #\<)
         (if (eq? 0 (enemy-fire a (world-tick w) 13))
                              (list (enemy-move (world-tick w) 13 (actor-speed a)))
                              (list (enemy-move (world-tick w) 13 (actor-speed a))
                                    (enemy-fire a (world-tick w) 13)))]
        [(char=? (actor-nature a) #\*)
         ;(list (enemy-move (world-tick w) 1 -1))]
         (list (enemy-move (world-tick w) 13 (actor-speed a)))]
	[else (list)]))

(define (world-msg Lmsg old-actor)
  (if (empty? Lmsg)
      old-actor
      (world-msg (cdr Lmsg) (actor-send old-actor (car Lmsg)))))

;fonction qui gère le déplacement de enemis
(define (enemy-move tick n speed)
  (if (zero? (modulo tick 4))
      (cond [(= (modulo tick n) 0)
         (message (list actor-move 0 speed))]
            [(< (modulo tick n) (/ n 2))
             (message (list actor-move speed 0))]
            [else
             (message (list actor-move (- speed) 0))])
      (message (list actor-move 0 0))))
      
(define (enemy-fire enemy tick n)
  (if (= (modulo tick n) 0)
      (message (list actor-create
                     (list (coord (coord-x (actor-location enemy))
                                  (sub1 (coord-y (actor-location enemy)))))
                     (list (list))
                     (list #\-)
                     (list -1)
                     (list (wall-name (coord-x (actor-location enemy))
                                  (sub1 (coord-y (actor-location enemy)))
                                  #\-
                                  tick))
                     (list 1)
                     (list 1)))
      0))

;fonction qui envoie des messages aux acteurs
(define (run w)
  (let ((w1 (runtime w (world (list) (world-tick w) (world-Lw w) (world-fps w)))))
    (runtime-collide w1 (world-Lactors w1))))

;fonctions qui permettent de remonter dans le temps
;----------------------------------------------

;ajoute w : world à lw : structure Lworlds et renvoie ce nouveau lw
(define (Lworlds-append Lw w)
  (cond 
    [(> (Lworlds-len Lw) (length (Lworlds-list Lw)))
     (Lworlds
      (append
       (Lworlds-list Lw) (list w))
      (Lworlds-len Lw))]
    [else 
     (Lworlds
      (append
       (cdr (Lworlds-list Lw))
       (list w))
      (Lworlds-len Lw))]))

;ajoute wappend : world à w : world et renvoie ce nouveau w
(define (world-append w wappend)
  (world
   (world-Lactors w)
   (world-tick w)
   (Lworlds-append (world-Lw w) (world (world-Lactors wappend) (world-tick wappend) (Lworlds (list) (Lworlds-len (world-Lw w))) (world-fps wappend)))
   (world-fps w)))

;supprime le world le plus récent dans world-Lw de w : structure Lworlds et renvoie ce nouveau w
(define (world-remove w)
  (if (<= (length (Lworlds-list (world-Lw w))) 1)
      w
      (let ((w1 (last (reverse (cdr (reverse (Lworlds-list (world-Lw w))))))))
        (world (world-Lactors w1) (world-tick w1) (Lworlds (reverse (cdr (reverse (Lworlds-list (world-Lw w))))) (Lworlds-len (world-Lw w))) (world-fps w1)))))
        

;fonctions utilisées dans world-output
;----------------------------------------------


;Put l in the good location to be displayed
(define (place-at-reverse l b)
  (raart:place-at b (car l) (car (cdr l)) (raart:char (car (cdr (cdr l))))))

(define (world-decompose w)
   (map actor-split (world-Lactors w)))

(define (actor-split a)
  (list (coord-x (actor-location a)) (coord-y (actor-location a)) (actor-nature a)))

;fonctions pour créer un monde
;----------------------------------------------

;crée un nom à partir de nombres (ce sont les coordonnées de l'actor)
(define (wall-name x y nature tick)
  (string-append (number->string x) (number->string y) (make-string 1 nature) (number->string tick)))

;créer une rangée de mur de (a,y) à (b,y)
(define (wall-construct-y w nature speed a b y)
  (if (> a b)
      w
      (wall-construct-y (world-create-actor (coord y a) (list) nature speed (wall-name y a nature (world-tick w)) 1 100 w)
                        nature
                        speed
                        (add1 a)
                        b
                        y)))
;créer une rangée de mur de (x,a) à (x,b)
(define (wall-construct-x w nature speed x a b)
  (if (= a b)
      w
      (wall-construct-x (world-create-actor (coord a x) (list) nature speed (wall-name a x nature (world-tick w)) 1 100 w)
                        nature
                        speed
                        x
                        (add1 a)
                        b)))
;créer un monde composé d'un rectangle de mur de sommet abcd :struct coord
(define (square-wall w nature speed a b c d)
  (let* ((w1 (wall-construct-y w nature speed (coord-x a) (coord-x b) (coord-y a)))
         (w2 (wall-construct-y w1 nature speed (coord-x d) (coord-x c) (coord-y d)))
         (w3 (wall-construct-x w2 nature speed (coord-x a) (add1 (coord-y a)) (coord-y d))))
    (wall-construct-x w3 nature speed (coord-x b) (add1 (coord-y b)) (coord-y c))))
         ;(wall-construct-x w a b x)


;créer le monde principal
(define (world-maker fps)
  (let* ((w (world (list (actor (coord 5 5) (list) #\> 1 "p1" 1 1)) 0 (Lworlds (list) 10) (real->double-flonum fps)))
         (w1 (square-wall w #\* -1 (coord 40 9) (coord 50 9) (coord 50 13) (coord 40 13)))
         (w2 (square-wall w1 #\* -1 (coord 41 10) (coord 49 10) (coord 49 12) (coord 41 12)))
         (w3 (world-create-actor (coord 6 50) (list) #\< -1 (wall-name 6 50 #\< (world-tick w2)) 1 1 w2))
         (w4 (world-create-actor (coord 17 50) (list) #\< -1 (wall-name 17 50 #\< (world-tick w2)) 1 1 w3))
         (w5 (world-create-actor (coord 11 36) (list) #\< -1 (wall-name 11 36 #\< (world-tick w2)) 1 1 w4))
         )
    (square-wall w5 #\# 0 (coord 2 2) (coord 60 2) (coord 60 20) (coord 2 20))))

;----------------------------------------------


;(let ((w (world (list (actor (coord 1 2) (list (message (list actor-move 0 1))) #\> 0 "p1" 1 1)) 0 (Lworlds (list) 10))))
 ; (tick-rec w (world-Lactors w)))

(provide Lworlds
         Lworlds-list
         Lworlds-len
         world
         world-Lactors
         world-tick
         world-Lw
         world-fps
         world-create-actor
         world-kill-actor
         world-send
         world-collision
         world-update
         tick-rec
         actor-send
         LdeleteL2
         Ldeletea
	 remove-actor
         world-search-nature
	 world-search-name
         actor-msg
	 runtime
         world-remove
         Lworlds-append
         world-append
         world-maker
	 collision-point
         time
         collide-detect
         test-move
         run
         runtime-collide
         collide-actor)  