;#
;#               (((((((((((( M A G I C ))))))))))))
;#
;# Poor parsing of a magic file. Returns the list of all extensions found after -name directive.
;# mgfile returned by wokBAG:magic:Name
;#
proc wokBAG:magic:Parse { mgfile } {
    if [ catch { set fileid [open $mgfile r] } ] {
	return {}
    }
    set lx {}
    foreach x [split [read $fileid] ] {
	if { ([string compare $x "-name"] == 0 ) || ( [string compare $x "(-name"] == 0 ) } {
	    set name 1 
	} else {
	    if [info exists name] {
		regsub -all {[");]} $x "" res
		set lx [concat $lx $res]
		unset name
	    }
	}
    }
    close $fileid
    return $lx
}
;#
;# returns the list of Known EXtension
;#
proc wokBAG:magic:kex { } {
    set l {}
    foreach mgfile [wokBAG:magic:Name] {
	if [file exists $mgfile] {
	    set l [concat $l [wokBAG:magic:Parse $mgfile]]
	} else {
	    puts stderr "Magic: File $mgfile not found"
	}
    }
    return $l
}
;#
;# Given a list of extension, returns the sublist of unknown extensions
;# If this sublist is {} then all extensions are known.
;# Plus merdique, tu meurs a virer des que possible.
;#
proc wokBAG:magic:CheckExt { lxt } {
    set kex [wokBAG:magic:kex]
    set l {}

    foreach e $lxt {
	set fnd 0
	foreach x $kex {
	    if { [string match $x $e] } {
		set fnd 1
		break
	    }
	}
	if { $fnd == 0 } {
	    set l [concat $l $e]
	}
    }

    return $l
}
;#
;#             (((((((((((( A D M I N ))))))))))))
;#
proc wokBAG:admin:Create {} {
    global tcl_platform
    set NAM [wokBAG:admin:Name]
    set TAG [file join [wokBAG:bag:GetRootTagName] $NAM]
    set VBS [file join [wokBAG:bag:GetAdmName] ${NAM}.vbs]
    set VWR [wokBAG:view:GetRootName]
    if { "$tcl_platform(platform)" == "unix" } {
	if ![file exists $TAG] {
	    if [catch {mkdir -path $TAG} tag_stat] {
		puts stderr ${tag_stat}
		return {}
	    }
	}
	if ![file exists [wokBAG:bag:GetAdmName]] {
	    if [catch {mkdir -path [wokBAG:bag:GetAdmName]} vbs_stat ] {
		puts stderr ${vbs_stat}
		return {}
	    }
	}
    }
    lappend l "cleartool mkvob -nc -tag $TAG $VBS"
    lappend l "cleartool mount $TAG"
    lappend l "cleartool co -nc $VWR/[wokBAG:view:GetViewImport]${TAG}"
    lappend l "cleartool mkelem -eltype directory  -nc $VWR/[wokBAG:view:GetViewImport]${TAG}/JOURNAL"
    lappend l "cleartool mkelem -eltype directory  -nc $VWR/[wokBAG:view:GetViewImport]${TAG}/CONFIGS"
    lappend l "cleartool ci -nc $VWR/[wokBAG:view:GetViewImport]${TAG}/JOURNAL"
    lappend l "cleartool ci -nc $VWR/[wokBAG:view:GetViewImport]${TAG}/CONFIGS"
    lappend l "cleartool ci -nc $VWR/[wokBAG:view:GetViewImport]${TAG}"
    return $l
}
;#
;#               (((((((((((( H L I N K ))))))))))))
;#
;# returns the sequence used to initialize the link for pnam
;#
proc wokBAG:hlink:Init { pnam } {
    set NAM [wokBAG:admin:Name]
    set TAG [file join [wokBAG:bag:GetRootTagName] $NAM]
    lappend l "cleartool mkhltype -nc -shared [wokBAG:hlink:Umaked $pnam]@$TAG"
}
;# returns the string that identify the link used to reflect build dependencies of pnam
;# This module uses journal definition.
;#
proc wokBAG:hlink:Umaked { pnam } {
    return ${pnam}_umakedwith
}
;#
;# Link 
;# from, lto : Versionned composant name
;# Example   : from = s_1 r_2
;# set from /view/IMPORT/dl_07/REFERENCE/BAG/ADMIN/JOURNAL/s.jnl@@/s_1
;# set to   /view/IMPORT/dl_07/REFERENCE/BAG/ADMIN/JOURNAL/r.jnl@@/r_2
;# set command "cleartool mkhlink -nc umaked $from $to"
;# set command "cleartool mkhlink -nc umake_s $from $to"

proc wokBAG:hlink:Attach { pfrom lpto } {
    if [regexp {([^_]*)_([0-9]*)} $pfrom all nfrom vfrom] {
	set from [wokBAG:journal:name $nfrom]@@/${pfrom}
	set hnam [wokBAG:hlink:Umaked $nfrom]
	foreach pto $lpto {
	    if [regexp {([^_]*)_([0-9]*)} $pto all npto vpto] {
		set to [wokBAG:journal:name $npto]@@/${pto}
		lappend l "cleartool mkhlink -nc $hnam $from $to"
	    } else {
		puts stderr "hlink:Attach(to) : Error in component name $pto"
		return {}
	    }
	}
	return $l
    } else {
	puts stderr "hlink:Attach(from) : Error in component name $pfrom"
	return {}
    }
}
;#
;#               (((((((((((( L A B E L S ))))))))))))
;#
;# returns the tag name of the VOB where labels are managed.
;# This VOB should be public.
;#
proc wokBAG:label:GetAdminVOB { } {
    return [file join [wokBAG:bag:GetRootTagName] [wokBAG:admin:Name]]
}
;#
;# Returns all labels that match regexp
;#
proc wokBAG:label:ls { {rgx *} } {
    set command "cleartool lstype -short -kind lbtype -invob [wokBAG:label:GetAdminVOB]"
    if ![catch { eval exec $command } status ] {
	set lret {}
	foreach e [wokUtils:LIST:GM [split $status \n] $rgx] {
	   lappend lret [lindex [split $e] 0] 
	}
	return $lret
    } else {
	puts stderr "$status"
	return -1
    }
}

;#
;# Returns all kwown labels
;# writes map(pnam) = list of kwown labels for pnam
;# opt should be short or long
;#
proc wokBAG:label:dump { map opt } {
    upvar $map TLOC
    catch { unset TLOC }
    set command "cleartool lstype -$opt -kind lbtype -invob [wokBAG:label:GetAdminVOB]"
    if ![catch { eval exec $command } status ] {
	if { "$opt" == "short" } {
	    foreach e [split $status \n] {
		if [regexp {([^_]*)_([0-9]*)} $e all n v] {
		    lappend TLOC($n) $v 
		}
	    }
	    foreach nam [array names TLOC] {
		set TLOC($nam) [lsort -integer $TLOC($nam)]
	    }
	} elseif { "$opt" == "long" } {
	    foreach e [split $status \n] {
		if [regexp {^label type "(.*)"} $e match label] {
		    set curlabel $label
		} elseif { [regexp {^ ([^ ]*) by (.*)} $e match date byandwhere] } {
		    if { "$curlabel" != "LATEST" && "$curlabel" != "CHECKEDOUT" } {
			set TLOC($date) "$curlabel $byandwhere"
		    }
		}
	    }
	}
	
    } else {
	puts stderr "$status"
	return -1
    }
}
;#
;# Init a label in Admin VOB. 
;#
proc wokBAG:label:Init { name } {
    lappend l "cleartool mklbtype -global -nc ${name}@[wokBAG:label:GetAdminVOB]"
    return $l
}
;#
;# Pose un label. name doit exister. (wokBAG:label:Add)
;#
proc wokBAG:label:Stick { name dir } {
    lappend l "cleartool mklabel -nc -rec $name $dir"
    lappend l "cleartool lock lbtype:${name}@$dir"
    return $l
}
;#
;# Delete a label. 
;#
proc wokBAG:label:Del { name } {
    lappend l "cleartool rmtype -nc lbtype:${name}@[wokBAG:label:GetAdminVOB]"
    return $l
}

;#
;#                     ((((((((((((  L E V E L S    ))))))))))))
;#
;#
;# Initialise les fichiers LEVEL.CFG (BASE.K4E, etc.. ) dans le repertoire ADMIN/CONFIG
;# i. e. cree les fichiers LEVEL.CFGi pour i dans LCFG (K4E K4F etc..)
;#
proc wokBAG:level:Init { level cfg from } {
    lappend l "cleartool co -nc [wokBAG:level:dirname]"
    lappend l "cleartool mkelem -eltype text_file -nc [wokBAG:level:file $level $cfg]"
    lappend l "cleartool ci -ide -rm -nc -from $from [wokBAG:level:file $level $cfg]"
    lappend l "cleartool ci -nc [wokBAG:level:dirname]"
    return $l
}
;#
;# Update le level <level>  avec le contenu de from
;# <flevel> : fichier associe au level
;# <from>   : nouveau contenu
;# <
proc wokBAG:level:update { flevel from } {
    lappend l "cleartool co -nc $flevel"
    lappend l "cleartool ci -nc -rm -ide -from $from $flevel"
    return $l
}

;#
;# Retourne  le full path du fichier decrivant level dans la config cfg
;# si ce 
;# 2. le nomune liste destinee a remplacer l'ancien contenu du fichier 
;# lbf est de la forme pnam_x
;# 
proc wokBAG:level:file { level cfg } {
    return [file join [wokBAG:level:dirname] ${level}.${cfg}]
}
;#
;# Retourne le nom du directory ou sont stockes les levels/configs
;# penser a mettre le file le join sur NT c'est plus sur.
;#
proc wokBAG:level:dirname { } {
    set vws [wokBAG:view:GetRootName]
    return $vws/[wokBAG:view:GetViewImport]/[wokBAG:bag:GetRootTagName]/[wokBAG:admin:Name]/CONFIGS
}
;#
;# Retourne 2 elements 
;# 1. le full path du fichier contenant lbf pour la config cfg (celui a modifier)
;# 2. une liste destinee a remplacer l'ancien contenu du fichier 
;# lbf est de la forme pnam_x
;# 
proc wokBAG:level:find { pnam_x cfg } {
    set pnam [wokBAG:cpnt:parse basename ${pnam_x}]
    foreach file [wokBAG:level:ls $cfg] {
	set lin [wokUtils:FILES:FileToList $file]
	if [array exists map] { unset map }
	set lxp [wokBAG:cpnt:explode $lin map]
	if [info exists map($pnam)] {
	    set map($pnam) [wokBAG:cpnt:parse version ${pnam_x}]
	    set newl [wokBAG:cpnt:implode map]
	    return [list $file $newl]
	}
    }
    return {}
}
;# Retourne le full path des fichiers de description correspondants a la config <cfg>
;# i. e. tous les fichiers de noms XXX.cfg
;#
proc wokBAG:level:ls { cfg } {
    return [glob -nocomplain [wokBAG:level:dirname]/*.${cfg}]
}
;#
;#                     ((((((((((((  J O U R N A L  ))))))))))))
;#
;# Initialise la premiere version de journal associee a pnam.
;#
proc wokBAG:journal:Init { pnam jnl } {
    set jnam [wokBAG:journal:name $pnam]
    lappend l "cleartool co -nc [file dirname $jnam]"
    lappend l "cleartool mkelem -nc $jnam"
    lappend l "cleartool ci -ide -rm -nc -from $jnl $jnam"
    lappend l "cleartool ci -nc [file dirname $jnam]"
    return $l
}
;#
;# Update le journal associe a pnam.
;#
proc wokBAG:journal:Update { pnam jnl } {
    set jnam [wokBAG:journal:name $pnam]
    lappend l "cleartool co -nc $jnam"
    lappend l "cleartool ci -ide -rm -nc -from $jnl $jnam"
    return $l
}

;#
;# Retourne le nom du journal associe a pnam. 
;#
proc wokBAG:journal:name { pnam } {
    set vws [wokBAG:view:GetRootName]
    return $vws/[wokBAG:view:GetViewImport]/[wokBAG:bag:GetRootTagName]/[wokBAG:admin:Name]/JOURNAL/${pnam}.jnl
}
;#
;# retourne le full path du journal associe a pnam_x 
;#
proc wokBAG:journal:read { pnam_x } {
    set nam [wokBAG:cpnt:parse basename ${pnam_x}]
    return  [wokBAG:journal:name $nam]@@/main/[wokBAG:cpnt:parse version ${pnam_x}]
}
;#
;#                     (((((((((((( V I E W S ))))))))))))
;#
proc wokBAG:view:Init { vnam {location {}} } {
    if { $location != {} } {
	set vws [file join [$location ${vnam}.vws]]
    } else {
	set vws [file join [wokBAG:bag:GetAdmName] ${vnam}.vws]
    }
    lappend l "cleartool mkview -tag $vnam $vws"
    return $l
}
;#
;# Configure la vue <tag> avec le fichier configspec <file>
;#
proc wokBAG:view:setcs { file { tag {} } } {
    if { $tag == {} } {
	lappend l "cleartool setcs $file"
    } else {
	lappend l "cleartool setcs -tag $tag $file"
    }
    return $l
}
;#
;#
;#
proc wokBAG:view:startview { view } {
    lappend l "cleartool startview $view"
}
;#
;#
;#
proc wokBAG:view:endview { view } {
    lappend l "cleartool endview $view"
}
;#
;#               (((((((((((( C O M P O N E N T S ))))))))))))
;#
;#
;# Retourne le vob-tag associe a pnam
;#
proc wokBAG:cpnt:GetTagName { pnam } {
    return [file join [wokBAG:bag:GetRootTagName] ${pnam}]
}
;#
;# Retourne le directory avec lequel faut comparer dans la VOB
;#
proc wokBAG:cpnt:GetImportName { pnam } {
    return  [wokBAG:view:GetRootName]/[wokBAG:view:GetViewImport][wokBAG:cpnt:GetTagName $pnam]
}
;#
;# Retourne le directory dans lequel il faut prendre les fichiers de pnam relativement la vue d'export.
;#
proc wokBAG:cpnt:GetExportName { pnam } {
    return  [wokBAG:view:GetRootName]/[wokBAG:view:GetViewExport][wokBAG:cpnt:GetTagName $pnam]
}
;#
;# Init d'un composant. 
;# pnam    : Nom du composant ( racine du directory dans la VOB)
;# from    : Nom d'une racine 
;# cvt_data: Nom du directory ou ecrire le fichier cvt_data de clearexport
;# cmt     : Un commentaire
;# LAM : faudrait voir a faire les mkdir sinon ca marchera pas.
;# le cd est fait dans pintegre c'est moche mais en attendant mieux.
;#
proc wokBAG:cpnt:Init { pnam from cvt_data {cmt Init} {location {}} } {
    global tcl_platform
    set tag [wokBAG:cpnt:GetTagName $pnam]
    if { $location != {} } {
	set vbs [file join [$location ${pnam}.vbs]]
    } else {
	set vbs [file join [wokBAG:bag:GetAdmName] ${pnam}.vbs]
    }
    if { "$tcl_platform(platform)" == "unix"    } {
	if ![file exists $tag] {
	    catch { mkdir -path $tag }
	}
	if ![file exists $vbs] {
	    catch { mkdir -path [file dirname $vbs] }
	}
    }
    ;#lappend l "cleartool mkvob -tag $tag -nc -public -password $passwd $vbs"
    lappend l "cleartool mkvob -nc -tag $tag $vbs"
    lappend l "cleartool mount $tag"
    lappend l "cleartool mkhlink AdminVOB vob:${tag} vob:[wokBAG:label:GetAdminVOB]"
    ;#lappend l "cd $from"
    lappend l "clearexport_ffile -r -o $cvt_data ."
    lappend l "cleartool startview [wokBAG:view:GetViewImport]"
    lappend l "clearimport -dir [wokBAG:cpnt:GetImportName $pnam] -comment \"$cmt\" $cvt_data"
    return $l
}
;#
;#
;#
proc wokBAG:cpnt:sortnam { pnam1 pnam2 } {
    if { [lindex [split $pnam1 _] end] >  [lindex [split $pnam2 _] end] } {
	return -1
    } else {
	return 1
    }
}
;#
;#
;#
proc wokBAG:cpnt:Del { pnam } {
    lappend l "cleartool umount [wokBAG:bag:GetRootTagName]/${pnam}"
    lappend l "cleartool rmvob -force [file join [wokBAG:bag:GetAdmName] ${pnam}.vbs]"
    return $l
}
;#
;# Returns the list of "patches" registered for pnam (Patch 0 is the version base.)
;# pnam is a component name without version ( no _)
;#
proc wokBAG:cpnt:Patches { pnam {upto 99999} } {
    set l {}
    foreach x [wokBAG:label:ls ${pnam}_*] {
	if { [lindex [split $x _] end] <= $upto } {
	    lappend l [file tail $x]
	}
    }
    return [lsort -command wokBAG:cpnt:sortnam $l]
}
;#
;# Returns the name of the label to place on pnam (_1 is the base version.)
;# pnam is a component name without version ( no _)
;#
proc wokBAG:cpnt:GetLabel { pnam } {
    set llp [wokBAG:cpnt:Patches $pnam]
    if { $llp != {} } {
	set n [lindex [split [lindex [wokBAG:cpnt:Patches $pnam] 0] _] 1]
	return ${pnam}_[incr n]
    } else {
	return ${pnam}_1
    }
}
;#
;# fait a_1 b_2 c_3 => map(a)=1,map(b)=2, map(c)=3 Comme parse ci dessous
;#
proc wokBAG:cpnt:explode  { lpnam_x map } {
    upvar $map TLOC
    foreach pnam_x ${lpnam_x} {
	set TLOC([lindex [split ${pnam_x} _] 0]) [lindex [split ${pnam_x} _] 1] 
    }
    return
}
;#
;# fait map(a)=1,map(b)=2, map(c)=3 => a_1 b_2 c_3 (inverse de ci dessus)
;#
proc wokBAG:cpnt:implode  { map } {
    upvar $map TLOC
    set l {}
    foreach n [array names TLOC] {
	lappend l ${n}_$TLOC($n)
    }
    return $l
}
;# 
;# Parse un nom d'UL a la JCR. 
;# KERNEL-B4-2_8 => root=KERNEL,basename=KERNEL-B4-2,extension=B4-2,version=8
;# KERNEL-B4-2   => root=KERNEL,basename=KERNEL-B4-2,extension=B4-2,version={}
;# KERNEL        => root=KERNEL,basename={}         ,extension={}  ,version={}
proc wokBAG:cpnt:parse { option pnam_x } {
    if { [regexp {([^-]*)-([^_]*)_([0-9]+)} ${pnam_x} a r e v] != 0 } {
	switch -- $option {
	    root      { return $r }
	    extension { return $e }
	    version   { return $v }
	    basename  { return ${r}-${e} }
	}
    } elseif { [regexp {([^-]*)-([^_]*)} ${pnam_x} a r e] != 0 } {
	switch -- $option {
	    root      { return $r }
	    extension { return $e }
	    version   { return {} }
	    basename  { return ${r}-${e} }
	}
    } else {
	return {}
    }
}
;#
;# Update directory dir ( which already exists in VOB ) with files in lfile.
;# Each element of lfile (non empty ) has the following format:
;# <sta> basn name1 [name2]
;# sta is # - or + if the file must be (resp ) modified, removed or added.
;#  if the file must be modified: 
;#    name1/basn is the full path of the VOB element to be checkouted 
;#    name2/basn is the full path of the file used for update 
;# if the file must be removed:
;#    name1/basn is the full path of the VOB element to be removed.
;#    name2 is blank
;# if the file must be added:
;#    name1/basn is the full path of the file used for the creation.
;#    
;#
proc wokBAG:cpnt:UpdateDirectory { dir lfile } {
    set l {}
    foreach e $lfile {
	if [regexp {    #[ ]*([^ ]*)[ ]*([^ ]*)[ ]*([^ ]*)} $e all basn elem from] {
	    lappend l "cleartool co -nc [file join $elem $basn]"
	    lappend l "cleartool ci -nc -rm -from [file join $from $basn] [file join $elem $basn]"
	} elseif [regexp {    \-[ ]*([^ ]*)[ ]*([^ ]*)} $e all basn elem] {
	    set mustco 1
	    lappend l "cleartool rmname -nc [file join $elem $basn]"
	} elseif [regexp {    \+[ ]*([^ ]*)[ ]*([^ ]*)} $e all basn from] {
	    set mustco 1
	    lappend l "cleartool mkelem -nc [file join $dir $basn]"
	    lappend l "cleartool ci -nc -rm -from [file join $from $basn] [file join $dir $basn]"
	} else {
	    puts stderr "wokBAG:cpnt:UpdateDirectory: Line $e does not match anything !!"
	    return {}
	}
    }

    if [info exists mustco] {
	lappend l "cleartool ci -nc $dir"
	return  [linsert $l 0 "cleartool co -nc $dir"]
    } else {
	return $l
    }
}
;#
;# Creates a directory and populates it with new files.
;#
proc wokBAG:cpnt:CreateDirectory { dir lfile } {
    lappend l "cleartool co -nc [file dirname $dir]"
    lappend l "cleartool mkelem -nc -eltype directory $dir"
    foreach e $lfile {
	if [regexp {    \+[ ]*([^ ]*)[ ]*([^ ]*)} $e all basn from] {
	    lappend l "cleartool mkelem -nc [file join $dir $basn]"
	    lappend l "cleartool ci -nc -rm  -from [file join $from $basn] [file join $dir $basn]"
	} else {
	    puts stderr "wokBAG:cpnt:CreateDirectory: Line $e does not match anything !!"
	    return {} 
	}
    }
    lappend l "cleartool ci -nc $dir"
    lappend l "cleartool ci -nc [file dirname $dir]"
}
;#
;# Removes all files in dir and removes directory itself.
;#
proc wokBAG:cpnt:DeleteDirectory { dir lfile } {
    lappend l "cleartool co -nc [file dirname $dir]"
    lappend l "cleartool rmname -nc $dir"
    lappend l "cleartool ci -nc [file dirname $dir]"
}
;#               (((((((((((( C O N F I G ))))))))))))
;#
;# <name> : The name of the config K4E, ..
;#
;# If Option is "strong" => then complete only if component already exists in Bag.
;# If Option is "weak"   => then ignore components not found in the Bag.
;#
proc wokBAG:cfg:Complete { name cmplst {option "strong"} } {
    set l {}
    wokBAG:cpnt:explode [wokBAG:cfg:read $name] LABELS
    foreach pnam $cmplst {
	if [regexp {([^_]*)_([0-9]*)} $pnam all n v] {
	    if [info exists LABELS($n)] {
		if { $v <= $LABELS($n) } {
		    set l [concat $l $pnam]
		} else {
		    puts stderr "Error: Patch level $v for $n does not exists. Higher level is $LABELS($n)"
		    return {} 
		}
	    } else {
		puts stderr "Error: $n is not a component."
		if { "$option" == "strong" } {
		    return {}
		}
	    }
	} else {
	    if [info exists LABELS($pnam)] {
		set l [concat $l ${pnam}_$LABELS($pnam)]
	    } else {
		puts stderr "Error: $pnam is not a component."
		if { "$option" == "strong" } {
		    return {}
		}
	    }
	}
    }
    return $l
}
;#
;#  Returns all pnam_x belonging to assembly/config name
;#  first is the name of configuration ( K4E, K4F ,.. )
;#  vrs is the version number of the configuratrion
;#  if vrs {} then use LATEST.
;#
proc wokBAG:cfg:read { name {vrs {}} } {
    set l {}
    foreach x [wokBAG:level:ls $name] {
	set l [concat $l [wokUtils:FILES:FileToList $x]]
    }
    return $l
}
;#
;# ecrit un config spec. lfpnam list de full path de composants dans le Bag
;#
proc wokBAG:cfg:ListToConfig { lfpnam file } {
    set l {}
    foreach pnam $lfpnam {
	lappend l "element * $pnam -nocheckout"
    }
    wokUtils:FILES:ListToFile $l $file
    return
}
;#               (((((((((((( E R R O R L O G ))))))))))))
;#
;#
proc wokBAG:errlog:ls { } {
    foreach f [readdir [wokBAG:errlog:location]] {
	puts $f
    }
}
;#
;#
;#
proc wokBAG:errlog:purge { } {
    foreach f [glob [wokBAG:errlog:location]/*] {
	unlink  $f
    }
}
;#
;#
;#
proc wokBAG:errlog:Add { pnam } {
    set p [file join [wokBAG:errlog:location] ${pnam}.[clock seconds]]
    if ![ catch { set id [ open $p w ] } ] {
	return $id
    } else {
	return {}
    }
}
proc wokBAG:errlog:Regexp { } {
    set rg1 {cleartool: Error:}
}
