 
#############################################################################
#
#                              P S T O R E
#                              ___________
#
#############################################################################
#
# Usage
#
proc pstoreUsage { } {
    puts stderr \
	    {
	Usage : pstore    [-conf cnam1,cnam2,..]  [-f] [-rm|-ls|-cat] [filename] 
	
	pstore filename  -conf option : Add a report in the report's list from <filename>.     
	-conf option is mandatory.    : Will update <cnam1,cnam2> during integration. (pintegre)
	
	pstore [-ls]               : Lists pending reports with their owner and IDs.        
	pstore -cat <report_ID>    : Shows the content of <report_ID>.                      
	pstore [-f] -rm <report_ID>: Remove a report from the queue                         
	: (-f used to force if you dont own the report).          
	
	-dump  <report_ID>         : Dump contents of Report .                                      
	-check                     : Check that all files referenced in queue have not
                                     not been modified since their storage.
	
    }
    return
}   
#
# Point d'entree de la commande
#
proc pstore { args } {

    set tblreq(-h)         {}
    set tblreq(-f)         {}
    set tblreq(-rm)        {}
    set tblreq(-ls)        {}
    set tblreq(-cat)       {}

    set tblreq(-dump)      {}
    set tblreq(-check)     {}

    set tblreq(-conf)      value_required:list


    set param {}

    if { [wokUtils:EASY:GETOPT param tabarg tblreq pstoreUsage $args] == -1 } return

    set option_specified [array exists tabarg]

    if { [info exists tabarg(-h)] } {
	pstoreUsage
	return
    }
    
    if { [info exists tabarg(-f)] } {
	set forced -1
    } else {
	set forced 0
    }
    


    set fshop nil
    
    set FrigoName [pstore:Report:MkRoot $fshop 1]
    
    if { $FrigoName == {} } {
	msgprint -c WOKBAG -e "Bad queue name."
	return
    }

    set ListReport [pstore:Report:GetReportList $FrigoName] 

    ;#
    ;#  Options ne s'appliquant pas a un ID
    ;#    
    set ID [lindex $param 0]

    if { $ID == {} } {
	if { ( [info exists tabarg(-ls)] == 1 ) || ( $option_specified == 0 ) } {
	    set i 0
	    foreach e  $ListReport { 
		set user [wokUtils:FILES:Userid $FrigoName/$e]
		set str  [pstore:Report:GetPrettyName $e]
		if { $str != {} } {
		    set rep [string range [lindex $str 0] 0 19]
		    set dte [lindex $str 1]
		    puts [format "%3d - %-10s %-20s (stored at %s)" [incr i] $user $rep $dte ]
		} else {
		    msgprint -c WOKBAG -e "Bad entry ($e) found in report.list"
		}
	    }
	    return
	} elseif { [info exists tabarg(-check)] } {
	    set LISTREPORT [pstore:Report:Get all $fshop]
	    foreach REPORT $LISTREPORT {
		set cmd [pstore:Report:Process $REPORT]
		if { [info procs pstoreReportWasThere] != {} } {
		    if { [set l [pstoreReportWasThere]] != {} } {
			foreach f $l {
			    puts stderr "File $f has been removed since storage of that report."
			}
			return
		    }
		}
		if { [info procs pstoreReportRemember] != {} } {
		    if { [set l [pstoreReportRemember]] != {} } {
			foreach [list fn dt] $l {
			    puts -nonewline stderr "File date has changed for $fn." 
			    puts stderr "Was stored at [fmtclock $dt]. Current is [fmtclock [file mtime $fn]]"
			}
		    }
		}
		pstore:Report:UnProcess $REPORT
	    }
	    return
	}
    }
    
    if { [info exists tabarg(-check)] || [info exists tabarg(-ls)] } {
	pstoreUsage
	return
    }


    ;#
    ;#  Options s'appliquant a un ID
    ;# 
    
    if ![wokUtils:FILES:ValidName $ID] {
	msgprint -c WOKBAG -e "Malformed command or invalid file name $ID"
	return {}
    }
    

    
    if [info exists tabarg(-rm)] {
	set entry [pstore:Report:GetTrueName $ID $ListReport]
	if { $entry != {}  } {
	    pstore:Report:Del $FrigoName/$entry $forced  
	}
	return
    }
    
    if [info exists tabarg(-cat)] {
	set entry [pstore:Report:GetTrueName $ID $ListReport]
	if { $entry != {}  } {
	    set rep $FrigoName/$entry/report-orig
	    if { [file exists $rep] } {
		return [exec cat $rep]
	    } else {
		msgprint -c WOKBAG -e "File $rep not found."
	    }
	}
	return
    }
    
    if [info exists tabarg(-dump)] {
	set entry [pstore:Report:GetTrueName $ID [pstore:Report:GetReportList $FrigoName]]
	return [pstore:Report:Dump $FrigoName/$entry]
    }

    
    if { [info exists tabarg(-conf)] } {
	set Config $tabarg(-conf)
    } else {
	pstoreUsage
	return
    }

    if [file exists [set report [lindex $ID 0]]] {
	if ![ catch { set fileid [ open $report r ] } ] {
	    pprepare:header:read $fileid RepHeader
	    set pnam  $RepHeader(Parcel)
	    if ![pstore:Report:Exists $pnam $ListReport] {
		wokUtils:EASY:ReadCompare map $fileid
		if ![wokUtils:EASY:MapEmpty map] {
		    set entry [pstore:Report:GetUniqueName $pnam]
		    if { $entry != {}  } {
			if [pstore:Report:Add $Config $report RepHeader map $FrigoName/${entry}] {
			    msgprint -c WOKBAG -i [set subject "Report $report has been stored."]
			    seek $fileid 0 start
			    pstore:mail:Send "With love from $pnam ..." [read $fileid]
			    close $fileid
			} else {
			    msgprint -c WOKBAG -e " during storage of $report"
			    catch { exec rm -rf $FrigoName/${entry} }
			}
		    } else {
			msgprint -c WOKBAG -e "Parcel name $pnam should not contains a comma." 
		    }
		} else {
		    msgprint -c WOKBAG -e "Report $report is empty."
		}
	    } else {
		msgprint -c WOKBAG -e "A report for parcel $pnam is already in queue."
	    }
	} else {
	    msgprint -c WOKBAG -e "File $report cannot be read."
	}
    } else {
	msgprint -c WOKBAG -e "File $report not found."
    }
    return
}
#;>
# Ajoute un report dans un frigo
#;<
proc pstore:Report:Add { Config report Header table frigo } {
    upvar $Header RepHeader $table RepBody
    
    mkdir -path $frigo
    chmod 0777 $frigo

    set RepHeader(FrigoName) $frigo
    wokUtils:FILES:ListToFile {} [set RepHeader(COMMAND) $frigo/COMMAND]
    wokUtils:FILES:ListToFile {} [set RepHeader(LABEL)   $frigo/LABEL]
    wokUtils:FILES:copy $report  [set RepHeader(Journal) $frigo/report-orig]
    wokUtils:EASY:ListToProc $Config   $frigo/Config.tcl pstoreReportConfig
    wokUtils:EASY:MapToProc  RepHeader $frigo/Header.tcl pstoreReportHeader
    wokUtils:EASY:MapToProc  RepBody   $frigo/Body.tcl   pstoreReportBody
    set l [wokUtils:EASY:RevFiles RepBody] 
    wokUtils:FILES:ListToFile [wokUtils:FILES:WasThere $l pstoreReportWasThere] $frigo/WasThere.tcl
    source $frigo/WasThere.tcl
    if { [set ll [pstoreReportWasThere]] == {} } {
	wokUtils:FILES:ListToFile [wokUtils:FILES:Remember $l pstoreReportRemember] $frigo/Remember.tcl
	chmod 0777 [list $frigo/Config.tcl $frigo/Header.tcl $frigo/Body.tcl $frigo/Remember.tcl $frigo/report-orig $frigo/COMMAND $frigo/LABEL]
	rename pstoreReportWasThere {}
	wokUtils:EASY:ext $l Extensions
	if { [set unk [wokBAG:magic:CheckExt [array names Extensions]]] != {} } {
	    foreach ext $unk {
		puts "Error : Unknown extension $ext ( $Extensions($ext) )"
	    }
	    return 0
	}
	return 1
    } else {
	foreach f $ll {
	    puts stderr "File $f not found"
	}
	rename pstoreReportWasThere {}
	return 0
    }
}
#;>
# Lit un report enregistre par pstore, remplit une table
#;<
proc pstore:Report:Process { RepName } {
    foreach file [list Config.tcl WasThere.tcl Remember.tcl Header.tcl Body.tcl] {
	if { [file exists $RepName/$file] } {
	    source $RepName/$file
	} else {
	    puts stderr "Report:Process. File $file not found in $RepName."
	    return 0
	}
    }
    return 1
}
#;>
# retire les procs utilisees par un report
# Pour l'instant RepName n'est pas utilise (la proc est independante !!).
#;<
proc pstore:Report:UnProcess { RepName } {
    foreach proc [list pstoreReportConfig pstoreReportWasThere pstoreReportRemember pstoreReportHeader pstoreReportBody] {
	if { [info procs $proc] != {} } { 
	    rename $proc {}
	}
    }
}
#;>
# Retire un report du frigo, le report est donne par son full path
#;<
proc pstore:Report:Del { LISTREPORT {forced -1} } {
    foreach entry $LISTREPORT {
	if { [file owned $entry] || $forced != -1 } {
	    if { [pstore:Report:RmEntry $entry] == -1 } {
		return -1
	    }
	} else {
	    msgprint -c WOKBAG -e "You are not the owner of this report."
	    return -1
	}
    }
    return
}
#;>
# Detruit effectivement une entry (full path) dans la queue.
#;<
proc pstore:Report:RmEntry { fullentry } {
    foreach itm [glob -nocomplain $fullentry/*] {
	if [file isdirectory $itm] {
	    wokUtils:FILES:removedir $itm
	}
    }
    wokUtils:FILES:removedir $fullentry
    return
}
;#
;#
;#
proc pstore:Report:Getexcep { } {
    return [list LABEL COMMAND Remember.tcl Header.tcl Body.tcl cvt_data report-orig]
}

#;>
# Pour debugger. Imprime tout ce qui se trouve accroche sous ID
#;<
proc pstore:Report:Dump { D } {
    wokUtils:FILES:FindFile $D *
}
#;>
# Retourne le nom de l'entry associee a  ReportID {} sinon
#;<
proc pstore:Report:GetTrueName { ReportID listreport } {
    set ln [llength $listreport]
    if { $ln > 0 } {
	if [ regexp {^[0-9]+$} $ReportID ] {
	    set idm1 [expr $ReportID - 1]
	    set res [lindex $listreport $idm1]
	    if { $res != {} } {
		return $res
	    } else {
		msgprint -c WOKBAG -e "Bad report ID. Should be a digit and range into ( 1 and $ln ) "
		return {}
	    }
	} else {
	    msgprint -c WOKBAG -e "Bad report ID. Should be a digit and range into ( 1 and $ln ) "
	    return {}
	}
    } else {
	msgprint -c WOKBAG -e "Report Queue is empty."
	return {}

    }
}
#;>
#
# Retourne un nom de directory unique base sur l'heure /append le nom du report
#
#;<
proc pstore:Report:GetUniqueName { name } {
    if { [string first , $name] == -1 } {
	return [getclock],${name}
    } else {
	return {}
    }
}
#;>
# A partir d'un nom genere par GetUniqueName, retourne une liste de 2 elem
#   1. La date ayant servi a creer le directory
#   2. Le nom du report
#;<
proc pstore:Report:GetPrettyName { Uniquename } {
    set l [split $Uniquename ,]
    return [list [lindex $l 1] [fmtclock [lindex $l 0]] ]
}
;#
;# Retourne 1 si pnam est deja dans la liste des reports.
;#
proc pstore:Report:Exists { pnam ListReport } {
    if { [lsearch -glob $ListReport *,$pnam] == -1 } {
	return 0
    } else {
	return 1
    }
}
#;>
# Retourne la liste des reports ordonnee par rapport a leur date d'arrivee
#;<
proc pstore:Report:GetReportList { FrigoName } {
    if [file exists $FrigoName] {
	return [lsort -command pstore:Report:SortEntry [readdir $FrigoName] ]
    } else {
	return {}
    }
}
#;>
# Retourne l'index dans la queue d'un report -1 si existe pas
#;<
proc pstore:Report:Index { FrigoName Truename } {
    set i [lsearch [pstore:Report:GetReportList $FrigoName] $Truename]
    if { $i != -1 } {
	return [expr $i + 1]
    } else {
	return -1
    }
}
#;>
# Retourne a partir d'un full path le nom du report
#;<
proc pstore:Report:Head { fullpath } {
    if [regexp {.*/([0-9]*,[^/]*)} $fullpath all rep] {
	return $rep
    } else {
	return {}
    }
}
#;
# Retourne la longueur  de la liste des reports en attente dans shop
#;<
proc pstore:Report:QueueLength { fshop } {
    return [llength [pstore:Report:GetReportList [pstore:Report:GetRootName]]]
}

#;>
# Commande utilise pour le tri ci dessus: (u,string1 > v,string2 <=> u > v)
#;<
proc pstore:Report:SortEntry { a b } {
    set lna [split $a ,] 
    set lnb [split $b ,]
    return [expr [lindex $lna 0] - [lindex $lnb 0] ]
}

;#
;# Retourne  un ou plusieurs pathes de report, mangeables par pstore:Report:Process
;#
proc pstore:Report:Get { id fshop } {
    set l {}
    if { [pstore:Report:QueueLength $fshop] != 0 } {
	set FrigoName [pstore:Report:GetRootName]
	if { $FrigoName != {} } {
	    set ListReport [pstore:Report:GetReportList $FrigoName] 
	    if { $ListReport != {} } {
		if { "$id" == "all" } {
		    foreach e $ListReport {
			lappend l $FrigoName/$e
		    }
		} else {
		    set brep [pstore:Report:GetTrueName $id $ListReport]
		    if { "$brep" != "" } {
			lappend l $FrigoName/$brep
		    }
		}
	    } else {
		msgprint -c WOKBAG -e "Unable to get report list."
	    }
	} else {
	    msgprint -c WOKBAG -e "Administration directory for $fshop not found. No report was stored."
	}
    } else {
	msgprint -c WOKBAG -i "Report queue is empty."
    }
    return $l
}
;#
;# Create root for report's queue. 
;#
proc pstore:Report:MkRoot { fshop {create 0} } {
    set root [pstore:Report:GetRootName]
    if [file exists $root] {
	return $root
    } else {
	if { $create } {
	    wokUtils:DIR:create $root
	    chmod 0777 $root
	    return $root
	} else {
	    return {}
	}
    }
}
;#
;# Actually send the mail.
;# The user "from"
;# The subject
;#
proc pstore:mail:Send { subject text } {
    foreach user [pstore:mail:Users] { 
	wokUtils:EASY:mail $user [id user] {} $subject $text send 
    }

}
