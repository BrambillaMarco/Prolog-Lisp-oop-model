:- dynamic class/3,
           instance/3.

% Predicato ausiliario per la creazione dinamica di regole per un'istanza specifica
create_instance_method_rule(InstanceName, MethodName, MethodAttributes, MethodBody) :-
    atomic_list_concat([InstanceName, MethodName|MethodAttributes], '_', RuleName),
    assertz((RuleName :- call_instance_method(InstanceName, MethodBody))).

% Predicato ausiliario per chiamare dinamicamente i metodi di un'istanza
call_instance_method(_, []) :- !.
call_instance_method(InstanceName, [Action|Rest]) :-
    instance(InstanceName, _, _),  % Verifica che l'istanza esista
    call(Action, InstanceName),
    call_instance_method(InstanceName, Rest).

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
    check_parts(Parts),
    check_legacy(Parents, InheritedParts),
    append(InheritedParts, Parts, AllParts),
    assert(class(ClassName, Parents, AllParts)).

% check_parents/1
% verifica se esistono le classi genitori
check_parents([]).
check_parents([Parent | Parents]):-
    class(Parent, _, _),
    check_parents(Parents).

% check_parts/1
% verifica se campi e/o metodi sono scritti correttamente
check_parts([]).
check_parts([Part | Rest]):-
    (Part = field(_, _), check_parts(Rest));
    (Part = field(_, _, _), check_parts(Rest));
    (Part = method(MethodName, MethodAttributes, MethodBody),
     create_instance_method_rule(_, MethodName, MethodAttributes, MethodBody),
     check_parts(Rest)).

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