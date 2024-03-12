%%%% -*- Mode: Prolog -*-

%%%% Brambilla Marco 856428
%%%% Colciago Federico 858643
%%%% Condello Paolo 829800

:- dynamic
    class/3,
    instance/3,
    method/3.

% def_class/2
% Definisce una classe con nome e genitori,
% senza campi o metodi. Richiama il predicato
% def_class/3.
def_class(ClassName, Parents) :-
    def_class(ClassName, Parents, []),
    !.

% def_class/3
% Definisce una classe con nome e genitori,
% con campi e metodi.
def_class(ClassName, Parents, Parts) :-
    not(var(ClassName)),
    not(is_list(ClassName)),
    not(is_class(ClassName)),
    is_list(Parents),
    is_list(Parts),
    list_to_set(Parents, ParentsSet),
    exist_parents(ParentsSet),
    check_parts(Parts),
    legacy(ParentsSet, InheritedParts),
    check_override(InheritedParts,
                   Parts,
                   [],
                   NewInheritedParts),
    ord_union(NewInheritedParts, Parts, AllParts),
    assert(class(ClassName, Parents, AllParts)),
    !,
    write("E' stata creata la classe "),
    write(ClassName),
    write(" e i suoi genitori sono: "),
    write(Parents),
    write(".").

% exist_parents/1
% Verifica se esistono le classi genitori passate
% dalla def_class/3.
exist_parents([]).
exist_parents([Parent | Parents]) :-
    is_class(Parent),
    exist_parents(Parents).

% check_parts/1
% Controlla che la sintassi dei campi e dei
% metodi sia corretta.
check_parts([]).
check_parts([Part | Parts]) :-
    check_part(Part),
    check_parts(Parts).

% check_part/1
% Verifica se la Part presa in questione e' un campo
% o un metodo. Nel primo caso analizza anche se
% il valore del campo corrisponde al tipo.
check_part(field(FieldName, Value)) :-
    not(is_list(FieldName)),
    not(is_list(Value)).
check_part(field(FieldName, Value, integer)) :-
    not(is_list(FieldName)),
    not(is_list(Value)),
    integer(Value).
check_part(field(FieldName, Value, float)) :-
    not(is_list(FieldName)),
    not(is_list(Value)),
    float(Value).
check_part(field(FieldName, Value, atom)) :-
    not(is_list(FieldName)),
    not(is_list(Value)),
    atom(Value).
check_part(field(FieldName, Value, string)) :-
    not(is_list(FieldName)),
    not(is_list(Value)),
    string(Value).
check_part(field(FieldName, Value, Type)) :-
    not(is_list(FieldName)),
    not(is_list(Value)),
    not(is_list(Type)),
    is_class(Type),
    is_instance(Value, Type).
check_part(field(FieldName, null, Type)) :-
    not(is_list(FieldName)),
    not(is_list(Type)),
    is_class(Type).
check_part(method(MethodName, Arglist, Form)) :-
    not(is_list(MethodName)),
    is_list(Arglist),
    compound(Form).

% legacy/2
% Eredita i campi e i metodi delle classi genitori.
legacy([], []).
legacy([Parent | Parents], AllParts) :-
    class(Parent, _, ParentParts),
    legacy(Parents, RestParts),
    ord_union(ParentParts, RestParts, AllParts).

% check_override/4
% Sovrascrive tutti i campi e i metodi ereditati
% che hanno lo stesso nome con quelli creati
% dalla def_class/3.
check_override([], _,
               List, NewInheritedParts) :-
    List = NewInheritedParts.
check_override([InheritedPart | InheritedParts],
               Parts, List, NewInheritedParts) :-
    InheritedPart = field(FieldName, _),
    member(field(FieldName, _), Parts),
    check_override(InheritedParts, Parts,
                   List, NewInheritedParts).
check_override([InheritedPart | InheritedParts],
               Parts, List, NewInheritedParts) :-
    InheritedPart = field(FieldName, _, _),
    member(field(FieldName, _, _), Parts),
    check_override(InheritedParts, Parts,
                   List, NewInheritedParts).
check_override([InheritedPart | InheritedParts],
               Parts, List, NewInheritedParts) :-
    InheritedPart = method(MethodName, _, _),
    member(method(MethodName, _, _), Parts),
    check_override(InheritedParts, Parts,
                   List, NewInheritedParts).
check_override([InheritedPart | InheritedParts],
               Parts, List, NewInheritedParts) :-
    append([[InheritedPart], List], NewList),
    check_override(InheritedParts, Parts,
                   NewList, NewInheritedParts).

% make/2
% Crea un'istanza di una classe senza
% modificare i valori dei campi. Richiama
% il predicato make/3.
make(InstanceName, ClassName) :-
    make(InstanceName, ClassName, []).

% make/3
% Crea un'istanza di una classe modificando
% i valori dei campi passati.
make(InstanceName, ClassName, Fields) :-
    var(InstanceName),
    not(is_list(ClassName)),
    is_class(ClassName),
    Fields = [],
    findall(X, instance(X, ClassName, _), Instances),
    member(Y, Instances),
    InstanceName = Y.
make(InstanceName, ClassName, Fields) :-
    var(InstanceName),
    not(is_list(ClassName)),
    is_class(ClassName),
    not(Fields = []),
    findall(X, instance(X, ClassName, Fields), Instances),
    member(Y, Instances),
    InstanceName = Y.
make(InstanceName, ClassName, Fields) :-
    not(var(InstanceName)),
    not(is_list(InstanceName)),
    not(is_list(ClassName)),
    not(is_instance(InstanceName, ClassName)),
    class(ClassName, _, ClassParts),
    is_list(Fields),
    validate_fields(Fields, ClassParts),
    transform_fields(ClassParts, TransformedFields),
    union_fields(Fields, TransformedFields, AllFields),
    create_method(InstanceName, ClassParts),
    assert(instance(InstanceName, ClassName, AllFields)),
    !,
    write("E' stata creata l'istanza "),
    write(InstanceName),
    write(" della classe"),
    write(ClassName).
make(InstanceName, ClassName, Fields) :-
    var(InstanceName),
    not(is_instance(_, ClassName)),
    !,
    InstanceName = instance(istanza, ClassName, Fields).

% validate_fields/2
% Verifica se i campi dell'istanza esistono nella
% classe.
validate_fields([], _).
validate_fields([FieldName = _ | Rest], ClassFields) :-
    member(field(FieldName, _), ClassFields),
    validate_fields(Rest, ClassFields).
validate_fields([FieldName = Value | Rest], ClassFields) :-
    member(field(FieldName, _, Type), ClassFields),
    compatible_type(Value, Type),
    validate_fields(Rest, ClassFields).

% compatible_type/2
% Verifica se i valori passati dalla make/3
% corrispondano al tipo dei campi specificati nella
% def_class/3.
compatible_type(Value, integer) :-
    integer(Value).
compatible_type(Value, float) :-
    float(Value).
compatible_type(Value, atom) :-
    atom(Value).
compatible_type(Value, string) :-
    string(Value).
compatible_type(Value, Type) :-
    is_class(Type),
    is_instance(Value).
compatible_type(Value, Type) :-
    Value = null,
    is_class(Type).

% transform_field/2
% Trasforma i campi da field(Name, Value) a Name = Value.
% Chiama la transform_field/2.
transform_fields([], []).
transform_fields([Field | Rest],
                 [Value | TransformedRest]) :-
    transform_field(Field, Value),
    transform_fields(Rest, TransformedRest).

% transform_field/2
% Trasforma il campo corrente da field(Name, Value)
% a Name = Value. Inoltre restituisce il nome dei
% metodi sotto forma di method = MethodName.
transform_field(field(FieldName, Value),
                FieldName = Value).
transform_field(field(FieldName, Value, _),
                FieldName = Value).
transform_field(method(MethodName, _, _),
                method = MethodName).

% union_fields/3
% Unisce i campi passati dalla make/3 con i campi
% della classe, non duplicandoli.
union_fields([], List, List).
union_fields([Field | Rest], List, Union) :-
    replace_value(Field, List, UpdatedList),
    union_fields(Rest, UpdatedList, Union).

% replace_value/3
% Sovrascrive il valore del campo corrente con il
% valore dello stesso campo passatogli dalla make/3.
replace_value(NewField, [], [NewField]).
replace_value(NewField, [OldField | Rest],
              [UpdatedField | Rest]) :-
    equivalent_field(NewField, OldField),
    !,
    UpdatedField = NewField.
replace_value(NewField, [OldField | Rest],
              [OldField | UpdatedRest]) :-
    replace_value(NewField, Rest, UpdatedRest).

% equivalent_field/2
% Verifica se il nome di due campi e' uguale.
equivalent_field(Name = _, Name = _).

% create_method/2
% Crea i metodi legati all'istanza della make/3.
create_method(_, []).
create_method(InstanceName, [Part | Parts]) :-
    Part = method(MethodName, [], MethodBody),
    Term =.. [MethodName, InstanceName],
    term_string(MethodBody, StringBody),
    replace(this, InstanceName,
            StringBody, NewStringBody),
    term_string(NewMethodBody, NewStringBody),
    assert(Term :- NewMethodBody),
    create_method(InstanceName, Parts).
create_method(InstanceName, [Part | Parts]) :-
    Part = method(MethodName, MethodAttributes, MethodBody),
    MethodAttributes \= [],
    term_string(MethodBody, StringBody),
    replace(this, InstanceName,
            StringBody, NewStringBody),
    term_string(NewMethodBody, NewStringBody),
    term_singletons(NewMethodBody, ListVariablesUnbounded),
    list_to_sequence(ListVariablesUnbounded,
                     SequenceVariablesUnbounded),
    Term =.. [MethodName,
              InstanceName,
              SequenceVariablesUnbounded],
    assert(Term :- NewMethodBody),
    create_method(InstanceName, Parts).
create_method(InstanceName, [Part | Parts]) :-
    Part = field(_, _),
    create_method(InstanceName, Parts).
create_method(InstanceName, [Part | Parts]) :-
    Part = field(_, _, _),
    create_method(InstanceName, Parts).

% replace/4
% Sostituisce il this con il nome dell'istanza passata
% dalla make/3.
replace(_, _, "", "").
replace(OldWord, NewWord, OldString, NewString) :-
    sub_string(OldString, Before, _, After, OldWord),
    sub_string(OldString, 0, Before, _, Prefix),
    sub_string(OldString, _, After, 0, Suffix),
    string_concat(Prefix, NewWord, Temp),
    string_concat(Temp, Suffix, TempNewString),
    replace(OldWord, NewWord, TempNewString, NewString).
replace(OldWord, _, OldString, NewString) :-
    not(sub_string(OldString, _, _, _, OldWord)),
    NewString = OldString.

% list_to_sequence/2
% Trasforma una lista in una sequenza.
list_to_sequence([Head], Head).
list_to_sequence([Head | Tail], (Head, Rest)) :-
    list_to_sequence(Tail, Rest).
list_to_sequence([], true).

% is_class/1
% Verifica se esiste la classe passata.
is_class(ClassName) :-
    class(ClassName, _, _).

% is_instance/1
% Verifica se esiste l'istanza passata.
is_instance(Value) :-
    instance(Value, _, _).

% is_instance/2
% Verifica se esiste la classe di una determinata
% classe.
is_instance(Value, ClassName) :-
    instance(Value, ClassName, _).
is_instance(Value, SuperClass) :-
    instance(Value, Class, _),
    class(Class, Parents, _),
    member(SuperClass, Parents).
is_instance(Value, SuperClass) :-
    instance(Value, Class, _),
    class(Class, Parents, _),
    ancestors(Parents, [], SuperClass).

% ancestors/3
% Verifica gli antenati di una classe.
ancestors([], ParentOfParents, SuperClass) :-
    member(SuperClass, ParentOfParents).
ancestors([Parent | Parents], ParentOfParents,
          SuperClass) :-
    class(Parent, ParentOfParent, _),
    append(ParentOfParent, ParentOfParents,
           NewParentOfParents),
    ancestors(Parents, NewParentOfParents, SuperClass).

% inst/2
% Recupera un'istanza dato il suo nome.
inst(InstanceName, Instance) :-
    var(Instance),
    is_instance(InstanceName),
    Instance = InstanceName.
inst(InstanceName, Instance) :-
    not(var(Instance)),
    is_instance(InstanceName),
    is_instance(Instance),
    InstanceName = Instance.

% field/3
% Estrae il valore di un campo da un'istanza.
field(InstanceName, FieldName, Result) :-
    not(is_list(FieldName)),
    var(Result),
    instance(InstanceName, _, Fields),
    memberchk(FieldName = Value, Fields),
    Result = Value.
field(InstanceName, FieldName, Result) :-
    not(is_list(FieldName)),
    not(is_list(Result)),
    not(var(Result)),
    instance(InstanceName, _, Fields),
    memberchk(FieldName = Value, Fields),
    Result = Value.

% fieldx/3
% Estrae il valore dell'ultimo campo passato di una
% data istanza.
fieldx(InstanceName, FieldNames, Result) :-
    var(Result),
    is_list(FieldNames),
    instance(InstanceName, _, Fields),
    find_field_values(FieldNames, Fields, ValuesList),
    last(ValuesList, LastValue),
    Result = LastValue.

% find_field_values/3
% Verifica se esistono tutti i campi passati e ne estrae
% i valori.
find_field_values([], _, []).
find_field_values([FieldName | Rest], Fields,
                  [Value | RestValues]) :-
    memberchk(FieldName = Value, Fields),
    find_field_values(Rest, Fields, RestValues).

%%%% end of file -- oop.pl --
