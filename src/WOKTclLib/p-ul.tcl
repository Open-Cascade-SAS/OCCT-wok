#========================================================================================================
# p-put Version 3.02 beta (egu 17/07/98 )
# ajout verification que les fichiers embarques ne sont pas protege en ecriture sous WNT
#========================================================================================================

#  
# Usage
# 
proc p-putUsage { } {
    puts stdout {p-put Version 3.02 17/07/98}
    puts stdout {Usage   : p-put [-h]   (this help)}
    puts stdout {Usage   : p-put [-web] (updating web site)}
    puts stdout {Usage   : p-put <cfg> [<cfg1>...] -B <BAG> -U <UL>  }                                   
    #puts stdout {          p-put <cfg> [<cfg1>...] -B <BAG> -U <UL>  [-P <patch>]                               }
    puts stdout {          p-put <cfg> [<cfg1>...] -B <BAG> -U <UL>  [-P <patch>] -L <liste-patch> -C "comment" }
    return
}

proc p-put { args } {
    global env

    set tblreq(-h)   {}
    set tblreq(-web)   {}
    set tblreq(-B)   value_required:string
    set tblreq(-U)   value_required:string
    set tblreq(-P)   value_required:string
    set tblreq(-L)   value_required:string
    set tblreq(-C)   value_required:string

    set param {}
    if { [putils:EASY:GETOPT param tabarg tblreq p-putUsage $args] == -1 } return

#==================== OPTIONS SETTINGS ==========================

    if [info exists tabarg(-web)] {
	update-web-data
	return
    }

    if [info exists tabarg(-h)] {
	p-putUsage
	return
    }

    set param_length [llength $param]

    if { $param_length == 0 } {
	puts stderr "Error : You must enter at least one configuration"
	return error
    } else {
	set list_config {}
	foreach config $param {
	    lappend list_config $config
	}
    }

    ### ABOUT UL ###

    set nbargx 0
    if [info exists tabarg(-B)] {
	set SRC_BAG_PATH $tabarg(-B)
	if ![file exists $SRC_BAG_PATH] { 
	    puts stderr " Error : can not see $SRC_BAG_PATH"
	    return error
	}
	incr nbargx
    }

    if [info exists tabarg(-U)] {
	set SRC_BAG_DIR $tabarg(-U)
	set SRC_DIR  ${SRC_BAG_PATH}/${SRC_BAG_DIR}
	if ![file exists ${SRC_DIR}] { 
	    puts stderr " Error : can not see $SRC_BAG_DIR directory under $SRC_BAG_PATH"
	    return error
	}
	incr nbargx
    }

    if [info exists tabarg(-P)] {
	set PATCH $tabarg(-P)
	set AUTONUM 0
    } else {
	set PATCH {}
	set AUTONUM 1
    }

    ### ABOUT PATCH ###

    set nbargy 0

    if [info exists tabarg(-C)] {
	set COMMENT $tabarg(-C)
	incr nbargy
    }
    
    
	 if [info exists tabarg(-L)] {
	set LIST_FILE $tabarg(-L)
	if ![file readable $LIST_FILE] { 
	    puts stderr " Error : can not read $LIST_FILE"
	    return
	} else {
	    set f [open $LIST_FILE r]
	    set PB 0
	    while { [ gets $f line ] >= 0 } {
		if ![catch { glob ${SRC_DIR}/${line} } ] {
		    foreach fich [glob ${SRC_DIR}/${line}] {
			if ![file readable $fich] {
			    puts stderr " Error : can not read $fich"
			    set PB 1
			} 
		    }	
		    if { $env(WOKSTATION) == "wnt"} {
			foreach fich [glob ${SRC_DIR}/${line}] {
			    if ![file writable $fich] {
				puts stderr " Error : $fich not writable, problem will exist for next patch"
				set PB 1
			    }
			}
		    }
		} else {
		    puts stderr " Error : can not glob line  ${SRC_DIR}/${line}"
		    set PB 1
		}
	    }
	    close $f
	    if { $PB == 1 } { 
		puts stderr " Procedure aborted " 
		return 0
	    }
	}
	incr nbargy
    } else {
	foreach fich [recursive_glob ${SRC_DIR} *] {
	    if ![file readable $fich] {
		puts stderr " Error : can not read $fich"
		return
	    }
	}
	if { $env(WOKSTATION) == "wnt"} {
	    foreach fich [recursive_glob ${SRC_DIR} *] {
		if ![file writable $fich] {
		    puts stderr " Error : $fich not writable, problem will exist for next patch"
		    return
		}
	    }
	}
    }

    ### REFERENCE ###

    set ULBAG [wokparam -e %BAG_Home REFERENCE]

    ### LETS GO ###
    
    if [expr {$nbargx == 2 && $nbargy == 0}] {
	if {[put-ul $SRC_BAG_PATH $SRC_BAG_DIR $ULBAG $list_config] == 1 } { return end }
	return error
    }

    if [expr { $nbargx == 2 && $nbargy == 2}] {
	if {[put-patch $SRC_BAG_PATH $SRC_BAG_DIR $AUTONUM $PATCH $ULBAG $LIST_FILE $COMMENT $list_config] == 1 } { return end }
	return error
    } 
    
}

##################### PUT-UL  ######################################

proc put-ul { src_bag ul_name dest_dir config_list} {
    
    
    if [file exists ${dest_dir}/${ul_name}.tar.gz] {
	puts stderr "Error :  ${ul_name}.tar.gz already exist in ${dest_dir}"
	return 0
    }
    
    set savpwd [pwd]
    cd ${src_bag}/${ul_name} 

    puts stdout "Info : Creating ${dest_dir}/${ul_name}.tar"
    
    if { [putils:EASY:tar tarfromroot ${dest_dir}/${ul_name}.tar .] == -1 } {
	puts stderr "Error while creating ${dest_dir}/{ul_name}.tar "
	catch {unlink ${dest_dir}/${ul_name}.tar}
	cd $savpwd
	return 0
    } 
 
    puts stdout "Info : Gziping  ${dest_dir}/${ul_name}.tar"
    
    if { [putils:FILES:compress ${dest_dir}/${ul_name}.tar] == -1 } {
	puts stderr "Error while creating ${dest_dir}/${ul_name}.tar.gz
	catch {unlink ${dest_dir}/${ul_name}.tar}
	catch {unlink ${dest_dir}/${ul_name}.tar.gz}
	cd $savpwd
	return 0
    }

    #### Construction du fichier de trace ####
    puts stdout "Info : Creating trace file  ${dest_dir}/TRC/${ul_name}.trc"
    set trace [open ${dest_dir}/TRC/${ul_name}.trc w]
    foreach fich [glob ${src_bag}/${ul_name}/*] {
	puts $trace $fich
    }
    close $trace

    #### Inscription dans le(s) configul(s) ####
    set now [clock format [getclock] -format "%d/%m/%y   %H:%M:%S"]
    foreach config $config_list {
	set CONFIGUL  ${dest_dir}/CONFIGUL.${config}
	puts stdout " Updating  $CONFIGUL"
        set f [ open $CONFIGUL a+]
        set s [format "%-18s %s" $ul_name $now]
	puts $f $s
        close $f
    }

    ###fin
    puts stdout  "  success... at [set now [string range [fmtclock [getclock]] 0 18]]"
    cd $savpwd


    #### mise a jour des fichiers du web ####  
    update-web-data

    return 1		
}


#
##################### PUT-PATCH  ######################################
#

proc put-patch { src_bag ul_name AUTONUM patch_name dest_bag lst_patch comment config_list} {
    
    set dest_dir $dest_bag/PATCH

    ### Pour la numerotation automatique ###
    if { $AUTONUM} {
	set level [conf_ul_level $ul_name [lindex $config_list 0] $dest_bag]
	foreach config $config_list {
	if ![ file exists  ${dest_dir}/PATCHISTO.${config} ] {
		puts stderr "Error autonum: File  ${dest_dir}/PATCHISTO.${config} dont exist, you must create it"
		return 0
	    }
	    set new_level [conf_ul_level $ul_name $config $dest_bag]
	    if { $new_level != $level } {
		puts stderr " Error autonum : different patch levels in different configul "
		return 0
	    }
	}
 
	
	if { $level == -1 } { 
	    puts stderr " Error : can't calculate patch levels "
	    return 0
	}
	incr level
	set patch_name ${ul_name}_${level}
        puts stdout "Info : patch auto numerotation = $level"
    }

    #####

    set savpwd [pwd]
    cd ${src_bag}/${ul_name}
	
    if [file exists ${dest_dir}/${patch_name}.tar.gz ] {
	puts stderr "Error : File  ${dest_dir}/${patch_name}.tar.gz already exists. Nothing done"
	cd $savpwd
	return 0
    }

    puts stdout "Info : Creating  ${dest_dir}/${patch_name}.tar"
    
if { [putils:EASY:tar tarfromliste ${dest_dir}/${patch_name}.tar ${lst_patch}] == -1 } {
	puts stderr "Error while creating ${dest_dir}/{patch_name}.tar "
	catch {unlink ${dest_dir}/{patch_name}.tar }
	cd $savpwd
	return 0
    } 
	
    puts stdout "Info : Gziping  ${dest_dir}/${patch_name}.tar"
    if { [putils:FILES:compress ${dest_dir}/${patch_name}.tar] == -1 } {
	puts stderr "Error while creating ${dest_dir}/${patch_name}.tar.gz
	catch {unlink ${dest_dir}/${patch_name}.tar}
	catch {unlink ${dest_dir}/${patch_name}.tar.gz}
	cd $savpwd
	return 0
    }

    puts stdout  "  success... at [set now [string range [fmtclock [getclock]] 0 18]]"
	
    #### Construction du fichier de trace ####
    puts stdout "Info : Creating trace file  ${dest_dir}/TRC/${patch_name}.trc"
    set f     [open $lst_patch r]
    set trace [open ${dest_dir}/TRC/${patch_name}.trc w]
    while { [ gets $f line ] >= 0 } {
	foreach fich [glob ${src_bag}/${ul_name}/${line}] {
	    puts $trace $fich
	}
    }
    close $f
    close $trace
		
    #### Inscription dans le(s) patchisto(s) ####
    
    #set now [string range [fmtclock [getclock]] 0 18]
    set now [clock format [getclock] -format "%d/%m/%y   %H:%M:%S"]
    set level [lindex [split ${patch_name} _] end]
    set ul_name [lindex [split ${patch_name} _] 0]
    foreach config $config_list {
        set PATCHISTO "${dest_dir}/PATCHISTO.${config}"
        puts stdout "Info : updating $PATCHISTO"
        set f [open $PATCHISTO r+]
	set indice 0
	while { [ gets $f line ] >= 0 } {
	    if [ ctype alnum [ lindex $line 0 ] ] {
		set indice [ lindex $line 0 ]
	    }
	}
        incr indice
	puts stdout "Info : $PATCHISTO patch indice = $indice"
        close $f
        set lpatch [putils:FILES:FileToList $PATCHISTO ]
	set s [format "%-5s%-18s%3s   %-5s    %s" $indice $ul_name $level $now $comment]
        lappend lpatch $s
	putils:FILES:ListToFile $lpatch $PATCHISTO
    }

    ###FIN
    puts stdout  "  success... at [set now [string range [fmtclock [getclock]] 0 18]]"
    cd $savpwd

    #### mise a jour des fichiers du web ####  
    update-web-data

    return 1		
}

#=================================================================================
proc conf_ul_level { ul_name config bag_path } {

    set CONFIGUL ${bag_path}/CONFIGUL.${config}
    set PATCHISTO ${bag_path}/PATCH/PATCHISTO.${config}

    set level -1
    if [file exists ${CONFIGUL} ] { 
	set f [open $CONFIGUL r ]
	while {[gets $f line] >= 0 } {
	    if [ctype alnum [ cindex [lindex $line 0] 0 ] ] {
		if { [lindex $line 0] == $ul_name } {
		    set level 0
		}
	    }
	}
        close $f
    }
    
    if [file exists ${PATCHISTO}] { 
	set f [open $PATCHISTO r]
	while { [ gets $f line ] >= 0 } {
	    if [ ctype alnum [ lindex $line 0 ] ] {
		if { [lindex $line 1] == $ul_name } {
		    set level [lindex $line 2]
		}
	    }
	}
	close $f
    }
    return $level
}

#################################################
proc update-web-data  { } {

    global env        
    set PROCFTPPATH $env(FACTORYHOME)/MajWeb
    puts -nonewline "=== Updating www data....."

    if { $env(WOKSTATION) == "wnt"} {
    	if [file exists $PROCFTPPATH/putdata.ftp] { 
         	if [catch { eval exec ftp {-v -i -s:$PROCFTPPATH/putdata.ftp} } status] {
		    puts stderr $status
		} else {
		    puts " done ==="
		}
	} else {
         puts stdout "Info : Cant find $PROCFTPPATH/putdata.ftp"
      }
    } else {
	if [file exists $PROCFTPPATH/putdata.com] { 
            if [catch { eval exec $PROCFTPPATH/putdata.com } status] {
		puts stderr $status
	    } else {
		puts " done ==="
	    }
	} else {
        puts stdout "Info : Cant find $PROCFTPPATH/putdat.ftp"
      }
    }
return
}

#========================================================================================================
# p-get Version 3.04 (egu 29/09/98 )
# ajout de l'option -f pour forcer l'install des patch
# (ajout de l'option -runtime pour ne pas faire de declarations
# liees a la descente des patchs)activite non visible
# Modification de nombreuses functions pour wok: wok n'est plus versionne
# suppression des options -v (verbose) et -n (no execute)
#========================================================================================================
#========================================================================================================
#========================================================================================================

proc p-get-usage { } {
    puts stderr {}
    puts stdout {p-get Version 3.04 (september 98)}
    #puts stderr {Usage  : p-get [-h][-f][-rt][-clean][-d dirinstall] <conf> [del list] [-P patch |-I indice]}
    puts stderr {Usage  : p-get [-h][-f][-clean][-d dirinstall] <conf> [del list] [-P patch |-I indice]}
    puts stderr {                   -h : this help}
    puts stderr {                   -f : force install}
#   puts stderr {                  -rt : runtime mode} #fonctionne mais volontairement cache
    puts stderr {               -clean : clean mode}
    puts stderr {      [-d dirinstall] : directory to install ul}
    puts stderr {               <conf> : configuration}
    puts stderr {           [del list] : list of one or more Delivery: [ <del1> [del2] [del3] ... ]}
    puts stderr {                        OR "ALL" ("ALL" is default value)}
    puts stderr {          [-P patch | : patch number OR "ALL" ("ALL" is default value)}
    puts stderr {          |-I indice] : indice number OR "ALL" ("ALL" is default value)}
#    puts stderr { Online doc at http://info.paris1.matra-dtv.fr/Devlog/Departements/Dcfao/env/pget304.htm}
    return
}

#========================================================================================================

proc p-get { args } {
    
    global env
    
    set tblreq(-h)      {}
    set tblreq(-f)      {}
    set tblreq(-rt)     {}
    set tblreq(-clean)  {}
    set tblreq(-d)   value_required:string
    set tblreq(-P)   value_required:string
    set tblreq(-I)   value_required:string
    
    set param {}
    if { [putils:EASY:GETOPT param tabarg tblreq p-get-usage $args] == -1 } return
    set param_length [llength $param]
    
    #======================================= VARIABLES SETTINGS =============================================
    if [info exists tabarg(-h)] {
	p-get-usage
	return
    }
    
    #----------- WOK SETTINGS -------------------------------------  
    wokclose -a [wokparam -e %[finfo]_Home]
    set SRCBAGPATH  [wokparam -e %BAG_Home REFERENCE]
    set SRCPATCHPATH $SRCBAGPATH/PATCH
    set DESTBAGPATH  [wokparam -e %BAG_Home]

    #------------- OPTIONS SETTINGS -------------------------------
    set FORCE    [info exists tabarg(-f)]
    set RUNTIME  [info exists tabarg(-rt)]
    set CLEAN    [info exists tabarg(-clean)]

    if [info exists tabarg(-d)] {
	set NEWDIR $tabarg(-d)
    } else {
	set NEWDIR 0
    }
    
    if { $param_length == 0 } {
	puts stderr " Error : You must at least enter a configuration"
	p-get-usage
	return
    }

    set CONF [lindex $param 0]
    set CONFIGUL ${SRCBAGPATH}/CONFIGUL.${CONF}
    if { ![file exists $CONFIGUL] } {
	puts stderr " Error : Cannot find $CONFIGUL, maybe version $CONF don't exist "
	p-get-usage
	return
    }
    
    set PATCHISTO ${SRCPATCHPATH}/PATCHISTO.${CONF}
    
    set ul_list {}
    if { $param_length == 1 } {  lappend ul_list ALL }
    if { $param_length >= 2 } {
	if { [lindex $param 1] == "ALL" } {  
	    lappend ul_list ALL 
	} else {
	    for { set i 1 } { $i < $param_length } { incr i } {
		lappend ul_list [lindex $param $i]
	    }
	}
    }
    
    if [info exists tabarg(-P)] {
	set maxlevel $tabarg(-P)
	if { $maxlevel != "ALL" && [ctype digit $maxlevel] == 0 } {
	    puts stderr " Error : -P option must be a number or \"ALL\""
	    p-get-usage
	    return
	}
    } else {
	set maxlevel ALL
    }
    
    if [info exists tabarg(-I)] {
	set maxindice $tabarg(-I)
	if { $maxindice != "ALL" && [ctype digit $maxindice] == 0 } {
	    puts stderr " Error : -I option must be a number or \"ALL\""
	    p-get-usage
	    return
	}
    } else {
	set maxindice ALL
    }
    
    
    #----------- OPTIONS RESTRICTIONS --------------------------
    
    if { $maxlevel != "ALL" && $maxindice != "ALL" } {
	puts stderr "Error : You can't use -I and -P options together"
	return
    }
    
    if { $maxlevel != "ALL" } {
	if { [llength $ul_list] > 1 || [lindex $ul_list 0] == "ALL"} {
	    puts stderr "Error : You can't use -P option with more than one selected UL"
	    return
	}
    }
    
    #-- Infos --
    puts "SELECTED UL(s)   : $ul_list"
    puts "CONFIGURATION    : $CONF"
    puts "MAX PATCH LEVEL  : $maxlevel"
    puts "MAX INDICE LEVEL : $maxindice"
    if { $NEWDIR != 0 } {
	puts "INSTALLATION DIR : $NEWDIR"
    } else {
	puts "INSTALLATION DIR : $DESTBAGPATH"
    }
    if $FORCE      { puts "FORCE   ON" }
    if $RUNTIME    { puts "RUNTIME ON" }
    puts {}

	
    #================================= LET'S GO ==============================================
    #====== creating array mytab of couples (ul full name - patch level to be installed) ======

    #reconstruct ul_list if "ALL" ul specified
    if { [lindex $ul_list 0] == "ALL" } {
	set admdir [wokparam -e %[finfo]_Adm]
	set file ${admdir}/${CONF}.edl
	if [file exists $file] {
	    wokclose -a [wokparam -e %[finfo]_Home]
	    set lst_conf [join  [wokparam -e %${CONF}_Config] ]
	    if ![ catch { wokparam -e %${CONF}_Runtime } gonogo ] {
		foreach a [join  [wokparam -e %${CONF}_Runtime] ] { lappend lst_conf $a }
	    } 
	    set ul_list {}
	    foreach p $lst_conf {
		if {  [lindex [split $p "-"] 1] != $CONF } {
		    puts stdout "   Info: I don't take accompt of a bad parcel name in your $file : $p"
		    #return
		} else {
		lappend ul_list [lindex [split $p "-"] 0]
		}	
	    }
	    foreach p $lst_conf {
		if {  [lindex [split $p "-"] 1] != $CONF } {
		    puts stdout "   Info: I don't take accompt of a bad parcel name in your $file : $p"
		    #return
		} else {
		lappend ul_list [lindex [split $p "-"] 0]
		}	
	    }
	} else {
	    puts stderr "Error: None ul installed. Option ul_list = ALL can't be used"
	    return
	}
    }

    #construct array from CONFIGUL file
    if { [array-set-from-CONFIGUL tab $CONFIGUL $ul_list] == 0 } { return }

    if { [array exists tab] == 0 } {
	puts stderr "Error : none del of $CONF matching given list"
	return
    }

    #construct array from PATCHISTO file
    array-set-from-PATCHISTO tab  $PATCHISTO $ul_list $maxindice $maxlevel
    
    #----------- Infos ----------------- 
    puts "***** install levels *****"
    array-print tab
   

    #====================== Installation from array "tab" ===============================
    
    set lstul [ lsort [array names tab] ]
   
    ### set destination directory ###
    if { $NEWDIR != 0 } {
	foreach MYUL $lstul {
	    set MYDEL [lindex [split $MYUL "-"] 0]
	    set PARCELPATH  [parcel-path $MYUL $CONF]
	    
	    #verrue wok
	    if { $MYDEL == "wok"} {
		set pat ${DESTBAGPATH}/${MYUL}
		if { $NEWDIR != $pat } {
		    puts stderr "Error : wok cannot be install in a special directory"
		    return
		}
	    }
	    #fin verrue wok
	    
	    if { $PARCELPATH != 0 && $PARCELPATH != $NEWDIR } {
		puts stderr "${MYDEL}-${CONF} already exist in $PARCELPATH : Cannot create same parcel in $NEWDIR"
		puts stderr "Nothing done"
		return
	    }
	}
    }

    ### begin install from array tab ###
    foreach MYUL $lstul {
	if { $tab($MYUL) >= 0 } {
	    set MYDEL [lindex [split $MYUL "-"] 0]
	    
	    ### test for wok 
	    if { $MYDEL == "wok"} { 
		set MYPARCEL ${MYUL}
		set PARCELPATH ${DESTBAGPATH}/${MYPARCEL}
	    } else {
		set MYPARCEL ${MYDEL}-${CONF}
		if { $NEWDIR != 0 } {
		    set PARCELPATH $NEWDIR 
		} else {
		    set PARCELPATH  [parcel-path $MYUL $CONF]
		    if { $PARCELPATH == 0 } {
			set PARCELPATH ${DESTBAGPATH}/${MYPARCEL}
		    }
		}
	    }
	    
            if $FORCE {  
		set level_to_begin_install 0 
	    } else {
		set installed_level [parcel-level $MYUL $CONF]
		set level_to_begin_install [expr ( $installed_level + 1)]
	    }
	    
	    if { $level_to_begin_install > $tab($MYUL) } {
		set bag_patch_level [conf_ul_level $MYUL $CONF $SRCBAGPATH]
#FUN 13/10/98 
		if {$installed_level > $tab($MYUL)} {
		    puts "\nWarning:  $MYUL is already at level $installed_level > $tab($MYUL)"
		} else {
		    puts "\n----- $MYUL is already at level $installed_level (max = $bag_patch_level)"
		}
	    } else {
		set s [format "\n----- INSTALLING %-15s\t%-3s>> %-3s in %s -----" $MYUL $level_to_begin_install $tab($MYUL) $PARCELPATH ]
		puts stdout $s
	    }
	    
	    for { set pnumber $level_to_begin_install } { $pnumber <= $tab($MYUL) } { incr pnumber } {
		puts stdout "INSTALL LEVEL $pnumber"
		switch $pnumber 0 {
		    if { ![install-ul $MYUL $SRCBAGPATH $PARCELPATH $CONF taberror $RUNTIME $FORCE]} { break }
		    set pnumber [expr max(0,[parcel-level $MYUL $CONF])]
		} default {
		    if { ![install-patch  $MYUL $pnumber $SRCPATCHPATH $PARCELPATH $CONF taberror] } { break }
		    
		}
	    }
            
	    if $CLEAN {
		set lst_station [join [wokparam -e %[finfo -W]_Stations] " "]
		foreach station [join [wokparam -e %REFERENCE_Stations]  " "] {
		    if {[lsearch -exact $lst_station $station] == -1} { 
			puts stdout "   - removing $station dependent files..."
			if { [file exists  $PARCELPATH/$station] }      { catch { exec rm -rf $PARCELPATH/$station  } }
			if { [file exists  $PARCELPATH/tmp/$station] }  { catch { exec rm -rf $PARCELPATH/tmp/$station  } }
			if { [file exists  $PARCELPATH/.adm/$station] } { catch { exec rm -rf $PARCELPATH/.adm/$station  } }
		    }
		}
	    }
	}
    }
    array-print taberror
      
    return
}

#=================================================================
# ARRAY-SET-FROM-CONFIGUL (egu)
#
# set "array_name" with couples (ul-level) get from "conf-file".
# with ul matching "ul-list" element
#=================================================================

proc array-set-from-CONFIGUL { array_name conf_file ul_list } {

    upvar $array_name tab
    if [file readable $conf_file ] {
	set f [open $conf_file r]
	set line {}
	while {[gets $f line] >= 0 } { 
	    if { [llength $line] != 0 } { 
		if { [ctype alnum [cindex [lindex $line 0] 0]] == 1 } { 
		    set  ul_name  [lindex $line 0]
		    if { [lindex $ul_list 0] == "ALL" } {
			set tab($ul_name) 0
		    } else {
			foreach ul $ul_list {
			    if { $ul == $ul_name ||  $ul == [lindex [split $ul_name "-"] 0 ] } {
				set tab($ul_name) 0 
				break
			    }
			}
		    }
		}
	    }
	}
	close $f
    } else {
	puts stderr "Error : Can not read $conf_file"
	return 0
    }

    return 1
}


#=================================================================
# ARRAY-SET-FROM-PATCHISTO (egu)
#
# set "array_name" with couples (ul-level) get from "patch-file"
# line of indice < max_i
# with ul matching "ul-list" element 
# with level < max_p
#=================================================================

proc array-set-from-PATCHISTO { array_name patch_file ul_list {max_i ALL} {max_p ALL} } {

    upvar $array_name tab
    if { $max_i == "ALL" } { set maxindice 1000000 } else { set maxindice $max_i }
    if { $max_p == "ALL" } { set maxpatch  1000000 } else { set maxpatch  $max_p }
    if [ file readable $patch_file ] {
	set f [open $patch_file r]
	set line {}
	incr maxindice
	while { [ gets $f line ] >= 0 && [ lindex $line 0 ] != $maxindice } {
	    if { [ llength $line ] != 0 } {   
		if { [ ctype alnum [ lindex $line 0 ] ] == 1 } {
		    
		    set ul_name  [lindex $line 1]
		    set ul_level [lindex $line 2]
		    if { [lindex $ul_list 0] == "ALL" } {
			set tab($ul_name) $ul_level 
		    } else {
			foreach ul $ul_list {
			    if { $ul == $ul_name ||  $ul == [lindex [split $ul_name "-"] 0 ] } {
				set tab($ul_name) [expr min($ul_level,$maxpatch)] 
				break
			    }
			}
		    }
		}
	    }
	}
	close $f
    } else {
	#puts stderr "Info : Can't find $patch_file, no patch exist for this configuration"
	return 0
    }
    return 1
}

#=================================================================
# ARRAY-PRINT (egu)
#=================================================================
proc array-print { array_name } {
    upvar $array_name tab
    set lst [lsort [array names tab]] 
    foreach elt $lst {
	set s [format "%-20s\t%s" $elt $tab($elt)]
	puts stdout $s
    }
}

#=================================================================
# PARCEL-EXIST (egu)
# test if parcel exist
# Last modif: 27/07/98: for wok (param del become param ul)
#=================================================================

proc parcel-exist { ul conf } {
    set del [lindex [split $ul "-"] 0]
    #verrue wok
    if { $del == "wok" } { 
	if [file exists [wokparam -e %BAG_Home]/${ul}] { 
	    return 1 
	} else {
	    return 0
	}
    }
    #fin verrue wok
    set ul_name ${del}-${conf}
    set lst [ Winfo -p [finfo]:[finfo -W]]
    if {[lsearch -exact $lst $ul_name] == -1} { return 0 } else { return 1 }
}
#=================================================================
# PARCEL-PATH (egu)
# return parcel-path, 0 if it parcel doesn't exist
# Last modif: 27/07/98: for wok (param del become param ul)
#=================================================================

proc parcel-path { ul conf } {
    set del [lindex [split $ul "-"] 0]
    if [parcel-exist $ul $conf] {
	if { $del == "wok" } {
	    set path [wokparam -e %BAG_Home]/${ul}
	} else {
	    set path  [wokinfo -p HomeDir [finfo]:[finfo -W]:${del}-${conf}]
	}
	return $path
    } else {
	return 0
    }
}
#=================================================================
# PARCEL-LEVEL (egu)
# return the patch top level already install, -1 if no install
# Last modif: 27/07/98: for wok (param del become param ul)
#=================================================================

proc parcel-level { ul conf } {
    if [parcel-exist $ul $conf] {
	set del [lindex [split $ul "-"] 0]
	if { $del == "wok" } {  
	    set getpatch_file [parcel-path $ul $conf]/.${ul}.GETPATCH 
	} else {
	    set getpatch_file [parcel-path $ul $conf]/.${del}-${conf}.GETPATCH
	}
	if [file exists $getpatch_file] {
	    set list_level [lsort -integer [p-get-installed $getpatch_file]]
	    set index [llength $list_level]
	    incr index -1
	    return [lindex $list_level $index]
	} else {
	    return 0
	}
    } else {
	return -1
    }
}

#=================================================================
# INSTALL-UL (egu)
#
# create and declare parcel, return 0 if failled
# if success : return patch level already install
# 27/07/98: verrue for wok (egu) ajout option force et runtime
# 10/08/98: supression option vernose et no-execute
#=================================================================

proc install-ul  { ul_name src_dir dest_dir conf tab_error RUNTIME FORCE} {
 
    ### variables setting
    upvar $tab_error tab_err

    #verrue anti verion pour wok
    set MYDEL [lindex [split $ul_name "-"] 0]
    if { $MYDEL == "wok" } {
	set MYPARCEL ${ul_name}
    } else {
	set MYPARCEL ${MYDEL}-${conf}
    }
    set WAREHOUSE_ADM_PATH [wokparam -e %[finfo -W]_Adm]
    set wdeclare_file      ${WAREHOUSE_ADM_PATH}/${MYPARCEL}.edl 
    set getpatch_file      ${dest_dir}/.${MYPARCEL}.GETPATCH
    set parcellist_file    ${WAREHOUSE_ADM_PATH}/ParcelList 
    
    ### on verifie l'existence du fichier a decompresser
    set tar ${src_dir}/${ul_name}.tar.gz
    if ![file exists $tar] {
	puts stderr ".... error"
	puts stderr "Nothing done : Cannot find $tar"
	set tab_err($ul_name) "Nothing done : Cannot find $tar"
	return 0
    }
    
    ### test cause option -d : dest_dir peut deja exister
    if { ![file exists $dest_dir] } {
	puts stdout "   - Mkdir $dest_dir ..."
	if [catch { mkdir $dest_dir} mkstat]   {
	    puts stderr ".... error"
	    puts stderr "Nothing done : Cannot create $dest_dir : $mkstat"
	    set tab_err($ul_name) "Nothing done : Cannot create $dest_dir : $mkstat"
	    return 0
	}
    }
    
    ### security cleaning
    if [file exists $getpatch_file] { 
	puts stdout "   - remove $getpatch_file"
	exec rm -rf $getpatch_file 
    }
    
    ### let's go
    puts stdout "   - Downloading $tar in $dest_dir..."
    p-get-ptar  $ul_name $dest_dir $tar
    
    ### in FORCE case without first classic install
  
    if { $MYDEL != "wok" && $FORCE } { 
	if ![file exists [wokparam -e %[finfo -W]_Adm]/${MYPARCEL}.edl] { 
	    set FORCE 0 
	    puts stdout "     -> Info: ${MYPARCEL} has never been declared, it will in spite of FORCE option"
	}
    }
    
    # if: verrue for wok: pas de declaration
    if { $MYDEL != "wok" && !$FORCE } {
	if { [file exists ${WAREHOUSE_ADM_PATH}/${MYPARCEL}.edl] } {
	    puts stderr ".... error"
	    puts stderr "Cannot create ${WAREHOUSE_ADM_PATH}/${MYPARCEL}.edl : file already exists"
	    set tab_err($ul_name) "Cannot create ${WAREHOUSE_ADM_PATH}/${MYPARCEL}.edl : file already exists"
	    return 0
	} else {
            puts stdout "   - Wdeclare ${MYPARCEL} (Don't worry about \"Error   : No entity...\")" 
	    puts stdout "     -> Info: Wdeclare create $wdeclare_file and update $parcellist_file"
	    
	    if { [catch { Wdeclare -p $MYPARCEL -d -DHome=${dest_dir} -DStations=[join [wokparam -e %[finfo -W]_Stations] " "]  -DDelivery=${MYDEL} [finfo -W]  } ] } {
		puts stderr ".... error" 
		puts stderr "Error Wdeclare $MYPARCEL"
		set tab_err($ul_name) "Error Wdeclare $MYPARCEL"
		return 0
	    } 
	}
	
	#declaration
	set FACTORY_ADM_PATH [wokparam -e %[finfo]_Adm]
	puts stdout "   - Updating ${FACTORY_ADM_PATH}/${conf}.edl file... "
	if {[maj-conf-edl $conf $MYPARCEL $RUNTIME] == 0 } {
	    puts stderr ".... error"
	    puts stderr "Cannot update  ${FACTORY_ADM_PATH}/${conf}.edl"
	    set tab_err($ul_name) "Error : Cannot update  ${FACTORY_ADM_PATH}/${conf}.edl"
	    return 0
	}
    }   
    return 1   
}
#=================================================================
# MAJ-CONF-EDL (egu)
# Mise a jour du fichier BAG/adm/${conf}.edl
# return 1 si ok, 0 sinon
#=================================================================

proc maj-conf-edl { conf new_parcel RUNTIME } {
    set admdir [wokparam -e %[finfo]_Adm]
    set lst_conf {}
    set lst_runt {}
    if [file exists ${admdir}/${conf}.edl] {
	wokclose -a [wokparam -e %[finfo]_Home]
	set lst_conf [join  [wokparam -e %${conf}_Config] ]
	### test cause old version of $file.edl
	if ![ catch { wokparam -e %${conf}_Runtime } toto ] {
	    set lst_runt  [join  [wokparam -e %${conf}_Runtime] ]
	} 
	exec rm -rf ${admdir}/${conf}.edl    
    } else {
	#lappend lst_conf $new_parcel
    }   
    if { $RUNTIME } {
	lappend lst_runt $new_parcel
    } else {
	lappend lst_conf $new_parcel
    }
    return [make-conf-edl $conf $lst_conf $lst_runt ]
}
#=================================================================
# MAKE-CONF-EDL (egu)
#=================================================================

proc make-conf-edl { conf lst_conf lst_runt } {
    set admdir [wokparam -e %[finfo]_Adm]
    set path ${admdir}/${conf}.edl
    if  [ catch { set fid [ open $path w ] } ] {
	return 0
    } else {
	puts $fid "@set %${conf}_Config  = \"$lst_conf\"; "
	puts $fid "@set %${conf}_Runtime = \"$lst_runt\"; "
	close $fid
	wokclose -a [wokparam -e %[finfo]_Home]
	return 1
    }
}
#=================================================================
# INSTALL-PATCH (egu)
#=================================================================

proc install-patch { ul_name patch_level src_dir dest_dir conf tab_error} {
    upvar $tab_error tab_err
    set tar ${src_dir}/${ul_name}_${patch_level}.tar.gz
    if ![catch { file exists $tar } ] {
	set MYDEL [lindex [split $ul_name "-"] 0]
	if { $MYDEL == "wok" } {
	    set MYPARCEL ${ul_name}
	} else {
	    set MYPARCEL ${MYDEL}-${conf}
	}

	#untar
	puts stdout "   - Downloading $tar in $dest_dir... "
	p-get-ptar  ${ul_name}_${patch_level} $dest_dir $tar
	
	# updating .GETPATCH file
        set getpatch_file ${dest_dir}/.${MYPARCEL}.GETPATCH
	puts stdout "   - Updating $getpatch_file file..."
	set now [string range [fmtclock [getclock]] 0 18]
	if [file exists $getpatch_file] {
	    set lf [putils:FILES:FileToList $getpatch_file]
	} else {
	    set lf {}
	}
	set s [format "%s %s %s %s" $ul_name ${ul_name}_${patch_level} $dest_dir $now]
	lappend lf $s
	putils:FILES:ListToFile $lf $getpatch_file
	
	
    } else {
	puts stderr ".... error"
	puts stderr "Nothing done : Cannot find $tar"
	set tab_err(${ul_name}_${patch_level}) "Nothing done : Cannot find $tar"
	return 0
    }
    return 1
}

#=================================================================
# P-GET-INSTALLED (egu)
#
# return list of patch'numbers already write in GETPATCH file 
# return null list if file doesn't exist
#=================================================================

proc p-get-installed { file } {
    if { ![file exists $file] } {
	return {}
    } else {
	set ll {}
	foreach l [putils:FILES:FileToList $file] {
	    lappend ll [lindex [split [lindex $l 1] _] end]
	}
	return $ll
    }
}

###==============================================================================================

proc p-get-ptar  { MYUL ULBAG tar } {

    global tcl_platform
    set savpwd [pwd]
    cd $ULBAG

    if { "$tcl_platform(platform)" == "unix" } {

	putils:EASY:tar untarZ ${tar}

    } elseif { "$tcl_platform(platform)" == "windows" } {
        set dirtmp [putils:EASY:tmpname ulget[id process]]
        catch { mkdir $dirtmp }
        putils:FILES:copy ${tar}  $dirtmp/${MYUL}.tar.gz

        if { [file exists  $dirtmp/${MYUL}.tar] } {
	    unlink $dirtmp/${MYUL}.tar
        }
        putils:FILES:uncompress $dirtmp/${MYUL}.tar.gz
        if { [file exists $dirtmp/${MYUL}.tar] } {
	    puts stderr "Info : Downloading $tar in [pwd]... "
	    putils:EASY:tar untar $dirtmp/${MYUL}.tar
        }
        unlink $dirtmp/${MYUL}.tar
        unlink -nocomplain $dirtmp
    }
    cd $savpwd
    return
}

#
# ######################################################################
#
proc putils:EASY:GETOPT { prm table tablereq usage listarg } {

    upvar $table TLOC $tablereq TRQ $prm PARAM
    catch {unset TLOC}

    set fill 0

    foreach e $listarg {
	if [regexp {^-.*} $e opt] {
	    if [info exists TRQ($opt)] {
		set TLOC($opt) {}
		set fill 1
	    } else {
		puts stderr "Error: Unknown option $e"
		eval $usage
		return -1
    }
	} else {
	    if [info exist opt] {
		set fill [regexp {value_required:(.*)} $TRQ($opt) all typ]
		if { $fill } {
		    if { $TLOC($opt) == {} } {
			set TLOC($opt) $e
			set fill 0
		    } else {
			lappend PARAM $e
		    }
		} else {
		    lappend PARAM $e
		}
	    } else {
		lappend PARAM $e
	    }
	}
    }

    foreach e [array names TLOC] {
	if { [regexp {value_required:(.*)} $TRQ($e) all typ ] == 1 } {
	    if { $TLOC($e) == {} } {
		puts "Error: Option $e requires a value"
		eval $usage
		return -1
	    }
	    switch -- $typ {

		file {
		}

		string {
		}
		
		date {
		}

		list {
		    set TLOC($e) [split $TLOC($e) ,]
		}

		number {
		    if ![ regexp {^[0-9]+$} $TLOC($e) n ] {
			puts "Error: Option $e requires a number."
			eval $usage
			return -1
		    }
		}

	    }
		
	}
    }

    return
}
#
#
#
proc putils:EASY:tar { option args } {
    
    catch { unset command return_output }
    
    switch -- $option {
	
	tarfromroot {
	    set name [lindex $args 0]
	    set root [lindex $args 1]
	    append command {tar cf } $name " " $root
	}
	
	tarfromliste {
	    set name [lindex $args 0]
	    set list [lindex $args 1]
	    if [file exists $list] {
		set liste [putils:FILES:FileToList [lindex $args 1]]
		append command  {tar cf } $name
		foreach f $liste {
#fsa
		    set listeeval [eval glob $f]
		    foreach ff $listeeval {
			append command " " $ff
		    }
#fsa		    append command " " $f
		}
	    } else {
		error "File $list not found"
		return -1
	    }
	}
	
	untar {
	    set name [lindex $args 0]
	    append command {tar xomf } $name
	}
	
	untarZ {
	    set name [lindex $args 0]
#fun	    append command uncompress { -c } $name { | tar xof - >& /dev/null }
	    append command gzip { -d -c } $name { | tar xomf - >& /dev/null }
	}


	ls {
	    set return_output 1
	    set name [lindex $args 0]
	    append command {tar tvf } $name
	}

	lsZ {
	    set return_output 1
	    set name [lindex $args 0]
#fun	    append command uncompress { -c } $name { | tar tvf - }
	    append command gzip -d { -c } $name { | tar tvf - }
	}

    }
    
    ;#puts "command = $command"
    
    if [catch {eval exec $command} status] {
	puts stderr "Tar messages in command: $command"
	puts stderr "Status          : $status"
	set statutar 1
    } else {
	if [info exist return_output] {
	    set statutar $status
	} else {
	    set statutar 1
	}
    }

    return $statutar
}
#
#
#
proc putils:FILES:ListToFile { liste path } {
    if [ catch { set id [ open $path w ] } ] {
	return 0
    } else {
	foreach e $liste {
	    puts $id $e
	}
	close $id
	return 1
    }
}
#
#
#
proc putils:FILES:FileToList { path {sort 0} {trim 0} {purge 0} {emptl 1} } {
    if ![ catch { set id [ open $path r ] } ] {
	set l  {}
	while {[gets $id line] >= 0 } {
	    if { $trim } {
		regsub -all {[ ]+} $line " " line
	    }
	    if { $emptl } {
		if { [string length ${line}] != 0 } {
		    lappend l $line
		}
	    } else {
		lappend l $line
	    }
	}
	close $id
	if { $sort } {
	    return [lsort $l]
	} else {
	    return $l
	}
    } else {
	return {}
    }
}
#
#
#
proc putils:FILES:copy { fin fout } {
    if { [catch { set in [ open $fin r ] } errin] == 0 } {
        if { [catch { set out [ open $fout w ] } errout] == 0 } {
	    set nb [copyfile $in $out]
	    close $in 
	    close $out
	    return $nb
	} else {
	    puts stderr "Error: $errout"
	    return -1
	}
    } else {
	    puts stderr "Error: $errin"
	return -1
    }
}
#
#
##
proc putils:FILES:compress { fullpath } {
    if [file exists ${fullpath}.gz] {
	catch {unlink ${fullpath}.gz}
    }
#fsa    if [catch { exec compress -f $fullpath} status] 
   if [catch { exec gzip -f $fullpath} status] {
	puts stderr "Error while compressing ${fullpath}: $status"
	return -1
    } else {
	return 1
    }
}

proc putils:FILES:uncompress { fullpath } {
#fsa    if [catch {exec uncompress -f $fullpath} status]
#fun:patch K4B_7
    if [catch {exec gzip -d -f $fullpath} status] {
	puts stderr "Error while uncompressing ${fullpath}: $status"
	return -1
    } else {
	return 1
    }
}

proc putils:EASY:tmpname { name } {
    global env
    global tcl_platform
    if { "$tcl_platform(platform)" == "unix" } {
	if [info exists env(TMPDIR)] {
	    return [file join $env(TMPDIR) $name]
	} else { 
	    return [file join "/tmp" $name]
	}
    } elseif { "$tcl_platform(platform)" == "windows" } {
	return [file join $env(TMP) $name]
    }
    return {}
}


