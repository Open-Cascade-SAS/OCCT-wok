#############################################################################
#
#                              W S T O R E
#                              ___________
#
#############################################################################
#
# Usage
#
proc wokStoreUsage { } {
    global env
    puts stderr \
	    {
	Usage : wstore is used to enqueue a report file, to get 
                information about a queue, or to perform an update of a workbench.
                (To update a workbench directly from a report see a the end of this help)

	  >wstore file : without option adds a report in the report's queue 
                         from <file>.
                         Queue name is deduced from the name of the father
                         workbench written in <file>. (created by wprepare).
         To list all pending reports name and ID in a queue use the following command:

         > wstore -wb name -ls 

         In the following syntaxes the option -wb is used to specify a workbench name.
         (Use a full workbench path for the workbench name. <Factory:workshop:workbench>
         Default is the current wb. <ID> is a report ID (see above)

         >wstore           [-rm|-cat] [-wb name] [ID]

	 >wstore -cat ID : Shows the content of <report_ID>.                      
	 >wstore -rm ID  : Remove a report from the queue                         
	
	Initialization/Admin options: 
	
	 >wstore  -param   : Lists queue parameters associed with wb.   
	
	To create a queue associated with the workbench Sam and say that the queue
        will be created under the directory /any/directory.

         >wstore -create -wb F:Shop:wSam -queue /any/directory -type SCCS

         -queue to specify the name of the directory under which the queue is created.
           (Default behavior: Creates a directory "queue" in the adm directory of the workbench)
	 -type to specify the type of the base.
           (defaulted to SCCS )
	 -base to specify the location where to put the archive files (only for SCCS )
           (Default behavior: Creates a directory SCCS in the adm directory of the workbench)
	 -counter to specify the name of the directory where the integration counter is located
	   (Default behavior: Create a subdirectory adm in directory created using -base option)
         -journal to specify the name of the directory where the integration journal is located
	   (Default behavior: Creates a a subdirectory adm in directory created using -base option)
         -welcome: If a report list new development units, by default store will refuse.
                   If you want wstore be quiet create the queue with -welcome option.
         -trigger to specify the full path of a tcl file defining a tcl proc triggered after a 
          report has been enqueued. An example for such a file can be found in 
          $env(WOK_LIBRARY)/wstore_trigger.example.

	To list all queues and their associated parameters:

	> wstore -lsqueue

      To directly update a workbench use the following command :

        > wstore -copy file

      where <file> is a report generated by wprepare. In that case the workbench listed in
      the report as the "master" workbench will be automatically updated. 

    }
    return
}   
#
# Point d'entree de la commande
#
proc wstore { args } {

    global WOKVC_STYPE WOKVC_LTYPE
    
    set tblreq(-h)       {}
    set tblreq(-rm)      {}
    set tblreq(-ls)      {}
    set tblreq(-cat)     {}
    
    set tblreq(-param)   {}

    set tblreq(-wb)      value_required:string

    set tblreq(-create)  {}

    set tblreq(-queue)   value_required:string
    set tblreq(-trigger) value_required:string

    set tblreq(-base)    value_required:string
    set tblreq(-type)    value_required:string
    set tblreq(-journal) value_required:string
    set tblreq(-counter) value_required:string
    set tblreq(-welcome) {}
    set tblreq(-copy)    {}

    set tblreq(-lsqueue) {}

    set tblreq(-v)       {}
    
    set param {}

    if { [wokUtils:EASY:GETOPT param tabarg tblreq wokStoreUsage $args] == -1 } return

    set verbose [info exists tabarg(-v)]

    if { [info exists tabarg(-h)] } {
	wokStoreUsage
	return
    }
    
    if { [info exists tabarg(-lsqueue)] } {
	if { [wokinfo -s [wokcd]] != {} } {
	    wokStore:queue:ls [sinfo -w [wokinfo -s [wokcd]]]
	} else {
	    puts stderr " Current location must be at least a workshop."
	}
	return
    }
    ;#
    ;# Admin options    wstore -create -wb F:Shop:wSam -queue /any/directory -type SCCS
    ;#
    if [info exists tabarg(-create)] {
	if [info exists tabarg(-wb)] {
	    set curwb $tabarg(-wb)
	    set queue [file join [wokinfo -p AdmDir:. $curwb] queue]
	    if [info exists tabarg(-queue)] {
		set queue $tabarg(-queue)
	    } 
	    set trig {} 
	    if [info exists tabarg(-trigger)] {
		set trig $tabarg(-trigger)
	    } 
	    set type SCCS
	    if [info exists tabarg(-type)] {
		set type $tabarg(-type) 
	    }

	    if [info exists tabarg(-welcome)] {
		set welcome yes
	    } else {
		set welcome no
	    }

	    set commonbase [file join [wokinfo -p AdmDir:. $curwb] archives]
	    if [info exists tabarg(-base)] {
		set base $tabarg(-base)
	    } else {
		set base [file join $commonbase BASES]
	    }

	    if [info exists tabarg(-counter)] {
		set counter $tabarg(-counter)
	    } else {
		set counter [file join $commonbase adm report.num]
	    }

	    if [info exists tabarg(-journal)] {
		set journal $tabarg(-journal)
	    } else {
		set journal [file join $commonbase adm wintegre.jnl]
	    }
	    wokStore:Report:Configure set \
		    [wokStore:Report:FileAdm $curwb] $curwb $queue $trig $base $type $counter $journal $welcome
	    if { $verbose } {
		msgprint -c WOKVC -i "Reports queue created under $queue " 
		msgprint -c WOKVC -i "Repository ($type) created under $base " 
		msgprint -c WOKVC -i "Counter in directory $counter "
		msgprint -c WOKVC -i "Journal in directory $journal "
	    }
	} else {
	   msgprint -c WOKVC -i "You must specify -wb with this option. "  
	}
	return
    }

    if { [info exists tabarg(-ls)] } {
	if [info exists tabarg(-wb)] {
	    set curwb $tabarg(-wb)
	} else {
	    if { [set curwb [wokinfo -w [wokcd]]] == {} } {
		msgprint -c WOKVC -e "Current location [wokcd] is not a workbench."
		return
	    }
	}
	if { [wokStore:Report:SetQName $curwb] == {} } {
	    return 
	}
	
	set FrigoName [wokStore:Report:GetRootName] 
	set ListReport [wokStore:Report:GetReportList $FrigoName]

	set i 0
	wokStore:Report:InitState $FrigoName tabdup
	foreach e  $ListReport { 
	    set user [wokUtils:FILES:Userid $FrigoName/$e]
	    set str  [wokStore:Report:GetPrettyName $e]
	    if { $str != {} } {
		set rep [string range [lindex $str 0] 0 19]
		set dte [lindex $str 1]
		puts [format "%3d - %-10s %-20s (stored at %s)" [incr i] $user $rep $dte ]
		if [info exists tabdup($e)] {
		    catch {unset dupfmt }
		    wokStore:Report:Fmtdup $FrigoName/$e $tabdup($e) dupfmt
		    foreach u [lsort [array names dupfmt]] {
			puts  "     [lindex [split $u .] 0]:"
			foreach f $dupfmt($u) {
			    puts "          $f ($FrigoName/$e/${u}/${f})"
			}
		    }
		}
	    } else {
		msgprint -c WOKVC -e "Bad entry ($e) found in report.list"
	    }
	}
	return
    }
    
    if [info exists tabarg(-param)] {
	if [info exists tabarg(-wb)] {
	    set curwb $tabarg(-wb)
	} else {
	    if { [set curwb [wokinfo -w [wokcd]]] == {} } {
		msgprint -c WOKVC -e "Current location [wokcd] is not a workbench."
		return
	    }
	}
	if { [wokStore:Report:SetQName $curwb] == {} } {
	    return 
	}
	
	set FrigoName [wokStore:Report:GetRootName] 
	set ListReport [wokStore:Report:GetReportList $FrigoName]
	
	msgprint -c WOKVC -i "Workbench $curwb :"
	msgprint -c WOKVC -i "Welcome new units ?: [wokIntegre:RefCopy:Welcome]"
	msgprint -c WOKVC -i "Reports queue created [wokStore:Report:GetRootName]" 
	msgprint -c WOKVC -i "Repository ([wokIntegre:BASE:GetType]) under [wokIntegre:BASE:GetRootName]" 
	msgprint -c WOKVC -i "Integration counter in : [wokIntegre:Number:GetName]"
	msgprint -c WOKVC -i "Integration journal in : [wokIntegre:Journal:GetName]"
	msgprint -c WOKVC -i "Trigger : [wokStore:Trigger:GetName]"
	return
    }

    ;# Following options requres an ID
    ;#
    set ID [lindex $param 0]
    
    if [info exists tabarg(-rm)] {
	if [info exists tabarg(-wb)] {
	    set curwb $tabarg(-wb)
	} else {
	    if { [set curwb [wokinfo -w [wokcd]]] == {} } {
		msgprint -c WOKVC -e "Current location [wokcd] is not a workbench."
		return
	    }
	}
	if { [wokStore:Report:SetQName $curwb] == {} } {
	    return 
	}
	
	set FrigoName [wokStore:Report:GetRootName] 
	set ListReport [wokStore:Report:GetReportList $FrigoName]
	set entry [wokStore:Report:GetTrueName $ID $ListReport]
	if { $entry != {}  } {
	    wokStore:Report:Del $FrigoName/$entry 
	}
	return
    }
    
    if [info exists tabarg(-cat)] {

	if [info exists tabarg(-wb)] {
	    set curwb $tabarg(-wb)
	} else {
	    if { [set curwb [wokinfo -w [wokcd]]] == {} } {
		msgprint -c WOKVC -e "Current location [wokcd] is not a workbench."
		return
	    }
	}

	if { [wokStore:Report:SetQName $curwb] == {} } {
	    return 
	}
	
	set FrigoName [wokStore:Report:GetRootName] 
	set ListReport [wokStore:Report:GetReportList $FrigoName]

	set entry [wokStore:Report:GetTrueName $ID $ListReport]
	if { $entry != {}  } {
	    set rep $FrigoName/$entry/report-orig
	    if { [file exists $rep] } {
		return [exec cat $rep]
	    } else {
		msgprint -c WOKVC -e "File $rep not found."
	    }
	}
	return
    }
    
    ;#
    ;# All previous option failed or -copy option => ID is a filename : wstore [-copy] filename.
    ;# Parameters are read from the report. wokStore:Setup is not called.
    ;# 
    if { [file exists $ID] } {
	wokPrepare:Report:InitTypes    
	wokPrepare:Report:Read $ID table banner notes 
	wokPrepare:Report:ReadInfo $banner shop wbpere wbfils
	set unews [wokStore:Report:CheckUnits [w_info -l ${shop}:$wbpere] table]
	if { $unews != {} } {
	    if {"[wokIntegre:RefCopy:Welcome]" == "yes" } {
		msgprint -c WOKVC -i "The following new units will be created in workbench ${shop}:$wbpere"
		foreach [list type name] $unews {
		    msgprint -c WOKVC -i "$WOKVC_STYPE($type) $name"
		}
	    } else {
		msgprint -c WOKVC -e "Ask your integration manager to create the following new units in ${shop}:$wbpere."
		foreach [list type name] $unews {
		    msgprint -c WOKVC -e "$WOKVC_STYPE($type) $name"
		}
		return
	    }
	}
	set msg1 "Workbench $wbpere has no associated queue. "
	set msg2 "Use wstore -create \n          to create one or wstore -wb to specify a workbench."
	set msg3 "\n Use wstore -copy to directly update workbench $wbpere"

	set defq [wokStore:Report:SetQName ${shop}:$wbpere]
	if { $defq != {} } {
	    if { [info exists tabarg(-copy)] } {
		msgprint -c WOKVC -w "Option -copy ignored. $wbpere has an associated queue."
	    }
	    set entry [wokStore:Report:GetUniqueName [set TID [file tail $ID]]]
	    if { $entry != {} } {
		msgprint -c WOKVC -i "Storing report in queue of workbench ${shop}:$wbpere"
		set frigo [file join [wokStore:Report:GetRootName] ${entry}]
		wokStore:Report:Add $ID table $banner $notes $frigo
		if { [set trig [wokStore:Trigger:Exists]] != {} } {
		   wokStore:Trigger:Invoke $trig $frigo 
		}
		return
	    } else {
		    msgprint -c WOKVC -e "Report name $TID should not contains a comma."
	    }
	} elseif { [info exists tabarg(-copy)] } {
	    msgprint -c WOKVC -i "Updating workbench ${shop}:$wbpere"
	    wokPrepare:Report:Copy table ${shop}:$wbpere $wbfils
	} else {
	    set errorInfo
	    msgprint -c WOKVC -e "$msg1$msg2$msg3"
	}
    } else {
	msgprint -c WOKVC -e "File $ID does not exists."
    }
    
}

;#
;# Fait la definition de la queue associee a wb
;# 
proc wokStore:Report:SetQName { wb {alert 0} } {
    ;#puts "appel setqname avec $wb"
    if { [wokinfo -x $wb] } {
	if { "[wokinfo -t $wb]" == "workbench" } {
	    if { [file exists [set vc [wokStore:Report:FileAdm $wb]]] } {
		uplevel #0 source $vc
		return 1
	    } else {
		if { $alert == 1 } {
		    msgprint -c WOKVC -e "File VCDEF.tcl not found in [file dirname $vc] of workbench $wb."
		}
		wokStore:Report:Configure unset {} {} {} {} {} {} {} {} {}
		return {}
	    }
	} else {
	    msgprint -c WOKVC -e "Entity $wb is not a workbench."
	    wokStore:Report:Configure unset {} {} {} {} {} {} {} {} {}
	    return {}
	}
    } else {
	msgprint -c WOKVC -e "Entity $wb does not exists."
	wokStore:Report:Configure unset {} {} {} {} {} {} {} {} {}
	return {}
    }
}
;#
;# retourne le nom du fichier VCDEF.tcl a sourcer pour le workbench wb
;#
proc wokStore:Report:FileAdm { wb } {
    return [file join [wokinfo -p AdmDir:. $wb] VCDEF.tcl]
}
;#
;#
;#
proc wokStore:Queue:Exists { wb } { 
    return [file exists  [wokStore:Report:FileAdm $wb]]
}
;#
;# Ecrit dans diradm le fichier VCDEF.tcl contenant les definitions de la queue.
;# 
proc wokStore:Report:Configure { option fileadm wb queue trignam base type counter journal welcome } {
    set proc_defined_in_VC [list \
	    wokStore:Report:GetRootName \
	    wokStore:Trigger:GetName \
	    wokIntegre:BASE:GetRootName \
	    wokIntegre:BASE:GetType \
	    wokIntegre:RefCopy:GetWB \
	    wokIntegre:Number:GetName \
	    wokIntegre:Version:Get \
	    wokIntegre:RefCopy:Welcome \
	    wokIntegre:Journal:GetName]

    
    switch -- $option {
	set {
	    wokUtils:FILES:mkdir $queue ;# the hook for the queue
	    eval "proc wokStore:Report:GetRootName { } { return $queue }"
	    eval "proc wokStore:Trigger:GetName { } { return $trignam }"
	    wokUtils:FILES:mkdir $base ;# the hook for the base
	    eval "proc wokIntegre:BASE:GetRootName { } { return $base }"
	    ;# the type of the base 
	    eval "proc wokIntegre:BASE:GetType { } { return $type }"
	    eval "proc wokIntegre:RefCopy:Welcome { } { return $welcome }"
	    ;# the workbench that will be updated during integration.
	    eval "proc wokIntegre:RefCopy:GetWB { } { return $wb }"
	    ;# the integration counter.
	    eval "proc wokIntegre:Number:GetName { } { return $counter }"
	    ;#
	    ;# create integration counter ONLY if it does not exists.
	    if { ![file exists [wokIntegre:Number:GetName]] } {
		msgprint -c WOKVC -i "Creating file [wokIntegre:Number:GetName]"
		wokUtils:FILES:mkdir [file dirname [wokIntegre:Number:GetName]]
		wokUtils:FILES:touch [wokIntegre:Number:GetName] 1
	    }

	    eval "proc wokIntegre:Journal:GetName { } { return $journal }"
	    ;#
	    ;# create journal file ONLY if it does not exists.
	    if { ![file exists [wokIntegre:Journal:GetName]] } {
		msgprint -c WOKVC -i "Creating file [wokIntegre:Journal:GetName]"
		wokUtils:FILES:mkdir [file dirname [wokIntegre:Journal:GetName]]
	    }
	    ;#
	    eval "proc wokIntegre:Version:Get { } { return 1 }"
	    ;#
	    set id [open $fileadm w]
	    foreach p ${proc_defined_in_VC} {
		puts $id "proc $p { } {"
		puts $id "[info body $p]"
		puts $id "}"	
	    }
	    close $id
	}
	
	unset {
	    foreach p ${proc_defined_in_VC} {
		if { "[info procs $p]" == "$p" } {
		    rename $p {}
		}
	    }
	}
    }
}
#;>
#  Retourne la table des elements dupliques dans la queue d'integration
#;<
proc wokStore:Report:InitState { FrigoName table } { 
    upvar $table tabdup
    catch {unset tabud}
    wokStore:Report:DumpQueue $FrigoName tabud
    if { [array exist tabud] } {
	catch {unset tabdup}
	foreach key [array names tabud] {
	    if  { [llength $tabud($key)] > 1 } {
		foreach e $tabud($key)] {
		    set h [wokStore:Report:Head $e]
		    if [info exists tabdup($h)] {
			set ll $tabdup($h)
		    } else {
			set ll {}
		    }
		    lappend ll $key
		    set tabdup($h) $ll
		}
	    }
	}
    }
    return
}
#;>
#  Formatte une entry dupliquee, uniquement pour la commande Tcl.
#;<
proc wokStore:Report:Fmtdup { report list duplic } {
    upvar $duplic tabfmt
    foreach itm $list {
	set lt [split $itm :]
	set ud [lindex $lt 1]
	if [info exists tabfmt($ud)] {
	    set ll $tabfmt($ud)
	} else {
	    set ll {}
	}
	lappend ll [lindex $lt 0]
	set tabfmt($ud) $ll 
    }
    return
}
#;<
# Repond un si path pourra ( a priori ) etre mis dans une base 
# de n'importe quel type (SCCS, RCS)
# Pour l'instant exclut les directories. 
#;<
proc wokStore:Report:FOK { path } {
    return [expr { ![file isdirectory $path] }]
}
#;>
# Ajoute un report dans un frigo
#  1. Creation du repertoire associe
#  3. Ecriture des report-work et de ReleaseNotes 
#  4. Gel des sources dans leur repertoire associe.
#;<
;# WARNING: voir chmod et clock au lieu de getclock

proc wokStore:Report:Add { ID intable banner notes frigo } {

    upvar $intable table
    set writact $banner
    wokUtils:FILES:mkdir $frigo
    wokUtils:FILES:chmod 0777 $frigo
    set LST [lsort [array names table]]
    foreach e $LST {
	;#msgprint -c WOKVC -i [format "Processing unit : %s" $e]
	wokUtils:FILES:mkdir $frigo/$e
	wokUtils:FILES:chmod 0777 $frigo/$e
	lappend writact "* $e"
	foreach l $table($e) {
	    set str [wokUtils:LIST:Trim $l]
	    set flag [lindex $str 0]
	    set file [lindex $str 3]
	    set orig [lindex $str 4]
	    if { [wokStore:Report:FOK $orig/$file] } {
		switch -- $flag {
		    - {
			lappend writact "- /dev/null/$file"
		    }
		    + {
			if { [wokUtils:FILES:copy $orig/$file $frigo/$e/$file] != -1 } {
			    wokUtils:FILES:chmod 0777 $frigo/$e/$file
			    lappend writact "+ $frigo/$e/$file"
			} else {
			    return -1
			}
		    }
		    = {
			;#puts stderr "Warning:File $file not modified. Ignored"
		    }
		    # {
			if { [wokUtils:FILES:copy $orig/$file $frigo/$e/$file] != -1 } {
			    wokUtils:FILES:chmod 0777 $frigo/$e/$file
			    lappend writact "# $frigo/$e/$file"
			} else {
			    return -1
			}
		    }
		    >>> {
		    }
		    default {
			msgprint -c WOKVC -w "Ignored line: $l"
		    }
		}
	    } else {
		msgprint -c WOKVC -w "Directory $file not processed."
	    }
	}
    }
    wokUtils:FILES:copy $ID $frigo/report-orig
    wokUtils:FILES:ListToFile $writact $frigo/report-work
    wokUtils:FILES:ListToFile $notes   $frigo/report-notes
    wokUtils:FILES:chmod 0777 [list $frigo/report-orig $frigo/report-work $frigo/report-notes]
    return 1
}
#;>
# Retire un report du frigo, le report est donne par son full path
#;<
proc wokStore:Report:Del { LISTREPORT } {
    foreach entry $LISTREPORT {
	if { [wokStore:Report:RmEntry $entry] == -1 } {
	    return -1
	}
    }
    return
}
#;>
# Detruit effectivement une entry (full path) dans la queue.
#;<
proc wokStore:Report:RmEntry { fullentry } {
    foreach itm [glob -nocomplain $fullentry/*] {
	if [file isdirectory $itm] {
	    wokUtils:FILES:rmdir $itm
	}
    }
    wokUtils:FILES:rmdir $fullentry
    return
}

#;>
# retourne une table  table(ud) = {R1/ud R2/ud etcc }
#;<
proc wokStore:Report:Cross { R table } {
    upvar $table TLOC 
    set excep [list report-notes report-orig report-work]
    if { $R != {} } {
	foreach r [glob -nocomplain $R/*/*] {
	    set ud [file tail $r]
	    if { [lsearch $excep $ud] == -1 } {
		if [info exists TLOC($ud)] {
		    set l $TLOC($ud)
		} else {
		    set l {}
		}
		lappend l $r
		set TLOC($ud) $l
	    }
	}
    }
    return
}
#;>
# Cree une table avec le contenu de la queue
# Table(file:ud) { liste des directories concernees }
# Si longueur de la liste  > 1 => duplication
#;<
proc wokStore:Report:DumpQueue { FrigoName table } {
    upvar $table TLOC
    catch { unset tabud }
    wokStore:Report:Cross $FrigoName tabud
    if [array exists tabud] {
	foreach ud [array names tabud] {
	    foreach dir $tabud($ud) {
		if [file exists $dir] {
		    foreach f [wokUtils:EASY:readdir $dir] {
			set key ${f}:${ud}
			if [info exists TLOC($key)] {
			    set ll $TLOC($key)
			} else {
			    set ll {}
			}
			lappend ll $dir
			set TLOC($key) $ll
		    }
		}
	    }
	}
    }
    return
}

#;>
# Pour debugger. Imprime tout ce qui se trouve accroche sous ID
#;<
proc wokStore:Report:Dump { D } {
   return [exec find $D -print]
}
#;>
# Retourne le nom de l'entry associee a  ReportID {} sinon
#;<
proc wokStore:Report:GetTrueName { ReportID listreport } {
    set ln [llength $listreport]
    if { $ln > 0 } {
	if [ regexp {^[0-9]+$} $ReportID ] {
	    set idm1 [expr $ReportID - 1]
	    set res [lindex $listreport $idm1]
	    if { $res != {} } {
		return $res
	    } else {
		msgprint -c WOKVC -e "Bad report ID. Should be a digit and range into ( 1 and $ln ) "
		return {}
	    }
	} else {
	    msgprint -c WOKVC -e "Bad report ID. Should be a digit and range into ( 1 and $ln ) "
	    return {}
	}
    } else {
	msgprint -c WOKVC -e "Report Queue is empty."
	return {}

    }
}
#;>
#
# Retourne un nom de directory unique base sur l'heure /append le nom du report
#
#;<
proc wokStore:Report:GetUniqueName { name } {
    if { [string first , $name] == -1 } {
	return [clock seconds],${name}
    } else {
	return {}
    }
}
#;>
# A partir d'un nom genere par GetUniqueName, retourne une liste de 2 elem
#   1. La date ayant servi a creer le directory
#   2. Le nom du report
#;<
proc wokStore:Report:GetPrettyName { Uniquename } {
    set l [split $Uniquename ,]
    return [list [lindex $l 1] [clock format [lindex $l 0]] ]
}

#;>
# Retourne la liste des reports ordonnee par rapport a leur date d'arrivee
#;<
proc wokStore:Report:GetReportList { FrigoName } {
    if [file exists $FrigoName] {
	return [lsort -command wokStore:Report:SortEntry [wokUtils:EASY:readdir $FrigoName] ]
    } else {
	return {}
    }
}
#;>
# Retourne l'index dans la queue d'un report -1 si existe pas
#;<
proc wokStore:Report:Index { FrigoName Truename } {
    set i [lsearch [wokStore:Report:GetReportList $FrigoName] $Truename]
    if { $i != -1 } {
	return [expr $i + 1]
    } else {
	return -1
    }
}
#;>
# Retourne a partir d'un full path le nom du report
#;<
proc wokStore:Report:Head { fullpath } {
    if [regexp {.*/([0-9]*,[^/]*)} $fullpath all rep] {
	return $rep
    } else {
	return {}
    }
}
#;
# Retourne la longueur  de la liste des reports en attente 
#;<
proc wokStore:Report:QueueLength { } {
    return [llength [wokStore:Report:GetReportList [wokStore:Report:GetRootName ]]]
}

#;>
# Commande utilise pour le tri ci dessus: (u,string1 > v,string2 <=> u > v)
#;<
proc wokStore:Report:SortEntry { a b } {
    set lna [split $a ,] 
    set lnb [split $b ,]
    return [expr [lindex $lna 0] - [lindex $lnb 0] ]
}
#;>
# Lit un report enregistre par wstore, remplit une table
# TABLE(UD.TYPE) = {liste des items de l'UD}
# Item = {[+|-|=|# full path}               
# Il n'y a qu'un path par item, c'est l'adresse dans le frigo du fichier
# a traiter
#
# Si OPT = ref a)Verifie que tous les items du report sont + sinon retourne une erreur
#              b)Retire le flag + dans table   (implicite)
#;<
proc wokStore:Report:Process { {OPT normal} RepName table info notes} {
    upvar $table TLOC $info lloc $notes ntloc
    set lf [wokUtils:FILES:FileToList ${RepName}/report-work]
    set ntloc [wokUtils:FILES:FileToList ${RepName}/report-notes]
    set lloc [lrange $lf 0 2]
    set lact [lrange $lf 3 end]
    switch $OPT {
	normal {
	    foreach x $lact {
		set header [regexp {\* (.*)} $x all ut]
		if { $header } {
		    set key $ut
		    set TLOC($key) {}
		} else {
		    set l $TLOC($key)
		    set elm [list [lindex $x 0] [file join $RepName $key [file tail [lindex $x 1]]]]
		    set TLOC($key) [lappend l $elm]
		}
	    }
	    return 0
	}

	ref {
	    foreach x $lact {
		set header [regexp {\* (.*)} $x all ut]
		if { $header } {
		    set key $ut
		    set TLOC($key) {}
		} else {
		    set flg [lindex $x 0]
		    if { $flg == {+} } {
			set l $TLOC($key)
			set elm [file join $RepName $key [file tail [lindex $x 1]]]
			set TLOC($key) [lappend l $elm]
		    } else {
			msgprint -c WOKVC -e "Bad flag for this kind of operation ($x).Should be marked {+}."
			return -1
		    }
		}
	    }
	    return 0
	}
    }
}
;#
;# Retourne  un ou plusieurs pathes de report, mangeables par wokStore:Report:Process
;#
proc wokStore:Report:Get { id } {
    set l {}
    if { [wokStore:Report:QueueLength ] != 0 } {
	set FrigoName [wokStore:Report:GetRootName ]
	if { $FrigoName != {} } {
	    set ListReport [wokStore:Report:GetReportList $FrigoName] 
	    if { $ListReport != {} } {
		if { "$id" == "all" } {
		    foreach e $ListReport {
			lappend l $FrigoName/$e
		    }
		} else {
		    set brep [wokStore:Report:GetTrueName $id $ListReport]
		    if { "$brep" != "" } {
			lappend l $FrigoName/$brep
		    }
		}
	    } else {
		msgprint -c WOKVC -e "Unable to get report list."
	    }
	} else {
	    msgprint -c WOKVC -e "Administration directory not found. No report was stored."
	}
    } else {
	msgprint -c WOKVC -i "Report queue is empty ."
    }
    return $l
}
;#
proc wokPrepare:Report:Copy  { intable wbpere wbfils {verbose 0} } {

    upvar $intable table

    set LST [lsort [array names table]]

    set lpere [w_info -l $wbpere]

    set writact {}

    foreach e $LST {
	regexp {(.*)\.(.*)} $e all udname type
	if  { [lsearch $lpere $udname] == -1 } {
	    ucreate -$type ${wbpere}:${udname}
	}
	set frigo [wokinfo -p source:. ${wbpere}:${udname}]
	set localfiles [uinfo -lp -Tsource ${wbfils}:${udname}]
	if [file exists $frigo] {
	    if [file writable $frigo] {
	    } else {
		msgprint -c WOKVC -e "You cannot write in directory $frigo."
		set error 1
	    }
	} else {
	    msgprint -c WOKVC -e "Directory $frigo does not exists."
	    set error 1
	}
	foreach l $table($e) {
	    set str [wokUtils:LIST:Trim $l]
	    set flag [lindex $str 0]
	    set file [lindex $str 3]
	    set orig [lindex $str 4]
	    set path [file join $orig $file]
		
	    if { [wokStore:Report:FOK $orig/$file] } {
		switch -- $flag {
		    - {
		    }
		    + {
			if { [lsearch $localfiles $path] != -1 } {
			    msgprint -c WOKVC -i " Adding $file in unit ${wbpere}:${udname}"
			    lappend writact "wokUtils:FILES:copy $path $frigo/$file"
			}
		    }
		    = {
		    }
		    # {
			if { [lsearch $localfiles $path] != -1 } {
			    msgprint -c WOKVC -i " Updating $file in unit ${wbpere}:${udname}"
			    lappend writact "wokUtils:FILES:chmod 0644 $frigo/$file"
			    lappend writact "wokUtils:FILES:copy $path $frigo/$file"
			}
		    }
		    >>> {
		    }
		    default {
			msgprint -c WOKVC -w "Ignored line: $l"
		    }
		}
	    } else {
		msgprint -c WOKVC -w "Directory $file not processed."
		set error 1
	    }
	}
    }

    if ![ info exists error] {
	foreach x $writact {
	    eval $x
	}
    } else {
	msgprint -c WOKVC -e "Nothing was done."
    }
    return 1
}
;#
;# retourne la liste des UDs de table qui ne sont pas dans WB
;# si cette liste est != {} il faut les creer.
;#
proc wokStore:Report:CheckUnits { lwb table } {
    upvar $table TLOC 
    set lret {}
    foreach u [array names TLOC] {
	regexp {(.*)\.(.*)} $u all udname type 
	if { [lsearch $lwb $udname] == -1 } {
	    lappend lret $type $udname
	}
    }
    return $lret
}
;#
;#
;#
proc wokStore:queue:ls { lwb } {
    foreach wb $lwb {
	if { [file exists [file join [wokinfo -p AdmDir:. [Sinfo -f]:[Sinfo -s]:$wb] VCDEF.tcl]] } {
	    wokStore:Report:SetQName [Sinfo -f]:[Sinfo -s]:$wb
	    msgprint -c WOKVC -i "Workbench $wb :"
	    msgprint -c WOKVC -i "Welcome new units ?: [wokIntegre:RefCopy:Welcome]"
	    msgprint -c WOKVC -i "Reports queue under [wokStore:Report:GetRootName]" 
	    msgprint -c WOKVC -i "Repository ([wokIntegre:BASE:GetType]) under [wokIntegre:BASE:GetRootName]" 
	    msgprint -c WOKVC -i "Integration counter in : [wokIntegre:Number:GetName]"
	    msgprint -c WOKVC -i "Integration journal in : [wokIntegre:Journal:GetName]"
	    msgprint -c WOKVC -i "Trigger : [wokStore:Trigger:GetName]"
	    puts ""
	}
    }
}
;# memo :
;# Pour faire pointer une file d'attente sur celle UpdateC31
;# Parametres d'integration des anciennes bases.
;#
;# Workbench KAS:C30:UpdateC31
;# wstore -create -wb :KAS:TEST:UpdateC31 -base /adv_11/KAS/C30/SCCS/BASES -type SCCS -queue /adv_11/KAS/C30/SCCS/adm/C30/FRIGO -counter /adv_11/KAS/C30/SCCS/adm/C30/report.num -journal /adv_11/KAS/C30/SCCS/adm/C30/wintegre.jnl
;#
;# Workbench KAS:C40:ros 
;#wstore -create -wb :KAS:TEST:ros -base /adv_20/KAS/C40/SCCS/BASES -type SCCS -queue /adv_20/KAS/C40/SCCS/adm/C40/FRIGO -counter /adv_20/KAS/C40/SCCS/adm/C40/report.num  -journal /adv_20/KAS/C40/SCCS/adm/C40/wintegre.jnl
#;>
# Check if file trigger exists
# 
#;<
proc wokStore:Trigger:Exists { } {
    set trignam [wokStore:Trigger:GetName]
    if { $trignam != {} } {
	if { [file exists $trignam] } {
	    return $trignam
	} else {
	    return {}
	}
    } else {
	return {}
    }
}
#;>
# Invoke a trigger
#;<
proc wokStore:Trigger:Invoke { trignam report_path } {
    uplevel #0 source $trignam 
    ;#msgprint -c WOKVC -i "Invoking  file $trignam."
    if { [catch { wstore_trigger $report_path } trigval ] == 0 } {
	;#msgprint -c WOKVC -i "Trigger $trignam successfully completed"
	return $trigval
    } else {
	msgprint -c WOKVC -e "Error in trigger: $trigval"
	return {}
    }
    return
}
