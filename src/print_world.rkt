#lang racket
(require raart)
(require "actor.rkt")

(struct world (Lactors tick) #:transparent)

;print the world in parameter
(define (world-output w)
(draw-here
	(fg 'green 
  	    (frame (bg 'yellow
  	     (matte 66 20
	     
  	     	    (fg 'red 
	     	    	

	(foldl place-at-reverse (blank 1 1) (world-decompose w)))))))))

;Put l in the good location to be displayed
(define (place-at-reverse l b)
  (place-at b (car l) (car (cdr l)) (car (cdr (cdr l)))))

;decompose the world to list of lists of 3 element x y and Nature.
(define (world-decompose w)
   (map actor-split (world-Lactors w)))

;consturct a list of 3 elements form a : actor. elements are x y and Nature. 
(define (actor-split a)
  (list (coord-x (actor-location a)) (coord-y (actor-location a)) (actor-nature a))) 


;(world-output (world (list (actor (coord 1 2) 1 #\# 2 3))))



(world-output (world (list (actor (coord 1 2) 1 (char #\#) 2 3 1 2) (actor (coord 2 3) 4 (char #\>) 22 1 1 2) (actor (coord 1 4) 1 (char #\?) 5 3 1 2)) 1)