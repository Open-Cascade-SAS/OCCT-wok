 
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
	Usage : wstore          [-f] [-rm|-ls|-cat] [-queue name] [filename] 
	
	wstore filename            : Add a report in the report's list from <filename>.     
	wstore [-ls]               : Lists pending reports with their owner and IDs.        
	wstore -cat <report_ID>    : Shows the content of <report_ID>.                      
	wstore [-f] -rm <report_ID>: Remove a report from the queue                         
	: (-f used to force if you dont own the report).          
	
	Backup/Admin options:                                                               
	-ctar <filename>  : Create a tar file named <filename> with all reports in queue.  
	-xtar <filename>  : Add all reports from tar file <filename>.                      
	Add -v option to display informational  messages               
	
	-dump <report_ID> : Dump contents of Report .                                      
	-param            : Lists queue parameters associed with the concerned workshop.   
	
	To store a "wpack archive files":                                                
	
	wstore -ar Archname.Z  (See command wpack)                                        
	
	-queue option allows you to specify a queue name.                                  
	To create a queue named XXX , define parameter VC_XXX (VC.edl) to a directory name. 
	The queue XXX will be created under this directory.                             
	
    }
    return
}   
#
# Point d'entree de la commande
#
proc wstore { args } {

    set tblreq(-h)         {}
    set tblreq(-f)         {}
    set tblreq(-rm)        {}
    set tblreq(-ls)        {}
    set tblreq(-cat)       {}
    set tblreq(-trig)      {}

    set tblreq(-ctar)      value_required:string
    set tblreq(-xtar)      value_required:string
    set tblreq(-v)         {} 

    set tblreq(-ar)        value_required:string

    set tblreq(-dump)      {}
    set tblreq(-param)     {}

    set tblreq(-ws)        value_required:string

    set tblreq(-queue)     value_required:string

    set param {}

    if { [wokUtils:EASY:GETOPT param tabarg tblreq wokStoreUsage $args] == -1 } return

    set option_specified [array exists tabarg]

    if { [info exists tabarg(-h)] } {
	wokStoreUsage
	return
    }
    
    if { [info exists tabarg(-f)] } {
	set forced -1
    } else {
	set forced 0
    }
    
    if [info exists tabarg(-ws)] {
	set fshop $tabarg(-ws)
    } else {
	set fshop [wokinfo -s [wokcd]]
    }
    set lshop [finfo -s $fshop]
    if { [lsearch $lshop [wokinfo -n [wokinfo -s $fshop]] ] == -1 } {
	msgprint -c WOKVC -e "Invalid Shop name or no current shop. Should be one of $lshop."
	return
    }

    if { [info exists tabarg(-param)] } {
	wokStore:Report:GetType $fshop 1
	return
    }
    
    if [info exists tabarg(-queue)] {
	set inqueue $tabarg(-queue)
	set FrigoName [wokStore:Report:GetQName $fshop $tabarg(-queue) 1]
    } else {
	set inqueue "default queue of $fshop"
	set FrigoName [wokStore:Report:GetRootName $fshop 1]
    }

    if { $FrigoName == {} } {
	msgprint -c WOKVC -e "Bad queue name. Check file [wokinfo -p AdmDir]/VC.edl"
	return
    }


    if { [info exists tabarg(-ar)] } {
	set Zadr $tabarg(-ar)
	set adr [wokUtils:FILES:SansZ $Zadr]
	if { $adr != -1} {
	    if ![catch {set idar [open $adr r]} status] {
		set TID [file tail $adr]
		set entry [wokStore:Report:GetUniqueName $TID]
		if { $entry != {} } {
		    wokStore:Report:UnPack $idar  $FrigoName/${entry}
		    close $idar
		} else {
		    msgprint -c WOKVC -e "Report name should not contains a comma."   
		}
	    } else {
		puts stderr "Error: $status"
	    }
	    if [file exists $adr] {
		catch {unlink $adr}
	    }
	}
	return
    }


    set ListReport [wokStore:Report:GetReportList $FrigoName] 
    ;#
    ;#  Options ne s'appliquant pas a un ID
    ;#    
    set ID [lindex $param 0]

    if { $ID == {} } {
	if { ( [info exists tabarg(-ls)] == 1 ) || ( $option_specified == 0 ) } {
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
	} else {
	    if [info exists tabarg(-ctar)] {
		if { $ListReport != {} } {
		    set tarfile $tabarg(-ctar)
		    if { [file dirname $tarfile] == "." } {
			set tarfile [pwd]/$tarfile
		    }
		    if [file writable [file dirname $tarfile]] {
			return [wokStore:Queue:Tar $FrigoName $tarfile]
		    } else {
			msgprint -c WOKVC -e "You cannot write in [file dirname $tarfile]"
			return {}
		    }
		} else {
		    msgprint -c WOKVC -e "Report Queue is empty."
		    return {}
		}
	    }
	    if [info exists tabarg(-xtar)] {
		set tarfile $tabarg(-xtar)
		if { [file exists $tarfile] } {
		    wokStore:Queue:Untar $tarfile $FrigoName [info exists tabarg(-v)]
		} else {
		    msgprint -c WOKVC -e "File $tarfile not found."
		    return {}  
		}
	    }
	}
	return
    }

    ;#
    ;#  Options s'appliquant a un ID
    ;# 

    if ![wokUtils:FILES:ValidName $ID] {
	msgprint -c WOKVC -e "Malformed command or invalid file name $ID"
	return {}
    }
    
    wokPrepare:Report:InitTypes
    
   if [info exists tabarg(-rm)] {
       set entry [wokStore:Report:GetTrueName $ID $ListReport]
       if { $entry != {}  } {
	 wokStore:Report:Del $FrigoName/$entry $forced  
       }
       return
   }
   
   if [info exists tabarg(-cat)] {
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

   if [info exists tabarg(-dump)] {
       set entry [wokStore:Report:GetTrueName $ID [wokStore:Report:GetReportList $FrigoName]]
       return [wokStore:Report:Dump $FrigoName/$entry]
   }

   set trig [info exists tabarg(-trig)]
   set trigexist [wokStore:Trigger:Exists $fshop]
   if { $trigexist != {} } {
       set ask [wokStore:Trigger:Invoke $fshop allways_activate {}]
       if { $ask == 0 } {
	   if { $trig == 0 } {
	       set trigger {}
	   } else {
	       set trigger $trigexist
	   }
       } else {
	   set trigger $trigexist
       }
   } else {
       if { $trig != 0 } {
	   msgprint -c WOKVC -w "Option -trig ignored. No trigger was declared for $fshop"
       }
       set trigger {}
   }
   
   set ID [lindex $ID 0]
   if [file exists $ID] {
       set TID [file tail $ID]
       set entry [wokStore:Report:GetUniqueName $TID]
       if { $entry != {}  } {
	   if { [wokStore:Report:Add $ID $FrigoName/${entry}_TMP _TMP] != -1 } {
	       if { [catch { frename $FrigoName/${entry}_TMP $FrigoName/${entry} }] == 0 } {
		   msgprint -c WOKVC -i "Report $TID has been stored in queue $inqueue."
		   if { $trigger != {} } {
		       wokStore:Trigger:Invoke $fshop put $FrigoName/${entry}
		   }
	       } else {
		   msgprint -c WOKVC -e "(rename) during storage of $TID"
	       }
	   } else {
	       msgprint -c WOKVC -e "(write) during storage of $TID"
	       catch { exec rm -rf $FrigoName/${entry}_TMP }
	   }
       } else {
	   msgprint -c WOKVC -e "Report name $ID should not contains a comma."
       }
   } else {
       msgprint -c WOKVC -e "File $ID not found."
   }
   return
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
#;>
# Appel un trigger pour wstore
#;<
proc wokStore:Trigger:Invoke { fshop action report_path } {
    set trignam [wokStore:Trigger:Exists $fshop]
    if { $trignam != {} } {
	uplevel #0 source $trignam 
	;#msgprint -c WOKVC -i "Invoking  file $trignam."
	if { [catch { wstore_trigger $action $report_path } trigval ] == 0 } {
	    ;#msgprint -c WOKVC -i "Trigger $trignam successfully completed"
	    return $trigval
	} else {
	    msgprint -c WOKVC -e "Error in trigger: $trigval"
	    return {}
	}
    }
    
    return
}
#;>
# Retourne si il y en a un le trigger associe a shop
# 
#;<
proc wokStore:Trigger:Exists { fshop } {
    set trignam [wokinfo -p AdmDir ${fshop}]/wstore_trigger.tcl
    if { [file exists $trignam] } {
	return $trignam
    } else {
	return {}
    }
}
#;>
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
proc wokStore:Report:Add { ID frigo sfx} {
    catch { unset table banner notes }
    wokPrepare:Report:Read $ID table banner notes 
    set writact $banner
    mkdir -path $frigo
    chmod 0777 $frigo
    regsub ${sfx}$ $frigo "" pthfrig
    set LST [lsort [array names table]]
    foreach e $LST {
	msgprint -c WOKVC -i [format "Processing unit : %s" $e]
	mkdir -path $frigo/$e
	chmod 0777 $frigo/$e
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
			    chmod 0777 $frigo/$e/$file
			    lappend writact "+ $pthfrig/$e/$file"
			} else {
			    return -1
			}
		    }
		    = {
			;#puts stderr "Warning:File $file not modified. Ignored"
		    }
		    # {
			if { [wokUtils:FILES:copy $orig/$file $frigo/$e/$file] != -1 } {
			    chmod 0777 $frigo/$e/$file
			    lappend writact "# $pthfrig/$e/$file"
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
    chmod 0777 [list $frigo/report-orig $frigo/report-work $frigo/report-notes]
    return 1
}
#;>
# Retourne une map tif(unit.t) { {source toto.c /a/b/toto.c} ... }
# cree a partir d'un report filename. Utilise par wpack -rep
#;<
proc wokStore:Report:Pack { fileid filename verbose } {
    catch { unset table banner notes }
    wokPrepare:Report:InitTypes
    wokPrepare:Report:Read $filename table banner notes 
    set writact $banner
    set LST [lsort [array names table]]
    foreach e $LST {
	set ll {}
	lappend writact "* $e"
	foreach l $table($e) {
	    set str [wokUtils:LIST:Trim $l]
	    set flag [lindex $str 0]
	    set file [lindex $str 3]
	    switch -- $flag {
		- {
		    lappend ll [list source $file [lindex $str 5]/$file]
		    lappend writact "# [lindex $str 5]/$file"
		}
		+ {
		    lappend ll [list source $file [lindex $str 4]/$file]
		    lappend writact "# [lindex $str 4]/$file"
		}
		= {
		    lappend ll [list source $file [lindex $str 4]/$file]
		    lappend writact "# [lindex $str 4]/$file"
		}
		# {
		    lappend ll [list source $file [lindex $str 4]/$file]
		    lappend writact "# [lindex $str 4]/$file"
		}
		
		default {
		    msgprint -c WOKVC -w "Ignored line: $l"
		}
	    }
	}
	set str [wokPrepare:Report:UnitHeader tolong $e]
	set typ [lindex $str 0]
	set nam [lindex $str 1]
	if { $verbose } { msgprint -c WOKVC -i "Packing $typ $nam..." }
	puts $fileid [format "=!=!=!=!=!=!=!=!=!=! %s %s" $typ $nam]
	upack:Fold $ll $fileid [upack:Upackable] 0
    }
    puts $fileid [format "=!=!=!=!=!=!=!=!=!=! report-orig report-orig"]
    puts $fileid "=+=+=+=+=+=+=+=+=+=+ source report-orig"
    foreach x [wokUtils:FILES:FileToList $filename] { puts $fileid $x }
    puts $fileid "=!=!=!=!=!=!=!=!=!=! report-notes report-notes"
    puts $fileid "=+=+=+=+=+=+=+=+=+=+ source report-notes"
    foreach x $notes { puts $fileid $x }
    puts $fileid "=!=!=!=!=!=!=!=!=!=! report-work report-work"
    puts $fileid "=+=+=+=+=+=+=+=+=+=+ source report-work"
    foreach x $writact { puts $fileid $x }
    return 
}
#;>
# Inverse du precedent.
#;<
proc wokStore:Report:UnPack { fileid frigo } {
    wokPrepare:Report:InitTypes
    set origact [set writact [wokPrepare:Report:ListInfo unknown unknown unknown]]
    while {[gets $fileid line] >= 0 } {
	if { [regexp {^=\+=\+=\+=\+=\+=\+=\+=\+=\+=\+ ([^ ]*) ([^ ]*)} $line ignore type name] } {
	    if [info exist fileout] {catch {close $fileout; unset fileout } }
	    if ![catch { set fileout [open $curdir/$name w] } errout] {
		lappend writact "# $curdir/$name"
		lappend origact "   $name"
	    } else {
		msgprint -e "$errout"
		return -1
	    }
	} elseif {[regexp {^=!=!=!=!=!=!=!=!=!=! ([^ ]*) ([^ ]*)} $line ignore utyp unam]}  {
	    if [string match report-* $utyp] {
		set curdir $frigo
	    } else {
		set curdir $frigo/${unam}.[set s [wokPrepare:Report:UnitHeader ltos $utyp]]
		msgprint -c WOKVC -i [format "Processing unit : %s" ${unam}.${s}]
		catch { mkdir -path $curdir }
		lappend writact "* ${unam}.${s}"
		lappend origact "\n * ${unam} ($utyp):\n"
	    }
	} else {
	    if [info exist fileout] {
		puts $fileout $line
	    }
	}

    }
    if [info exist fileout] {catch {close $fileout; unset fileout} }

    if ![file exists $frigo/report-work] {
	wokUtils:FILES:ListToFile $writact $frigo/report-work
    }

    if ![file exists $frigo/report-notes] {
	set cmt [wokIntegre:Journal:EditReleaseNotes [id user] {It was a workbench backup(wpack)}]
	wokUtils:FILES:ListToFile  $cmt $frigo/report-notes
    }

    if ![file exists $frigo/report-orig]  { 
	set cmt [wokIntegre:Journal:EditReleaseNotes [id user] {This is a workbench backup(wpack)}]
	wokUtils:FILES:ListToFile [concat $origact $cmt] $frigo/report-orig
    }

    chmod 0777 [list $frigo/report-orig $frigo/report-work $frigo/report-notes]
    return
}
#;>
# Retire un report du frigo, le report est donne par son full path
#;<
proc wokStore:Report:Del { LISTREPORT {forced -1} } {
    foreach entry $LISTREPORT {
	if { [file owned $entry] || $forced != -1 } {
	    if { [wokStore:Report:RmEntry $entry] == -1 } {
		return -1
	    }
	} else {
	    msgprint -c WOKVC -e "You are not the owner of this report."
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
	    wokUtils:FILES:removedir $itm
	}
    }
    wokUtils:FILES:removedir $fullentry
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
		    foreach f [readdir $dir] {
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
#
# Retourne le full path de la racine de la file de nom name. Ce path se trouve dans la variable EDL
# VC_<name>.
#;<
proc wokStore:Report:GetQName { fshop name {create 0} } {
    if { [lsearch {TYPE ROOT WBROOT DEFAULT EDL} $name] == -1 } {
	set pth {}
	catch { set pth [wokparam -e %VC_${name} $fshop] }
	if { $pth != {} } {
	    set diradm [file join $pth FRIGO]
	    if [file exists $diradm] {
		return $diradm
	    } else {
		if { $create } {
		    msgprint -c WOKVC -i "Creating file $diradm"
		    mkdir -path $diradm
		    chmod 0777 $diradm
		    return $diradm
		} else {
		    return {}
		}
	    }
	} else {
	    return {}
	}
    } else {
	msgprint -c WOKVC -e "The string $name should not be used as a queue name."
	return {}
    }
}
    
#;>
#
# Retourne le full path de la racine ou on accroche les reports pour le "gel" des sources d'un ilot.
#  1. Si create = 1 le cree dans le cas ou il n'existe pas.
#;<
proc wokStore:Report:GetRootName { fshop {create 0} } {
    set root [wokStore:Report:GetAdmName $fshop $create]/FRIGO
    if [file exists $root] {
	return $root
    } else {
	if { $create } {
	    mkdir -path $root
	    chmod 0777 $root
	    return $root
	} else {
	    return {}
	}
    }
}
#;>
# Retourne le full path du repertoire d'administration de wstore pour un ilot donne.
#  1. Si create = 1 le cree dans le cas ou il n'existe pas.
#;<
proc wokStore:Report:GetAdmName { fshop {create 0} } {
    set diradm [wokparam -e %VC_ROOT $fshop]/adm/[wokinfo -n [wokinfo -s $fshop]]
    if [file exists $diradm] {
	return $diradm
    } else {
	if { $create } {
	    msgprint -c WOKVC -i "Creating file $diradm"
	    mkdir -path $diradm
	    chmod 0777 $diradm
	    return $diradm
	} else {
	    return {}
	}
    }
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
proc wokStore:Report:GetPrettyName { Uniquename } {
    set l [split $Uniquename ,]
    return [list [lindex $l 1] [fmtclock [lindex $l 0]] ]
}

#;>
# Retourne la liste des reports ordonnee par rapport a leur date d'arrivee
#;<
proc wokStore:Report:GetReportList { FrigoName } {
    if [file exists $FrigoName] {
	return [lsort -command wokStore:Report:SortEntry [readdir $FrigoName] ]
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
# Retourne la longueur  de la liste des reports en attente dans shop
#;<
proc wokStore:Report:QueueLength { fshop } {
    return [llength [wokStore:Report:GetReportList [wokStore:Report:GetRootName $fshop]]]
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
proc wokStore:Report:Get { id fshop } {
    set l {}
    if { [wokStore:Report:QueueLength $fshop] != 0 } {
	set FrigoName [wokStore:Report:GetRootName $fshop]
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
	    msgprint -c WOKVC -e "Administration directory for $fshop not found. No report was stored."
	}
    } else {
	msgprint -c WOKVC -i "Report queue is empty or workshop not found."
    }
    return $l
}
;#
;# Renvoie 1 si on peut faire store dans une queue associee au workbench.
;# Pour l'instant workbench racine
;#
proc wokStore:Queue:Enabled { shop wb } {
    if { "[wokIntegre:RefCopy:GetWB ${shop}]" == "$wb" } {
	return 1
    } else {
	return 0
    }
}


;#
;# Fait ls d'une file qname. Si qname = {} ls de la file de l'ilot.
;#
proc wokStore:Report:LS { FrigoName } {
    set i 0
    wokStore:Report:InitState $FrigoName tabdup
    foreach e [wokStore:Report:GetReportList $FrigoName] { 
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
}

;#
;# Queue -> Tar retourne 1 si OK tarfile n'est pas compresse
;#
proc wokStore:Queue:Tar { FrigoName tarfile } {
    set savpwd [pwd]
    cd $FrigoName
    set stat [wokUtils:EASY:tar tarfromroot $tarfile .]
    cd $savpwd
    return $stat
}
;#
;# Tar -> Queue retourne 1 si OK, tarfile est decompresse
;#
proc wokStore:Queue:Untar { tarfile FrigoName {verbose 0} } {
    set tmpfrig [wokUtils:FILES:tmpname TMPFRIG]
    catch { exec rm -rf $tmpfrig } statrm
    catch { mkdir -path $tmpfrig } statmk
	
    if [file exists $tmpfrig] {
	set savpwd [pwd]
	cd $tmpfrig
	set stat [wokUtils:EASY:tar untar $tarfile]
	set ListReport [wokStore:Report:GetReportList $tmpfrig]
	set inx 0
	foreach e $ListReport {
	    set label [getclock],[lindex [split $e ,] 1]
	    if [catch { exec  cp -rp $tmpfrig/$e $FrigoName/$label } status] {
		msgprint -c WOKVC -e "$status"
	    } else {
		if { $verbose == 1 } {
		    msgprint -c WOKVC -i "Report [incr inx] has been restored."
		}
	    }
	}
	cd $savpwd
	catch { exec rm -rf $tmpfrig } 

	if { $verbose == 1 } {
	    msgprint -c WOKVC -i "A total of $inx reports has been restored."
	}
	return $inx
    } else {
	return 0
    }
}
;#
;# Parametres
;#
#;>
# Retourne le type de la base courante.  {} sinon => utiliser ca pour savoir si il y en une !!
#;<
proc wokStore:Report:GetType { fshop {dump 0} } {
    set lvc [wokparam -l VC $fshop]
    if { $lvc != {} } {
	if { [lsearch -regexp $lvc %VC_TYPE=*] != -1 } {
	    if { $dump } {
		foreach dir [wokparam -L $fshop] {
		    if [file exists $dir/VC.edl] {
			msgprint -c WOKVC -i "Following definitions in file : $dir/VC.edl"
			break
		    }
		}
		msgprint -c WOKVC -i "Repository root : [wokparam -e %VC_ROOT $fshop]"
		msgprint -c WOKVC -i "Repository type : [wokparam -e %VC_TYPE $fshop]" 
		msgprint -c WOKVC -i "Default queue   : [wokStore:Report:GetRootName $fshop]"
		msgprint -c WOKVC -i "Attached to     : [wokIntegre:RefCopy:GetWB $fshop]\n"

		foreach nam $lvc {
		    if [regsub {^%VC_} $nam {} msg] {
			set t [split $msg =]
			if { [lsearch {TYPE ROOT WBROOT DEFAULT EDL} [lindex $t 0] ] == -1 } {
			    msgprint -c WOKVC -i "[lindex $t 0]             : [lindex $t 1]"
			}
		    }
		}

	    }
	    return  [wokparam -e %VC_TYPE $fshop]
	} else {
	    return {}
	}
    } else {
	return {}
    }
}
