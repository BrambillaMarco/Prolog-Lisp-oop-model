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

def_class(ClassName, Parents, Parts)

check_parents([]).

check_parents([Parent|Parents]):-
    class(Parent, _, _),
    check_parents(Parents).
