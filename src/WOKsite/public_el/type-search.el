;;; type-search.el --- define a type of a matter at point in source file

;;;Author       :  Edward AGAPOV  <eap@opencascade.com>
;;;History      :  Thu Oct 11 2001     Edward AGAPOV   Creation

(require 'method-search)
(require 'class-info)

(defun eap-current-type ()
  "Return type found at point in c++ or cdl file,
or type of c++ object (local variable or field) at point."
  (or (eap-class-in-cdl)
      (if (equal 'c++-mode (eap-file-mode))
	  (eap-type-of-object (eap-current-word)))
      (eap-current-word)
      )
  )
(defvar eap-type-is-handle nil
  "stringp means 'not defined'. Is set by type search."
  )
(defvar eap-type-scope-description nil
  "Is set by type search"
  )
(defvar eap-type-modifier-string nil
  "Is set by type search"
  )
(defun eap-type-modifier (&optional raw)
  "Return modificator string for type found by 'eap-current-type
without spaces and other stuff. Result may be nil.
Modificators are *,&,[], etc"
  (if eap-type-modifier-string
      (eap-simplify-string eap-type-modifier-string '("[ \t\n]+")))
  )
(defun eap-type-handle-p (type-pos)
  "Check if last found object type is handle"
  (if (not (stringp eap-type-is-handle))
      eap-type-is-handle
    (if (null (nth 1 type-pos))  ;; type was not found or file-pos is null
	nil
      ;; type surely is a field found in cdl
      (let* ((type (car type-pos))
	     (file (car (nth 1 type-pos)))
	     (hxx-file (eap-find-file-with-ext file "hxx"))
	     (pnt (cdr (nth 1 type-pos)))
	     (buf (if hxx-file (eap-find-file-noselect hxx-file)))
	     )
	(if (or (not (string-match "[.]cdl" file))
		(null buf))
	    ;; strange but nevertheless
	    (prog1 (eap-find-file-in (concat "Handle_" type ".hxx") "inc")
	      (if buf (kill-buffer buf)))
	  ;; find field in hxx
	  (set-buffer buf)
	  (goto-char (point-max))
	  (prog1 (re-search-backward (concat  "^ *Handle *[_(]" type "[) ]" ) nil t)
	    (kill-buffer buf))
	  )))
    ))
(defun eap-get-type-descriptors ()
  "Return list of 'eap-type-is-handle, 'eap-type-scope-description and
'eap-type-modifier-string"
  (list eap-type-is-handle eap-type-scope-description eap-type-modifier-string)
  )
(defun eap-set-type-descriptors (descr-list)
  "set 'eap-type-is-handle, 'eap-type-scope-description and
'eap-type-modifier-string from list returned by 'eap-get-type-descriptors"
  (setq eap-type-is-handle         (nth 0 descr-list)
	eap-type-scope-description (nth 1 descr-list)
	eap-type-modifier-string   (nth 2 descr-list))
  )
(defun eap-type-of-object (obj &optional pos)
  "If POS returns list \(\<type\> \(\<file\> . \<pos-in-file\>\)\)"
  (save-excursion
    (setq eap-type-is-handle "not defined")
    (setq eap-type-scope-description nil)
    (let* ((not-gen-param t)
	   (type (or (if (string= "this" obj)
			 (let ((cls (eap-class-name)))
			   (if pos (setq cls (list cls (cons buffer-file-name (point)))))
			   (setq eap-type-scope-description "this class object pointer")
			   cls))
		     (eap-type-of-object-in-buffer obj pos)
		     (eap-type-of-field obj pos)
		     (setq not-gen-param nil)
		     (eap-find-generic-parameter-type obj pos)))
	   (type-name (if pos (car type) type))
	   )
      (if type
	  (if (and (string-match "[.][gl]xx" buffer-file-name)
		   (not (string-match "_" type-name)))
	      ;; look for real type name of generic parameter
	      (let ((param-type-name (eap-find-generic-parameter-type type-name)))
		(and param-type-name
		     (setq type-name param-type-name)
		     (if pos
			 (setcar type type-name)
		       (setq type type-name))
		     (setq not-gen-param nil)
		     )
		)
	    ;; look for real type by typedef (pointer case)
	    (let* (file buf)
	      (and (setq file (eap-find-file-with-ext type-name "hxx" 'any))
		   (setq buf (set-buffer (eap-find-file-noselect file)))
		   (re-search-forward
		    (format "^[^/]*typedef \\([^ ]+\\)[*] %s;" type-name) nil t)
		   (setq type-name (match-string 1))
		   (if pos
		       (setcar type type-name)
		     (setq type type-name))
		   )
	      (if buf (kill-buffer buf))
	      )))
      (if (string-match "^Handle_" (or type-name ""))
	  (let ((name (substring type-name (match-end 0))))
	    (setq eap-type-is-handle t)
	    (if pos
		(setcar type name)
	      (setq type name))
	    ))
      (or (null type)
	  not-gen-param
	  (setq eap-type-scope-description
		(if eap-type-scope-description
		    (concat eap-type-scope-description ", generic parameter")
		  "generic parameter")))
      type))
  )

;; regexp for obj standing after other obj of the same type
(defun eap-obj-sch-re2 (&optional obj)
  (concat ",\\([\t\n *]*\\)\\(" (or obj "[_a-zA-Z0-9]+") "\\)[\t\n ]*\\([[,=(;]\\)" ))
;; regexp for obj standing next to it's type
(defun eap-obj-sch-re1 (&optional obj)
  (concat "[ \t\n{},;(]"
	  "\\(\\(static\\|const\\|extern\\|Standard_EXPORT\\|Standard_IMPORT\\)[\t\n ]+\\)?"
	  "\\(Handle[\t\n ]*[(_] *\\)?"
	  "\\([_a-zA-Z0-9]+\\)" ;; type name
	  "\\([][*&) \t\n]+\\)" ;; type modifs (*& etc)
	  "\\(" (or obj "[_a-zA-Z0-9]+") "\\)[\t\n ]*\\([[,=();]\\)" ))
(defun eap-obj-sch-obj (&optional re2-p) (eap-match-string (if re2-p 2 6)))
(defun eap-obj-sch-obj-pnt (&optional re2-p) (match-end (if re2-p 2 6)))
(defun eap-obj-sch-handle-p ()    (eap-match-string 3)) ;; for search-forward re1 only
(defun eap-obj-sch-type ()        (eap-match-string 4)) ;; for re1 only
(defun eap-obj-sch-type-modifs (&optional re2-p)
  (concat
   (eap-match-string (if re2-p 1 5))
   (eap-simplify-string (eap-match-string (if re2-p 3 7)) '("[^[]"))
   ))

(defun eap-statement-beg (&optional decl-beg)
  "Return position of current statement beginning.
Current point should not be in comment, so it is supposed that 'eap-quit-comment or
'eap-in-comment has been called before and it returned nil.
DECL-BEG means that beginning of currunt variable declaration is needed, which
may happen to be a function argument"
  (save-excursion
    ;; end of prev statment
    (if (not decl-beg)
	(skip-chars-backward "^{}#;")
      (and (looking-at "(")
	   (if (string-match "^\\(Handle\\|if\\)$" (current-word))
	       (forward-char -3)
	     ;; arg list first paren?
	     (let ((paren-pnt (point)))
	       (skip-chars-backward " \t\n")
	       (forward-char -1)
	       (and (looking-at "[a-zA-Z0-9]")
		    (skip-chars-backward "_a-zA-Z0-9")
		    (skip-chars-backward " \t\n")
		    (or (bobp) (forward-char -1) t)
		    (looking-at "[&*:)a-zA-Z0-9]")
		    (goto-char paren-pnt)) ;; keep point if look like arg list first paren
	       )))
      (or (looking-at "[{}#,(;]")
	  (skip-chars-backward "^{}#,(;")))
    ;; preprocessor instruction?
    (if (= ?# (char-after (1- (point))))
	(end-of-line))
    ;; skip comment and white spaces before declaration
    (if (< (point) (cdr eap-next-comment-ends)) ;save time on 'eap-quit-comment
	(eap-quit-comment nil 'skip-spaces)
      (skip-chars-forward " \t\n"))
    (if (looking-at "[a-zA-Z0-9]")
	(point) (1+ (point)))
    ))
(defun eap-obj-sch (obj &optional re2-p boundary)
  "Return alist \(type object-point declaration-beginning)"
  (let* ((re (if re2-p (eap-obj-sch-re2 obj) (eap-obj-sch-re1 obj)))
	 (forbiden-type-re "^\\(return\\|delete\\|else\\|const\\|Handle\\|void\\|[0-9]+\\)$")
	 (case-fold-search nil) ;; Case is significant for c++ obj names
	 type obj-pnt stmt-beg handle-p modif
	 )
    (save-excursion
      (while (and (null type)
		  (re-search-backward re boundary t))
	(or (eap-quit-comment 'backward)
	    (setq obj-pnt (eap-obj-sch-obj-pnt re2-p)
		  eap-type-modifier-string (eap-obj-sch-type-modifs re2-p)
		  type nil)
	    (and ;;(not re2-p) check long modifs
		 (setq modif (eap-type-modifier))
		 (> (length modif) 1)
		 (not (string-match "^)&\\|[[]]$" modif))) ;; <- allowed long modifs
	    (save-excursion
	      ;; statement beginning
	      (setq stmt-beg (eap-statement-beg (not re2-p)))
	      (goto-char (1- stmt-beg))
	      ;; look at declaration?
	      (and (looking-at (if re2-p (eap-obj-sch-re1) re))
		   (setq handle-p (eap-obj-sch-handle-p)
			 type (eap-obj-sch-type))
		   ;;   wrong type name?
		   (or (string-match forbiden-type-re type)
		       (if re2-p
			   ;; arg in function call?
			   (let ((before-str (buffer-substring stmt-beg obj-pnt)))
			     (> (eap-count-symbols-in-string "(" before-str)
				(eap-count-symbols-in-string ")" before-str))
			     )
			 ;; multiplication or pointer declaration?
			 (and (string= "*" modif)
			      ;; only arg decl is doubtful
			      (or (looking-at ",")
				  (save-excursion
				    (skip-chars-backward "^,{};")
				    (if (< 1 (point)) ;; not skipped up to buffer beginning
					(= ?, (char-after (1- (point)))))))
			      ;; function call or declaration?
			      (save-excursion
				(skip-chars-forward "^{;")
				(looking-at ";"))
			      )
			 )
		       )
		   (setq type nil) ;; not declaration encountered
		   )
	      ))))
    (if (null type)
	nil
      (setq eap-type-is-handle (stringp handle-p))
      (list type obj-pnt stmt-beg)))
  )
(defun eap-static-obj-p (obj-point)
  "Check that OBJ-POINT is not inside method definition"
  (save-excursion
    (goto-char obj-point)
    (if (not (re-search-forward "^[^/\n]*{" nil t))
	'static
      (let ((eap-method-search-boundaries (cons (point) (point))))
	(goto-char obj-point)
	(and (eap-method-fullstring nil nil 'save 'c++-mode)
	     (not (re-search-backward "^[^/\n]*}" obj-point t))
	     )
	)))
  )
(defun eap-type-of-object-in-buffer (obj &optional pos boundary)
  "Find type of OBJ in current c++ buffer.
If POS, returns list \(\<type\> \(\<file\> . \<pos-in-file\>\)\).
BOUNDARY is a limit for backward search"
  (or (stringp obj)
      (error "OBJECT IS NOT A STRING"))
  (let ((bnd boundary)
	(cur-pnt (point))
	type-pos type-pos-1 type-pos-2 meth-pos descr-1 descr-2
	eap-method-search-boundaries
	)
    (or boundary
	(re-search-forward "[{});]" nil t)  ;; may be we are on declaration
	)
    ;; search for re1
    (and (setq type-pos-1 (eap-obj-sch obj (not 're2) bnd))
	 (setq type-pos type-pos-1)
	 (null bnd)
	 ;; must be in current method or static
	 (setq eap-method-search-boundaries (cons (nth 2 type-pos)(nth 2 type-pos)))
	 (setq meth-pos (eap-method-fullstring 'backwards 'pos 'save-pos))
	 ;; found in other method or is static
	 (setq bnd (nthcdr 2 meth-pos)) ;; for re2 search
	 (setq type-pos nil)
	 )
    (setq eap-type-scope-description "local variable")
    (setq descr-1 (eap-get-type-descriptors))
    (if type-pos
	;; are we inside method args?
	(save-excursion
	  (setq eap-method-search-boundaries (cons (nth 1 type-pos) (nth 1 type-pos) ))
	  (goto-char (nth 2 type-pos))
	  (skip-chars-backward "^{};")
	  (setq meth-pos (eap-method-fullstring (not 'backwards) 'pos 'save-pos))
	  (and meth-pos
	       (< (nth 1 type-pos) (nthcdr 2 meth-pos))
	       (setq eap-type-scope-description "function argument"))
	  ))
    ;; search for re2
    (and (null type-pos)
	 (setq type-pos-2 (eap-obj-sch obj 're2 bnd))
	 (setq type-pos type-pos-2)
	 (null bnd)
	 ;; must be in current method or static
	 (setq eap-method-search-boundaries (cons (nth 2 type-pos)(nth 2 type-pos)))
	 (setq meth-pos (eap-method-fullstring 'backwards 'pos 'save-pos))
	 ;; found in other method or is static
	 (setq type-pos nil)
	 )
    (setq descr-2 (eap-get-type-descriptors))
    (or boundary
	type-pos
	;; found is static?
	(and (or type-pos-1 type-pos-2)
	     (eap-static-obj-p (nth 1 (or type-pos-1 type-pos-2)))
	     (save-excursion
	       (eap-set-type-descriptors (if type-pos-1 descr-1 descr-2))
	       (goto-char (nth 2 (or type-pos-1  type-pos-2)))
	       (if (looking-at "static\\>")
		   (setq eap-type-scope-description "static variable")
		 (setq eap-type-scope-description "global variable"))
	       (setq type-pos (or type-pos-1 type-pos-2))))
	(save-excursion
	  ;; look for static or global before the first method definition
	  (setq type-pos-1 nil type-pos-2 nil)
	  (goto-char (point-min))
	  (re-search-forward "^[^/\n]*{" nil t)
	  (and (search-backward ";" nil t)
	       (setq type-pos
		     (or (setq type-pos-1 (eap-obj-sch obj (not 're2)))
			 (setq type-pos-2 (eap-obj-sch obj 're2))))
	       (goto-char (nth 2 type-pos))
	       (if (looking-at "static\\>")
		   (setq eap-type-scope-description "static variable")
		 (setq eap-type-scope-description "global variable"))
	       ;; check that we are not in method declaration
	       (if type-pos-1
		   (while (not (bobp))
		     (eap-no-comment (skip-chars-backward "^(#;"))
		     (forward-char -1)
		     (if (or (bobp) (looking-at "[;#]"))
			 (goto-char (point-min)) ;; ok -> quit
		       (skip-syntax-backward "^w")
		       (skip-syntax-backward "w_")
		       (or (looking-at "Handle")
			   (setq type-pos nil)
			   (goto-char (point-min)) ;; ko -> quit
			   )
		       ))))
	  ;; look for static through the whole buffer
	  (goto-char (point-min))
	  (let ((re (format "^[ \t]*static[ \t]+[^{};]*%s[\t\n ]*[[,=();]" obj)))
	    (while (and (null type-pos)
			(re-search-forward re cur-pnt t))
	      (setq bnd (match-beginning 0))
	      (if (setq type-pos (or (eap-obj-sch obj (not 're2) bnd)
				     (eap-obj-sch obj 're2 bnd)))
		  (if (eap-static-obj-p (nth 1 type-pos))
		      (setq eap-type-scope-description "static variable")
		    (setq type-pos nil)))
	      ))
	  type-pos
	  )
	;; defined symbol
	(save-excursion
	  (if (re-search-backward (format "^[/ \t\n]*# *define +%s +\\([^\n]+\\)" obj) nil t)
	      (setq type-pos (list (match-string 1) (match-beginning 1))
		    eap-type-scope-description "macro"))
	  )
	)
    (if (null type-pos)
	(setq eap-type-is-handle "not defined"
	      eap-type-scope-description nil)
      (if pos
	  (setq type-pos (list (car type-pos) (cons buffer-file-name (nth 1 type-pos))))
	(setq type-pos (car type-pos))))
    type-pos)
  )

(defun eap-type-of-field (field &optional pos)
  "If POS returns list \(\<type\> \(\<file\> . \<pos-in-file\>\)\)"
  (eap-walk-over-inherited
   '(lambda ()
      (let ((type
	     (if (string-match "[.]cdl" buffer-file-name)
		 (eap-type-of-field-in-cdl field pos)
	       (eap-type-of-field-in-hxx field pos)
	       )))
	(if type
	    (setq eap-type-scope-description (format "field of %s" (eap-class-name))))
	type)
      )
   (or (eap-find-source buffer-file-name t) " ") nil t)
  )
(defun eap-type-of-field-in-cdl (field &optional pos)
  "Tries to find type of FIELD in current cdl buffer.
If POS returns list \(\<type\> \(\<file\> . \<pos-in-file\>\)\)"
  (save-excursion
    ;; field ex: myValue1, myValue2 : Real [4,2];
    (let* ((re (concat "^\\([^-\n]*[ \t,]\\)?\\(" field
		       "\\)\\s *\\(,[^:]+\\)?:\\s *\\(\\w+\\)"
		       "\\(\\s +from\\s +\\(\\w+\\)\\)?"
		       "\\(\\s *\\[\\)?")) ;; [] modif 
	   case-fold-search ;; do not ignore case
	   type) 
      (goto-char (point-max))
      (re-search-backward "^[^-]*fields\\>" nil t)
      (if (not (re-search-forward re nil t))
	  nil
	(setq eap-type-modifier-string (match-string 7))
	(let* ((cl (match-string 4))
	       (pack (match-string 6))
	       (pt (match-beginning 2))
	       )
	  (if pack
	      (setq type (concat pack "_" cl))
	    (setq type
		  (or (eap-find-pack-for-class cl) cl)))
	  (and type
	       pos
	       (setq type (list type (cons buffer-file-name pt)))
	       )
	  type)
	)))
  )
(defun eap-type-of-field-in-hxx (field &optional pos)
  "Tries to find type of FIELD in current hxx buffer.
If POS returns list \(\<type\> \(\<file\> . \<pos-in-buffer\>\)\)"
  (let* ((re (format
	      "^\\s *\\([()_a-zA-Z0-9]+\\)\\([ *\t\n]+\\)%s\\s *\\([][0-9]+ *\\)?;" field))
	 case-fold-search ;; do not ignore case
	 type)
    (goto-char 1)
    (if (not (re-search-forward re nil t))
	nil
      (setq type (list (match-string 1)
		       (cons buffer-file-name (match-beginning 1))))
      (setq eap-type-modifier-string
	    (concat (match-string 2)
		    (eap-simplify-string (or (match-string 3) "") '("[0-9]+"))))
      (if (setq eap-type-is-handle (string-match "Handle[ \t\n]*(" (car type)))
	  (setcar type (substring (car type) (match-end 0) -1)))
      (if pos type (car type))
      ))
  )

(defun eap-class-in-cdl (&optional cdl-type)
  "Return class name found at point in cdl buffer"
  (or (eap-cdl-class nil (not cdl-type))
      (eap-cdl-class-decl (not cdl-type))
      )
  )
(defun eap-cdl-class (&optional ends cpp-type)
  "returns string with cdl class description like <CLASS from PACK>
found near the point. If ENDS is not nil returns list: 
\(<CLASS from PACK> \(START . END\)\) where START and END are boundary
points of retstring in buffer"
  ;;(message "look for CDL")
  (let ((notfound t))
    (save-excursion
      (or (eobp) (forward-char 1))
      (forward-word -1)
      (if (looking-at "from ")
	  (setq notfound nil)
	(forward-word -1)
	(if (looking-at "from ")
	    (setq notfound nil)
	  (forward-word 3)
	  (forward-word -1)
	  (if (looking-at "from ")
	      (setq notfound nil))))
      (forward-word -1)
      (if (or notfound
	      (not (looking-at "\\(\\w+\\)[ \t\n]+from[ \t\n]+\\(\\w+\\)")))
	  nil
	(let* ((cls (match-string 1))
	       (pack (match-string 2))
	       (pos (cons (match-beginning 0) (match-end 0)))
	       (ret (if cpp-type
			(concat pack "_" cls)
		      (concat cls " from " pack)))
	       )
	  (if ends (cons ret pos) ret)))
      ))
  )

(defun eap-cdl-class-decl (&optional cpp-type)
  "Return <CLASS from PACK> found as <class CLASS> around point"
  (let ((count 3)
	(re (eap-look-at-cls-re))
	found-p)
    (save-excursion
      (or (eobp) (forward-char 1))
      (while (and (< 0 count)
		  (not (setq found-p (looking-at re)))
		  )
	(if (looking-at "instantiates[ \t\n]+")
	    (re-search-backward "class[ \t\n]" nil t)
	  (backward-word 1))
	(setq count (1- count))
	)
      (if found-p
	  (let ((cls (eap-cls-sch-cl))
		(pack (eap-cls-sch-pack))
		(gen-cl (eap-cls-sch-gen-cl))
		(gen-pack (eap-cls-sch-gen-pack))
		)
	    (or pack
		(setq pack (eap-get-package-name buffer-file-name)))
	    (if gen-cl
		(eap-update-instantiation-list
		 (list (concat pack "_" cls)
		       (concat gen-pack (if gen-pack "_") gen-cl)
		       (eap-class-name buffer-file-name)
		       gen-pack))
	      )
	    (if cpp-type
		(concat pack "_" cls)
	      (concat cls " from " pack))
	    ))
      ))
  )

(provide 'type-search)
