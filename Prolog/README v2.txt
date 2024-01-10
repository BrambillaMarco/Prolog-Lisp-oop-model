Progetto Prolog OOP

Brambilla Marco, mat. 856428
Colciago Federico, mat. 858643
Condello Paolo, mat. 829800

___________________________________________________________________________________________

def_class/2

def_class(ClassName, Parents)

Crea una classe di nome ClassName, che ha come genitori le classi contenute nella 
lista Parents, utilizzano però il predicato def_class/3 chiamandolo in questo modo:
def_class(ClassName, Parents, [])
Dove la lista vuota indica l'assenza di fields e methods per la nuova classe da creare.

___________________________________________________________________________________________

def_class/3

def_class(ClassName, Parents, Parts)

-Verifica che non esista una classe con il nome ClassName.
-Verifica che Parents sia una lista.
-Verifica che i parents presenti nella lista Parents esistano, e non contengano
 doppioni, tramite il predicato exist_parents/1.
-Verifica che la sintassi di Parts sia quella corretta, tramite il metodo
 check_parts/2.
-Eredita i field e methods delle classi genitori, tramite il predicato legacy/2.
-Crea una classe di nome ClassName, con ha come genitori le classi contenute nella
 lista Parents, e associa i field e method passati in Parts alla classe stessa.

___________________________________________________________________________________________

exist_parents/1

exist_parents(Parents)

CHIAMATO DA def_class/3

Verifica che i Parents siano delle classi esistenti.

___________________________________________________________________________________________

check_parts/2 e check_part/2

check_parts(ClassName, Parts)

CHIAMATO DA def_class/3

Verifica che le Parts passate siano nel formato corretto, chiamando durante
l'esecuzione anche il predicato check_part/2.

___________________________________________________________________________________________

legacy/2

CHIAMATO DA def_class/3

Eredita i field e/o i method delle classi genitore.

___________________________________________________________________________________________



