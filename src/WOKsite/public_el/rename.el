;;;File		:rename.el
;;;Author	:Edward AGAPOV
;;;Purpose	:rename files modifing Dired buffer contents
;;;History	:Mon Nov 30 09:28:45 1998	Edward AGAPOV	Creation

(require 'hilit19)

(defvar rename-source-buf nil
  "Original Dired buffer"
  )

(defun rename-in-dired ()
  "Rename files modifing Dired buffer contents"
  (interactive)
  (let* ((bn (buffer-name))
	 (cb (current-buffer))
	 (new-name (concat " " bn))
	 (cont (buffer-string))
	 (new-buf (get-buffer-create " rename-work-buffer"))
	 (pt (point))
	 )
    (rename-buffer new-name)
    (switch-to-buffer new-buf)
    (or (local-variable-p 'rename-source-buf)
	(rename-mode))
    (setq rename-source-buf cb)
    (message "Prepare buffer for renaming files ...")
    (let ((inhibit-read-only t)
	  after-change-functions before-change-functions)
      (erase-buffer)
      (insert cont)
      (rename-copy-hiliting);;(hilit-rehighlight-buffer t)
      (rename-protect-non-names)
      (goto-char pt)
      (rename-buffer bn)
      )
    (setq buffer-undo-list nil)
    (message "After file names edition, type 'M-r' to actually rename files" )
    )
  )
(defun rename-mode ()
  "Mode for renaming any number of files at once.
Allow modifing file names right in Dired buffer.
Type 'M-r to save changes i.e. rename files.
Type 'C-g to quit without saving"
  (make-local-variable 'rename-source-buf)
  (setq mode-line-buffer-identification '("Dired: %17b"))
  (let ((tmp-map (make-keymap)))
    (define-key tmp-map "\M-r" 'rename-save)
    (define-key tmp-map "\C-g" '(lambda()
				  "Quit without renaming"
				  (interactive)
				  (setq buffer-undo-list nil)
				  (rename-save)))
    (define-key tmp-map [return] 'next-line)
    (use-local-map tmp-map)
    (setq mode-name "Rename")
    (setq major-mode 'rename-mode)
    (if (eq 'not (car hilit-mode-enable-list))
	(setq hilit-mode-enable-list (delete 'rename-mode hilit-mode-enable-list))
      (add-to-list 'hilit-mode-enable-list 'rename-mode))
    ;; copy patterns of dired-mode
    (add-to-list 'hilit-patterns-alist
		 (cons 'rename-mode (cdr (assq 'dired-mode hilit-patterns-alist))))
    (set (make-local-variable 'after-change-function) nil)
    (make-local-variable 'after-change-functions)
    (add-hook 'after-change-functions 'rename-rehilit-changes)
    (run-hooks 'rename-mode-hooks)
    ))

(defun rename-rehilit-changes (&rest args)
  (save-excursion
    (let* ((beg (progn (goto-char (car args))
		       (beginning-of-line)
		       (1- (point))))
	   (end (progn (goto-char (nth 1 args))
		       (end-of-line)
		       (1+ (point)))))
      (hilit-rehighlight-region (max beg (point-min))
				(min end (point-max))
				t)))
  )
(defun rename-copy-hiliting ()
  "Copy overlays instead of hitiling buffer"
  (let ((ovl-end 1) ovl ovl-copy ovl-list)
    (while (save-excursion
	     (set-buffer rename-source-buf)
	     (setq ovl nil)
	     (while (and (null ovl)
			 (setq ovl-end (next-overlay-change ovl-end))
			 (setq ovl-list (overlays-at ovl-end)))
	       (mapcar '(lambda (ovr)
			  (and (overlay-get ovr 'hilit)
			       (setq ovl ovr
				     ovl-end (overlay-end ovr))))
		       ovl-list))
	     ovl)
      (setq ovl-copy (make-overlay (overlay-start ovl) ovl-end))
      (overlay-put ovl-copy 'face (overlay-get ovl 'face))
      ))
  )
(defun rename-protect-non-names ()
  "Set read-only property to all buffer except file names"
  (let ((beg 1) end)
    (goto-char beg)
    (while (/= beg (progn
		     ;;same as (dired-goto-next-nontrivial-file)
		     (while (and (not (eobp))
				 (if (dired-move-to-filename)
				     (looking-at "\\.\\.?$")
				   'go-on))
		       (forward-line 1))
		     (setq end (1- (point)))))
      (put-text-property beg end 'read-only t)
      (forward-line)
      (setq beg (1- (point)))
      ))
  )
(defmacro rename-prepend (lft seq &optional as-list)
  "Prepend LFT to SEQ \(list) that must be '\(nil) at least"
  `(progn (if (car ,seq) (setcdr ,seq (cons (car ,seq) (cdr ,seq))))
	  (if (or (not (listp ,lft))
		  (not ,as-list))
	      (setcar ,seq ,lft)
	    (setcar ,seq (car ,lft))
	    (setcdr ,seq (append (cdr ,lft) (cdr ,seq)))))
  )
(defmacro rename-append (lft seq &optional as-list)
  "Append LFT to SEQ \(list) that must be '\(nil) at least.
LFT can be a list"
  `(if (car ,seq)
       (setcdr ,seq (append (cdr ,seq)
			    (if (and ,as-list (listp ,lft)) ,lft (list ,lft))))
     (if (or (not (listp ,lft))
	     (not ,as-list))
	 (setcar ,seq ,lft)
       (setcar ,seq (car ,lft))
       (setcdr ,seq (cdr ,lft))))
  )
(defmacro rename-delete (lft seq)
  "Remove LFT from SEQ \(list) if it is member, return nil if it is not"
  `(let ((rename-list (member ,lft ,seq)))
     (if rename-list
	 (let* ((rename-len (length rename-list))
		(rename-seq-len (length ,seq))
		)
	   (if (/= rename-len rename-seq-len)
	       (let ((rename-prev-list
		      (member (nth (- rename-seq-len rename-len 1) ,seq) ,seq)))
		 (setcdr rename-prev-list (cdr rename-list)))
	     ;; remove car
	     (setcar ,seq (nth 1 ,seq))
	     (setcdr ,seq (nthcdr 2 ,seq))
	     ))))
  )

(defun rename-save ()
  "Perform renaming after file names modification"
  (interactive)
  (let ((total-ln-nb (count-lines 1 (point-max)))
	(nb-renamed 0)
	ln from to ; line-nb, old and new file name (full-name)
	lft ; list of <ln> <from> and <to>, basic data item
	  ;;; line number is used as identifier of single rename action
	  ;;; because it is more relevant for quicker search in list
	all-lft-list ; list of all <ltf>s to process
	free-lft ; list of <lft>s whos execution order doesn't matter
	bound-lft-list ; list of lft sequences, each being a list of lft in
		     ;;; order of renaming that does metter
	err )
    (setq bound-lft-list (list (list))
	  free-lft       (list (list))
	  all-lft-list   (list (list)))
    (if (/= total-ln-nb
	    (save-excursion
	      (set-buffer rename-source-buf)
	      (count-lines 1 (point-max))))
	(error "Can't rename files if number of lines changed"))
    (while buffer-undo-list
      (setq lft
	    (rename-lft-by-undo (car buffer-undo-list) all-lft-list))
      (setq buffer-undo-list (cdr buffer-undo-list))
      (and lft
	   ;; find other <ltf>s with other-from==<to> and other-to==<from>
	   (let ((ft-list (mapcar 'cdr all-lft-list))
		 to-coinc-lft from-coinc-lft)
	     (setq from (nth 1 lft)
		   to (nth 2 lft))
	     (if (rassoc (list to) ft-list)
		 nil ;; skip this line if same <to> already encountered
	       (setq from-coinc-lft (rassoc (assoc to ft-list) all-lft-list))
	       (setq to-coinc-lft (rassoc (rassoc (list from) ft-list) all-lft-list))
	       (if from-coinc-lft
		   (rename-bind from-coinc-lft lft from-coinc-lft bound-lft-list free-lft))
	       (if to-coinc-lft
		   (rename-bind lft to-coinc-lft to-coinc-lft bound-lft-list free-lft))
	       (or to-coinc-lft from-coinc-lft
		   (rename-append lft free-lft))
	       (rename-append lft all-lft-list)
	       )
	     ))
      );; end loop on buffer-undo-list

    ;; make one list appending bound-lft-list to free-lft 
    (mapcar '(lambda (bnd-group)
	       (setq free-lft (append free-lft bnd-group)))
	    bound-lft-list)
    ;; do renaming
    (rename-buffer " rename-work-buffer")
    (switch-to-buffer rename-source-buf)
    (rename-buffer (substring (buffer-name) 1))
    (mapcar '(lambda (lft)
	       (if (null (car lft))
		   nil
		 (setq ln (nth 0 lft)
		       from (nth 1 lft)
		       to (nth 2 lft))
		 (condition-case err
		     (let ((actual-marker-char (dired-file-marker from))
			   (ovwr (file-exists-p to)))
		       ;;(message "%s -> %s" from to)
		       (if (= 0 ln)
			   (dired-goto-file from)
			 (goto-line ln))
		       (dired-rename-file from to 4)
		       (if ovwr
			   (dired-remove-file to))
		       (dired-add-file to actual-marker-char)
		       (if (/= 0 ln)
			   (setq nb-renamed (1+ nb-renamed)))
		       )
		   (error (message "%s" err)(sit-for 1.5))
		   )))
	    free-lft)
    (or err
	(message "%d files renamed" nb-renamed))
    ))
(defun rename-lft-by-undo (undo already-list)
  "Return \(list <line-nb> <from> <to>), if file name modificaton is recorded in UNDO.
UNDO is a member of buffer-undo-list"
  (let* ((pos (if (stringp (car-safe undo))
		  (abs (cdr undo))
		(if (numberp (car-safe undo))
		    (car undo))))
	 (line (if pos (count-lines 1 pos)))
	 from to col from-dir add-bad lft
	 buffer-undo-list ;; protect actual undo list being iterated
	 )
    (and pos
	 (not (assoc line already-list))
	 (setq add-bad t) ; if the following ckecks are not successfully passed,
			;;; add current line to <already-list> as checked
	 ;; get <from>
	 (save-excursion
	   (set-buffer rename-source-buf)
	   (goto-line line)
	   (dired-move-to-filename)
	   (setq col (current-column))
	   (setq from-dir (dired-current-directory))
	   (setq from (rename-get-file-name))
	   )
	 ;; new name must begin at the same column as the old one
	 (goto-char pos)
	 (<= col (current-column))
	 (move-to-column col)
	 (= (char-after (1- (point))) ? ) ;;whitespace
	 ;; get <to>
	 (setq to (rename-get-file-name))
	 )
    (primitive-undo 1 (list undo))
    (setq lft (list line (concat from-dir from) (concat from-dir to)))
    (and (null to)
	 add-bad
	 (rename-append already-list lft))
    (if to lft)
    ))
(defun rename-get-file-name ()
  "Return buffer-substring from point till file name end"
  (let* ((beg (point))
	 (end (progn (re-search-forward "\\([ \t]*[\n\r]\\)\\|\\( -> \\)" nil t)
		     (match-beginning 0))))
    (if (< beg end)
	(buffer-substring-no-properties beg end))
  ))

;;; lft is alist of <line-nb> <from-full-name> <to-name>
;;; all args are lft or lists of lft
(defun rename-bind (fr-coin to-coin old-lft bound-list free)
  "Assure renaming in proper order when <form> and <to> coincide.
Put new lft to BOUND-LIST. Lft with coinciding <from> is prepended to
some sequence to be performed earlier than it's <to> pair lft that is
appended to the same sequence of BOUND-LIST"
  (let* ((old-was-free (rename-delete old-lft free))
	 (bnd-list bound-list)
	 fr-bound-group ; list already containing <fr-coin>
	 to-bound-group ; list already containing <to-coin>
	 )
    ;; look for bound groups containing old and may be new lft
    (while (car bnd-list)
      (let* ((group (car bnd-list)))
	(setq bnd-list (cdr bnd-list))
	(if (member fr-coin group)
	    (setq fr-bound-group group))
	(if (member to-coin group)
	    (setq to-bound-group group))
	;; stop searching?
	(or (null bnd-list)
	    (if old-was-free
		(if (or fr-bound-group to-bound-group)
		    (setq bnd-list nil))
	      (if (and fr-bound-group to-bound-group)
		  (setq bnd-list nil)))
	    )
	))
    ;; binding
    (cond ((null (or fr-bound-group to-bound-group))
	   (let ((new-group (list fr-coin to-coin)))
	     (rename-append new-group bound-list)
	     ))
	  ((and fr-bound-group to-bound-group)
	   (if (eq fr-bound-group to-bound-group)
	       ;; case a->b b->a, bind tmp ltf (b->tmp): b->tmp a->b tmp->a
	       ;; here a->b -- to-coin, b->a -- fr-coin
	       (let* ((dir (file-name-directory (nth 1 to-coin)))
		      (from (nth 2 to-coin))
		      (tmp-to (format ".__%d__" (nth 2 (current-time))))
		      (tmp-from-lft (list 0 from (concat dir tmp-to))))
		 (setcdr fr-coin (list (concat dir tmp-to) (nth 2 fr-coin)))
		 (rename-prepend tmp-from-lft fr-bound-group)
		 )
	     (rename-delete fr-bound-group bound-list)
	     (rename-prepend fr-bound-group to-bound-group 'as-list)
	     ))
	  (fr-bound-group
	   (rename-append to-coin fr-bound-group)
	   )
	  (to-bound-group
	   (rename-prepend fr-coin to-bound-group)
	   )
	  (t
	   (error "rename-bind: group analys")
	   ))
    )
  )
(defun rename-key ()
  (add-hook 'dired-mode-hook ;;dired-load-hook ;; 
	    '(lambda ()
	       (define-key dired-mode-map "\M-r" 'rename-in-dired)))
  )


(provide 'rename)
