;;; source-browse.el --- browse source files contained in CasCade Software Factory

;;;Author  : Edward AGAPOV   <eap@opencascade.com>
;;;History : Thu Oct 11 2001      Creation

;; Provides commands (with default keybindings):
;;
;; * eap-find-method-declaration          C-f3 (global)
;; * eap-find-method-definition           S-f3 (global)
;; * eap-find-class-declaration           C-f2 (global)
;; * eap-find-class-definition            S-f2 (global)
;; * eap-switch-to-inherited-declaration  C-f4
;; * eap-switch-to-inherited-definition   S-f4
;; * eap-switch-def-decl                  C-f7
;; * eap-switch-to-lxx                    S-f7
;; * eap-open-header                      S-C-f3
;; * eap-open-package                     S-C-f2

;; Default keybinding is done by 'source-browse-key function.
;; NOTE: the commands are bound to local map when 'c++-mode-hook and
;; 'cdl-mode-hook run.

;;   All but 'eap-open-header commands called with prefix argument
;; (C-u for ex.) kill current buffer and show search result in
;; current window, otherwise (without argument) display found
;; source file in other window.
;;   A way through sources led to current file is kept and you can
;; get back using 'eap-come-back-to-origin command.
;;   Names of visited files can be stored in a special buffer.
;; To enable this possibility, set 'eap-enable-remember-visited to t.
;; The buffer can be found calling 'eap-show-visited-files.

(require 'type-search)
(eval-when-compile ;; a macros needed
  (require 'shared)
  )

(defun eap-same-place-p (buf pnt)
  "Check if current buffer is BUF and point is close to PNT"
  (and (eq (current-buffer) buf)
       (<= (count-lines (point) pnt) 2))
  )
(defun eap-generic-cdl-instead-of-hxx (header cur-buf cur-pnt)
  "Return buffer with either instantiation of HEADER or generic cdl the HEADER instantiates"
  (if (not (string-match "[.]hxx" (or header "")))
      nil
    (save-excursion
      (let* ((instance (file-name-nondirectory header))
	     (buf (eap-find-generic instance 'buffer 'existing))
	     )
	(and buf 
	     (set-buffer buf)
	     (eap-same-place-p cur-buf cur-pnt)
	     (let ((gen-cdl (eap-find-file-with-ext (eap-find-generic instance) "cdl")))
	       (if gen-cdl (setq buf (eap-find-file-noselect gen-cdl)))
	       ))
	buf)))
  )
(defun eap-find-method-declaration (&optional kill-start)
  "Find declaration of method found at point in c++ file."
  (interactive "P")
  (eap-find-method-internal kill-start nil)
  )
(defun eap-find-method-definition (&optional kill-start)
  "Find definition of method found at point in c++ or cdl file."
  (interactive "P")
  (eap-find-method-internal kill-start t)
  )
(defun eap-find-method-internal (&optional kill-start definition-p)
  "Looks for a cdl, hxx declaration or c++ definition of the method found at point.
Arguments type and number is not taken into account."
  (eap-csf-check)
  (let* ((start (eap-get-back-file))
	 (start-buf (current-buffer))
	 (str_pos (eap-method-call-string 'endPos))
	 (method_object_class  (eap-parse-method-call-string (car str_pos)))
	 (find-meth '(lambda ()
		       (if buffer-file-name
			   (eap-find-method-in-current-aux method definition-p start))))
	 file_pos file msg
	 method object class found-p
	 )
    ;; mark method
    (let ((endPos (cdr str_pos)))
      (goto-char endPos) (set-mark endPos) (skip-syntax-backward "w_")
      )
    (while (and method_object_class (not found-p))
      (setq method (nth 0 method_object_class))
      (setq object (nth 1 method_object_class))
      (setq class  (nth 2 method_object_class))
      (setq method_object_class (nthcdr 3 method_object_class))
      (setq msg nil file nil)
      (and object
	   (message "Define type of '%s'..." object)
	   (setq class (eap-type-of-object object)))
      ;; find source file of <class>
      (if (null class)
	  (progn (setq msg (message "Define type of '%s'... Failure" object))
		 (sit-for 0.5))
	(if object
	    (message "Define type of '%s'... Done: '%s'" object class))
	(or (string-match "_" class)
	    (let ((cls (eap-find-generic-parameter-type class)))
	      (if cls (setq class cls)))
	    )
	(setq file (or (eap-find-source class (not definition-p))
		       (eap-find-source class definition-p)))
	)
      ;; look for method in found source file and ancestor files
      (or (if file
	      (setq file_pos (eap-walk-over-inherited find-meth file nil (not definition-p) t)))
	  ;; try to find in current (ex. math_FunctionSetRoot, class MyDirFunction)
	  (member (file-name-nondirectory buffer-file-name)
		  eap-inherited-walked-over) ;; do not search twice
	  (string= "Create" method)       ;; constructor is in any file
	  (save-excursion
	    (and (setq file_pos (funcall find-meth))
		 ;; found method must not be class method of current class
		 (goto-char (nth 1 file_pos))
		 (looking-at (format ".*%s[ \t]*::[ \t]*%s" (eap-class-name) method))
		 (setq file_pos nil)
		 ))
	  (and class (null file) (null msg)
	       (setq msg (message "No file found for type '%s'" class))
	       ))
      (setq found-p
	    (eap-jump-plus (car file_pos) kill-start start start-buf (nth 1 file_pos) 2))
      )
    (if found-p
	(skip-syntax-forward "^w")
      (and (string= "Create" method)
	   class
	   (setq method class))
      (or msg (message "Look for %s()... Not found. Sorry" method))
      )
    )
  )
(defun eap-find-method-in-current-aux (method definition-p start)
  "Look for METHOD in current buffer
Make additional check on buffer type and result returned by eap-find-method-in-current"
  (let* ((cur-file buffer-file-name)
	 (file-name (file-name-nondirectory cur-file))
	 (msg (message "Look for %s()... in %s" method file-name))
	 (pos (eap-find-method-in-current method))
	 generic meth)
    (and (null pos)
	 (string= "Create" method)
	 (setq meth (eap-class-name file-name))
	 (setq pos (eap-find-method-in-current meth))
	 )
    (cond
     ((null pos)
      nil
      )
     ;; check if definition found in [cglh]xx
     ((and definition-p
	   (string-match "[.][hcg]xx" cur-file)
	   (let ((header-p (string-match "[.][h]xx" cur-file))
		 stop-check-p)
	     ;;(skip-chars-backward "^\n")
	     (while (and (not stop-check-p)
			 (goto-char pos)
			 (or
			  (looking-at "[ \t]*\\(\\(}? *else +\\)?if\\|for\\|switch\\)[ \t\n]*(")
			  (progn
			    ;;(search-forward (or meth method))
			    (eap-no-comment nil (skip-chars-forward "^{;"))
			    (not (looking-at "{")))))
	       ;; not definition
	       (if header-p
		   (setq pos nil stop-check-p t)
		 ;; suppose declaration or call is found, look for definition
		 (end-of-line)
		 (or (setq pos (eap-find-method-in-current method 'from-this-point))
		     (setq stop-check-p t))
		 ))
	     stop-check-p))
      )
     ;; check if definition-p found
     ((not (eq definition-p (eap-is-definition cur-file)))
      (cond
       ;; find packed definition if declaration found in BAG instead of definition 
       ((string-match "/BAG/" cur-file)
	(setq pos nil)
	(setq generic (eap-find-generic file-name))
	(let* ((def-name (if generic
			     (concat generic ".gxx")
			   (concat (eap-class-name cur-file) ".cxx")))
	       (bag-path (if generic
			     (eap-find-file-in-BAG (concat generic ".cdl") "src")
			   (if (string-match "/src/" cur-file) cur-file nil)))
	       (buf (if bag-path
			(eap-find-packed-file-internal def-name bag-path)
		      (eap-find-packed-file def-name))))
	  (and buf
	       (set-buffer buf)
	       (setq pos (eap-find-method-in-current method))
	       (setq cur-file buffer-file-name))
	  (and (null pos)
	       (buffer-live-p buf)
	       (kill-buffer buf))
	  (and (null pos)
	       (setq def-name (eap-make-extention cur-file "lxx"))
	       (setq buf (eap-find-packed-file-internal def-name cur-file))
	       (set-buffer buf)
	       (setq pos (eap-find-method-in-current method))
	       (setq cur-file buffer-file-name))
	  (and (null pos)
	       (buffer-live-p buf)
	       (kill-buffer buf))
	  )
	)
       )
      )
     ;; find cdl of generic instead of hxx of instance
     ((and (not definition-p)
	   (string-match "[.]hxx" cur-file)
	   (setq generic (eap-find-generic file-name)))
      (let* ((gen-file (eap-find-file-with-ext generic "cdl"))
	     (buf (if gen-file (set-buffer (eap-find-file-noselect gen-file))))
	     (gen-pos (if gen-file (eap-find-method-in-current method)))
	     )
	(if (null gen-pos)
	    (if buf (kill-buffer buf))
	  (setq pos gen-pos)
	  (setq cur-file gen-file)))
      )
     ) ;; cond
    (goto-char (cdr (car start)))
    (if pos
	;; check if we returned back
	(if (and (string= (car (car start)) cur-file)
		 (<= (count-lines (cdr (car start)) pos) 2))
	    (setq pos nil)
	  (list cur-file pos)))
    )
  )
(defun eap-find-class-declaration (&optional kill-start)
  "Find declaration of class found at point in any buffer. 
If a c++ object is at point, find it's class declaration."
  (interactive "P")
  (eap-find-class kill-start t))
(defun eap-find-class-definition (&optional kill-start)
  "Find definition of class found at point in any buffer. 
If a c++ object is at point, find it's class definition."
  (interactive "P")
  (eap-find-class kill-start nil))
(defun eap-find-class (&optional kill-start decl-p)
  "Find file declaring or implementing a class found near point
in C++/CDL buffer."
  (eap-csf-check)
  (let* ((start (eap-get-back-file))
	 (cur-buf (current-buffer))
	 (cur-pnt (point))
	 (cls (or (eap-class-in-cdl)
		  (eap-current-word)))
	 file buffer pnt line)
    (message "Look for class %s..." (if decl-p "declaration" "definition"))
    (or (string-match "_" cls)
	;; find package file 
	(setq file (eap-find-source cls decl-p))
	;; add package name before <cls> 
	(setq cls (eap-find-pack-for-class cls))
	;; find object type in cxx
	(setq cls (eap-current-type))
	)
    (or file
	(null cls)
	(setq file (eap-find-source cls decl-p))
	(if (not decl-p)
	    (setq buffer (eap-find-packed-file cls)))
	;; find generic
	(let (gen)
	  (if decl-p
	      (and (setq buffer (eap-find-generic cls 'buf 'existing))
		   (set-buffer buffer)
		   (setq pnt (point))
		   (eap-same-place-p cur-buf cur-pnt)
		   (if (= (buffer-modified-tick buffer) 1)
		       (kill-buffer buffer) t) ;; kill if newly opened
		   (setq pnt nil
			 gen (eap-find-generic cls))
		   (setq file (eap-find-file-with-ext gen "cdl")))
	    (and (setq gen (eap-find-generic cls))
		 (setq file (eap-find-source gen decl-p))))
	  (or file buffer)
	  )
	;; find enum
	(setq buffer (eap-find-enum cls 'buf 'exist))
	;; find class declared in current cxx
	(and (set-buffer cur-buf)
	     (string-match "[.][cg]xx" buffer-file-name)
	     (setq pnt (save-excursion
			 (re-search-backward
			  (format "^[ \t]*class[ \t\n]+%s[ \t\n]*[:{]" cls) nil t)))
	     (setq buffer cur-buf line 2))
	)
    ;; instantiation in cdl instead of instance header
    (and file
	 decl-p
	 (setq buffer (eap-generic-cdl-instead-of-hxx file cur-buf cur-pnt))
	 (set-buffer buffer)
	 (setq pnt (point))
	 )
    (if (eap-jump-plus (or buffer file) kill-start start cur-buf pnt line)
	(message "Ok")
      (message "not found: %s.*" cls))
    )
  )
(defvar eap-complete-find-file-history nil
  )
(defun eap-complete-find-file (update-types-list)
  "Find file with extention providing file name completion.
Prefix arguments forces updating list of existing files."
  (interactive "P")
  (let (( init (if mark-active (buffer-substring (point) (mark)) ""))
	file path ext predicate require-match)
    (if (> (length init) 30)
	(setq init ""))
    (eap-check-all-type-list update-types-list)
    (while (null ext)
      (setq file (completing-read "File: "
				  eap-all-type-list
				  predicate require-match init
				  'eap-complete-find-file-history))
      (setq ext (eap-extention file))
      (if ext
	  (setq file (file-name-nondirectory file))
	(message "Provide file extention")
	(sit-for 0.5)
	(setq init file))
      )
    (setq path (eap-find-file-with-ext file ext))
    (if (null path)
	(message "%s.%s not found" file ext)
      (eap-find-file path 'existing)
      (eap-prepare-to-edit)
      (message "Ok" ))
    )
  )
(defun eap-switch-to-inherited-declaration (&optional kill-start)
  "Switch to declaration of inherited class of current one."
  (interactive "P")
  (eap-switch-to-inherited kill-start t)
  )
(defun eap-switch-to-inherited-definition (&optional kill-start)
  "Switch to definition of inherited class of current one."
  (interactive "P")
  (eap-switch-to-inherited kill-start nil)
  )
(defun eap-switch-to-inherited (&optional kill-start decl-p)
  "switch to inherited or generic class"
  (eap-csf-check)
  (let* ((start (eap-get-back-file))
	 (start-name (file-name-nondirectory (buffer-file-name)))
	 (pearent (or (eap-pearent)
		      (eap-find-generic start-name)))
	 buf found-file
	 )
    (if (null pearent)
	(message "No pearent found for %s" start-name)
      (or (setq found-file (eap-find-source pearent decl-p))
	  decl-p
	  (setq buf (eap-find-packed-file pearent))
	  )
      (and found-file
	   decl-p
	   (setq buf (eap-generic-cdl-instead-of-hxx found-file nil 0))
	   )
      (or (eap-jump-plus (or buf found-file) kill-start start)
	  (message "%s not found" pearent))
      )
    )
  )

(defun eap-switch-to-lxx (kill-start)
  "Switch from current file to lxx file and from lxx to [cg]xx file."
  (interactive "P")
  (eap-switch-def-decl kill-start 'lxx)
  )
(defun eap-switch-def-decl (kill-start &optional to-lxx)
  "Switch between definition and declaration of current class."
  (interactive "P")
  (eap-csf-check)
  (if (null buffer-file-name)
      (error "Wrong file type")
    (and to-lxx
	 (string-match "[.]lxx" buffer-file-name)
	 (setq to-lxx nil))
    (let* ((start (eap-get-back-file))
	   (fileName (eap-class-name))
	   (decl-p nil)
	   (file (if to-lxx
		     (eap-find-file-with-ext fileName "lxx")
		   (setq decl-p (string-match "[.][gc]xx" (or buffer-file-name (buffer-name))))
		   (eap-find-source fileName decl-p)))
	   buf)
      (or file
	  ;; if file name differs from class name
	  (let ((class (eap-class-name-by-method-def fileName)))
	    (if class
		(if to-lxx
		     (eap-find-file-with-ext class "lxx")
		   (setq decl-p (string-match "[.][gc]xx" class))
		   (eap-find-source class decl-p)))
	    )
	  decl-p
	  (setq buf (eap-find-packed-file fileName (if to-lxx "lxx"))))
      ;; prefer generic cdl instead of instance hxx
      (and file
	   decl-p
	   (setq buf (eap-generic-cdl-instead-of-hxx file nil 0)))
      (setq fileName (eap-class-name fileName))
      (or (eap-jump-plus (or buf file) kill-start start)
	  (cond
	   (to-lxx
	    (not (message "'%s.lxx' not found" fileName))
	    )
	   (decl-p
	    (not (message "Neither '%s.cdl' nor '%s.hxx' is found" fileName fileName))
	    )
	   (t
	    (not (message "Neither '%s.cxx' nor '%s.gxx' is found" fileName fileName))
	    ))
	  )))
  )

(defun eap-open-header (ofCurrentFile)
  "Show header file for current buffer class (with prefix argument) or class at point."
  (interactive "P")
  (eap-csf-check)
  (let* ((start (eap-get-back-file))
	 (type (if ofCurrentFile buffer-file-name (eap-current-type)))
	 (type-name (if type (eap-class-name type)))
	 (msg (message "Look for %s.hxx..." type-name))
	 (foxName (if type (eap-find-file-with-ext type "hxx")))
	 )
    (or (eap-jump-plus foxName nil start)
	(if type
	    (message "%s Not found" msg)
	  (if ofCurrentFile
	      (message "Open header: Wrong buffer type")
	    (message "Open header: no type found at point"))
	  ))
    )
  )
(defun eap-open-package (&optional kill-start)
  "Show file of package the current buffer class belongs to.
First look for cdl then, if failed, for definition"
  (interactive "P")
  (if (null buffer-file-name)
      (not (message "Wrong buffer type"))
    (let* ((start (eap-get-back-file))
	   (package (eap-get-package-name buffer-file-name))
	   (file (concat (eap-n-level-up buffer-file-name) package ".cdl"))
	   )
      (or (file-exists-p file)
	  (setq file (eap-find-file-with-ext package "cdl"))
	  (setq file (eap-find-source package nil))
	  )
      (if (eap-jump-plus file kill-start start)
	  (message "Ok")
	(not (message "%s.cdl not found" package)))
      ))
  )
(defun source-browse-local-key ()
  (define-key (current-local-map) [C-f4]   'eap-switch-to-inherited-declaration)
  (define-key (current-local-map) [S-f4]   'eap-switch-to-inherited-definition)
  (define-key (current-local-map) [C-f7]   'eap-switch-def-decl)
  (define-key (current-local-map) [S-f7]   'eap-switch-to-lxx)
  (define-key (current-local-map) [S-C-f2] 'eap-open-package)
  (define-key (current-local-map) [S-C-f3] 'eap-open-header)

  ;; repeat - override local bindings
  (define-key (current-local-map) [C-f2] 'eap-find-class-declaration)
  (define-key (current-local-map) [S-f2] 'eap-find-class-definition)
  (define-key (current-local-map) [C-f3] 'eap-find-method-declaration)
  (define-key (current-local-map) [S-f3] 'eap-find-method-definition)
  
  (define-key (current-local-map) [M-f4]   'eap-come-back-to-origin)
  )
(defun source-browse-key ()
  (global-set-key [C-f2] 'eap-find-class-declaration)
  (global-set-key [S-f2] 'eap-find-class-definition)
  (global-set-key [C-f3] 'eap-find-method-declaration)
  (global-set-key [S-f3] 'eap-find-method-definition)
  
  (global-set-key [C-S-f4] 'eap-complete-find-file)

  (define-key esc-map " " 'eap-prepare-to-edit)

  (add-hook 'cdl-mode-hook 'source-browse-local-key 'append)
  (add-hook 'c++-mode-hook 'source-browse-local-key 'append)
  )


(provide 'source-browse)
