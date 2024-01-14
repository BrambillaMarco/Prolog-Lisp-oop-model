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



;;; Funzione ricorsiva "parents-control" ritorna false se tutti i parents
;;; sono simboli, se tutti i parents sono classi e se
;;; non ci sono parents uguali a class-name.
(defun parents-control (class-name parents)
  (cond
   ((equal parents NIL)
    NIL)
   ((not (symbolp (first parents)))
    (error "Errore: le superclassi devono essere una lista di simboli"))
   ((not (get-class-spec (first parents)))
    (error "Errore: superclasse non esistente"))
   ((or (equal (first parents) class-name)
        (parents-control class-name (rest parents))))))


;;; Funzione "check-parts" ritorna true se gli elementi in parts
;;; sono al più 2 e se la funzione "valid-parts-list-p" torna true.
(defun check-parts (parts)
  (and (valid-parts-list-p parts)
       (<= (length parts) 2)))



;;; Funzione ricorsiva "valid-parts-list-p", chiamata da "check-parts",
;;; ritorna true se ogni elemento in part è corretto.
(defun valid-parts-list-p (parts)
  (if (null parts)
      t  ; Se non ci sono più parti, restituisce vero
    (and (valid-part-p (car parts))
         (valid-parts-list-p (cdr parts)))))



;;; Funzione "valid-part-p", chiamata da "valid-parts-list-p",
;;; ritorna true se l'elemento passato in input è ben formattato.
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
      (if (and (third field)
               (not (subtypep (type-of field-value) (third field))))
          (error "Error: field-value e field-type non compatibili"))
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
    ; condizione per verificare se è un metodo
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
    (if (and (get-class-spec class-name)
	     (instance-check class-name formatted))
	(list 'oolinst
	      class-name
	      (field-unifier formatted nil))
      (error "Error: classe o field non compatibile"))))



;;; Funzione ricorsiva "format-parameters" ritorna i parametri 
;;; sotto forma di association list
(defun format-parameters (parameters)
  (if (null parameters)
      nil
    (append (list (list (first parameters) (second parameters)))
            (format-parameters (cdr (cdr parameters))))))


;;; Funzione ricorsiva "parameters-control" ritorna true se
;;; ogni field-name passato nella make è un simbolo
(defun parameters-control (values)
  (if (equal values NIL)
      NIL
    (or (not (symbolp (first (first values))))
        (parameters-control (rest values)))))



;;; Controllo valori e metodi di Make 
(defun instance-check (class parameters)
  (if (equal parameters NIL)
      T
    (let* ((part (first parameters))
           (part-name (first part))
           (class-value
            (field (list 'oolinst class NIL) part-name))
           (class-value-type
            (get-field-type (list 'oolinst class NIL) part-name))
           (instance-value
            (if (listp (second part))
                (first (second part))
              (second part))))
      (if (and (not (functionp class-value))
               (not (listp instance-value))
               (not (check-type-match instance-value class-value-type)))
          (error "Error: value ~A for field ~A is not of type ~A ."
                 instance-value part-name class-value-type)
	(and
	 (or (and (functionp class-value) (listp instance-value))
	     (and (not (functionp class-value))
		  (not (listp instance-value))
                  (check-type-match instance-value class-value-type)))
	 (instance-check class (rest parameters)))))))




;;; Primitiva field
(defun field (instance part-name)
  (cond
   ((or (not (symbolp part-name))
        (null part-name))
    (error "Error: part-name non valido"))
   ((not (equal 'oolinst (first instance)))
    (error "Error: istanza non valida")))
  (let* ((is-in-instance
	  (recursive-field-instance (third instance) part-name)))
    (if is-in-instance
	(second is-in-instance)
      (let* ((is-in-tree
              (recursive-field-tree (list (second instance))
                                    part-name)))
        (if is-in-tree
            (second is-in-tree)
          (error "Errore: valore non valido"))))))


;;; Funzione get-field-type
(defun get-field-type (instance part-name)
  (cond
   ((or (not (symbolp part-name))
        (null part-name))
    (error "Error: part-name non valido"))
   ((not (equal 'oolinst (first instance)))
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
          (error "Errore: valore non valido"))))))




;;; Ritorna una coppia di valori di istanza
(defun recursive-field-instance (values part-name)
  (cond
   ((equal values NIL)
    NIL)
   ((equal (first (first values)) part-name) 
    (first values))
   ((not (equal (first (first values)) part-name))
    (recursive-field-instance (rest values) part-name))))





;;; Ritorna una coppia di valori di una classe in gerarchia
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



(defun check-type-match (instance-value class-value-type)
  (subtypep (type-of instance-value) class-value-type))



;;; Primitiva field*, funge da trampolino
(defun field* (instance &rest part-name)
  (if (null part-name)
      (error "Errore: part-name+ vuoto"))
  (field*-recursive instance part-name))



;;; Effettiva getvx applicata ricorsivamente
(defun field*-recursive (instance part-name)
  (cond
   ((not (symbolp (first part-name)))
    (error "Errore: part-names devono essere simboli"))
   ((null (rest part-name))
    (field instance (first part-name)))
   ((rest part-name)
    (field*-recursive (field instance (first part-name))
		      (rest part-name)))))




;;; Identifico i metodi e li tratto
(defun field-unifier (values result)
  (cond
   ((null values)
    result)
   ((not (null values))
    (field-unifier (rest values)
                   (append result
                           (list (first values)))))))




;;; La funzione "is-class" ritorna true se il class-name
;;; è un simbolo ed esiste nella tabella hash
(defun is-class (class-name)
  (and (symbolp class-name)
       (gethash class-name *classes-specs*)))



;;; La funzione "is-instance" ritorna true se il value in
;;; input è un'istanza di una classe specifica oppure se
;;; è un'istanza di qualunque classe se class-name non è specificato
(defun is-instance (value &optional (class-name t))
  (cond
   ((not (listp value))
    nil)
   ((not (equal (first value) 'oolinst))
    nil)
   ((eq class-name t)
    t) ; se class-name non è specificato, qualunque istance è valida
   ((symbolp class-name)
    (if (equal (second value) class-name)
        t
      nil))))


;;;; end of file -- ool.lisp