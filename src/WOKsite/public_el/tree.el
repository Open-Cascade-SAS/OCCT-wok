;;; tree.el --- presentation and exploration of data having tree structure

;;;Author  : Edward AGAPOV   <eap@opencascade.com>
;;;History : Tue Dec 04 2001               Creation

;;; Commentary

;;; This is a base for major modes intended for presentation and exploration
;; of any data having tree structure. 
;;; To use 'tree-mode for your own data, bind variables 'tree-get-ansestor,
;;; 'tree-has-descendants and 'tree-get-descendants-list to your functions
;;; either in 'tree-mode-hook or in buffer passed to 'tree-build-tree 

;;; Mode entrance function is 'tree-build-tree. To try 'tree-mode evaluate
;;; (tree-build-tree "1000" nil).

;; customization variables ;;

(defvar tree-get-ansestor nil
  "*Function returning ansestor \(string) of item \(argument, string)"
  )
(defvar tree-has-descendants nil
  "*Function returning not nil if an item (argument, string) has descendant(s)"
  )
(defvar tree-get-descendants-list nil
  "*Function returning a list of item descendants (strings)"
  )
(defvar tree-keep-info t
  "*t means that data got for an item through 'tree-get-ansestor and
'tree-get-descendants-list is stored internally and no more asked, so
that it can become out of date if changes after last call "
  )
(defvar tree-top-margin 2
  "*Number of empty top lines"
  )
(defvar tree-level-width 4
  "*Number of columns between neighbour level branches"
  )

(make-variable-buffer-local 'tree-get-ansestor)
(make-variable-buffer-local 'tree-has-descendants)
(make-variable-buffer-local 'tree-get-descendants-list)

;; mode entry function ;;

(defun tree-build-tree (item buffer)
  "Build inheritance tree for ITEM in BUFFER."
  (tr-start-edition)
  (tr-check-buffer buffer)
  (or (tr-is-shown item)
      ;;(if (tr-in-tree item)
	  (tr-find-and-show item);;)
      (setq tr-data-list nil)
      (if (tr-check-data-list item)
	  (tr-init-tree item)
	(message "'%s' has neither ansestors nor descendants" item)
	)
      )
  (tr-end-edition)
  (and (tr-is-shown item)
       (tr-goto-item)
       (message nil))
  )

;; customisation functions for debug and mode demonstration ;;

(defun tr-get-ansestor-fun (item)
  (if (> (length item) 4)
      nil
    (if (string-match "\\([1-9]\\)0*$" item)
	(replace-match "0" nil nil item 1)))
  )
(defun tr-has-descendants-fun (item)
  (if (string-match "^[^5]+0+$" item) t)
  )
(defun tr-get-descendants-list-fun (item)
    (if (string-match "^\\([^0]+\\)\\(0*\\)0$" item) 
	(let ((head (match-string 1 item))
	      (zeros (match-string 2 item))
	      (fun '(lambda (nb) (concat head nb zeros)))
	      )
	  (mapcar fun '(1 2 3 4 5 6 7 8 9 ))))
  )

;; internal part ;;

(defconst tree-left-margin 2
  "Number of left margin columns"
  )
(defun tr-level-str ()
  (make-string tree-level-width ? )
  )
(defun tr-left-mrgn-str ()
  (make-string tree-left-margin ? )
  )
(defun tr-top-mrgn-str ()
  (make-string tree-top-margin ?\n)
  )
;; item seach in buffer
(defconst tr-item-regexp "\\([ |]+\\)[ +-] \\(%s\\) \\([ +-]\\)$")
(defun tr-find-item-re (item) (format tr-item-regexp item))
(defun tr-cur-item-re () (format tr-item-regexp "[^\n]+"))
(defun tr-found-item () (match-string 2))
(defun tr-cur-des-sign () (match-string 3))
(defun tr-item-point () (1- (match-end 1)))
(defun tr-goto-item () (goto-char (+ 3 (tr-item-point))))

(defun tr-current-item ()
  (save-excursion
    (beginning-of-line)
    (if (looking-at (tr-cur-item-re))
	(tr-found-item))
    ))
(defun tr-is-shown (item)
  (save-excursion
    (beginning-of-line)
    (if (or (re-search-backward (tr-find-item-re item) nil t)
	    (re-search-forward (tr-find-item-re item) nil t))
	(tr-item-point))
    ))
(defun tr-set-des-sign (sign item)
  (save-excursion
   (if (tr-is-shown item)
       (replace-match sign nil nil nil 3)))
  )
(defun tr-more-items (&optional backward-p)
  (save-excursion
    (if backward-p
	(re-search-backward (tr-cur-item-re) nil t)
      (re-search-forward (tr-cur-item-re) nil t)
      ))
  )
;; store data in internal list ;;
(defvar tr-data-list nil)
(make-variable-buffer-local 'tr-data-list)

(defun tr-check-data-list (item)
  (or (assoc item tr-data-list)
      (let* ((item-data (list item
			      (funcall tree-get-ansestor item)
			      (funcall tree-has-descendants item)
			      )))
	(and (or (nth 1 item-data)
		 (nth 2 item-data))
	     (if tree-keep-info
		 (setq tr-data-list (cons item-data tr-data-list))
	       'not-remember)
	     item-data
	     )
	)))
(defun tr-get-ans (item)
  (nth 1 (tr-check-data-list item))
  )
(defun tr-get-des-list (item)
  (let* ((data (tr-check-data-list item))
	 (des-list (nth 2 data))
	 )
    (if (listp des-list)
	des-list
      (setq des-list (funcall tree-get-descendants-list item))
      (setcdr data (list (nth 1 data) des-list))
      des-list)
    ))

;; buffer edition ;;

(defun tr-start-edition ()
  (setq buffer-read-only nil)
  )
(defun tr-end-edition ()
  (setq buffer-read-only t)
  )

(defun tr-insert-item (item as-root-p &rest args-to-insert)
  (let* ((item-data (tr-check-data-list item))
	 (des-list (nth 2 item-data))
	 )
    (insert
     (if as-root-p
	 (if (tr-get-ans item) "+" " ")
       "-")
     " " item " "
     (if des-list 
	 (tr-des-sign des-list)
       " ")
     )
    (if args-to-insert
	(apply 'insert args-to-insert))
    ))
(defun tr-des-sign (des-list)
  "Return descendants sign an item should have"
  (if (not (listp des-list))
      "+" ;; has descendants but none was shown
    (let ((all-p t))
      (while (and all-p des-list)
	(setq all-p (tr-is-shown (car des-list)))
	(setq des-list (cdr des-list))
	)
      (if all-p "-" "+"))
    )
  )
(defun tr-next-line (&optional backward-p)
  (let ((col (current-column))
	(inhibit-point-motion-hooks t)
	)
    (if (if backward-p
	    (re-search-backward "\n" nil t)
	  (re-search-forward "\n" nil t))
	(= col (move-to-column col)))
    ))
(defun tr-goto-spring-line (item-line-point)
  (goto-char item-line-point)
  (beginning-of-line 2)
  )
(defun tr-spring-string (item-true-point)
  (save-excursion
    (goto-char item-true-point)
    (let ((str (tr-line-before)))
      (beginning-of-line 2)
      (if (looking-at (concat str "|[ -]"))
	  (setq str (concat str "|"))
	(setq str (concat str " "))
	)
      (concat str (tr-level-str) "|")
      ))
  )
(defun tr-line-before (&optional point)
  (buffer-substring (or point (point))
		    (save-excursion (beginning-of-line) (point)))
  )
(defun tr-in-tree (item)
  (assoc item tr-data-list)
  )
(defun tr-init-tree (item)
;;  (setq tr-data-list nil)
  (erase-buffer)
  (insert (tr-top-mrgn-str) (tr-left-mrgn-str))
  (tr-insert-item item 'as-root "\n")
  (or (tr-show-all-descendants item)
      (let ((ans (tr-get-ans item)))
	(if ans
	    (tr-show-ansestor item ans)))
      )
  )
(defun tr-find-and-show (item)
  (let (branch pnt)
    (if (setq branch (tr-find-shown-ans item))
	(while (nth 1 branch)
	  (setq pnt (tr-show-descendant (car branch) (nth 1 branch) pnt))
	  (setq pnt (1- pnt))
	  (setq branch (cdr branch))
	  )
      (if (setq branch (tr-find-shown-des item))
	  (while (nth 1 branch)
	    (tr-show-ansestor (car branch) (nth 1 branch))
	    (setq branch (cdr branch))
	    )
	))
    branch)
  )
(defun tr-find-shown-ans (item)
  (let ((des item)
	;;(branch (list item))
	branch ans found-p)
    (while (and (not found-p)
		(setq ans (tr-get-ans des))
;;;		(setq ans (nth 1 (assoc des tr-data-list)))
		)
      (setq found-p (tr-is-shown ans))
      (setq branch (cons des branch))
      (setq des ans)
      )
    (if found-p
	(cons ans branch))
    ))
(defun tr-show-ansestor (des ans &optional des-true-pnt)
  (let* ((des-pnt (or des-true-pnt (tr-is-shown des)))
	 (spring-str (tr-spring-string des-pnt))
	 ans-true-pnt)
    (goto-char des-pnt)
    (if (looking-at " \\([ +]\\) ")
	(replace-match "-" nil nil nil 1))
    (move-to-column tree-left-margin)
    (setq ans-true-pnt (1- (point)))
    (tr-insert-item ans 'as-root "\n" spring-str "\n" spring-str)
    (let ((str (concat (tr-level-str) " ")))
      (while (tr-next-line)
	(beginning-of-line)
	(insert str)
	))
    (tr-set-des-sign (tr-des-sign (tr-get-des-list ans)) ans)
    ans-true-pnt)
  )
(defun tr-find-shown-des (item)
  (message "Look for shown descendant of '%s'..." item)
  (let ((des-list (nth 2 (assoc item tr-data-list)))
	found-p branch des)
    (while (and des-list (listp des-list) (not found-p))
      (setq des (car des-list)
	    des-list (cdr des-list))
      (if (tr-is-shown des)
	  (setq branch (list des item)
		found-p t)
	(if (setq branch (tr-find-shown-des des))
	    (setq branch (append branch (list item))
		  found-p t))
	))
    branch)
  )
(defun tr-show-descendant (ans des &optional ans-pnt)
  "Return point where DES itself is inserted \(not it's true point)"
  (let* ((ans-pnt (or ans-pnt (tr-is-shown ans)))
	 (spring-str (tr-spring-string ans-pnt))
	 des-pnt)
    (tr-goto-spring-line ans-pnt)
    (if (looking-at spring-str)
	(beginning-of-line 2)
      (insert spring-str "\n" ))
    (insert spring-str)
    (setq des-pnt (point))
    (tr-insert-item des nil "\n")
    (or (looking-at (concat spring-str "-"))
	(looking-at "[ |]+$")
	(insert (substring spring-str 0 (- tree-level-width)) "\n"))
    (sit-for 0)
    des-pnt)
  )
(defun tr-kill-line (&optional move-up)
  "Kill a whole line"
  (let ((col (current-column)))
    (delete-region (progn (beginning-of-line) (point))
		   (progn (forward-line) (point)))
    (if move-up (beginning-of-line 0))
    (move-to-column col))
  )
(defun tr-hide-descendants (item-true-pnt)
  (goto-char item-true-pnt)
  (and (tr-current-item)
       (not (string= " " (tr-cur-des-sign)))
       (tr-set-des-sign "+" (tr-found-item)))
  (let ((col (current-column)))
    (if (tr-next-line)
	(while (and (not (looking-at "|-"))
		    (= col (tr-kill-line)))
	  (sit-for 0)
	  )
      )
    ))
(defun tr-hide-item (item &optional item-true-pnt)
  (let* ((pnt (or item-true-pnt (tr-is-shown item)))
	 col)
  (tr-hide-descendants pnt)
  (tr-set-des-sign "+" (tr-get-ans item))
  (goto-char pnt)
  (setq col (current-column))
  (if (and (= col (tr-kill-line)) ;; kill item
	   (looking-at "|-"))
      nil ;; more brothers beneeth
    (tr-next-line 'backward)
    (move-to-column col)
    (if (looking-at "|-")
	nil ;; upper brother
      (tr-kill-line 'up)
      (if (looking-at "|[ \n]")
	  ;; hide branch before brother's children
	  (while (looking-at "\\(|\\)[ \n]")
	    (replace-match " " nil nil nil 1)
	    (tr-next-line 'backward)
	    (move-to-column col)
	    )
	;; lines between ansestors
	(if (tr-current-item)
	    (let ((str (tr-line-before (tr-item-point))))
	      (beginning-of-line 2)
	      (if (looking-at (concat str "|"))
		  (tr-kill-line))
	      )))
      )))
  )
(defun tr-hide-ansestor (item item-true-pnt des-sign)
  (tr-goto-spring-line item-true-pnt)
  (let* ((beg (point))
	 (l-mrgn-str (tr-left-mrgn-str))
	 des-str extra-len spring-str col)
    (goto-char item-true-pnt)
    (setq col (current-column))
    ;; look for descendants end
    (while (and (tr-next-line)
		(looking-at "[ |] +|"))
      )
    ;; erase all but descendants
    (beginning-of-line)
    (setq des-str (buffer-substring beg (point)))
    (erase-buffer)
    ;; insert item and descendants
    (insert (tr-top-mrgn-str) )
    (setq beg (point))
    (tr-insert-item item 'as-root "\n")
    (setq spring-str (tr-spring-string beg))
    (setq beg (point))
    (insert des-str)
    ;; left margin string before item
    (goto-char beg) 
    (beginning-of-line 0)
    (insert l-mrgn-str)
    ;; cut off extra chars
    (end-of-line 2)
    (setq extra-len (- (point) beg (length spring-str) 1))
    (beginning-of-line 0)
    (if (< 0 extra-len)
	(while (and (tr-next-line)
		    (< (+ (point) extra-len) (point-max)))
	  (delete-region (point) (+ (point) extra-len))
	  (insert l-mrgn-str)
	  (beginning-of-line)
	  ))
    (tr-set-des-sign des-sign item)
    )
  )
(defun tr-show-all-descendants (item &optional item-true-pnt)
  ;; return spring-string
  (let* ((des-list (tr-get-des-list item))
	 des-pnt spring-str)
    (and des-list
	 ;;(message "Show %s descendants..." (length des-list))
	 (tr-set-des-sign "-" item))
    (while des-list
      (if (tr-is-shown (car des-list))
	  nil
	(if spring-str
	    (tr-insert-item (car des-list) nil "\n" spring-str)
	  (goto-char (tr-show-descendant item (car des-list)))
	  (setq spring-str (tr-line-before))
	  ))
      (sit-for 0)
      (setq des-list (cdr des-list))
      )
    spring-str)
  )
(defun tr-check-buffer (buffer)
  (or (buffer-live-p buffer)
      (setq buffer (get-buffer-create "*tree*")))
  (let ((win (get-buffer-window buffer)))
    (if win
	(select-window win)
      (pop-to-buffer buffer)))
  (or tr-data-list
      (tree-mode))
  )
(defvar tree-mode-map nil
  "Keymap for tree-mode"
  )
(or tree-mode-map
    (let ((map (make-sparse-keymap)))
      (define-key map [C-return] 'tree-show-ansestors)
      (define-key map [M-up]     'tree-previous-item-same-level)
      (define-key map [M-down]   'tree-next-item-same-level)
      (define-key map [M-prior]  'tree-level-up)
      (define-key map [M-next]   'tree-level-down)
      (define-key map [up]       'tree-previous-item)
      (define-key map [down]     'tree-next-item)
      (define-key map "\C-z"     'tree-undo)
      (define-key map [C-delete] 'tree-hide-current-item)
      (define-key map [M-delete] 'tree-hide-ansestors)
      (define-key map [M-insert] 'tree-show-ansestors)
      (define-key map [delete]   'tree-hide-descendants)
      (define-key map [insert]   'tree-show-descendants)

      (setq tree-mode-map map)
      )
    )
;; (use-local-map tree-mode-map)
(defun tree-mode ()
  "Mode for presentation and exploration of data having tree structure.
Mode entrance function is 'tree-build-tree. To try 'tree-mode evaluate
\(tree-build-tree \"1000\" nil).
To use 'tree-mode for your own data, bind variables 'tree-get-ansestor,
'tree-has-descendants and 'tree-get-descendants-list to your functions
before calling 'tree-build-tree.

Keybindings:
\\{tree-mode-map}"

  (run-hooks 'tree-mode-hooks)

  (make-local-variable 'tree-level-width)
  (make-local-variable 'tree-keep-info)
  (make-local-variable 'tree-top-margin)
  
  (or tree-get-descendants-list
      (progn (message "Tree mode demonstration")
	     (setq tree-get-descendants-list 'tr-get-descendants-list-fun
		   tree-has-descendants      'tr-has-descendants-fun
		   tree-get-ansestor         'tr-get-ansestor-fun)
	     ))
  (if (member major-mode '(fundamental-mode nil))
      (setq major-mode 'tree-mode))
  (if (string= "Fundamental" mode-name)
      (setq mode-name "tree"))
  (use-local-map tree-mode-map)
  )


;; interactive functions ;;

(defun tree-show-descendants (arg &optional item)
  "Show  up to ARG-th level descendants of current item"
  (interactive "p")
  (if (> arg 0)
      (let* ((ans (or item (tr-current-item)))
	     (des-list (if ans (tr-get-des-list ans)))
	     (len (length des-list))
	     (msg (and (null item) des-list
		       (format "Look for not shown of %d descendants " len)))
	     (nb 1)
	     des)
	(save-excursion
	  (tr-start-edition)
	  (while des-list
	    (and msg
		 (eap-progress-indicator nb len msg))
	    (setq des (car des-list)
		  des-list (cdr des-list)
		  nb (1+ nb))
	    (or (tr-is-shown des)
		(tr-show-descendant ans des))
	    (if (= arg 2)
		(tr-show-all-descendants des)
	      (tree-show-descendants (1- arg) des)
	      )
	    )
	  (if des
	      (tr-set-des-sign "-" ans))
	  (if (interactive-p) (tr-end-edition))
	  )
	(and (null item)
	     des
	     (message "Ok")
	     )
	))
  )
(defun tree-show-ansestors (arg &optional item item-true-pnt)
  "Show up to ARG-th level ansestors of current item"
  (interactive "p")
  (if (> arg 0)
      (let* ((des (or item (tr-current-item)))
	     (des-pnt (if item item-true-pnt (tr-item-point)))
	     (ans (if des (tr-get-ans des)))
	     ans-pnt)
	(if ans
	    (save-excursion
	      (tr-start-edition)
	      (setq ans-pnt
		    (or (tr-is-shown ans)
			(tr-show-ansestor des ans des-pnt)))
	      (tree-show-ansestors (1- arg) ans ans-pnt)
	      (tr-end-edition)
	      ))
	(and (null item)
	     ans
	     (message "Ok"))
	))
  )
(defun tree-hide-descendants ()
  "Hide descendants of current item"
  (interactive)
  (if (null (tr-current-item))
      nil
    (let ((item (tr-found-item)))
      (tr-start-edition)
      (tr-hide-descendants (tr-item-point))
      (tr-end-edition)
      (if (tr-is-shown item)
	  (tr-goto-item))
      ))
  )
(defun tree-hide-ansestors ()
  "Hide ansestors of current item"
  (interactive)
  (if (null (tr-current-item))
      nil
    (let* ((item (tr-found-item))
	   (des-sign (tr-cur-des-sign))
	   (pnt (tr-item-point))
	   )
      (tr-start-edition)
      (tr-hide-ansestor item pnt des-sign)
      (tr-end-edition)
      (if (tr-is-shown item)
	  (tr-goto-item))
      ))
  )
(defun tree-hide-current-item ()
  "Hide currrent item and it's descendants"
  (interactive)
  (tr-start-edition)
  (if (tr-current-item)
      (tr-hide-item (tr-found-item) (tr-item-point)))
  (tr-end-edition)
  (while (and (not (tr-current-item))
	      (tr-next-line 'back)))
  (if (tr-current-item)
      (tr-goto-item))
  )
(defun tree-previous-item ()
  "Move up to previous item"
  (interactive)
  (setq mark-active nil)
  (tr-next-line 'backward)
  (while (and (null (tr-current-item))
	      (tr-more-items 'backward))
    (tr-next-line 'backward))
  (if (tr-current-item)
      (tr-goto-item))
  )
(defun tree-next-item ()
  "Move down to next item"
  (interactive)
  (setq mark-active nil)
  (tr-next-line)
  (while (and (null (tr-current-item))
	      (tr-more-items))
    (tr-next-line))
  (if (tr-current-item)
      (tr-goto-item))
  )
(defun tree-level-up ()
  "Move to an upper level item"
  (interactive)
  (tr-next-item-check-level 'back '>)
  )
(defun tree-level-down ()
  "Move to next level item"
  (interactive)
  (tr-next-item-check-level (not 'back) '<)
  )
(defun tree-previous-item-same-level ()
  "Move up to previous item of the same level"
  (interactive)
  (tr-next-item-check-level 'back '=)
  )
(defun tree-next-item-same-level ()
  "Move down to next item of the same level"
  (interactive)
  (tr-next-item-check-level (not 'back) '=)
  )
(defun tr-next-item-check-level (backward-p check-level-fun)
  "CHECK-LEVEL-FUN compares current level \(column) to target one"
  (setq mark-active nil)
  (if (and (null (tr-current-item))
	   (not (if backward-p (tree-previous-item) (tree-next-item))))
      nil
    (let ((col (progn (tr-goto-item) (current-column)))
	  (pnt (point))
	  )
      (save-excursion
	(if backward-p (tree-previous-item) (tree-next-item))
	(while (and (not (funcall check-level-fun col (current-column)))
		    (tr-more-items backward-p))
	  (if backward-p (tree-previous-item) (tree-next-item))
	  )
	(if (funcall check-level-fun col (current-column))
	    (setq pnt (point))
	  (message "Required level item not found"))
	)
      (goto-char pnt)
      ))
  )
(defun tree-undo (arg)
  "Undo some previous changes"
  (interactive "p")
  (let ((item (tr-current-item)))
    (tr-start-edition)
    (undo arg)
    (tr-end-edition)
    ;; move to last current item
    (if (and item (tr-is-shown item))
	(tr-goto-item)
      ;; or any shown
      (or (tree-previous-item)
	  (tree-next-item))
      (tr-goto-item))
    )
  )

(provide 'tree)
