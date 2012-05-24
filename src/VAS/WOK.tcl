;#
;# Liste des toolkits WOK sous forme de full path
;# 
proc WOK:toolkits { } {
    return {TKWOK TKWOKTcl TKTCPPExt TKCDLFront TKCPPExt TKCPPClient TKIDLFront TKCPPJini TKCPPIntExt TKCSFDBSchema}
}
;#
;# Autres UDs a prendre. Listes de triplets
;# { ar typ UD str } Tous les types de UD vont dans un sous directory nomme root/str
;# Ils seront dans CAS3.0/str de l'archive de type ar (source/runtime)
;# { ar typ UD {}  } Tous les types de UD vont dans root/UD/src => CAS3.0/src
;#
proc WOK:ressources { } {
    return [list \
		[list both r WOKBuilderDef {}]\
		[list both r WOKStepsDef {}]\
		[list both r WOKEntityDef {}]\
		[list both r WOKTclLib {}] \
		[list both r WOKsite {}] \
		[list both x WOKSH {}] \
		[list both x WOKLibs {}] \
	    ]
}
;#
;# retourne une liste de triplets {type <full path1> <target directory>/name}
;# permet de faire : cp <full path> $CASROOT/<target directory>/name
;# On peut ainsi embarquer des fichiers d'un peu partout et les dispatcher sous 
;# la racine d'arrivee et ce avec un autre nom.
;# rien n'empeche de CALCULER automatiquement des paths dans cette proc.
;# type = source/runtime/both pour dire si le fichier va dans l'archive en question.
;# une deux (ou les deux) type d'archive fabriquees. 
;#
proc WOK:freefiles { } {
    return 
}
;#
;# Nom du module 
;#
proc WOK:name { } {
    return WOK
}
;#
;# Nom du module 
;#
proc WOK:alias { } {
    return WOK
}
;#
;#
;#
proc WOK:depends { } {
    return {}
}
;#
;# Pre-requis pour la compilation ( -I ... )
;# Returns a list of directory that should be used in -I directives
;# while compiling c or c++ files.
;#
proc WOK:CompileWith { {plat {}}} {
    
    set l {}
    switch -- [OS:os] {
	HP-UX {
	}
	Linux {
	    lappend l "-I[lindex [wokparam -v %CSF_JavaHome] 0]/include"
	    lappend l "-I[lindex [wokparam -v %CSF_JavaHome] 0]/include/linux"
	    lappend l "[lindex [wokparam -v %CSF_TCL_HOME] 0]/include"
           lappend l "[lindex [lindex [wokparam -v %STLPortInclude] 0] 0]" 
	}

	SunOS {
	    lappend l "/usr/openwin/include"
	    lappend l "/usr/dt/include"
	    lappend l "[lindex [wokparam -v %CSF_CXX_INCLUDE] 0]"
	    lappend l "-I[lindex [wokparam -v %CSF_JavaHome] 0]/include"
	    lappend l "-I[lindex [wokparam -v %CSF_JavaHome] 0]/include/solaris"
	    lappend l "[lindex [wokparam -v %CSF_TCL_HOME] 0]/include"
	}

	IRIX {
	}
    }
    return $l
}
;#
;# Pre-requis pour la compilation ( -L ... )
;# Returns a list of directory that should be used in -L directives
;# while creating shareable.
;#
proc WOK:LinksoWith {{plat {}} } {
    
    set l {}
    switch -- [OS:os] {
	HP-UX {
	}
	Linux {
	    lappend l /usr/X11R6/lib
	}

	SunOS {
	    lappend l "-L[wokparam -v %CSF_TCL_HOME]/lib -R[wokparam -v %CSF_TCL_HOME]/lib -ltcl"
	    lappend l "-L[wokparam -v %CSF_TCL_HOME]/lib -R[wokparam -v %CSF_TCL_HOME]/lib -ltk"
	}

	IRIX {
	}
    }
    return $l
}
;#
;# Returns a list of exported features.
;# source : Source files
;# runtime: Shareables
;# wokadm : WOK admin files
;# api    : Public include files
;#
proc WOK:Export { } {
    return [list source runtime wokadm api]
}
