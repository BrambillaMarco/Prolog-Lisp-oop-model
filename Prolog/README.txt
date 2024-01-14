Progetto Prolog OOP

Brambilla Marco, mat. 856428
Colciago Federico, mat. 858643
Condello Paolo, mat. 829800

_______________________________________________________________________________

def_class/2

def_class(ClassName, Parents)

Crea una classe di nome ClassName, che ha come genitori le classi contenute 
nella lista Parents, utilizzando il predicato def_class/3 chiamandolo in 
questo modo:
def_class(ClassName, Parents, [])
Dove la lista vuota indica l'assenza di fields e methods per la nuova classe 
da creare.

_______________________________________________________________________________

def_class/3

def_class(ClassName, Parents, Parts)

-Verifica che non esista una classe con il nome ClassName.
-Verifica che Parents sia una lista.
-Verifica che i parents presenti nella lista Parents esistano, e non 
 contengano doppioni, tramite il predicato exist_parents/1.
-Verifica che la sintassi di Parts sia quella corretta, tramite il metodo
 check_parts/2.
-Eredita i field e methods delle classi genitori, tramite il predicato 
 legacy/2.
-Gestisce l'override tramite il predicato check_override/4.
-Crea una classe di nome ClassName, con ha come genitori le classi contenute 
 nella lista Parents, e associa i field e method passati in Parts alla classe 
 stessa.

_______________________________________________________________________________


exist_parents/1

exist_parents(Parents)

CHIAMATO DA def_class/3

Verifica che i Parents siano delle classi esistenti.

_______________________________________________________________________________


check_parts/2 e check_part/2

check_parts(ClassName, Parts)

CHIAMATO DA def_class/3

Verifica che le Parts passate siano nel formato corretto, chiamando durante
l'esecuzione anche il predicato ausiliario check_part/2.

_______________________________________________________________________________


legacy/2

CHIAMATO DA def_class/3

Eredita i field e/o i method delle classi genitore.

_______________________________________________________________________________

check_override/4

CHIAMATO DA def_class/3

check_override([InheritedPart | InheritedRest],
               Parts,
               List,
               NewInheritedParts)

Gestisce l'override, eliminando quindi eventuali fields e method di "default"
definiti nelle classi genitori, solamente se in questa nuova classe, vengono
definiti nuovamente fields o methods che hanno un nome identico a quelli di 
"default".

_______________________________________________________________________________

make/2

make(InstanceName, ClassName)

Crea una istanza della classe ClassName di nome InstanceName,utilizzando il 
predicato make/3 chiamandolo in questo modo:
make(InstanceName, ClassName, [])
Dove la lista vuota indica l'assenza di fields per la nuova istanza, tenendo 
così tutti i fields di "default" della classe dell'istanza.

_______________________________________________________________________________


make/3

make(InstanceName, ClassName, Fields)

-Controlla che non esista già un istanza della classe ClassName di nome 
 InstanceName.
-Controlla che esista la classe ClassName, e attribuisce alla variabile 
 ClassParts le Parts della classe di cui si vuole creare l'istanza.
-Verifica che i Fields siano contenuti in una lista, e che siano coerenti 
 con quelli della classe ClassName, tramite il predicato validate_fields/2.
-Trasforma i field(FieldName, Value, Type) in [FieldName = Value], tramite il
 predicato transform_fields/2.
-Unisce i Fields alle ClassParts, togliendo i duplicati, tramite il predicato
 union_fields/3.
-Crea una istanza della classe ClassName, di nome IstanceName, che contiene
 come Fields il risultato di tutti i vari predicati descritti sopra.
-Chiama il predicato examination/4, passandogli l'istanza appena creata,
 le sue Parts, una lista nuova e la variabile MethodList in modo da 
 controllare nuovamente che siano tutti nel formato corretto, e nel caso che
 la classe ClassName abbia un metodo, allora lo crea dinamicamente per la 
 istanza appena creata.

_______________________________________________________________________________

validate_fields/2

validate_fields([FieldName = Value | Rest], ClassFields)

CHIAMATO DA make/3

Verifica se i campi dell'istanza da creare esistono nella classe.

_______________________________________________________________________________

compatible_type/2

Varie definizioni...

CHIAMATO DA validate_fields/2

Verifica che i Fields passati alla make/3, siano del tipo specificato nel 
parametro Type.

_______________________________________________________________________________

transform_fields/2 e transform_field/2

transform_fields([Field | Rest], [KeyValue | TransformedRest])

CHIAMATO DA make/3

Trasforma field(FieldName, Value, Type) in [FieldName = Value], chiamando
durante l'esecuzione anche il predicato ausiliario transform_field/2.

_______________________________________________________________________________

union_fields/3

union_fields([Field | Rest], List2, Union)

CHIAMATO DA make/3

Unisce i campi della make con i campi della classe, non duplicandoli.

_______________________________________________________________________________

replace_value/3 e equivalent_field/2

replace_value(NewField, [OldField | Rest], [UpdatedField | Rest])

CHIAMATO DA union_fields/3

Verifica se i Fields passati alla make/3 per la creazione della nuova istanza
esistano nella classe di riferimento, e in tal caso, sostituisce i valori di
"default" con quelli passati alla make/3.
Il predicato equivalent_field/2 è da considerarsi ausiliario di
replace_value/3.

_______________________________________________________________________________

examination/4

examination(InstanceName, [Part | Parts], List, MethodList)

CHIAMATO DA make/3

Analizza tutte le Parts di una istanza appena creata, e se trova un method,
allora chiama lo crea dinamicamente per la istanza appena creata.

_______________________________________________________________________________

remove_this/2, remove_this_helper/4 e create_method/2

remove_this(InstanceName, [Method | Rest])
remove_this_helper(InstanceName, [Line | Lines], List, NewMethodBody)
create_method(Method, MethodBody)

CHIAMATO DA make/3

Inizialmente i remove_this/2 e remove_this_helper/4 prendono in ingresso tutti 
i metodi (e i rispettivi corpi dei metodi) della istanza appena creata, per 
poter sostituire l'atomo "this" con il nome dell'istanza stessa.
In questo modo, i metodi funzioneranno solamente se vengono chiamati con la
istanza come attributo, impedendo così che un istanza che non abbia quel
metodo possa comunque eseguirlo.

Tuttavia, durante l'esecuzione di remove_this/2 e remove_this_helper/4 i 
vecchi metodi creati a runtime in precedenza (che contenevano ancora
l'atomo "this") vengono cancellati, e quindi andranno creati a runtime dei 
nuovi metodi, con al posto dell'atomo "this" il nome dell'istanza stessa.

Per questo procedimento abbiamo utilizzato create_method/2, che crea
dinamicamente i nuovi metodi ottenuti con remove_this/2 e 
remove_this_helper/4, ma create_method/2, non si limita a questo.

*******************************************************************************
ATTENZIONE!

Analizzando i test del progetto, ci siamo accorti che nel corpo di un metodo 
era possibile inserire dei predicati del calibro di "with_output_to" o 
"call", predicati che solitamente vengono inseriti "all'inizio" del corpo di 
un metodo.

Per consentire il corretto funzionamento del codice, nel caso venga inserito
uno di questi predicati, abbiamo inserito varie definizioni del predicato
create_method/2. 

Il codice quindi può interpretare dei corpi del metodo che siano tra:

-Sequenze di istruzioni Prolog
-Una regola con un unico attributo (ovvero tutto il corpo del metodo vero e 
 proprio) che può essere del tipo "call/1", "ignore/1", e simili
-Una regola con due attributi, come nel caso di "with_output_to/2" dove il
 secondo attributo deve contenere il corpo del metodo vero e proprio.

Il codice invece, NON può interpretare

-Sequenze di "istruzioni" che però non rispettino la sintassi di Prolog.
-Corpi del metodo che contengano dei predicati come "call" o
 "with_output_to/2", oltre alla seconda riga del corpo del metodo.

*******************************************************************************

_______________________________________________________________________________

list_to_sequence/2

list_to_sequence([H | T], (H, Rest))

Chiamato in vari predicati, è da considerarsi un predicato "utility" in quanto
svariate volte lungo il codice è necessario passare da una lista ad una
sequenza.

_______________________________________________________________________________

is_class/1

is_class(ClassName)

Verifica che ClassName sia una classe esistente.

_______________________________________________________________________________

is_instance/1 e is_instance/2

is_instance(Value)
is_instance(Value, Class)

Nel primo caso verifica che esista una determinata istanza, senza preoccuparsi
della sua classe.
Nel secondo caso invece, verifica che esista una determinata istanza di una 
determinata classe.

*******************************************************************************
ATTENZIONE!
 
Sulla traccia del progetto, veniva richiesto che is_instance/2 verificasse
l'esistenza di una determinata istanza, che appartenesse ad una classe avente
come genitore Class.
Tuttavia, a seguito di alcune discussioni sul forum studenti da noi lette,
abbiamo deciso di implementarlo nel modo descritto nella documentazione, in 
quanto ci sembrava più utile.
Una definizione coerente al testo del progetto sarebbe tuttavia facilmente
ottenibile, in quanto basterebbe scrivere un codice del tipo:

is_instance(Value, Parent):-
	instance(Value, Class, _),
	class(Class, Parents, _),
	member(Parent, Parents).

*******************************************************************************

_______________________________________________________________________________

inst/2

inst(InstanceName, Instance)

Recupra un istanza dato il suo nome.

_______________________________________________________________________________

field/3 - PREDICATO

field(InstanceName, FieldName, Result)

Estrae il valore di un campo da una classe.

_______________________________________________________________________________

fieldx/3

fieldx(InstanceName, FieldNames, Values)

Estrae i valori dei fields indicati come lista in FieldNames.

_______________________________________________________________________________

find_field_values/3

find_field_values([FieldName | Rest], Fields, [Value | RestValues])

CHIAMATO DA fieldx/3

Predicato ausiliario di fieldx/3.

_______________________________________________________________________________
