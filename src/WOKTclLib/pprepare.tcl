#############################################################################
#
#                              P P R E P A R E
#                              _______________
#
#############################################################################
#
# Usage
#
proc wokpprepareUsage { } {
    puts stderr \
	    {
	Usage: pprepare Pnam [ options... ]

	Compare the parcel Pnam in the local bag with its last occurence in 
        the reference bag. Pnam should be given with its full path, in the format
        FACTORY:BAGNAME:PARCELNAME
      
        File extensions in Pnam are checked against a list of known types.
        If some extensions are unknown, a warning is issued. 

     Options for specifying location and contents of the parcel Pnam.
        -from <dir> specify that <dir> must be used as the contents of Pnam.
        By default <dir> is the root directory of the parcel in the bag of
        your factory.

	-init <level> specify that Pnam is a new parcel to be initialized in the 
         reference BAG. No comparison is done. <level> is a character string
	that identify the level the parcel belongs to. <level> should be
	given using uppercase letter.

	-req specify a list of parcels used to build Pnam.
        By default this list is automatically inserted using the requisites
        declared in your bag.

     Options for specifying output. 

        By default, creates a file named Pnam.report in the current directory.
        If option -o <file> is specified the output is written in file.
        By default the identical files are not listed unless option -show= is 
        specified.
      
     Options for filtering comparison:

        By default, all the directories and files under Pnam root directory
        are compared with the contents of the last occurence of pnam in
        the reference bag. You can avoid some of these comparisons with the
        following options.

        -depth depth : Subdirectories whose level is greater than depth are  
                       not compared. (Directory itself is depth = 0 )         
        -ext e1,e2,..: Select extension file to be compared. Extenstions must 
                       separated by comma, and begin with a dot (.)          
        -dir d1,d2,. : Select directory names to be compared. Names can be   
                       glob-style match.                                     
        -Xdir d1,d2, : Same as above but excludes listed directories.
                                                                         
	Examples: 

	Writes in /tmp/report the compared state of parcel KL:BAG:KERNEL-B4-1
        with the last occurence of KERNEL-B4-1 in the reference BAG.

	   tclsh> pprepare KL:BAG:KERNEL-B4-1 -o /tmp/report

      }        
    return
}
#
# Point d'entree de la commande
#
proc pprepare { args } {
    
    set tblreq(-h)       {}
    set tblreq(-o)       value_required:file
    set tblreq(-show=)   {}
    set tblreq(-init)    value_required:string
    set tblreq(-from)    value_required:file
    set tblreq(-v)       {}
    set tblreq(-V)       {}
    set tblreq(-req)     value_required:string
    set tblreq(-depth)   value_required:string
    set tblreq(-ext)     value_required:list
    set tblreq(-dir)     value_required:list
    set tblreq(-xdir)    value_required:list

    set param {}
    if { [wokUtils:EASY:GETOPT param tabarg tblreq wokpprepareUsage $args] == -1 } return

    if [info exists tabarg(-h)] {
	wokpprepareUsage
	return
    }

    set verbose 0
    if { [info exists tabarg(-v)] || [info exists tabarg(-V)] } { set verbose 1 }

    if { [llength $param] != 1 } {
	wokpprepareUsage
	return
    }

    set hidee 1
    if [info exists tabarg(-show=)] {
	set hidee 0
    }


    set init NO
    if [info exists tabarg(-init)] {
	set init $tabarg(-init)
    } 

    if { [set comp [package require Wokutils]] != {} } {
	set compare_routine wokcmp
    } else {
	set compare_routine wokUtils:FILES:AreSame
    }

    if { $verbose } { puts "Will use the command $compare_routine for file comparison." ; flush stdout }

    set inam [lindex $param 0]

    if [info exists tabarg(-from)] {
	set pnam $inam  ;# si il n'y a pas de : 
	set drev $tabarg(-from)
    } else {
	if [wokinfo -x $inam] {
	    set pnam [wokinfo -n $inam]
	    set drev [wokinfo -p HomeDir $inam]
	} else { 
	    puts "Qui peut me dire comment on utilise simplement wokinfo et Cie.. ??"
	    puts "En attendant specifier la parcel avec son full path. Ex KERNEL:BAG:KERNEL-B6-1"
	    puts "ou utiliser l'option -from pour dire ou faut prendre les directories de l'UL"
	    return
	}
    } 

    if [info exists tabarg(-req)] {
	set umak $tabarg(-req)
    } else {
	set umak [pprepare:depends:read $inam]
    }

    set dmas [wokBAG:cpnt:GetImportName $pnam]
    if { "$init" == "NO" } {
	if { $verbose } { puts "Will use $dmas as directory for comparison" ; flush stdout }
	if { [file exists $dmas] } {
	    if { ![file isdirectory $dmas] } {
		puts  stderr "$dmas is not a directory"
		return
	    }
	    if { $verbose } { puts -nonewline "Reading $dmas ..."; flush stdout }
	    
	    wokUtils:FILES:DirToMap $dmas mas
	    
	    if { $verbose } { puts "Done"  ; flush stdout}
	    if [info exists mas(/lost+found)] {
		unset mas(/lost+found)
	    }
	}
    }

    if { [file exists  $drev] } {
	if { ![file isdirectory $drev] } {
	    puts stderr "$drev is not a directory"
	    return
	}
	if { $verbose } { puts -nonewline "Reading $drev ..." ; flush stdout  }
	wokUtils:FILES:DirToMap $drev rev
	if { $verbose } { puts "Done" ; flush stdout }
	if [info exists rev(/lost+found)] {
	    unset rev(/lost+found)
	}
    } else {
	puts  stderr "Directory $drev does not exists."
	return
    }

    if [info exists tabarg(-o)] {
	if [ catch { set fileid [ open [set written $tabarg(-o)] w ] } status ] {
	    puts stderr "$status"
	    return
	}
    } else {
	if [ catch { set fileid [ open [set written [pwd]/${pnam}.report] w ] } status ] {
	    puts stderr "$status"
	    return
	}
    }

    set gblist {}
    if [info exists tabarg(-ext)] {
	foreach e $tabarg(-ext) {
	    lappend gblist $e
	}
    }

    if [info exists tabarg(-depth)] {
	set depth [expr $tabarg(-depth) + 1]
	if [array exists mas] {
	    foreach ky [array names mas] {
		if { [expr [llength [split $ky /]] -1] >= $depth } {
		    unset mas($ky)  
		}
	    }
	}
	foreach ky [array names rev] {
	    if { [expr [llength [split $ky /]] -1] >= $depth } {
		unset rev($ky)  
	    }
	}
    }
    
    if [info exists tabarg(-dir)] {
	foreach ptn $tabarg(-dir) {
	    if [array exists mas] {
		foreach ky [array names mas] {
		    if ![string match $ptn $ky] {
			unset mas($ky)
		    }
		}
	    }
	    foreach ky [array names rev] {
		if ![string match $ptn $ky] {
		    unset rev($ky)
		}
	    }
	}
    }
    
    if [info exists tabarg(-xdir)] {
	foreach ptn $tabarg(-xdir) {
	    if [array exists mas] {
		foreach ky [array names mas] {
		    if [string match $ptn $ky] {
			unset mas($ky)
		    }
		}
	    }
	    foreach ky [array names rev] {
		if [string match $ptn $ky] {
		    unset rev($ky)
		}
	    }
	}
    }
    ;# bai gio em phai di lam...
    if { $verbose } { puts -nonewline "Begin comparison ..." ; flush stdout }
    wokUtils:EASY:Compare mas rev MAPWRK $compare_routine $hidee $gblist
    if { $verbose } { puts "Done ..." ; flush stdout }

    pprepare:header:write $pnam $dmas $drev $init $umak $fileid
    wokUtils:EASY:WriteCompare $dmas $drev MAPWRK $fileid
    pprepare:comments:write $fileid

    if { [string match file* $fileid] } {
	close $fileid
    }
    
    set l [wokUtils:EASY:RevFiles MAPWRK] 
    wokUtils:EASY:ext $l Extensions
    if { [set unk [wokBAG:magic:CheckExt [array names Extensions]]] != {} } {
	foreach ext $unk {
	    puts "Error : Unknown extension $ext"
	}
    }

    puts "File $written has been created."
    return
}
;#
;# retourne le header d'un report dans map.
;#
proc pprepare:header:read { fileid  map } {
    upvar $map TLOC
    while {[gets $fileid x] >= 0} {
	if { [regexp {^Parcel  : (.*)} $x all pnam] } {set f0 1 }
	if { [regexp {^Master  : (.*)} $x all dmas] } {set f1 1 }
	if { [regexp {^Revision: (.*)} $x all drev] } {set f2 1 }
	if { [regexp {^Init    : (.*)} $x all init] } {set f3 1 }
	if { [regexp {^Umaked  : (.*)} $x all umak] } {set f4 1 }
	if { [info exists f0] && [info exists f1] && [info exists f2] && [info exists f3]  && [info exists f4]} { 
	    array set TLOC [list Parcel $pnam Master $dmas Revision $drev Init $init Umaked $umak]
	    return 1
	} 
    }
    return {}
}
;#
;# ecrit le header d'un report.
;#
proc pprepare:header:write { pnam dir1 dir2 init umak fileid } {
    puts $fileid "Parcel  : $pnam"
    puts $fileid "Master  : $dir1"
    puts $fileid "Revision: $dir2"
    puts $fileid "Init    : $init"
    puts $fileid "Umaked  : $umak"
    return
}
;#
;# retourne les commentaires d'un report
;#
proc pprepare:comments:read { fileid  } {
    set l {}
    while {[gets $fileid x] >= 0} {
	lappend l $x
    }
    return $l
}
;#
;# ecrit un template de commentaires d'un report
;#
proc pprepare:comments:write { fileid } {
    puts $fileid "is"
    puts $fileid "  Author        :"
    puts $fileid "  Study/CSR     :"
    puts $fileid "  Debug         :"
    puts $fileid "  Improvements  :"
    puts $fileid "  News          :"
    puts $fileid "  Deletions     :"
    puts $fileid "  Impact        :"
    puts $fileid "  Comments      :"
    puts $fileid "end;"
}
;#
;# recupere les dependances de fab i. e. lit un machin ecrit 
;# /adv_20/MDL/BAG/GEOMETRY-M4-6/adm/GEOMETRY.depul qui contient (GEOMLITE-M4-6 KERNEL-K4L)
;# 
;# inam est un FULL PATH.
;#
proc pprepare:depends:read { inam } {
    if [wokinfo -x $inam] {
	set nam [wokBAG:cpnt:parse root [wokinfo -n $inam]]
	return [wokUtils:FILES:FileToList [wokinfo -p AdmDir $inam]/$nam.depul]
    }
}
