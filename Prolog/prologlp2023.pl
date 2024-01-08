:- dynamic
    class/3,
    instance/3,
    method/3.
:-discontiguous
    create_method/6,
    create_method_finisher/6.

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
    ord_union(InheritedParts, Parts, AllParts),
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
% verifica se una parte e' un campo o un metodo
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
% eredita i campi e/o i metodi delle classi genitore
legacy([], []).
legacy([Parent|Parents], Out) :-
    class(Parent, _, ParentParts),
    legacy(Parents, Rest),
    ord_union(ParentParts, Rest, Out).


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
    transform_fields(ClassParts, TransformedFields),
    union_fields(Fields, TransformedFields, AllFields),
    assert(instance(InstanceName, ClassName, AllFields)),
    examination(InstanceName, ClassParts).


% validate_fields/2
% verifica se i campi dell'istanza esistono
% nella classe
validate_fields([], _).
validate_fields([FieldName = Value| Rest], ClassFields) :-
    (
        member(field(FieldName, _), ClassFields);
        member(field(FieldName, _, Type), ClassFields),
        compatible_type(Value, Type)
    ),
    validate_fields(Rest, ClassFields).


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
% trasforma i campi da field(Name, Value) a Name=Value
transform_fields([], []).
transform_fields([Field | Rest],
                 [KeyValue | TransformedRest]) :-
    transform_field(Field, KeyValue),
    transform_fields(Rest, TransformedRest).


% transform_field/2
% trasforma i campi da field(Name, Value) a Name=Value
transform_field(field(Name, Value), Name=Value).
transform_field(field(Name, Value, _), Name=Value).
transform_field(method(Name, _, _), method=Name).


% union_fields/3
% unisce i campi della make con i campi della classe, non
% duplicandoli
union_fields([], List2, List2).
union_fields([Field | Rest1], List2, Union) :-
    replace_value(Field, List2, UpdatedList),
    union_fields(Rest1, UpdatedList, Union).


% replace_value/3
% se i campi esistono nella classe sovrascrive il risultato
% della make
replace_value(NewField, [], [NewField]).
replace_value(NewField, [OldField | Rest],
              [UpdatedField | Rest]) :-
    equivalent_field(NewField, OldField),
    !,
    UpdatedField = NewField.
replace_value(NewField, [OldField | Rest], [OldField | UpdatedRest]) :-
    replace_value(NewField, Rest, UpdatedRest).


% equivalent_field/2
% verifica se i due nomi sono equivalenti
equivalent_field(Name=_, Name=_).


% examination/2
% in una make viene chiamato per esaminare field e method
% e nel caso incontri quest'ultimi, crea il metodo per l'istanza
% InstanceName
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
    list_to_sequence(MethodAttributes, MethodAttributesSequence),
    create_method(InstanceName,
                  MethodName,
                  MethodAttributesSequence,
                  MethodBody,
                  [],
                  NewMethodBody),
    Term=..[MethodName, InstanceName, MethodAttributesSequence],
    assert(Term:-NewMethodBody),
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
    append([List,[field(InstanceName, FieldName, Value)]], NewList),
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
create_method_finisher(_, _, [], _, NewList, NewMethodBody):-
    list_to_sequence(NewList, X),
    X=NewMethodBody.

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
    append([List,[field(InstanceName, FieldName, Value)]], NewList),
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
create_method_finisher(_, _, _, _, NewList, NewMethodBody):-
    list_to_sequence(NewList, X),
    X=NewMethodBody.


list_to_sequence([X], X).
list_to_sequence([H | T], (H, Rest)) :-
    list_to_sequence(T, Rest).
list_to_sequence([], true).



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
    var(Result),
    instance(InstanceName, _, Fields),
    memberchk(FieldName=Value, Fields),
    Result = Value.


% fieldx/3
% estrae
fieldx(InstanceName, FieldNames, Values) :-
    var(Values),
    is_list(FieldNames),
    instance(InstanceName, _, Fields),
    find_field_values(FieldNames, Fields, Values).

find_field_values([], _, []).
find_field_values([FieldName | Rest], Fields,
                  [Value | RestValues]) :-
    memberchk(FieldName=Value, Fields),
    find_field_values(Rest, Fields, RestValues).
