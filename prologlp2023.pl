:- dynamic class/2, field/2, field/3, method/3.

def_class(ClassName, Parents):-
    not(class(ClassName, _)),
    assert(class(ClassName, Parents)).

def_class(ClassName, Parents, Parts):-
    not(class(ClassName, _)),
    assert(class(ClassName, Parents)),
    parts_assertion(ClassName, Parts).


parts_assertion(_, []).

parts_assertion(ClassName, [Part|Rest]):-
    assert(Part),
    parts_assertion(ClassName, Rest).


field(FieldName, Value):-
    assert(field(FieldName, Value)).

field(FieldName, Value, Type):-
    assert(field(FieldName, Value, Type)).


method(MethodName, ArgList, Form):-
    assert(method(MethodName, ArgList, Form)).



