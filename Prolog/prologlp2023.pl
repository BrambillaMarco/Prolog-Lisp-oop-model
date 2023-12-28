:- dynamic class/3,
           instance/3.

% def_class/2
% definisce una classe con nome e genitori
def_class(ClassName, Parents):-
    def_class(ClassName, Parents, []).


% def_class/3
% definisce una classe con nome, genitori, campi e metodi
def_class(ClassName, Parents, Parts):-
    not(class(ClassName, _, _)),
    is_list(Parents),
    check_parents(Parents),
    check_parts(ClassName, Parts),
    check_legacy(Parents, InheritedParts),
    append(InheritedParts, Parts, AllParts),
    assert(class(ClassName, Parents, AllParts)).


% check_parents/1
% verifica se esistono le classi genitori
check_parents([]).
check_parents([Parent | Parents]):-
    class(Parent, _, _),
    check_parents(Parents).


% check_parts/2
% insieme a check_part/2 controlla che la sintassi delle Parts
% sia corretta
check_parts(_, []).
check_parts(ClassName, [Part | Rest]):-
    check_part(ClassName, Part),
    check_parts(ClassName, Rest).

% check_part/2
% verifica se una parte � un field o un method, e in quest'ultimo
% caso, crea il metodo stesso
check_part(_, field(_, _)).
check_part(_, field(_, _, _)).
check_part(ClassName, method(MethodName, MethodAttributes, MethodBody)):-
    create_method(ClassName, MethodName, MethodAttributes, MethodBody).


% check_legacy/2
% eredita i campi e/o i metodi delle classi genitore
check_legacy([], []).
check_legacy([Parent|Parents], Out) :-
    class(Parent, _, ParentParts),
    check_legacy(Parents, Rest),
    append(ParentParts, Rest, Out).

% make/2
% crea l'istanza di una classe attribuendo valori
% ai campi
make(InstanceName, ClassName):-
    not(instance(InstanceName, ClassName, _)),
    class(ClassName, _, _),
    assert(instance(InstanceName, ClassName, [])).

make(InstanceName, ClassName):-
    var(InstanceName),
    class(ClassName, _, _),
    InstanceName=instance(InstanceName, ClassName, []).

% create_method/4
% crea dinamicamente le regole per i metodi
% specifici dell'istanza
create_method(ClassName, MethodName, MethodAttributes, MethodBody):-
    assert((MethodName:MethodAttributes :- call_method(ClassName,
                                      MethodAttributes,
                                      MethodBody))).

call_method(_, _, []).
call_method(InstanceName, MethodAttributes, [Rule|Rest]):-
    instance(InstanceName, _, _),
    call(Rule, InstanceName, MethodAttributes),
    call_method(InstanceName, MethodAttributes, Rest).


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
