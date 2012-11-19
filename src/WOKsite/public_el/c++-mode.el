;; C++ code editing commands for Emacs
;; based on C mode
;; by Remi Lequette @ MDTV
;;
;; requires the C mode which is always loaded

(load-library "cc-mode")

(defvar c++-mode-abbrev-table nil
  "Abbrev table in use in C++-mode buffers.")
(define-abbrev-table 'c++-mode-abbrev-table ())

(defvar c++-mode-map ()
  "Keymap used in C++ mode.")
;; this keymap is a copy of the C keymap
(if c++-mode-map
    ()
  (setq c++-mode-map (copy-keymap c-mode-map)))
(define-key c++-mode-map "{" 'electric-c++-brace)
(define-key c++-mode-map "}" 'electric-c++-brace)
(define-key c++-mode-map ";" 'electric-c++-semi)
(define-key c++-mode-map ":" 'electric-c++-terminator)
(define-key c++-mode-map "\e\C-q" 'indent-c++-exp)
(define-key c++-mode-map "\t"     'c++-indent-command)
(define-key c++-mode-map "\M-k"   'c++-find-class)
(define-key c++-mode-map "\M-l"   'c++-find-c++)


(defvar c++-mode-syntax-table nil
  "Syntax table in use in C++-mode buffers.")

;; it is the C syntax table 
(if c++-mode-syntax-table
    ()
  (setq c++-mode-syntax-table c-mode-syntax-table)
)

(defun c++-mode ()
  "Major mode for editing C++ code.
Expression and list commands understand all C brackets.
Tab indents for C code.
Comments are delimited with /* ... */. or // and newline
Created comments starts with //.
Paragraphs are separated by blank lines only.
Delete converts tabs to spaces as it moves back.
\\{c++-mode-map}
Variables controlling indentation style (like C)
 c-tab-always-indent
    Non-nil means TAB in C mode should always reindent the current line,
    regardless of where in the line point is when the TAB command is used.
 c-auto-newline
    Non-nil means automatically newline before and after braces,
    and after colons and semicolons, inserted in C code.
 c-indent-level
    Indentation of C statements within surrounding block.
    The surrounding block's indentation is the indentation
    of the line on which the open-brace appears.
 c-continued-statement-offset
    Extra indentation given to a substatement, such as the
    then-clause of an if or body of a while.
 c-continued-brace-offset
    Extra indentation given to a brace that starts a substatement.
    This is in addition to c-continued-statement-offset.
 c-brace-offset
    Extra indentation for line if it starts with an open brace.
 c-brace-imaginary-offset
    An open brace following other text is treated as if it were
    this far to the right of the start of its line.
 c-argdecl-indent
    Indentation level of declarations of C function arguments.
 c-label-offset
    Extra indentation for line that is a label, or case or default.

Settings for K&R and BSD indentation styles are
  c-indent-level                5    8
  c-continued-statement-offset  5    8
  c-brace-offset               -5   -8
  c-argdecl-indent              0    8
  c-label-offset               -5   -8

Turning on C++ mode calls the value of the variable c++-mode-hook with no args,
if that value is non-nil."
  (interactive)
  (kill-all-local-variables)
  (use-local-map c++-mode-map)
  (setq major-mode 'c++-mode)
  (setq mode-name "C++")
  (setq local-abbrev-table c++-mode-abbrev-table)
  (set-syntax-table c++-mode-syntax-table)
  (make-local-variable 'paragraph-start)
  (setq paragraph-start (concat "^$\\|" page-delimiter))
  (make-local-variable 'paragraph-separate)
  (setq paragraph-separate paragraph-start)
  (make-local-variable 'paragraph-ignore-fill-prefix)
  (setq paragraph-ignore-fill-prefix t)
  (make-local-variable 'indent-line-function)
  (setq indent-line-function 'c-indent-line)
  (make-local-variable 'require-final-newline)
  (setq require-final-newline t)
  (make-local-variable 'comment-start)
  (setq comment-start "// ")
  (make-local-variable 'comment-end)
  (setq comment-end "")
  (make-local-variable 'comment-column)
  (setq comment-column 32)
  (make-local-variable 'comment-start-skip)
  ;; beginning of comment is either two or more / then spaces
  ;; or / then one or more * then spaces
  (setq comment-start-skip "/[/*]+ *")
  (make-local-variable 'comment-indent-hook)
  (setq comment-indent-hook 'c++-comment-indent)
  (make-local-variable 'parse-sexp-ignore-comments)
  (setq parse-sexp-ignore-comments t)
  (run-hooks 'c++-mode-hook))

;; This is used by indent-for-comment
;; to decide how much to indent a comment in C++ code
;; based on its context.
(defun c++-comment-indent ()
  (if
      (looking-at "^/\\*\\|^//\\|^$")
      0				;Existing comment at bol stays there.
    ;; if comment preceded by spaces or tabs, indent as code
    (if
	(save-excursion
	  (beginning-of-line)
	  (looking-at "[ \t]+\\(/\\*\\|//\\|$\\)"))
	(calculate-c-indent)
      (save-excursion
	(skip-chars-backward " \t")
	(max (1+ (current-column))	;Else indent at comment column
	     comment-column)))))	; except leave at least one space.


(defun electric-c++-brace (arg)
  "Insert character and correct line's indentation."
  (interactive "P")
  (let (insertpos)
    (if (and (not arg)
	     (eolp)
	     (or (save-excursion
		   (skip-chars-backward " \t")
		   (bolp))
		 (if c-auto-newline (progn (c++-indent-line) (newline) t) nil)))
	(progn
	  (insert last-command-char)
	  (c++-indent-line)
	  (if c-auto-newline
	      (progn
		(newline)
		;; (newline) may have done auto-fill
		(setq insertpos (- (point) 2))
		(c++-indent-line)))
	  (save-excursion
	    (if insertpos (goto-char (1+ insertpos)))
	    (delete-char -1))))
    (if insertpos
	(save-excursion
	  (goto-char insertpos)
	  (self-insert-command (prefix-numeric-value arg)))
      (self-insert-command (prefix-numeric-value arg)))))

(defun electric-c++-semi (arg)
  "Insert character and correct line's indentation."
  (interactive "P")
  (if c-auto-newline
      (electric-c++-terminator arg)
    (self-insert-command (prefix-numeric-value arg))))

(defun electric-c++-terminator (arg)
  "Insert character and correct line's indentation."
  (interactive "P")
  (let (insertpos (end (point)))
    (if (and (not arg) (eolp)
	     (not (save-excursion
		    (beginning-of-line)
		    (skip-chars-forward " \t")
		    (or (= (following-char) ?#)
			;; Colon is special only after a label, or case ....
			;; So quickly rule out most other uses of colon
			;; and do no indentation for them.
			(and (eq last-command-char ?:)
			     (not (looking-at "case[ \t]"))
			     (save-excursion
			       (forward-word 1)
			       (skip-chars-forward " \t")
			       (< (point) end)))
			(progn
			  (beginning-of-defun)
			  (let ((pps (parse-partial-sexp (point) end)))
			    (or (nth 3 pps) (nth 4 pps) (nth 5 pps))))))))
	(progn
	  (insert last-command-char)
	  (c++-indent-line)
	  (and c-auto-newline
	       (not (c-inside-parens-p))
	       (progn
		 (newline)
		 (setq insertpos (- (point) 2))
		 (c++-indent-line)))
	  (save-excursion
	    (if insertpos (goto-char (1+ insertpos)))
	    (delete-char -1))))
    (if insertpos
	(save-excursion
	  (goto-char insertpos)
	  (self-insert-command (prefix-numeric-value arg)))
      (self-insert-command (prefix-numeric-value arg)))))


(defun c++-indent-command (&optional whole-exp)
  (interactive "P")
  "Indent current line as C++ code, or in some cases insert a tab character.
If c-tab-always-indent is non-nil (the default), always indent current line.
Otherwise, indent the current line only if point is at the left margin
or in the line's indentation; otherwise insert a tab.

A numeric argument, regardless of its value,
means indent rigidly all the lines of the expression starting after point
so that this line becomes properly indented.
The relative indentation among the lines of the expression are preserved."
  (if whole-exp
      ;; If arg, always indent this line as C++
      ;; and shift remaining lines of expression the same amount.
      (let ((shift-amt (c++-indent-line))
	    beg end)
	(save-excursion
	  (if c-tab-always-indent
	      (beginning-of-line))
	  (setq beg (point))
	  (forward-sexp 1)
	  (setq end (point))
	  (goto-char beg)
	  (forward-line 1)
	  (setq beg (point)))
	(if (> end beg)
	    (indent-code-rigidly beg end shift-amt "#")))
    (if (and (not c-tab-always-indent)
	     (save-excursion
	       (skip-chars-backward " \t")
	       (not (bolp))))
	(insert-tab)
      (c++-indent-line))))

(defun c++-indent-line ()
  "Indent current line as C++ code.
Return the amount the indentation changed by."
  (let ((indent (calculate-c++-indent nil))
	beg shift-amt
	(case-fold-search nil)
	(pos (- (point-max) (point))))
    (beginning-of-line)
    (setq beg (point))
    (cond ((eq indent nil)
	   (setq indent (current-indentation)))
	  ((eq indent t)
	   (setq indent (calculate-c-indent-within-comment)))
	  ((looking-at "[ \t]*#")
	   (setq indent 0))
	  (t
	   (skip-chars-forward " \t")
	   (if (listp indent) (setq indent (car indent)))
	   (cond ((or (looking-at "case[ \t]")
		      (and (looking-at "[A-Za-z]")
			   (save-excursion
			     (forward-sexp 1)
			     (looking-at ":[^:]"))))
		  (setq indent (max 1 (+ indent c-label-offset))))
		 ((and (looking-at "else\\b")
		       (not (looking-at "else\\s_")))
		  (setq indent (save-excursion
				 (c-backward-to-start-of-if)
				 (current-indentation))))
		 ((= (following-char) ?})
		  (setq indent (- indent c-indent-level)))
		 ((= (following-char) ?{)
		  (setq indent (+ indent c-brace-offset))))))
    (skip-chars-forward " \t")
    (setq shift-amt (- indent (current-column)))
    (if (zerop shift-amt)
	(if (> (- (point-max) pos) (point))
	    (goto-char (- (point-max) pos)))
      (delete-region beg (point))
      (indent-to indent)
      ;; If initial point was within line's indentation,
      ;; position after the indentation.  Else stay at same point in text.
      (if (> (- (point-max) pos) (point))
	  (goto-char (- (point-max) pos))))
    shift-amt))

(defun calculate-c++-indent (&optional parse-start)
  "Return appropriate indentation for current line as C++ code.
In usual case returns an integer: the column to indent to.
Returns nil if line starts inside a string, t if in a comment."
  (save-excursion
    (beginning-of-line)
    (let ((indent-point (point))
	  (case-fold-search nil)
	  state
	  containing-sexp)
      (if parse-start
	  (goto-char parse-start)
	(beginning-of-defun))
      (while (< (point) indent-point)
	(setq parse-start (point))
	(setq state (parse-partial-sexp (point) indent-point 0))
	(setq containing-sexp (car (cdr state))))
      (cond ((or (nth 3 state) (nth 4 state))
	     ;; return nil or t if should not change this line
	     (nth 4 state))
	    ((null containing-sexp)
	     ;; Line is at top level.  May be data or function definition,
	     ;; or may be function argument declaration.
	     ;; Indent like the previous top level line
	     ;; unless that ends in a closeparen without semicolon,
	     ;; in which case this line is the first argument decl.
	     (goto-char indent-point)
	     (skip-chars-forward " \t")
	     (if (= (following-char) ?{)
		 0   ; Unless it starts a function body
	       (c++-backward-to-noncomment (or parse-start (point-min)))
	       ;; Look at previous line that's at column 0
	       ;; to determine whether we are in top-level decls
	       ;; or function's arg decls.  Set basic-indent accordinglu.
	       (let ((basic-indent
		      (save-excursion
			(re-search-backward "^[^ \^L\t\n#]" nil 'move)
			(if (and (looking-at "\\sw\\|\\s_")
				 (looking-at ".*(")
				 (progn
				   (goto-char (1- (match-end 0)))
				   (forward-sexp 1)
				   (and (< (point) indent-point)
					(not (memq (following-char)
						   '(?\, ?\;))))))
			    c-argdecl-indent 0))))
		 ;; Now add a little if this is a continuation line.
		 (+ basic-indent (if (or (bobp)
					 (memq (preceding-char) '(?\) ?\; ?\})))
				     0 c-continued-statement-offset)))))
	    ((/= (char-after containing-sexp) ?{)
	     ;; line is expression, not statement:
	     ;; indent to just after the surrounding open.
	     (goto-char (1+ containing-sexp))
	     (current-column))
	    (t
	     ;; Statement level.  Is it a continuation or a new statement?
	     ;; Find previous non-comment character.
	     (goto-char indent-point)
	     (c++-backward-to-noncomment containing-sexp)
	     ;; Back up over label lines, since they don't
	     ;; affect whether our line is a continuation.
	     (while (or (eq (preceding-char) ?\,)
			(and (eq (preceding-char) ?:)
			     (or (eq (char-after (- (point) 2)) ?\')
				 (memq (char-syntax (char-after (- (point) 2)))
				       '(?w ?_)))))
	       (if (eq (preceding-char) ?\,)
		   (c-backward-to-start-of-continued-exp containing-sexp))
	       (beginning-of-line)
	       (c++-backward-to-noncomment containing-sexp))
	     ;; Now we get the answer.
	     (if (not (memq (preceding-char) '(nil ?\, ?\; ?\} ?\{)))
		 ;; This line is continuation of preceding line's statement;
		 ;; indent  c-continued-statement-offset  more than the
		 ;; previous line of the statement.
		 (progn
		   (c-backward-to-start-of-continued-exp containing-sexp)
		   (+ c-continued-statement-offset (current-column)
		      (if (save-excursion (goto-char indent-point)
					  (skip-chars-forward " \t")
					  (eq (following-char) ?{))
			  c-continued-brace-offset 0)))
	       ;; This line starts a new statement.
	       ;; Position following last unclosed open.
	       (goto-char containing-sexp)
	       ;; Is line first statement after an open-brace?
	       (or
		 ;; If no, find that first statement and indent like it.
		 (save-excursion
		   (forward-char 1)
		   (let ((colon-line-end 0))
		     (while (progn (skip-chars-forward " \t\n")
				   (looking-at "#\\|/\\*\\|case[ \t\n].*:\\|[a-zA-Z0-9_$]*:\\|//"))
		       ;; Skip over comments and labels following openbrace.
		       (cond ((= (following-char) ?\#)
			      (forward-line 1))
			     ((looking-at "/\\*")
			      (forward-char 2)
			      (search-forward "*/" nil 'move))
			     ((looking-at "//")
			      (end-of-line))
			     ;; case or label:
			     (t
			      (save-excursion (end-of-line)
					      (setq colon-line-end (point)))
			      (search-forward ":"))))
		     ;; The first following code counts
		     ;; if it is before the line we want to indent.
		     (and (< (point) indent-point)
			  (if (> colon-line-end (point))
			      (- (current-indentation) c-label-offset)
			    (current-column)))))
		 ;; If no previous statement,
		 ;; indent it relative to line brace is on.
		 ;; For open brace in column zero, don't let statement
		 ;; start there too.  If c-indent-level is zero,
		 ;; use c-brace-offset + c-continued-statement-offset instead.
		 ;; For open-braces not the first thing in a line,
		 ;; add in c-brace-imaginary-offset.
		 (+ (if (and (bolp) (zerop c-indent-level))
			(+ c-brace-offset c-continued-statement-offset)
		      c-indent-level)
		    ;; Move back over whitespace before the openbrace.
		    ;; If openbrace is not first nonwhite thing on the line,
		    ;; add the c-brace-imaginary-offset.
		    (progn (skip-chars-backward " \t")
			   (if (bolp) 0 c-brace-imaginary-offset))
		    ;; If the openbrace is preceded by a parenthesized exp,
		    ;; move to the beginning of that;
		    ;; possibly a different line
		    (progn
		      (if (eq (preceding-char) ?\))
			  (forward-sexp -1))
		      ;; Get initial indentation of the line we are on.
		      (current-indentation))))))))))


(defun c++-backward-to-noncomment (lim)
  (let (opoint stop)
    (while (not stop)
      (skip-chars-backward " \t\n\f" lim)
      (setq opoint (point))
      (cond
       ((and (>= (point) (+ 2 lim))
	     (save-excursion
	       (forward-char -2)
	       (looking-at "\\*/")))
	(search-backward "/*" lim 'move))
       ((search-backward "//"
			 (max lim (save-excursion
				    (beginning-of-line)
				    (point))) 
			 t))
       (t
	(beginning-of-line)
	(skip-chars-forward " \t")
	(setq stop (or (not (looking-at "#")) (<= (point) lim)))
	(if stop (goto-char opoint)
	  (beginning-of-line)))))))



;; to find class in the buffer

(defun c++-find-class ()
  "Find the cdl file for the class in the buffer at current point"
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
	  (if (looking-at "\\(\\w+\\)")
	      (setq package (buffer-substring (match-beginning 1) (match-end 1))))))
    (if class
	(set-buffer (find-file 
		     (car (wok-command (format "woklocate -p %s:source:%s_%s.cdl\n" package package class))))) 
      (set-buffer (find-file 
		   (car (wok-command (format "woklocate -p %s:source:%s.cdl\n" package package))))))))

(defun c++-find-c++ ()
  "Find the c++ file for the class in the buffer at current point"
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
	  (if (looking-at "\\(\\w+\\)")
	      (setq package (buffer-substring (match-beginning 1) (match-end 1))))))
    (if class
	(set-buffer (find-file 
		     (car (wok-command (format "woklocate -p %s:source:%s_%s.cxx\n" package package class))))) 
      (set-buffer (find-file 
		   (car (wok-command (format "woklocate -p %s:source:%s.cxx\n" package package))))))))
