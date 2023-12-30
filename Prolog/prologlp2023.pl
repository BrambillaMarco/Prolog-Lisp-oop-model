:- dynamic
    class/3,
    instance/3,
    method/3.

% def_class/2
% definisce una classe con nome e genitori
def_class(ClassName, Parents):-
    def_class(ClassName, Parents, []).


% def_class/3
% definisce una classe con nome, genitori, campi e metodi
def_class(ClassName, Parents, Parts):-
    not(class(ClassName, _, _)),
    is_list(Parents),
    exist_parents(Parents),
    check_parts(ClassName, Parts),
    legacy(Parents, InheritedParts),
    append(InheritedParts, Parts, AllParts),
    assert(class(ClassName, Parents, AllParts)).


% exist_parents/1
% verifica se esistono le classi genitori
exist_parents([]).
exist_parents([Parent | Parents]):-
    class(Parent, _, _),
    exist_parents(Parents).


% check_parts/2
% insieme a check_part/2 controlla che la sintassi delle parti
% sia corretta
check_parts(_, []).
check_parts(ClassName, [Part | Rest]):-
    check_part(ClassName, Part),
    check_parts(ClassName, Rest).


% check_part/2
% verifica se una parte � un campo o un metodo
check_part(_, field(_, _)).
check_part(_, field(_, _, _)).
check_part(_, method(_, _, _)).


% legacy/2
% eredita i campi e/o i metodi delle classi genitore
legacy([], []).
legacy([Parent|Parents], Out) :-
    class(Parent, _, ParentParts),
    legacy(Parents, Rest),
    append(ParentParts, Rest, Out).


% make/2
% crea l'istanza di una classe attribuendo valori
% ai campi
make(InstanceName, ClassName):-
    make(InstanceName, ClassName, []).


% make/3
% crea l'istanza di una classe attribuendo valori
% ai campi
make(InstanceName, ClassName, Fields) :-
    not(instance(InstanceName, ClassName, _)),
    class(ClassName, _, ClassParts),
    is_list(Fields),
    validate_fields(Fields, ClassParts),
    transform_fields(Fields, Out),
    examination(InstanceName, ClassParts),
    assert(instance(InstanceName, ClassName, Out)).


% validate_fields/2
% verifica se i campi dell'istanza esistono
% nella classe
validate_fields([], _).
validate_fields([FieldName = _| Rest], ClassFields) :-
    (
        member(field(FieldName, _), ClassFields);
        member(field(FieldName, _, _), ClassFields)
    ),
    validate_fields(Rest, ClassFields).

% transform_fields/2
% trasfroma i campi da lista a funtore
transform_fields([], []).
transform_fields([FieldName = Value | Rest],
                 [Field | TransformedRest]) :-
    Field =.. [field, FieldName, Value],
    transform_fields(Rest, TransformedRest).

% examination/2
% esamina se le parti di una classe sono dei campi o dei metodi
examination(_, []).
examination(InstanceName, [Part|Parts]):-
    Part=method(MethodName, MethodAttributes, MethodBody),
    create_method(InstanceName,
                  MethodName,
                  MethodAttributes,
                  MethodBody),
    examination(InstanceName, Parts).
examination(InstanceName, [Part|Parts]):-
    Part=field(_,_),
    examination(InstanceName, Parts).
examination(InstanceName, [Part|Parts]):-
    Part=field(_,_,_),
    examination(InstanceName, Parts).


% create_method/4
% crea dinamicamente le regole per i metodi
% specifici dell'istanza
create_method(InstanceName, MethodName, [], MethodBodyList):-
    Term=..[MethodName, InstanceName],
    list_to_sequence(MethodBodyList, MethodBody),
    assert(Term :- MethodBody).


% list_to_sequence/2
% trasforma una lista in una sequenza
list_to_sequence([], true).
list_to_sequence([X], X).
list_to_sequence([H | T], (H, Rest)) :-
    list_to_sequence(T, Rest).


% is_class/1
% verifica se esiste la classe
is_class(ClassName) :-
    class(ClassName,_,_).


% is_instance/1
% verifica se esiste un'istanza generica
is_instance(Value) :-
    instance(Value, _, _).


% is_instance/2
% verifica se esiste un'istanza con una determinato
% genitore/superclasse
is_instance(Value, SuperClass) :-
    instance(Value, Class, _),
    class(Class, Parents, _),
    member(SuperClass, Parents).


% inst/2
% recupera un istanza dato il suo nome
inst(InstanceName, Instance) :-
    instance(InstanceName, ClassName, Fields),
    Instance=instance(InstanceName, ClassName, Fields).


% field/3
% estrae il valore di un campo da una classe
field(InstanceName, FieldName, Result) :-
    instance(InstanceName, _, Fields),
    Result = member(instance(InstanceName, _, FieldName),
                    Fields).

% fieldx/3
% estrae