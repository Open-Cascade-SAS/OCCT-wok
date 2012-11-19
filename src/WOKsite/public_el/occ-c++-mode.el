;;;File         :occ-c++-mode.el
;;;Author       :MSV
;;;Purpose      :Emacs adjustments for project OCC

(defun occ-set-c++-file-header ()
  "Sets OCC style header at beginning of a C++ buffer"
  (interactive)
  (defun c++-file-header ()
    "insert a header at beginning of buffer"
    (interactive)
    (beginning-of-buffer)

    (insert   "// File:      " (buffer-name))
    (insert "\n// Created:   " (format-time-string "%d.%m.%y %H:%M:%S"))
    (insert "\n// Author:    " (concat (user-login-name) "@" (system-name)))
    (insert "\n// Copyright: Open CASCADE " (format-time-string "%Y") "\n"))
  (setq current-c++-file-header 'occ-set-c++-file-header)
  (message "OCC style C++ header is set"))

(defun c++-new-file-header ()
  "insert a header at beginning of buffer"
  (interactive)
  (c++-file-header)

  (cond
   ((string-match "\\.hxx$" (buffer-name))
    (let* ((classname  (substring (buffer-name) 0 -4))
          (headername (concat classname "_HeaderFile")))
      (insert "\n#ifndef " headername)
      (insert "\n#define " headername)
      (insert "\n\n#include \n")
      (insert "\n//  Block of comments describing class " classname "\n//\n")
      (insert "\nclass " classname " ") (setq p (point))
      (insert "\n{\npublic:")
      (insert "\n  // ---------- PUBLIC METHODS ----------\n")
      (insert "\n  " classname "() {}")
      (insert "\n  // Empty constructor\n")
      (insert "\n  Standard_EXPORT " classname "(const " classname "& theOther);")
      (insert "\n  // Copy constructor\n")
      (insert "\n  Standard_EXPORT virtual ~" classname "();")
      (insert "\n  // Destructor\n")
      (insert "\n\n\nprotected:")
      (insert "\n  // ---------- PROTECTED METHODS ----------\n")
      (insert "\n\n\nprivate:")
      (insert "\n  // ---------- PRIVATE FIELDS ----------\n")
      (insert "\n\n\npublic:")
      (insert "\n  // Declaration of CASCADE RTTI")
      (insert "\n  //DEFINE_STANDARD_RTTI(" classname ")")
      (insert "\n};\n")
      (insert "\n// Definition of HANDLE object using Standard_DefineHandle.hxx")
      (insert "\n//DEFINE_STANDARD_HANDLE(" classname ", )\n")
      (insert "\n#endif\n")
      (goto-char p)))

   ((string-match "\\.cxx$" (buffer-name))
    (let ((classname  (substring (buffer-name) 0 -4)))
      (insert "\n#include <" classname ".hxx>\n")
      (insert "\n//=======================================================================")
      (insert "\n//function : " classname)
      (insert "\n//purpose  : Constructor")
      (insert "\n//=======================================================================\n\n")
      (insert classname "::" classname "()") (setq p (point))
      (insert "\n{\n}\n")
      (goto-char p)))
   ))

(occ-set-c++-file-header)

(defun csf-c++-mode-init ()
  (abbrev-mode 1)
  (if (zerop (buffer-size))     ; insert in new files
      (c++-new-file-header))
  (setq font-lock-maximum-decoration 2)
  (font-lock-mode 1)
  (setq indent-tabs-mode nil)
  (if (string-match "Emacs 21" (emacs-version))
      (c-set-style "OCC"))
  (setq c-continued-brace-offset -2) ;; for "{" style
  (funcall current-c++-file-header))

(defun occ-header-key ()
  (define-key mode-specific-map [f1] 'occ-set-c++-file-header))
