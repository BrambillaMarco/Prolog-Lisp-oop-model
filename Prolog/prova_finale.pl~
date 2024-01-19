% Brambilla Marco mat. 856428
% Colciago Federico mat. 858643
% Condello Paolo mat. 829800

:- dynamic
    class/3,
    instance/3,
    method/3.

% def_class/2
% Definisce una classe con nome e genitori, richiamando il
% metodo def_class/3.
def_class(ClassName, Parents):-
    def_class(ClassName, Parents, []),
    !.

% def_class/3
% Definisce una classe con nome, genitori, campi e metodi.
def_class(ClassName, Parents, Parts):-
    not(class(ClassName, _, _)),
    is_list(Parents),
    list_to_set(Parents, ParentsSet),
    exist_parents(ParentsSet),
    check_parts(ClassName, Parts),
    legacy(ParentsSet, InheritedParts),
    check_override(InheritedParts,
                   Parts,
                   [],
                   NewInheritedParts),
    ord_union(NewInheritedParts, Parts, AllParts),
    assert(class(ClassName, ParentsSet, AllParts)),
    !,
    write("E' stata creata la classe "),
    write(ClassName),
    write(", i suoi genitori sono:"),
    write(Parents),
    write(".").

% exist_parents/1
% Verifica se esistono le classi genitori passate nella
% def_class/3.
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
% Verifica tutti i membri di Parts e se sono field verrà
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
check_part(_, field(_, null, Type)) :-
    class(Type, _, _).
check_part(_, method(_, _, _)).

% legacy/2
% Eredita i field e/o i method delle classi genitore.
legacy([], []).
legacy([Parent|Parents], Out) :-
    class(Parent, _, ParentParts),
    legacy(Parents, Rest),
    ord_union(ParentParts, Rest, Out).

% check_override/4
% Sovrascrive tutti i field e method che hanno lo stesso
% nome di quelli definiti nella nuova classe.
check_override([],
               _,
               List,
               NewInheritedParts):-
    List=NewInheritedParts.
check_override([InheritedPart | InheritedRest],
               Parts,
               List,
               NewInheritedParts):-
    InheritedPart=field(X, _, _),
    member(field(X, _, _), Parts),
    check_override(InheritedRest,
                   Parts,
                   List,
                   NewInheritedParts).
check_override([InheritedPart | InheritedRest],
               Parts,
               List,
               NewInheritedParts):-
    InheritedPart=field(X, _),
    member(field(X, _), Parts),
    check_override(InheritedRest,
                   Parts,
                   List,
                   NewInheritedParts).
check_override([InheritedPart | InheritedRest],
               Parts,
               List,
               NewInheritedParts):-
    InheritedPart=method(X, _, _),
    member(method(X, _, _), Parts),
    check_override(InheritedRest,
                   Parts,
                   List,
                   NewInheritedParts).
check_override([InheritedPart | InheritedRest],
               Parts,
               List,
               NewInheritedParts):-
    append([[InheritedPart], List], NewList),
    check_override(InheritedRest,
                   Parts,
                   NewList,
                   NewInheritedParts).

% make/2
% Richiama make/3, creando così un istanza di una classe,
% senza inserire però fields aggiuntivi, verranno quindi
% tenuti i fields "di default" della classe.
make(InstanceName, ClassName):-
    make(InstanceName, ClassName, []),
    !.

% make/3
% Crea l'istanza di una classe, attribuendo modificando i
% fields "di default" e inserendo quelli nel parametro
% Fields.
make(InstanceName, ClassName, Fields) :-
    not(var(InstanceName)),
    not(instance(InstanceName, ClassName, _)),
    class(ClassName, _, ClassParts),
    is_list(Fields),
    validate_fields(Fields, ClassParts),
    transform_fields(ClassParts, TransformedFields),
    union_fields(Fields, TransformedFields, AllFields),
    assert(instance(InstanceName, ClassName, AllFields)),
    examination(InstanceName, ClassParts),
    !,
    write("E' stata creata l'istanza "),
    write(InstanceName),
    write(" della classe "),
    write(ClassName).
make(InstanceName, ClassName, Fields):-
    var(InstanceName),
    is_class(ClassName),
    Fields = [],
    findall(X, instance(X, ClassName, _), Instances),
    member(Y, Instances),
    InstanceName = Y,
    !.
make(InstanceName, ClassName, Fields):-
    var(InstanceName),
    is_class(ClassName),
    not(Fields = []),
    findall(X, instance(X, ClassName, Fields), Instances),
    member(Y, Instances),
    InstanceName = Y,
    !.
make(InstanceName, ClassName, Fields):-
    var(InstanceName),
    not(is_instance(_, ClassName)),
    InstanceName = instance(istanza, ClassName, Fields),
    !.

% validate_fields/2
% Verifica se i campi dell'istanza esistono nella classe.
validate_fields([], _).
validate_fields([FieldName = _| Rest], ClassFields) :-
    member(field(FieldName, _), ClassFields),
    validate_fields(Rest, ClassFields).
validate_fields([FieldName = Value | Rest], ClassFields):-
    member(field(FieldName, _, Type), ClassFields),
    compatible_type(Value, Type),
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
compatible_type(Value, Type) :-
    Value = null,
    class(Type, _, _).


% transform_fields/2
% Insieme a transform_field/1, trasforma i campi da
% field(Name, Value) a Name=Value.
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
% Predicato ausiliario di replace_value/3 che verifica che i
% nomi di due field siano uguali.
equivalent_field(Name=_, Name=_).

% examination/2
% Viene chiamato dalla make/3, dopo aver fatto l'assert della
% istanza in questione.
% Analizza tutte le Parts di una istanza, e quando una di
% queste Parts è un method, allora crea il metodo in questione
% a runtime, eseguibile solamente dalla istanza appena creata
% nella make/3.
examination(_, []).
examination(InstanceName, [Part|Parts]):-
    Part=method(MethodName, [], MethodBody),
    Term=..[MethodName,
             InstanceName],
    term_string(MethodBody, AtomBody),
    replace(this, InstanceName, AtomBody, NewAtomBody),
    term_string(NewMethodBody, NewAtomBody),
    assert(Term:-NewMethodBody),
    examination(InstanceName, Parts).
examination(InstanceName, [Part|Parts]):-
    Part=method(MethodName, _, MethodBody),
    term_string(MethodBody, AtomBody),
    replace(this, InstanceName, AtomBody, NewAtomBody),
    term_string(NewMethodBody, NewAtomBody),
    term_singletons(NewMethodBody, ListUnbounded),
    Term=..[MethodName,
            InstanceName,
            ListUnbounded],
    assert(Term:-NewMethodBody),
    examination(InstanceName, Parts).
examination(InstanceName, [Part|Parts]):-
    Part=field(_,_),
    examination(InstanceName, Parts).
examination(InstanceName, [Part|Parts]):-
    Part=field(_,_,_),
    examination(InstanceName, Parts).



% Caso base: la stringa è vuota, non c'è nulla da sostituire
replace(_, _, "", "").

% Se la sottostringa corrente è quella da sostituire, sostituiscila con la nuova sottostringa
replace(Old, New, StringaOriginale,StringaModificata) :-
    sub_string(StringaOriginale, Before, _, After, Old),
    sub_string(StringaOriginale, 0, Before, _, Prefisso),
    sub_string(StringaOriginale, _, After, 0, Suffisso),
    string_concat(Prefisso, New, Temp),
    string_concat(Temp, Suffisso, TempStringaModificata),
    replace(Old, New, TempStringaModificata,StringaModificata).
% Se la sottostringa corrente non è quella da sostituire, mantienila invariata
replace(Old, _, StringaOriginale,StringaModificata) :-
    not(sub_string(StringaOriginale, _, _, _, Old)),
    StringaModificata = StringaOriginale.





% list_to_sequence/2
% Trasforma una lista in una sequenza, predicato utile in più
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
    class(ClassName,_,_).

% is_instance/1
% Verifica se esiste un'istanza Value(senza controllare la
% classe di questa istanza).
is_instance(Value) :-
    instance(Value, _, _).

% is_instance/2
% Verifica se esiste un'istanza di una determinata classe
% classe o superclasse.
is_instance(Value, Class) :-
    instance(Value, Class, _),
    !.
is_instance(Value, Superclass) :-
    instance(Value, Class, _),
    class(Class, Parents, _),
    member(Superclass, Parents),
    !.
is_instance(Value, Superclass) :-
    instance(Value, Class, _),
    class(Class, Parents, _),
    is_instance_helper(Parents, [], Superclass),
    !.

% is_instance_helper/2
% Predicato ausiliario di is_instance, utile per
% fare delle verifiche sugli "antenati" di una
% classe.
is_instance_helper([], POPs, Superclass):-
    member(Superclass, POPs).
is_instance_helper([Parent | Parents], POPs, Superclass) :-
    class(Parent, POP, _),
    append(POP, POPs, NewPOPs),
    is_instance_helper(Parents, NewPOPs, Superclass).

% inst/2
% Recupera un istanza dato il suo nome.
inst(InstanceName, Instance) :-
    instance(InstanceName, _, _),
    Instance=InstanceName.

% field/3
% Estrae il valore di un campo da una classe.
field(InstanceName, FieldName, Result) :-
    var(Result),
    instance(InstanceName, _, Fields),
    memberchk(FieldName=Value, Fields),
    Result = Value.

% fieldx/3
% Insieme a find_field_values/2, estrae i valori dei
% fields indicati come lista in FieldNames.
fieldx(InstanceName, FieldNames, Values) :-
    var(Values),
    is_list(FieldNames),
    instance(InstanceName, _, Fields),
    find_field_values(FieldNames, Fields, ValuesList),
    get_last_value(ValuesList, ValueList),
    list_to_sequence(ValueList, Value),
    Values = Value,
    !.

% find_field_values/3
% Predicato ausiliario di fieldx/3.
find_field_values([], _, []).
find_field_values([FieldName | Rest], Fields,
                  [Value | RestValues]) :-
    memberchk(FieldName=Value, Fields),
    find_field_values(Rest, Fields, RestValues).

% get_last_value/2
% Chiamato da fieldx, restituisce l'ultima occorenza
% del predicato find_field_values.
get_last_value([_|Rest], Value) :-
    not(Rest = []),
    get_last_value(Rest, Value).
get_last_value(Values, Value) :-
    Values = Value.
