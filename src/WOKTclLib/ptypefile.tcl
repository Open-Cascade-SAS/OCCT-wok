proc ptypefile_usage { } {
    puts stderr \
	    {
	Usage: ptypefile -[hwt] [-S ao1,sil,sun,hp,wnt] <Parcelname>
	
	Context:
	The command must be runned from a workbnech belonging to a workshop which contains
	the given parcel in its ParcelList

	ptypefile -h displays this text

	ptypefile -w <Parcelname>  
	displays on the standard output the non kept type files.

	ptypefile <Parcelname> 
	generates a type file in the adm directory of the parcel for ALL UNIX PLATFORMS

	ptypefile -S ao1,sil <ParcelName> 
	generates a type file in the adm directory of the parcel ONLY for the given platforms 
	
	ptypefile -S wnt <ParcelName> 
	generates a type file in the adm directory of the parcel ONLY for wnt platform
	
	ptypefile -t <Parcelname> 
	generates a type file in the adm directory where the package libraries contained in a toolkit
	are removed from the type file.

	3 files are generated:
	parcel.typ contains pairs of file type, relative path which will be taken into account 
	during packaging.
	parcel.unktyp file warns the UNKNOWN types i.e. not taken into account
	parcel.notyp warns all the files that will be removed while packaging the parcel for Quantum
    }
}
proc ptypefile { args } {
    ;# Options
    ;#
    set tblreq(-h) {}
    set tblreq(-w) {}
    set tblreq(-t) {}
    set tblreq(-S) value_required:list
    ;# Parameters
    ;# 
    set param {}
    if {[wokUtils:EASY:GETOPT param table tblreq ptypefile_usage $args] == -1 } return
    ;#
    if { [info exists table(-h)] } {
	ptypefile_usage 
	return
    }
    set warn 0
    if { [info exists table(-w)] } {
	set warn 1
    }
    if { [info exists table(-t)] } {
	set tkpriority 1
	msgprint -w "SORRY NOT YET IMPLEMENTED ...."
	return
    }
    set statlist { ao1 hp sil sun }
    if { [info exists table(-S)] } {
	set statlist $table(-S)
	}
    set parc [lindex  $param 0]
    if { $parc == "" } {
	ptypefile_usage
	return
    }
    set parcname [wokinfo -n $parc]
    # sauvons la plateforme en cours 
    set curstation  [wokparam -v %Station]
    ;# sauvons
    catch {exec cp "[wokparam -v %${parcname}_Adm]/${parcname}.typ" "[wokparam -v %${parcname}_Adm]/${parcname}.typ-sav"}
    set typfile [open  "[wokparam -v %${parcname}_Adm]/$parcname.typ" w+]
    set notypfile [open  "[wokparam -v %${parcname}_Adm]/$parcname.notyp" w+]
    set unktypfile [open  "[wokparam -v %${parcname}_Adm]/$parcname.unktyp" w+]
    # Traitons d'abord les fichiers non plateformes dependants
    # les uds de l'ul
    ;#    catch {
	foreach ud [ pinfo -l $parc] {
	    set lstwokfilecom "[uinfo -Fi $parc:$ud ] [uinfo -Fb $parc:$ud ] "
	    puts " UD $ud "
	    foreach wokfile  $lstwokfilecom  {
		switch  -exact [lindex $wokfile 0] {
		    EXTERNLIB -
		    admfile -
		    ccldrv -
		    dbadmfile -
		    demofile -
		    derivated -
		    dummy -
		    infofile -
		    intdat -
		    object -
		    pubinclude -
		    source -
		    srcinc -
		    stadmfile -
		    sttmpdir -
		    testobject {typnotkept $warn $wokfile $notypfile }
		    cclcfg -
		    cclrun -
		    corelisp -
		    dbunit -
		    'default' -
		    engdatfile -
		    engine -
		    englisp -
		    englispfile -
		    executable -
		    icon -
		    iconfd -
		    loginfile -
		    motifdefault -
		    msentity -
		    msgfile -
		    shapefile -
		    shellcfg -
		    shellscript -
		    template -
		    testexec { typkept $wokfile  $parcname $ud $typfile }
		    datafile { typdatafile $warn $wokfile $parcname $ud  $typfile $notypfile }
		    default { typunknown $wokfile $unktypfile}
		}
	    }
	    foreach worksta $statlist {
		wokprofile -S $worksta
		set lstwokfilesta [uinfo -Fs $parc:$ud ]
		foreach wokfile  $lstwokfilesta  {
		    switch  -exact [lindex $wokfile 0] {
			EXTERNLIB -
			admfile -
			ccldrv -
			dbadmfile -
			demofile -
			derivated -
			dummy -
			infofile -
			intdat -
			object -
			pubinclude -
			source -
			srcinc -
			stadmfile -
			sttmpdir -
			testobject { typnotkept $warn $wokfile $notypfile }
			cclcfg -
			cclrun -
			corelisp -
			dbunit -
			'default' -
			engdatfile -
			engine -
			englisp -
			englispfile -
			executable -
			icon -
			iconfd -
			motifdefault -
			msentity -
			msgfile -
			shapefile -
			shellcfg -
			shellscript -
			template -
			testexec { typkept $wokfile  $parcname $ud $typfile }
			library { typlibrary $warn $wokfile $parcname $ud $typfile $notypfile }
			datafile { typdatafile $warn $wokfile $parcname $ud $typfile $notypfile }
			loginfile { typloginfile $warn $wokfile $parcname $ud $typfile $notypfile }
			default { typunknown $wokfile $unktypfile }
		    }
		}
	    }
	}
    ;#    }
    close $typfile	    
    close $unktypfile	    
    close $notypfile
    ;# on remet la station
    wokprofile -S $curstation	    
}
;#
proc typkept { wokfile parcname ud typfile  } {
    puts  $typfile "[lindex $wokfile 0]          [string range [wokinfo -p [lindex $wokfile 0]:[lindex $wokfile 1]   ${parcname}:${ud}] [expr [string length [wokparam -v %${parcname}_Home]] + 1] end]"
}
proc typnotkept { warn wokfile notypfile } {
    if { $warn } { msgprint -w "TYPE $wokfile NOT KEPT"	 }
    puts $notypfile "TYPE $wokfile  NOT KEPT" 
} 
proc typunknown { wokfile unktypfile } {
    msgprint -e "TYPE $wokfile UNKNOWN " 
    puts $unktypfile "TYPE $wokfile UNKNOWN"
}

proc typlibrary { warn  wokfile parcname ud  typfile notypfile } {
    ;# rajouter pktklist et tkpriority apres
    if {[file extension [lindex $wokfile 1]] == ".Z"} {
	typnotkept $warn $wokfile $notypfile 
    } else { 
	typkept $wokfile  $parcname $ud $typfile
    }
}
proc typdatafile { warn  wokfile parcname ud  typfile notypfile} {
    if {[file extension [lindex $wokfile 1]] == ".ilm"} {	
	typnotkept $warn $wokfile $notypfile 
    } else { 
	typkept $wokfile  $parcname $ud $typfile
    }
}
proc typloginfile { warn  wokfile parcname ud  typfile notypfile } {
    if {[file extension [lindex $wokfile 1]] == ".edl"} {
	typnotkept $warn $wokfile $notypfile 
    } else { 
	typkept $wokfile  $parcname $ud $typfile
    }
}

