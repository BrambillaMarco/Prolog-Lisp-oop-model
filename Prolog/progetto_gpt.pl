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

make(InstanceName, ClassName):-
    make(InstanceName, ClassName, []).

make(InstanceName, ClassName, Fields) :-
    not(instance(InstanceName, ClassName, _)),
    class(ClassName, _, ClassFields),
    get_inherited_fields(ClassName, InheritedFields),
    append(InheritedFields, ClassFields, AllFields),
    process_fields(Fields, AllFields, ProcessedFields),
    assert(instance(InstanceName, ClassName, ProcessedFields)).

% get_inherited_fields/2
% Ottiene la lista di tutti i campi ereditati
get_inherited_fields(Class, InheritedFields) :-
    class(Class, Parents, _),
    get_inherited_fields(Parents, InheritedFields).

get_inherited_fields([], []).
get_inherited_fields([Parent|Rest], InheritedFields) :-
    get_inherited_fields(Rest, RestInheritedFields),
    class(Parent, _, ParentFields),
    union(RestInheritedFields, ParentFields, InheritedFields).

% process_fields/3
% Unisce i campi della make con i campi della classe, gestendo la sovrascrittura
process_fields([], _, []).
process_fields([Field|Rest], ClassFields, [ProcessedField|ProcessedRest]) :-
    process_field(Field, ClassFields, ProcessedField),
    process_fields(Rest, ClassFields, ProcessedRest).

% process_field/3
% Gestisce la sovrascrittura del valore del campo
process_field(field(FieldName, Value), ClassFields, field(FieldName, NewValue)) :-
    memberchk(field(FieldName, _), ClassFields),
    !,
    NewValue = Value.
process_field(Field, _, Field).
