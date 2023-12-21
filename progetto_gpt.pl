:- dynamic
    class/3.

def_class(ClassName, Parents, Parts):-
    not(class(ClassName, _, _)),
    is_list(Parents),
    check_parents(Parents),
    check_parts(Parts),
    check_legacy(Parents, InheritedParts),
    append(InheritedParts, Parts, AllParts),
    asserta(class(ClassName, Parents, AllParts)).

check_parents([]).
check_parents([Parent|Parents]):-
    class(Parent, _, _),
    check_parents(Parents).

check_parts([]).
check_parts([Part|Rest]):-
    (Part=field(_, _) ; Part=method(_, _, _)),
    check_parts(Rest).

check_legacy([], []).
check_legacy([Parent|Parents], Out) :-
    class(Parent, _, ParentParts),
    check_legacy(Parents, Rest),
    append(ParentParts, Rest, Out).
