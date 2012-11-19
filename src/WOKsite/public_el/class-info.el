;;; class-info.el --- some info on C++ class contained in Cascade Software Factory

;;;Author       : Edward AGAPOV <eap@opencascade.com>
;;;History      : Thu Oct 11 2001       Edward AGAPOV   Creation

;;; Commentary:

;; Prerequisite: CSF environment to be set \(see 'eap-csf library)

;; Useful entries:
;; * eap-all-acceseble-fields
;; * eap-all-included
;; * eap-pearent
;; * eap-walk-over-inherited

(require 'eap-csf)

(defun eap-is-definition (file)
  (string-match "[.][gc]x*" file)
  )
(defun eap-all-acceseble-fields (type &optional type-names-p)
  "Return a list of all own and accessible inherited fields for class TYPE.
If TYPE-NAMES-P, return a list of field types."
  (let* (not-private-p res-list)
    (save-excursion
      (eap-walk-over-inherited
       '(lambda()
          ;;(message "%s" buffer-file-name)
          (setq res-list
                (append res-list 
                        (if (string-match "[.]cdl$" buffer-file-name)
                            (eap-all-fields-in-cdl type-names-p not-private-p)
                          (eap-all-fields-in-hxx type-names-p not-private-p))))
          (setq not-private-p t)
          ) ;; BODY
       type ;; SOURCE
       t    ;; THROUGHALL
       t    ;; DECLARATION-P
       )
      res-list))
  )

(defun eap-all-fields-in-cdl (&optional type-names-p not-private)
  "Return list of fields found in visited cdl file.
If TYPE-NAMES-P, return a list of field types.
NOT-PRIVATE makes ignore private fields."
  (goto-char (point-max))
  (re-search-backward "^\\s *fields\\>" nil t)
  (let* ((field-re (concat "^\\s *\\([,\t a-z0-9]+,[ \t]*\\)?\\(\\w+\\)\\s *:"
                           "\\s *\\(\\w+\\(\\s +from\\s +\\w+\\)?\\)"))
         (modif-re "\\(\\s +[^;]+\\|\\s *;\\)")
         (re (concat field-re modif-re))
         res-list res type-complete-p modificator rest)
    (while (re-search-forward re nil t)
      (setq type-complete-p (match-end 4))
      (setq modificator (eap-match-string 5))
      (setq rest (match-string 1))
      (setq res (if type-names-p (eap-match-string 3)(eap-match-string 2)))
      (if not-private
          (setq modificator (eap-replace-all "--[^\n]+" " " modificator)))
      (if (and not-private
               (not (string-match "[^a-z0-9]is[ \t\n]+\\(protected\\|public\\)" modificator)))
          (setq res nil)
        (if type-names-p
            ;; find field type
            (if type-complete-p
                (setq res (eap-cpp-style (eap-replace-all "[\t\n]" " " res)))
              (setq res (eap-find-pack-for-class res)))
          ;; get rest fields
          (let (start)
            (while (string-match "\\w+" (or rest "") start)
              (setq res-list (cons (eap-match-string 0 rest) res-list))
              (setq start (match-end 0))
              ))
          ))
      (if res
          (setq res-list (cons res res-list)))
      )
    res-list)
  )
(defun eap-all-fields-in-hxx (&optional type-names-p not-private)
  "Return list of fields found in visited hxx file.
If TYPE-NAMES-P, return a list of field types.
NOT-PRIVATE makes ignore private fields."
  (goto-char 1)
  (let* ((re "^\\s *\\(Handle\\s *[(_]\\s *\\)?\\([_a-z0-9]+\\)[*&) ]+\\([_a-z0-9]+\\)\\s *;")
         (cl (eap-class-name))
         (beg (re-search-forward (format "^\\s *class\\s +%s\\>" cl) nil t))
         res-list res type handle-p)
    (while (re-search-forward re nil t)
      (setq handle-p (match-end 1))
      (setq type (eap-match-string 2))
      (setq res (if type-names-p type (eap-match-string 3)))
      (or (string-match "^\\(class\\|return\\)" type)
          (and not-private
               (save-excursion
                 ;; check private
                 (re-search-backward "^\\s *\\(private\\|protected\\|public\\)\\s *:" beg t))
               (string-match "private" (eap-match-string 0)))
          (setq res-list (cons res res-list)))
      )
    res-list)
  )
(defun eap-all-included ()
  "Return list of types included into current one.
For C++ class file recursively collects included headers.
For CDL file return classes from 'used clause"
  (if (string-match "[.]cdl" buffer-file-name)
      (eap-all-included-in-cdl)
    (eap-all-included-in-cpp)
    ))
(defun eap-all-included-in-cpp (&optional avoid-list msg)
  "Return list of classes included in current C++ file excluding ones in AVOID-LIST.
If MSG, print message MSG plus visited include file name"
  (save-excursion
    (let (res-list cls ext)
      (goto-char 1)
      (while (re-search-forward
              "^[ \t]*#[ \t]*include[ \t][<\"]\\([_a-z0-9]+\\)[.]\\([hij]x*\\)[>\"]" nil t)
        (setq cls (eap-match-string 1)
              ext (eap-match-string 2))
        (and (if (member cls avoid-list)
                 (string-match "[ij]xx" ext)
               (setq res-list (cons cls res-list)))
             (save-excursion
               (let* ((file (eap-find-file-with-ext cls ext))
                      (buf (if file (eap-find-file-noselect file))))
                 (if buf
                     (progn 
                       (if msg (message "%s %s.%s" msg cls ext))
                       ;;(eap-message "%s.%s" cls ext)
                       (set-buffer buf)
                       (setq res-list
                             (append (eap-all-included-in-cpp (append res-list avoid-list) msg)
                                     res-list))
                       (kill-buffer buf)
                       ))
                 ))
             ))
      res-list))
  )

(defun eap-all-included-in-cdl (&optional avoid-list)
  "Return list of used classes or packages in current CDL file excluding ones in AVOID-LIST"
  (save-excursion
    (goto-char 1)
    (if (not (re-search-forward "^\\([^-\n]*[ \t]\\)?uses[ \t\n]+" nil t))
        nil
      (let* ((package-p (not (string-match "_" (eap-class-name))))
             (re "\\(\\w+\\)\\(\\s +from\\s +\\(\\w+\\)\\)?[ \t\n]*")
             res-list end-p cls pack)
        (while (and (not end-p)
                    (looking-at re))
          ;; get current
          (setq cls (eap-match-string 1))
          (setq pack (eap-match-string 3))
          ;; look for next
          (goto-char (match-end 0))
          (while (looking-at "--")
            ;; skip comment
            (skip-chars-forward "^\n")
            (skip-chars-forward " \t\n"))
          (if (not (looking-at ","))
              (setq end-p t)
            (skip-chars-forward ", \t\n")
            (while (looking-at "--")
              (skip-chars-forward "^\n")
              (skip-chars-forward " \t\n"))
            )
          ;; add found to list
          (if package-p
              nil
            (if (null pack)
                (setq cls (eap-find-pack-for-class cls))
              (setq cls (concat pack "_" cls)))
            )
          (and cls
               (not (member cls avoid-list))
               (setq res-list (cons cls res-list)))
          )
        res-list)))
  )
(defun eap-pearent ()
  "Find the inherited class name"
  (if (eq 'cdl-mode (eap-file-mode))
      (eap-pearent-from-cdl)
    (eap-pearent-from-cxx))
  )
(defun eap-pearent-from-cxx ()
  (if buffer-file-name
      (save-excursion
        (let* ((hxx-p t)
               (cls (eap-class-name))
               (file-name (or (eap-find-file-with-ext cls "hxx" t)
                              (setq hxx-p nil)
                              (eap-find-file-with-ext cls "cdl" t)))
               pearent)
          (if file-name
              (let* ((buf (set-buffer (eap-find-file-noselect file-name))))
                (if hxx-p
                    (setq pearent (eap-pearent-from-hxx))
                  (setq pearent (eap-pearent-from-cdl)))
                (kill-buffer buf))
            )
          pearent))
    )
  )
(defun eap-pearent-from-hxx ()
  (save-excursion
    (let ((re (concat "class "
                      (eap-class-name (or buffer-file-name (buffer-name)))
                      "[ ]*:[ \t\n]*\\(public\\|private\\)?[  \t\n]*\\([^ \t\n]+\\)"))
          )
      (goto-char 1)
      (if (re-search-forward re nil t)
          (eap-match-string 2))))
  )
(defun eap-pearent-from-cdl ()
  (save-excursion
    (goto-char 1)
    (if (re-search-forward 
         (concat "^[^-\n]*inherits[\t\n\ ]+\\(\\w+\\)[\t\n\ ]+"
                 "\\(from[\t\n\ ]+\\(\\w+\\)\\)?")
         (save-excursion ;; this is a boundary for a search
           (re-search-forward "^[^-\n]*class[ \t\n]+" nil t)
           (re-search-forward "^[^-\n]*\\(uses\\|raises\\|is\\|class\\)[ \t\n]+" nil t))
         t)
        (let* ((cl (eap-match-string 1))
               (pack (eap-match-string 3)))
          (if (null pack)
              (eap-find-pack-for-class cl)
            (concat pack "_" cl)
            )))
    )
  )
(defun eap-all-def-files (class)
  "Find all CLASS definition files \(full names), searching in 'FILES'"
  (save-excursion
    (let* ((pack (eap-get-package-name class))
           (cls (eap-class-name class))
           (true-cls (eap-class-name-by-method-def class))
           (cls-re (concat "\\(" cls (if true-cls "\\|") true-cls "\\)"))
           (re (concat "^ *\\(" cls-re "_[^.]+[.][cgl]xx\\)"))
           (n 0)
           def-list wb-path stop-p)
      (while (and (not stop-p)
                  (setq wb-path (cdr (nth n csf-ref-list))))
        (setq n (1+ n))
        (let ((files-buf (eap-find-file-noselect (concat wb-path "src/" pack "/FILES")))
              def)
          (set-buffer files-buf)
          (setq stop-p (< 0 (buffer-size)))
          (while (re-search-forward re nil t)
            (if (setq def (eap-find-file-in (match-string 1)))
                (add-to-list 'def-list def))
            )
          (and true-cls
               (setq def (eap-find-source true-cls (not 'declaration)))
               (add-to-list 'def-list def))
          (kill-buffer files-buf)
          (if (setq def (eap-find-file-with-ext cls "lxx"))
              (add-to-list 'def-list def))
          ))
      (nreverse def-list)))
  )
(defvar eap-inherited-walked-over ()
  "List of files visited by 'eap-walk-over-inherited.
Files are without directory"
  )
(defun eap-walk-over-inherited (body source &optional throughAll declaration-p any-p)
  "Returns first non-nil result recieved when executing BODY, if THROUGHALL
is nil. If THROUGHALL is non-nil, returns last result.
SOURCE is either file or buffer or type to start from.
ANY-P allows walk to \(not DECLARATION-P) when DECLARATION-P not found"
  (save-excursion
    (let* ((def-files-list (if declaration-p '(t)))
           buffer result)
      (setq eap-inherited-walked-over nil)
      ;; find source buffer
      (if (bufferp source)
          (setq buffer source)
        (or (stringp source)
            (error "eap-walk-over-inherited: SOURCE is neither buffer nor string") )
        (let ((src (or (eap-find-source source declaration-p)
                       (if any-p (eap-find-source source (not declaration-p)))
                       )))
          (if src
              (setq buffer (eap-find-file-noselect src)))
          )
        )
      ;; walk trough parents
      (while (and (bufferp buffer)
                  (set-buffer buffer)
                  (add-to-list 'eap-inherited-walked-over
                               (file-name-nondirectory buffer-file-name))
                  (if (not throughAll)
                      (null (setq result (funcall body)))
                    (funcall body)
                    t))
        (let* (file)
          (or (eq t (car def-files-list))
              (progn
                ;; switch [cg]xx  -> *_1.[cg]xx -> lxx
                (or def-files-list
                    (setq def-files-list (eap-all-def-files buffer-file-name)))
                (setq file (car def-files-list))
                (setq def-files-list (or (cdr def-files-list)
                                         '(t)))
                ))
          ;; next inherited 
          (or file
              (and (setq file (eap-pearent))
                   (setq file (or (eap-find-source file declaration-p)
                                  (if any-p (eap-find-source file (not declaration-p)))))
                   (setq def-files-list (if declaration-p '(t))) ;; try all defs again
                   )
              )
          (or (eq buffer source)
              (kill-buffer buffer))
          (if file
              (setq buffer (eap-find-file-noselect file))
            (setq buffer nil))
          )
        )
      (and (buffer-live-p buffer)
           (not (eq buffer source))
           (kill-buffer buffer))
      result))
  )

(provide 'class-info)
