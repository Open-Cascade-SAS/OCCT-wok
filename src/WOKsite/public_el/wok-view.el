;; Default view for WOK in Emacs

;; Load color settings
;;(set-default-font "Courier New:14")
;(set-default-font "DejaVu Sans Mono Bold:14")
(if (>= emacs-major-version 20)
    (progn
      (message "Emacs 21!")
      (set-frame-width  (selected-frame) 120)
      (set-frame-height (selected-frame) 55))
    (progn
      (set-screen-width  120)
      (set-screen-height 55)))

;;(set-background-color "MidnightBlue")
(set-background-color "White")
(set-foreground-color "Black")
(load "theme-kgv")

;; no splash screen
(setq inhibit-splash-screen t)
;; no toolbar
;;(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
;;no menubar
;;(menu-bar-mode -1)
;; no scroll bar
;;(scroll-bar-mode -1)

(if (string-match "Emacs 22." (emacs-version))
    (progn
      ;; NT-emacs assumes a Windows command shell.
      (setq process-coding-system-alist '(("bash" . undecided-unix)))
      (setq shell-file-name "bash")
      (setenv "SHELL" shell-file-name)
      (setq explicit-shell-file-name shell-file-name)
      ;;
      ;; This removes unsightly ^M characters that would otherwise
      ;; appear in the output of java applications.
      ;;
      (add-hook 'comint-output-filter-functions
		'comint-strip-ctrl-m)
      ; in order to find header file like C-x C-f <iostream.h> RET
      (partial-completion-mode t)
      ; C++ mode indentation style
      (c-add-style "OCC" '("gnu" (c-offsets-alist (substatement-open . 0))))
      ))

(load "my_csf")

(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(c-offsets-alist (quote ((substatement-open . 0))))
 '(cvs-auto-remove-directories (quote empty))
 '(cvs-auto-remove-handled nil)
 '(font-lock-maximum-decoration (quote ((t . 2) (sgml-mode . 3))))
 '(font-lock-maximum-size (quote ((t . 20000000)))))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(cvs-handled ((((class color) (background light)) (:foreground "pink3"))))
 '(cvs-msg ((t (:foreground "magenta4" :slant italic))))
 '(cvs-need-action ((((class color) (background light)) (:foreground "orange3"))))
 '(font-lock-builtin-face ((((class color) (background light)) (:foreground "CadetBlue4"))))
 '(font-lock-string-face ((((class color) (background light)) (:foreground "RosyBrown4")))))

(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)

;; ABV settings
(load "abv-keys.el")
(load "eap-pc-mode.el")
(eap-pc-mode-key)
