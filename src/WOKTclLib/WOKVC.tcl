
#############################################################################
#
#                              W I N T E G R E
#                              _______________
#
#############################################################################
#
# Usage
#
proc wokIntegreUsage { } {
    puts stderr { }    
    puts stderr { usage : wintegre [ <reportID> ]}
    puts stderr { }        
    puts stderr {          <reportID>  is a number. The range of the report in the queue.}
    puts stderr {          You get this number by using the command : wstore -ls }
    puts stderr { }
    puts stderr {  -ref    <Base-number> }
    puts stderr {          Used to init version of elements in the repository.}
    puts stderr { }        
    puts stderr {  -all      : Process all reports in the queue. }
    puts stderr { }
    puts stderr {  -norefcopy: Update the repository but don't update target workbench." }
    puts stderr {  -nobase   : Update the target workbench but don't update the repository. }
    puts stderr {              These 2 previous options are mutually exclusive. }
    puts stderr {  -ws Shop  : Use Shop as working shop. Shop has the form Factory:shop. }
    puts stderr {              Default is the current workshop.                          }
    puts stderr {  -root wb  : Use wb as the target workbench. }
    puts stderr {  -param    : Show the current value of parameters. }
    return
}
#
# Point d'entree de la commande
#
proc wintegre { args } {

    set tblreq(-h)         {}
    set tblreq(-ref)       value_required:number
    set tblreq(-all)       {}
    set tblreq(-norefcopy) {}
    set tblreq(-nobase)    {}
    set tblreq(-ws)        value_required:string 
    set tblreq(-root)      value_required:string
    set tblreq(-V)         {}
    set tblreq(-param)     {}

    set disallow(-nobase)    {-norefcopy}
    set disallow(-norefcopy) {-nobase}

    set param {}
    if { [wokUtils:EASY:GETOPT param tabarg tblreq wokIntegreUsage $args] == -1 } return
    if { [wokUtils:EASY:DISOPT tabarg disallow wokIntegreUsage ] == -1 } return

    set VERBOSE [info exists tabarg(-V)]

    if { $VERBOSE } {
	puts "param = $param"
	catch {parray tabarg}
    }
    
    if { [info exists tabarg(-h)] } {
	wokIntegreUsage 
	return
    }

    if [info exists tabarg(-ws)] {
	set fshop $tabarg(-ws)
    } else {
	set fshop [Sinfo -s]
    }

    if { [info exists tabarg(-param)] } {
	wokIntegre:BASE:GetType $fshop 1
	return
    }

    if { [set refer [info exists tabarg(-ref)]] } {
	set vrsref $tabarg(-ref)
    }

    set refcopy [expr ![info exists tabarg(-norefcopy)]]
    set nobase  [info exists tabarg(-nobase)]

    if [info exists tabarg(-root)] {
	set wbtop $tabarg(-root)
	msgprint -c WOKVC -i "Using $wbtop as target workbench."
    } else {
	set wbtop [wokIntegre:RefCopy:GetWB]
    }

    if { [info exists tabarg(-all)] } {
	set LISTREPORT [wokStore:Report:Get all $fshop ]
    } else {
	if { [llength $param] == 1 } {
	    set ID [lindex $param 0]
	    set LISTREPORT [wokStore:Report:Get $ID $fshop ]
	} else {
	   wokIntegreUsage 
	    return -1 
	}
    }
	
    ;# fin analyse des arguments

    if { $VERBOSE } {
	puts stderr "refer      = $refer"
	if { $refer } { puts stderr "  vrsref = $vrsref" }
	puts stderr "refcopy    = $refcopy"
	puts stderr "nobase     = $nobase"
	puts stderr "fshop      = $fshop"
	puts stderr "wbtop      = $wbtop"
	puts stderr "LISTREPORT = $LISTREPORT"
    }

    if { [set BTYPE [wokIntegre:BASE:InitFunc $fshop]] == {} } {
	return -1
    }
    ;#
    ;# ClearCase : La base n'est pas geree par WOK
    ;#
    if { "$BTYPE" == "ClearCase" } {
	wokIntegreClearCase
	return
    }
    ;#
    ;# Autre : SCCS, RCS, NOBASE, SIMPLE geree par WOK
    ;#
    set broot [wokIntegre:BASE:GetRootName $fshop 1]
    if ![file writable $broot] {
	msgprint -c WOKVC -e "You cannot write in $broot."
	return -1
    }

    set vc [file join [wokinfo -pAdmDir:. $fshop] VC.tcl]
    if [file exists $vc] {
	source $vc
    } else {
	msgprint -c WOKVC -e "Pas de fichier VC.tcl dans adm de ${fshop} ."
	return -1
    }

    set ros [wokIntegre:RefCopy:OpenWB]
    set los [wokIntegre:RefCopy:OpenUD]

    if { "$BTYPE" == "NOBASE" } {
	wokIntegrenobase
    } else {
	if { $nobase } {
	    wokIntegrenobase
	} else {
	    wokIntegrebase
	}
    }
    return
}
#;>
# Miscellaneous: Assemblage traitement avec base
#;<
proc wokIntegrebase  { } {
    uplevel {
        foreach REPORT $LISTREPORT {
	    if { $VERBOSE } { msgprint -c WOKVC -i "Processing report in $REPORT" }
	    set num [wokIntegre:Number:Get $fshop 1]
	    if { [wokUtils:FILES:dirtmp [set dirtmp /tmp/wintegre[id process]]] == -1 } {
		msgprint -c WOKVC -e "Unable to create working directory"
		return -1
	    }
	    set jnltmp $dirtmp/wintegre.jnl
	    set jnlid [open $jnltmp w]
	    set comment [wokIntegre:Journal:Mark [wokinfo -n [wokinfo -s $fshop]] $num rep]
	    ;#
	    ;# Lecture du report
	    ;#  
	    set mode normal
	    if { $refer } { set mode ref }
	    catch {unset table}
	    set stat [wokStore:Report:Process $mode $REPORT table info notes]
	    if { $stat == -1 } {
		wokIntegreCleanup $broot table [list $jnlid] $dirtmp 
		return -1
	    }
	    ;#
	    ;#  Recup version associee a l'ilot et Inits
	    ;#
	    if { $refer } {
		set version [wokIntegre:Version:Check $fshop $vrsref]
		set func wokIntegre:BASE:InitRef
	    } else {
		set version [wokIntegre:Version:Get $fshop]
		set func wokIntegre:BASE:UpdateRef
	    }
	    
	    if { $version == {} } {
		msgprint -c WOKVC -e "Unable to get base version for $fshop"
		wokIntegreCleanup $broot table [list $jnlid] $dirtmp 
		return -1
	    }
	    ;#
	    ;# 1. Bases temporaires : Ecriture de la commande
	    ;# 
	    set cmdtmp $dirtmp/wintegre.cmd
	    set cmdid [open $cmdtmp w]
	    
	    $func $broot table $version $comment $cmdid
	    wokIntegre:BASE:EOF $cmdid ; close $cmdid

	    ;#
	    ;# 1 bis. Tester [id user] peut ecrire dans le workbench qui sert de REFCOPY
	    ;#
	    if { $refcopy == 1 } {
		set write_ok [wokIntegre:RefCopy:Writable $fshop table $wbtop $ros $los]
		if { $write_ok == -1 } {
		    msgprint -c WOKVC -e "You cannot write or create units in the workbench $wbtop"
		    wokIntegreCleanup $broot table [list $cmdid $jnlid] $dirtmp 
		    return -1
		}
	    }    
	    
	    ;#
	    ;# 2. Bases temporaires : Execution et ecriture journal temporaire
	    ;#    
	    wokPrepare:Report:ReadInfo $info station workshop workbench
	    wokIntegre:Journal:WriteHeader rep $num $workbench $station $jnlid
	    
	    set statx [wokIntegre:BASE:Execute $VERBOSE $cmdtmp $jnlid] 
	    if { $statx != 1 } {
		set cmd [file tail $cmdtmp]
		wokUtils:FILES:copy $cmdtmp $cmd
		wokIntegreCleanup $broot table [list $cmdid $jnlid] $dirtmp 
		msgprint -c WOKVC -e "occuring while creating temporary bases. Repository not modified."
		msgprint -c WOKVC -e "Dump script in file [pwd]/$cmd"
		return -1
	    }
	    
	    ;#
	    ;# 3. Ecriture Bases definitives
	    ;#
	    foreach UD [lsort [array names table]] {
		msgprint -c WOKVC -i [format "Updating unit %s in repository" $UD]
		wokIntegre:BASE:Fill $broot/$UD [wokIntegre:BASE:BTMPCreate $broot $UD 0]
	    }

	    
	    ;#
	    ;# 4. Fermer le journal temporaire
	    ;#
	    wokIntegre:Journal:WriteNotes $notes $jnlid ; close $jnlid
	    
	    ;#
	    ;# 5. Mettre a jour le journal , le scoop et le compteur et le numero de version si -ref
	    ;#
	    wokUtils:FILES:concat [wokIntegre:Journal:GetName $fshop 1] $jnltmp
	    wokIntegre:Scoop:Create $fshop $jnltmp
	    
	    if { [wokIntegre:Number:Put $fshop [wokIntegre:Number:Incr $fshop]] == {} } {
		msgprint -c WOKVC -e "during update of counter."
		wokIntegreCleanup $broot table [list $cmdid $jnlid] $dirtmp 
		return -1
	    }
	    
	    if { $refer } {
		wokIntegre:Version:Put $fshop $version
	    }
	    
	    ;#
	    ;# 6. Si refcopy = 1 Mise a jour de WBTOP 
	    ;#
	    if { $refcopy == 1 } {
		catch {unset table}
		wokIntegre:Journal:PickReport $jnltmp table notes $num
		wokIntegre:RefCopy:GetPathes $fshop table $wbtop $ros $los
		set dirtmpu /tmp/wintegrecreateunits[id process]
		catch {
		    rmdir -nocomplain $dirtmpu 
		    mkdir -path $dirtmpu
		}
		set chkout $dirtmpu/checkout.cmd
		set chkid  [open $chkout w]
		wokIntegre:RefCopy:FillRef $fshop table $chkid
		wokIntegre:BASE:EOF $chkid 
		close $chkid
		msgprint -c WOKVC -i "Updating units in target workbench(es) $wbtop $ros"
		set statx [wokIntegre:BASE:Execute $VERBOSE $chkout] 
		if { $statx != 1 } {
		    msgprint -c WOKVC -e "during checkout(Get). The report has not been removed."
		    wokIntegreCleanup $broot table [list $chkid] [list $dirtmpu]
		    return -1
		}
		wokIntegreCleanup $broot table [list $chkid] [list $dirtmpu]
	    }
	    
	    ;#
	    ;# 8. Detruire le report et menage
	    ;#
	    wokStore:Report:Del $REPORT 1
	    wokIntegreCleanup $broot table [list $cmdid $jnlid] [list $dirtmp]
	}
    }
}
#;>
# Miscellaneous: Assemblage traitement sans mise a jour de la base. 
#;<
proc wokIntegrenobase  { } {
    uplevel {
	foreach REPORT $LISTREPORT {
	    if { $VERBOSE } {msgprint -c WOKVC -i "Processing report in $REPORT"}
	    set num [wokIntegre:Number:Get $fshop 1]
	    if { [wokUtils:FILES:dirtmp [set dirtmp /tmp/wintegre[id process]]] == -1 } {
		msgprint -c WOKVC -e "Unable to create working directory"
		return -1
	    }
	    set jnltmp $dirtmp/wintegre.jnl
	    set jnlid [open $jnltmp w]
	    set comment [wokIntegre:Journal:Mark [wokinfo -n [wokinfo -s $fshop]] $num rep]
	    ;#
	    ;# Lecture du report
	    ;#  
	    catch {unset table}
	    set stat [wokStore:Report:Process normal $REPORT table info notes]
	    if { $stat == -1 } {
		wokIntegreCleanup $broot table [list $jnlid] $dirtmp 
		return -1
	    }
	    
	    set write_ok [wokIntegre:RefCopy:Writable $fshop table $wbtop $ros $los]
	    if { $write_ok == -1 } {
		msgprint -c WOKVC -e "You cannot write or create units in the workbench $wbtop"
		wokIntegreCleanup $broot table [list $jnlid] $dirtmp
		return -1
	    }
	    set pathes_ok [wokIntegre:RefCopy:GetPathes $fshop table $wbtop $ros $los]
	    if { $write_ok == -1 } {
		wokIntegreCleanup $broot table [list $jnlid] $dirtmp
		return -1
	    }
	    
	    wokPrepare:Report:ReadInfo $info station workshop workbench
	    wokIntegre:Journal:WriteHeader rep $num $workbench $station $jnlid
	    
	    set copy_ok [wokIntegre:RefCopy:Copy $VERBOSE table $jnlid]
	    if { $copy_ok == -1 } {
		wokIntegreCleanup $broot table [list $jnlid] $dirtmp
		return -1
	    }
	    wokIntegre:Journal:WriteNotes $notes $jnlid ; close $jnlid
	    wokUtils:FILES:concat [wokIntegre:Journal:GetName $fshop 1] $jnltmp
	    if { [wokIntegre:Number:Put $fshop [wokIntegre:Number:Incr $fshop]] == {} } {
		msgprint -c WOKVC -e "during update of counter."
		wokIntegreCleanup $broot table [list $jnlid] $dirtmp 
		return -1
	    }
	    
	    wokStore:Report:Del $REPORT 1
	    wokIntegreCleanup $broot table [list $jnlid] $dirtmp 
	}
    }
}
#;>
#
# Miscellaneous: Fait le menage apres wintegre
#
# listid : liste de file descripteur a fermer
# dirtmp : liste de repertoire  a demolir
# table  : liste des UDs contenant une base temporaire
#;<
proc wokIntegreCleanup { broot table listid dirtmp } {
    upvar table TLOC

    foreach UD [array names TLOC] {
	wokIntegre:BASE:BTMPDelete $broot $UD
    }
    if [info exists listid] {
	foreach id $listid {
	    catch { close $id }
	}
    }
    if [info exists dirtmp] {
	foreach d $dirtmp {
	    catch { wokUtils:FILES:removedir $d }
	}
    }
    return
}
#;>
# Charge l'interface necessaire pour acceder aux bases de la factory.
# Se fait en fonction du type de repository code dans le parametre VC_TYPE
#
#;<
proc wokIntegre:BASE:InitFunc { fshop } {
    global env
    set wdir $env(WOK_LIBRARY)
    set type [wokIntegre:BASE:GetType $fshop ]
    if { $type != {} } {
	set interface $wdir/WOKVC.$type
	if [file exist $interface] {
	    uplevel #0 source $interface
	    return $type
	} else {
	    msgprint -c WOKVC -e "File $interface not found."
	    return {}
	}
    } else {
	msgprint -c WOKVC -w "Unknown type for source repository."
	return {}
    }
}
#;>
# Retourne le type de la base courante.  {} sinon => utiliser ca pour savoir si il y en une !!
#;<
proc wokIntegre:BASE:GetType { fshop {dump 0} } {
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
		puts $fshop
		msgprint -c WOKVC -i "Repository root : [wokparam -e %VC_ROOT $fshop]"
		msgprint -c WOKVC -i "Repository type : [wokparam -e %VC_TYPE $fshop]" 
		msgprint -c WOKVC -i "Attached to     : [wokIntegre:RefCopy:GetWB]" 
	    }
	    return  [wokparam -e %VC_TYPE $fshop]
	} else {
	    return {}
	}
    } else {
	return {}
    }
}
#;>
#######################################################################
# Updater la reference : Ecriture du fichier de commande base temporaire
#
# table  : table des UDs a traiter ( il ya des flags + - # )
# vrs    : version  a utiliser
# comment: Commentaire a coller dans l'historique PAS DE BLANC
# fileid : file descriptor
#######################################################################
#;<
proc wokIntegre:BASE:UpdateRef { broot table vrs comment fileid } {
    upvar table TLOC
    foreach UD [lsort [array names TLOC]] {
	set tmpud [wokIntegre:BASE:BTMPCreate $broot $UD 1]
	puts $fileid [format "echo Processing unit : %s" $UD]
	puts $fileid [format "cd %s" $tmpud]
	set root $broot/$UD
	foreach ELM $TLOC($UD) {
	    set mark _[lindex $ELM 0]
	    set F [lindex $ELM 1]
	    set bna [file tail $F]
	    set sfl $root/[wokIntegre:BASE:ftos $bna $vrs]
	    switch $mark {
		
		_+ {
		    if [file exists $sfl] {
			;#puts "Coucou: reapparition de $sfl"
			wokIntegre:BASE:UpdateFile $sfl $vrs $comment $F $fileid
		    } else {
			wokIntegre:BASE:InitFile $F $vrs $comment \
				$tmpud/[wokIntegre:BASE:ftos $bna $vrs] $fileid
		    }
		}
		
		_# {
		    if [file exists $sfl] {
			wokIntegre:BASE:UpdateFile $sfl $vrs $comment $F $fileid
		    } else {
			wokIntegre:BASE:InitFile $F $vrs $comment \
				$tmpud/[wokIntegre:BASE:ftos $bna $vrs] $fileid
		    }
		}
		
		_- {
		  wokIntegre:BASE:DeleteFile $bna $fileid
		}
	    }
	}
    }
    return
}
#;>
#######################################################################
# Init d'une reference: Ecriture du fichier de commande base temporaire
#
# table  : table des UDs a traiter
# vrs    : version de base a creer
# comment: Commentaire a coller dans l'historique
# fileid : file descriptor
########################################################################
#;<
proc wokIntegre:BASE:InitRef { broot table vrs comment fileid } {
    upvar table TLOC
    foreach UD [lsort [array names TLOC]] {
	set tmpud [wokIntegre:BASE:BTMPCreate $broot $UD 1]
	puts $fileid [format "echo Processing unit : %s" $UD]
	puts $fileid [format "cd %s" $tmpud]
	set root $broot/$UD
	foreach F $TLOC($UD) {
	    set bna [file tail $F]
	    set sfl $root/[wokIntegre:BASE:ftos $bna $vrs]
	    if [file exists $sfl] {
		wokIntegre:BASE:ReInitFile $sfl $vrs $comment $F $fileid
	    } else {
		wokIntegre:BASE:InitFile $F $vrs $comment $tmpud/[wokIntegre:BASE:ftos $bna $vrs] $fileid
	    }
	}
    }
    return
}
#;>
# Remplit une base Bname avec les elements de elmin (full pathes)
# Si la base n'existe pas la cree.   
# Par defaut le remplissage se fait avec frename (mv)
# Pour faire une copie (cp) action = copy (pas traite)
# Seuls les fichiers commencant par s. sont traites
# (sfiles ou des directories de sfiles)
#;<
proc wokIntegre:BASE:Fill { broot elmin {action move} } {
    set bdir $broot
    if ![file exists $bdir] {
	mkdir -path $bdir
	chmod 0777 $bdir
    }
 
    foreach e $elmin {
	if { [file isfile $e] } {
	    set bna [file tail $e]
	    catch { frename $e $bdir/$bna }
	} elseif { [file isdirectory $e] } {
	    set dl {}
	    foreach f [readdir $e] {
		lappend dl $e/$f
	    }
	    wokIntegre:BASE:Fill $broot $dl $action
	}
    }
    return $bdir
}
#;>
# Detruit une base Bname. 
#;<
proc wokIntegre:BASE:Delete { fshop Bname } {
    if [catch { exec rm -rf [wokIntegre:BASE:GetRootName $fshop]/$Bname } status ] {
	msgprint -c WOKVC -e "BASE:Delete $status"
	return -1
    } 
    return 1
}

#;>
# retourne le nom de la racine ou les bases sont accrochees.
# Il y a une etage de plus par rapport aux anciennes bases pour faciliter 
# les tests et la sauvegarde.
#;<
proc wokIntegre:BASE:GetRootName { fshop {create 0} } {
    set diradm [wokparam -e %VC_ROOT $fshop]/BASES
    if [file exists $diradm] {
	return $diradm
    } else {
	if { $create } {
	    msgprint -c WOKVC -i "Creating file $diradm"
	    mkdir -path $diradm
	    chmod 0755 $diradm
	    return $diradm
	} else {
	    return {}
	}
    }
}
#;>
# retourne 1 si le user courant peut ecrire dans les base de l'atelier courant
#;<
proc wokIntegre:BASE:Writable { fshop } {
    return [file writable [wokIntegre:BASE:GetRootName $fshop]]
}
#;>
# retourne la liste des bases sous la forme { {name ext} ... {name ext} } 
#;<
proc wokIntegre:BASE:LS { fshop } {
    set l {}
    set r [wokIntegre:BASE:GetRootName $fshop]
    if [file exists $r] {
	foreach e [lsort [readdir $r]] {
	    if { [string compare [file type $r/$e] file] != 0 } {
		lappend l [list [file root $e] [file extension $e]]
	    }
	}
    }
    return $l
}
#;>
# retourne la liste des bases ayant une base temporaire
#;<
proc wokIntegre:BASE:BTMPLS { fshop } {
    set l {}
    set r [wokIntegre:BASE:GetRootName $fshop]
    if [file exists $r] {
	foreach e [lsort [readdir $r]] {
	    if [file exists $r/$e/tmp] {
		lappend l $e
	    }
	}
    }
    return $l
}
#;>
# retourne le nom de la base temporaire associee a une Unit. Si create la cree
#;<
proc wokIntegre:BASE:BTMPCreate { broot Unit {create 0} } {
    if { $create } {
	wokIntegre:BASE:BTMPDelete $broot $Unit
	mkdir -path $broot/$Unit/tmp
    }
    return $broot/$Unit/tmp
}
#;>
# detruit la base temporaire associee a une Unit.
# Le directory est vide puis detruit. Il y a un seul niveau
# Le directory courant ne doit pas etre unit/tmp
#;<
proc wokIntegre:BASE:BTMPDelete { broot Unit } {
    set R $broot/$Unit/tmp
    if [file exists $R] {
	foreach f [readdir $R] {
	    unlink $R/$f
	}
	rmdir -nocomplain $R
    }
    return 1
}
#
#  ((((((((((((((((REFCOPY))))))))))))))))
#
#;>
#   Check owner et fait ucreate si necessaire des UDs de table
#   1. ucreate -p workbench:NTD si owner OK    
#   workbench est celui dans lequel on integre sauf si UD est dans
#   la liste $los auquel cas l'integration se fait dans ros
#;< 
proc wokIntegre:RefCopy:Writable { fshop table workbench ros los} {
    upvar $table TLOC

    foreach UD [array names TLOC] {
	regexp {(.*)\.(.*)} $UD ignore name type
	if { [lsearch $los $name] != -1 } {
	    set destwb $ros
	} else {
	    set destwb $workbench
	}
	if { [lsearch [w_info -l ${fshop}:${destwb}] $name ] == -1 } {
	    ucreate -$type ${fshop}:${destwb}:${name}
	}
	set dirsrc [wokinfo -p source:. ${fshop}:${destwb}:${name}]
	;#puts " writable dirsrc = $dirsrc"
	if ![file writable $dirsrc] {
	    msgprint -c WOKVC -e "You cannot write in workbench $destwb ($dirsrc)"
	    return -1
	}
    }
    return 1
}

#;>
#   1. Met en tete des elements de table (liste) le liste le full path du repertoire a alimenter
#      SOUS RESERVE QUE LES UDS aient deja ete crees.
#   Input:   table(NTD.p) = { {toto.c 2.1} {titi.c 4.3} } 
#   Output:  table(NTD.p) = { /home/wb/qqchose/NTD/src {toto.c 2.1} {titi.c 4.3} }
#;<
proc wokIntegre:RefCopy:GetPathes { fshop table workbench ros los} {
    upvar $table TLOC
    ;#puts "-------------AVANT getpathes ----------------"    
    ;#parray TLOC
    foreach UD [array names TLOC] {
	regexp {(.*)\.(.*)} $UD ignore name type
	if { [lsearch $los $name] != -1 } {
	    set destwb $ros
	} else {
	    set destwb $workbench
	}
	if { [lsearch [w_info -l ${fshop}:$destwb] $name ] != -1 } {
	    set lsf $TLOC($UD)
	    set TLOC($UD) [linsert $lsf 0 [wokparam -e %${name}_Src ${fshop}:${destwb}:${name}]] 
	} else {
	    msgprint -c WOKVC -e "(GetPathes) Unit $name not found in $destwb"
	    return -1
	}
    }
    ;#puts "-------------APRES----------------"
    ;#parray TLOC
    return 1
}
#;>
#   Copy les elements de table (liste) dans le repertoire associe
#   Utilise par wintegre -nobase
#   Input:  table(NTD.p) = { /home/wb/qqchose/NTD/src {flag1 path1} {flag2 path2} }
#   path :  adresse du fichier dans le frigo. 
#   Retour: { ... {p1 p2} ... } si OK {} sinon
#;<
proc wokIntegre:RefCopy:Copy { VERBOSE table {fileid stdout} } {
    upvar $table TLOC
   
    catch { unset err }
    set LUD [lsort [array names TLOC]]
    foreach ud $LUD {
	set lret {}
	set dirsrc [lindex $TLOC($ud) 0]
	foreach e [lrange $TLOC($ud) 1 end] {
	    if { "[lindex $e 0]" != "-" } {
		set fromp [lindex $e 1]
		set file [file tail $fromp]
		set destp $dirsrc/$file
		if { [file exists $fromp] } {
		    if { [file exists $destp] } {
			if { [file owned $destp] } {
			    lappend lret [list [format "    Modified  :  %s -.-" $file] $fromp $destp]
			} else {
			    msgprint -c WOKVC -e "Protection of $destp cannot be modified (not owner)."
			    set err 1
			    break
			}
		    } else {
			if { [file writable [file dirname $destp]] } {
			    lappend lret [list [format "    Added     :  %s -.-" $file] $fromp $destp]
			} else {
			    msgprint -c WOKVC -e "File $destp cannot be created (permission denied)."
			    set err 1
			    break
			}
		    }
		} else {
		    msgprint -c WOKVC -e "File $fromp doesnt not exists."
		    set err 1
		    break
		}
	    }
	}
	if [info exists err ] { break }
	set TLOC($ud) $lret
    }
    
    if [info exists err] { 
	msgprint -c WOKVC -i "No file copied."
	return -1 
    }

    foreach ud $LUD {
	puts $fileid [format "\n  %s (Updated) :  \n----" $ud]
	msgprint -c WOKVC -i [format "  %s (Updated) :  \n----" $ud]
	foreach d $TLOC($ud) {
	    set straff [lindex $d 0]
	    set fromp  [lindex $d 1]
	    set destp  [lindex $d 2]
	    msgprint -c WOKVC -i $straff
	    puts $fileid $straff
	    if { [file exists $destp] } {
		chmod 0644 $destp
	    }
	    if { $VERBOSE } { msgprint -c WOKVC -i "Copying $fromp $destp"}
	    wokUtils:FILES:copy $fromp $destp
	    chmod 0444 $destp
	}
    }

    return 1
}
#;>
# Ecriture du fichier de commande pour remplir ce qui se trouve decrit dans table
# (format :Journal:PickReport modifie par wokIntegre:RefCopy:Getpathes )
# Si un fichier a creer existe deja et est writable, il est renomme en -sav
# Comportement correspondant au remplissage du workbench de reference
#;<
proc wokIntegre:RefCopy:FillRef { fshop table {fileid stdout} } {
    upvar $table TLOC
    foreach UD [array names TLOC] {
	set lsf $TLOC($UD)
	set dirsrc [lindex $lsf 0]
	puts $fileid "cd $dirsrc"
	set root [wokIntegre:BASE:GetRootName $fshop]/$UD
	set i [llength $lsf]
	while { $i > 1 } {
	    set i [expr $i-1]
	    set elm  [lindex $lsf $i]
	    set vrs  [lindex $elm 1]
	    set file [lindex $elm 0]
	    if { [string compare $vrs x.x] != 0 } {
		if [file writable $dirsrc/$file] {
		    frename $dirsrc/$file $dirsrc/${file}-sav
		    msgprint -c WOKVC -i "File $dirsrc/$file renamed ${file}-sav"
		}
		set Sfile $root/[wokIntegre:BASE:ftos $file $vrs]
		wokIntegre:BASE:GetFile $Sfile $vrs $fileid
	    }
	}
    }
    return
}
#;>
# Ecriture du fichier de commande pour remplir ce qui se trouve decrit dans table
# (format :Journal:PickReport modifie par wokIntegre:RefCopy:Getpathes )
# Si un fichier a creer existe deja, il n'est pas ecrase
# Comportement correspondant au remplissage d'une UD avec wget.
# On change aussi la protection du fichier cree (writable pour le user)
#;<
proc wokIntegre:RefCopy:FillUser { fshop table {force 0} {fileid stdout} {mask 644} } {
    upvar $table TLOC
    foreach UD [array names TLOC] {
	set lsf $TLOC($UD)
	set dirsrc [lindex $lsf 0]
	puts $fileid "cd $dirsrc"
	set root [wokIntegre:BASE:GetRootName $fshop]/$UD
	set i [llength $lsf]
	while { $i > 1 } {
	    set i [expr $i-1]
	    set elm  [lindex $lsf $i]
	    set vrs  [lindex $elm 1]
	    set file [lindex $elm 0]
	    if { [string compare $vrs x.x] != 0 } {
		if [file exists $dirsrc/$file] {
		    if { $force } {
			if { [file writable $dirsrc/$file] } {
			    frename $dirsrc/$file $dirsrc/${file}-sav
			    msgprint -c WOKVC -i "File $dirsrc/$file renamed ${file}-sav"
			    set Sfile $root/[wokIntegre:BASE:ftos $file $vrs]
			    wokIntegre:BASE:GetFile $Sfile $vrs $fileid
			    puts $fileid [format "chmod %s %s" $mask $dirsrc/$file]
			} else {
			    msgprint -c WOKVC -e "File $dirsrc/$file is not writable. Cannot be overwritten."
			    return -1
			}
		    } else {
			msgprint -c WOKVC -e "File $dirsrc/$file already exists. Not overwritten."
		    }
		} else {
		    set Sfile $root/[wokIntegre:BASE:ftos $file $vrs]
		    wokIntegre:BASE:GetFile $Sfile $vrs $fileid
		    puts $fileid [format "chmod %s %s" $mask $dirsrc/$file]
		}
	    }
	}
    }
    return
}
#
#  ((((((((((((((((VERSION))))))))))))))))
#
#;>
# Retourne le path du fichier version.sccs, si create = 1 le cree s'il n'existe pas.
#;<
proc wokIntegre:Version:GetTableName { fshop {create 0} } {
    set diradm [wokparam -e %VC_ROOT $fshop]/adm/version.sccs
    if [file exists $diradm] {
	return $diradm
    } else {
	if { $create } {
	    msgprint -c WOKVC -i "Creating versions file in [file dirname $diradm]"
	    catch { mkdir -path [file dirname $diradm] }
	    wokUtils:FILES:ListToFile {} $diradm
	    chmod 0777 $diradm
	    return $diradm
	} else {
	    return {}
	}
    }
}
#;>
# Retourne la liste des ilots et leur numero associe.
#;<
proc wokIntegre:Version:Dump { fshop } {
    return [wokUtils:FILES:FileToList [wokIntegre:Version:GetTableName $fshop]]
}
#;>
# Retourne le numero de version associe a l'ilot <shop> {} sinon
#;<
proc wokIntegre:Version:Get { fshop } {
    set f [wokIntegre:Version:GetTableName $fshop]
    if { $f != {} } {
	set str [wokinfo -n [wokinfo -s $fshop]]
	foreach e [wokUtils:FILES:FileToList $f] {
	    if { $str == [lindex $e 0] } {
		return [lindex $e 1]
	    }
	}
    }
    return {}
}
#;>
# Ecrit dans version.sccs le numero de version <ver> associe a shop
#;<
proc wokIntegre:Version:Put { fshop ver } {
    set f [wokIntegre:Version:GetTableName $fshop]
    set l [wokUtils:FILES:FileToList $f]
    set str [wokinfo -n [wokinfo -s $fshop]]
    if { [lsearch $l [list $str $ver]] == -1 } {
	msgprint -c WOKVC -i "Registering the shop $str with version number $ver"
	lappend l [list $str $ver]
	wokUtils:FILES:copy $f ${f}-previous
	wokUtils:FILES:ListToFile $l $f
    }
    return $ver
}
#;>
# retourne un entier utilisable pour initialiser un nouvel ilot
#;<
proc wokIntegre:Version:Next { fshop } {
    set mx 0
    foreach e [wokUtils:FILES:FileToList [wokIntegre:Version:GetTableName $fshop]] {
	set n [lindex $e 1]
	set mx [expr ( $mx > $n ) ? $mx : $n]
    }
    return [incr mx]
}
#
#  ((((((((((((((((COMPTEUR-INTEGRATIONS))))))))))))))))
#
#;>
# Retourne le nom du fichier contenant le compteur d'integration 
#;<
proc wokIntegre:Number:GetName { fshop } {
    return [wokparam -e %VC_ROOT $fshop]/adm/[wokinfo -n [wokinfo -s $fshop]]/report.num
}
#;>
# Retourne le numero de l'integration suivante (celle a faire dans shop )
# Si Setup = 1 , met le compteur a 1
#;<
proc wokIntegre:Number:Get { fshop {Setup 0} } {
    set diradm [wokIntegre:Number:GetName $fshop]
    if [file exists $diradm] {
	return [wokUtils:FILES:FileToList $diradm]
    } else {
	if { $Setup } {
	    msgprint -c WOKVC -i "Creating file $diradm"
	    catch { mkdir -path [file dirname $diradm] }
	    wokUtils:FILES:ListToFile 1 $diradm
	    chmod 0777 $diradm
	    return 1
	} else {
	    return {}
	}
    }
}
#;>
# Ecrit number comme numero de l'integration suivante
#;<
proc wokIntegre:Number:Put { fshop number } {
    set diradm [wokIntegre:Number:GetName $fshop]
    if [file exists $diradm] {
	wokUtils:FILES:ListToFile $number $diradm
	return $number
    } else {
	return {}
    }
}
#;>
# Incremente le numero de l'integration 
#;<
proc wokIntegre:Number:Incr { fshop } {
    set diradm [wokIntegre:Number:GetName $fshop]
    if [file exists $diradm] {
	set n [wokUtils:FILES:FileToList $diradm]
	return [incr n]
    } else {
	return {}
    }
}

#############################################################################
#
#                              W G E T
#                              _______
#
#############################################################################
#
# Usage
#
proc wokGetUsage { } {
    puts stderr \
	    {
	Usage:
	
	wget  [-f] [-ud <udname>] <filename> [-v <version>]
	wget  [-f] [-ud <udname>] <filename_1> ... <filename_N>
	wget  [-f] -r <reportname>  
	
	-ud     : Keyword used to specify a unit name

	-f      : Force files to be overwritten if they already exist.

	wget -l : List "gettable" files for the current unit (default)

    }
    return
}


#
# Point d'entree de la commande
#
proc wget { args } {

    ;# Options
    ;#
    set tblreq(-h)      {}
    set tblreq(-l)      {}
    set tblreq(-f)      {}
    set tblreq(-V)      {}
    set tblreq(-v)      value_required:string
    set tblreq(-ud)     value_required:string
    set tblreq(-r)      value_required:string
    set tblreq(-ws)     value_required:string
    set tblreq(-root)   value_required:string 
    set tblreq(-from)   value_required:string 
    
    set param {}
    if { [wokUtils:EASY:GETOPT param tabarg tblreq wokGetUsage $args] == -1 } return

    set VERBOSE [info exists tabarg(-V)]

    if { $VERBOSE } {
	puts "param = $param"
	catch {parray tabarg}
    }
    

    if { [info exists tabarg(-h)] } {
	wokGetUsage
	return
    }

    if [info exists tabarg(-ws)] {
	set fshop $tabarg(-ws)
    } else {
	set fshop [wokinfo -s [wokcd]]
    }


    ;# name of target workbench
    ;# 
    if [info exists tabarg(-root)] {
	set workbench $tabarg(-root)
    } else {
	set workbench [wokinfo -n [wokinfo -w [wokcd]]]
    }


    ;#puts "fshop = $fshop workbench = $workbench"

    ;# name of source workbench from where the source file are to be copied.
    ;# only used in NOBASE case.
    ;#
    if [info exists tabarg(-from)] {
	set fromwb $tabarg(-from)
    } else {
	set fromwb [wokIntegre:RefCopy:GetWB]
    }


    if [info exists tabarg(-ud)] {
	set ud $tabarg(-ud)
    } else {
	set ud [Sinfo -u]
    }

    set forced [info exists tabarg(-f)]

    if [info exists tabarg(-v)] {
	set version $tabarg(-v)
    } else {
	catch {unset version}
    }

    if [info exists tabarg(-l)] {
	set listbase 1
    } else {
	catch {unset listbase}
    }

    if [info exists tabarg(-r)] {
	set ID $tabarg(-r)
    } else {
	catch {unset ID }
    }

    if { [set BTYPE [wokIntegre:BASE:InitFunc $fshop]] == {} } {
	return -1
    }

    if { "$BTYPE" == "ClearCase" } {
	wokGetClearCase
	return
    }

    ;#
    ;# Autre : SCCS, RCS, NOBASE, SIMPLE geree par WOK
    ;#

    set broot [wokIntegre:BASE:GetRootName $fshop]
    if { $broot == {} } {
	msgprint -c WOKVC -e "The repository does not exists."
	wokIntegre:BASE:GetType $fshop 1
	return -1
    }

    if { "$BTYPE" == "NOBASE" } {
	wokGetnobase
    } else {
	wokGetbase
    }
    return
}
;#
;# 
;#
proc wokGetbase { } {
    uplevel {
	set actv [wokIntegre:Version:Get $fshop]
	if { $actv == {} } {
	    msgprint -c WOKVC -e "The workshop $fshop has no entry in the repository."
	    return -1
	}
	
	if [info exists version] {
	    set vrs $version
	} else {
	    set vrs last:${actv} 
	}

	if { $VERBOSE } { msgprint -c WOKVC -i "Checking out version : $vrs" }
	
	set listfileinbase [wokIntegre:BASE:List $fshop $ud $actv]

	if [info exists listbase] {
	    set laff [wokUtils:LIST:GM $listfileinbase $param]
	    foreach f $laff {
		puts $f
	    }
	    return
	}
	
	if [info exists ID] {
	    wokIntegre:Journal:Assemble  /tmp/jnltmp $fshop
	    if [regexp {^[0-9]+$} $ID] {
		wokIntegre:Journal:PickReport /tmp/jnltmp table notes $ID 
	    } else {
		puts "Not yet implemented"
		;#set res [wokIntegre:Journal:PickMultReport /tmp/jnltmp $ID $ID]
		;#puts $res
	    }
	    catch { unlink /tmp/jnltmp }
	} else {
	    if { $param == {} } {
		foreach f $listfileinbase {
		    puts $f
		}
		return
	    }
	    if { [set RES [wokUtils:LIST:GM $listfileinbase $param]]  == {} } {
		msgprint -c WOKVC -e "No match for $param in unit $ud."
	    }

	    if { [info exists version] && [llength $RES] > 1 } {
		msgprint -c WOKVC -e "Option -v should be used with only one file to check out. Not done"
		return
	    }

	    set locud [woklocate -u $ud ${fshop}:${workbench}]
	    if { $locud != {} } {
		set table(${ud}.[uinfo -c $locud]) [wokUtils:LIST:pair $RES $vrs 2]
	    } else {
		msgprint -c WOKVC -e "Unit $ud not found. Cannot create a new one (Unknown type)."
		return -1
	    }
	}
	
	if { [wokIntegre:RefCopy:Writable $fshop table $workbench {} {}] == -1 } {
	    return -1
	}
	wokIntegre:RefCopy:GetPathes $fshop table $workbench {} {}
	
	if { [llength [w_info -A ${fshop}:$workbench]] == 1 } {
	    msgprint -c WOKVC -w "You are working in the reference area."
	    return -1
	}
	
	if { [wokUtils:FILES:dirtmp [set dirtmp /tmp/wintegrecreateunits[id process]]] == -1 } {
	    msgprint -c WOKVC -e "Unable to create working directory"
	    return -1
	}

	set chkout $dirtmp/checkout.cmd
	set chkid  [open $chkout w]
	wokIntegre:RefCopy:FillUser $fshop table $forced $chkid
	wokIntegre:BASE:EOF $chkid
	close $chkid

	if { $VERBOSE } {
	    msgprint -c WOKVC -i "Send the following script:"
	    puts [exec cat $dirtmp/checkout.cmd]
	}

	set statx [wokIntegre:BASE:Execute $VERBOSE $chkout] 
	if { $statx != 1 } {
	    msgprint -c WOKVC -e "Error during checkout(Get)."
	    msgprint -c WOKVC -e "The following script was sent to perform check-out"
	    puts [exec cat $dirtmp/checkout.cmd]
	}
	
	unlink $chkout
	rmdir -nocomplain $dirtmp
	return $statx
    }
}
;#
;#
;#
proc wokGetnobase { } {
    uplevel {
	if [wokUtils:WB:IsRoot $workbench] {
	    msgprint -c WOKVC -e "You are working in the reference area. Use chmod and edit the file..."
	    return -1
	}

	if [info exists version] {
	    msgprint -c WOKVC -w "Value $version for option -v ignored in this context (NOBASE)."
	}
	
	set listfileinbase [wokIntegre:BASE:List $fshop $ud {}]

	if [info exists listbase] {
	    set laff [wokUtils:LIST:GM $listfileinbase $param]
	    foreach f $laff {
		puts $f
	    }
	    return
	}
	
	if [info exists ID] {
	    msgprint -c WOKVC -w "Value $ID for option -r ignored in this context (NOBASE)."
	    return
	} else {
	    if { $param == {} } {
		foreach f $listfileinbase {
		    puts $f
		}
		return
	    }
	    if { [set RES [wokUtils:LIST:GM $listfileinbase $param]]  == {} } {
		msgprint -c WOKVC -e "No match for $param in unit $ud."
	    }
	    set locud [woklocate -u $ud]
	    if { $locud != {} } {
		set table(${ud}.[uinfo -c $locud]) $RES
	    } else {
		msgprint -c WOKVC -e "Unit $ud not found. Unknown type for creation."
		return -1
	    }
	}
	
	foreach UD [array names table] {
	    regexp {(.*)\.(.*)} $UD ignore name type
	    if { [lsearch [w_info -l $workbench] $name ] == -1 } {
		;# if workbench is writable ..
		;#msgprint -c WOKVC -i "Creating unit ${workbench}:${name}"
		ucreate -$type ${workbench}:${name}
	    }
	    set dirsrc [wokinfo -p source:. ${workbench}:${name}]
	    if ![file writable $dirsrc] {
		msgprint -c WOKVC -e "You cannot write in directory $dirsrc"
		return -1
	    }
	    set fromsrc [wokinfo -p source:. ${fromwb}:${name}]
	    set table($UD) [list $fromsrc $dirsrc $table($UD)]
	}
	foreach UD [array names table] {
	    set from [lindex $table($UD) 0]
	    set dest [lindex $table($UD) 1]
	    foreach file [lindex $table($UD) 2] {
		if [file exists $dest/$file] {
		    if { $forced } {
			if { [file writable $dest/$file] } {
			    frename $dest/$file $dest/${file}-sav
			    msgprint -c WOKVC -i "File $dest/$file renamed ${file}-sav"
			    wokUtils:FILES:copy $from/$file $dest/$file
			    chmod 0644 $dest/$file
			} else {
			    msgprint -c WOKVC -e "File $dest/$file is not writable. Cannot be overwritten."
			    return -1
			}
		    } else {
			msgprint -c WOKVC -e "File $dest/$file already exists. Not overwritten."
		    }
		} else {
		    wokUtils:FILES:copy $from/$file $dest/$file
		    chmod 0644 $dest/$file
		}
	    }
	}
    }
    return
}
