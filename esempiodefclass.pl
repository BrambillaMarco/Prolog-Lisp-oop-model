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

create_instance(Class, Instance) :-
    assert(instance(Instance, Class)).

call_method(Instance, MethodName, Args) :-
    instance(Instance, Class),
    method(Class, MethodName, ArgList, Form),
    append(ArgList, [this=Instance], FullArgList),
    call(Form).

% Esempio di utilizzo
def_class(persona, [], [
    field(persona, nome, ''),
    field(persona, eta, 0),
    method(persona, saluta, [this], (
        format('Ciao, sono ~w e ho ~d anni.~n', [this:nome, this:eta])
    ))
]).

def_class(studente, [persona], [
    field(studente, corso, ''),
    method(studente, saluta, [this], (
        call_method(this, saluta, []),
        format('Studio ~w.~n', [this:corso])
    ))
]).

def_class(impiegato, [persona], [
    field(impiegato, ufficio, ''),
    field(impiegato, stipendio, 0),
    method(impiegato, saluta, [this], (
        call_method(this, saluta, []),
        format('Lavoro in ufficio ~w e il mio stipendio è ~d.~n', [this:ufficio, this:stipendio])
    ))
]).

create_instance(persona, *persona1*),
create_instance(studente, *studente1*),
create_instance(impiegato, *impiegato1*).

call_method(*persona1*, saluta, []),
call_method(*studente1*, saluta, []),
call_method(*impiegato1*, saluta, []).
