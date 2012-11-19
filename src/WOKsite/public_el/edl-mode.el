;;;File		:edl-mode.el
;;;Author	:Mister CSF
;;;Purpose	:
;;;History	:Wed Sep  6 13:58:12 1995	Mister CSF	Creation


(defun edl-new-file-header ()
  "Insert a header in each empty .edl buffer "
  (interactive)
  (insert   "-- File:      " (buffer-name))
  (insert "\n-- Created:   " (format-time-string "%d.%m.%y %H:%M:%S"))
  (insert "\n-- Author:    " (concat (user-login-name) "@" (system-name)))
  (insert "\n-- Copyright: Open CASCADE " (format-time-string "%Y") "\n\n")
  (let (
	(name 
	 (concat "%" (substring (buffer-name) 0 -4) "_EDL")
	 ))
    (insert "@ifnotdefined ( " name ") then\n" )
    (insert "@set " name " = \"\";\n\n"))
  (insert "--- Insert your stuff Here\n\n\n")
  (insert "@endif;\n")
  )


;; face carac for functions
;;(make-face 'edltmp-function-face)
;;(set-face-foreground 'edltmp-function-face "darkred")
;;(defvar edl-function-face 'edltmp-function-face)
(defvar edl-function-face 'font-lock-keyword-face)
;; face carac for variable
;;(make-face 'edltmp-variable-face)
;;(set-face-foreground 'edltmp-variable-face "darkgreen")
;;(defvar edl-variable-face 'edltmp-variable-face)
(defvar edl-variable-face 'font-lock-variable-name-face)
;; face carac for comment
;;(make-face 'edltmp-comment-face)
;;(set-face-foreground 'edltmp-comment-face "grey")
;;(defvar edl-comment-face 'edltmp-comment-face)
(defvar edl-comment-face 'font-lock-comment-face)
;; face carac for template clause
;;(make-face 'edltmp-template-face)
;;(set-face-foreground 'edltmp-template-face "darkblue")
;;(defvar edl-template-face 'edltmp-template-face)
(defvar edl-template-face 'font-lock-keyword-face)
;; face carac for template name
;;(make-face 'edltmp-templatename-face)
;;(set-face-foreground 'edltmp-templatename-face "red")
;;(defvar edl-templatename-face 'edltmp-templatename-face)
(defvar edl-templatename-face 'font-lock-function-name-face)
;; face carac for string clause
;;(defvar edl-string-face 'underlined)
(defvar edl-string-face 'font-lock-string-face)
;;

(setq edl-default-keywords 
      '(
;; les commandes @ puis le mot-cle
	("\\@\\(openlib\\|closelib\\|call\\|apply\\|set\\|string\\|ifdefined\\|ifnotdefined\\|if\\|endif\\|cout\\|write\\|file\\|close\\|while\\|endw\\|uses\\)" . edl-function-face)
;; les commentaires -- fin de ligne
		("--.*$" . edl-comment-face )
;; inside template  juste le $ ou @template
("\\(\\$\\|\\@template\\|\\@end;\\).*$" 1 edl-template-face )
;; le nom du template 
("\\@template[^a-z|^A-Z|^0-9^_^-]+\\([a-z|A-Z|0-9|_-]*\\)[^a-z|^A-Z|^0-9|^_^-].*$" 1 edl-templatename-face )
		("\\(\\%[a-z|A-Z|0-9_-]*\\)[^a-z|^A-Z|^0-9^_]" 1 edl-variable-face)
;; les variables % un nom puis caractere exotique  .. a verifier 
;; les string 

)
      )

(defun edl-mode ()
"This is a mode intended to support EDL documentation writing

\\{edl-mode-map}
"
  (interactive)
  (setq major-mode 'edl-mode)
  (setq mode-name "EDL")
  (setq auto-fill-hook nil)
  (setq require-final-newline t)
  (if (zerop (buffer-size)) (edl-new-file-header))
  (make-local-variable 'font-lock-mode-hook)
  (setq font-lock-mode-hook 
	'(lambda () (setq font-lock-keywords edl-default-keywords)))
  (run-hooks 'edl-mode-hook))

