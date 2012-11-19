;; 
;; definitions for c++-mode, loaded at first c++-mode invocation

(load-library "c++-mode")

;; hook to insert header in new C++ file
(defun csf-c++-mode-init ()
	 (abbrev-mode 1)
	 (if (zerop (buffer-size))	; insert in new files
	     (c++-file-header))
	 (setq font-lock-maximum-decoration 2)
	 (font-lock-mode 1))


;; keys
; \M-i insert #include
(define-key c++-mode-map "\M-I" "#include <>") 
; \M-I add include file
(define-key c++-mode-map "\M-i" 'c++-add-include)
; \M-= insert function header
(define-key c++-mode-map "\M-=" 'c++-function-header)  
; \M-h put "Handle()" around the current symbol
(define-key c++-mode-map "\M-h" 'c++-handlify)  
; \M-s frame a comment block
(define-key c++-mode-map "\M-s" 'c++-frame-comments)
; \M-m insert a modified comment
(define-key c++-mode-map "\M-m" 'c++-modif)
; \M-c turn a header to an implemantation
(define-key c++-mode-map "\M-c" 'c++-header-to-code)
; \M-e insert an exception raise
(define-key c++-mode-map "\M-e" 'c++-raise)
; \M-g complete a set or get filed method
;(define-key c++-mode-map "\M-g" 'c++-getorset)
; \M-H insert C++ Header 
(define-key c++-mode-map "\M-H" 'c++-file-header)



(defun c++-file-header ()
  "insert a header at beginnig of buffer"
  (interactive)
  (beginning-of-buffer)
  (insert "// File:\t" (buffer-name))
  (insert "\n// Created:\t" (current-time-string))
  (insert "\n// Author:\t" (user-full-name))
  (insert "\n//\t\t<" (user-login-name) "@" (system-name)">\n")
  ;; different headers for .hxx files
  (cond
   ((string-match "\\.hxx$" (buffer-name))
    (let (
	  (name 
	   (concat (substring (buffer-name) 0 -4) "_HeaderFile")
	   ))
      (insert "\n\n#ifndef " name)
      (insert "\n#define " name)
      (insert "\n\n\n\n#endif")))
   
   ((string-match "\\.cxx$" (buffer-name))
    (insert "\n\n#include <"
	    (substring (buffer-name) 0 -4)
	    ".ixx>\n"))
   ))

(defun c++-function-header ()
  "insert a header comment for the c++ function on the current line"
  (interactive)
  (beginning-of-line)
  (if (looking-at ".*::\\([^ (]*\\)")
      (let (p (name (buffer-substring (match-beginning 1) (match-end 1))))
	(insert "//=======================================================================")
	(insert "\n//function : " name)
	(insert "\n//purpose  : " ) (setq p (point))
	(insert "\n//=======================================================================\n\n")
	(goto-char p)
)))

(defun c++-handlify ()
  "insert the string handle before and two () around the symbol under the point"
  (interactive)
  (if (eq (point) (point-max)) () (forward-char 1))
  (forward-word -1) 
  (while (eq 95 (char-after (1- (point)))) (forward-word -1))
  (insert "Handle(")
  (forward-word 1)
  (while  (eq 95 (char-after (point))) (forward-word 1))
  (insert ")"))

(defun c++-frame-comments ()
  "Add a line of stars before and after a block of comments"
  (interactive)
  (save-excursion
    ;; are we in a block of comments ?
    (beginning-of-line)
    (if (looking-at "[\t ]*//")
	(progn
	  (while (and (looking-at "[\t ]*//") (not (eq (point) 1)))
	    (forward-line -1))
	  (end-of-line) (insert "\n// ")
	  (c++-indent-line)
	  (while (not (eq (current-column) fill-column)) (insert "*"))
	  (forward-line 1)
	  (while (looking-at "[\t ]*//")
	    (forward-line 1))
	  (if (not (eq (point) (point-max)))(backward-char 1))
	  (insert "\n// ")
	  (c++-indent-line)
	  (while (not (eq (current-column) fill-column)) (insert "*"))
	  ))))
	  

;; add a modified entry at the beginning of the file
(defun c++-modif ()
  "Add a modification comment line after the header of the file"
  (interactive)
  (save-excursion
    (beginning-of-buffer)
    (while (looking-at "^//") (forward-line 1))
    (insert "// Modified by " (user-login-name) ", " (current-time-string) "\n"
	    )))

;;
(defun c++-header-to-code ()
  "Assume that the current line is a method declaration coming from a .hxx and turn it into an implementation"
  (interactive)
  (beginning-of-line)
  (let ((constructor (looking-at (substring (buffer-name) 0 -4)))
	(pos))
    (if (not constructor) (search-forward " "))
    (insert (buffer-name))
    (delete-backward-char 4)
    (insert "::")
    (c++-function-header)
    (forward-line 3)
    (beginning-of-line)
    (setq pos (point))
    (end-of-line)
    (while (search-backward "Handle_" pos t)
      (forward-char 6)
      (delete-char 1)
      (insert "(")
      (forward-word 1) (while (looking-at "_") (forward-word 1))
      (insert ")"))
    (end-of-line)
    (delete-backward-char 1)
    (c++-indent-command)
    (end-of-line)
    (if constructor (insert " :"))
    (newline) (insert "{") (newline) (insert "}") (newline) (newline)
    (forward-line))
)

(defun c++-raise (Exception Package)
  "Insert an exception raise call."
  (interactive "sException : \nsPackage (Standard) : ")
  (if (equal Package "") (setq Package "Standard"))
  (let (p Method)
    (save-excursion
      (if (beginning-of-defun)
	  (progn
	    (forward-line -1)
	    (beginning-of-line)
	    (setq Method (buffer-substring (progn
					     (search-forward "::")
					     (forward-word -1)
					     (forward-char -1)
					     (if (looking-at "_")
						 (forward-word -1)
					       (forward-char 1))
					     (point))
					   (progn
					     (search-forward "(")
					     (forward-char -1)
					     (point)))))))
    (if Method
	(progn
	  (insert "\t" Package "_" Exception "_Raise_if(,")
	  (setq p (point))
	  (insert "\"" Method "\");")
	  (c++-indent-line)
	  (goto-char p)))))


(defun c++-getorset ()
  "Fill the current method as a set or get field method"
  (interactive)
  (let (linestart isget fieldname argname)
    (beginning-of-line)
    (setq startline (point))
    ;; test if it the line ends with const
    (end-of-line)
    (forward-word -1)
    (setq isget (looking-at "const"))
    (search-backward "::" startline t)
    (forward-char 2)
    (setq fieldname (buffer-substring (point) 
				      (progn (forward-word 1) (point))))
    (if (not isget)
	(progn (end-of-line)
	       (search-backward ")")
	       (forward-word -1)
	       (setq argname (buffer-substring 
			      (point) 
			      (progn (forward-word 1) (point))))))
    (forward-line 1)
    (end-of-line)
    (insert "\n")
    (c++-indent-line)
    (if isget (insert "return "))
    (insert "my" fieldname)
    (if (not isget) (insert " = " argname))
    (insert ";")
    ))






(defun c++-find-include ()
  "Find the cdl file of the class near point in other window."
  (interactive)
  (let (class package)
    (save-excursion
      (if (eq (point) (point-max)) () (forward-char 1))
      (forward-word -1)
      (while (eq 95 (char-after (1- (point)))) (forward-word -1))
      (if (looking-at "\\(\\w+\\)_\\(\\w+\\)")
	  (setq
	   package (buffer-substring (match-beginning 1) (match-end 1))
	   class (buffer-substring (match-beginning 2)   (match-end 2)))
	(forward-char 1)
	(forward-word -1)
	(setq pos (point))
	(forward-word 1)
	(setq package (buffer-substring pos (point)))))

    (if class (setq class (concat package "_" class))
      (setq class package))))



(defun c++-add-include ()
  (interactive)
  (let (class)
    (save-excursion
      (setq class (c++-find-include))
      (search-backward-regexp "^#include")
      (next-line 1)
      (insert (concat "#include <" class ".hxx>\n"))
      (princ (concat "Insertion: #include <" class ".hxx> done.")))))

