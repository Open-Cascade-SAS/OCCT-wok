;;

;;; Modified pc-selection-mode

;;; New feature:  a text is copied immediately when selected


(defvar eap-last-mark-pos nil
  "is alist \(mark point)")

(defun eap-copy-region-as-kill (beg end)
  (interactive "r")
  (kill-new (buffer-substring-no-properties (mark) (point))
	    ;; REPLACE
	    (or (member (point) eap-last-mark-pos)
		(member (mark) eap-last-mark-pos))
	    )
  (setq eap-last-mark-pos (list (mark) (point)))
  )
(defun ensure-mark()
  (if (not mark-active)
      (progn (set-mark (point))
	     (make-local-variable 'eap-last-mark-pos))
    ))
;;       (set-mark-command nil)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; forward and mark
;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun forward-char-mark (&optional arg)
  (interactive "p")
  (ensure-mark)
  (forward-char arg)
  (eap-copy-region-as-kill (point) (mark)))
(defun forward-word-mark (&optional arg)
  (interactive "p")
  (ensure-mark)
  (forward-word arg)
  (eap-copy-region-as-kill (point) (mark)))
(defun forward-whole-word-mark (&optional arg)
  (interactive "p")
  (ensure-mark)
  (and (= (skip-syntax-forward "w_") 0)
       (skip-syntax-forward "^w_")
       (skip-syntax-forward "w_"))
  (eap-copy-region-as-kill (point) (mark)))
(defun forward-paragraph-mark (&optional arg)
  (interactive "p")
  (ensure-mark)
  (forward-paragraph arg)
  (eap-copy-region-as-kill (point) (mark)))
(defun next-line-mark (&optional arg)
  (interactive "p")
  (ensure-mark)
  (next-line arg)
  (eap-copy-region-as-kill (point) (mark))
  (setq this-command 'next-line))

(defun end-of-line-mark (&optional arg)
  (interactive "p")
  (ensure-mark)
  (end-of-line arg)
  (eap-copy-region-as-kill (point) (mark))
  (setq this-command 'end-of-line))

(defun scroll-down-mark (&optional arg)
  (interactive "P") 
  (ensure-mark)
  (scroll-down arg)
  (eap-copy-region-as-kill (point) (mark)))

(defun end-of-buffer-mark (&optional arg)
  (interactive "P")
  (ensure-mark)
  (let ((size (- (point-max) (point-min))))
    (goto-char (if arg
		   (- (point-max)
		      (if (> size 10000)
			  ;; Avoid overflow for large buffer sizes!
			  (* (prefix-numeric-value arg)
			     (/ size 10))
			(/ (* size (prefix-numeric-value arg)) 10)))
		 (point-max))))
  (if arg (forward-line 1)
    (if (let ((old-point (point)))
	  (save-excursion
		    (goto-char (window-start))
		    (vertical-motion (window-height))
		    (< (point) old-point)))
	(progn
	  (overlay-recenter (point))
	  (recenter -3))))
  (eap-copy-region-as-kill (point) (mark)))

;;;;;;;;;
;;;;; no mark
;;;;;;;;;

(defun forward-char-nomark (&optional arg)
  (interactive "p")
  (setq mark-active nil)
  (forward-char arg))

(defun forward-word-nomark (&optional arg)
  (interactive "p")
  (setq mark-active nil)
  (forward-word arg))
(defun forward-whole-word-nomark (&optional arg)
  (interactive "p")
  (setq mark-active nil)
  (if (not (= (skip-syntax-forward "w_") 0))
      1
    (skip-syntax-forward "^w")
    (skip-syntax-forward "w_")))
(defun forward-paragraph-nomark (&optional arg)
  (interactive "p")
  (setq mark-active nil)
  (forward-paragraph arg))

(defun next-line-nomark (&optional arg)
  (interactive "p")
  (setq mark-active nil)
  (next-line arg)
  (setq this-command 'next-line))

(defun end-of-line-nomark (&optional arg)
  (interactive "p")
  (setq mark-active nil)
  (end-of-line arg)
  (setq this-command 'end-of-line))

(defun scroll-down-nomark (&optional arg)
  (interactive "P")
  (setq mark-active nil)
  (scroll-down arg))

(defun end-of-buffer-nomark (&optional arg)
  (interactive "P")
  (setq mark-active nil)
  (let ((size (- (point-max) (point-min))))
    (goto-char (if arg
		   (- (point-max)
		      (if (> size 10000)
			  ;; Avoid overflow for large buffer sizes!
			  (* (prefix-numeric-value arg)
			     (/ size 10))
			(/ (* size (prefix-numeric-value arg)) 10)))
		 (point-max))))
  (if arg (forward-line 1)
    (if (let ((old-point (point)))
	  (save-excursion
		    (goto-char (window-start))
		    (vertical-motion (window-height))
		    (< (point) old-point)))
	(progn
	  (overlay-recenter (point))
	  (recenter -3)))))


;;;;;;;;;;;;;;;;;;;;
;;;;;; backwards and mark
;;;;;;;;;;;;;;;;;;;;

(defun backward-char-mark (&optional arg)
  (interactive "p")
  (ensure-mark)
  (backward-char arg)
  (eap-copy-region-as-kill (point) (mark)))

(defun backward-word-mark (&optional arg)
  (interactive "p")
  (ensure-mark)
  (backward-word arg)
  (eap-copy-region-as-kill (point) (mark)))
(defun backward-whole-word-mark (&optional arg)
  (interactive "p")
  (ensure-mark)
  (and (= (skip-syntax-backward "w_") 0)
       (skip-syntax-backward "^w_")
       (skip-syntax-backward "w_"))
  (eap-copy-region-as-kill (point) (mark)))

(defun backward-paragraph-mark (&optional arg)
  (interactive "p")
  (ensure-mark)
  (backward-paragraph arg)
  (eap-copy-region-as-kill (point) (mark)))

(defun previous-line-mark (&optional arg)
  (interactive "p")
  (ensure-mark)
  (previous-line arg)
  (eap-copy-region-as-kill (point) (mark))
  (setq this-command 'previous-line))

(defun beginning-of-line-mark (&optional arg)
  (interactive "p")
  (ensure-mark)
  (beginning-of-line arg)
  (eap-copy-region-as-kill (point) (mark)))


(defun scroll-up-mark (&optional arg)
  (interactive "P")
  (ensure-mark)
  (scroll-up arg)
  (eap-copy-region-as-kill (point) (mark)))

(defun beginning-of-buffer-mark (&optional arg)
  (interactive "P")
  (ensure-mark) 
  (let ((size (- (point-max) (point-min))))
    (goto-char (if arg
		   (+ (point-min)
		      (if (> size 10000)
			  ;; Avoid overflow for large buffer sizes!
			  (* (prefix-numeric-value arg)
			     (/ size 10))
			(/ (+ 10 (* size (prefix-numeric-value arg))) 10)))
		 (point-min))))
  (if arg (forward-line 1))
  (eap-copy-region-as-kill (point) (mark)))

;;;;;;;;
;;; no mark
;;;;;;;;

(defun backward-char-nomark (&optional arg)
  (interactive "p")
  (setq mark-active nil)
  (backward-char arg))

(defun backward-word-nomark (&optional arg)
  (interactive "p")
  (setq mark-active nil)
  (backward-word arg))
(defun backward-whole-word-nomark (&optional arg)
  (interactive "p")
  (setq mark-active nil)
  (if (not (= (skip-syntax-backward "w_") 0))
      1
    (skip-syntax-backward "^w")
    (skip-syntax-backward "w_")))
(defun backward-paragraph-nomark (&optional arg)
  (interactive "p")
  (setq mark-active nil)
  (backward-paragraph arg))

(defun previous-line-nomark (&optional arg)
  (interactive "p")
  (setq mark-active nil)
  (previous-line arg)
  (setq this-command 'previous-line))

(defun beginning-of-line-nomark (&optional arg)
  (interactive "p")
  (setq mark-active nil)
  (beginning-of-line arg))

(defun scroll-up-nomark (&optional arg)
  (interactive "P")
  (setq mark-active nil)
  (scroll-up arg))

(defun beginning-of-buffer-nomark (&optional arg)
  (interactive "P")
  (setq mark-active nil)
  (let ((size (- (point-max) (point-min))))
    (goto-char (if arg
		   (+ (point-min)
		      (if (> size 10000)
			  ;; Avoid overflow for large buffer sizes!
			  (* (prefix-numeric-value arg)
			     (/ size 10))
			(/ (+ 10 (* size (prefix-numeric-value arg))) 10)))
		 (point-min))))
  (if arg (forward-line 1)))


(defun eap-yank (arg)
  (interactive "*P")
  (let ((transient-mark-mode nil))
    (yank arg)
    (setq this-command 'yank))
  )

(defun backward-delete-word (arg)
  "Delete ARG words backward but doesn't not copy it."
  (interactive "*p")
  (delete-region (point)
		 (save-excursion (backward-word arg) (point)))
  )
(defun delete-word (arg)
  "Delete ARG words forward but doesn't not copy it."
  (interactive "*p")
  (delete-region (point)(save-excursion (forward-word arg) (point)))
  )
(defun eap-pc-mode-key ()
  "Modified pc-select.
   New feature:  selected text is copied right away, like when selecting text with mouse-3"
  (interactive)

  (setq transient-mark-mode t)
  ;; *Non-nil means deactivate the mark when the buffer contents change.

  (setq mark-even-if-inactive t)
  ;; *Non-nil means you can use the mark even when inactive.
  ;; This option makes a difference in Transient Mark mode.
  ;; When the option is non-nil, deactivation of the mark
  ;; turns off region highlighting, but commands that use the mark
  ;; behave as if the mark were still active.

  (delete-selection-mode 1)
  ;; Toggle Delete Selection mode.
  ;; When ON, typed text replaces the selection if the selection is active.
  ;; When OFF, typed text is just inserted at point.

  (add-hook 'pre-command-hook 'delete-selection-pre-hook)

  (define-key global-map [S-right]   'forward-char-mark)
  (define-key global-map [right]     'forward-char-nomark)
  (define-key global-map [C-S-right] 'forward-word-mark)
  (define-key global-map [C-right]   'forward-word-nomark)
  (define-key global-map [M-S-right] 'forward-whole-word-mark)
  (define-key global-map [M-right]   'forward-whole-word-nomark)

  (define-key global-map [S-down]    'next-line-mark)
  (define-key global-map [down]      'next-line-nomark)

  (define-key global-map [S-end]     'end-of-line-mark)
  (define-key global-map [end]       'end-of-line-nomark)
  (global-set-key [S-C-end]          'end-of-buffer-mark)
  (global-set-key [C-end]            'end-of-buffer-nomark)

  (define-key global-map [S-next]    'scroll-up-mark)
  (define-key global-map [next]      'scroll-up-nomark)

  (define-key global-map [S-left]    'backward-char-mark)
  (define-key global-map [left]      'backward-char-nomark)
  (define-key global-map [C-S-left]  'backward-word-mark)
  (define-key global-map [C-left]    'backward-word-nomark)
  (define-key global-map [M-S-left]  'backward-whole-word-mark)
  (define-key global-map [M-left]    'backward-whole-word-nomark)
  
  (define-key global-map [S-up]      'previous-line-mark)
  (define-key global-map [up]        'previous-line-nomark)
  
  (define-key global-map [S-home]    'beginning-of-line-mark)
  (define-key global-map [home]      'beginning-of-line-nomark)
  (global-set-key [S-C-home]         'beginning-of-buffer-mark)
  (global-set-key [C-home]           'beginning-of-buffer-nomark)
  
  (define-key global-map [S-prior]   'scroll-down-mark)
  (define-key global-map [prior]     'scroll-down-nomark)
  
  (define-key global-map [S-insert]  'eap-yank)

  ;; some key remapping

  (global-set-key [delete]      'delete-char)
  (global-set-key [C-delete]    'delete-word)
  (global-set-key [S-delete]    'kill-word)
  (global-set-key [S-backspace] 'backward-kill-word)
  (global-set-key [C-backspace] 'backward-delete-word)
  )

(provide 'eap-pc-mode)
