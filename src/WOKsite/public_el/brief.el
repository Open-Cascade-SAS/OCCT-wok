;;; brief.el --- show compactly only method heads

;;;Author	: Edward AGAPOV <eap@opencascade.com>
;;;History      : Mon Jan 31 18:06:15 2000      Creation

;;; Commentary:

;; This is a major mode for quick method overview and search.

;; Mode entry: brief-show-only-method-heads

;;; Key binding:
;;   (brief-key) binds 'brief-show-only-method-heads to f3

;; Method search itself is done by 'eap-method-fullstring defined
;; in 'method-search library; customize 'method-search-regexp-or-function
;; vriable to use 'brief-mode in other major-modes than provided in
;; 'method-search

(require 'method-search)
(require 'hilit19)

(defvar brief-pos-list nil
  "Contains data of methods location.
A member of brief-pos-list is a list of
 . pos in brief buffer
 . pos in source buffer
 . regexp for method head")
(defvar breif-old-size nil
  "Size of source buffer the 'brief-pos-list was built for,
to know a need to update info of methods location")
(defvar breif-source-file nil
  "Name of source file")
(defvar breif-source-buffer nil)
(defvar breif-old-tick nil)
(defvar brief-mode-map nil)

(if brief-mode-map
    nil
  ;; keymap
  (setq brief-mode-map (make-keymap))
  (suppress-keymap brief-mode-map t)
  (define-key brief-mode-map [return] 'breif-return-to-method)
  (define-key brief-mode-map [mouse-2] 'breif-court-fichier-mouse2)
  (define-key brief-mode-map "g" 'breif-refresh-court-fichier)
  (define-key brief-mode-map [C-return] 'kill-this-buffer)
  (define-key brief-mode-map "q" 'bury-buffer)
  ;; hilit
  (if (eq 'not (car hilit-mode-enable-list))
      (setq hilit-mode-enable-list (delete 'brief-mode hilit-mode-enable-list))
    (add-to-list 'hilit-mode-enable-list 'brief-mode))
  (hilit-set-mode-patterns
   'brief-mode
   '(("^%[^%]+%" nil comment )  
     ("\\(Handle\\s *([^)]+)\\s *\\)?\\([_a-zA-Z0-9]+\\)\\s *(" 2 defun)
     ("static \\(const \\)?[_a-zA-Z0-9()]+[ *&]+\\([^(]+\\)\\s *" 2 defun);warning)
     ("(def\\w+\\s +\\([^( ]+\\)" 1 defun)
     ("defcommand\\>" 0 comment)
     ("\\<\\(static\\|const\\|virtual\\)\\>" 0 keyword);;path-face)
     ("defscript" 0 keyword)
     )
   )
  )

(defun brief-show-only-method-heads (&optional refresh)
  "Shows only method heads found in current file.
Then, `return' or `mouse-2' at any method bring the origin file
with the cursor at the first line of the method."
  (interactive "P")
  (or 
   (equal major-mode 'brief-mode)
   (let* ((sourceBuffer (current-buffer))
	  (init-b-sz (buffer-size))
	  (tick (buffer-modified-tick))
	  (source-file buffer-file-name)
	  (bufferName (format " %s" (buffer-name)))
	  (buffer (get-buffer-create bufferName))
	  (pt (point))
	  newly method-pos
	  (get-time '(lambda ()
		       (let ((time (current-time)))
			 (+ (nth 1 time) (/ (nth 2 time) 1000000.0)))))
	  (old-time (funcall get-time))
	  (msg "Look for methods ")
	  eap-method-search-boundaries
	  )
     (set-buffer buffer)
     (or (setq newly (not (and (boundp 'breif-old-size)
			       (local-variable-p 'breif-old-size))))
	 refresh
	 (= init-b-sz breif-old-size)
	 (setq refresh t))
     
     (if (not newly)
	 (if refresh
	     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	     ;; update data
	     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	     (let* ((pos-list (reverse brief-pos-list))
		    (nb-of-meth (length pos-list))
		    (meth-nb 1)
		    intrvl next-intvl cur-intvl-nb beg end 
		    source-pos-list checked-intervals new-pos-list
		    s-p-l-and-ch-int nb-of-found-meths
		    (time (funcall get-time))
		    (old-size breif-old-size)
		    )
	       (setq msg "Update methods ")
	       (message msg)
	       (set-buffer sourceBuffer)

	       ;; a trick to enable mesurement of the last method size
	       ;; and not to check interval (1 - <1-st method>)
	       (setq pos-list (append pos-list (list (list 0 (1+ old-size) "^\"")))
		     pos-list (cons (list 0 1 "^\"") pos-list)
		     source-pos-list (list (cons (point-max) "")
					   '(1 . ""))
		     )
	       ;; look for previousely found methods
	       (while (< meth-nb nb-of-meth)
		 (setq nb-of-found-meths (length source-pos-list))
		 
		 (if (= 1 (or (car (car checked-intervals))
			      2))
		     (setq intrvl (car checked-intervals)
			   next-intvl (nth 1 checked-intervals)
			   cur-intvl-nb 1)
		   (setq intrvl '(-9 . -9)
			 next-intvl (car checked-intervals)
			 cur-intvl-nb 0))
		 
		 (while (and (= nb-of-found-meths (length source-pos-list))
			     intrvl)
		   (setq beg (+ 10 (cdr intrvl)))
		   (setq end (or (car next-intvl)
				 (point-max)))
		   (setq s-p-l-and-ch-int (brief-find-elt-in-interval meth-nb
								      pos-list
								      beg
								      end
								      source-pos-list
								      checked-intervals))
		   (setq source-pos-list (car s-p-l-and-ch-int)
			 checked-intervals (cdr s-p-l-and-ch-int))
		   
		   (setq cur-intvl-nb (1+ cur-intvl-nb)
			 intrvl next-intvl
			 next-intvl (nth cur-intvl-nb checked-intervals))
		   )
		 (setq meth-nb (1+ meth-nb))
		 )

	       ;; try to find new meths in not checked-intervals  
	       (setq cur-intvl-nb 0
		     intrvl '(-9 . -9)
		     next-intvl (car checked-intervals))
	       (while intrvl
		 (setq beg (+ 10 (cdr intrvl)))
		 (setq end (or (car next-intvl)
			       (point-max)))
		 (goto-char beg)
		 (setq eap-method-search-boundaries (cons beg end))
		 (while (setq method-pos (eap-method-fullstring nil 'endPos))
		   (setq source-pos-list
			 (car (brief-add-to-pos-list (nth 1 method-pos)
						     (car method-pos)
						     source-pos-list)))
		   )
		 (setq cur-intvl-nb (1+ cur-intvl-nb)
		       intrvl next-intvl
		       next-intvl (nth cur-intvl-nb checked-intervals))
		 )
	        ;; remove buffer start and end and reverse
	       (setq source-pos-list (cdr (nreverse (cdr source-pos-list))))

	       ;; restore point
	       (goto-char pt)
	       
	       ;; erase old contens apart from the header comments
	       (set-buffer buffer)
	       (goto-char (or (car (nth 1 pos-list))
			      (point-min)))
	       (setq buffer-read-only nil)
	       (delete-region (point) (point-max))

	       ;; insert the search results
	       (while source-pos-list
		 (let* ((elt (car source-pos-list))
			(meth (eap-simplified-string (cdr elt)))
			)
		   (setq new-pos-list (cons (list (point)
						  (car elt)
						  (eap-regexp-for-method-string meth))
					    new-pos-list))
		   (insert " " meth "\n")
		   (setq source-pos-list (cdr source-pos-list))
		   )
		 )
	       (setq brief-pos-list new-pos-list
		     eap-method-search-boundaries nil)

	       )
	   ) ;; end update data

       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;       
       ;; build data for the first time
       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       (brief-mode)
       (erase-buffer)
       (insert "%\nfile:\t " (file-name-nondirectory source-file) "\n%\n\n")
       (set-buffer sourceBuffer)
       (goto-char (point-min))
       (message "Look for methods ")
       (while (setq method-pos (eap-method-fullstring nil 'endPos))
	 (set-buffer buffer)
	 ;; elements of brief-pos-list:
					; pos in brief buffer
					; pos in source buffer
					; regexp for method head
	 (setq brief-pos-list (cons
			       (list (point)
				     (car (cdr method-pos))
				     (eap-regexp-for-method-string (car method-pos)))
			       brief-pos-list))
	 (insert " " (eap-simplified-string (car method-pos)) "\n")
	 (eap-progress-indicator (car (cdr method-pos)) init-b-sz "Look for methods ")
	 (set-buffer sourceBuffer))
       )
     (switch-to-buffer buffer)

     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     ;;  find position in buffer
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     (let* ((posList brief-pos-list))
       (while (and posList (< pt (nth 1 (car posList))))
	 (setq posList (cdr posList)))
       (goto-char (or (car (car posList))
		      (point-min)))
       )
     
     (if (or newly refresh)
	 (hilit-rehighlight-buffer t))
     (set-buffer-modified-p nil)
     
     (if (or newly refresh)
	 (message "%s- Ok. It took %s seconds" msg (- (funcall get-time) old-time ))
       (message "%s- Ok" msg)
       (or 
	(= breif-old-tick tick)
	(save-excursion (set-buffer sourceBuffer) buffer-read-only)
	(message
	 "Source buffer seems to be modified. If methods location changed, press `%s' to update"
	 (substitute-command-keys "\\[breif-refresh-court-fichier]")
	 )))

     (setq buffer-read-only t
	   breif-old-size init-b-sz
	   breif-old-tick tick
	   breif-source-buffer sourceBuffer
	   breif-source-file source-file)
     )
   ))

(defun brief-mode ()
  "Show only method heads in order to overview all methods and
to find a method easily.
Type '\\[breif-return-to-method]' or '\\[breif-court-fichier-mouse2]' to get back source buffer
with cursor at the first line of the method clicked on.
Type '\\[breif-refresh-court-fichier]' to make 'brief buffer up-to-date when you know it is not.
Type '\\[bury-buffer]' when you want to rid of 'brief buffer without changing cursor position"
  (use-local-map brief-mode-map)
  (set (make-local-variable 'breif-old-size) 0)
  (set (make-local-variable 'breif-old-tick) 0)
  (set (make-local-variable 'brief-pos-list) nil)
  (set (make-local-variable 'breif-source-file) nil)
  (set (make-local-variable 'breif-source-buffer) nil)
  (set (make-local-variable 'after-change-function) nil)
  (set (make-local-variable 'after-change-functions) nil)
  (setq mode-name "Brief"
	major-mode 'brief-mode
	truncate-lines t)
  (auto-show-mode t)
  (run-hooks 'brief-mode-hooks)
  )

(defun brief-add-to-pos-list (beg method-string source-pos-list)
;;; add a new item to source-pos-list regarding the decreasing order of
;;; 1-st elements of items. Returns list:
;;; (
;;;  <updated source-pos-list> 
;;;  <the 1-st element of the item following the new one or 1>
;;;  <the 1-st element of the item followed by the new one or 1>
;;;                                                               )
;;;  so (nth 1 result) < (nth 2 result)
  (if (null source-pos-list)
      (cons (list (cons beg method-string))
	    '(1 1))
    (if (assoc beg source-pos-list) ;; - already added
	(list source-pos-list 1 1)
      (let* ((new-item (list (cons beg method-string)))
	     tmp-list)
	(while (and source-pos-list
		    (< beg (car (car source-pos-list))))
	  (setq tmp-list (cons (car source-pos-list) tmp-list)
		source-pos-list (cdr source-pos-list))
	  )
	(list (append (nreverse tmp-list) new-item source-pos-list)
	      (car (car source-pos-list))
	      (car (car tmp-list))
	      ))
      ))
  )
(defun brief-add-checked-interval (beg end intervals)
  ;; returns new intervals
  (let* ((nb-of-intrvls (length intervals))
	 (counter 0)
	 add-p
	 new-intervals);; intvl first-pt last-pt) 
    (while (and (<= counter nb-of-intrvls)
		(not add-p))
      (let* ((first-pt (cdr (car new-intervals)))
	     (last-pt (car (car intervals)))
	     (first-coins (and first-pt
			       (= beg first-pt)))
	     (last-coins (and last-pt
			      (= end last-pt)))
	     )
	(if (not (or first-coins last-coins))
	    (and (or (null first-pt) (< first-pt beg))
		 (or (null last-pt)  (> last-pt end))
		 (setq add-p t))
	  (if first-coins
	      (setq beg (car (car new-intervals))
		    new-intervals (cdr new-intervals)))
	  (if last-coins
	      (setq end (cdr (car intervals))
		    intervals (cdr intervals)))
	  (setq add-p t)
	  ))
	
      (if add-p
	  (setq new-intervals (cons (cons beg end) new-intervals))
	(setq new-intervals (cons (car intervals) new-intervals)
	      intervals (cdr intervals)
	      counter (1+ counter)))
      )
    (append (nreverse new-intervals) intervals))
  )

(defun brief-fill-checked-intervals (before-beg beg after-beg elt-nb elts-list checked-intervals)
;;; returns updated checked-intervals.
;;; Define if the previous or\and current meths length rested the same
  (let* ((elt (nth elt-nb elts-list))
	 (prev-elt (if (> elt-nb 0)
		       (nth (1- elt-nb) elts-list)))
	 (next-elt (nth (1+ elt-nb) elts-list))
	 
	 (before-dist (- beg (or before-beg 1)))
	 (expected-before-dist (- (nth 1 elt)
				  (or (nth 1 prev-elt) 1)))
	 (length-before-rest-p (= expected-before-dist before-dist))
	   
	 (after-dist (- (or after-beg 0)
			beg))
	 (expected-after-dist (- (or (nth 1 next-elt) (point-max))
				 (nth 1 elt)))
	 (length-after-rest-p (= expected-after-dist after-dist))
	 )
    (if (or length-before-rest-p
	    length-after-rest-p)
	  ;; meth size not changed - save bounaries not to check later
	(brief-add-checked-interval (if length-before-rest-p
					 before-beg beg)
				    (if length-after-rest-p
					after-beg beg)
				    checked-intervals)
      checked-intervals)
    )
  )
(defun brief-find-elt-in-interval (elt-nb elts-list beg end source-pos-list checked-intervals)
  ;; returns cons: (source-pos-list . checked-intervals)
  (goto-char beg)
  (let* ((elt (nth elt-nb elts-list))
	 (regexp (nth 2 elt)))
    (if (re-search-forward regexp end t)
	(let* ((method (match-string 0))
	       (beg (match-beginning 0))
	       (list-and-begs (brief-add-to-pos-list beg method source-pos-list))
	       )
	  (setq source-pos-list (car list-and-begs))
	  (setq checked-intervals
		(brief-fill-checked-intervals (nth 1 list-and-begs) ;; prev-beg
					      beg
					      (nth 2 list-and-begs) ;; next-beg
					      elt-nb
					      elts-list
					      checked-intervals))
	  ))
    (cons source-pos-list checked-intervals)
    )
  )

(defun eap-regexp-for-method-string (meth-string) ;; for C++
  (let* ((len (length meth-string))
	 (cur-pos 0)
	 result) ;; & * :: (,)
    (while (< cur-pos len)
      (let* (w-b w-e word elt)
	(if (string-match "[0-9a-z_A-Z]+" meth-string cur-pos)
	    (setq word (match-string 0 meth-string)
		  w-b (match-beginning 0)
		  w-e (match-end 0))
	  (setq w-b len))
	(while (< cur-pos w-b)
	  (setq elt (aref meth-string cur-pos))
	  (cond ((or (= 32 elt) ;; whitespace - skip
		     (= 10 elt) ;; RET
		     (= 9  elt)) ;; TAB
		 nil)
		((= 47 elt) ;; c++-comment  - add regexp
		 (setq result (concat result "[ \t\n]*//[^\n]*\n")
		       cur-pos (or (string-match "\n" meth-string cur-pos)
				   len)))
		((= 58 elt) ;; :: - don't separate
		 (setq result (concat result "[ \t\n]*::") 
		       cur-pos (1+ cur-pos)))
		((= 42 elt) ;; *  - quote regexp
		 (setq result (concat result "[ \t\n]*[*]")))
		(t ;; any other
		 (setq result (concat result "[ \t\n]*"
				      (substring meth-string cur-pos (1+ cur-pos))))))
	  (setq cur-pos (1+ cur-pos)))
	(and word
	     (= cur-pos w-b)
	     (setq result (concat result "[ \t\n]*" word)
		   cur-pos w-e))
	))
    (if (= 0 (string-match "\\[ \t\n\\][*]" result))
	(substring result 6)
      result))
  )
(defun breif-court-fichier-mouse2 (event)
;;;  Move point to the position clicked on with the mouse-2
;;; and returns the buffer visiting origin file with the
;;; point at first line of the clicked method.
  (interactive "e")
  (mouse-set-point event)
  (breif-return-to-method))
(defun breif-refresh-court-fichier ()
  ;; Updates info in brief-buffer
  (interactive)
  (set-buffer (find-file-noselect breif-source-file))
  (brief-show-only-method-heads 'refresh))
(defun breif-return-to-method ()
  (interactive)
  (let* ((posList brief-pos-list)
	 (home (point))
	 (sourceBuffer (if (buffer-live-p breif-source-buffer)
			   breif-source-buffer
			 (if (not (file-exists-p breif-source-file))
			     (eap-find-packed-file-internal
			      (file-name-nondirectory breif-source-file) breif-source-file)
			   (find-file-noselect breif-source-file))))
	 )
    (if (not (buffer-live-p sourceBuffer))
	(message "Can't find file: %s" breif-source-file)
      (while (and posList (< home (car (car posList))))
	(setq posList (cdr posList)))
      (switch-to-buffer sourceBuffer)
      (setq mark-active nil)
      (goto-char (or (nth 1 (car posList)) (point-min)))
      (recenter 1)
      ))
  )
(defun brief-key()
  (global-set-key [f3] 'brief-show-only-method-heads)
  )

(provide 'brief)


;;;(defun dump-pos-list (&optional msg pos-list)
;;;  (interactive)
;;;  (if (boundp 'brief-pos-list)
;;;      (let* ((text (if pos-list
;;;		       msg
;;;		     (concat msg " <brief-pos-list> ")))
;;;	     (pos-list (or pos-list brief-pos-list))
;;;	     elt)
;;;	(eap-message "%s (%s)" (or text "") (buffer-name))
;;;	(while pos-list
;;;	  (setq elt (car pos-list)
;;;		pos-list (cdr pos-list))
;;;	  (condition-case nil
;;;	      (eap-message "%s %s %s"
;;;			   (car elt)
;;;			   (if (atom (nthcdr 1 elt))
;;;			       (nthcdr 1 elt)
;;;			     (car (nthcdr 1 elt))) ;;(nth 1 elt)
;;;			   (or (atom (nthcdr 1 elt))
;;;			       (if (car (nthcdr 2 elt));;(nth 2 elt)
;;;				   (eap-simplify-string (nth 2 elt)
;;;							'(("\\([\n\t]\\|\\*\\)")("\\[ \\]" " ")))
;;;				 ""
;;;				 )))
;;;	    (error (eap-message "ERROR: elt: %s  list: %s" elt pos-list)))
;;;	  )
;;;	(eap-message "")
;;;	)))

