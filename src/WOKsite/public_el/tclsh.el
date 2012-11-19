;;; tclsh.el --- add tclsh command to launch TCL shell

(require 'comint)
(require 'shell)

;; This function mostly duplicates original *shell* command
(defvar tclsh-program (getenv "TCLSH_EXE")
  "*Name of program to invoke TCL shell")
(if (equal (getenv "WOKSTATION") "wnt")
  (progn 
    (setq tclsh-program "tclsh85.exe")))

(defun tclsh (&optional buffer)
  "Run TCL shell."
  (interactive
   (list
    (and current-prefix-arg
	 (read-buffer "Shell buffer: "
		      (generate-new-buffer-name "*tclsh*")))))
  (setq buffer (get-buffer-create (or buffer "*tclsh*")))
  ;; Pop to buffer, so that the buffer's window will be correctly set
  ;; when we call comint (so that comint sets the COLUMNS env var properly).
  (pop-to-buffer buffer)
  (unless (comint-check-proc buffer)
    (let* ((prog tclsh-program)
	   (name (file-name-nondirectory prog))
	   (startfile (concat "~/.emacs_" name))
	   (xargs-name (intern-soft (concat "explicit-" name "-args"))))
      (unless (file-exists-p startfile)
	(setq startfile (concat "~/.emacs.d/init_" name ".sh")))
      (apply 'make-comint-in-buffer "tclsh" buffer prog
	     (if (file-exists-p startfile) startfile)
	     (if (and xargs-name (boundp xargs-name))
		 (symbol-value xargs-name)
	       '("-i")))

      ;; workaround concerning unproper work of tclsh under Emacs on Windows
      (if (equal (getenv "WOKSTATION") "wnt")
      (progn 
        (insert 
           (concat "source \"" (getenv "WOKHOME") "/site/interp.tcl\""))
        (comint-send-input)))

      (shell-mode)))
  buffer)
