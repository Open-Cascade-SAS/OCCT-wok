#############################################################################
#
#                              P I N T E G R E
#                              _______________
#
#############################################################################
#
# Usage
#
proc pintegreUsage { } {
    puts stderr \
	    {
	usage : pintegre [ <reportID> ]
	
	<reportID>  is a number. The range of the report in the queue.
	You get this number by using the command : pstore -ls 
	
	-all            : Process all reports in the queue. 
	-noexec         : Don't execute. Only display script file.
	-dump   <file>  : Trace of commands in file. If file exists append commands. 
    }
    return
}
#
# Point d'entree de la commande
#
proc pintegre { args } {
    
    set tblreq(-h)      {}
    set tblreq(-all)    {}
    set tblreq(-v)      {}
    set tblreq(-noexec) {}
    set tblreq(-dump)   value_required:string
    
    set param {}
    if { [wokUtils:EASY:GETOPT param tabarg tblreq pintegreUsage $args] == -1 } return
    set VERBOSE [info exists tabarg(-v)]
    
    if { [info exists tabarg(-h)] } {
	pintegreUsage 
	return
    }
    
    set fshop nil
    
    if { [info exists tabarg(-all)] } {
	set LISTREPORT [pstore:Report:Get all $fshop ]
    } else {
	if { [llength $param] == 1 } {
	    set ID [lindex $param 0]
	    set LISTREPORT [pstore:Report:Get $ID $fshop ]
	} else {
	    pintegreUsage 
	    return -1 
	}
    }
    
    set execute 1
    if { [info exists tabarg(-noexec)] } { set execute 0 }

    if { [info exists tabarg(-dump)] } { 
	set FileDump $tabarg(-dump)
    }

    set savpwd [pwd]

    foreach REPORT $LISTREPORT {
	
	if { [pstore:Report:Process $REPORT] != 1 } { 
	    return 
	}
	if { [set l [pstoreReportWasThere]] != {} } {
	    foreach f $l {
		puts stderr "File $f has been removed since storage of that report."
	    }
	    pstore:Report:UnProcess $REPORT
	    return
	}
	pstoreReportHeader  ReportHeader       
	pstoreReportBody    ReportBody
	set Config          [pstoreReportConfig]
	set pnam $ReportHeader(Parcel)
	set label [wokBAG:cpnt:GetLabel $pnam]
	set umaked [split $ReportHeader(Umaked) ,]
	set tmpconf [lindex $Config 0]

	set depends [wokBAG:cfg:Complete $tmpconf $umaked]

	pstore:Report:UnProcess $REPORT

	if { $VERBOSE } {
	    puts stderr "Processing report in $REPORT" 
	    puts stderr "Will use label $label to stick elements of this update."
	    puts stderr "Requires $umaked"
	    puts stderr "That is: $depends"
	}
	
	set init $ReportHeader(Init) ;# Si Init != "NO" => level a creer et a updater si existe pas.

	if { "$init" != "NO" } {
	    cd  $ReportHeader(Revision)
	    set x_1  [wokBAG:cpnt:Init $pnam $ReportHeader(Revision) $ReportHeader(FrigoName)/cvt_data]
	    set x_2  [wokBAG:journal:Init $pnam $ReportHeader(Journal)]
	    set x_3  [wokBAG:label:Init  $label]
	    set x_4  [wokBAG:hlink:Init  $pnam]
	    set x_5  [wokBAG:label:Stick $label $ReportHeader(Master)]
	    set x_6  [wokBAG:label:Stick $label [wokBAG:journal:name $pnam]]
	    set res  [concat $x_1 $x_2 $x_3 $x_4 $x_5 $x_6]
	} else {
	    set x_mod {}
	    foreach e [array names ReportBody ##,*] {
		set dir [file join $ReportHeader(Master) [string range $e 4 end]]  
		if { $ReportBody($e) != {} } {
		    set x_mod [concat $x_mod [wokBAG:cpnt:UpdateDirectory $dir $ReportBody($e)]]
		}
	    }
	    set x_add {}
	    foreach e [lsort -command wokUtils:FILES:Depth [array names ReportBody ++,*]] {
		set dir [file join $ReportHeader(Master) [string range $e 4 end]]
		if { $ReportBody($e) != {} } {
		    set x_add [concat $x_add [wokBAG:cpnt:CreateDirectory $dir $ReportBody($e)]]
		}
	    }
	    set x_del {}
	    foreach e [lsort -decreasing -command wokUtils:FILES:Depth [array names ReportBody --,*]] {
		set dir [file join $ReportHeader(Master) [string range $e 4 end]]
		if { $ReportBody($e) != {} } {
		    set x_del [concat $x_del [wokBAG:cpnt:DeleteDirectory $dir $ReportBody($e)]]
		}
	    }
	    set x_labinit [wokBAG:label:Init  $label]
	    set j_upd     [wokBAG:journal:Update $pnam $ReportHeader(Journal)]
	    set x_lab     [wokBAG:label:Stick $label $ReportHeader(Master)]
	    set j_lab     [wokBAG:label:Stick $label [wokBAG:journal:name $pnam]]

	    set res [concat $x_mod $x_add $x_del  $x_labinit $x_lab $j_upd $j_lab]

	}
	
	if { $depends != {} } {
	    set actdep [wokBAG:cfg:Complete $tmpconf $depends]
	    if { $actdep != {} } {
		if { $VERBOSE } { puts stderr "Will link $label to $actdep" }
		set res [concat $res [wokBAG:hlink:Attach $label $actdep]]
	    }
	}
	
	if { [info exists FileDump] } {
	    wokUtils:FILES:AppendListToFile $res $FileDump
	}
	
	wokUtils:FILES:ListToFile [wokUtils:EASY:stobs2 $res] $ReportHeader(COMMAND)_1
	if { $execute } {
	    if { [set fileid [wokBAG:errlog:Add $pnam]] != {} } {
		wokUtils:EASY:Execute $ReportHeader(COMMAND)_1 sh $fileid
		close $fileid
	    } else {
		puts "Unable to open log file for writing"
		return
	    }
	} else {
	    wokUtils:EASY:Execute $ReportHeader(COMMAND)_1 noexec stdout
	}
	
	;# Mise a jour des levels
	
	puts "Mise a jour levels Config = $Config"
	foreach cfg $Config {
	    set LABELTMP $ReportHeader(LABEL).$cfg
	    wokUtils:FILES:ListToFile $label $LABELTMP
	    if { "$init" != "NO" } {  
		puts -nonewline "on fait INIT ($cfg) ..."
		;# Init = ANAME il faut soit creer le level soit l'updater avec la nouvelle UL.
		set flevel [wokBAG:level:file $init $cfg]
		if [file exists $flevel] {
		    puts "dans un level qui existe"
		    set contents [wokUtils:FILES:FileToList $flevel]
		    wokUtils:FILES:ListToFile [concat $contents $label] $LABELTMP
		    set xlv [wokBAG:level:update $flevel $LABELTMP]
		} else {
		    puts "dans un level qui n'existe pas "
		    set xlv [wokBAG:level:Init  $init $cfg $LABELTMP]		
		}
	    } else {
		;# Init = NO Il faut recuperer le level auquel appartient pnam
		set lvl [wokBAG:level:find $label $cfg]
		if { $lvl != {} } {
		    wokUtils:FILES:ListToFile [lindex $lvl 1] $LABELTMP
		    set xlv [wokBAG:level:update [lindex $lvl 0] $LABELTMP]
		} else {
		    puts stderr "Error updating levels for $label in $cfg . Level not found"
		    return
		}
	    }
	    wokUtils:FILES:ListToFile [wokUtils:EASY:stobs2 $xlv] $ReportHeader(COMMAND)_2
	    if { $execute } {
		if { [set fileid [wokBAG:errlog:Add $pnam]] != {} } {
		    wokUtils:EASY:Execute $ReportHeader(COMMAND)_2 sh $fileid
		    close $fileid
		} else {
		    puts "Unable to open log file for writing"
		    return
		}
	    } else {
		wokUtils:EASY:Execute $ReportHeader(COMMAND)_2 noexec stdout
	    }
	}

	
	;# Destruction du report
	if { $execute } { pstore:Report:Del $REPORT 1 } 
	
    }
    cd $savpwd
    return
}

#############################################################################
#
#                              P G E T
#                              _______
#
#############################################################################
#
# Usage
#
proc pgetUsage { } {
    puts stderr \
	    {
	Usage  : pget [-h]  [-d dir] -conf <name> [-parcel <p1,p2,..>] [-P patch]
	-h          : this help
	-d dir      : Uses dir as directory for downloading files.
	-conf name  : configuration name. This parameter is required.
	-parcel <p1,p2..> : list of one or more parcel. if this parameter is not given
                            install all parcels listed in name. 
	-v          : verbose mode
	-noexec     : Display update operations but don't perform them.
	[-P num ]   : <num> is a patch number. By default the parcel is downloaded up to its last patch. 
	              This option can be used to specify the higher patch level you want to download.
	              This option cannot be used with more than one parcel specified in the -parcel option.

       Acces modes  : By default, files of parcels are created (copied) in the bag of your factory. If you
                      specify -view <Myview> then a ClearCase view <Myview> will be configured so that
                      you can access (read) the parcels without copying them. Note that <Myview> must 
                      already exists. 
    }
}
#
# Point d'entree de la commande
#
proc pget { args } {

    set tblreq(-h)      {}
    set tblreq(-conf)   value_required:string
    set tblreq(-parcel) value_required:list
    set tblreq(-d)      value_required:string 
    set tblreq(-v)      {}
    set tblreq(-mode)   value_required:string
    set tblreq(-P)      value_required:number
    set tblreq(-cat)    {}
    set tblreq(-noexec) {}

    set param {}
    if { [wokUtils:EASY:GETOPT param tabarg tblreq pgetUsage $args] == -1 } return

    if { $param != {} } {
	pgetUsage 
	return
    }


    if { [info exists tabarg(-h)] } {
	pgetUsage 
	return
    }

    set VERBOSE [info exists tabarg(-v)]
    
    if { [info exists tabarg(-conf)] } {
	set conf $tabarg(-conf)
    } else {
	pgetUsage 
	return
    }

    if { [info exists tabarg(-cat)] } {
	foreach pnam [lsort [wokBAG:cfg:read $conf]] {
	    puts $pnam
	}
	return
    }

    
    if [info exists tabarg(-mode)] {
	set mode $tabarg(-mode)
    } else {
	set mode copy
    }

    set view [wokBAG:view:GetViewExport]
    ;# tester ici que la vue view existe
    
    set fact [wokinfo -f [wokcd]]

    if { [info exists tabarg(-d)] } {
	set down $tabarg(-d)
	if ![file exists $down] {
	    if { [wokUtils:DIR:create $down] == -1 } {
		return
	    }
	}
    } else {
	set down {}
    }
    
    if { [info exists tabarg(-parcel)] } {
	set lnuk $tabarg(-parcel)
    } else {
	set luli [pget:ulist read $conf $fact $down {} $VERBOSE]
	if { $luli != {} } {
	    set lnuk {}
	    foreach p $luli {
		if { $p != {} } {
		    if { "[wokBAG:cpnt:parse extension $p]" == "$conf" } {
			lappend lnuk [wokBAG:cpnt:parse root $p]
		    } else {
			puts stderr "Mismatch version for $p . Ignored."
		    }
		}
	    }
	} else {
	    puts stderr "Please Specify at least one parcel of this config."
	    puts stderr "All parcels defined in this config are:"
	    pget -cat -conf $conf
	    return
	}
    }

    if { [info exists tabarg(-P)] } {
	if { [llength $lnuk] == 1 } {
	    set preq $tabarg(-P)
	} else {
	    puts stderr "You cannot use -P option with more than one parcel."  
	    return
	}
    }

    if { $VERBOSE } { puts "lnuk = $lnuk" }
    # lnuk est la liste des ULs demandees dans la ligne de commande
    # wokBAG:cfg:read retourne la liste des Uls de <conf> au dernier niveau 
    # pget:sink fait la correspondance CCL <-> CCL-B4-5_13
    # Il faudra mettre ici le niveau si il est demande et separer BASE, MODEL, APPLI 

    set linst [pget:sink $lnuk [wokBAG:cfg:read $conf {}]]
     if  { $linst == {} } {
	 puts "No match for $lnuk in config $conf."
	 return
    }

    # si preq est settee => il n'y a qu'une parcel , et on a demande une version precise.
    # lcomp contient pour le level demandee la plus haute version connue.
    # verifier que preq est inferieur ou egal a cette version. 

    if [info exists preq] {
	set vx [wokBAG:cpnt:parse version $linst]
	if { $preq > $vx } {
	    puts stderr "Patch level $preq does not exist. Higher level is $vx."
	    return
	}
	set lres [wokBAG:cpnt:parse basename $linst]_${preq}
    } else {
	set lres $linst
    }

    if { $VERBOSE } { puts "linst = $linst" }
    ;# 1. Calcul du fichier ConfigSpec pour configurer la vue d'acces au Bag
    ;#
    wokBAG:cfg:ListToConfig $lres [set configspec [wokUtils:FILES:tmpname viewof[id user].setcs]]
    
    if { $VERBOSE } {
	foreach x [wokUtils:FILES:FileToList $configspec] { puts $x }
    }

    if { $VERBOSE } {
	puts "Configuring view $view.."
    }

    ;# 2.   execute ( config + demarrage )
    ;#
    set cfw [concat [wokBAG:view:setcs $configspec $view] [wokBAG:view:startview $view]]

    ;# 3. La demarrer
    ;#
    wokUtils:FILES:ListToFile $cfw [set cmdget [wokUtils:FILES:tmpname cmdget[id user]]]
    wokUtils:EASY:Execute $cmdget sh stdout

    ;# 4. Mode increment, ou copy, ou view
    ;#
    switch -- $mode {

	increment {
	    set lget {}
	    foreach pnam_x $lres { 
		set jnl [wokBAG:journal:read ${pnam_x}]
		set dfrom [wokBAG:cpnt:GetExportName [wokBAG:cpnt:parse basename ${pnam_x}]]
		set dto [pget:down $conf $fact $down $pnam_x]
		if { $VERBOSE } { puts stderr "Downloading ${pnam_x} in $dto" }
		set lget [concat $lget [pget:getfiles ${pnam_x} $jnl $dfrom $dto]]
	    }
	    
	    ;# 5. Executer la copie
	    ;#
	    if { [info exists tabarg(-noexec)] } {
		foreach x $lget {
		    puts "$x"
		}
	    } else {
		wokUtils:EASY:TclCommand $lget $VERBOSE 
	    }

	    pget:ulist write $conf $fact $down $lres $VERBOSE 
	}

	copy {
	    foreach pnam_x $lres {
		set dfrom [wokBAG:cpnt:GetExportName [wokBAG:cpnt:parse basename ${pnam_x}]]
		if { [file exist $dfrom] } {
		    set dto [pget:down $conf $fact $down ${pnam_x}]
		    if { $VERBOSE } { puts stderr "Downloading ${pnam_x} in $dto" }
		    set FunCopy wokUtils:FILES:copy
		    if { [info exists tabarg(-noexec)] } { set FunCopy pget:CopyNothing }
		    wokUtils:FILES:recopy $dfrom $dto $VERBOSE $FunCopy
		} else {
		    puts stderr "Error: Directory $dfrom is unreachable."
		}
	    }

	    pget:ulist write $conf $fact $down $lres $VERBOSE 
	}

	view {
	}

    }

    return 
}
#
# retourne le nom du dir ou il faut descendre pnam_x
#
proc pget:down { conf fact down pnam_x } {
    if { $down == {} } { 
	set root [wokinfo -p HomeDir ${fact}:[finfo -W $fact]]
	return $root/[wokBAG:cpnt:parse root ${pnam_x}]-${conf}	
    } else { 
	return $down 
    }
}
#
# Lit/Ecrit la liste des Uls du bag de <fact> se trouvant listes dans <conf>. 
# De fait le contenu de : Factory/adm/K4E_Config.
# ya qqche dans WOK pour lire mais pas pour ecrire
# quand on fait read: ulist  = {}              retourne dans la liste le contenu du parametre K4E_Config
# quand on fait write ulist  = suite de pnam_x retourne une liste ayant le format suivant
# {KERNEL KERNEL-K4E down KERNEL-B4-2 8} 
#
proc pget:ulist { option conf fact down ulist VERBOSE } {
    switch -- $option {

	read {
	    set lvc [wokparam -l ${conf} $fact]
	    if { $lvc != {} } {
		if { [lsearch -regexp $lvc %${conf}_Config=*] != -1 } {
		    catch { set value [wokparam -e %${conf}_Config $fact] }
		    if [info exists value] {
			return [split [join $value]]
		    } else {
			return {}
		    }
		} else {
		    return {}
		}
	    } else {
		return {}
	    }  
	}

	write {
	    set bagName ${fact}:[finfo -W $fact]
	    set bagAdm [wokinfo -p AdmDir $bagName]
	    set ParcelListFile [wokinfo -p ParcelListFile $bagName]
	    set lp [wokUtils:FILES:FileToList $ParcelListFile]
	    set Config  "@set %${conf}_Config   = \""
	    set Runtime "@set %${conf}_Runtime  = \""
	    foreach pnam_x $ulist {
		set pclName [wokBAG:cpnt:parse root ${pnam_x}]
		set pclHome [pget:down $conf $fact $down ${pnam_x}]
		set pclAdm  $pclHome/adm
		catch { mkdir -path $pclAdm }
		set edl [pget:declare ${pclName}-${conf} $pclName $pclHome $pclAdm]
		if [wokUtils:FILES:ListToFile [list $edl] $bagAdm/${pclName}-${conf}.edl] {
		    if { $VERBOSE } { puts stderr "File $bagAdm/${pclName}-${conf}.edl has been created." }
		} else {
		    puts stderr "Unable to create file $bagAdm/${pclName}-${conf}.edl"
		}
		pget:WVersion $bagName $conf ${pclName} ${pnam_x}
		;#if [wokUtils:FILES:ListToFile ${pnam_x} $pclAdm/${pclName}.version] {
		    ;#if { $VERBOSE } { puts stderr "File $pclAdm/${pclName}.version has been created" }
		;#} else {
		   ;# puts stderr "Unable to create file $pclAdm/${pclName}.version"
		;#}
		append Config " ${pclName}-${conf}"
		if { [lsearch $lp ${pclName}-${conf}] == -1 } { lappend lp ${pclName}-${conf} }
	    }
	    append Config "\";"
	    append Runtime "\";"
	    if [wokUtils:FILES:ListToFile [list $Config $Runtime] [wokinfo -p AdmDir $fact]/${conf}.edl] {
		if { $VERBOSE } { puts stderr "File [wokinfo -p AdmDir $fact]/${conf}.edl has been updated" }
	    } else {
		puts stderr "Unable to update file [wokinfo -p AdmDir $fact]/${conf}.edl"
	    }
	    if [wokUtils:FILES:ListToFile $lp $ParcelListFile] {
		if { $VERBOSE } { puts stderr "File $ParcelListFile has been updated."}
	    } else {
		puts stderr "Unable to update file $ParcelListFile."
	    }
	}
    }
    
}
#
# retourne les occurences de lnuk = { CCL GRAPHIC KERNEL VIEWERS .. } 
#              trouvees dans loff = { KERNEL-B4-2_x CCL-B4-2_y GRAPHIC-B4-2_z ...}
#
proc pget:sink { lnuk loff } {
    foreach p $loff {
	set map([wokBAG:cpnt:parse root $p]) $p
    }
    set l {}
    foreach p $lnuk {
	if [info exists map($p)] {
	    lappend l $map($p)
	} else {
	    puts stderr "Warning : $p not found in required config. Ignored"
	}
    }
    return $l
}
;#
;# retourne la liste des commandes a passer pour updater le directory dest avec le patch pnam_x
;# La vue doit avoir ete configuree (element * pnam_x -nocheckout)
;#
proc pget:getfiles { pnam_x jnl dmas dest } {
    if ![ catch { set fileid [ open $jnl r ] } ] {
	pprepare:header:read $fileid RepHeader
	wokUtils:EASY:ReadCompare ReportBody $fileid
	if ![wokUtils:EASY:MapEmpty ReportBody] {
	    set x_mod {}
	    set vers ${pnam_x}
	    foreach e [array names ReportBody ##,*] {
		set dir [string range $e 4 end]  
		if { $ReportBody($e) != {} } {
		    set x_mod [concat $x_mod [pget:UpdateDirectory $vers $dest $dmas $dir $ReportBody($e)]]
		}
	    }
	    
	    set x_add {}
	    foreach e [lsort -command wokUtils:FILES:Depth [array names ReportBody ++,*]] {
		set dir [string range $e 4 end]
		if { $ReportBody($e) != {} } {
		    set x_add [concat $x_add [pget:CreateDirectory $vers $dest $dmas $dir $ReportBody($e)]]
		}
	    }
	    
	    set x_del {}
	    foreach e [lsort -decreasing -command wokUtils:FILES:Depth [array names ReportBody --,*]] {
		set dir [string range $e 4 end]
		if { $ReportBody($e) != {} } {
		    set x_del [concat $x_del [pget:DeleteDirectory $vers $dest $dmas $dir $ReportBody($e)]]
		}
	    }

	}
	close $fileid
	return [concat $x_mod $x_add $x_del]
    } else {
	puts stderr "pget:getfiles. Unable to open $jnl for reading."
	return {}
    }
}
;#
;# 
;#
proc pget:UpdateDirectory { vers dest dmas dir lfile } {
    set l {}
    foreach e $lfile {
	if [regexp {    #[ ]*([^ ]*)[ ]*([^ ]*)[ ]*([^ ]*)} $e all basn elem from] {
	    lappend l "wokUtils:FILES:copy [file join $dmas $dir $basn]@@/main/$vers [file join $dest $dir $basn]"
	} elseif [regexp {    \-[ ]*([^ ]*)[ ]*([^ ]*)} $e all basn elem] {
	    lappend l "wokUtils:FILES:delete [file join $dest $dir $basn]"
	} elseif [regexp {    \+[ ]*([^ ]*)[ ]*([^ ]*)} $e all basn from] {
	    lappend l "wokUtils:FILES:copy [file join $dmas $dir $basn]@@/main/$vers [file join $dest $dir $basn]"
	} else {
	    puts stderr "pget:UpdateDirectory: Line $e does not match anything !!"
	    return {}
	}
    }
    return $l
}
;#
;# 
;#
proc pget:CreateDirectory { vers dest dmas dir lfile } {
    lappend l "wokUtils:DIR:create [file join $dest $dir]"
    foreach e $lfile {
	if [regexp {    \+[ ]*([^ ]*)[ ]*([^ ]*)} $e all basn from] {
	    if [file exists [file join $dmas $dir $basn]@@/main/$vers] {
		lappend l "wokUtils:FILES:copy [file join $dmas $dir $basn]@@/main/$vers [file join $dest $dir $basn]"
	    } else {
		puts stderr "pget:CreateDirectory: [file join $dmas $dir $basn]@@/main/$vers not found"
	    }
	} else {
	    puts stderr "pget:CreateDirectory: Line $e does not match anything !!"
	    return {} 
	}
    }
    return $l
}
;#
;# Removes all files in dir but dont removes directory itself. Merdier aggregats
;#
proc pget:DeleteDirectory { vers dest dmas dir lfile } {
    foreach e $lfile {
	if [regexp {    \-[ ]*([^ ]*)[ ]*([^ ]*)} $e all basn elem] {
	    lappend l "wokUtils:FILES:delete [file join $dest $dir $basn]"
	}
    }
    ;#lappend l "rmdir [file join $dest $dir]"
    return $l
}
;#
;# Remplace Wdeclare.. 
;# 1. ce qui est retourne doit etre ecrit dans CCL-K4E.edl dans l'adm du bag et s'appeler CCL-K4E.edl. 
;# Wdeclare -p ${pclName}-${conf} -d -DHome=$pclHome -DDelivery=$pclName $bagName
;#
;# p  = CCL-K4E
;# d  = CCL
;# h  = /adv_22/WOK/BAG/CCL-K4E
;# a  = /adv_22/WOK/BAG/CCL-K4E/adm
;#
proc pget:declare { p d h a } {
    append st {@ifnotdefined ( %__PNAM_EDL ) then} \n
    append st {@set %__PNAM_EDL = "";} \n
    append st {@set %__PNAM_Home = "__HOME";} \n
    append st {@set %__PNAM_Adm = "__ADM";} \n
    append st {@set %__PNAM_Stations = "sun ao1 sil hp";} \n 
    append st {@set %__PNAM_DBMSystems = " DFLT ";} \n 
    append st {@set %__PNAM_Delivery = "__NAME";} \n  
    append st {@ifdefined(%ShopName) then} \n 
    append st {@uses "USECONFIG.edl";} \n 
    append st {@endif;} \n
    append st {@endif;} \n
    regsub -all {__PNAM} $st $p r1  
    regsub -all {__NAME} $r1 $d r2
    regsub -all {__HOME} $r2 $h r3
    regsub -all {__ADM}  $r3 $a xx
    return $xx
}
;#
;# Retourne le nom de l'UL 
;#
proc pget:RVersion { bagName conf PclName } {
    if [wokinfo -x ${bagName}:${PclName}-${conf}] {
	set pclAdm  [wokinfo -p admdir ${bagName}:${PclName}-${conf}]/${PclName}.version
	return [wokUtils:FILES:FileToList $pclAdm]
    } else {
	return {}
    }
}
;#
;# 
;#
proc pget:WVersion { bagName conf PclName version } {
    set pclAdm  [wokinfo -p admdir ${bagName}:${PclName}-${conf}]/${PclName}.version
    return [wokUtils:FILES:ListToFile $version $pclAdm]
}
;#
;#
;#
proc pget:specialwok { } {
}
;#
;# copy avec -noexec mode.
;#
proc pget:CopyNothing { f1 f2 } {
    puts stderr "copy $f1 $f2"
    return
}
