(if (string-match "Emacs 22" (emacs-version))
    (progn
      (setq show-paren-delay 0.5)
      (setq fill-column 78)
      (custom-set-variables
       '(font-lock-maximum-size (quote ((t . 20000000))))
       '(font-lock-maximum-decoration (quote ((t . 2) (sgml-mode . 3))))
       )
      (set-scroll-bar-mode 'right)
      (put 'scroll-bar-width 'x-frame-parameter 10)
      )
)

(load "faces")

;; csf/emacs in the load-path
(setq load-path (cons (concat (getenv "WOKHOME") "/lib") load-path))
(if (not (boundp 'woksh))
    (progn
        (load-library "woksh")
    )
)

(global-set-key (quote [home]) (quote beginning-of-buffer))
(global-set-key (quote [end]) (quote end-of-buffer))
(global-set-key "" (quote kill-this-buffer))
(global-set-key (quote [f2]) (quote save-buffer))
(global-set-key (quote [f3]) (quote find-file-at-point))
(global-set-key (quote [f4]) (quote ediff-buffers))
(global-set-key (quote [f5]) (quote goto-line))
(global-set-key (quote [S-f5]) (quote jump-to-register))
(global-set-key (quote [C-S-f5]) (quote point-to-register))
(global-set-key (quote [f6]) (quote font-lock-mode))
(global-set-key (quote [f7]) (quote blink-matching-open))
(global-set-key (quote [f8]) (quote find-alternate-file))
(global-set-key (quote [f9]) (quote compile))
(global-set-key (quote [C-tab]) (quote tab-to-tab-stop))
(global-set-key (quote [C-g]) (quote keyboard-quit))
(global-set-key "	" (quote agv-indent-by-tab))
(global-set-key " " (quote agv-indent-by-space))

(auto-compression-mode 1)
(set-language-environment "Latin-1")
(show-paren-mode t)

(defun csf-fortran-mode-init()
  (setq font-lock-maximum-decoration 2)
  (font-lock-mode 1))

(defun csf-c-mode-init()
  (setq font-lock-maximum-decoration 2)
  (font-lock-mode 1))

(defun agv-indent-by-space ()
  (interactive)
  (setq indent-tabs-mode nil))

(defun agv-indent-by-tab ()
  (interactive)
  (setq indent-tabs-mode t))

(defun agv-toggle-c-mode ()
  (interactive)
  (if (string-equal mode-name "C++")
      (c-mode)
    (if (string-equal mode-name "C") (c++-mode))))

; project specific settings
(load-library "csf-cdl-mode")
;(load-library "csf-c++-mode")
(load "occ-c++-mode")
(occ-header-key)	;C-c f1
(occ-set-c++-file-header)

(setq auto-mode-alist (cons (cons "\\.cpp$" 'c++-mode) auto-mode-alist))
(setq auto-mode-alist (cons (cons "\\.cxx$" 'c++-mode) auto-mode-alist))
(setq auto-mode-alist (cons (cons "\\.lxx$" 'c++-mode) auto-mode-alist))
(setq auto-mode-alist (cons (cons "\\.ixx$" 'c++-mode) auto-mode-alist))
(setq auto-mode-alist (cons (cons "\\.gxx$" 'c++-mode) auto-mode-alist))
(setq auto-mode-alist (cons (cons "\\.pxx$" 'c++-mode) auto-mode-alist))
(setq auto-mode-alist (cons (cons "\\.cdl$" 'cdl-mode) auto-mode-alist))
(setq auto-mode-alist (cons (cons "\\.edl$" 'edl-mode) auto-mode-alist))

(autoload 'cdl-mode "cdl-mode")
(autoload 'edl-mode "edl-mode")

(add-hook 'cdl-mode-hook 'csf-cdl-mode-init)
(add-hook 'c-mode-hook 'csf-c-mode-init)
(add-hook 'c++-mode-hook 'csf-c++-mode-init)
(add-hook 'fortran-mode-hook 'csf-fortran-mode-init)

(if (string-match "Emacs 22." (emacs-version))
;;	Emacs.22 customisation
    (progn
      (defface font-lock-builtin-face
	'((((class grayscale) (background light)) (:foreground "LightGray" :bold t))
	  (((class grayscale) (background dark)) (:foreground "DimGray" :bold t))
	  (((class color) (background light)) (:foreground "CadetBlue"))
	  (((class color) (background dark)) (:foreground "LightSteelBlue"))
	  (t (:bold t)))
	"Font Lock mode face used to highlight builtins."
	:group 'font-lock-highlighting-faces)
      (defface font-lock-type-face
	'((((class grayscale) (background light)) (:foreground "Gray90" :bold t))
	  (((class grayscale) (background dark)) (:foreground "DimGray" :bold t))
	  (((class color) (background light)) (:foreground "ForestGreen" :italic t))
	  (((class color) (background dark)) (:foreground "PaleGreen"))
	  (t (:bold t :underline t)))
	"Font Lock mode face used to highlight type and classes."
	:group 'font-lock-highlighting-faces))

;;	Emacs.19 customisation
  (setq font-lock-face-attributes
	'((font-lock-comment-face "Firebrick")
	  (font-lock-string-face "RosyBrown")
	  (font-lock-keyword-face "Purple")
	  (font-lock-function-name-face "Blue")
	  (font-lock-variable-name-face "DarkGoldenrod")
	  (font-lock-type-face "DarkGreen")
	  (font-lock-reference-face "CadetBlue"))))

(defvar ps-paper-type 'ps-a4
  "*Specifies the size of paper to format for.  Should be one of
`ps-letter', `ps-legal', or `ps-a4'.")
(defvar ps-left-margin 72)		; 1 inch
(defvar ps-right-margin 24)		; 1/3 inch
(defvar ps-bottom-margin 36)		; 1/2 inch
(defvar ps-top-margin 36)		; 1/2 inch
(defvar ps-font-size 7
  "*Font size, in points, for generating Postscript.")

(defvar ps-avg-char-width (if (fboundp 'float) 4.5 5.35)
  "*The average width, in points, of a character, for generating Postscript.
This is the value that ps-print uses to determine the length,
x-dimension, of the text it has printed, and thus affects the point at
which long lines wrap around.  If you change the font or
font size, you will probably have to adjust this value to match.")

(defvar ps-space-width (if (fboundp 'float) 4.5 5.35)
  "*The width of a space character, for generating Postscript.
This value is used in expanding tab characters.")

(defvar ps-line-height (if (fboundp 'float) 8.1 8)
  "*The height of a line, for generating Postscript.
This is the value that ps-print uses to determine the height,
y-dimension, of the lines of text it has printed, and thus affects the
point at which page-breaks are placed.  If you change the font or font
size, you will probably have to adjust this value to match.  The
line-height is *not* the same as the point size of the font.")

;(add-hook 'shell-mode-hook 'cv5-shell-mode)
;(defun cv5-shell-mode ()
;;  (load-library "cv5")
;)
