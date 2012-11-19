; dummy (set-mouse-color "White")
;; Colors for dark background for C++ and Emacs lisp
;; and syntax hylighting for C++
;; NOTE: background color is to be defined elsewhere
;; Defines function det-reset-colors-dark, calls it
;; and defines keys A-q and M-q as shortcuts

;(global-set-key [A-C-return] 'list-text-properties-at)
;(global-set-key [?\M-f] 'list-faces-display)

(set-background-color "MidnightBlue")  ;; background
(set-foreground-color "White")  ;; text
(set-cursor-color "White")      ;; text cursor
(set-mouse-color "White")       ;; mouse cursor (frame-parameters)
;(setq x-pointer-shape 68)      ;; select mouse cursor shape - does it work?

;; C++ syntax hilighting
(hilit-set-mode-patterns
  'c++-mode
  '(
    ( "//.*$" nil comment )
;    ( "/[*]\\([^/]\\|\\([*][^/]\\)\\)*[*]/" nil comment )
    ( "#.*" nil string )  ; preprocessor
;    ( "\"\\([^\\\"\n]\\|\\(\\$\\)\\)*\"" nil string )
    ( "\"(.*)[\"\n]" nil string )
;    ( "cout.*endl" nil decl )
;    ( "([0-9]+[.]?|[0-9]*[.][0-9]+)([EeDd][+-]?[0-9]+)?" nil decl )
    ( "\\<\\(\\(\\([0-9]+\\([.]?\\)\\)\\|\\([0-9]*[.]\\([0-9]+\\)\\)\\)\\([EeDd]\\([+-]?\\)\\([0-9]+\\)\\)?\\)\\>" nil decl )
;    ( "[0-9]+" nil decl )
;    ( "\\([^ (){}=\n]*\\)::\\([^ (){}=\n]*\\)" nil warning )
;    ( "\\<\\(return\\|goto\\|if\\|else\\|case\\|default\\|switch\\|break\\|continue\\|while\\|do\\|for\\|catch\\|try\\|new\\|const\\|static\\|class\\|struct\\|Handle\\)\\>" nil include )
    ( "\\<\\(return\\|return\\|if\\|else\\|case\\|default\\|switch\\|break\\|continue\\|while\\|do\\|for\\)\\>" nil include )
    ( "\\<\\(catch\\|try\\|new\\|const\\|static\\|void\\|Handle\\|cin\\|cout\\|cerr\\|endl\\)\\>" nil include )
    ( "\\<\\(goto\\|public\\|private\\|protected\\|class\\|struct\\|enum\\|extern\\|int\\|char\\|float\\|double\\|short\\|long\\)\\>" nil include )
;    ( "(\\|)\\|[[]\\|[]]\\||\\|&\\|+\\|-\\|=\\|*\\|/" nil include )
;    ( "\\<[A-Za-z_][A-Za-z_0-9]*\\>" nil italic )
;    ( "\\<[0-9][A-Za-z_0-9]*\\>" nil error )
    ()
    nil 'case-sensitive
   )
)

;; Colors for different text styles
;; NOTE: may need to change for different Emacs installations
(defun det-reset-colors-dark () "(Re)Set colors for dark background" (interactive)
  (if (not (getenv "DISPLAY")) t
    ;; csf favorite colors
    ;; Face for keywords bold
;    (set-face-foreground 'bold "cyan")
    ;; Face for comments italic
    ;;(make-face-italic 'italic)
;    (set-face-foreground 'italic "bisque")
    ;;Face for rubrics bold-italic
;    (set-face-foreground 'bold-italic "gray30")
;    (set-face-background 'bold-italic "gray80")
    ;; Face for region highlighting
    (set-face-underline-p 'region nil) ; t)
    (set-face-foreground 'region "Black")
    (set-face-background 'region "LightGray")

    (set-face-background 'default "MidnightBlue")
    (set-face-foreground 'default "White")

    (or (facep 'RoyalBlue)
	(make-face 'RoyalBlue))
    (set-face-foreground 'RoyalBlue "SkyBlue")  ;; keywords in lisp
    
    (or (facep 'blue-bold)
	(make-face 'blue-bold))
    (set-face-foreground 'blue-bold "SkyBlue")  ;; defun's in lisp
    (or (facep 'grey40)
	(make-face 'grey40))
    (set-face-foreground 'grey40 "LimeGreen") ;; strings in lisp

;    (set-face-foreground 'blue-italic "Yellow") ;; identifiers in cxx
    (or (facep 'purple)
	(make-face 'purple))
    (set-face-foreground 'purple "SkyBlue")  ;; keywords in cxx
;    (set-face-foreground 'font-lock-reference-face "Green") ;; #include
    (or (facep 'firebrick-italic)
	(make-face 'firebrick-italic))
    (make-face-unitalic 'firebrick-italic)

    (set-face-foreground 'firebrick-italic "Magenta")  ;; Orchid ;; comments //
    (make-face-unitalic 'italic)
    (set-face-foreground 'italic "Yellow")  ;; identifiers in cxx
    (and (string-match "linux" system-configuration)
	 (facep 'i-face)
	 (set-face-foreground 'i-face "Green")  ;; Info messages in log files
	 )

;    (set-face-foreground 'bold-italic "Red")

    (if (facep 'font-lock-string-face)
      (progn
	(set-face-foreground 'font-lock-string-face "LimeGreen") ;; strings in cxx
	(set-face-foreground 'font-lock-type-face "SkyBlue") ;; ?? in cxx
	(set-face-foreground 'font-lock-comment-face "Magenta") ;; Orchid ;; comments /* */
	(set-face-foreground 'font-lock-keyword-face "SkyBlue") ;; keyword in CDL
	(set-face-foreground 'font-lock-function-name-face "Turquoise")  ;; names in edl
	(set-face-foreground 'font-lock-variable-name-face "Yellow")     ;; variables in edl
      )
    )
  )
)

(if (not (string-match "linux" system-configuration)) ;;"i386-mandrake-linux-gnu"
    (det-reset-colors-dark)
)

; set C++ highlighting for SWIG interface files (*.i)
(add-to-list 'auto-mode-alist '("\\.i$" . c++-mode))

(global-set-key [?\M-q] 'det-reset-colors-dark)
(global-set-key [?\A-q] 'det-reset-colors-dark)
