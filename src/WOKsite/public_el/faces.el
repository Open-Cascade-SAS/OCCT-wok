;;;File		:faces.el
;;;Author	:Alexander GRIGORIEV
;;;Purpose	:
;;;History	:Tue Apr 11 19:01:47 2000 creation

(defun hilit-compiler-message-init()
  (message "Welcome to WOK compilation font-lock-mode")
  (make-local-variable 'font-lock-mode-hook)
  ;;
  ;; information face
  ;;
  (make-face 'i-face)
  (set-face-foreground 'i-face "DarkGreen")
  (defvar information-face 'i-face)
  ;;
  ;; compilating face
  ;;
  (make-face 'c-face)
  (set-face-foreground 'c-face "DarkSlateBlue")
  (defvar compilating-face 'c-face)
  ;;
  ;; warning face
  ;;
  (make-face 'w-face)
  (set-face-foreground 'w-face "brown")
  (defvar warning-face 'w-face)
  ;;
  ;; error face
  ;;
  (make-face 'e-face)
  (set-face-foreground 'e-face "red")
  (defvar error-face 'e-face)
  ;;
  ;; keywords face
  ;;
  (make-face 'k-face)
  (set-face-foreground 'k-face "blue")
  (defvar wok-keywords-face 'k-face)
  ;;
  ;; command prompt face
  ;;
  (make-face 'p-face)
  (set-face-foreground 'p-face "DarkBlue")
  (defvar cmdprompt-face 'p-face)

  (make-variable-buffer-local 'compiler-messages)

  (defvar compiler-messages nil  "*Default list of messages for font-lock")

  (setq compiler-messages
	'(
	  ("^:.+:.*\\[[0-9]+\\]>" . cmdprompt-face)
	  ("[a-z]+_[a-z]+\\[[0-9]+\\].*:.*>" . cmdprompt-face)
	  ;; information lines use information face
;;	  ("^\\(.+: [I|i]nformation : .*$\\)" . information-face)
;;	  ("^\\(Information: .*$\\)" . information-face)
	  ("^\\(Info[ ]*: .*$\\)" . information-face)
	  ("^make\\(:\\|\\[[0-9]+\\]:\\).*$" . information-face)
	  ;;
	  ;; warning lines use warning face
	  ;; for cdl tools
	  ;;
	  ("^\\(.+: Warning : .*$\\)" . warning-face)
	  ("^\\(Warning: .*$\\)" . warning-face)
	  ("^[ \t]*is newer than .*:.*$" . warning-face)
	  ;;
	  ;; for compilation
	  ;;
	  ("^------->.*$" .  compilating-face)
	  ;; for usual compilers
	  ("^[-_.\"A-Za-z0-9]+\\(:\\|, line \\)[0-9]+: [w|W]arning:.*$" . warning-face)
	  ("^.*line [0-9].*: [w|W]arning:.*$" . warning-face)
	  ("^.+\\(: [w|W]arning:.*$\\)" .  warning-face)
	  ;; error lines use error face
	  ;; for cdl tools
	  ("^\\(.+: [e|E]rror[ \t]*: .*$\\)" . error-face)
	  ("^\\(Error   : .*$\\)" . error-face)
	  ("^\\(Warning : .*$\\)" . warning-face)
	  ("^\\(Info    : .*$\\)" . information-face)
	  ;; for usual compilers
	  ("^[-_.\"A-Za-z0-9/]+\\(:\\|, line \\)[0-9]+: [e|E]rror:.*$" . error-face)
	  ("^.+\\(:\\|, line \\)[0-9]+: [e|E]rror:.*$" . error-face)
	  ("^.+\\(: [e|E]rror:.*$\\)" .  error-face)
	  ("^\\*\\*\\* Error code.*$" . error-face) 
	  ("\"\\([^,\" \n\t]+\\)\", lines? \\([0-9]+\\)[:., (-].*$" . error-face)
	 ;; for linker  

	  ;; essai juste pour le plaisir les commandes wok
	  ("\\(^\\|[ \t]+\\)\\([fWswu]create\\|[fsWup]info\\|w_info\\|wdrv\\|wsrc\\|winc\\|wlib\\|umake\\|wokcd\\|wokparam\\|wokprofile\\|wokinfo\\|wokclose\\|wokenv\\|woklocate\\|Wdeclare\\|info-config\\|[fs]-config\\|p-get\\|p-put\\|pinstall\\|wprepare\\|wprepare\\|wintegre\\|wstore\\|wnews\\|wpack\\)\\>" . wok-keywords-face)
	  ("\\(^\\|[ \t]+\\)\\(\\(cr\\|rm\\)\\(unit\\|wb\\)\\|wcd\\|\\(w\\|ws\\)ls\\|dsrc\\|father\\|make\\([ \t][^ \t]+\\)?\\)\\>" . wok-keywords-face)
	  ;; pour les meta
	  ("\\(^\\|[ \t]+\\)\\(winfo\\)\\>" . error-face)
	  ;; 	

	  )
	)
  


(setq font-lock-mode-hook 
	  '(lambda () (setq font-lock-keywords compiler-messages)))
(font-lock-mode 1)
)
