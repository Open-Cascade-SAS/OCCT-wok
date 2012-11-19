;;; inheritance.el --- show inheritance of classes contained in CSF as a tree

;;;Author  : Edward AGAPOV  <eap@opencascade.com>
;;;History : Mon Dec 21 1998       Creation

;;; Comment

;;; Mode entry: inh-show-inheritance

;;; Key binding:
;;   (inheritance-key) binds
;;   'inh-show-inheritance to M-f7
;;   'inh-show-buffer      to C-a C-i

(require 'type-search)
(require 'tree)

(defconst inh-buffer-name "*inheritance*"
  )
(defvar inh-info-buffer-list nil
  "List of buffers containing inheritance info.
Each member corresponds to csf-ref-list member and looks like
\(buffer . wb-path)"
  )
(defvar inh-info-path nil
  "Path to inheritance info files"
  )
(defun inh-show-inheritance (of-current)
  "Show tree of class inheritance.
Of current buffer class \(with prefix argument) or class at point.
See mode description for keybindings on tree management.
Type \\[inh-show-buffer] to find '*inheritance*' buffer quickly.

Be patient calling this command for the first time for a current workbench,
building info files for all reference workbenches can take a few minutes:
for ex. 15 min on SUN Ultra 10 \(300MHz 256Mb)"
  (interactive "P")
  (message "inh-show-inheritance: look for current class")
  (let* ((start (eap-get-back-file))
	 (type (if of-current
		   (eap-class-name)
		 (eap-current-type)))
	 )
    (if (null type)
	(error "inh-show-inheritance: no type found")
      (setq inh-info-path (eap-check-tmp-path))
      (inh-buf-list-check)
      (if (null (or (inh-has-descendants type)
		    (inh-get-ansestor type)
		    ))
	  (message "'%s' has neither ansestor nor descendants" type)
	(and (not (string-match "#$" type))
	     (eap-find-file-with-ext type "gxx" 'any)
	     (setq type (concat type "#")))
	(tree-build-tree type (inh-mode))
	(eap-save-back-file start)
	)))
  )
(defun inh-mode ()
  "Show inheritance of classes contained in CSF as a tree
Generic classes have '#' mark, their instantiations are shown like inheritance.
'+' before or after class means that this class has not shown ansestor or
descendants respectively.
'-' before or after class means that ansestor or all descendants respectively
of this class are shown.
Absence of '-' or '+' before or after class means that this class has not
ansestor or descendants respectively.

Keybindings:

\\{tree-mode-map}"
  (let ((buf (get-buffer-create inh-buffer-name)))
    (set-buffer buf)
    (if (eq major-mode 'inh-mode)
	nil
      (setq tree-get-ansestor 'inh-get-ansestor
	    tree-has-descendants 'inh-has-descendants
	    tree-get-descendants-list 'inh-get-descendants-list
	    tree-level-width 4)
      (setq major-mode 'inh-mode
	    mode-name "Inheritance")
      )
    buf)
  )
(defun inh-get-ansestor (cls)
  (let ((buf-list inh-info-buffer-list)
	ans)
    (save-excursion
      (while (and (null ans) buf-list)
	(set-buffer (car (car buf-list)))
	(if (inh-find-class cls nil)
	    (setq ans (inh-cur-ansestor))
	  (setq buf-list (cdr buf-list)))
	))
    ans)
  )
(defun inh-has-descendants (cls)
  (let ((buf-list inh-info-buffer-list)
	has-p)
    (save-excursion
      (while (and (not has-p) buf-list)
	(set-buffer (car (car buf-list)))
	(setq has-p (inh-find-class cls 'inherited))
	(setq buf-list (cdr buf-list)))
      has-p))
  )
(defun inh-get-descendants-list (cls)
  (let ((buf-list inh-info-buffer-list)
	des-list)
    ;;(message "Find descendants of '%s'... " cls)
    (save-excursion
      (while buf-list
	(set-buffer (car (car buf-list)))
	(if (inh-find-class cls 'inherited)
	    (setq des-list (append des-list
				   (inh-cur-des-list des-list)))
	  )
	(setq buf-list (cdr buf-list))
	))
    ;;(message nil)
    des-list)
  )
(defvar inh-gen-des-list nil
  "List of classes whose ansestor is generic descendant of non-generic class.
Such classes are found twice, this list allow treating them only once"
  )
(defun inh-buf-list-check ()
  (if (and (member (eap-wb-path) (mapcar 'cdr inh-info-buffer-list))
	   (get-buffer inh-buffer-name))
      'ok
    ;; kill existing info buffers
    (mapcar 'kill-buffer (mapcar 'car inh-info-buffer-list))
    (setq inh-info-buffer-list nil)
    ;; make info buffer list
    (let* ((ref-list csf-ref-list)
	   wb-name-path name)
      (while ref-list
	(setq wb-name-path (car ref-list)
	      ref-list (cdr ref-list)
	      name (car wb-name-path))
	(or (inh-find-info-file name (cdr wb-name-path))
	    (if (inh-build-info-file name)
		(inh-find-info-file name (cdr wb-name-path))))
	(setq inh-gen-des-list nil)
	)
      ))
  )
(defun inh-find-info-file (wb-name wb-path)
  (let ((file (inh-info-file-name wb-name)) buf)
    (and (file-exists-p file)
	 (if (or (eap-file-newer-p (concat  wb-path "inc") file)
		 (eap-file-newer-p (concat  wb-path "drv") file))
	     (not (y-or-n-p (format "Update inheritance info file of '%s' " wb-name)))
	   t)
	 (set-buffer (setq buf (eap-find-file-noselect file)))
	 (rename-buffer (concat " " (buffer-name)));; hide buffer
	 (setq inh-info-buffer-list (cons (cons buf wb-path) inh-info-buffer-list))
	 ))
  )
(defun inh-info-file-name (wb-name)
  (concat inh-info-path wb-name "_inheritance_info")
  )
(defun inh-build-info-file (wb-name)
  (let* ((inc-dir (eap-wb-path "inc" wb-name))
	 (headers (eap-directory-files inc-dir nil "hxx$" 'no-sort "Get headers from"))
	 (msg (format "Build 'inheritance_info' file for '%s':" wb-name))
	 (cur-nb 1) max-nb
	 (generic-p t) ;; just for debugging
	 info-buf buf packages)
    (set-buffer (setq info-buf (eap-find-file-noselect
				(inh-info-file-name wb-name))))
    (erase-buffer)
    (if generic-p
	;; get all cdl packages
	(progn 
	  (setq buf (eap-find-file-noselect
		     (concat (eap-wb-path "adm" wb-name) "UDLIST")))
	  (set-buffer buf)
	  (while (re-search-forward "p[ \t]+\\([^ \t\n]+\\)" nil t)
	    (setq packages (cons (match-string 1) packages)))
	  (kill-buffer buf)
	  ))
    (setq max-nb (+ (length packages) (length headers)))
    ;; fill inheritance file
    ;; 1. generics
    (let ((drv-dir (eap-wb-path "drv" wb-name))
	  pack-dir files)
      (while packages
	(setq pack-dir (concat drv-dir (car packages) "/"))
	(setq packages (cdr packages))
	(setq cur-nb (1+ cur-nb))
	(and (file-exists-p pack-dir)
	     (setq files (directory-files pack-dir nil "_0[.]cxx$" 'no-sort))
	     (while files
	       (setq buf (eap-find-file-noselect (concat pack-dir (car files))))
	       (inh-fill-info-buf info-buf buf (car files) cur-nb max-nb msg 'generic)
	       (setq files (cdr files))
	       (kill-buffer buf)
	       )))
      )
    ;; 2. real inheritance
    (while headers
      (setq buf (eap-find-file-noselect (concat inc-dir (car headers))))
      (inh-fill-info-buf info-buf buf (car headers) cur-nb max-nb msg)
      (setq headers (cdr headers))
      (setq cur-nb (1+ cur-nb))
      (kill-buffer buf)
      )
    (message "%s ... Done" msg)
    ;; sort info
    (set-buffer info-buf)
    (sort-lines nil 1 (point-max))
    ;; save & kill
    (or (buffer-modified-p)
	(set-buffer-modified-p t))
    (let (err)
      (condition-case err
	  (progn
	    (save-buffer 0)
	    (set-file-modes buffer-file-name 511)
	    )
	(error (message "inh-build-info-file: %s" err) (sit-for 1))
	))
    (kill-this-buffer)
    )
  )
(defun inh-fill-info-buf (info-buf buf file-name cur-nb max-nb msg &optional generic-p)
  (set-buffer buf)
  ;; get inherited
  (let* ((inherited (if (not generic-p)
			(eap-pearent-from-hxx)
		      (goto-char (point-max))
		      (if (re-search-backward "^#include <\\([^.]+\\)[.]gxx>" nil t)
			  (match-string 1))))
	 (cls (if inherited (eap-class-name file-name)))
	 )
    (eap-progress-indicator cur-nb max-nb msg)
    ;; insert in info buffer
    (if (or (null inherited)
	    (and (not generic-p)
		 (member cls inh-gen-des-list)))
	nil
      (set-buffer info-buf)
      ;; check if cls already has generic ansestor
      (and (not generic-p)
	   (inh-find-class cls (not 'ancestor))
	   (let ((gen-ans (inh-cur-ansestor)))
	     ;; check that not same inheritance is found twice
	     (and (inh-generic-found)
		  (not (string= gen-ans (concat inherited "#")))
		  (setq cls gen-ans
			inh-gen-des-list (append (inh-cur-des-list) inh-gen-des-list)))
	     ))
      (if (not (inh-find-class inherited 'inherited))
	  ;; insert new
	  (progn (beginning-of-line)
		 (inh-insert inherited generic-p " ( " cls " )\n"))
	;; add to existing descendant list
	(inh-goto-cur-des)
	(inh-insert cls nil " ")
	))
    ))
(defun inh-find-class (class inherited-p)
  (let ((re (concat (if inherited-p "^" " ") class "[ #]"))
	(search-funs '(re-search-backward . re-search-forward)))
    (if (and inherited-p
	     (> (buffer-size) 10000))
	;; choose direction to search, inherited are sorted
	(let ((cur-inh (progn (beginning-of-line) (current-word))))
	  (if (string< cur-inh class)
	      (setq search-funs '(re-search-forward . re-search-backward)))
	  (if (bobp)
	      (end-of-line)
	    (forward-char -1))
	  )
      )
    (or (funcall (car search-funs) re nil t)
	(funcall (cdr search-funs) re nil t)
	))
  )
(defun inh-cur-ansestor (&optional kill-p)
  (beginning-of-line)
  (if (looking-at "[^ ]+")
      (prog1 (match-string 0)
	(if kill-p (delete-region (match-beginning 0) (match-end 0)))
	))
  )
(defun inh-generic-found ()
  (let ((found (match-string 0)))
    (= ?# (aref found (1- (length found)))))
  )
(defun inh-goto-cur-des ()
  (beginning-of-line)
  (re-search-forward "( " nil t)
  )
(defun inh-cur-des-list (&optional avoid-list)
  (let (des-list des)
    (inh-goto-cur-des)
    (while (looking-at "[^ )]+")
      (or (member (setq des (match-string 0)) avoid-list)
	  (setq des-list (cons des des-list)))
      (goto-char (match-end 0))
      (skip-chars-forward " ")
      )
    des-list)
  )
(defun inh-insert (cls generic-p &rest args-to-insert)
  (insert cls (if generic-p "#" ""))
  (if args-to-insert (apply 'insert args-to-insert))
  )

  
(defun inh-show-buffer ()
  (interactive)
  (let* ((buf (get-buffer inh-buffer-name)))
    (if buf (pop-to-buffer buf)
      (message "Buffer %s doesn't exist" inh-buffer-name))))

(defun inheritance-key ()
  (define-key (eap-buf-mgt-map) "\C-i"  'inh-show-buffer)
  (global-set-key [M-f7]              'inh-show-inheritance)
  )

(mapcar 'kill-buffer (mapcar 'car inh-info-buffer-list))
(setq inh-info-buffer-list nil)
;; (dired inh-info-path)

(provide 'inheritance)
