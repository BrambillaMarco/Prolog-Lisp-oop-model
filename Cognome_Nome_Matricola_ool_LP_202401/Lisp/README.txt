Brambilla Marco, mat. 856428
Colciago Federico, mat. 858643
Condello Paolo, mat. 829800

README per ool.lisp

________________________________________________________________________________

add-class-spec

- Scopo: Questa funzione è utilizzata per aggiungere una nuova specifica di 
	classe all'hash-table globale *classes-specs*. È un'operazione 
	fondamentale per mantenere un registro centrale di tutte le classi 
	definite nel sistema.

- Parametri:
  - name: 	Il nome simbolico della classe che si desidera aggiungere.
  - class-spec: La specifica effettiva della classe, che è una rappresentazione
 		dei dettagli della classe come la sua struttura, i genitori 
		(se presenti), e i suoi campi e metodi.

- Restituisce: 	non restituisce un valore diretto; 
		opera modificando l'hash-table.

________________________________________________________________________________

get-class-spec

- Scopo: Fornisce un mezzo per recuperare le specifiche di una classe 
	precedentemente definita dall'hash-table globale. 
	Questo è cruciale per l'accesso e la manipolazione delle informazioni 
	di classe durante l'esecuzione del programma.

- Parametri:
  - name: Il nome simbolico della classe di cui si desidera 
	  recuperare la specifica.

- Restituisce: 	restituisce la specifica della classe se questa è presente 
		nell'hash-table; altrimenti restituisce nil.

________________________________________________________________________________

def-class

- Scopo: La funzione principale per definire una nuova classe. 
	Si occupa di controllare la validità del nome della classe, 
	dei genitori e delle parti (campi e metodi), e, se tutto è corretto, 
	memorizza la nuova definizione di classe nell'hash-table.

- Parametri:
  - class-name: Il nome simbolico della nuova classe da definire.
  - parents: 	Una lista di genitori (superclassi) della classe, 
		utilizzata per implementare l'ereditarietà.
  - &rest parts: Un elenco variabile di componenti della classe, che possono 
		includere definizioni di campi (fields) e metodi (methods).

- Restituisce: 	Restituisce il class-name se la classe viene definita 
		correttamente. Se ci sono errori nella definizione, ad esempio 
		a causa di nomi non validi o parti mal formattate, 
		solleva un errore.

________________________________________________________________________________

parents-control

- Scopo: Una funzione ausiliaria utilizzata in def-class per verificare 
	la validità dei genitori specificati per una classe. Controlla che ogni 
	genitore sia un simbolo valido e che sia stato definito come una classe.
	
- Parametri:
  - class-name: Il nome della classe per cui stiamo verificando i genitori.
  - parents: 	La lista dei genitori da verificare.

- Restituisce: 	Restituisce NIL se tutti i genitori sono validi. Se un genitore 
		non è valido o è lo stesso nome della classe in definizione, 
		solleva un errore.

________________________________________________________________________________

check-parts

- Scopo: Questa funzione verifica che le parti fornite nella definizione di 
	una classe (campi e metodi) siano formattate correttamente e siano al 
	massimo due (campi e metodi).

- Parametri:
  - parts: Le parti della classe (campi e metodi) da verificare.

- Restituisce: 	Restituisce T (vero) se le parti sono formattate correttamente, 
		altrimenti NIL.
________________________________________________________________________________

valid-parts-list-p

- Scopo: Una funzione ausiliaria di check-parts che verifica ogni singola parte 
	(campo o metodo) di una classe per assicurarsi che sia formattata 
	correttamente.

- Parametri:
  - parts: La lista delle parti (campi e metodi) da verificare.

- Restituisce: 	Restituisce T se ogni parte è correttamente formattata, 
		altrimenti NIL.
________________________________________________________________________________

valid-part-p

- Scopo: Verifica una singola parte (campo o metodo) di una classe, controllando 
	il suo formato e la validità dei suoi componenti.

- Parametri:
  - part: La parte (campo o metodo) da verificare.

- Restituisce: 	Restituisce T se la parte è formattata correttamente, 
		altrimenti NIL.
________________________________________________________________________________

my-check-type

- Scopo: Verifica che i tipi dei valori assegnati ai campi siano compatibili 
	con i tipi dichiarati per questi campi nella definizione della classe. 
	Questo assicura che i valori assegnati ai campi rispettino le 
	restrizioni di tipo definite.

- Parametri:
  - fields: I campi (con i loro valori e tipi) da verificare.

- Restituisce: 	Restituisce T se i tipi sono tutti compatibili. 
		Se un tipo non è compatibile, solleva un errore.

- Note aggiuntive: è possibile inserire un'istanza come value di un field,
		l'importante è che sia istanziata da una classe 
		corrispondente al field-type
________________________________________________________________________________

formatta

- Scopo: Trasforma le parti di una classe (campi e metodi) in una forma 
	standardizzata ("association list"), rendendo più semplice la gestione 
	di queste parti durante la definizione e l'utilizzo della classe.

- Parametri:
  - parts: Le parti (campi e metodi) della classe da trasformare.

- Restituisce: Una lista associativa delle parti formattate.
________________________________________________________________________________

format-fields

- Scopo: Formatta i campi di una classe in una struttura standard, assegnando 
	un tipo predefinito (t) se non specificato esplicitamente.

- Parametri:
  - fields: I campi da formattare.

- Restituisce: 	Una lista dei campi formattati, ciascuno con il suo nome, 
		valore e tipo.
________________________________________________________________________________

format-methods

- Scopo: Formatta i metodi di una classe in una struttura standard, rendendoli 
	pronti per l'uso all'interno della classe.

- Parametri:
  - methods: I metodi da formattare.

- Restituisce: Una lista dei metodi formattati.
________________________________________________________________________________

identify-method

- Scopo: Identifica i metodi all'interno di una lista di parti di una classe e 
	li processa usando process-method per renderli eseguibili.

- Parametri:
  - values: I valori (campi e metodi) da identificare e processare.
  - result: Il risultato accumulato fino a quel momento.

- Restituisce: Una lista aggiornata con i metodi processati.
________________________________________________________________________________

process-method

- Scopo: Prepara un metodo per l'esecuzione, associando il suo nome a una 
	funzione lambda che può essere chiamata. Questo permette di rendere 
	i metodi "vivi" e chiamabili all'interno dell'ambiente del programma.

- Parametri:
  - method-name: Il nome del metodo da processare.
  - method-spec: La specifica del metodo, che include i parametri e 
		il corpo del metodo.

- Restituisce: 	Non restituisce un valore diretto, modifica l'ambiente globale 
		associando il nome del metodo alla sua implementazione.
________________________________________________________________________________

rewrite-method-code

- Scopo: Riscrive il codice di un metodo per includere 'this' 
	(l'istanza corrente) come primo parametro. Questo consente ai metodi 
	di accedere ai campi e altri metodi dell'istanza.

- Parametri:
  - method-name: Il nome del metodo.
  - method-spec: La specifica del metodo da riscrivere.

- Restituisce: 	Una nuova espressione S (S-expression) che rappresenta il 
		metodo riscritto.
________________________________________________________________________________

make

- Scopo: Crea un'istanza di una classe, inizializzando i suoi campi con i 
	valori specificati nei parametri e verificando che siano coerenti con 
	le definizioni di tipo della classe.

- Parametri:
  - class-name: 	Il nome della classe dell'istanza da creare.
  - &rest parameters: 	Parametri per inizializzare l'istanza, forniti 
			come coppie campo-valore.

- Restituisce:	 Un'istanza della classe se la creazione ha successo. 
		Se i parametri non sono validi o non compatibili con la classe, 
		solleva un errore.
________________________________________________________________________________

format-parameters

- Scopo: Formatta i parametri forniti alla funzione `make` in una lista 
	associativa, che facilita la creazione dell'istanza organizzando i 
	valori in un formato standard.

- Parametri:
  - parameters: I parametri da formattare.

- Restituisce: Una lista associativa dei parametri formattati.
________________________________________________________________________________

parameters-control

- Scopo: Verifica che i nomi dei campi forniti alla funzione make siano simboli 
	validi, garantendo così che i parametri di inizializzazione siano 
	conformi alle aspettative della definizione della classe.

- Parametri:
  - values: I valori dei parametri da controllare.

- Restituisce: 	Restituisce NIL se tutti i nomi dei campi sono validi. 
		Se un nome non è valido, solleva un errore.
________________________________________________________________________________

instance-check

- Scopo: Verifica che i parametri forniti per la creazione di un'istanza siano 
	compatibili con le definizioni dei campi nella classe. Assicura che 
	ogni campo riceva un valore del tipo corretto e conforme alle 
	restrizioni della classe.

- Parametri:
  - class: 	La classe dell'istanza.
  - parameters: I parametri dell'istanza.

- Restituisce: 	Restituisce T se l'istanza è valida. Se i parametri non sono 
		validi o non compatibili, solleva un errore.

-Note aggiuntive: per ottenere class-value e class-value-type riutilizzo
		la funzione "field" e "get-field-type"
________________________________________________________________________________

field

- Scopo: Recupera il valore di un campo specifico da un'istanza di una classe. 
	Questo è essenziale per l'accesso ai dati incapsulati all'interno 
	di un'istanza.

- Parametri:
  - instance: 	L'istanza dalla quale recuperare il campo.
  - part-name: 	Il nome del campo da recuperare.

- Restituisce: 	Il valore del campo se esiste. Se il campo non esiste 
		nell'istanza, solleva un errore.
________________________________________________________________________________

get-field-type

- Scopo: Recupera il tipo di un campo di un'istanza di una classe. 
	Questo è utile per la verifica dei tipi e l'incapsulamento dei dati.

- Parametri:
  - instance: 	L'istanza dalla quale recuperare il tipo del campo.
  - part-name: 	Il nome del campo di cui recuperare il tipo.

- Restituisce: 	Il tipo del campo se esiste. Se il campo non esiste 
		nell'istanza, solleva un errore.
________________________________________________________________________________

recursive-field-instance

- Scopo: Una funzione ausiliaria per field e get-field-type che ricerca 
	ricorsivamente un campo in un'istanza, verificando se il campo è 
	presente e restituendo i suoi dettagli se trovato.

- Parametri:
  - values: 	I valori dell'istanza (campi e relativi valori).
  - part-name: 	Il nome del campo da cercare.

- Restituisce: 	Restituisce i dettagli del campo (nome, valore, tipo) 
		se trovato, altrimenti NIL.
________________________________________________________________________________

recursive-field-tree

- Scopo: Una funzione ausiliaria che ricerca ricorsivamente un campo attraverso 
	l'albero di ereditarietà delle classi, partendo da un'istanza specifica. 
	Questo permette di trovare i campi ereditati da classi genitore.

- Parametri:
  - classes: 	La lista delle classi da esaminare durante la ricerca.
  - part-name: 	Il nome del campo da cercare.

- Restituisce: 	Restituisce i dettagli del campo se trovato nell'albero di 
		ereditarietà, altrimenti NIL.
________________________________________________________________________________

check-type-match

- Scopo: Verifica se un valore assegnato a un campo durante la creazione di 
	un'istanza corrisponde al tipo di campo definito nella classe. 
	Questo garantisce che i valori siano conformi alle aspettative di 
	tipo della classe.

- Parametri:
  - instance-value: Il valore da verificare.
  - class-value-type: Il tipo di campo definito nella classe.
  - part-name: Il nome del campo (utilizzato per scopi di debug).

- Restituisce: 	Restituisce T se il valore corrisponde al tipo. 
		Se non corrisponde, solleva un errore.

- Note aggiuntive: la funzione controlla che, se instance-value è un'istanza,
		allora questa deve essere della classe specificata nel
		class-value-type. Altrimenti controlla che instance-value
		sia di un tipo/sottotipo corrispondente al class-value-type
		(casting implicito).

________________________________________________________________________________

field*

- Scopo: Una funzione che facilita l'accesso ai campi annidati all'interno delle 
	istanze delle classi. Permette di recuperare i valori dei campi 
	attraversando più livelli di campi in un'unica chiamata.

- Parametri:
  - instance: 		L'istanza dalla quale iniziare la ricerca.
  - &rest field-name: 	Una sequenza di nomi di campi che specifica 
			il percorso attraverso i campi annidati.

- Restituisce: 	Il valore dell'ultimo campo nel percorso specificato. 
		Se uno dei campi intermedi non esiste, solleva un errore.
________________________________________________________________________________

field*-recursive

- Scopo: Funzione ausiliaria utilizzata da field* per navigare ricorsivamente 
	attraverso i campi annidati di un'istanza e recuperare il 
	valore dell'ultimo campo.

- Parametri:
  - instance: 	L'istanza dalla quale iniziare la ricerca.
  - field-name: La sequenza di nomi di campi da seguire.

- Restituisce: Il valore dell'ultimo campo nel percorso specificato.
________________________________________________________________________________

is-class

- Scopo: Verifica se un determinato simbolo rappresenta una classe definita 
	all'interno dell'ambiente del programma.

- Parametri:
  - class-name: Il nome simbolico della classe da verificare.

- Restituisce: 	Restituisce T se class-name è una classe definita, 
		altrimenti NIL.
________________________________________________________________________________

is-instance

- Scopo: Determina se un dato valore è un'istanza di una specifica 
	classe/superclasse o di una classe generica. È utile per controllare 
	il tipo di un oggetto durante l'esecuzione del programma.

- Parametri:
  - value: Il valore da verificare.
  - class-name: (Opzionale) Il nome della classe specifica da verificare. 
		Se non fornito, la funzione controlla se value è un'istanza 
		di qualsiasi classe.

- Restituisce: 	Restituisce T se value è un'istanza della classe specificata 
		o di qualsiasi classe se class-name non è fornito. 
		Altrimenti, restituisce NIL.
________________________________________________________________________________

is-subclass

- Scopo: Verifica se una classe è sottoclasse di un'altra, cioè se eredita 
	da quella classe. 

- Parametri:
  - subclass: 	La classe da testare come sottoclasse.
  - superclass: La classe genitore da confrontare.

- Restituisce: 	Restituisce T se subclass è una sottoclasse di superclass, 
		altrimenti NIL.
________________________________________________________________________________

is-subclass-helper

- Scopo: Funzione ausiliaria utilizzata da is-subclass per implementare 
	la verifica ricorsiva dell'ereditarietà delle classi.

- Parametri:
  - subclass: 	La classe da testare come sottoclasse.
  - superclass: La classe genitore da confrontare.

- Restituisce: 	Restituisce T se subclass è una sottoclasse di superclass, 
		altrimenti NIL.

-Note aggiuntive: utilizza la funzione 'some' per completare una ricerca 
		orizzontale/verticale nell'albero di ereditarietà.
________________________________________________________________________________
