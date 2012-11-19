;; definitions for the CDL mode
;; called at the first CDL mode invocation


(defun csf-cdl-mode-init ()
  (setq fill-column 70)
  (cdl-fill-mode 1)
  (abbrev-mode 1)
  (setq cdl-auto-fill-function 'csf-cdl-do-auto-fill)
  (setq auto-fill-function cdl-auto-fill-function)
(font-lock-mode 1))


(defun csf-cdl-do-auto-fill ()
  ""
  (if (cdl-in-comment)
      (progn
	(cdl-comment-do-auto-fill)
	(cdl-comment-fill nil)
	(if (eolp)
	    (insert " ")))))

;; We define here all the cdl keywords
(setq cdl-default-keywords
      '(
	"\\<\\(alias\\|any\\|as\\|class\\|deferred\\|domain\\|end\\|engine\\|enumeration\\|exception\\|executable\\|fields\\|friends\\|from\\|generic\\|immutable\\|imported\\|in\\|inherits\\|instantiates\\|interface\\|is\\|like\\|me\\|mutable\\|myclass\\|out\\|package\\|private\\|protected\\|raises\\|redefined\\|returns\\|schema\\|signature\\|static\\|uses\\|verifies\\)\\>"
	("---.*:" 0 cdl-rubrique-face t)))

(defun cdl-in-comment ())

