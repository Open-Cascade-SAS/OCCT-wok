;;;File		:misc-tools.el
;;;Author		:Edward AGAPOV
;;;Purpose	:
;;;History	:Tue Mar 14 12:27:39 2000	Edward AGAPOV	Creation

(eval-and-compile
  (require 'shared)
  )

(defun eap-goto-matching-paren ()
  "Move cursor to the matching parenthesis"
  (interactive)
  (let* ((match (eap-matching-paren)))
    (if (not match)
	(message "Matching parenthesis not found")
      (if (and (interactive-p)
	       (not (pos-visible-in-window-p match)))
	  (eap-set-pos-at-line match (if (< (point) match) -2 2))
	t)
      (goto-char match)))
  )
(defun eap-show-matching-paren ()
  "Make visible both current and it's matching parenthesis"
  (interactive)
  (let* ((match (eap-matching-paren))
	(pt (point))
	(split-window-keep-point nil)
	(lines (if match (1+ (count-lines pt match)))))
    (cond 
     ((null match)
	(message "Matching parenthesis not found")
      )
     ((pos-visible-in-window-p match)
      (message "Matching parenthesis is already visible")
      )
     ((and (< lines (frame-height))
	   (let ((wh1 (window-height)) (wh2 0))
	     (if (> lines (1+ wh1))
		 (while (and (<= wh1 (+ 2 lines))
			     (/= wh1 wh2)) ;; avoid infinite loop
		   (enlarge-window 1)
		   (sit-for 0)
		   (setq wh2 wh1
			 wh1 (window-height))
		   ))
	     (eap-set-pos-at-line match (if (< pt match) -1 0))
	     (and (pos-visible-in-window-p pt)
		  (pos-visible-in-window-p match))
	     ))
      )
     (t ;;  lines > frame-height
      (delete-other-windows)
      (if (> pt match)
	  (eap-set-pos-at-line pt -2)
        (eap-set-pos-at-line pt 2))
      (split-window-vertically)
      (sit-for 0)
      (eap-other-window)
      (if (> pt match)
	  (eap-set-pos-at-line match 2)
	(eap-set-pos-at-line match -2))
      (goto-char match)
      (sit-for 0)
      (eap-other-window)
      (goto-char pt)
      )))
  )
(defun eap-other-window (&optional toMiniBuffer)
  "Move cursor to other window but not in mini-buffer.
With prexif argument move cursor in mini-buffer."
  (interactive "P")
  (if toMiniBuffer
      (if (active-minibuffer-window)
          (select-window (active-minibuffer-window))
        (message "Minibuffer in not active"))
    (other-window 1)
    (while (equal (selected-window) (minibuffer-window))
      (other-window 1)))
  (if (fboundp 'eap-check-overwrite-state)
      (eap-check-overwrite-state))
  )
(defun eap-immediate-search (curWord &optional backward)
  "Search for either the last copied text or \(with numeric argument\) current word"
  (interactive "P")
  (setq mark-active nil)
  (if curWord (kill-new (current-word)))
  (let* ((fox (current-kill 0))
	 (hole (save-excursion
		 (if backward
		     (search-backward fox nil t)
		   (search-forward fox nil t)))))
    (if (not hole)
	(message "No more `%s' found" fox)
      (or (pos-visible-in-window-p hole) (eap-set-pos-at-line hole))
      (goto-char hole)))
  )
(defun eap-immediate-search-backward (curWord)
  "Same as `eap-immediate-search' but backward." 
  (interactive "P")
  (eap-immediate-search curWord 'backward)
  )

(defun buffer-navig-key ()
  (global-set-key [?\C-0]        'eap-show-matching-paren)
  (global-set-key [?\C-9]        'eap-goto-matching-paren)
  (global-set-key [f11]       'eap-immediate-search-backward)
  (global-set-key [f12]       'eap-immediate-search)
  )
(provide 'buffer-navig)
