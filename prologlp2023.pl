:- dynamic class/3,
           field/2,
           field/3,
           method/3,
           instance/3.

def_class(ClassName, Parents):-
    not(class(ClassName, _, _)),
    is_list(Parents),
    check_parents(Parents),
    assert(class(ClassName, Parents, [])).

def_class(ClassName, Parents, Parts):-
    not(class(ClassName, _, _)),
    is_list(Parents),
    check_parents(Parents),
    check_parts(Parts),
    assert(class(ClassName, Parents, Parts)).

check_parents([]).

check_parents([Parent|Parents]):-
    class(Parent, _, _),
    check_parents(Parents).


check_parts([]).

check_parts([Part|Rest]):-
    Part=field(_,_),
    check_parts(Rest).

check_parts([Part|Rest]):-
    Part=field(_,_,_),
    check_parts(Rest).

check_parts([Part|Rest]):-
    Part=method(_,_,_),
    check_parts(Rest).


make(InstanceName, ClassName):-
    not(instance(InstanceName, ClassName, _)),
    class(ClassName, _, _),
    assert(instance(InstanceName, ClassName, [])),
    concat_atom(["Hai creato l'istanza ",
                 InstanceName,
                 " per la classe ",
                 ClassName],
                 WO),
    write(WO).












