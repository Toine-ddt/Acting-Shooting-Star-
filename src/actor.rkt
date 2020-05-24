#lang racket

(struct coord (x y)#:transparent);Coordonnées. Nom != location pour eviter confusion
;entre nom de structure et nom de paramètre

(struct actor (location mail-box nature speed name life damage)#:transparent)
;location  -> couple entiers , mail-box ->liste string

(struct message (Lpara)#:transparent) ;Lpara-> liste des parametres avec en
;premier le label puis des paramètres

(struct response (main Lactors Lmessages)#:transparent) ;structure de reponse de update

(define (actor-send old msg) ;Ajout d'un message dans mail-box
  (actor (actor-location old)
         (cons msg (actor-mail-box old))
         (actor-nature old)
         (actor-speed old)
         (actor-name old)
         (actor-life old)
         (actor-damage old)))

;Envoie le message a une liste d'acteurs
;(define (actor))

(define (actor-remove-msg old) ;Enleve le premier message de la amil box d'un acteur
  (actor (actor-location old)
         (cdr (actor-mail-box old))
         (actor-nature old)
         (actor-speed old)
         (actor-name old)
         (actor-life old)
         (actor-damage old)))


;Déplace l'acteur d'un vecteur (x y)
(define (actor-move old x y)
  (actor (coord
           (+ (coord-x (actor-location old)) x)
           (+ (coord-y (actor-location old)) y))
         (actor-mail-box old)
         (actor-nature old)
         (actor-speed old)
         (actor-name old)
         (actor-life old)
         (actor-damage old)) )

;Réaction d'un acteur touché en baisse de vie : actor * int -> actor
(define (actor-hit touch damage)
      (actor (actor-location touch)
                   (actor-mail-box touch)
                   (actor-nature touch)
                   (actor-speed touch)
                   (actor-name touch)
                   (- (actor-life touch) damage)
                   (actor-damage touch)
                   ))
;Apres rassemblement des listes de paramètres rangées par catégories
;en listes de paramètre rangées par acteur,
;on enrichie de manière récursive response-Lactors
;response * List -> response
(define (actor-create-aux old-response Lparametres)
  (if (null? (car Lparametres))
    old-response
    (actor-create-aux (response (response-main old-response)
                            (cons (apply actor (map car Lparametres))
                                  (response-Lactors old-response))
                             (response-Lmessages old-response))
                            (map cdr Lparametres))))

;Creation d'une liste d'acteurs à partir de plusieurs listes des paramètres
;respone * L1 * ... * L7 -> response
(define (actor-create res-main
                      Llocations
                      Lmail-boxes
                      Lnatures
                      Lspeeds
                      Lnames
                      Llives
                      Ldamages)
(let ((Lparametres (list
                    Llocations
                    Lmail-boxes
                    Lnatures
                    Lspeeds
                    Lnames
                    Llives
                    Ldamages)))
  (actor-create-aux (response res-main (list) (list)) Lparametres)))

;Fonction qui prend en argument une response vierge au début
;Créer de manière récursive une liste de massages à envoyer ux destinataires indiqués 
(define (actor-send-actor final-res Ldests Lmessages)
  (if (empty? Ldests)
        final-res
        (actor-send-actor (response (response-main final-res)
                                    (response-Lactors final-res)
                                    (cons (list (car Ldests) (car Lmessages)) (response-Lmessages final-res)))
                          (cdr Ldests)
                          (cdr Lmessages))))

;Demande d'envoie d'un message par unn acteur à un autre
;(define (actor-send-actor old-actor Ldests Lmessages)
 ; (let ((nw-res (response old-actor (list) (list))))
 ;   (actor-send-actor-aux nw-res Ldests Lmessages)))

;Execution dela fonction associée à un message. Ici, la recherche de la fonction
;s'effectue grâce à une a-liste avec comme clef une chaîne de caractère.*
; actor -> execution de la fonction aproriee
(define (actor-execute-msg entity)
  (apply (car (message-Lpara (car (actor-mail-box entity))))
         (cons entity (cdr (message-Lpara (car (actor-mail-box entity)))))))

;(define (actor-update old-actor) 
;  (if (empty? (actor-mail-box old-actor))
;      old-actor
;     (actor-update (actor-remove-msg (actor-execute-msg old-actor)))))


;Vider mail-box d'un unique acteur en exécutant le contenu des messages.
;response -> response
(define (actor-update old-response) 
  (if (empty? (actor-mail-box (response-main old-response)))
      old-response
      (if (member (car (message-Lpara (car (actor-mail-box (response-main old-response)))))
                  (list actor-create actor-send-actor))
          (let ((add-response (actor-execute-msg (response-main old-response))))
            (actor-update (response (actor-remove-msg (response-main add-response))
                     (append (response-Lactors old-response)
                             (response-Lactors add-response))
                     (append (response-Lmessages old-response)
                             (response-Lmessages add-response)))))
          (actor-update (response (actor-remove-msg
                                   (actor-execute-msg
                                    (response-main old-response)))
                                  (response-Lactors old-response)
                                  (response-Lmessages old-response))))))

;Provide de toutes les fonctions et structures 


(provide coord
         coord-x
         coord-y
         message
         message-Lpara
         actor
         actor-location
         actor-mail-box
         actor-nature
         actor-speed
         actor-name
         actor-life
         actor-damage
         actor-send
         actor-move
         actor-remove-msg
         actor-execute-msg
         actor-update
         actor-hit
         actor-create-aux
         actor-create
         actor-send-actor
         response
         response-main
         response-Lactors
         response-Lmessages
         )

;Renvoie le premier acteur dans la pile d'acteur qui correspond au parametres de recherche
;world * char -> actor
;(define (world-search old-world val-name)
;  (if (null? (world-Lactors old-world))
;      #f
;      (if (eq? (val-name) (actor-name (car (world-Lactors old-world))))
;          (car (world-Lactors old-world))
;          (world-search (world (cdr (world-Lactors old-world)) (world-tick old-world))
;                        val-name))))


(define ac1 (actor (coord 1 3) (list) "player" 4 "ac1" 5 2))
(define ac1-1 (actor-send ac1 (message (list actor-move 3 4))))
(define ac1-2 (actor-send ac1-1 (message (list actor-create
                                       (list (coord 3 4))
                                       (list (list))
                                       (list "wall")
                                       (list 4)
                                       (list "ac2")
                                       (list 12)
                                       (list 1)))))
(define res1 (response ac1-2 (list) (list)))
(actor-update res1)
;(let* ([ac1 (actor (coord 1 3) (list) "player" 4 "ac1" 5 2)]) (actor-location ac1))
;(define ac2 (actor (coord 3 4) (list "mess3" "mess4") "player" 4 "ac2" 12 1))
;(define ac3 (actor (coord 5 7) (list "mess4" "mess5") "player" -3 "ac3" 4 10))
;(define ac1-1 (actor-send ac1 (message (list actor-move 3 4))))
;(define ac1-2 (actor-execute-msg ac1-1))
(define res (response ac1 (list) (list)))
(define Llocations (list (coord 3 5) (coord 3 4) (coord -5 8) (coord 123 -34)))
(define Lmail-boxes (list (message (list "mess")) (message (list "test")) (message (list)) (message (list "testtest"))))
(define Lnatures (list "x" "ezr" "ezf" "gtt"))
(define Lspeeds (list 23 344 534 22))
(define Lnames (list "p1" "p2" "p3" "p4"))
(define Llives (list 23 4554 55 234))
(define Ldamages (list 23 5 45 23))
(define Ldests (list ac1 ac1-1 ac1-2))
(define Lmessages (list (message (list actor-move 3 5))
                          (message (list actor-move 66 45))
                          (message (list actor-move 23 -78))))
(actor-send-actor (response ac1 (list) (list)) Ldests Lmessages)
;(actor-create res
;              Llocations
;              Lmail-boxes
;              Lnatures
;              Lspeeds
;              Lnames
;              Llives
;              Ldamages)