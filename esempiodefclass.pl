:- dynamic class/2, field/3, method/3, instance/2.

def_class(Class, Parents, Parts) :-
    assert(class(Class, Parents)),
    process_parts(Class, Parts).

process_parts(_, []).
process_parts(Class, [Part|Rest]) :-
    assert(Part),
    process_parts(Class, Rest).

field(field(Class, FieldName, Value)) :-
    assert(field(Class, FieldName, Value)).
field(field(Class, FieldName, Value, Type)) :-
    assert(field(Class, FieldName, Value, Type)).

method(method(Class, MethodName, ArgList, Form)) :-
    assert(method(Class, MethodName, ArgList, Form)).
