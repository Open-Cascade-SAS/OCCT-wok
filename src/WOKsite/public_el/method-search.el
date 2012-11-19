;;; method-search.el --- search for method declaration, definition, call etc.

;;;Author  : Edward AGAPOV <eap@opencascade.com>
;;; History	:Mon Mar 13 2000	Creation

;;; Commentary:

;;  Interactive entries (with default keybindings)
;;     eap-next-method           C-.
;;     eap-next-method-backward  C-,

;; Default keybinding is done by 'method-search-key function

(eval-and-compile ;; a macro needed
  (require 'shared)
  )

(defun eap-next-method (only-say-name &optional backward)
  "Moves cursor to the first line of the nearest method.
With prefix argument, just inform you about current method name and
copy it"
  (interactive "P")
    (let* ((msg (message "Look for %s method..."
			 (if backward (if only-say-name "current" "previous") "next")))
	   (eap-method-search-boundaries nil)
	   (meth-ends  (save-excursion
			 (if backward (beginning-of-line) (end-of-line))
			 (eap-method-fullstring backward 'endPos 'save)))
	   (name (if only-say-name (eap-method-name (car meth-ends)))) 
	   (ends (cdr meth-ends)))
      (if (null ends)
	  (message "%s Not found" msg)
	(if only-say-name
	    (progn
	      (message "%s    '%s'" msg name)
	      (kill-new name))
	  (push-mark nil nil t)
	  (setq mark-active nil)
	  (eap-set-pos-at-line (car ends) 2)
	  (goto-char (if backward (car ends) (cdr ends))))))
  )
(defun eap-next-method-backward (only-say-name)
  "The same as eap-next-method but backward"
  (interactive "P")
  (eap-next-method only-say-name 'back)
  )

(defvar method-search-regexp-or-function
  (list
   (cons 'cdl-mode  "^\\s *\\(\\w+\\s *\\(([^)]+)\\|returns\\)[^;]*;\\|class +[a-z0-9]+;\\|Create *;\\)")
   (cons 'ccl-mode "\\(^\\s *( *def[a-z]+\\(-constant\\)?\\s +[-_a-zA-Z0-9]+[^\n]*\\)$")
   (cons 'tcl-mode "^\\s *\\(proc\\s +[^\n]+\\)")
   (cons 'c++-mode 'eap-cpp-method-fullstring)
   (cons 'c-mode   'eap-c-method-fullstring)
   (cons 'emacs-lisp-mode "\\(^\\s *( *def[a-z]+\\s +[-_a-zA-Z0-9]+[^\n]+\\)$")
   )
  "*Alist mapping major-mode to <regexp or function>.
Is used in 'eap-method-fullstring \(which see).
<Regexp> is used to find 'method-fullstring that is 1-st match-string.
<Function> must look like FUNCTION (&optional BACKWARD ENDPOS)
and return result of the same format as 'eap-method-fullstring."
  )
(defvar method-search-simpli-list
  (list
   (cons 'cdl-mode '(("[ \t]*--[^\n]*\\(\n\\|$\\)")))
   (cons 'ccl-mode '(("[ \t]*;[^\n]*\\(\n\\|$\\)")))
   (cons 'emacs-lisp-mode '(("[ \t]*;[^\n]*\\(\n\\|$\\)")))
   (cons 'tcl-mode '(("[ \t]*#[^\n]*\\(\n\\|$\\)")))
   )
  "*Alist mapping major-mode to <simplifying list>.
Is used in 'eap-method-fullstring \(which see) as the second
argument of 'eap-simplify-string applied to string matching <regexp>
corresponding to major-mode in 'method-search-regexp-or-function."
  )

(defvar eap-method-search-boundaries nil
  "Cons (UPPER-BOUNDARY . LOWER-BOUNDARY) to restrict region for the search")

(defun eap-method-fullstring (&optional backward-p endPos save mode)
  "Search for the next method head.
BACKWARD-P indicates direction.
Return: if ENDPOS not nil, (<head string> <starting-position> . <end-position>)
otherwise just <head string> or nil if nothing found.
To get <starting-position> from the result use (nth 1 result)
and <end-position> - (nthcdr 2 result).
SAVE means resore cursor position after the seach.
Use MODE to indicate major-mode if it is known for sure. If MODE is nil
or omitted it is deduced from file name or current major-mode is used."
  (let* ((mode (or mode (eap-file-mode) major-mode))
	 (oldPos (point))
	 (bnd (funcall (if backward-p 'car 'cdr) eap-method-search-boundaries))
	 (regexp-or-fun (or (cdr (assoc mode method-search-regexp-or-function))
			    ;; default e-lisp 
			    "\\(^\\s *( *def[a-z]+\\s +[-_a-zA-Z0-9]+[^\n]+\\)$"))
	 (case-fold-search t)
	 methodString pos m_p)
    (if (stringp regexp-or-fun)
	(and (if backward-p
		 (search-backward-regexp regexp-or-fun bnd t)
	       (search-forward-regexp regexp-or-fun bnd t))
	     (setq pos (cons (match-beginning 1) (match-end 1))
		   methodString (match-string 1))
	     ;; special case for cdl mode
;;;	     (if (string-match "[\n\t ]+inherits[\t\n ]+*" methodString)
;;;		 (progn
;;;		   (goto-char (car pos)) (skip-chars-forward "^\n")
;;;		   (setq m_p (eap-method-fullstring backward-p endPos nil mode)))
	       (setq methodString
		     (eap-simplify-string methodString
					  (cdr (assoc mode method-search-simpli-list))))
	       (setq m_p (if endPos (cons methodString pos) methodString))
	       );;;)
      (condition-case nil
	  (and (symbolp regexp-or-fun)
	       (fboundp regexp-or-fun)
	       (setq m_p (funcall regexp-or-fun backward-p endPos))
	       )
	(error nil)
	)
      )
    (if (or save (null m_p)) (goto-char oldPos))
    m_p)
  )
(defun eap-c-method-fullstring (&optional backward endPos)
  (let* ((regexp "\\<\\(\\(static\\|Standard_EXPORT\\) +\\)?[_a-z0-9]+[&* \t\n]+[_a-z0-9]+\\s *([^)]*)")
	 (searchFun (if backward 're-search-backward 're-search-forward))
	 (bndry (if backward
		    (or (car eap-method-search-boundaries) (point-min))
		  (or (cdr eap-method-search-boundaries) (point-max))))
	 str ends)
    (if (null (funcall searchFun regexp bndry t))
	nil
      (setq str (match-string 0)
	    ends (cons (match-beginning 0) (match-end 0)))
      (goto-char (cdr ends))
      (if (or (not (looking-at "[\t\n ]*\\({\\|\\w\\)"))
	      (string-match "\\<\\(if\\|else\\|for\\)\\>" str)
	      (eap-in-comment)
	      )
	  (progn (if backward (goto-char (car ends)))
		 (eap-c-method-fullstring backward endPos))
	;;(setq str (eap-simplify-string str '(("\t" " ")("\n" " ")("  " " "))))
	(if endPos
	    (cons str ends)
	  str))))
  )

(defun eap-cpp-method-fullstring (&optional backward ends)
  (if (string-match "[.]h[xp]*$" buffer-file-name)
      (eap-hxx-method-fullstring backward ends)
    (eap-cxx-method-fullstring backward ends)
    )
  )

(defun eap-cxx-method-fullstring (&optional backward ends)

  (let* ((case-fold-search t) ;; ignore case
	 (retValue "[ \t\n]\\(static[ \t\n]+\\)?\\(const[ \t\n]+\\)?\\(Handle[( \n\t]+\\)?[_:a-z0-9]+[ )&*\n\t]+")
	 (meth-name "[_a-z0-9]+[ \t\n]*\\(::[ \t\n]*[_a-z0-9]+[ \t\n]*\\)?")
	 (constructor-name "\\([_a-z0-9]+\\)[ \t\n]*::[ \t\n]*\\2[ \t\n]*")
	 (arg "([ \t\n]*\\()\\|\\(const[ \t\n]+\\)?\\(Handle[( \n\t]+\\)?[_:a-z0-9]+[ )&/*\n\t]*[,)_a-z0-9]+\\)")
	 (regexp (format "\\(%s\\|%s%s\\)%s" constructor-name retValue meth-name arg))
	 ;;;(regexp (concat "[_a-z0-9]+[ )&*\n\t]+"))
	 (bound (funcall (if backward 'car 'cdr) eap-method-search-boundaries))
	 (re-sch-fun '(lambda ()
			(if bound
			    (if backward
				(if (> (point) bound) (re-search-backward regexp bound t))
			      (if (< (point) bound) (re-search-forward regexp bound t)))
			  (if backward
			      (re-search-backward regexp nil t)
			    (re-search-forward regexp nil t)))))
	 (re-search-method-fun '(lambda()
				  ;;(goto-char end);;(if backward beg end)
				  (goto-char (if backward beg end))
				  (eap-cxx-method-fullstring backward ends)))
	 (quit-comment-fun '(lambda (comm-ends)
			      (goto-char
			       (funcall (if backward 'car 'cdr) comm-ends))))
	 end beg meth-beg string
	 has-bad-symbols has-comm-inside has-preproc-inside
	 )
    (while (and (null beg)
		(funcall re-sch-fun))
      (setq beg (match-beginning 1))
      (setq end (match-end 1))
      (goto-char beg)
      (skip-syntax-forward "^w")
      (and (or (re-search-forward
		"\\<\\(if\\|else\\|return\\|new\\|switch\\|throw\\|raise\\)\\>" end t)
	       ;; definition or declaration ?
	       (save-excursion
		 (setq has-comm-inside
		       (or (eap-no-comment nil (skip-chars-forward "^{;"))
			   (< end (cdr eap-next-comment-ends))))
		 (setq meth-beg (point))
		 (not (looking-at "{")))
	       ;; beg is in comment ?
	       (if (if has-comm-inside
		       (if (< (point) (car eap-next-comment-ends))
			   (eap-quit-comment backward)
			 (funcall quit-comment-fun eap-next-comment-ends))
		     (if (< (point) (cdr eap-next-comment-ends))
			 (funcall quit-comment-fun eap-next-comment-ends)))
		   (setq end (1- (point)) ;; to see space before word
			 beg end))
	       )
	   (goto-char (if backward beg end))
	   (setq beg nil)
	   )
      (and beg backward ;; if 'const Handle(...)' is a first arg and we skip it ->
	   ;; we miss a method
	   (re-search-forward "const[ \t]+Handle" end t)
	   (not (setq beg nil))
	   (skip-chars-backward "^{}#;")
	   (if (< (point) (cdr eap-next-comment-ends))
	       (goto-char (cdr eap-next-comment-ends)) t)
	   (save-excursion (re-search-forward regexp end t))
	   (/= end (match-end 1)) ;; not the same 'const Handle(...)'
	   (setq beg (match-beginning 1)
		 end (match-end 1))
	   bound ;; overgo boundary?
	   (< beg bound)
	   (setq beg nil)
	   )
      )
    (if (null beg)
	nil
      (goto-char beg)
      (skip-syntax-forward "^w")
      (setq beg (point))
      ;; first args parenthesis
      (goto-char end)
      (skip-chars-forward "^(")
      ;; look for not allowed symbols that are not in comments
      (while (and (not has-bad-symbols)
		  ;;(< (point) end)
		  (re-search-forward  "[^][ \t\n,:*&/()_=a-z0-9]" meth-beg t))
	(if (= ?# (char-after (1- (point)))) ;; preprocessor instruction
	    (setq has-preproc-inside
		  (goto-char (min meth-beg (search-forward "\n"))))
	  (setq has-bad-symbols (if has-comm-inside (not (eap-quit-comment)) t)))
	)
      (if has-bad-symbols
	  (funcall re-search-method-fun)
	;; check symbols after closing parenthesis
	(goto-char end)
	(skip-chars-forward "^(")
	(setq end (if (not has-comm-inside)
		      (eap-matching-paren)
		    (save-excursion
		      (goto-char meth-beg)
		      (eap-no-comment 'back (skip-chars-backward "^)"))
		      (point))))
	(goto-char end)
	;; skip preprocessor instruction
	;;(if has-preproc-inside
	    (while (re-search-forward "^[^/\n]*#[^\n]+" meth-beg t ))
	    ;;)
	;; skip comments
	(if has-comm-inside
	    (while (re-search-forward "[ \t\n]*\\(const[ \t\n]*\\)?/[/*]" meth-beg t)
	      (eap-quit-comment)))
	;; check
	(if (not (looking-at "[\t\n ]*\\(const\\|throw\\)?[\t\n ]*\\([{(]\\|:[ \t\n]*[a-z0-9]\\)"))
	    (funcall re-search-method-fun)
	  ;; end = closing parenthesis
	  (goto-char (if backward beg end)) ; prepare for next search
	  (setq string (eap-simplify-string (buffer-substring-no-properties beg end)
					    '(("//[^\n]+")
					      ;;("inline[ \t]*")
					      )))
	  (if ends
	      (cons string (cons beg end))
	    string))))
    )
  )

(defun eap-hxx-method-fullstring (&optional backward ends) 
  (let* ((re-search-fun '(lambda()
			   (goto-char (if backward beg end))
			   (eap-hxx-method-fullstring backward ends)
			   ))
	 (case-fold-search t)
	 bad-beg beg end meth-str)
    ;; look for method
    (if (not (funcall (if backward 're-search-backward 're-search-forward)
		      "\\<\\([_a-z0-9]+\\)\\s *(" nil t))
	nil
      (setq beg (match-beginning 1)
	    end (match-end 0))
      (setq meth-str (match-string 1))
      (backward-char 1) ;; case of 1-st arg commented
      (if (or (eap-in-comment)
	      (string-match "^\\(Handle\\|raises\\|throw\\)$" meth-str))
	  (eap-hxx-method-fullstring backward ends)
	;; look for method beginning
	(if (string= (eap-class-name) meth-str) ;; constructor
	    (setq bad-beg (1+ beg))
	  (goto-char beg)
	  (skip-syntax-backward " ")
	  (setq bad-beg (point))
	  (or (= 0 (skip-chars-backward ":")) ;; scope in inline implementation
	      (progn (skip-syntax-backward " ")
		     (setq bad-beg (point))))
	  (skip-chars-backward "_&*()a-zA-Z0-9") ;; skip ret value
	  (setq beg (point))
	  (while (and (skip-syntax-backward " ")
		      (skip-chars-backward "_a-zA-Z") ;; skip Standard_EXPORT or ...
		      (looking-at "\\(Standard_EXPORT\\|virtual\\|static\\|inline\\)\\>")
		      (not (eap-in-comment)))
	    (setq beg (point))
	    ))
	(if (or (= beg bad-beg)
		(string-match "\\<\\(return\\|new\\)\\>" (buffer-substring bad-beg beg)))
	    (funcall re-search-fun)
	  ;; look for method end
	  (goto-char (1- end))
	  (if (not (and (setq end (eap-matching-paren))
			(goto-char end)
			(if (looking-at "\\s */[*/]")
			    (eap-quit-comment (not 'back) 'skip-space)
			  'ok)
			(looking-at
			 "\\s *\\(\\(raises\\|throw\\)\\>\\|\\(const\\s *\\)?[=0 \t\n]*[{;]\\)")))
	      (funcall re-search-fun)
	    (setq meth-str
		  (eap-simplify-string (buffer-substring beg end)
				       '(("//[^\n]+")
					 ("/[^/]+/")
					 ("Standard_EXPORT\\s *")
					 ("\\(inline\\)\\s *")
					 )))
	    (goto-char (if backward beg end))
	    (if ends
		(cons meth-str (cons beg end))
	      meth-str)
	    )))
      ))
  )

(defun eap-parse-method-call-string (method-str)
  (if (not (string-match
	    "\\([_a-zA-Z0-9]+\\)\\(\\s *\\([.:=>-]+\\)?\\s *\\([_a-zA-Z0-9]+\\)\\)?"
	    method-str))
      (not (message "WRONG METHOD STRING"))
    (let* ((object (match-string 1 method-str))
	   (inter  (match-string 3 method-str))
	   (method (match-string 4 method-str))
	   class var2)
      (cond 
       ;; [this->] Method() or field initialization or constructor call
       ((null method)
	(or (string-match "[.]cdl" (or buffer-file-name (buffer-name)))
	    (setq var2 (list "Create" object nil  "Create" nil object )))
	(setq class (eap-class-name (or buffer-file-name (buffer-name))))
	(setq method object
	      object nil)
	)
       ;; new|return Class() or return this->Method()
       ((string-match "^\\(new\\|return\\)$" object)
	(if (string= "return" object)
	    (setq var2 (list method nil (eap-class-name))))
	(setq class method
	      object nil
	      method "Create")
	)
       ((null inter)
       ;; Obj_Class anObj() or RetVal_Class Method()
	;; first variant
	(setq class object
	      object nil)
	(if (and (string-match "[.]hx*$" (or buffer-file-name ""))
		 (setq class (eap-class-name)))
	    (if (string= class method)
		(setq method "Create"))
	  (setq var2 (list method nil (eap-class-name)))
	  (setq method "Create"))
	)
       ;; object.Method()  or object->Method()
       ((string-match "[.>-]" inter)
	;; nothing to change
	)
       ;; Class::Method()
       ((string= "::" inter)
	(setq class object
	      object nil)
	(if (string= class method)
	    (setq method "Create"))
	)
       ;; obj = this->Method() or obj = Create_Obj() 
       ((string= "=" inter)
	(setq var2 (list "Create" nil method "Create" object nil)) ;; second variant
	(setq object nil
	      class (eap-class-name))
	)
       )
      (append (list method object class) var2)))
  )
(defun eap-method-call-string (&optional endPos)
  "Return method call string"
  (let* ((cdl-p (string-match "[.]cdl" (or buffer-file-name (buffer-name))))
	 not-in-comment beg end str)
    (save-excursion
      (skip-syntax-forward "w_");; reach end of either object or method
      (and (not cdl-p)
	   (looking-at "[ \t\n]*\\(->\\|[.]\\|::\\)[_a-zA-Z0-9]+")
	   (goto-char (match-end 0))
	   )
      (setq end (point))
      (skip-syntax-backward "^w")
      (or cdl-p
	  (setq not-in-comment (not (eap-in-comment))))
      (skip-syntax-backward "w_") ;; may be method
      (setq beg (point))
      (skip-chars-backward "->:.= \t\n")
      (and (not cdl-p)
	   (looking-at "[ \t\n]*\\(->\\|[.]\\|::\\)?[ \t\n]*[_a-zA-Z0-9]+")
	   (eq not-in-comment (not (eap-in-comment)))
	   (skip-syntax-backward "w_") ;; object
	   (save-excursion
	     (beginning-of-line)
	     (not (looking-at "[ \t]*#"))) ;; not preprocessor instruction
	   (setq beg (point)))
      )
    (setq str (eap-simplify-string (buffer-substring end beg) '(("\t\n" " "))))
    (if endPos (cons str end) str)
    )
  )
(defvar method-search-in-cur-re
  (list
   (list 'c++-mode
	 "^\\([ \t_(a-zA-Z0-9]+\\w[ \t)&*]*\\)?[ \t]*[_a-zA-Z0-9]+[ \t\n]*::[ \t\n]*%s[ \t\n]*([^{;]+{" 
	 "^[ \t_(a-zA-Z0-9]+\\w[ \t\n)&*]+%s[ \t\n]*(" )
   (list 'cdl-mode
	 "^[\t ]*%s\\s *\\((\\s *[a-zA-Z]\\|returns\\s +\\)" )
   (list 'ccl-mode
	 "^\\s *(\\s *def[a-z]+\\(-constant\\)? +%s\\( \\|(\\|\n\\|\t\\)" )
   (list 'c-mode
	 "[-_a-zA-Z0-9]+ +%s *([^)]*)[\t\n ]*\\({\\|\\w\\)" )
   (list 'tcl-mode
	 "^\\s *proc %s[\t\n {]" )
   )
  "*Alist mapping major-mode to list of regexps for search for given method definition.
A regexp should contain %s format control-string to be replaced with method name.
Search is case sensitive.

Default regexps for c++-mode would find class method definition or anything looking
like method definition or declaration"
  )
(defun eap-find-method-in-current (methodName &optional from-cur-pt)
  "Look for method METHODNAME definition in current buffer
starting from buffer beginning or from current position \(if FROM-CUR-PT).
Move point at definition beginning and return this position.

Actually it looks for regexp associated with major-mode in
'method-search-in-cur-re and return \(match-beginning 0). If none regexp is
associated, regexp for elisp def[un,var,..] is searched"
  (let* ((re-list (or (cdr (assq (or (eap-file-mode) major-mode) method-search-in-cur-re))
		      (list "^\\s *(\\s *def[a-z]+ +%s\\( \\|(\\|\n\\|\t\\)"))) ;; e-lisp
	 case-fold-search
	 regexp pt)
    (save-excursion
      (or from-cur-pt
	  (goto-char (point-min)))
      (while (and (null pt) re-list)
	(setq regexp (format (car re-list) methodName)
	      re-list (cdr re-list))
	(while (and (re-search-forward regexp nil t)
		    (setq pt (match-beginning 0))
		    (eap-quit-comment))
	  (setq pt nil))
	))
    (if pt
	(goto-char pt)))
  )
(defun eap-method-name (method-fullstring &optional mode) 
  (if (stringp method-fullstring)
      (let* (name
	     (meth-str method-fullstring)
	     (match 1)
	     (mode (or mode (eap-file-mode)))
	     (regexp (cond 
		      ((equal mode 'c++-mode);;
		       (setq meth-str (eap-replace-all "Handle[ \t\n]*(" "Handle_" meth-str ))
		       "\\([_a-zA-Z0-9]+\\)[ \t\n]*(")
		      ((equal mode 'c-mode) "\\([-_a-zA-Z0-9]+\\) *(")
		      ((equal mode 'cdl-mode) "^\\s *\\([a-zA-Z0-9]+\\)")
		      ((equal mode 'ccl-mode)
		       (setq match 2)
		       "( *def[a-z]+\\(-constant\\)? *\\([-_a-zA-Z0-9]+\\)")
		      ((equal mode 'tcl-mode)
		       "proc\\s +\\([^ {\n]+\\)")
		      (t "( *def[a-z]+ \\([-_a-zA-Z0-9]+\\)"))))
	(and (string-match regexp meth-str)
	     (setq name (match-string match meth-str))
	     (if (string-match (format " %s *::" name) meth-str)
		 (setq name "Create") t)
	     name)))
  )
(defun method-search-key()
  (global-set-key [?\C-,]  'eap-next-method-backward)
  (global-set-key [?\C-.]  'eap-next-method)
  )

(provide 'method-search)
