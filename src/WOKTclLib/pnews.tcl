#############################################################################
#
#                              P N E W S
#                              _________
#
#############################################################################
#
# Usage
#
proc wokpnewsUsage { } {
    puts stderr \
	    {
	Usage  : pnews [-h]   [-parcel <p1,p2,..>] 

    }
}
#
# Point d'entree de la commande
#
proc pnews { args } {

    set tblreq(-h)      {}
    set tblreq(-parcel) value_required:string

    set param {}
    if { [wokUtils:EASY:GETOPT param tabarg tblreq wokpnewsUsage $args] == -1 } return


    if { [info exists tabarg(-h)] } {
	wokpnewsUsage 
	return
    }

    set VERBOSE [info exists tabarg(-v)]
    
    if { [info exists tabarg(-parcel)] } {
	pnews:journal $tabarg(-parcel) 
	return
    }

    return 
}
#
# Retourne la liste des Uls du bag de <factory> se trouvant listes dans <config>
#
proc pnews:journal { {regx *} } {
    wokBAG:label:dump JNL long
    set blank "                                                             "
    if [array exists JNL] {
	set i 0
	foreach n [lsort -command wokUtils:TIME:clrsort [array names JNL]] {
	    set i [incr i]
	    set pnam [lindex [split $JNL($n)] 0]
	    if [string match $regx $pnam] {
		set b [string range $blank 1 [expr {30 - [string length $pnam] }]]
		puts [format "%3d - %s%s (Done at %s)" $i $pnam $b $n  ]
	    }
	}
    }
    return
}
