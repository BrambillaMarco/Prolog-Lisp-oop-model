is_class('(Class)') :-
    class(Class, _Parents).

is_instance('(Instance, ClassName)') :-
    instance(Instance, ClassName).

is_instance('(Instance)') :-
    instance(Instance, _).

inst('(InstanceName, Instance)') :-
    instance(InstanceName, _),
    Instance = InstanceName.

field('(Instance, FieldName, Result)') :-
    field(Instance, FieldName, Result).

fieldx('(Instance, FieldNames, Result)') :-
    fieldx_recursive(Instance, FieldNames, Result).

fieldx_recursive(Instance, [FieldName], Result) :-
    field(Instance, FieldName, Result).

fieldx_recursive(Instance, [FieldName | Rest], Result) :-
    field(Instance, FieldName, NextInstance),
    fieldx_recursive(NextInstance, Rest, Result).

%Per semplificare, ho creato un predicato ausiliario fieldx_recursive che gestisce la catena di attributi. Assicurati di testare queste implementazioni con casi di utilizzo specifici. Se tutto funziona correttamente, possiamo procedere con le successive primitive o apportare eventuali correzioni necessarie.
