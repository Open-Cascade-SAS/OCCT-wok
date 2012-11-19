;; abv 21.05.2009
;; 
;; This file defines a number of keyboard shortcuts taken from obsolete det
;; settings to complete the state-of-the-art eap and msv settings
;;
;; Current version is for Windows only

; global shortcuts for tools
(define-key global-map [C-f1] 'describe-key) ; Ctrl-F1 runs help on following command
(define-key global-map [C-S-f1] 'describe-function) ; Ctrl-F1 runs help on function
(define-key global-map [S-f2] 'grep)         ; Shift-F2 runs grep
(define-key global-map [M-return] 'tclsh)    ; Alt-Enter runs woksh

; windows and buffers management
(define-key global-map [C-tab] 'other-window); Ctrl-Tab switches subwindows
(define-key global-map [?\M-0] 'buffer-menu) ; Alt-0 runs buffer list
(define-key global-map [C-f4] 'kill-this-buffer)
(define-key global-map [f6] 'bury-buffer)
(define-key global-map [f5] 'delete-other-windows)
(define-key global-map [C-f5] 'split-window-vertically)

;; switch mode of truncatiion of lines
(defun det-switch-truncating () (interactive)
  (setq truncate-lines (not truncate-lines))
  (redraw-display)
)
(global-set-key [?\C-t] 'det-switch-truncating)

;; commands to scroll buffer by single line (rather than by paragraph)
(defun det-scroll-up ()   "Scrolls text up"   (interactive)
  (scroll-down-nomark 1)
  (previous-line-nomark 1)
)
(defun det-scroll-down () "Scrolls text down" (interactive)
  (scroll-up-nomark 1)
  (next-line-nomark 1)
)
(define-key global-map [C-up] 'det-scroll-up)
(define-key global-map [C-down] 'det-scroll-down)

; other commands to make editors behaving in more conventional way
(define-key global-map [C-delete] 'kill-word)
(define-key global-map [?\C-y] 'kill-whole-line)
(define-key global-map [?\C-.] 'forward-sexp)
(define-key global-map [?\C-,] 'backward-sexp)

; commands to make right keypad to work with Shift and Control modifiers
; see det-keys.el for similar commands for other platforms
(define-key global-map [C-kp-insert] 'copy-region-as-kill-nomark)
(define-key global-map [S-kp-insert] 'yank)
(define-key global-map [S-kp-delete] 'kill-region)

; Lisp mode shortcuts to easily evaluate edited Lisp command
(define-key lisp-mode-map [C-return] 'eval-last-sexp)
(define-key emacs-lisp-mode-map [C-return] 'eval-last-sexp)
