Progetto LISP OOL

Brambilla Marco, mat. 856428
Colciago Federico, mat. 858643
Condello Paolo, mat. 829800

__________________________________________________________________________

def-class/3

(def-class class-name parents &rest parts)

def-class prende in input 3 parametri: class-name, parents e/o 
fields/methods. 
Se questi parametri sono inseriti correttamente, allora
inserisce la classe nell'hash-table globale, usando come key <class-name> 
e il value di questa key sarà in un formato del tipo:
(<parents> <association-list-fields/methods>)

__________________________________________________________________________

parents-control/2

(parents-control class-name parents)

parents-control prende in input 2 parametri: class-name e parents.
E' una funzione ricorsiva booleana che viene chiamata dalla def-class per 
controllare che i parents siano simboli e che siano effettivamente delle
classi pre-esistenti. Inoltre controlla se ci sono dei parents che si 
chiamano come la classe in creazione.

__________________________________________________________________________

check-parts/1

(check-parts parts)

check-parts prende in input 1 parametro: parts.
E' una funzione booleana trampolino chiamata dalla def-class, 
controlla solo che parts abbia al massimo 2 elementi.

__________________________________________________________________________

valid-parts-list-p/1

(valid-parts-list-p parts)

Funzione booleana ricorsiva chiamata da "check-parts", funge da
trampolino per valid-part-p. 

__________________________________________________________________________

valid-part-p/1

(valid-part-p part)

Funzione booleana chiamata da "valid-parts-list-p" che controlla se 
l'elemento singolo, presente in parts, abbia come primo elemento o 
'fields o 'methods. Se l'elemento ha come primo elemento "fields" allora 
chiama la "my-check-type" sulla coda di tale elemento.

__________________________________________________________________________

my-check-type/1

(my-check-type fields)

Funzione booleana ricorsiva chiamata da "valid-part-p" controlla se 
i field-value sono "compatibili" con i rispettivi field-type.
Se un field-type esiste ed è una classe allora controlla che il field-value
sia nil o un'istanza di quella classe/superclasse specificata nel 
field-type. 
Se field-type esiste e non è compatibile con il suo field-value allora
lancia un errore.

__________________________________________________________________________

formatta/1

(formatta parts)

Funzione che prese in input le "parti" di una classe le restituisce sotto
forma di association-list. Controlla prima l'ordine delle part e, in
base alle casistiche possibili, chiama le specifiche format. 
Assumiamo che i fields vengano sempre prima dei methods, in ogni caso
questa assunzione non darà problemi in futuro in quanto 
scaturirà un errore.

__________________________________________________________________________

format-fields/1

(format-fields fields)

Funzione ricorsiva che presa in input la lista dei fields la ritorna
sotto forma di association list. Inoltre controlla se ogni field, 
preso singolarmente, ha un tipo specificato, se non lo ha lo setta a true.

__________________________________________________________________________

format-methods/1

(format-methods methods)

Funzione ricorsiva che presa in input la lista dei methods la ritorna 
sotto forma di association list con un formato del tipo:

((<method-name> (<parametri> <method-body>)))

__________________________________________________________________________

identify-method/2

(identify-method values result)

Funzione ricorsiva, chiamata dalla def-class, prende in input due 
parametri: 1)fields/methods formattati   2)result = nil
Il parametro "result" serve da accumulatore per la ricorsione.
La funzione riconosce se una "part" è un field o un method, in 
quest'ultimo caso chiama la funzione "process-method", e ritorna la 
association list con i field e i metodi "processati".

La condizione per riconoscere se una part è un metodo o meno è se 
il secondo e terzo elemento di una part sono liste.

__________________________________________________________________________

process-method/2

(process-method method-name method-spec)

Funzione che presi in input "method-name" e le "












__________________________________________________________________________









__________________________________________________________________________









__________________________________________________________________________












__________________________________________________________________________













__________________________________________________________________________


























































