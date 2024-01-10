;;; Definizione e manipolazione Hash-Table
(defparameter *classes-specs* (make-hash-table))
(defun add-class-spec (name class-spec)
  (setf (gethash name *classes-specs*) class-spec))
(defun get-class-spec (name)
  (gethash name *classes-specs*))

;;; Primitiva definizione classe
(defun def-class (class-name parents &rest parts)
  (cond
    ((not (symbolp class-name))
     (error "Error: nome classe non e' un simbolo"))
    ((not (listp parents))
     (error "Error: parent non e' una lista"))
    ((parents-control class-name parents)
     (error "Error: classe e parents con stesso nome"))
    ((check-parts parts)
     (error "Error: bad values formatting")))
  (let*
      ((genitori
	(if (null parents)
	    NIL
	    (remove-duplicates parents)))
       (formatted-slot (identify-method (formatta parts) nil)))
    (remhash class-name *classes-specs*)
    (add-class-spec class-name (list genitori formatted-slot)))
  class-name)



;;; Funzione parents-control controlla che tutti i parents
;;; siano simboli, che tutte i parents siano classi e che
;;; non ci siano parents con lo stesso class-name
(defun parents-control (class-name parents)
  (cond
    ((equal parents NIL)
     NIL)
    ((not (symbolp (first parents)))
     (error "Errore: i parents devono essere lista di simboli"))
    ((not (get-class-spec (first parents)))
     (error "Errore: classe genitore non esistente"))
    ((or (equal (first parents) class-name)
	 (parents-control class-name (rest parents))))))


;;; Funzione che controlla se ogni parte dell'input è una lista
;;; che inizia con 'fields o 'methods."
(defun check-parts (parts)
  ; Controlla se l'elenco delle parti è valido
  (and (valid-parts-list-p parts) 
       (<= (length parts) 2))) ; controllo massimo due parti   



;;; Verifica ricorsivamente se ogni parte nell'elenco è una 
;;; lista valida che inizia con 'fields o 'methods."
(defun valid-parts-list-p (parts)
  (if (null parts)
      t  ; Se non ci sono più parti, restituisce vero
      (and (valid-part-p (car parts))           
           (valid-parts-list-p (cdr parts)))))  


;;; Verifica se la parte è una lista che inizia 
;;; con 'fields o 'methods."
(defun valid-part-p (part)
  (and (listp part)
       ; Controlla se il primo elemento è 'fields o 'methods
       (or (equal (first part) 'fields)
           (equal (first part) 'methods))))  





;;; assumo che i methods vengano sempre dopo i fields
(defun formatta (&rest input)
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
         (format-fields (first input)))
    ))


(defun format-fields (fields)
  (if (= (length fields) 1)
      nil
      (cons (list (first (cadr fields)) (second (cadr fields)) (if (third (cadr fields)) (third (cadr fields)) T))
            (format-fields (rest fields)))))

(defun format-methods (methods)
  (if (= (length methods) 1)
      nil
      (cons (list (first (cadr methods)) (list (second (cadr methods)) (third (cadr methods))))
            (format-methods (rest methods)))))




;;; Identifico i metodi e li tratto
(defun identify-method (values result)
  (cond
    ((null values)
     result)
    ((and (listp (second (first values)))
          (listp (third (first values))))
     (identify-method
      (rest values)
      (append result (list (list
                            (first (first values))
                            (process-method
                             (first (first values))
                             (second (first values))))))))
    ((not (null values))
     (identify-method (rest values)
		      (append result
			      (list (first values)))))))
    







;;; Funzione principale gestione metodi, ritorna un eval di una lambda
(defun process-method (method-name method-spec)
  (setf (fdefinition method-name)
	(lambda (this &rest args)
	  (apply (getv this method-name)
		 (append (list this) args))))
  (eval (rewrite-method-code method-name method-spec)))





;;; Riscrivo S-expression cosi da poter usare this
(defun rewrite-method-code (method-name method-spec)
  (if (symbolp method-name)
      (append
       (list 'lambda)
       (list(append (list 'this) (first method-spec)))
       (list (append '(progn) (rest method-spec))))))






;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;forse non servono questi extract;;; da rivedere


;;; Funzione che estrae i fields dalle parts
(defun extract-fields (input)
  (let ((fields-part (assoc 'fields input)))
    (when fields-part
      (extract-pairs (cdr fields-part)))))

;;; Funzione che estrae i methods dalle parts
(defun extract-methods (input)
  (let ((methods-part (assoc 'methods input)))
    (when methods-part
      (extract-pairs (car (cdr methods-part))))))

;;; Funzione di appoggio a extract-fields/methods
;;; che estra ogni coppia
(defun extract-pairs (lst)
  (cond ((null lst) nil)
        ((listp (car lst)) (cons (car lst) (extract-pairs (cdr lst))))
        (t (extract-pairs (cdr lst)))))

