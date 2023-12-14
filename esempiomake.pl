make(InstanceName, ClassName, Fields) :-
    class(ClassName, _Parents), % Verifica se la classe � definita

    % Verifica se l'istanza esiste gi�
    (   instance(InstanceName, ClassName) ->
        true  % L'istanza esiste gi�, nessuna azione richiesta
    ;   % Creazione di una nuova istanza
        assert(instance(InstanceName, ClassName)),
        % Unificazione dei campi della nuova istanza
        set_fields(InstanceName, Fields)
    ).

set_fields(_, []).
set_fields(Instance, [Field=FieldValue | Rest]) :-
    assert(field(Instance, Field, FieldValue)),
    set_fields(Instance, Rest).
