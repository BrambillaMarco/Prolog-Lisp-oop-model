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

-Verifica che ClassName non sia nè una variabile nè una lista.
-Verifica che non esista una classe con il nome ClassName.
-Verifica che Parents e Parts siano una lista.
-Verifica che i parents presenti nella lista Parents esistano, e non 
 contengano doppioni, tramite il predicato exist_parents/1.
-Verifica che la sintassi di Parts sia quella corretta, tramite il metodo
 check_parts/1.
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


check_parts/1 e check_part/1

check_parts(Parts)

CHIAMATO DA def_class/3

Verifica che le Parts passate siano nel formato corretto, chiamando durante
l'esecuzione anche il predicato ausiliario check_part/1.

_______________________________________________________________________________


legacy/2

legacy([Parent | Parents], AllParts)

CHIAMATO DA def_class/3

Eredita i field e/o i method delle classi genitore.

_______________________________________________________________________________

check_override/4

check_override([InheritedPart | InheritedParts],
               Parts,
               List,
               NewInheritedParts)

CHIAMATO DA def_class/3

Gestisce l'override, eliminando quindi eventuali fields e method di "default"
definiti nelle classi genitori, solamente se in questa nuova classe, vengono
definiti nuovamente fields o methods che hanno un nome identico a quelli di 
"default".

_______________________________________________________________________________

make/2

make(InstanceName, ClassName)

Crea una istanza della classe ClassName di nome InstanceName, utilizzando il 
predicato make/3 chiamandolo in questo modo:
make(InstanceName, ClassName, [])
Dove la lista vuota indica l'assenza di fields per la nuova istanza, tenendo 
così tutti i fields di "default" della classe dell'istanza.

_______________________________________________________________________________


make/3

make(InstanceName, ClassName, Fields)

SE InstanceName E' UNA VARIABILE E ClassName E' UNA CLASSE ESISTENTE:

InstanceName unifica con tutte le instanze di ClassName

SE InstanceName E' UNA VARIABILE E ClassName NON E' UNA CLASSE ESISTENTE:

InstanceName unifica con un istanza fittizia di cui non viene fatto l'assert

SE InstanceName E' UN SIMBOLO:

-Controlla che non esista già un istanza della classe ClassName di nome 
 InstanceName.
-Controlla che esista la classe ClassName, e attribuisce alla variabile 
 ClassParts le Parts della classe di cui si vuole creare l'istanza.
-Verifica che i Fields siano contenuti in una lista, e che siano coerenti 
 con quelli della classe ClassName, tramite il predicato validate_fields/2.
-Trasforma i field(FieldName, Value) e i field(FieldName, Value, Type) in
 [FieldName = Value], tramite il predicato transform_fields/2.
-Unisce i Fields alle ClassParts, togliendo i duplicati, tramite il predicato
 union_fields/3.
-Crea una istanza della classe ClassName, di nome IstanceName, che contiene
 come Fields il risultato di tutti i vari predicati descritti sopra.
-Chiama il predicato create_method/2, passandogli l'istanza appena creata,
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

transform_fields([Field | Rest], [Value | TransformedRest])

CHIAMATO DA make/3

Trasforma field(FieldName, Value) e field(FieldName, Value, Type) 
in [FieldName = Value], chiamando durante l'esecuzione anche il predicato 
ausiliario transform_field/2.

_______________________________________________________________________________

union_fields/3

union_fields([Field | Rest], List, Union)

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

create_method/2

create_method(InstanceName, [Part | Parts])

CHIAMATO DA make/3

Analizza tutte le Parts di una istanza appena creata, e se trova un method,
allora lo crea dinamicamente per la istanza appena creata.
I metodi con più di un attributo andranno chiamati in questo modo:
MethodName(InstanceName, (MethodAttribute1, ..., MethodAttributeN).
L'ordine dei MethodAttribute deve essere quello di comparsa nel corpo del
metodo.

_______________________________________________________________________________

replace/4

replace(Old, New, OldString, NewString)

CHIAMATO DA create_method/2

Sostituisce tutte le ricorrenze di Old in OldString con New, ed unifica il 
risultato con NewString.
Viene utilizzato per sostituire l'atomo "this" con InstanceName.

_______________________________________________________________________________

list_to_sequence/2

list_to_sequence([Head | Tail], (Head, Rest))

Chiamato in vari predicati, è da considerarsi un predicato "utility" in quanto
svariate volte lungo il codice è necessario passare da una lista ad una
sequenza.

_______________________________________________________________________________

is_class/1

is_class(ClassName)

Verifica che ClassName sia una classe esistente.
Se invece ClassName è una variabile allora unifica con tutte le classi create
finora a runtime.

_______________________________________________________________________________

is_instance/1 e is_instance/2

is_instance(Value)
is_instance(Value, ClassName)

Nel primo caso verifica che esista una determinata istanza, senza preoccuparsi
della sua classe.
Nel secondo caso invece, verifica che esista una determinata istanza, e che 
ClassName sia la classe di Value, oppure una sua superclasse/antenata.
Può essere usato anche con variabili al posto di Value e/o Class.

_______________________________________________________________________________

ancestors/3

ancestors([Parent | Parents], ParentOfParents, SuperClass)

CHIAMATO DA is_instance

Trova gli antenati di una classe.

_______________________________________________________________________________

inst/2

inst(InstanceName, Instance)

Instance unifica con un istanza dato il suo nome.
Se InstanceName è una variabile, unifica Instance con tutte le istanze create
a runtime.

_______________________________________________________________________________

field/3 - PREDICATO

field(InstanceName, FieldName, Result)

Estrae il valore di un campo da una classe.

_______________________________________________________________________________

fieldx/3

fieldx(InstanceName, FieldNames, Value)

Estrae l'ultimo field nella lista FieldNames per l'istanza InstanceName e lo
unifica con Values.

_______________________________________________________________________________

find_field_values/3

find_field_values([FieldName | Rest], Fields, [Value | RestValues])

CHIAMATO DA fieldx/3

Predicato ausiliario di fieldx/3.
