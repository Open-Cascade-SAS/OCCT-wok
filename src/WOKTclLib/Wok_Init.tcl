
auto_load wok_cd_proc
auto_load wok_exit_proc
auto_load wok_source_proc
auto_load wok_setenv_proc
auto_load wokemacs

if { [info commands tcl_exit_proc] == "" } {
    rename exit tcl_exit_proc
    rename wok_exit_proc exit
}

set tcl_prompt1 {if {[info commands wokcd] != ""}  then {puts -nonewline stdout "[wokcd]> "} else {puts -nonewline stdout "tclsh> "}}

global WOK_GLOBALS;

set WOK_GLOBALS(setenv_proc,term)  1
set WOK_GLOBALS(setenv_proc,emacs) 1
set WOK_GLOBALS(setenv_proc,tcl)   0

set WOK_GLOBALS(cd_proc,term)      1
set WOK_GLOBALS(cd_proc,emacs)     1
set WOK_GLOBALS(cd_proc,tcl)       1

set WOK_GLOBALS(source_proc,term)  1
set WOK_GLOBALS(source_proc,emacs) 1
set WOK_GLOBALS(source_proc,tcl)   1

set WOK_GLOBALS(wokinterp,tclcommands) "Winfo|finfo|pinfo|screate|sinfo|srm|ucreate|uinfo|umake|urm|w_info|wcreate|wokcd|wokclose|wokinfo|wokparam|wokprofile|wokenv|wrm|wmove|msclear|wprepare|wstore|wintegre|upack|iwok|wsrc|wdrv|wls|wcd|cd"
