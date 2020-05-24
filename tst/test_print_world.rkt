#lang racket
(require raart)

;shows the first page
(draw-here
	(fg 'green 
  	    (frame (bg 'yellow
  	     (matte 66 20
	     
 	     	    (fg 'red 
	     	    	(frame #:bg 'red
				(text "This is the first page !"))))))))

;print one frame with position x y
(define (person_plot y x)
(draw-here
	(fg 'green 
  	    (frame (bg 'yellow
  	     (matte 66 20
	     
  	     	    (fg 'red 
	     	    	(place-at (char #\0) y x (char #\>)))))))))

(person_plot 10 33) ; max in x 33
;(person_plot 10 10) ; max in y 10


;-------------------------------------------
;prints all actors of the world structure

;(define (print_world lactors)

;(define (print_world lactors)
;(let ([a (place-at (vide) (x) (y) (actor-name (car lactors))])
;     (place-at a (newx) (newy) (car (cdr lactors)) 

;(define (recurvive


;----------------------------------------------------

;(define (person_plot y x)
;(draw-here
;	(fg 'green 
 ; 	    (frame (bg 'yellow
  ;	     (matte 66 20
;	     
 ; 	     	    (fg 'red 
;	     	    	(place-at (char #\0) y x (char #\>)))))))))



; shows the evolution of actor between n in parameter and 33 max inside the frame

;(define (print_evolution n)
;	(if (= n 33) (write "end")
;	    (and (person_plot 10 n)
;	    		 (print_evolution (add1 n)))))
;
;(print_evolution 0)
	
	

;non important things:

;(define move (lambda (x y act)
;	(actor 
;	       (cons (+ x (car (actor-position act))) (+ y (cdr (actor-position act))))
;	       (cdr (actor-mailbox act))
;	       )))


;(draw-here (vappend2 (text "Hello") (text "World")))

; une fonction qui represente les joueurs en fonction de leurs position
;(text-rows '(# # # # # # # #))

;(draw-here (vappend (text "Short") (text "A Little Medium") (text "Very Very Long") #:halign 'left))

;(place-at (blank ) 50 50 (char #\a))
