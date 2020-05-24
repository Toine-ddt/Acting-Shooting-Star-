#lang racket

(require "runtime.rkt")

(require
  (prefix-in ct: charterm)
  (prefix-in lux: lux)
  (prefix-in raart: raart))


(define (get-option-parameter)  
  (if (string=? (vector-ref (current-command-line-arguments) 0) "-f")
      (let ((s (string->number (vector-ref (current-command-line-arguments) 1))))
        (if (and s
                 (> s 0)
                 (<= s 60))
            s
          #f))
      #f))

;; lux function
;; fps s
(define (start-application fps)
  (lux:call-with-chaos
   (raart:make-raart)
   (lambda () (lux:fiat-lux (world-maker fps))))
  (void))


;;main function
(define (main) 
  (if (get-option-parameter) 
      (start-application (get-option-parameter))
      "Veuillez rentrer : racket src/main.rkt -f n avec n entre 1 et 60"))

(main)
 

    