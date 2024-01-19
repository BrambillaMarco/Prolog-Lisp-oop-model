;;;; Brambilla Marco 856428
;;;; Colciago Federico 858643
;;;; Condello Paolo 829800
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; -*- Mode: Lisp -*-

;;; Definisce un'hash-table globale.
(defparameter *classes-specs* (make-hash-table))

;;; Aggiunge una specifica di classe all'hash-table.
(defun add-class-spec (name class-spec)
  (setf (gethash name *classes-specs*) class-spec))

;;; Ottiene una specifica di classe dall'hash-table.
(defun get-class-spec (name)
  (gethash name *classes-specs*))



;;; Funzione "def-class" ritorna class-name se crea
;;; correttamente la classe memorizzandola nell'hash-table.
(defun def-class (class-name parents &rest parts)
  (cond
   ((not (symbolp class-name))
    (error "Error: class-name non e' un simbolo"))
   ((not (listp parents))
    (error "Error: le superclassi non sono in una lista"))
   ((parents-control class-name parents)
    (error "Error: superclasse/i non valida/e"))
   ((not (check-parts parts))
    (error "Error: parts non ben formattati")))
  (let*
      ((genitori
	(if (null parents)
	    NIL
          (remove-duplicates parents)))
       (formatted-slot (identify-method (formatta parts) nil)))
    (remhash class-name *classes-specs*)
    (add-class-spec class-name (list genitori formatted-slot)))
  class-name)



;;; Funzione ricorsiva "parents-control" ritorna false se tutti i 
;;; parents sono simboli, se tutti i parents sono classi e se
;;; non ci sono parents uguali a class-name.
(defun parents-control (class-name parents)
  (cond
   ((equal parents NIL)
    NIL)
   ((not (symbolp (first parents)))
    (error "Errore: le superclassi devono essere una lista di simboli"))
   ((not (is-class (first parents)))
    (error "Errore: superclasse non esistente"))
   ((or (equal (first parents) class-name)
        (parents-control class-name (rest parents))))))


;;; Funzione "check-parts" ritorna true se gli elementi in parts
;;; sono al piu' 2 e se la funzione "valid-parts-list-p" torna true.
(defun check-parts (parts)
  (and (valid-parts-list-p parts)
       (<= (length parts) 2)))



;;; Funzione ricorsiva "valid-parts-list-p", chiamata da "check-parts",
;;; ritorna true se ogni elemento in part e' corretto.
(defun valid-parts-list-p (parts)
  (if (null parts)
      t  ; Se non ci sono piu' parti, restituisce vero
    (and (valid-part-p (car parts))
         (valid-parts-list-p (cdr parts)))))



;;; Funzione "valid-part-p", chiamata da "valid-parts-list-p",
;;; ritorna true se l'elemento passato in input e' ben formattato.
(defun valid-part-p (part)
  (and (listp part)
       (or (equal (first part) 'fields)
           (equal (first part) 'methods))
       (if (equal (first part) 'fields)
           (my-check-type (cdr part))
         t)))


;;; Funzione ricorsiva "my-check-type", chiamata da "valid-part-p",
;;; ritorna true se i field-value e i field-type corrispondenti
;;; sono compatibili.
(defun my-check-type (fields)
  (if (null fields)
      t
    (let* ((field
            (first fields))
           (field-value
            (second field)))
      (cond ((and (third field)
                  (is-class (third field)))
             (if (equal field-value 'nil)
                 t
               (and (is-instance field-value (third field))
                    (equal (second field-value) (third field)))))
            ((and (third field)
                  (not (subtypep (type-of field-value) (third field))))
             (error "Error: field-value e field-type non compatibili")))
      (my-check-type (rest fields)))))



;;; Funzione "formatta" prende in input le parts e le
;;; ritorna sotto forma di "association list".
(defun formatta (parts)
  ;se ci sono sia fields che methods
  (cond ((and (equal (first (first parts)) 'fields)
              (equal (first (second parts)) 'methods))
         (append
          (format-fields (first parts))
          (format-methods (second parts))))
        ;se non ci sono fields
        ((equal (first (first parts)) 'methods)
         (format-methods (first parts)))
        ;se non ci sono methods
        ((and (equal (first (first parts)) 'fields)
              (= (length parts) 1))
         (format-fields (first parts)))))



;;; Funzione ricorsiva "format-fields", chiamata da "formatta",
;;; ritorna i fields ben formattati. Inoltre se un field non ha
;;; un type corrispondente lo assegna come T.
(defun format-fields (fields)
  (if (= (length fields) 1)
      nil
    (cons (list (first (cadr fields)) (second (cadr fields))
                (if (third (cadr fields)) (third (cadr fields)) T))
          (format-fields (rest fields)))))


;;; Funzione ricorsiva "format-methods", chiamata da "formatta",
;;; ritorna i methods ben formattati.
(defun format-methods (methods)
  (if (= (length methods) 1)
      nil
    (cons (list (first (cadr methods))
                (list (second (cadr methods)) (third (cadr methods))))
          (format-methods (rest methods)))))




;;; Funzione ricorsiva "identify-method" ritorna la association list
;;; con i metodi trattati dalla "process-method".
(defun identify-method (values result)
  (cond
   ((null values)
    result)
    ; condizione per verificare se e' un metodo
   ((and (listp (second (first values)))
         (listp (third (first values))))
    (identify-method
     (rest values)
     (append result (list (list
                           (first (first values))
                           (process-method
                            (first (first values))
                            (second (first values))))))))
    ; condizione fields (lasciati cosi' come sono)
   ((not (null values))
    (identify-method (rest values)
                     (append result
                             (list (first values)))))))



;;; Funzione "process-method" ritorna un eval di una lambda 
;;; per rendere il metodo "eseguibile".
(defun process-method (method-name method-spec)
  (setf (fdefinition method-name)
	(lambda (this &rest args)
	  (apply (field this method-name)
		 (append (list this) args))))
  (eval (rewrite-method-code method-name method-spec)))




;;; Funzione "rewrite-method-code", chiamata da "process-method",
;;; restituisce una nuova S-expression costruita con una nuova
;;; definizione di funzione lambda che include this come primo parametro.
(defun rewrite-method-code (method-name method-spec)
  (if (symbolp method-name)
      (append
       (list 'lambda)
       (list (append (list 'this) (first method-spec)))
       (list (append '(progn) (rest method-spec))))))



;;; Funzione "make" crea l'istanza di una classe con il
;;; formato suggerito dalla specifica. I parametri vanno
;;; passati in un formato differente rispetto alla def-class.
(defun make (class-name &rest parameters)
  ; creo l'association list dei parametri
  (let* ((formatted (format-parameters parameters)))
    (cond
     ((not (symbolp class-name))
      (error "Errore: class-name non e' un simbolo"))
     ((parameters-control formatted)
      (error "Error: bad input format")))
    (if (and (is-class class-name)
	     (instance-check class-name formatted))
	(list 'oolinst
	      class-name
	      formatted)
      (error "Error: classe o field non compatibile"))))



;;; Funzione ricorsiva "format-parameters" ritorna i parametri 
;;; sotto forma di association list
(defun format-parameters (parameters)
  (if (null parameters)
      nil
    (append (list (list (first parameters) (second parameters)))
            (format-parameters (cdr (cdr parameters))))))


;;; Funzione ricorsiva "parameters-control" ritorna true se
;;; ogni field-name passato nella make e' un simbolo
(defun parameters-control (values)
  (if (equal values NIL)
      NIL
    (or (not (symbolp (first (first values))))
        (parameters-control (rest values)))))



;;; Funzione ricorsiva "instance-check" ritorna true se i
;;; parametri della make sono corretti e se effettivamente
;;; esistono nella classe specificata
(defun instance-check (class parameters)
  (if (equal parameters NIL)
      T
    (let* ((part (first parameters))
           (part-name (first part))
           ; utilizzo la funzione "field" con un'istanza fittizia
           (class-value
            (field (list 'oolinst class NIL) part-name))
           (class-value-type
            (get-field-type (list 'oolinst class NIL) part-name))
           (instance-value
            (if (and (listp (second part))
                     (not (is-instance (second part))))
                (first (second part))
              (second part))))
      ; check parametro
      (if (and (not (functionp class-value))
               (not (if (is-instance instance-value)
                        t   ;se e' un'istanza ok altrimenti errore
                      (not (listp instance-value))))
               (not (check-type-match 
                     instance-value class-value-type part-name)))
          (error "Error: parametro make non valido")
	(and
	 (or (and (functionp class-value) (listp instance-value))
	     (and (not (functionp class-value))
		  (if (is-instance instance-value)
                      t
                    (not (listp instance-value)))
                  (check-type-match 
                   instance-value class-value-type part-name)))
	 (instance-check class (rest parameters)))))))


;;; Funzione "field" ritorna il valore di part-name di una
;;; specifica istanza di una classe.
(defun field (instance part-name)
  (cond
   ((or (not (symbolp part-name))
        (null part-name))
    (error "Error: part-name non valido"))
   ((not (is-instance instance))
    (error "Error: istanza non valida")))
  (let* ((is-in-instance
	  (recursive-field-instance (third instance) part-name)))
    ; se field e' nell'istanza
    (if is-in-instance
        (second is-in-instance)
      ; se field non e' nell'istanza
      (let* ((is-in-tree
              (recursive-field-tree (list (second instance))
                                    part-name)))
        (if is-in-tree
            (second is-in-tree)
          (error "Error: unknown field"))))))


;;; Funzione "get-field-type" ritorna il tipo di un campo di
;;; una specifica istanza di una classe. E' praticamente uguale
;;; alla funzione field solo che cambia il valore ritornato.
(defun get-field-type (instance part-name)
  (cond
   ((or (not (symbolp part-name))
        (null part-name))
    (error "Error: part-name non valido"))
   ((not (is-instance instance))
    (error "Error: istanza non valida")))
  (let* ((is-in-instance
	  (recursive-field-instance (third instance) part-name)))
    (if is-in-instance
	(third is-in-instance)
      (let* ((is-in-tree
              (recursive-field-tree (list (second instance))
                                    part-name)))
        (if is-in-tree
            (third is-in-tree)
          (error "Error: unknown field"))))))




;;; Funzione ricorsiva "recursive-field-instance" ritorna
;;; la lista di valori (field-name field-value field-type) che
;;; ha field-name = part-name.
;;; "values" e' l'association list dei field di un'istanza.
(defun recursive-field-instance (values part-name)
  (cond
   ((equal values NIL)
    NIL)
   ((equal (first (first values)) part-name)
    (first values))
   ((not (equal (first (first values)) part-name))
    (recursive-field-instance (rest values) part-name))))





;;; Funzione ricorsiva "recursive-field-tree" ritorna
;;; una lista di valori (field-name field-value field-type)
;;; sfruttando ad ogni ciclo la recursive-field-instance.
;;; Se l'occorrenza di part-name non e' a quel "livello" di classe,
;;; richiama ricorsivamente se stessa passando come "classes"
;;; le superclassi.
(defun recursive-field-tree (classes part-name)
  (let* ((is-in-level
	  (recursive-field-instance
	   (second (get-class-spec (first classes)))
	   part-name)))
    (cond
     ((equal classes  NIL)
      NIL)
     (is-in-level
      is-in-level)
     ((not is-in-level)
      (recursive-field-tree
       (append (first (get-class-spec (first classes)))
               (rest classes))
       part-name)))))



;;; Funzione "check-type-match", chiamata nella instance-check,
;;; ritorna true se un field-value, passato nella make,
;;; e' ""assegnabile"" al type specificato nella classe.
;;; Il parametro part-name c'e' solo per una questione 
;;; di debugging.
(defun check-type-match (instance-value class-value-type part-name)
  ; l'istanza deve essere della stessa classe specificata nel tipo
  (cond ((and (is-class class-value-type)
              (equal (second instance-value) class-value-type)
              (is-instance instance-value class-value-type))
         t)
        ((not (subtypep (type-of instance-value) class-value-type))
         (error "Error: value ~A for field ~A is not of type ~A ."
                instance-value part-name class-value-type))
        (t     ; in tutti gli altri casi torna true
         t)))




;;; Funzione "field*" ritorna un errore se part-name e' null,
;;; altrimenti funge da trampolino per la funzione
;;; "field*-recursive".
(defun field* (instance &rest field-name)
  (if (null field-name)
      (error "Error: field-name+ vuoto")
    (field*-recursive instance field-name)))



;;; Funzione "field*-recursive" ritorna il valore associato
;;; all'ultimo elemento di field-name nell'istanza.
;;; Controlla che i tutti i field in "field-name" esistano.
(defun field*-recursive (instance field-name)
  (cond
   ((not (symbolp (first field-name)))
    (error "Error: part-names devono essere simboli"))
   ((null (rest field-name))
    (field instance (first field-name)))
   ; controllo che i field esistano in instance
   ((and (rest field-name)
         (field instance (first field-name)))
    (field*-recursive instance (rest field-name)))))





;;; La funzione "is-class" ritorna true se class-name
;;; e' un simbolo ed esiste nella tabella hash
(defun is-class (class-name)
  (if (and (symbolp class-name)
           (gethash class-name *classes-specs*))
      t
    nil))



;;; La funzione "is-instance" ritorna true se il value in
;;; input e' un'istanza di una classe specifica oppure se
;;; e' un'istanza di qualunque classe se class-name non
;;; e' specificato
(defun is-instance (value &optional (class-name t))
  (cond
   ((not (listp value))
    nil)
   ((not (equal (first value) 'oolinst))
    nil)
   ((eq class-name t)
    t) ; se class non e' specificato, qualunque instance e' valida
   ((symbolp class-name)
    (if (or (equal (second value) class-name)
            (is-subclass (second value)  class-name))
        t
      nil))))



;;; Funzione "is-subclass" ritorna true se subclass
;;; e' una sottoclasse di superclass.
(defun is-subclass (subclass superclass)
  (cond
   ((not (is-class subclass))
    (error "Errore: subclass non e' una classe valida"))
   ((not (is-class superclass))
    (error "Errore: superclass non e' una classe valida"))
   (t
    (is-subclass-helper subclass superclass))))



;;; Funzione ausiliaria "is-subclass-helper" utilizzata 
;;; da "is-subclass".
(defun is-subclass-helper (subclass superclass)
  (let ((parents (first (get-class-spec subclass))))
    (or (member superclass parents)
        (some 
         (lambda (parent) (is-subclass-helper parent superclass))
         parents))))


;;;; end of file -- ool.lisp