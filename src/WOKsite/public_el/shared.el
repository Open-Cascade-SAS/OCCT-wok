;;; shared.el --- common use functions

;;;Author       :Edward AGAPOV  <eap@opencascade.com>
;;;History      :Thu Mar  9 2000       Creation

(defvar eap-animation nil
  "*Turn on and off animation effect when scrolling buffer.
Default is nil \(off) because is not well tested and needs improvement"
  )

(defvar eap-enable-remember-visited nil
  "*Switch on and off storage of names of visited files in a buffer.
The buffer name is given by 'eap-visited-files-buf-name variable
(*visited-files* by default).
'eap-show-visited-files displays that buffer."
  )

(defun eap-chk-load-path ()
  "Remove doubling paths in 'load-path and make it contain true file names"
  (let ((lp (mapcar 'file-truename load-path)))
    (setq load-path nil)
    (mapcar '(lambda (f)
	       (add-to-list 'load-path f))
	    lp))
  )
(eap-chk-load-path)

(or (getenv "USER")
    (setenv "USER" (getenv "USERNAME")) ;; for WNT
    )
(setenv "HOME" (if (getenv "HOME")
		   (directory-file-name (file-truename (getenv "HOME")))))
(defun eap-home ()
  (concat (getenv "HOME") "/"))

(defun eap-load-all-el (where &optional forced-p match fun)
  "Load all or matching regexp MATCH emacs lisp files found in WHERE.
Add WHERE to 'load-path.
If not FORCED-P, a file is loaded only if corresponding feature is not yet provided.
FUN is called for loaded file name."
  (and (file-exists-p where)
       (file-directory-p where)
       (let* ((files (directory-files where nil "[.]el$"))
              (dir (file-truename where))
              file)
         (setq load-path (mapcar 'file-truename load-path))
         (and files
              (add-to-list 'load-path dir))
         (while files
           (setq file (file-name-sans-extension (car files))
                 files (cdr files))
           (and (or forced-p
                    (not (member (intern file) features)))
                (or (null match)
                    (string-match match file))
                (load file)
                fun
                (funcall fun file))
           )
         ))
  )
(defun eap-bind-key (library)
  "call \(LIBRARY-key) function"
  (let ((fun (intern (concat library "-key"))))
    (if (fboundp fun)
        (funcall fun)))
  )
(defun eap-bug-report ()
  "Put info about place where failure occures and CSF env vars in clipboard"
  (interactive)
  (kill-new
   (concat 
    "\n" (or buffer-file-name (buffer-name))
    ":" (count-lines (point-min) (point)) "\n"
    (point) "\n"
    "csf-shop-adm-path: " (if (boundp 'csf-shop-adm-path) csf-shop-adm-path "-") "\n"
    "csf-ref-list: " (if (boundp 'csf-ref-list) (format "%s" csf-ref-list) "-") "\n"
    "load-path: " (format "%s" load-path) "\n"
    ))
  (message "Call it right after failure occures. Ok, environment copied")
  )

(eval-when-compile
  (require 'hilit19))
(defun eap-rehighlight-changes (&rest args)
  "Rehilit changed text"
  (save-excursion
    ;;(message "%s %s %s" (car args) (nth 1 args) (nth 2 args))
    (let* ((beg (progn (goto-char (car args))
		       (beginning-of-line -1)
		       (point)))
	   (end (progn (goto-char (nth 1 args))
		       (end-of-line 2)
		       (point)))
	   )
      (setq beg (apply 'min beg (mapcar 'overlay-start (overlays-at beg))))
      (setq end (apply 'max end (mapcar 'overlay-end (overlays-at end))))
      (hilit-unhighlight-region beg end 'quietly)
      (or (= beg (point-min))
	  (setq beg (1- beg)))
      (or (= end (point-max))
	  (setq end (1+ end)))
      (hilit-highlight-region   beg end nil 'quietly)))
  )

(defun eap-kill-line (&optional dont-copy)
  "Kill and copy \(without prefix argument\\) a whole line."
  (interactive "P*")
  (let* ((beg (or (beginning-of-line) (point)))
         (end (and (forward-line) (point))))
    (if dont-copy
        (delete-region beg end)
      (kill-region beg end)))
  )
(defun eap-extention (file &optional pos)
  "Return extention or it's beginning position if POS is not nil"
  (let* ((file (if file (file-name-sans-versions file))))
    (if (and file (string-match "\\w\\.\\(\\w+\\)$" file))
        (if pos
            (match-beginning 1)
          (substring file (match-beginning 1)))))
  )
(defun eap-make-extention (fileName ext)
  "Replace existing extention with \(or just append\) new one."
  (let* ((f fileName)
         (pos (eap-extention fileName 'pos)))
    (if pos
        (setq f (substring f 0 pos))
      (or (string-match "\\.$" f)
          (setq f (concat f "."))))
    (concat f ext))
  )
(defun eap-n-level-up (dir &optional level noslash div-str)
  "Remove LEVEL components of path DIR
Remove components from left if LEVEL is negative.
NOSLASH removes last divider from result.
DIV-STR gives components divider, defaults to \"/\"."
  (let* ((path dir)
         (divider (or div-str "/"))
         (counter (or level 1 )))
    (if (> counter 0)
        (while (and (> (length path) 0)
                    (> counter 0))
          (setq counter (1- counter))
          (if (string-match (format "[^%s]+%s*$" divider divider) path)
              (setq path (substring path 0 (match-beginning 0)))))
      (while (and (> (length path) 0)
                  (< counter 0))
        (setq counter (1+ counter))
        (if (string-match (format "[^%s]+" divider) path)
            (setq path (substring path (match-end 0))))))
    (if noslash 
        (if (and level 
                 (< level 0)
                 (= 0 (string-match divider path)))
            (setq path (substring path 1))
          (if (string-match (format "%s$" divider) path)
              (setq path (substring path 0 (match-beginning 0))))))
    path)
  )
(defun eap-class-name (&optional file with-number)
  "Returns file-name without path, extention and version \(if not WITH-NUMBER)"
  (let* ((file (or file buffer-file-name (buffer-name) default-directory ""))
         (cl-name (file-name-sans-extension (file-name-nondirectory file)))
         )
    (if with-number
        cl-name
      (eap-replace-all "_[a-z0-9]+\\(_[a-z0-9]+\\)$" "" cl-name 1)
      ))
  )
(defun eap-get-package-name (fullName)
  "Return package component of FULLNAME.
FULLNAME may be either path or class name"
  (if (stringp fullName)
      (let* ((path (file-name-directory fullName))
             (name (file-name-nondirectory fullName)))
        (if (and path
                 (not (string-match "BAG" path))
                 (string-match "[/\]src[/\]" path))
            (if (string-match "src[/\]$" path)
                name;; case: path/src/file -> file = pack
              (substring path (match-end 0) -1))
          (if (string-match 
               "\\(_\\|[.]toolkit\\|[.]package\\|\\.\\w+[^/]*$\\)" name)
              (substring name 0 (match-beginning 0))
            name))))
  )
(defun eap-cpp-style (aclass)
  "Make <PACK_CLASS> from <CLASS from PACK>"
  (let* (packname classname)
    (if (string-match " +in +" aclass)
        (setq aclass (substring aclass 0 (match-beginning 0)))
      )
    (if (string-match "[ \t\n]+from[ \t\n]+" aclass)
        (setq packname  (substring aclass (match-end 0))
              classname (substring aclass 0 (match-beginning 0)))
      (setq packname aclass
            classname nil)
      )
    (concat (eap-simplify-string packname '((" ")))
            (if classname (concat "_" (eap-simplify-string classname '((" ")))))
            ))
  )

(defun eap-file-mode (&optional fileName list-p)
  "Return the mode corresponding to the FILENAME or buffer-file-name.
Return a list of corresponding modes, if LIST-P"
  (let* ((file (if fileName fileName (or (buffer-file-name) (buffer-name))))
         (file (file-name-sans-versions file))
         (alist auto-mode-alist)
         (mode nil) mode-list)
    (while (and (or list-p (not mode))
                alist)
      (and (string-match (car (car alist)) file)
           (setq mode (cdr (car alist)))
           (not (member mode mode-list))
           (setq mode-list (append mode-list (list mode))))
      (setq alist (cdr alist)))
    (if list-p
        mode-list
      mode))
  )
(defun eap-file-is-mine (file &optional my-file)
  "Compare UID of FILE with one of MY-FILE or HOME dir"
  (condition-case nil
      (= (nth 2 (file-attributes (or my-file (eap-home))))
         (nth 2 (file-attributes file)))
    (error nil))
  )
(defun eap-file-newer-p (newer other)
  (let ((new-time (nth 5 (file-attributes newer)))
        (other-time (nth 5 (file-attributes other)))
        )
    (if (or (null other-time)
            (null new-time))
        nil
      (or (> (car new-time) (car other-time))
          (if (= (car new-time) (car other-time))
              (> (nth 1 new-time) (nth 1 other-time)))
          )))
  )
(defun eap-current-file (&optional any)
  "Find current file under different major-modes.
If ANY, return 'default-directory at least"
  (let* ((file (or buffer-file-name
                   (car (eap-dired-get-marked-files))
                   (progn (set-buffer (or (if Buffer-menu-buffer-column
                                              (Buffer-menu-buffer nil))
                                          (current-buffer)))
                          (or buffer-file-name default-directory))
                   ))
         )
    (if (and file
             (or any
                 (not (file-directory-p file))))
        (expand-file-name file)
      ))
  )
(defun eap-find-file-noselect (file &optional existing any-existing-p)
  "Read FILE into a buffer and return the buffer.
Set 'buffer-file-name, 'default-directory and 'major-mode.
If EXISTING, first try to find buffer visiting FILE.
If ANY-EXISTING-P, also try to find buffer named as one visiting FILE would be named.
Run 'eap-find-file-hooks"
  (save-excursion
    (or (if existing (or (find-buffer-visiting file)
                         (if any-existing-p (get-buffer (file-name-nondirectory file)))))
        (let ((buf (set-buffer (create-file-buffer file)))
              er)
          (setq buffer-file-name file
                default-directory (file-name-directory file)
                major-mode (eap-file-mode file))
          (condition-case er
              (if (file-exists-p file)
                  (if (file-directory-p file)
                      (progn (kill-buffer buf)
                             (setq buf (dired-noselect file)))
                    ;;(insert-file-contents-literally file)
                    (insert-file-contents file)
                    (goto-char 1)
                    ))
            (error (message "eap-find-file-noselect error: %s" er)))
	  (run-hooks 'eap-find-file-hooks)
          (set-buffer-modified-p nil)
          buf
          )
        ))
  )
(defun eap-find-file (file &optional existing any-existing-p)
  "Switch to buffer returned by 'eap-find-file-noselect \(see)"
  (switch-to-buffer (eap-find-file-noselect file existing any-existing-p))
  )
(defun eap-dired-get-marked-files (&optional no-dir)
  "Unlike dired-get-marked-files never causes errors but returns nil"
  (if (equal major-mode 'dired-mode)
      (let* ((localp (if no-dir 'no-dir nil))
             (marked
              (save-excursion
                (nreverse (dired-map-over-marks (dired-get-filename localp t) nil)))))
        (while (string-match dired-trivial-filenames
                             (file-name-nondirectory
                              (or (car marked) "")))
          (setq marked (cdr marked)))
        (if (equal marked '(nil))
            nil marked)))
  )
(defun eap-directory-files (directory &optional full match nosort msg)
  "The same as 'directory-files plus check that all files are retrived.
If MSG not t, print 'MSG DIRECTORY: <nb of retrived files>'.
Do not signal an error if DIRECTORY is not existent"
  (if (file-exists-p directory)
      (let* ((msg (if (eq msg t)
                      nil
                    (concat msg " " directory ": %d" )))
             (files (directory-files directory full match nosort))
             (nb (length files))
             (old-nb 0)
             )
        (while (/= nb old-nb)
          (if msg (message msg nb))
          (setq old-nb nb)
          (setq files (directory-files directory full match nosort))
          (setq nb (length files))
          )
        files))
  )
(defun eap-replace-all (obj with string &optional subexp)
  "Replace all encounters of OBL with WITH in STRING.
OBL is considered to be regexp.
The optional fifth argument SUBEXP specifies a subexpression of the match
to be replaced."
  (let* ((res string))
    (while (and (string-match obj res)
                (if subexp (match-end subexp) t))
      (setq res (replace-match with nil nil res subexp)))
    res)
  )
(defun eap-simplify-string (string how-list)
  "Replace all text matched of car of HOW-LIST member with
optional nth 1 of HOW-LIST member. Optional nth 2 of HOW-LIST member
specifies a subexpression of the match to be replaced."
  (let* ((how-list (if (atom (car how-list)) (list how-list) how-list))
         triple obj with)
    (while (car how-list)
      (setq triple (car how-list)
            how-list (cdr how-list)
            obj (car triple)
            with (or (nth 1 triple) "")
            string (eap-replace-all obj with string (nth 2 triple))))
    string)
  )
(defun eap-simplified-string (string)
  "Replace TAB, RET with SPC, double SPC with single ones."
  (eap-simplify-string string '(("[\t\n]" " ") ("  +" " ")))
  )
(defmacro eap-no-prp (&rest body)
  "Execute the BODY forms removing all properties from result"
  `(let ((res (progn ,@body)))
     (if (stringp res)
         (set-text-properties 0 (length res) nil res))
     res)
  )
(defun eap-match-string (num &optional string)
  "The same as 'match-string' but returns substring without properties"
  (eap-no-prp (match-string num string))
  )
(defun eap-current-word (&optional strict)
  "The same as 'current-word but returned string has no properties"
  (eap-no-prp (current-word strict))
  )
(defun eap-count-lines (start end)
  "Return number of lines between START and END.
Unlike 'count-lines return number of screen lines if \(not truncate-lines)"
  (if (or truncate-lines 
          (and truncate-partial-width-windows
               (< (window-width) (frame-width)))
          )
      (1+ (count-lines start end))
    (save-excursion
      (save-match-data
        (let* ((nb 0)
              (win-wid (window-width))
              (beg (min start end))
              (end (max start end))
              stop-p)
          (goto-char beg)
          (while (not stop-p)
            (setq nb (+ nb 1 (/ (skip-chars-forward "^\n\C-m") win-wid)))
            (setq stop-p (or (>= (point) end)
                             (not (re-search-forward "[\n\C-m]" end t))))
            )
          nb)))
    )
  )
(defun eap-count-symbols-in-string (symbol string)
  "SYMBOL - regexp. Return number of SYMBOLs."
  (let* ((posix 0)  (counter 0) )
    (while (string-match symbol string posix)
      (setq posix (match-end 0))
      (setq counter (1+ counter)))
    counter))

(defvar eap-comment-ends-list
  (list (cons 'c++-mode
              (list (cons "//" "\n")(cons "[^/\"]/[*]" "[*]/")))
        (cons 'cdl-mode
              (list (cons "--" "\n")))
        (cons 'c-mode
              (list (cons "/[*]" "[*]/")))
        (cons 'emacs-lisp-mode
              (list (cons ";" "\n")))
        (cons 'ccl-mode
              (list (cons ";" "\n")))
        (cons 'lisp-mode
              (list (cons ";" "\n")))
        (cons 'edl-mode
              (list (cons "--" "\n")))
        (cons 'tcl-mode
              (list (cons "#" "\n")))
        )
  "*List associating major-mode with list of cons of regexps for comment ends"
  )
(defvar eap-next-comment-ends (cons 0 0)
  "Cons of comment end points found by last 'eap-in-comment.
If point is in comment, cdr is 0"
  )
(defun eap-in-comment ()
  "Check if point is in comment
Return cons cell of comment ends if in comment
Set eap-next-comment-ends"
  (let* ((comm-ends-list (cdr (assoc (or major-mode (eap-file-mode))
                                     eap-comment-ends-list)))
         (cur-pnt (point))
         comm-ends in-p beg end)
    (save-match-data
      (while (and (not in-p) comm-ends-list)
        (setq comm-ends (car comm-ends-list))
        (save-excursion
          (setq in-p (or (if (looking-at (car comm-ends))
                             (setq beg (point))
                           )
                         (save-excursion
                           (forward-char -1)
                           (if (looking-at (car comm-ends))
                               (setq beg (point)))
                           )
                         (and (if (re-search-backward (car comm-ends) nil t)
                                  (setq beg (max (or beg 0) (point))))
                              (if (re-search-forward (cdr comm-ends) cur-pnt t)
                                  (not (setq end (max (or end 0) (1- (point)))))
                                t))))
          (or in-p
              (setq comm-ends-list (cdr comm-ends-list)))
          )))
    (setcar eap-next-comment-ends (or beg 0))
    (setcdr eap-next-comment-ends (or end 0))
    (car comm-ends-list)
    )
  )
(defun eap-quit-comment (&optional backward skip-space-p)
  "Move point out of comment
Return non-nil if point was in comment.
If SKIP-SPACE-P, look for closest non-space symbol before comment check"
  (let* (in-p comm-ends)
    (if skip-space-p
        (if backward (skip-chars-backward " \t\n") (skip-chars-forward " \t\n"))
      )
    (save-match-data
      (while (and (not (if backward (bobp) (eobp)))
                  (setq comm-ends (or (eap-in-comment)
                                      (and backward (looking-at "$")
                                           (save-excursion
                                             (backward-char 1)
                                             (eap-in-comment)))))
                  )
        (setq in-p t)
        (if backward
            (let (at-beg-p)
              (goto-char (car eap-next-comment-ends))
              (while (looking-at (car comm-ends))
                ;;(setq at-beg-p t)
                (or (/= 0 (skip-chars-backward (car comm-ends)))
                    (backward-char 1))
                )
;;            (or at-beg-p
;;                (re-search-backward (car comm-ends) nil t))
              (and (looking-at "[ \t\n]")
                   (skip-chars-backward " \t\n")
                   ;;(skip-chars-backward "^ \t\n")
                   )
              )
          (if (looking-at "$")
              (forward-char 1)
            (re-search-forward (cdr comm-ends) nil t))
          (skip-chars-forward "[ \t\n]")
          )
        ))
    in-p)
  )
(defmacro eap-no-comment (backward-p &rest body)
  "Repeatedly execute the BODY while resulting point is in comment.
BODY is executed at least once.
BACKWARD-P means direction to exit from comment"
  `(let (eap-no-comment-in)
    (while (progn ,@body (and (not (if ,backward-p (bobp) (eobp)))
                              (eap-quit-comment ,backward-p)))
      (setq eap-no-comment-in t))
    eap-no-comment-in)
  )
(defun eap-progress-indicator (cur-val max-val &optional message symbol)
  "Send message MESSAGE or `Done: ' with the rest of line dot or SYMBOL filled
according to CUR-VAL to MAX-VAL ratio. SYMBOL must be number."
  (let* ((msg (or message "Done: "))
         (len-max (- (frame-width) (length msg) 2))
         (ind-len (round (/ (* cur-val len-max 1.0) max-val)))
         (init (or symbol ?.))
         )
    (message "%s %s" msg (make-string ind-len init))
    )
  )
(defun eap-matching-paren (&optional quiet-p)
  "Returns the position of the matchign paren or nil.
QUIET-P means not display errors"
  ;;;;;;;;  this is a modified copy of show-paren-function() from 
  ;;;;;;;;  paren.el
  (let (pos dir mismatch (oldpos (point)) err)
    (cond ((eq (char-syntax (preceding-char)) ?\))
               (setq dir -1))
          ((eq (char-syntax (following-char)) ?\()
           (setq dir 1)))
    (if dir
        (save-excursion
          (save-restriction
            ;; Scan across one sexp within that range.
            (condition-case err
                (setq pos (scan-sexps (point) dir))
              (error (or quiet-p (message "%s" err))))
            ;; See if the "matching" paren is the right kind of paren
            ;; to match the one we started at.
            (if pos
                (let ((beg (min pos oldpos)) (end (max pos oldpos)))
                  (and (/= (char-syntax (char-after beg)) ?\$)
                       (setq mismatch
                             (not (eq (char-after (1- end))
                                      ;; This can give nil.
                                      (matching-paren (char-after beg))))))))
            ;; If they don't properly match, use a different face,
            ;; or print a message.
            (if mismatch
                (not (or quiet-p (message "Paren mismatch")))
              pos)))))
  )
(defun on-last-line-p()
  (save-excursion
    (not (search-forward "\n" nil t)))
  )
(defun eap-first-line-p ()
  (save-excursion
    (not (search-backward "\n" nil t)))
  )
(defun my-next-line (&optional arg)
"Same as 'next-line but not cause error on the last line"
  (interactive)
  (let ((arg (if arg arg 1)))
    (if (on-last-line-p) nil (next-line arg)))
  )
(defun eap-scroll (&optional nbLines down-p)
  "Scroll buffer NBLINES up \(or down if DOWN-P is not nil).
If NBLINES is nil, scroll for the window heigth.
To be improved"
  (interactive)
  (let* ((ws (window-start))
         (we (window-end))
;;;      (win-area (* (window-height) (window-width)))
;;;      (max-lines (if down-p
;;;                     (if (> (- ws win-area) (point-min))
;;;                         (buffer-size);; no sence just large number
;;;                       (count-lines ws (point-min)))
;;;                   (if (> (point-max) (+ we win-area))
;;;                       (buffer-size)
;;;                     (count-lines we (point-max)))))
;;;      (lines (min max-lines (or nbLines (window-height))))
         (lines (or nbLines (window-height)))
         (sum (if eap-animation 0 lines))
         (parts '( 1 2 3 4 5 8 11 12   12 11 7 6 5 4 3 2 1))
         step-lines)
    (if (not eap-animation)
        (scroll-up (if down-p (- lines) lines))
      (condition-case nil
          (while (< sum lines)
            (setq step-lines
                  (if parts
                      (max 1 (round ( / (* lines (car parts)) 100)))
                    (max 1 (/ (- lines sum) 2))))
            (setq parts (cdr parts))
            ;;(setq step-nb (1+ step-nb))
            (setq sum (+ sum step-lines))
            (scroll-up (if down-p (- step-lines) step-lines))
            (sit-for 0))
        (error nil)
        )
      ;; control shot
      ;; for long not truncated lines
;;;      (and (null nbLines)
;;;        (condition-case nil
;;;            (while (if down-p
;;;                       (> (abs (- ws (window-end))) (window-width))
;;;                     (> (abs (- we (window-start))) (window-width)))
;;;              (scroll-up (if down-p -1 1))
;;;              (sit-for 0)
;;;              )
;;;          (error nil)))
      )
    sum)
  )

(defun eap-scroll-down (&optional nbLines)
  (interactive)
  (eap-scroll nbLines 'down))

(defun eap-set-pos-at-line (pos &optional lineNb)
  "Scroll buffer until POS is at LINENB of the window.
If LINENB is ommited, act like recenter. Negative LINENB
means LINENB form the window bottom. Return number of 
line scrolled."
  (let* ((home pos)
         (beg (window-start))
         (lineNb (if lineNb
                     (if (< lineNb 0)
                         (+ (window-height) lineNb -1) lineNb)
                   (/ (window-height) 2)))
         (homeWay (eap-count-lines home beg))
         (homeWay (if (< beg home) (- homeWay) homeWay))
         (lines (+ lineNb homeWay)))
    ;;message "lineNb: %s homeWay: %s lines %s" lineNb homeWay lines)
    (if (/= 0 lines)
        (condition-case nil
            (eap-scroll (abs (1+ lines)) (or (< home beg) (< 0 lines)))
          (error nil))
          )
    ;; control shot
;;;    (let ((cur-ws (window-start))
;;;       need-ws dir)
;;;      (save-excursion 
;;;     (goto-char pos)
;;;     (recenter lineNb)
;;;     (setq need-ws (window-start))
;;;     (setq dir (if (< cur-ws need-ws) 1 -1))
;;;     )
;;;      (while (/= cur-ws need-ws)
;;;     (scroll-up dir)
;;;     (sit-for 0)
;;;     (setq cur-ws (window-start))
;;;     ))
    )
  )

(defvar eap-tmp-buffer-name " eap-tmp-buffer"
  )
(defun eap-tmp-buffer (&optional file-or-buf)
  "Return hiden working buffer.
Buffer contents is the one of FILE-OR-BUF \(file-name or buffer).
Buffer contents remains unchanged if FILE-OR-BUF is t.
Buffer is empty in other cases."
  (let ((buf (get-buffer eap-tmp-buffer-name)))
    (and (null buf)
         (set-buffer (setq buf (get-buffer-create eap-tmp-buffer-name)))
         (setq buffer-undo-list '(t))
         )
    (if (null file-or-buf)
        nil
      (set-buffer buf)
      (set (make-local-variable 'after-change-functions) nil)
      (set (make-local-variable 'after-change-function) nil)
      (or (eq t file-or-buf)
	  (erase-buffer))
      (cond ((buffer-live-p file-or-buf)
	     (insert (save-excursion
		       (set-buffer file-or-buf)
		       (buffer-string)))
	     )
	    ((stringp file-or-buf)
	     (condition-case nil
		 (insert-file-contents file-or-buf)
	       (error nil))
	     )
	    ))
    buf)
  )
(defun eap-erase-buffer (buffer)
  "Like erase-buffer but accepts buffer as argument"
  (and (buffer-live-p buffer)
       (save-excursion
         (set-buffer buffer)
         (erase-buffer)))
  )
(defun eap-prepare-to-edit ()
  "Check major mode to set and load. If interactive, rehighlight buffer also.
Run 'eap-prepare-to-edit-hooks"
  (interactive)
  (sit-for 0)
  ;; store as visited
  (if buffer-file-name
      (eap-add-to-visited-files))
   ;; check major-mode
  (let ((mode (eap-file-mode)))
    (if (null mode)
        nil
      (setq major-mode mode)
      ;; call major-mode
      (if (string= mode-name "Fundamental")
          (funcall major-mode))
      ;; hilit
      (and (interactive-p)
           (member 'hilit19 features)
           (hilit-rehighlight-buffer)
           )
      ;; check read-only
      (if buffer-file-name
	  (setq buffer-read-only (not (file-writable-p (buffer-file-name)))))
      (run-hooks 'eap-prepare-to-edit-hooks)
      ))
  )

(defvar eap-back-file 0
  "Trace path through buffers led to one where this var is local.
Global value is a number of repeated 'eap-come-back-to-origin in one buffer")
(make-variable-buffer-local 'eap-back-file)

(defun eap-get-back-file ()
  "Result is for passing to 'eap-save-back-file after jump to other buffer or point"
  (cons (cons (or buffer-file-name (buffer-name)) (point))
        (if (local-variable-p 'eap-back-file)
            eap-back-file))
  )
(defun eap-save-back-file (start)
  "Keep the way back to file we came from
START is returned by eap-get-back-file"
  (setq eap-back-file start)
  (let* ((file-point (car start)))
    (message (substitute-command-keys
              (format "Type '\\[eap-come-back-to-origin]' for returning to `%s'"
                      (if (string= (car file-point) (or buffer-file-name (buffer-name)))
                          (cdr file-point)
                        (file-name-nondirectory (car file-point)))
                      )))
    )
  )
(defun eap-come-back-to-origin (kill-start)
  "Bring back the file you were before a jump to the visited file.
Prefix argument kills current buffer"
  (interactive "P")
  (if (not (local-variable-p 'eap-back-file))
      (message "Nowhere to return")
    (let* ((chain eap-back-file)
	   (this-buf (current-buffer))
	   (n (if (eq last-command 'eap-come-back-to-origin)
		  (default-value 'eap-back-file)
		(setq-default eap-back-file 0)))
	   (filePosToReturn (nth n eap-back-file))
	   (buf (or (get-buffer (car filePosToReturn))
		    (eap-find-file-noselect (car filePosToReturn) 'exist)))
	   )
      (if (null buf)
	  (message "Can't return to '%s'" (car filePosToReturn))
	(eap-jump-plus buf kill-start nil this-buf (cdr filePosToReturn))
	(set-buffer buf)
	(if (eq this-buf buf)
	    (setq-default eap-back-file (1+ n))
	  (setq eap-back-file (cdr chain)))
	)))
  )
(defun eap-jump-plus (target kill-source back-trace &optional source point line)
  "Jump to TARGET and do other things necessary after that.
TARGET is buffer or full file name.
If KILL-SOURCE, SOURCE buffer or current-buffer is killed and TARGET
is shown in current window. Otherwise, pop to TARGET in other window.
Move to POINT. Recenter position the POINT to be on LINE.
BACK-TRACE is returned by eap-get-back-file."
  (if target
      (let ((src (or source (current-buffer)))
	    (tgt (if (stringp target)
		     (eap-find-file-noselect target t)
		   target))
	    ;;(point (or point (point)))
	    )
	(if (not (eq src tgt))
	    (if (not kill-source)
		(pop-to-buffer tgt)
	      (if (buffer-live-p src) (kill-buffer src))
	      (switch-to-buffer tgt)
	      )
	  (if back-trace
	      (goto-char (cdr (car back-trace))))
	  (or kill-source
	      (select-window (display-buffer src 'other-window)))
	  )
	(and point
	     eap-animation
	     line
	     (sit-for 0)
	     (eap-set-pos-at-line point line))
	(if point (goto-char point))
	(eap-prepare-to-edit)
	(if back-trace (eap-save-back-file back-trace))
	t))
  )
(defvar eap-visited-files-buf-name "*visited-files*"
  "*Buffer name to store names of visited files")

(defun eap-add-to-visited-files (&optional file)
  "Store FILE name in buffer named as 'eap-visited-files-buf-name"
  (save-excursion
    (let* ((f (or file buffer-file-name))
	   (buf (get-buffer eap-visited-files-buf-name))
	   add-p)
      (and (boundp 'eap-enable-remember-visited)
	   eap-enable-remember-visited
	   f
	   (setq add-p t)
	   (null buf)
	   (let* ((dir (concat (eap-home) ".emacs-visited-files"))
		  (full-name (concat dir "/"
				     (getenv "USER") "_("
				     (eap-replace-all " " "_" (current-time-string)) ")"))
		  )
	     (or (file-exists-p dir)
		 (condition-case nil
		     (make-directory dir)
		   (error (setq full-name nil) ))
		 )
	     (setq buf (set-buffer (get-buffer-create eap-visited-files-buf-name)))
	     (setq buffer-file-name full-name)
	     )
	   )
      (and add-p
	   (set-buffer buf)
	   (goto-char (point-max))
	   (if (re-search-backward (format "^%s$" f) nil t)
	       (progn (eap-kill-line 'no-copy)
		      (goto-char (point-max)))
	     t)
	   (insert f "\n"))
      )
    )
  )

(add-hook 'find-file-hooks 'eap-add-to-visited-files)

(defun eap-show-visited-files ()
  "Show buffer collecting names of visited files.
This feature is controlled by 'eap-enable-remember-visited variable"
  (interactive)
  (switch-to-buffer (get-buffer-create eap-visited-files-buf-name)))

(defvar eap-buf-mgt-key-map nil
  "Keymap containing bindings to functions for buffer management"
  )
(defun eap-buf-mgt-map ()
  "Make and return 'eap-buf-mgt-key-map map"
  (if (keymapp 'eap-buf-mgt-key-map)
      eap-buf-mgt-key-map
    (define-prefix-command 'eap-buf-mgt-key-map)
    (global-set-key "\C-a"  'eap-buf-mgt-key-map)
    eap-buf-mgt-key-map)
  )

(defun shared-key()
;;;  (define-key esc-map         [delete] 'eap-kill-line)
;;;  (define-key esc-map         " "      'eap-prepare-to-edit)
  (define-key (eap-buf-mgt-map) "\C-v"   'eap-show-visited-files)
  ;;(global-set-key             [f4]     'eap-come-back-to-origin)
  )

(provide 'shared)
