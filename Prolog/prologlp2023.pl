% Brambilla Marco mat. 856428
% Colciago Federico mat. 858643
% Condello Paolo mat. 829800

:- dynamic
    class/3,
    instance/3,
    method/3.
:-discontiguous
    create_method/6,
    create_method_finisher/6.

% def_class/2
% Definisce una classe con nome e genitori, richiamando il
% metodo def_class/3.
def_class(ClassName, Parents):-
    def_class(ClassName, Parents, []).

% def_class/3
% Definisce una classe con nome, genitori, campi e metodi.
def_class(ClassName, Parents, Parts):-
    not(class(ClassName, _, _)),
    is_list(Parents),
    list_to_set(Parents, ParentsSet),
    exist_parents(ParentsSet),
    check_parts(ClassName, Parts),
    legacy(ParentsSet, InheritedParts),
    ord_union(InheritedParts, Parts, AllParts),
    assert(class(ClassName, ParentsSet, AllParts)),
    write("E' stata creata la classe "),
    write(ClassName),
    write(", i suoi genitori sono:"),
    write(Parents),
    write(".").

% exist_parents/1
% Verifica se esistono le classi genitori passate nella
% def_class.
exist_parents([]).
exist_parents([Parent | Parents]):-
    class(Parent, _, _),
    exist_parents(Parents).

% check_parts/2
% Insieme a check_part/2 controlla che la sintassi dei field
% e dei method sia corretta.
check_parts(_, []).
check_parts(ClassName, [Part | Rest]):-
    check_part(ClassName, Part),
    check_parts(ClassName, Rest).

% check_part/2
% Verifica tutti i membri di Parts e se sono field verr�
% verificato che il loro tipo sia quello corretto.
check_part(_, field(_, _)).
check_part(_, field(_, Value, integer)) :-
    integer(Value).
check_part(_, field(_, Value, float)) :-
    float(Value).
check_part(_, field(_, Value, atom)) :-
    atom(Value).
check_part(_, field(_, Value, string)) :-
    string(Value).
check_part(_, field(_, Value, Type)) :-
    class(Type, _, _),
    instance(Value, Type, _).
check_part(_, method(_, _, _)).

% legacy/2
% Eredita i field e/o i method delle classi genitore.
legacy([], []).
legacy([Parent|Parents], Out) :-
    class(Parent, _, ParentParts),
    legacy(Parents, Rest),
    ord_union(ParentParts, Rest, Out).

% make/2
% Richiama make/3, creando cos� un istanza di una classe,
% senza inserire per� fields o methods.
make(InstanceName, ClassName):-
    make(InstanceName, ClassName, []).

% make/3
% Crea l'istanza di una classe, attribuendo fields e methods
% all'istanza appena creata.
make(InstanceName, ClassName, Fields) :-
    not(instance(InstanceName, ClassName, _)),
    class(ClassName, _, ClassParts),
    is_list(Fields),
    validate_fields(Fields, ClassParts),
    transform_fields(ClassParts, TransformedFields),
    union_fields(Fields, TransformedFields, AllFields),
    assert(instance(InstanceName, ClassName, AllFields)),
    examination(InstanceName, ClassParts),
    write("E' stata creata l'istanza "),
    write(InstanceName),
    write(" della classe "),
    write(ClassName),
    write(".").

% validate_fields/2
% Verifica se i campi dell'istanza esistono nella classe.
validate_fields([], _).
validate_fields([FieldName = Value| Rest], ClassFields) :-
    (
        member(field(FieldName, _), ClassFields);
        member(field(FieldName, _, Type), ClassFields),
        compatible_type(Value, Type)
    ),
    validate_fields(Rest, ClassFields).

% compatible_type/2
% Verifica che i field/3, passati all'interno della make,
% siano del tipo specificato nel parametro Type.
compatible_type(Value, integer) :-
    integer(Value).
compatible_type(Value, float) :-
    float(Value).
compatible_type(Value, atom) :-
    atom(Value).
compatible_type(Value, string) :-
    string(Value).
compatible_type(Value, Type) :-
    class(Type, _, _),
    instance(Value, _, _).

% transform_fields/2
% Trasforma i campi da field(Name, Value) a Name=Value.
transform_fields([], []).
transform_fields([Field | Rest],
                 [KeyValue | TransformedRest]) :-
    transform_field(Field, KeyValue),
    transform_fields(Rest, TransformedRest).

% transform_field/2
% Predicato ausiliario di transform_fields/2.
transform_field(field(Name, Value), Name=Value).
transform_field(field(Name, Value, _), Name=Value).
transform_field(method(Name, _, _), method=Name).

% union_fields/3
% Unisce i campi della make con i campi della classe, non
% duplicandoli.
union_fields([], List2, List2).
union_fields([Field | Rest], List2, Union) :-
    replace_value(Field, List2, UpdatedList),
    union_fields(Rest, UpdatedList, Union).

% replace_value/3
% Chiamato dalla make/3, verifica se un field della nuova
% istanza e' presente all'interno della classe dell'istanza
% stessa, e in questo caso, sovrascrive il valore
% "di default" al valore passato come field nella make/3.
replace_value(NewField, [], [NewField]).
replace_value(NewField, [OldField | Rest],
              [UpdatedField | Rest]) :-
    equivalent_field(NewField, OldField),
    !,
    UpdatedField = NewField.
replace_value(NewField,
             [OldField | Rest],
             [OldField | UpdatedRest]) :-
    replace_value(NewField, Rest, UpdatedRest).

% equivalent_field/2
% Predicato ausiliario di replaca_value/3 che verifica che i
% nomi di due field siano uguali.
equivalent_field(Name=_, Name=_).

% examination/2
% Viene chiamato dalla make/3, dopo aver fatto l'assert della
% istanza in questione.
% Analizza tutte le Parts di una istanza, e quando una di
% queste Parts � un method, allora chiama il predicato
% create_method/6, che si occupera' di creare un nuovo metodo
% a runtime, eseguibile solamente dalla istanza appena creata
% nella make/3.
examination(_, []).
examination(InstanceName, [Part|Parts]):-
    Part=method(MethodName, [], MethodBody),
    create_method(InstanceName,
                  MethodName,
                  [],
                  MethodBody,
                  [],
                  NewMethodBody),
    Term=..[MethodName, InstanceName],
    assert(Term:-NewMethodBody),
    examination(InstanceName, Parts).
examination(InstanceName, [Part|Parts]):-
    Part=method(MethodName, MethodAttributes, MethodBody),
    create_method(InstanceName,
                  MethodName,
                  MethodAttributes,
                  MethodBody,
                  [],
                  NewMethodBody),
    list_to_sequence(MethodAttributes,
                     MethodAttributesSequence),
    Term=..[MethodName,
            InstanceName,
            MethodAttributesSequence],
    assert(Term:-NewMethodBody),
    examination(InstanceName, Parts).
examination(InstanceName, [Part|Parts]):-
    Part=field(_,_),
    examination(InstanceName, Parts).
examination(InstanceName, [Part|Parts]):-
    Part=field(_,_,_),
    examination(InstanceName, Parts).

% create_method/6
% Crea i metodi della nuova istanza appena creata con make/3,
% senza aggiungere parametri aggiuntivi (che non siano
% l'istanza stessa).
create_method(InstanceName,
              MethodName,
              [],
              MethodBody,
              List,
              NewMethodBody):-
    arg(1, MethodBody, Riga),
    not(var(Riga)),
    not(atom(Riga)),
    not(string(Riga)),
    Riga=field(this, FieldName, Value),
    append([List,
           [field(InstanceName, FieldName, Value)]],
           NewList),
    arg(2, MethodBody, Next),
    create_method(InstanceName,
                  MethodName,
                  [],
                  Next,
                  NewList,
                  NewMethodBody).
create_method(InstanceName,
              MethodName,
              [],
              MethodBody,
              List,
              NewMethodBody):-
    arg(1, MethodBody, Riga),
    not(var(Riga)),
    not(atom(Riga)),
    not(string(Riga)),
    append([List, [Riga]], NewList),
    arg(2, MethodBody, Next),
    create_method(InstanceName,
                  MethodName,
                  [],
                  Next,
                  NewList,
                  NewMethodBody).
create_method(InstanceName,
              MethodName,
              [],
              MethodBody,
              List,
              NewMethodBody):-
    append([List, [MethodBody]], NewList),
    create_method_finisher(InstanceName,
                           MethodName,
                           [],
                           MethodBody,
                           NewList,
                           NewMethodBody).

% create_method_finisher/6
% Predicato ausiliario di create_method/6, nell'eventualita'
% che il nuovo metodo da creare non abbia parametri
% (al di la' dell'istanza stessa).
create_method_finisher(_, _, [], _, NewList, NewMethodBody):-
    list_to_sequence(NewList, X),
    X=NewMethodBody.

% create_method/6
% Crea i metodi della nuova istanza appena creata con make/3,
% aggiungendo i parametri aggiuntivi.
create_method(InstanceName,
              MethodName,
              MethodAttributes,
              MethodBody,
              List,
              NewMethodBody):-
    arg(1, MethodBody, Riga),
    not(var(Riga)),
    not(atom(Riga)),
    not(string(Riga)),
    Riga=field(this, FieldName, Value),
    append([List,
           [field(InstanceName, FieldName, Value)]],
           NewList),
    arg(2, MethodBody, Next),
    create_method(InstanceName,
                  MethodName,
                  MethodAttributes,
                  Next,
                  NewList,
                  NewMethodBody).
create_method(InstanceName,
              MethodName,
              MethodAttributes,
              MethodBody,
              List,
              NewMethodBody):-
    arg(1, MethodBody, Riga),
    not(var(Riga)),
    not(atom(Riga)),
    not(string(Riga)),
    append([List, [Riga]], NewList),
    arg(2, MethodBody, Next),
    create_method(InstanceName,
                  MethodName,
                  MethodAttributes,
                  Next,
                  NewList,
                  NewMethodBody).
create_method(InstanceName,
              MethodName,
              MethodAttributes,
              MethodBody,
              List,
              NewMethodBody):-
    append([List, [MethodBody]], NewList),
    create_method_finisher(InstanceName,
                           MethodName,
                           MethodAttributes,
                           MethodBody,
                           NewList,
                           NewMethodBody).

% create_method_finisher/6
% Predicato ausiliario di create_method/6, nell'eventualita'
% che il nuovo metodo da creare abbia parametri aggiuntivi
% (al di la' dell'istanza stessa).
create_method_finisher(_, _, _, _, NewList, NewMethodBody):-
    list_to_sequence(NewList, X),
    X=NewMethodBody.

% list_to_sequence/2
% Trasforma una lista in una sequenza, predicato utile in pi�
% parti del nostro progetto, in quanto frequentemente ci si
% ritrova a dover passare un insieme di "dati" ma senza dover
% utilizzare una lista.
list_to_sequence([X], X).
list_to_sequence([H | T], (H, Rest)) :-
    list_to_sequence(T, Rest).
list_to_sequence([], true).

% is_class/1
% Verifica se esiste la classe ClassName.
is_class(ClassName) :-
    class(ClassName,_,_),
    write("La classe "),
    write(ClassName),
    write(" esiste.").

% is_instance/1
% Verifica se esiste un'istanza Value(senza controllare la
% classe di questa istanza).
is_instance(Value) :-
    instance(Value, _, _),
    write("La istanza "),
    write(Value),
    write(" esiste.").

% is_instance/2
% Verifica se esiste un'istanza di una determinata classe.
is_instance(Value, Class) :-
    instance(Value, Class, _),
    write("La istanza "),
    write(Value),
    write(" della classe "),
    write(Class),
    write(" esiste.").

% inst/2
% Recupera un istanza dato il suo nome.
inst(InstanceName, Instance) :-
    instance(InstanceName, ClassName, Fields),
    Instance=instance(InstanceName, ClassName, Fields).

% field/3
% Estrae il valore di un campo da una classe.
field(InstanceName, FieldName, Result) :-
    var(Result),
    instance(InstanceName, _, Fields),
    memberchk(FieldName=Value, Fields),
    Result = Value.

% fieldx/3
% Estrae i valori dei fields indicati come lista in FieldNames.
fieldx(InstanceName, FieldNames, Values) :-
    var(Values),
    is_list(FieldNames),
    instance(InstanceName, _, Fields),
    find_field_values(FieldNames, Fields, Values).

% find_field_values/3
% Predicato ausiliario di fieldx/3.
find_field_values([], _, []).
find_field_values([FieldName | Rest], Fields,
                  [Value | RestValues]) :-
    memberchk(FieldName=Value, Fields),
    find_field_values(Rest, Fields, RestValues).
