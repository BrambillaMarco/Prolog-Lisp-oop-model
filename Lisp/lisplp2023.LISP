;;;; Brambilla Marco 856428
;;;; Colciago Federico 858643 
;;;; Condello Paolo 829800
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; -*- Mode: Lisp -*-

;;; Definizione e manipolazione Hash-Table
(defparameter *classes-specs* (make-hash-table))
(defun add-class-spec (name class-spec)
  (setf (gethash name *classes-specs*) class-spec))
(defun get-class-spec (name)
  (gethash name *classes-specs*))



;;; Funzione "def-class" ritorna class-name se crea
;;; correttamente la classe memorizzandola nell'hash-table
(defun def-class (class-name parents &rest parts)
  (cond ; inizio vari controlli sui parametri in input
    ((not (symbolp class-name))
     (error "Error: il nome della classe non e' un simbolo"))
    ((not (listp parents))
     (error "Error: le superclassi non sono in una lista"))
    ((parents-control class-name parents)
     (error "Error: classe e parents con stesso nome"))
    ((not (check-parts parts))
     (error "Error: parts non ben formattati")))
  (let*
      ((genitori ; variabile locale
	(if (null parents)
	    NIL
	    (remove-duplicates parents)))
       ;seconda variabile locale "formatted-slot"
       (formatted-slot (identify-method (formatta parts) nil)))
    ; body della let: lavoro in memoria 
    (remhash class-name *classes-specs*)
    (add-class-spec class-name (list genitori formatted-slot)))
  class-name)



;;; Funzione ricorsiva "parents-control" ritorna false se tutti i parents
;;; sono simboli, se tutti i parents sono classi e se
;;; non ci sono parents uguali a class-name
(defun parents-control (class-name parents)
  (cond
    ((equal parents NIL)
     NIL)
    ((not (symbolp (first parents)))
     (error "Errore: i parents devono essere una lista di simboli"))
    ((not (get-class-spec (first parents)))
     (error "Errore: superclasse non esistente"))
    ((or (equal (first parents) class-name)
	 (parents-control class-name (rest parents))))))


; ('(fields (name "Eva Lu Ator") (university "Berkeley" string)) '(methods (talk (&optional (out *standard-output*)) (format out "My name is ~A~%My age is ~D~%" (field this 'name) (field this 'age)))))


;;; Funzione che ritorna true se gli elementi in parts sono al più 2
;;; e se la funzione "valid-parts-list-p" torna true  
(defun check-parts (parts)
  ; Controlla se l'elenco delle parti è valido
  (and (valid-parts-list-p parts) 
       (<= (length parts) 2))) 



; ('(methods (talk (&optional (out *standard-output*)) (format out "My name is ~A~%My age is ~D~%" (field this 'name) (field this 'age)))))


;;; Funzione ricorsiva valid-parts-list-p, chiamata da check-parts,
;;; ritorna true se ogni elemento in part è corretto
(defun valid-parts-list-p (parts)
  (if (null parts)
      t  ; Se non ci sono più parti, restituisce vero
      (and (valid-part-p (car parts))           
           (valid-parts-list-p (cdr parts)))))  

; part= (FIELDS (NAME "Eva Lu Ator") (UNIVERSITY "Berkeley" STRING))
;;; Funzione valid-part-p d'appoggio chiamata da "valid-parts-list-p
;;; ritorna true se l'elemento passato in input è ben formattato
(defun valid-part-p (part)
  (and (listp part)
       (or (equal (first part) 'fields)
           (equal (first part) 'methods))
       (if (equal (first part) 'fields)
           (my-check-type (cdr part))
           t)))


;;; fields= ((UNIVERSITY "Berkeley" STRING))

;field = (UNIVERSITY "Berkeley" STRING)
;field-value = "berkeley"

(defun my-check-type (fields)
  ; caso base:
  (if (null fields)
      t
    (let* ((field
            (first fields))
           (field-value
            (second field)))
    ;se esiste il terzo elemento di un field
      (if (and (third field) 
               (not (subtypep (type-of field-value) (third field))))
          (error "Error: field-value e field-type non compatibili!"))
      (my-check-type (rest fields)))))
        
               
    









;;; Funzione "formatta" prende in input le parts e le
;;; ritorna sotto forma di "association list"
(defun formatta (input)
  ;se ci sono sia fields che methods
  (cond ((and (equal (first (first input)) 'fields) 
           (equal (first (second input)) 'methods))
    (append (format-fields (first input)) (format-methods (second input))))
        ;se non ci sono fields
        ((equal (first (first input)) 'methods)
         (format-methods (first input)))
        ;se non ci sono methods
        ((and (equal (first (first input)) 'fields) 
           (= (length input) 1)) 
         (format-fields (first input))))
  
  )



;;; Funzione ricorsiva "format-fields" chiamata da "formatta"
;;; ritorna i fields ben formattati 
(defun format-fields (fields)
  (if (= (length fields) 1)
      nil
      (cons (list (first (cadr fields)) (second (cadr fields)) 
                  (if (third (cadr fields)) (third (cadr fields)) T))
            (format-fields (rest fields)))))


;;; Funzione ricorsiva "format-methods" chiamata da "formatta"
;;; ritorna i methods ben formattati
(defun format-methods (methods)
  (if (= (length methods) 1)
      nil
      (cons (list (first (cadr methods)) 
                  (list (second (cadr methods)) (third (cadr methods))))
            (format-methods (rest methods)))))







;;; Funzione ricorsiva "identify-method" ritorna la association list
;;; con i metodi trattati dalla "process-method"
(defun identify-method (values result)
  (cond
   ; caso base
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
    


;;; Funzione "process-method" per la gestione dei metodi, 
;;; ritorna un eval di una lambda
(defun process-method (method-name method-spec)
  (setf (fdefinition method-name)
	(lambda (this &rest args)
	  (apply (field this method-name)
		 (append (list this) args))))
  (eval (rewrite-method-code method-name method-spec)))





;;; Funzione "rewrite-method-code", chiamata da "process-method"
;;; restituisce una nuova S-expression costruita con una nuova 
;;; definizione di funzione lambda che include this come primo parametro
(defun rewrite-method-code (method-name method-spec)
  (if (symbolp method-name)
      (append
       (list 'lambda)
       (list (append (list 'this) (first method-spec)))
       (list (append '(progn) (rest method-spec))))))




;;;;;;ESEMPIO (make ’student ’name "Eduardo De Filippo" ’age 108)



;formatted= ((name "eduardo") (age 108))



;;; class-name = student   ;;; parameters = ('name "Eduardo" 'age 108)
;;; Primitiva Make
(defun make (class-name &rest parameters)
  (let* ((formatted (format-parameters parameters)))
    ;controlli sull'integrita' dell'input
    (cond
      ((not (symbolp class-name))
       (error "Errore: class-name non e' un simbolo"))
      ((parameters-control formatted)
       (error "Error: bad input format")))
    ;se i controlli vengono passati:
    (if (and (get-class-spec class-name)
	     (instance-check class-name formatted)) ;;; STATIC LINK
	(list 'oolinst
	      class-name
	      (field-unifier formatted nil))
	(error "Errore: classe o parametro incompatibile"))))



;;; Funzione formattazione per lista associativa
(defun format-parameters (slot-value)
  (if (null slot-value)
      nil
      (append (list (list (first slot-value) (second slot-value)))
	      (format-parameters (cdr( cdr slot-value))))))


;;; Controllo che field-name sia simbolo in ogni elemento
;;; dell'association list della make
(defun parameters-control (values)
  (if (equal values NIL)
      NIL
      (or (not(symbolp (first (first values))))
	  (parameters-control (rest values)))))


;;; class = student ;;;; parameters = ((name "eduardo") (age 108))

; class-value = (field ('oolinst student NIL) name) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;; Controllo valori e metodi di Make 
(defun instance-check (class parameters)
  (if (equal parameters NIL)
      T
      (let* ((part (first parameters))
             (part-name (first part))
             (class-value 
              (field (list 'oolinst class NIL) part-name))   
	     (instance-value (if (listp (second part)) 
				 (first (second part)) 
				 (second part))))
      (if (and (not (functionp class-value))
		  (not (listp instance-value))
                  (not (check-type-match instance-value class-value)))
          (error "Error: value ~A for field ~A is not of type ~A ." 
                 instance-value part-name (type-of class-value))
	(and
	 (or (and (functionp class-value) (listp instance-value))
	     (and (not (functionp class-value))
		  (not (listp instance-value))
                  (check-type-match instance-value class-value)))
	 (instance-check class (rest parameters)))))))

;;; instance = ('oolinst student NIL) ;;;;; slot-name= name

;;; is-in-istance = NIL 

;;; is-in-tree = (recursive-field-tree (student) name) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Primitiva field
(defun field (instance slot-name)
  (cond
    ((or (not (symbolp slot-name))
	 (null slot-name))
     (error "Errore: slot-name non valido"))
    ((not (equal 'oolinst (first instance)))
     (error "Errore: istanza non valida")))
  (let* ((is-in-instance
	  (recursive-field-instance (third instance) slot-name)))
    (if is-in-instance 
	(second is-in-instance)
	(let* ((is-in-tree  
		(recursive-field-tree (list (second instance)) 
				     slot-name)))
	  (if is-in-tree   ;;; controllo per vedere se nella make dopo 'name ho messo effettivamente il suo valore
	      (second is-in-tree)                                   
	      (error "Errore: valore non valido"))))))




; values = ((NAME "Eva Lu Ator" T) (UNIVERSITY "Berkeley" STRING) (TALK #<anonymous interpreted function 40F001641C>))   ;;;; slot-name = name 

;;; Ritorna una coppia di valori di istanza
(defun recursive-field-instance (values slot-name)
  (cond
    ((equal values NIL)
     NIL)
    ((equal (first (first values)) slot-name) 
     (first values))
    ((not (equal (first (first values)) slot-name))                  
     (recursive-field-instance (rest values) slot-name))))


        



;;; classes=(student) ;;;;; slot-name = name


;is-in-level = (recursive-field-instance ((NAME "Eva Lu Ator" T) (UNIVERSITY "Berkeley" STRING) (TALK #<anonymous interpreted function 40F001641C>))    name )      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




;;; Ritorna una coppia di valori di una classe in gerarchia
(defun recursive-field-tree (classes slot-name)
  (let* ((is-in-level
	  (recursive-field-instance
	   (second (get-class-spec (first classes))) 
	   slot-name)))
    (cond
      ((equal classes  NIL)
       NIL)
      (is-in-level
       is-in-level)
      ((not is-in-level)
       (recursive-field-tree
	(append (first (get-class-spec (first classes)))
		(rest classes))
	slot-name)))))

(defun check-type-match (instance-value class-value)
  (subtypep (type-of instance-value) class-value)
  )
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;ATTENZIONE! AGGIUNGERE CHE SE IL FIELD-TYPE è "real" devo solo controllare che 
;;;;;;;;;;;;;; CAMBIARE SLOT-NAME CON PART-NAME

;;; Primitiva field*, funge da trampolino
(defun field* (instance &rest slot-name)
  (if (null slot-name)
      (error "Errore: slot-name+ vuoto"))
  (field*-recursive instance slot-name))



;;; Effettiva getvx applicata ricorsivamente
(defun field*-recursive (instance slot-name)
  (cond
    ((not (symbolp (first slot-name)))
     (error "Errore: slot-names devono essere simboli"))
    ((null (rest slot-name))
     (field instance (first slot-name)))
    ((rest slot-name)
     (field*-recursive (field instance (first slot-name))
		      (rest slot-name)))))
















;;; Identifico i metodi e li tratto
(defun field-unifier (values result)
  (cond
    ((null values)
     result)
    ((not (null values))
     (field-unifier (rest values)
		      (append result
			      (list (first values)))))))















;;; La funzione "is-class" restituisce vero se il class-name
;;; è un simbolo ed esiste nella tabella hash,
;;; altrimenti restituisce NIL.
(defun is-class (class-name)
  (and (symbolp class-name) 
       (gethash class-name *classes-specs*))) ; 



;;; La funzione "is-instance" ritorna true se il value in 
;;; input è un'istanza di una classe specifica oppure se
;;; è un'istanza di qualunque classe se class-name non è specificato  
(defun is-instance (value &optional (class-name t))
  
  (cond
    ((not (listp value)) 
     nil) ; value non è un'istanza se non è una lista
    ((not (equal (first value) 'oolinst)) 
     nil) ; value non è un'istanza se il 1elemento non è 'oolinst
    ((eq class-name t) 
     t) ; se class-name non è specificato, qualunque istance è valida      
    ((symbolp class-name)
     (if (equal (second value) class-name) ; Check diretto istanza-classe
         t
       nil))))


;;;; end of file -- ool.lisp