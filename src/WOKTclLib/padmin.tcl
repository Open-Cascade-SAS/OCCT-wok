 
#############################################################################
#
#                              P A D M I N
#                              ___________
#
#############################################################################
#
# Usage
#
proc padminUsage { } {
    puts stderr \
	{
    Usage : padmin [ options ... ] [pnam,...]
	
    This command operates on elements in the central BAG. 

    Components: A component represents an UL and all its versions

    -param       : List parameters relative to the BAG.

    -ls          : List kwown components. 
    -rm          : Deletes the components pnam1,pnam2 ... This will destroy the VOB associated and all
                   label attached to it in the Admin VOB. 
    
    -mkadm       : Creates the vob administration. 
    
    -noexec      : Don't execute. Only display script file.

    Types: Set of rules used to store files.

    -lsext       : List known extensions. For more information, use -magic and explore 
                   the magic file.

    
    }
    return
}   
#
# Point d'entree de la commande
#
proc padmin { args } {
    
    set tblreq(-h)         {}
    
    set tblreq(-mkadm)     {}
    set tblreq(-noexec)    {}
    set tblreq(-rm)        value_required:list

    set tblreq(-lsext)     {}

    set tblreq(-ls)        value_required:string

    set tblreq(-magic)     {}

    set tblreq(-param)     {}

    set param {}
    
    if { [wokUtils:EASY:GETOPT param tabarg tblreq padminUsage $args] == -1 } return
    
    if { [info exists tabarg(-h)] } {
	padminUsage
	return
    }

    if { [info exists tabarg(-param)] } {
	padmin:param
	return
    }


    set execute 1
    if { [info exists tabarg(-noexec)] } { set execute 0 }

    if { [info exists tabarg(-mkadm)] } {
	set lvws [concat [wokBAG:view:Init IMPORT] [wokBAG:view:Init EXPORT]]
	padmin:execute [wokUtils:EASY:stobs2 $lvws] $execute
	set ladm [wokBAG:admin:Create]
	padmin:execute [wokUtils:EASY:stobs2 $ladm] $execute
	return
    }

    if { [info exist tabarg(-rm)] } {
	foreach pnam $tabarg(-rm) {
	    set res [wokBAG:cpnt:Del $pnam]
	    foreach lbs [wokBAG:cpnt:Patches $pnam] {
		set res [concat $res [wokBAG:label:Del $lbs]]
	    }
	    padmin:execute $res $execute
	}
	return
    }

    
    
    if { [info exist tabarg(-ls)] } {
	puts "not yet"
    }


    if { [info exist tabarg(-lsext)] } {
	foreach e [wokBAG:magic:kex] {
	    puts $e
	}
	return
    }

    if { [info exist tabarg(-magic)] } {
	foreach e [wokUtils:LIST:SortPurge [wokBAG:magic:Name]] {
	    puts "$e"
	}
	return
    }
    


}
;#
;#
;#
proc padmin:execute { res execute } {
    if { $execute } {
	wokUtils:FILES:ListToFile $res execute
	wokUtils:EASY:Execute execute
	unlink execute
    } else {
	foreach l $res {
	    puts "$l"
	} 
    }
}
;#
;# Je m'emmerddre , tai vi o phap troi lanh qua !!
;#
proc padmin:param { } {
    set maxl 0
    foreach name [wokBAG:bag:Names] {
	set lb [$name 1]
	if {[string length $lb] > $maxl} {
	    set maxl [string length $lb]
	}
    }
    set maxl [expr {$maxl + 2}]
    foreach name [wokBAG:bag:Names] {
	puts stdout [format "%-*s %s" $maxl [$name 1] [$name]]
    }
    return
}
