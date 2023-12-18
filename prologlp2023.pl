:- dynamic class/2,
           field/2,
           field/3,
           method/3,
           instance/3,
           cf/2,
           cm/2.


def_class(ClassName, Parents):-
    not(class(ClassName, _)),
    check_parents(Parents),
    assert(class(ClassName, Parents)).

def_class(ClassName, Parents, Parts):-
    not(class(ClassName, _)),
    check_parents(Parents),
    assert(class(ClassName, Parents)),
    parts_assertion(ClassName, Parts).


check_parents([]).

check_parents([Parent|Parents]):-
    class(Parent, _),
    check_parents(Parents).


parts_assertion(_, []).

parts_assertion(ClassName, [Part|Rest]):-
    Part=field(_,_),
    assert(Part),
    assert(cf(ClassName, Part)),
    parts_assertion(ClassName, Rest).

parts_assertion(ClassName, [Part|Rest]):-
    Part=field(_,_,_),
    assert(Part),
    assert(cf(ClassName, Part)),
    parts_assertion(ClassName, Rest).

parts_assertion(ClassName, [Part|Rest]):-
    Part=method(_,_,_),
    assert(Part),
    assert(cm(ClassName, Part)),
    parts_assertion(ClassName, Rest).


field(FieldName, Value):-
    assert(field(FieldName, Value)).

field(FieldName, Value, Type):-
    assert(field(FieldName, Value, Type)).


method(MethodName, ArgList, Form):-
    assert(method(MethodName, ArgList, Form)).


make(InstanceName, ClassName):-
    not(instance(InstanceName, ClassName, _)),
    class(ClassName, _),
    assert(instance(InstanceName, ClassName, [])),
    concat_atom(["Hai creato l'istanza ",
                 InstanceName,
                 " per la classe ",
                 ClassName],
                 WO),
    write(WO).












