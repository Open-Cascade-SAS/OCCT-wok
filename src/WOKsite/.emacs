;; .emacs file for CSF Factory

;; Setup path to WOK configuration scripts
(setq load-path (cons (concat (getenv "WOKHOME") "/site/public_el") load-path))

;; Load useful commands and setup default theme
(load "wok-view.el")

;; Launch TCL shell
(load "tclsh.el")
(tclsh)
