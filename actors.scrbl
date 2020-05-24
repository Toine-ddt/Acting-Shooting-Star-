#lang scribble/manual
 
@title{Documentation du projet de S6 : Acting Shooting Star}
 
Cette documentation décrit les fonctions utilisées dans le projet Acting Shooting Star fait dans le cadre du S6.

@table-of-contents[]

@section{Acteurs}

@(require "src/actor.rkt")

@subsection{Définition des structures}

@defstruct[coord ([x int] [y int])]{
Coordonées}

@defstruct[message ([Lpara list])]{
Les messages reçus par un acteur contiennent en première place dans la liste une procédure à appliquer.
Le reste des éléments de la liste sont les paramètres que prend la procédure, éxcepté l'acteur. 
}

@defstruct[actor ([location coord] [mail-box (list message)] [nature char] [speed int] [name string] [life int] [damage int])]{
Décrit les caractéristiques d'état d'un acteur 
}


@defstruct[response ([main actor] [Lactors (list actor)] [Lmessage (list message)])]{
Triplet contenant un acteur d'origine, une liste d'acteurs et de messages engendrés par l'acteur principal.
}

@subsection{Fonctions de changement d'état d'un acteur}

@defproc[(actor-send [old actor] [msg message])actor]{
Ajout d'un message dans la mail-box de l'acteur.
}

@defproc[(actor-remove-msg [old actor])actor]{
Supprime le premier message de la boîte mail d'un acteur}

@defproc[(actor-move [old actor] [x int] [y int])actor]{
Déplace l'acteur d'un vecteur (x,y)
}

@defproc[(actor-hit [touch actor] [damage int])actor]{
Réduit la vie d'un acteur de l'entier damage.
}

@subsection{Interaction d'acteur à acteur}

@defproc[(actor-create [res-main response] [Llocations (list coord)] [Lmail-boxes (list (list message))] [Lnatures (list char)] [Lspeeds (list int)] [Lnames (list string)] [Llives (list int)] [Ldamages (list int)])response]{
Cette fonction construit à la chaîne des acteurs en vidant les listes de paramètres. Cela enrichie le paramètre Lactors de la structure response}

@defproc[(actor-send-actor [final-res response] [Ldests (list actor)] [Lmessages (list message)])response]{
Contruit une liste de messages contenant un destinataire et enrichie le paramètre Lmessage de repsonse.
}

@subsection{Mise à jour des acteurs}

@defproc[(actor-execute-msg [entity actor])actor/repsonse]{
Exécute le contenu du premier message d'un acteur. Renvoie un acteur ou une response selon la procédure à exécuter. 
}

@defproc[(actor-update [old-reponse response])response]{
Vide la mail-box d'un acteur en éxécutant au passage le contenu des messages.
}

@section{Monde}

@(require "src/runtime.rkt")

@subsection{Description de la structure world}

@defstruct[Lworlds ([list (list world)] [len int])]{
Cette structure est utilisée pour contenir un nombre maximal de len mondes antérieurs au monde actuel.
}

@defstruct[world ([Lactors (list actors)] [tick int] [Lw Lworlds] [fps int])]{
Cette structure repsrésente un monde à l'instant tick.
}

@subsection{Fonctions non-spécifiques à une partie en particulier}

@defproc[(world-search-nature [old-world world] [val-nature char])actor]{
Renvoie le premier acteur de nature val-nature.
}

@defproc[(world-search-name [old-world world] [val-name str])actor]{
Renvoie le premier acteur de nom val-name.
}

@defproc[(world-create-actor [location coord] [mail-box (list message)] [nature char] [speed int] [name str] [life int] [damage int] [old-world world]) world]{
Renvoie un nouveau monde crée à partir de old-world auquel on a rajouté un acteur défini par les paramètres donnés en entrée.
}

@defproc[(world-kill-actor [dead actor] [old-world world]) world]{
Renvoie un nouveau monde créé à partir de old-world duquel on a supprimé un acteur dead.
}

@defproc[(world-send [old-world world] [old-actor actor] [msg message]) world]{
Renvoie un nouveau monde créé à partir de old-world auquel on a ajouté à la boite de messages de old-actor le message msg.
}

@defproc[(collide-actor [Ltouch (list actor)] [old-world world] [number int] [total-damage int]) world]{
Envoie un message de dommage à tous les acteurs concernés par la collision. Se charge de répartir les dégâts entre acteurs de manière équitable sans infliger à un acteur ses propres dégâts.
}

@defproc[(world-collision [Ltouch (list actor)] [old-world world]) world]{
Gère une collision entre acteurs. Elle génère les variables number et total-damage utiles à collide-acteur avant de l'appeler.
}

@defproc[(remove-actor [dead actor] [pile (list actor)]) (list actor)]{
Dépile une liste d'acteurs jusqu'à trouver l'acteur à supprimer. La fonction rempile ensuite la liste sans l'acteur.
}

@subsection{Fonctions utlisées dans word-event}

@subsubsection{Fonctions utilisées pour remonter dans le temps}

@defproc[(Lworlds-append [Lw Lworlds] [w world]) Lworlds]{
Renvoie une structure Lworlds créée à partir de Lw à la quelle on a ajouté w si possible.
}

@defproc[(world-append [w world] [wappend world]) world]{
Renvoie un monde créé à partir de w auquel on a ajouté à Lw le monde wappend.
}

@defproc[(world-remove [w world]) world]{
Renvoie un monde créé à partir de w duquel on a enlever de Lworlds le monde le plus récent.
}

@subsection{Fonctions utilisées dans word-output}

@defproc[(actor-split [a actor]) (list integer? integer? raart?)]{
Renvoie une liste de trois éléments de la structure "actor" de a : les cordonnés x et y puis la nature de l'acteur de type raart.
}

@defproc[(world-decompose [w world]) (list (list integer? integer? raart?)) ]{
Renvoie une liste de listes créée à partir de la liste d'acteur de w. Chaque sous-liste contient 3 éléments : les cordonnés x et y puis la nature de l'acteur de type raart. 
}

@defproc[(place-at-reverse [l (list integer? integer? raart?)] [b raart?]) raart?]{
Effectue l'affichage de l'acteur dont les cordoonées x y et la nature sont stockées en l, ceci en le superposant sur l'affichage de b.
}

@defproc[(world-output [w world]) raart?]{
Effectue l'affichage de tous les acteurs du monde w.
}










@subsection{Fonctions utilisées dans word-tick}

@subsubsection{Fonctions utilisées pour remplir les  boites de messages des acteurs}

@subsubsection{Messages de collision}

Tu dois mettre tes fonctions la omar

@defproc[(collision-point [a1 actor] [a2 actor]) int]{
Renvoie 1 s'il y a collision entres les actors et 0 sinon
}

@defproc[(collide_detect [a actor] [La (list actor)]) (list actor)]{
Renvoie à partir de la liste La la liste des actors qui seront en collision avec l'actor a.  
}

@defproc[(test-move [a actor])(list [x int] [y int])]{
Regarde les coordonnées de déplacement contenues dans un message de déplacement de l'acteur.
}

@defproc[(Ldeletea [La list] [a element] [Lres list]) list]{
Renvoie La\a.
}

@defproc[(LdeleteL2 [La list] [Ld list]) list]{
Renvoie la liste La\Ld.
}

@defproc[(runtime-collide [w world] [La (list actor)]) world]{
Renvoie un monde créé à partir de w auquel des messages de collision ont été envoyés aux acteurs si besoin.
}

@subsubsection{Messages de déplacement}

@defproc[(actor-msg [w world] [a actor]) message]{
Renvoie un message de déplacement en fonction de l'acteur a.
}

@defproc[(enemy-move [tick int] [n int] [speed int]) message]{
Renvoie un message de déplacement en fonction des paramètres.
}

@defproc[(runtime [oldworld world] [newworld world]) world]{
Renvoie un monde créé à partir de w auquel des messages ont été envoyés aux acteurs, notamment des messages de déplacement.
}

@defproc[(run [w world]) world]{
Renvoie un monde créé à partir de w auquel des messages ont été envoyés aux acteurs.
}

@subsubsection{Fonctions utilisées pour vider les boites de messages des acteurs}

@defproc[(tick-rec [w world] [La (list actor)]) world]{
Renvoie un monde créé à partir de old-world auquel les boites de messages de tous les acteurs ont été vidées, c'est-à-dire que tous les messages s'y trouvant ont été exécutés.
}

@defproc[(world-update [old-world world] [old-actor actor]) world]{
Renvoie un monde créé à partir de old-world auquel la boite de messages de l'acteur actor a été vidée, c'est-à-dire que tous les messages s'y trouvant ont été exécutés.
}

@section{Fonctions utilisées dans la création du monde du jeu.}

@defproc[(wall-name [x int] [y int] [nature char] [tick int]) string]{
Transforme toutes les variables en chaînes de caractères si besoin. Concatène ces chaînes pour former un nom unique pour l'acteur.
}

@defproc[(wall-construct-y [w world] [nature char] [speed int] [a int] [b int] [y int]) world]{
Renvoie un monde créé à partir de w auquel on a ajouté une ligne d'acteurs définis par les paramètres de la fonction.
}

@defproc[(wall-construct-x [w world] [nature char] [speed int] [x int] [a int] [b int]) world]{
Renvoie un monde créé à partir de w auquel on a ajouté une colonne d'acteurs définis par les paramètres de la fonction.
}

@defproc[(square-wall [w world] [nature char] [speed int] [a coord] [b coord] [c coord] [d coord]) world]{
Renvoie un monde créé à partir de w auquel on a ajouté une rectangle d'acteurs.
}

@defproc[(world-maker [fps int]) world]{
Renvoie le monde du jeu.
}
