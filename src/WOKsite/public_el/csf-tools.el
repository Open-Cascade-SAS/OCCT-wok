;;; csf-tools.el --- auxilary tools about CSF and woksh

;;;Author       :Edward AGAPOV <eap@opencascade.com>
;;;History	:Mon Dec 10 2001	Creation

;;; Key binding:
;;   (csf-tools-key) binds
;;   'eap-what-toolkit to M-C-t

(require 'eap-csf)

(defun eap-what-toolkit (&optional cur-word-p file-or-cls)
  "Say and copy toolkit name a current package belongs to.
Current package is either
- current-word \(if called with prefix argument) or
- package of visited file or
- package of file current in *Dired* or *Buffer List*"
  (interactive "P")
  (let* ((cur-file (or file-or-cls (eap-current-file t)))
	 (pack (if cur-word-p
		   (eap-get-package-name (eap-current-word))
		 (if cur-file (eap-get-package-name cur-file))))
	 (re (concat "^ *" pack "[ \t\n]"))
	 ref-list tk checked-tk-list msg)
    (if (null pack)
	(error "eap-what-toolkit: current package not found")
      (setq msg (message "'%s' is in toolkit... " pack))
      (eap-csf-check (if (string-match "[/\\]" (or file-or-cls "")) file-or-cls))
      (setq ref-list csf-ref-list)
      (while ref-list
	(save-excursion
	  (let* ((wb-path (cdr (car ref-list)))
		 (udlist (eap-find-file-noselect (concat wb-path "adm/UDLIST")))
		 )
	    ;;(message "%s look through '%s'" msg (car (car ref-list)))
	    (setq ref-list (cdr ref-list))
	    (while (and (set-buffer udlist)
			(re-search-forward "^[ \t]*t[ \t]\\([a-z0-9]+\\)[ \t\n\C-M]" nil t))
	      (setq tk (match-string 1))
	      (if (member tk checked-tk-list)
		  (setq tk nil)
		(save-excursion
		  (set-buffer (eap-find-file-noselect (concat wb-path "src/" tk "/PACKAGES")))
		  (or (zerop (buffer-size))
		      (add-to-list 'checked-tk-list tk))
		  (or (re-search-forward re nil t)
		      (setq tk nil))
		  (kill-this-buffer)
		  )
		(and tk
		     (goto-char (point-max));; stop toolkits iteration
		     (setq ref-list nil));; stop wb iteration
		) ;; if memeber tk checked-tk-list
	      ) ;; while more tks in UDLIST
	    (kill-buffer udlist)
	    )))
      )
    (if (interactive-p)
	(if tk
	    (message "%s %s (copied)" msg tk)
	  (message "%s Not found" msg)))
    (if tk (kill-new tk))
    tk)
  )

(defun csf-tools-key ()
  (global-set-key "\M-\C-t" 'eap-what-toolkit)
  )

(provide 'csf-tools)
