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


% legacy(_, [], [], []).

% legacy(ClassName, [], PastParents, In):-
%    retract(class(ClassName, _, _)),
%    assert(class(ClassName, PastParents, In)).

% legacy(ClassName, [Parent|Parents], PastParents, In):-
%    findall(Parts, class(Parent, _, Parts), FA),
%    append(In, FA, Out),
%    append([Parent], PastParents, PP),
%    legacy(ClassName, Parents, PP, Out).

% check_parts/1
% verifica se campi e/o metodi sono scritti correttamente
check_parts([]).
check_parts([Part | Rest]):-
    Part=field(_, _),
    check_parts(Rest).
check_parts([Part | Rest]):-
    Part=field(_, _, _),
    check_parts(Rest).
check_parts([Part|Rest]):-
    Part=method(_, _, _),
    check_parts(Rest).

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
% verifica se esiste un'istanza con una determinata
% superclasse
is_instance(Value, ClassName) :-
    check_superclass(ClassName, Class),
    instance(Value, Class, _).


% check_superclass/2
% verifica se una classe � figlia di un'altra classe
check_superclass([], _).
check_superclass(SuperClass, Class) :-
    class(Class, [SuperClass | OtherSuperClass], _),
    check_superclass(OtherSuperClass, Class).

% inst/2
% recupera il nome con cui � stata creata una
% istanza
inst(InstanceName, Instance) :-
    instance(InstanceName, _, _).





