;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CDL editing support package in GNUlisp.  v1.1
; Author: Remi Lequette @ Matra-Datavision  August 1990.
;
; Update: (FID 06/02/96)
;         new CDL keywords;
;         quicker working.
; Update:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; CDL (Class Description Language) is used internally at Matra-Datavision
; for Object Oriented software specifications
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Features of this mode are :
; 
; simple indentation scheme based on tabulations
; tabulation value is given by the variable cdl-indent
;
; automatic insertion of CDL keywords with templates :
; class, package, etc..
;
; for comment rubriques C-c C-r there is an automatic completion on rubrique
; names, see cdl-rubrique-table
;
; special behaviour inside comments
;
; automatic fontifying on CDL keywords.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar cdl-rubrique-table nil

  "Completion table for CDL rubriques")

(setq
 cdl-rubrique-table
  '(
    ("Purpose: ")
    ("Version: ")
    ("Include: ")
    ("Category: ")
    ("Example: ")
    ("Le Lisp: ")
    ("Keywords: ")
    ("Warning: ")
    ("References: ")
    ("Overview: ")
    ("C++: ")
    ("C++: inline")
    ("C++: alias ")
    ("Level: Public ")
    ("Level: Advanced ")
    ("Level: Internal ")
    ("See Also: ")))

(defvar cdl-structure-table
  '(
    ("class" . cdl-new-class)
    ("package" .  cdl-new-package)
    ("rubrique" . cdl-new-rubrique)
    ("buffer" . cdl-new-buffer)
    ("enumeration" . cdl-new-enumeration)
    ("exception" . cdl-new-exception)
    )
  "*Structures in CDL, name followed by function to insert structure.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CDL keywords list features for fontifying.
;;
;; Please, keep the CDL keyword lists in alphabetic order!
;; So it is much easier to verify or update them. Thanks!
;; Revision: FID 06/02/96
;;           Addition of many forgotten keywords (18);
;;           Addition of next CDL version keywords (8);
;;           New regexps for a quicker working.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar cdl-default-keywords nil
  "*Default list of keywords for font-lock")

(defvar cdl-default-public-keywords nil
  "*Default sub-list of public access CDL keywords")

(defvar cdl-default-private-keywords nil
  "*Default sub-list of restricted access CDL keywords")

(defvar cdl-rubrique-face 'bold-italic
  "*Default CDL rubrique font")

;; Public access keywords; for everybody
(setq cdl-default-public-keywords
      ( concat
	"a\\(lias\\|ny\\|s\\)"
	"\\|class"
	"\\|deferred"
	"\\|e\\(n\\(d\\|gine\\|umeration\\)"
	    "\\|x\\(ception\\|e\\(cfile\\|cutable\\)\\|ternal\\)\\)"
	"\\|f\\(ields\\|ortran\\|r\\(iends\\|om\\)\\)"
	"\\|generic"
	"\\|i\\(m\\(mutable\\|ported\\)"
	    "\\|n\\(\\|herits\\|stantiates\\|terface\\)"
	    "\\|s\\)"
	"\\|li\\(brary\\|ke\\)"
	"\\|m\\(e\\|utable\\|yclass\\)"
	"\\|o\\(bject\\|ut\\)"
	"\\|p\\(ackage\\|ointer\\|r\\(i\\(mitive\\|vate\\)\\|otected\\)\\)"
	"\\|r\\(aises\\|e\\(defined\\|turns\\)\\)"
	"\\|s\\(chema\\|tatic\\)"
	"\\|to"
	"\\|uses"
	"\\|virtual"
	)
      )

;; Restricted access keywords; for internal and specialized use only.
(setq cdl-default-private-keywords
      ( concat
	"c"
	"\\|ex\\(ecfile\\|ternal\\)"
	"\\|fortran"
	"\\|library"
	"\\|object"
	"\\|primitive"
	)
      )


;; The complete formed CDL keyword regexp now!
(setq cdl-default-keywords
      (list

       (concat
	"\\<\\("
	cdl-default-public-keywords
	"\\|"
	cdl-default-private-keywords
	"\\)\\>")

       '("c[+][+]" 0 font-lock-keyword-face t)
       '("---.*:" 0 cdl-rubrique-face t))
      )

(defvar cdl-mode-syntax-table nil
  "*Syntax table in use in CDL mode buffers.")

(let ((table (make-syntax-table)))
  (modify-syntax-entry ?_ "_" table)
  (modify-syntax-entry ?\( "()" table)
  (modify-syntax-entry ?\) ")(" table)
  (modify-syntax-entry ?$ "." table)
  (modify-syntax-entry ?* "." table)
  (modify-syntax-entry ?/ "." table)
  (modify-syntax-entry ?+ "." table)
  (modify-syntax-entry ?- "." table)
  (modify-syntax-entry ?= "." table)
  (modify-syntax-entry ?\& "." table)
  (modify-syntax-entry ?\| "." table)
  (modify-syntax-entry ?< "." table)
  (modify-syntax-entry ?> "." table)
  (modify-syntax-entry ?\[ "." table)
  (modify-syntax-entry ?\] "." table)
  (modify-syntax-entry ?\{ "." table)
  (modify-syntax-entry ?\} "." table)
  (modify-syntax-entry ?. "." table)
  (modify-syntax-entry ?\\ "/" table)
  (modify-syntax-entry ?: "." table)
  (modify-syntax-entry ?\; "." table)
  (modify-syntax-entry ?\' "\"" table)
  (modify-syntax-entry ?\" "\"" table)
  (modify-syntax-entry ?- ". 12" table)
  (modify-syntax-entry ?\n ">" table)
  (setq cdl-mode-syntax-table table))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar cdl-cc-map nil
  "Keymap used in CDL mode for Control-C commands.")
;; keys definition
(let ((map (make-sparse-keymap)))
  (define-key map "e" 'cdl-comment-end)
  (define-key map "t" 'cdl-tabsize)
  (define-key map "s" 'cdl-structure)
  (define-key map "f" 'cdl-fill-mode)
  (define-key map "\C-c" 'cdl-new-class)
  (define-key map "\C-r" 'cdl-new-rubrique)
  (define-key map "\C-p" 'cdl-new-package)
  (define-key map "\C-b" 'cdl-new-buffer)
  (define-key map "\C-e" 'cdl-new-enumeration)
  (define-key map "\C-x" 'cdl-new-exception)
  (setq cdl-cc-map map))

(defvar cdl-mode-map nil
  "Keymap used in CDL mode.")
;; keys definition
(let ((map (make-sparse-keymap)))
  (define-key map "\C-m" 'cdl-newline)
  (define-key map "\M-\C-m" 'cdl-raw-newline)
  (define-key map "\C-?" 'backward-delete-char-untabify)
  (define-key map "\C-i" 'cdl-tab)
  (define-key map "\M-\C-i" 'cdl-untab)
  (define-key map "\M-p" 'cdl-insert-packname)
  (define-key map "\M-c" 'cdl-insert-classname)
  (define-key map "\M-a" 'cdl-insert-from)
  (define-key map "\e\q" 'cdl-comment-fill)
  (define-key map "\C-c" cdl-cc-map)
  (setq cdl-mode-map map))

(defvar cdl-indent 4 "*Value is the number of columns to indent in CDL Mode.")

(defvar cdl-mode-abbrev-table nil
  "Abbrev table in use in CDL-mode buffers.")
(define-abbrev-table 'cdl-mode-abbrev-table ())

(defun cdl-mode ()
"This is a mode intended to support CDL specifications writing

Variable cdl-indent controls the number of spaces for indent/undent.
Function cdl-new-buffer is called on empty buffers and can be redefined.

\\{cdl-mode-map}
"
  (interactive)
  (kill-all-local-variables)
  (use-local-map cdl-mode-map)
  (setq major-mode 'cdl-mode)
  (setq mode-name "CDL")
  (setq local-abbrev-table cdl-mode-abbrev-table)
  (make-local-variable 'auto-fill-function)
  (setq auto-fill-function nil)
  (make-local-variable 'cdl-auto-fill-function)
  (setq cdl-auto-fill-function 'cdl-comment-do-auto-fill)
  (make-local-variable 'comment-column)
  (setq comment-column 41)
  (make-local-variable 'end-comment-column)
  (setq end-comment-column 72)
  (set-syntax-table cdl-mode-syntax-table)
  (make-local-variable 'paragraph-start)
  (setq paragraph-start (concat "^$\\|" page-delimiter))
  (make-local-variable 'paragraph-separate)
  (setq paragraph-separate paragraph-start)
  (make-local-variable 'paragraph-ignore-fill-prefix)
  (setq paragraph-ignore-fill-prefix t)
  (make-local-variable 'require-final-newline)
  (setq require-final-newline t)
  (make-local-variable 'comment-start)
  (setq comment-start "--")
  (make-local-variable 'comment-end)
  (setq comment-end "\n")
  (make-local-variable 'comment-start-skip)
  (setq comment-start-skip "--+ *")
  (make-local-variable 'comment-indent-function)
  (setq comment-indent-function 'c-comment-indent)
  (make-local-variable 'parse-sexp-ignore-comments)
  (setq parse-sexp-ignore-comments t)
;;  (make-local-variable 'package)
;;  (make-local-variable 'class)
  (make-local-variable 'cdl-mode-package)
  (make-local-variable 'cdl-mode-class)
  (make-local-variable 'font-lock-mode-hook)
  (setq font-lock-mode-hook 
	'(lambda () (setq font-lock-keywords cdl-default-keywords)))
  (setq cdl-mode-package (substring (buffer-name) 0 -4))
  (let ((i (string-match "_" cdl-mode-package)))
    (if i (setq 
	   cdl-mode-class (substring cdl-mode-package (1+ i))
	   cdl-mode-package (substring cdl-mode-package 0 i))
      (setq cdl-mode-class nil)))
  (if (zerop (buffer-size))
      (cdl-new-buffer))
  (run-hooks 'cdl-mode-hook))

(defun cdl-tabsize (s)
  "changes spacing used for indentation. Reads spacing from minibuffer."
  (interactive "nnew indentation spacing: ")
  (setq cdl-indent s))

(defun cdl-newline ()
  "Open a new line with indent and comment if necessary."
  (interactive)
  (if (cdl-in-comment)
      (insert ?\n (cdl-comment-current-fill))
    (cdl-raw-newline)))

(defun cdl-raw-newline ()
  "Start new line and indent to current tab stop."
  (interactive)
  (let ((cdl-cc (current-indentation)))
    (newline)
    (if (looking-at "^[ \t]*$")
	(progn
	  (indent-to cdl-cc)
	  (if (looking-at "[ \t]")
	      (kill-line))))))

(defun cdl-tab ()
  "Indent to next tab stop."
  (interactive)
  (indent-to (* (1+ (/ (current-indentation) cdl-indent)) cdl-indent)))

(defun cdl-untab ()
  "Delete backwards to previous tab stop."
  (interactive)
  (backward-delete-char-untabify cdl-indent nil))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; here we define the CDL comment commands
;; used to fill the comments
;; this only for comments alone on a line ...
;;

;; the basic test, are we inside a comment
(defun cdl-in-comment ()
  "Test if we are in a comment line."
  (save-excursion
    (beginning-of-line)
    (looking-at "^[ \t]*--")))

;; find the current fill prefix
;; generally from the beginning of the line to the first non blank
;; skipping the --
;; exception if the line is a rubrique, the rubrique title is skipped
;; a rubrique title is of the form ---xxxxx:

(defun cdl-comment-current-fill ()
  (save-excursion
    (let (prefix)
      (beginning-of-line)
      (looking-at "^[ \t]*---*[^ \t]*[ \t]*")
      (setq prefix (buffer-substring (match-beginning 0) (match-end 0)))
      ;; clear non dash caracters in prefix
      (let ((clean-prefix "")
	    (sp 0)
	    c
	    (size (length prefix)))
	(setq  c (substring prefix 0 1))
	(while (not (string= c "-"))
	  (setq clean-prefix (concat clean-prefix c))
	  (setq sp (1+ sp))
	  (setq  c (substring prefix sp (1+ sp))))
	(setq clean-prefix (concat clean-prefix "--"))
	(setq sp (+ sp 2))
	(while (< sp size)
	  (setq  c (substring prefix sp (1+ sp)))
	  (setq clean-prefix 
		(concat clean-prefix (if (string= c "\t") c " ")))
	  (setq sp (1+ sp)))
	clean-prefix))))
	

;; toggles the auto-fill mode
;;
(defun cdl-fill-mode (arg)
  "Toggle cdl auto-fill-mode, fills only in comments"
  (interactive "P")
  (auto-fill-mode arg)
  (if auto-fill-function
      (setq auto-fill-function
	    cdl-auto-fill-function)))

;; used in auto-fill mode to fill-in comments
(defun cdl-comment-do-auto-fill ()
  "Performs auto-fill in comments"
  (if (cdl-in-comment)
      (let ((opoint (point)))
	(save-excursion
	  (move-to-column (1+ fill-column))
	  (skip-chars-backward "^ \t\n")
	  (if (bolp)
	      (re-search-forward "[ \t]" opoint t))
	  (if (save-excursion
		(let (is-begin is-end)
		  (setq is-end (eolp))
		  (skip-chars-backward " \t")
		  (setq is-begin (bolp))
		  (and (not is-begin) (not is-end))))
	      ;; wrap the line
	      (progn
		(setq fill-prefix (cdl-comment-current-fill))
		(insert ?\n fill-prefix)))))))

;; fill command
;; narrow the buffer to the surrounding indented comment before filling it
(defun cdl-comment-fill (arg)
  "fill current comment paragraph."
  (interactive "P")
  (if (cdl-in-comment)
      (let (is-bolp fill-prefix)
	(setq is-bolp (bolp))
	(save-excursion
	  (let (beg end)
	    (setq beg
		  (progn
		    (while (and
			    (if (bobp)
				nil
			      (forward-line -1) t)
			    (if (and
				 (cdl-in-comment)
				 (progn 
				   (beginning-of-line)
				   (not (looking-at "^[ \t]*--[ \t]*$"))))
				t
			      (forward-line 1) nil)))
		    (beginning-of-line)
		    (setq fill-prefix (cdl-comment-current-fill))
		    (point)))
	    (setq end
		  (progn
		    (while (and
			    (if (progn (end-of-line) (eobp))
				nil
			      (forward-line 1) t)
			    (if (and
				 (cdl-in-comment)
				 (progn
				   (beginning-of-line)
				   (not (looking-at "^[ \t]*--[ \t]*$"))))
				t
			      (forward-line -1) nil)))
		    (if (eobp) 
			(insert ?\n)
		      (forward-line 1)
		      (beginning-of-line))
		    (point)))
	    (fill-region beg end arg)))
	(if (and (not is-bolp) (bolp))
	    (search-forward fill-prefix)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; following functions are used to insert structures
;;;; they have a name like cdl-new-structname
;;;; an entry ("structname" . cdl-new-structname) should
;;;; be entered in cdl-structure-table
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun cdl-structure ()
  "Insert a CDL structure prompted in a list."
  (interactive)
  (let ((name 
	 (completing-read "structure to insert : "
			  cdl-structure-table
			  nil t)))
    (if name
	(funcall (cdr (assoc name cdl-structure-table))))))


(defun cdl-new-class ()
  "Insert a class declaration, name is prompted."
  (interactive)
  (let (p
	(name (read-from-minibuffer 
	       "class name : " cdl-mode-class)))
    (end-of-line)
    (insert "\nclass " name " from ")
    (if cdl-mode-package (insert cdl-mode-package " "))
    (setq p (point))
    (insert "\n\n\t---Purpose: ")
    (insert "\n\nuses")
    (insert "\n\nraises")
    (insert "\n\nis")
    (insert "\n\nfields")
    (insert "\n\nend " name ";\n")
    (goto-char p)))

(defun cdl-new-package ()
  "Insert a package declaration, name is prompted."
  (interactive)
  (let (p
	(name (read-from-minibuffer 
	       "package name :" cdl-mode-package)))
    (end-of-line)
    (insert "\npackage " name " ")
    (setq p (point))
    (insert "\n\n\t---Purpose: ")
    (insert "\n\nuses")
    (insert "\n\nis")
    (insert "\n\nend " name ";\n")
    (goto-char p)))

(defun cdl-new-buffer ()
 "Insert a header for each empty CDL buffer "
 (interactive)
 (insert   "-- File:      " (buffer-name))
 (insert "\n-- Created:   " (format-time-string "%d.%m.%y %H:%M:%S"))
 (insert "\n-- Author:    " (concat (user-login-name) "@" (system-name)))
 (insert "\n---Copyright: Open CASCADE " (format-time-string "%Y") "\n")
 )

(defun cdl-new-rubrique ()
  "Insert a rubrique comment, prompt with completion"
  (interactive)
  (let 
      ((name (completing-read "Rubrique name:" cdl-rubrique-table nil t))
       (prefix))
    (beginning-of-line)
    (indent-to (current-indentation))
    (insert "---" name )
    ;; delete blank and tabs
    (delete-region (point) (save-excursion 
			     (skip-chars-forward " \t" (buffer-size))
			     (point)))))

(defun cdl-new-enumeration ()
  "Insert an enumeration declaration, name is prompted."
  (interactive)
  (let (p
	(name (read-from-minibuffer "enumeration name :")))
    (end-of-line)
    (insert "\nenumeration " name " is ")
    (insert "\n\t---Purpose: ")
    (setq p (point))
    (insert "\n\nend " name ";\n")
    (goto-char p)))

(defun cdl-new-exception ()
  "Insert an exception declaration, name is prompted."
  (interactive)
  (let (p
	(name (read-from-minibuffer "exception name :")))
    (insert "\texception " name " inherits ")
    (setq p (point))
    (insert ";\n")
    (goto-char p)))



;; to find the class whose name is in buffer

;;(defun cdl-find-class ()
;;  "Find the cdl file of the class near point in other window."
;;  (interactive)
;;  (let ((class nil) (notfound t) pos)
;;    (save-excursion
;;      (forward-char 1)
;;      (forward-word -1)
;;      (if (looking-at "from ")
;;	  (setq notfound nil)
;;	(forward-word -1)
;;	(if (looking-at "from ")
;;	    (setq notfound nil)
;;	  (forward-word 3)
;;	  (forward-word -1)
;;	  (if (looking-at "from ")
;;	      (setq notfound nil))))
;;      (if notfound
;;	  ()
;;	(forward-word -1)
;;	(setq pos (point))
;;	(forward-word 3)
;;	(setq class (buffer-substring pos (point)))
;;	))
;;    (if class (wok-find-cdl class))))


(defun cdl-find-class ()
  "Find the cdl file of the class near point in other window."
  (interactive)
  (let ((class nil) (notfound t) pos)
    (save-excursion
      (forward-char 1)
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
      (if notfound
	  ()
	(forward-word -1)
	(setq pos (point))
	(forward-word 1)
	(setq class (buffer-substring pos (point)))
	(forward-word 2)
	(forward-word -1)
	(setq pos (point))
	(forward-word 1)
	(setq cdl-mode-package (buffer-substring pos (point)))
	))
    (if class
	(set-buffer (find-file 
		     (car (wok-command (format "woklocate -p %s:source:%s_%s.cdl\n"
					       cdl-mode-package cdl-mode-package class))))) 
      (set-buffer (find-file 
		   (car (wok-command (format "woklocate -p %s:source:%s.cdl\n"
					     cdl-mode-package cdl-mode-package)))))))
  )
;; to insert in the file

(defun cdl-insert-classname ()
  "Insert the current class name at point."
  (interactive)
  (insert cdl-mode-class))

(defun cdl-insert-packname ()
  "Insert the current package name at point."
  (interactive)
  (insert cdl-mode-package))

(defun cdl-insert-from ()
  "Insert \"class from package\" at point."
  (interactive)
  (insert cdl-mode-class " from " cdl-mode-package))

