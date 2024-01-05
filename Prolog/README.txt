Brambilla Marco, mat. 
Colciago Federico, mat. 858643
Condello Paolo, mat. 829800

predicato def_class(NomeClasse, [Genitori], [Parti]):
    crea una classe con nome = NomeClasse;
    "estende" le classi contenute nella lista [Genitori], ereditandone sia i campi
        che i metodi;
    possiede campi e metodi inclusi nella lista [Parti]; qualora la lista sia
        inesistente o vuota, viene creata una classe con [Parti] = [].

predicato make(NomeIstanza, Classe, [FieldName = Value]):
    crea un'istanza di una classe Genitore, con nome = NomeIstanza;
    eredita campi e metodi della classe Genitore, sovrascrivendo i valori
        dei campi presenti nella lista [FieldName = Value], restituendo così
        un'istanza con una lista di campi del tipo [FieldName = Value];
    installa i metodi ereditati dalla classe che potranno essere invocati
        con NomeMetodo(NomeIstanza);
    nel caso [FieldName = Value] sia una lista vuota verrà creata un'istanza senza
        campi.

predicato is_class(NomeClasse):
    verifica se esiste una classe con nome = NomeClasse.

predicato is_instance(NomeIstanza):
    verifica se esiste un'istanza con nome = NomeIstanza.
predicato is_instance(NomeIstanza, SuperClasse):
    verifica se esiste un'istanza con nome = InstanceName e che abbia come
        genitore la classe SuperClasse

predicato inst(NomeIstanza, Risultato):
    verifica 

predicato field(NomeIstanza, NomeCampo, Risultato):
    verifica se nell'istanza con nome = NomeIstanza esiste il campo con
        nome = NomeCampo, ne estrae il valore e lo unifica al Risultato.

predicato fieldx(NomeIstanza, [NomiCampi], Risultato):
    verifica se nell'istanza con nome = NomeIstanza esistono i campi con
        nomi = [NomeCampi], ne estrae i valori e li unifica al Risultato.

