;#
;# Open source Tcl utilities. This contains material to automatically create
;# MS project or automake builders from the OpenCascade modules definition.
;# This file requires:
;# 1. Tcl utilities of Wok.
;# 2. Wok commands and workbench environment.
;#
;# Author: yolanda_forbes@hotmail.com
;# 
;# (((((((((((((((((((((((( MS PROJECT )))))))))))))))))))))))
;#
;# the full path of a MS project template file.
;# Should be overwritten
;#
proc osutils:vcproj:readtemplate { } {
    puts stderr "Info : readtemplate : Template for MS project from [set loc [woklocate -p WOKTclLib:source:template.vcproj]]"
    return [wokUtils:FILES:FileToString $loc]
}
proc osutils:vcproj:readtemplatex { } {
    puts stderr "Info : readtemplate : Template for MS project from [set loc [woklocate -p WOKTclLib:source:template.vcprojx]]"
    return [wokUtils:FILES:FileToString $loc]
}
proc osutils:dsp:readtemplate { } {
    puts stderr "Info : readtemplate : Template for MS project from [set loc [woklocate -p WOKTclLib:source:template.dsp ]]"
    return [wokUtils:FILES:FileToString $loc]
}
proc osutils:dsp:readtemplatex { } {
    puts stderr "Info : readtemplate : Template for MS project from [set loc [woklocate -p WOKTclLib:source:template.dspx]]"
    return [wokUtils:FILES:FileToString $loc]
}
proc osutils:mak:readtemplate { } {
    puts stderr "Info : readtemplate : Template for MS project from [set loc [woklocate -p WOKTclLib:source:template.mak ]]"
    return [wokUtils:FILES:FileToString $loc]
}
proc osutils:mak:readtemplatex { } {
    puts stderr "Info : readtemplate : Template for MS project from [set loc [woklocate -p WOKTclLib:source:template.makx]]"
    return [wokUtils:FILES:FileToString $loc]
}
proc osutils:am:readtemplate { } {
    puts stderr "Info : readtemplate : Template for Makefile.am from [set loc [woklocate -p WOKTclLib:source:template.mam]]"
    return [wokUtils:FILES:FileToString $loc]

}
proc osutils:am:readtemplatex { } {
    puts stderr "Info : readtemplatex : Template for Makefile.am from [set loc [woklocate -p WOKTclLib:source:template.mamx]]"
    return [wokUtils:FILES:FileToString $loc]

}
proc osutils:in:readtemplate { } {
    puts stderr "Info : readtemplate : Template for Makefile.in from [set loc [woklocate -p WOKTclLib:source:template.min]]"
    return [wokUtils:FILES:FileToString $loc]

}
proc osutils:in:readtemplatex { } {
    puts stderr "Info : readtemplatex : Template for Makefile.in from [set loc [woklocate -p WOKTclLib:source:template.minx]]"
    return [wokUtils:FILES:FileToString $loc]

}
;#
;# 
;#
proc osutils:dsw:header { } {
    append var \
	    "Microsoft Developer Studio Workspace File, Format Version 6.00" "\n" \
	    "# WARNING: DO NOT EDIT OR DELETE THIS WORKSPACE FILE!" "\n" \
	    "\n" \
	    "###############################################################################" "\n" \
	    "\n"
    return $var
}
proc osutils:sln:header { } {
    append var \
	    "Microsoft Visual Studio Solution File, Format Version 8.00\n" 
    return $var
}
;#
;# the leaf of a workspace file
;#
proc osutils:dsw:projectleaf { TK } {
    append var \
	    "Project: \"$TK\"=.\\$TK.dsp - Package Owner=<4>" "\n" \
	    "\n" \
	    "Package=<5>" "\n" \
	    "\{\{\{" "\n" \
	    "\}\}\}" "\n" \
	    "\n" \
	    "Package=<4>" "\n" \
	    "\{\{\{" "\n" \
	    "\}\}\}" "\n" \
	    "\n" \
	    "###############################################################################" "\n" \
	    "\n"
    return $var
}
;#
;# an item of a workspace file
;#
proc osutils:dsw:projectby2 { TK Dep_Name } {
    append var \
	    "Project: \"$TK\"=.\\$TK.dsp - Package Owner=<4>" "\n" \
	    "\n" \
	    "Package=<5>" "\n" \
	    "\{\{\{" "\n" \
	    "\}\}\}" "\n" \
	    "\n" \
	    "Package=<4>" "\n" \
	    "\{\{\{" "\n" 
            if {[wokinfo -x $TK] != "0"} {
              if {[uinfo -t $TK] == "toolkit"} {
  	         set deplist [LibToLink $TK]
  	      } else {
                 set deplist [LibToLinkX $TK $TK]
                 ;#puts $deplist
              }
	      foreach deplib $deplist {
                 if {$deplib != $TK} {
	             append var "    Begin Project Dependency" "\n" \
				"    Project_Dep_Name $deplib" "\n" \
				"    End Project Dependency" "\n" 
                 }
	      }
            }
             
	    append var "\}\}\}" "\n" \
	    "\n" \
	    "###############################################################################" "\n" \
	    "\n" 
    return $var
}
;#
;#
;#
proc osutils:dsw:footer { } {
    append var \
	    "Global:" "\n" \
	    "\n" \
	    "Package=<5>" "\n" \
	    "{{{" "\n" \
	    "}}}" "\n" \
	    "\n" \
	    "Package=<3>" "\n" \
	    "{{{" "\n" \
	    "}}}" "\n" \
	    "\n" \
	    "###############################################################################" "\n" 
    return $var
}
;#
;# An item for compiling a c++ class
;#
proc osutils:dsp:fmtcpp { } {
    return {# ADD CPP /I ..\..\inc /I ..\..\drv\%s /I ..\..\src\%s /D "__%s_DLL"}
}
proc osutils:mak:fmtcpp { } {
    return {CPP_SWITCHES=$(CPP_PROJ) /I ..\..\inc /I ..\..\drv\%s /I ..\..\src\%s /D "__%s_DLL"}
}
;#
;# An item for compiling a c++ main
;#
proc osutils:dsp:fmtcppx { } {
    return {# ADD CPP /I ..\..\inc /I ..\..\drv\%s /I ..\..\src\%s /D "__%s_DLL"}
}
proc osutils:vcproj:fmtcpp { } {
    return {AdditionalIncludeDirectories="..\..\inc,..\..\drv\%s,..\..\src\%s"
                                                        PreprocessorDefinitions="__%s_DLL;"}
}
proc osutils:vcproj:fmtcppx { } {
    return {AdditionalIncludeDirectories="..\..\inc,..\..\drv\%s,..\..\src\%s"
                                                        PreprocessorDefinitions="__%s_DLL;$(NoInherit)"}
}
proc osutils:mak:fmtcppx { } {
    return {CPP_SWITCHES=$(CPP_PROJ) /I ..\..\inc /I ..\..\drv\%s /I ..\..\src\%s /D "__%s_DLL"}
}
;#
;# List extensions of files devoted to be eaten by cl.exe compiler.
;#
proc osutils:dsp:compilable { } {
    return [list .c .cxx .cpp]
}
proc osutils:vcproj:compilable { } {
    return [list .c .cxx .cpp]
}
;#
;# remove from listloc OpenCascade units indesirables on NT
;#
proc osutils:juststation {goaway listloc} {
    set lret {}
    foreach u $listloc {
	if { 
	     (
	     	[woklocate -u $u] != ""
	     	&&
	     	[lsearch $goaway [wokinfo -n [woklocate -u $u]]] == -1
	     )
	     ||
	     (
	     	[woklocate -u $u] == ""
	     	&&
	     	[lsearch $goaway [wokinfo -n $u]] == -1
	     )
	    
	} {
	    lappend lret $u
	}
    }
    return $lret	
}

proc osutils:justwnt { listloc } {
    set goaway [list Xdps Xw ImageUtility WOKUnix]
    return [osutils:juststation $goaway $listloc]
}
;#
;# remove from listloc OpenCascade units indesirables on Unix
;#
proc osutils:justunix { listloc } {
    set goaway [list WNT WOKNT]
    return [osutils:juststation $goaway $listloc]
}
;#
;# Define libraries to link
proc LibToLink {tkit} {
    if {[uinfo -t $tkit] == "toolkit"} {
    set l {}
    set LibList [woklocate -p [wokinfo -n $tkit]:stadmfile:[wokinfo -n $tkit]_lib_tks.Out]
    if ![ catch { set id [ open $LibList r ] } status ] {
	while {[gets $id x] >= 0 } {
	    if [regexp -- {(-E[^ ]*)} $x] {
                set endnameid [expr { [string wordend $x 4] -1 }]
		set fx [string range $x 3 $endnameid]
		if {[uinfo -t [woklocate -u [file rootname $fx]]] == "toolkit"} {	
	 		lappend l $fx
		}
	    }
	    #if [regexp -- {(-VE[^ ]*)} $x] {
            #    set startid [string first CSF $x]
	    #	set endid [ expr { [string wordend $x $startid] -1 } ]
	    #	set fx [string range $x $startid $endid]
	    #	lappend l $fx
	    #}

	}
	close $id
    } else {
	puts $status
    }
    return $l
    }
}

proc LibToLinkX {tkit name} {
    if {[uinfo -t $tkit] == "executable"} {
        set l {}
	set LibList [woklocate -p [wokinfo -n $tkit]:stadmfile:[wokinfo -n $tkit]_exec_tks_${name}.Out]
        if ![ catch { set id [ open $LibList r ] } status ] {
 	  while {[gets $id x] >= 0 } {
	    if [regexp -- {(-E[^ ]*)} $x] {
		if {[regexp -- {library} $x]} {
                  set endnameid [expr { [string wordend $x 4] -1 }]
                  set fx [string range $x 3 $endnameid]
		  lappend l $fx
                }
	    }
	    #if [regexp -- {(-VE[^ ]*)} $x] {
            #    set startid [string first CSF $x]
	    #	set endid [ expr { [string wordend $x $startid] -1 } ]
	    #	set CSF_fx [string range $x $startid $endid]
            #    if { $CSF_fx != "-"} {
	    #	  puts $CSF_fx
	    #	  set fx [file tail [lindex [wokparam -v \%$CSF_fx $tkit] 0]]
	    #	  lappend l $fx
	    #	}
	    #}

	 }
	 close $id
       } else {
	 puts $status
       }
       return $l
    }
}


;#
;#      ((((((((WOK toolkits manipulations))))))))
;#
;#  close dependencies of ltk. (full wok pathes of toolkits)
;# The CURRENT WOK LOCATION MUST contains ALL TOOLKITS required. 
;# (locate not performed.)
proc osutils:tk:close { ltk } {
    set result {}
    set recurse {}
    foreach dir $ltk {
	#set ids [woklocate -p [wokinfo -n [wokinfo -u $dir]]:source:EXTERNLIB [wokinfo -w $dir]]
        set ids [LibToLink $dir]
	set eated [osutils:tk:eatpk $ids]
	set result [concat $result $eated]
        set ids [LibToLink $dir]
	set result [concat $result $ids]
	#puts "EXTERNLIB dir = $dir ids = $ids result = $result eated = $eated"
	foreach file $eated {
	    set kds [woklocate -p [wokinfo -n [wokinfo -u $file]]:source:EXTERNLIB [wokinfo -w $file]]
	    if { [osutils:tk:eatpk $kds] !=  {} } {
		lappend recurse $file
	    }
	}
    }
    ;#    if ![lempty $recurse] {
	;#	set result [concat $result [osutils:tk:close $recurse]]
	;#    }
	if { $recurse != {} } {
	    set result [concat $result [osutils:tk:close $recurse]]
	}
    #puts $result
    return $result
}
;#
;# Topological sort of toolkits in tklm
;#
proc osutils:tk:sort { tklm } {
    set tkby2 {}
    foreach tkloc $tklm {
	set lprg [wokUtils:LIST:Purge [osutils:tk:close [woklocate -u $tkloc]]]
	foreach tkx  $lprg {
	    if { [lsearch $tklm $tkx] != -1 } {
		lappend tkby2 [list $tkx $tkloc]
	    } else {
		lappend tkby2 [list $tkloc {}]
	    }
	}
    }
    set lret {}
    foreach e [wokUtils:EASY:tsort $tkby2] {
	if { $e != {} } {
	    lappend lret $e
	}
    }
    return $lret
}

;#
;# Returns liste of UD in a toolkit. tkloc is a full path wok.
;# 
proc osutils:tk:units { tkloc {typed 0} } {
    set l {}
    set PACKAGES [woklocate -p [wokinfo -n [wokinfo -u $tkloc]]:source:PACKAGES [wokinfo -w $tkloc]]
    foreach u [wokUtils:FILES:FileToList $PACKAGES] {
	set fu [woklocate -u $u]
	if { [set fu [woklocate -u $u]] != {} } {
	    if { $typed == 0 } {
		lappend l $fu
	    } 
	    if { $typed == 1 } {
		lappend l [list [uinfo -c $fu] [wokinfo -n $fu]]
	    }
	    if { $typed == 2 } {
		lappend l [list [uinfo -c $fu] $fu]
	    }
	    if { $typed == 3 } {
		lappend l [list [uinfo -t $fu] [wokinfo -n $fu]]
	    }
	    if { $typed == 4 } {
		lappend l [list [uinfo -t $fu] $fu]
	    }
	} else {
	    puts stderr "Unit inconnue $u"
	}
    }
    if { $l == {} } {
	;#puts stderr "Warning. No devunit included in $tkloc"
    }
    return $l
}
;#
;# for a unit returns a map containing all its file in the current
;# workbench
;# local = 1 only local files
;#
proc osutils:tk:loadunit { loc map {local 0}} {
    upvar $map TLOC
    catch { unset TLOC }
    if { $local == 1 } {
	set lfiles [uinfo -Fpl $loc]
    } else {
	set lfiles [uinfo -Fp $loc]
    }
    foreach f $lfiles { 
	#puts $f
	set t [lindex $f 0]
	set p [lindex $f 2]
	if [info exists TLOC($t)] {
	    set l $TLOC($t)
	    lappend l $p
	    set TLOC($t) $l
	} else {
	    set TLOC($t) $p
	}
    }
    return
}
;#
;# Returns the list of all compilable files name in a toolkit, or devunit of any type
;# Call unit filter on units name to accept or reject a unit
;# Tfiles lists for each unit the type of file that can be compiled.
;#
proc osutils:tk:files { tkloc  {l_compilable {} } {justail 1} {unitfilter {}} } {
    set Tfiles(source,package)       {source derivated privinclude pubinclude drvfile}
    set Tfiles(source,nocdlpack)     {source pubinclude drvfile}
    set Tfiles(source,schema)        {source derivated privinclude pubinclude drvfile}
    set Tfiles(source,toolkit)       {}
    set Tfiles(source,executable)    {source pubinclude drvfile}
    set listloc [concat [osutils:tk:units [woklocate -u $tkloc]] [woklocate -u $tkloc]]
    #puts " listloc = $listloc"
    if { $l_compilable == {} } {
	set l_comp [list .c .cxx .cpp]
    } else {
	set l_comp [$l_compilable]
    }
    if { $unitfilter == {} } {
	set resultloc $listloc
    } else {
	set resultloc [$unitfilter $listloc]
    }
    set lret {}
    foreach loc $resultloc {
	set utyp [uinfo -t $loc]
	if [array exists map] { unset map }		
	osutils:tk:loadunit $loc map
	#puts " loc = $loc === > [array names map]"
	set LType $Tfiles(source,${utyp})
	foreach typ [array names map] {
	    if { [lsearch $LType $typ] == -1 } {
		unset map($typ)
	    }
	}
	foreach type [array names map] {
	    #puts $type
	    foreach f $map($type) {
		#puts $f
		if { [lsearch $l_comp [file extension $f]] != -1 } {
		    if { $justail == 1 } {
			if {$type == "source"} {
			    if {[lsearch $lret "@top_srcdir@/drv/[wokinfo -n $loc]/[file tail $f]"] == -1} {
				lappend lret @top_srcdir@/src/[wokinfo -n $loc]/[file tail $f]
			    }
			    } elseif {$type == "derivated" || $type == "drvfile"} {
				if {[lsearch $lret "@top_srcdir@/src/[wokinfo -n $loc]/[file tail $f]"] == -1} {
				    lappend lret @top_srcdir@/drv/[wokinfo -n $loc]/[file tail $f]
			    }
			}
		    } else {
			lappend lret $f
		    }
		}
	    }
	}
    }
    return $lret
}
;#
;# 
;#
proc osutils:tk:eatpk { EXTERNLIB  } {
    set l [wokUtils:FILES:FileToList $EXTERNLIB]
    set lret  {}
    foreach str $l {
	 if ![regexp -- {(CSF_[^ ]*)} $str csf] {
	     lappend lret $str
	 }
    }
    return $lret
}
;#
;# Return the list of name *CSF_ in a EXTERNLIB description of a toolkit
;#
proc osutils:tk:hascsf { EXTERNLIB } {
    set l [wokUtils:FILES:FileToList $EXTERNLIB]
    set lret  {STLPort}
    foreach str $l {
	 if [regexp -- {(CSF_[^ ]*)} $str csf] {
	     lappend lret $csf
	 }
    }
    return $lret
}
;#
;# Create file tkloc.dsp for a shareable library (dll).
;# in dir return the full path of the created file
;#
proc osutils:mkdsp { dir tkloc {tmplat {} } {fmtcpp {} } } {
    if { $tmplat == {} } {set tmplat [osutils:dsp:readtemplate]}
    if { $fmtcpp == {} } {set fmtcpp [osutils:dsp:fmtcpp]}
    set fp [open [set fdsp [file join $dir ${tkloc}.dsp]] w]
    fconfigure $fp -translation crlf
    set l_compilable [osutils:dsp:compilable]
    regsub -all -- {__TKNAM__} $tmplat $tkloc  temp0
    set tkused ""
    foreach tkx [wokUtils:LIST:Purge [osutils:tk:close [woklocate -u $tkloc]]] {
	append tkused "${tkx}.lib "
    }
    foreach tk [lappend [wokUtils:LIST:Purge [osutils:tk:close [woklocate -u $tkloc]]] $tkloc] {
	foreach element [osutils:tk:hascsf [woklocate -p ${tk}:source:EXTERNLIB [wokcd]]] {
	    if {[wokparam -t %$element] != 0} {
		set felem [file tail [lindex [wokparam -v "%$element"] 0]]
	      if {[lsearch $tkused $felem] == "-1"} {
		if {$felem != "\{\}"} {
		    set tkused [concat $tkused $felem]
		}
	     }   
	   }
	}
    }

    #puts "alternative [LibToLink $tkloc]"
    puts "$tkloc requires  $tkused"
    regsub -all -- {__TKDEP__} $temp0  $tkused temp1
    set files ""
    ;#set listloc [concat [osutils:tk:units [woklocate -u $tkloc]] [woklocate -u $tkloc]]
    set listloc [osutils:tk:units [woklocate -u $tkloc]]
    set resultloc [osutils:justwnt $listloc]
    ;#puts "result = $resultloc"
    ;#set lsrc   [lsort [osutils:tk:files $tkloc osutils:am:compilable 1 osutils:justwnt]]
    if [array exists written] { unset written }
    foreach fxlo $resultloc {
        set xlo [wokinfo -n $fxlo]
	append files "# Begin Group \"${xlo}\"" "\n"        
	set lsrc   [osutils:tk:files $xlo osutils:am:compilable 0]
	set fxloparam [lindex [intersect3 [split [lindex [wokparam -v %CMPLRS_CXX_Options] 0]] [split [lindex [wokparam -v %CMPLRS_CXX_Options $fxlo] 0]] ] 2]
        set fxloparam "$fxloparam [lindex [intersect3 [split [lindex [wokparam -v %CMPLRS_C_Options] 0]] [split [lindex [wokparam -v %CMPLRS_C_Options $fxlo] 0]] ] 2]"
        set needparam ""
        foreach partopt $fxloparam {
	    if { "-I[lindex [wokparam -v %CSF_TCL_INCLUDE] 0]" != "$partopt "} {
		if { "-I[lindex [wokparam -v %CSF_JAVA_INCLUDE] 0]" != "$partopt "} {
		  set needparam "$needparam $partopt"
                }
	    }
        }
        foreach f $lsrc {
	    ;#puts " f = $f"
	    if { ![info exists written([file tail $f])] } {
		set written([file tail $f]) 1
		append files "# Begin Source File" "\n"
		append files "SOURCE=..\\..\\" [wokUtils:EASY:bs1 [wokUtils:FILES:wtail $f 3]] "\n"
		append files [format $fmtcpp $xlo $xlo $xlo] "$needparam" "\n"
		append files "# End Source File" "\n"
	    } else {
		puts "Warning : in dsp more than one occurences for [file tail $f]"
	    }
	}
    append files "# End Group" "\n"
    }
    
    regsub -all -- {__FILES__} $temp1 $files temp2
    puts $fp $temp2
    close $fp
    return $fdsp
}
proc osutils:vcproj { dir tkloc {tmplat {} } {fmtcpp {} } } {
   if { $tmplat == {} } {set tmplat [osutils:vcproj:readtemplate]}
    if { $fmtcpp == {} } {set fmtcpp [osutils:vcproj:fmtcpp]}
    set fp [open [set fvcproj [file join $dir ${tkloc}.vcproj]] w]
    fconfigure $fp -translation crlf
    set l_compilable [osutils:dsp:compilable]
    regsub -all -- {__TKNAM__} $tmplat $tkloc  temp0
    set tkused ""
    foreach tkx [wokUtils:LIST:Purge [osutils:tk:close [woklocate -u $tkloc]]] {
	append tkused "${tkx}.lib "
    }
    foreach tk [lappend [wokUtils:LIST:Purge [osutils:tk:close [woklocate -u $tkloc]]] $tkloc] {
	foreach element [osutils:tk:hascsf [woklocate -p ${tk}:source:EXTERNLIB [wokcd]]] {
	    if {[wokparam -t %$element] != 0} {
		set felem [file tail [lindex [wokparam -v "%$element"] 0]]
	      if {[lsearch $tkused $felem] == "-1"} {
		if {$felem != "\{\}"} {
		    set tkused [concat $tkused $felem]
		}
	     }   
	   }
	}
    }

    puts "$tkloc requires  $tkused"
    regsub -all -- {__TKDEP__} $temp0  $tkused temp1
    set files ""
    set listloc [osutils:tk:units [woklocate -u $tkloc]]
    set resultloc [osutils:justwnt $listloc]
    if [array exists written] { unset written }
    foreach fxlo $resultloc {
        set xlo [wokinfo -n $fxlo]        
	append files "        <Filter\n"
        append files "                                Name=\"${xlo}\"\n"
        append files "                                Filter=\"\">\n"
        set lsrc   [osutils:tk:files $xlo osutils:am:compilable 0]
	set fxloparam [lindex [intersect3 [split [lindex [wokparam -v %CMPLRS_CXX_Options] 0]] [split [lindex [wokparam -v %CMPLRS_CXX_Options $fxlo] 0]] ] 2]
        set fxloparam "$fxloparam [lindex [intersect3 [split [lindex [wokparam -v %CMPLRS_C_Options] 0]] [split [lindex [wokparam -v %CMPLRS_C_Options $fxlo] 0]] ] 2]"
        set needparam ""
        foreach partopt $fxloparam {
	    if { "-I[lindex [wokparam -v %CSF_TCL_INCLUDE] 0]" != "$partopt "} {
		if { "-I[lindex [wokparam -v %CSF_JAVA_INCLUDE] 0]" != "$partopt "} {
        	  set needparam "$needparam $partopt"
                }
	    }
        }
        foreach f $lsrc {
	    #puts " f = $f"
	    if { ![info exists written([file tail $f])] } {
		set written([file tail $f]) 1
		append files "\t\t\t\t<File\n"
		append files "\t\t\t\t\tRelativePath=\"..\\..\\[wokUtils:EASY:bs1 [wokUtils:FILES:wtail $f 3]]\">\n"
                append files "\t\t\t\t\t<FileConfiguration\n"
                append files "\t\t\t\t\t\tName=\"Debug\|Win32\">\n"
                append files "\t\t\t\t\t\t<Tool\n"
                append files "\t\t\t\t\t\t\tName=\"VCCLCompilerTool\"\n"
                if {$needparam != ""} {
                  append files "\t\t\t\t\t\t\tAdditionalOptions=\""
                  foreach paramm $needparam {
                     append files "$paramm "
                  }
                  append files "\"\n"
                }
                append files "\t\t\t\t\t\t\tOptimization=\"0\"\n"
		append files "\t\t\t\t\t\t\t[format $fmtcpp $xlo $xlo $xlo]\n"
                append files "\t\t\t\t\t\t\tCompileAs=\"0\"/>\n"
                append files "\t\t\t\t\t</FileConfiguration>\n"
                append files "\t\t\t\t\t<FileConfiguration\n"
                append files "\t\t\t\t\t\tName=\"Release\|Win32\">\n"
                append files "\t\t\t\t\t\t<Tool\n"
                append files "\t\t\t\t\t\t\tName=\"VCCLCompilerTool\"\n"
                if {$needparam != ""} {
                  append files "\t\t\t\t\t\t\tAdditionalOptions=\""
                  foreach paramm $needparam {
                     append files "$paramm "
                  }
                  append files "\"\n"
                }
                append files "\t\t\t\t\t\t\tOptimization=\"2\"\n"
		append files "\t\t\t\t\t\t\t[format $fmtcpp $xlo $xlo $xlo]\n"
                append files "\t\t\t\t\t\t\tCompileAs=\"0\"/>\n"
                append files "\t\t\t\t\t</FileConfiguration>\n"
		append files "\t\t\t\t</File>\n"
	    } else {
		puts "Warning : in vcproj more than one occurences for [file tail $f]"
	    }
	}
    append files "\t\t\t</Filter>"
    }
    
    regsub -all -- {__FILES__} $temp1 $files temp2
    puts $fp $temp2
    close $fp
    return $fvcproj
}
;#
;# Create file tkloc.dsp for a executable "console" application
;# in dir return the full path of the created file
;#
proc osutils:mkdspx { dir tkloc {tmplat {} } {fmtcpp {} } } {
    if { $tmplat == {} } {set tmplat [osutils:dsp:readtemplatex]}
    if { $fmtcpp == {} } {set fmtcpp [osutils:dsp:fmtcppx]}
    foreach f [osutils:tk:files $tkloc osutils:am:compilable 0] {
        set tf [file rootname [file tail $f]]   
        set fp [open [set fdsp [file join $dir ${tf}.dsp]] w]
        puts $fdsp
        fconfigure $fp -translation crlf
        set l_compilable [osutils:dsp:compilable]
        regsub -all -- {__XQTNAM__} $tmplat $tf  temp0
        set tkused ""
        puts [LibToLinkX [woklocate -u $tkloc] $tf]
        foreach tkx [LibToLinkX [woklocate -u $tkloc] $tf] {
	  if {[uinfo -t [woklocate -u $tkx]] == "toolkit"} {
	    append tkused "${tkx}.lib "
	  }
#          if {[lsearch [w_info -l] [woklocate -u $tkx]] == "-1"} {
#	    append tkused "${tkx}.lib "
#	  }
	  if {[woklocate -u $tkx] == "" } {
	      append tkused "${tkx}.lib "
	  }
        }
        foreach tk [LibToLinkX [woklocate -u $tkloc] $tf] {
	    foreach element [osutils:tk:hascsf [woklocate -p ${tk}:source:EXTERNLIB [wokinfo -N [woklocate -u $tk]]]] {
	    if {[wokparam -t %$element] != 0} {
              set elemlist [wokparam -v "%$element"]
	      set felem [file tail [lindex $elemlist 0]] 
	      if {[lsearch $tkused $felem] == "-1"} {
		if {$felem != "\{\}"} {
                    #puts "was found $element $felem"	   
		    set tkused [concat $tkused $felem]
		}
	      }   
	    }
	 }
       }
       if {[wokparam -v %WOKSteps_exec_link [woklocate -u $tkloc]] == "#WOKStep_DLLink(exec.tks)"} { 
           set tkused [concat $tkused "\/dll"]
       }
       regsub -all -- {__COMPOPT__} $temp0 "\/MD" temp1 
       regsub -all -- {__COMPOPTD__} $temp1 "\/MDd" temp2 
       puts "$tf requires  $tkused"
       regsub -all -- {__TKDEP__} $temp2  $tkused temp3
       set files ""
       ;#set lsrc   [osutils:tk:files $tkloc osutils:am:compilable 0]
       ;#foreach f $lsrc {
	if { ![info exists written([file tail $f])] } {
	    set written([file tail $f]) 1
            append files "# Begin Group \"" $tkloc "\" \n"
	    append files "# Begin Source File" "\n"
	    append files "SOURCE=..\\..\\" [wokUtils:EASY:bs1 [wokUtils:FILES:wtail $f 3]] "\n"
	    append files [format $fmtcpp $tkloc $tkloc $tkloc] "\n"
	    append files "# End Source File" "\n"
            append files "# End Group" "\n"
	} else {
	    puts "Warning : in dsp more than one occurences for [file tail $f]"
	}
	;#}
    
   regsub -all -- {__FILES__} $temp3 $files temp4
    puts $fp $temp4
    close $fp
	set fout [lappend fout $fdsp]
    }
    return $fout
}
proc osutils:vcprojx { dir tkloc {tmplat {} } {fmtcpp {} } } {
    if { $tmplat == {} } {set tmplat [osutils:vcproj:readtemplatex]}
    if { $fmtcpp == {} } {set fmtcpp [osutils:vcproj:fmtcppx]}
    set fout {}
    foreach f [osutils:tk:files $tkloc osutils:am:compilable 0] {
        puts "1"
        set tf [file rootname [file tail $f]]   
        set l_compilable [osutils:dsp:compilable]
        regsub -all -- {__XQTNAM__} $tmplat $tf  temp0
        set tkused ""
        foreach tkx [LibToLinkX [woklocate -u $tkloc] $tf] {
	  if {[uinfo -t [woklocate -u $tkx]] == "toolkit"} {
	    append tkused "${tkx}.lib "
	  }
          if {[lsearch [w_info -l] $tkx] == "-1"} {
	    append tkused "${tkx}.lib "
	  }
        }
       foreach tk [LibToLinkX [woklocate -u $tkloc] $tf] {
	  foreach element [osutils:tk:hascsf [woklocate -p ${tk}:source:EXTERNLIB [wokcd]]]  {
	    if {[wokparam -t %$element] != 0} {
                set elemlist [wokparam -v "%$element"]
		set felem [file tail [lindex $elemlist 0]] 
	      if {[lsearch $tkused $felem] == "-1"} {
		if {$felem != "\{\}"} {
                    #puts "was found $element $felem"	   
		    set tkused [concat $tkused $felem]
		}
	      }   
	    }
	 }
       }
       if {[wokparam -v %WOKSteps_exec_link [woklocate -u $tkloc]] == "#WOKStep_DLLink(exec.tks)"} { 
           set tkused [concat $tkused "\/dll"]
           set binext 2
       } else {
           set binext 1
       }
       #puts "$tf requires  $tkused"
       regsub -all -- {__TKDEP__} $temp0  $tkused temp3
       set files ""
       ;#set lsrc   [osutils:tk:files $tkloc osutils:am:compilable 0]
       ;#foreach f $lsrc {
	if { ![info exists written([file tail $f])] } {
	    set written([file tail $f]) 1
            append files "\t\t\t<Filter\n"
            append files "\t\t\t\tName=\"$tkloc\"\n"
	    append files "\t\t\t\tFilter=\"\">\n"
            append files "\t\t\t\t<File\n"
	    append files "\t\t\t\t\tRelativePath=\"..\\..\\[wokUtils:EASY:bs1 [wokUtils:FILES:wtail $f 3]]\">\n"
            append files "\t\t\t\t\t<FileConfiguration\n"
            append files "\t\t\t\t\t\tName=\"Debug|Win32\">\n"
            append files "\t\t\t\t\t\t<Tool\n"
            append files "\t\t\t\t\t\t\tName=\"VCCLCompilerTool\"\n"
            append files "\t\t\t\t\t\t\tOptimization=\"0\"\n"
            append files "\t\t\t\t\t\t\t[format $fmtcpp $tkloc $tkloc $tkloc] \n"
	    append files "\t\t\t\t\t\t\tBasicRuntimeChecks=\"3\"\n"
            append files "\t\t\t\t\t\t\tCompileAs=\"0\"/>\n"
            append files "\t\t\t\t\t</FileConfiguration>\n"
            append files "\t\t\t\t\t<FileConfiguration\n"
            append files "\t\t\t\t\t\tName=\"Release|Win32\">\n"
            append files "\t\t\t\t\t\t<Tool\n"
            append files "\t\t\t\t\t\t\tName=\"VCCLCompilerTool\"\n"
            append files "\t\t\t\t\t\t\tOptimization=\"2\"\n"
            append files "\t\t\t\t\t\t\t[format $fmtcpp $tkloc $tkloc $tkloc] \n"
            append files "\t\t\t\t\t\t\tCompileAs=\"0\"/>\n"
            append files "\t\t\t\t\t</FileConfiguration>\n"
            append files "\t\t\t\t</File>\n"
            append files "\t\t\t</Filter>\n"
	} else {
	    puts "Warning : in dsp more than one occurences for [file tail $f]"
	}
	;#}
    #puts "$temp3 $files"
    regsub -all -- {__FILES__} $temp3 $files temp4
    regsub -all -- {__CONF__} $temp4 $binext temp5
    set fp [open [set fdsp [file join $dir ${tf}.vcproj]] w]
    fconfigure $fp -translation crlf
 
    puts $fp $temp5
    set fout [lappend fout $fdsp]
    close $fp
   }
   return $fout
}

;#
;# Create file tkloc.mak for a shareable library (dll).
;# in dir return the full path of the created file
;#
proc osutils:mkmak { dir tkloc {tmplat {} } {fmtcpp {} } } {
    puts $tkloc
    if { $tmplat == {} } {set tmplat [osutils:mak:readtemplate]}
    if { $fmtcpp == {} } {set fmtcpp [osutils:mak:fmtcpp]}
    set fp [open [set fdsp [file join $dir ${tkloc}.mak]] w]
    fconfigure $fp -translation crlf
    set l_compilable [osutils:dsp:compilable]
    set tkused [wokUtils:LIST:Purge [osutils:tk:close [woklocate -u $tkloc]]]
    set listloc [osutils:tk:units [woklocate -u $tkloc]]
    set resultloc [osutils:justwnt $listloc]
    regsub -all -- {__TKNAM__} $tmplat $tkloc  temp0
    set area1 ""
    append area1 "\!IF \"\$(RECURSE)\" == \"0\" \n"
    append area1 "ALL : \"\$(OUTDIR)\\${tkloc}.dll\"\n"
    append area1 "\!ELSE\n"
    append area1 "ALL : "
    if {$tkused != ""} {
      foreach tkproj $tkused {
        append area1 "\"$tkproj - Win32 Release\" " 
      }
    }
    append area1 " \"\$(OUTDIR)\\$tkloc.dll\"\n"
    append area1 "\!ENDIF \n"
    append area1 "\!IF \"\$(RECURSE)\" == \"1\"\n" 
    append area1 "CLEAN :"
    if {$tkused != ""} {
      foreach tkproj $tkused {
        append area1 "\"$tkproj - Win32 ReleaseCLEAN\" " 
      }
    }
    append area1 "\n" 
    append area1 "\!ELSE\n" 
    append area1 "CLEAN :\n"
    append area1 "\!ENDIF\n"
    set tclused 0
    set javaused 0
    if [array exists written] { unset written }
    foreach fxlo $resultloc {
      set xlo [wokinfo -n $fxlo]
      set lsrc   [osutils:tk:files $xlo osutils:am:compilable 0]
      set fxlocxxparam [lindex [intersect3 [split [lindex [wokparam -v %CMPLRS_CXX_Options] 0]] [split [lindex [wokparam -v %CMPLRS_CXX_Options $fxlo] 0]] ] 2]
      set fxlocparam [lindex [intersect3 [split [lindex [wokparam -v %CMPLRS_C_Options] 0]] [split [lindex [wokparam -v %CMPLRS_C_Options $fxlo] 0]] ] 2]
      if {[lsearch [lindex [wokparam -v %CMPLRS_CXX_Options $fxlo] 0] "-I[lrange [lindex [wokparam -v %CSF_TCL_INCLUDE] 0] 0 end]"] != -1} {
        set tclused 1
      }
      if {[lsearch [lindex [wokparam -v %CMPLRS_CXX_Options $fxlo] 0] "-I[lrange [lindex [wokparam -v %CSF_JavaHome]/include 0] 0 end]"] != -1} {
       set javaused 1
      }
      if {[lsearch [lindex [wokparam -v %CMPLRS_C_Options $fxlo] 0] "-I[lrange [lindex [wokparam -v %CSF_TCL_INCLUDE] 0] 0 end]"] != -1} {
         set tclused 1
      }
      if {[lsearch [lindex [wokparam -v %CMPLRS_C_Options $fxlo] 0] "-I[lrange [lindex [wokparam -v %CSF_JavaHome]/include 0] 0 end]"] != -1} {
         set javaused 1
      }

      foreach srcfile $lsrc {
        if { ![info exists written([file tail $srcfile])] } {
	  set written([file tail $srcfile]) 1
	  append area1 "\t-@erase \"\$(INTDIR)\\[wokUtils:EASY:bs1 [file root [wokUtils:FILES:wtail $srcfile 1]]].obj\"\n"
        }
      }
    } 
    regsub -all -- {__FIELD1__} $temp0 $area1  temp1

    set area2 "LINK32_FLAGS=-nologo -subsystem:windows -dll -incremental:no -machine:IX86 -libpath:\"\$(LIBDIR)\" -implib:\$(LIBDIR)\\$tkloc.lib -out:\$(OUTDIR)\\$tkloc.dll "
    set libused ""
    foreach tkx [wokUtils:LIST:Purge [osutils:tk:close [woklocate -u $tkloc]]] {
	append libused "${tkx}.lib "
    }
    set ltk [wokUtils:LIST:Purge [osutils:tk:close [woklocate -u $tkloc]]]
    set ltk [lappend ltk $tkloc]
    foreach tk $ltk {
        foreach element [osutils:tk:hascsf [woklocate -p $tk:source:EXTERNLIB [wokcd]]] {
	    if {[wokparam -t %$element] != 0} {
	      set felem [file tail [lindex [wokparam -v "%$element"] 0]]
	      if {[lsearch $libused $felem] == "-1"} {
		if {$felem != "\{\}"} {
		    set libused [concat $libused $felem]
		}
	     }   
	   }
	}
    }
    if {$tclused == 1} {
      append area2 "-libpath:\"\$(TCLHOME)\\lib\" "
    }
    
    foreach tk $libused {
      append area2 "$tk "
    }
    append area2 "\n"
    append area2 "LINK32_OBJS= \\\n"
    if [array exists written] { unset written }
    foreach fxlo $resultloc {
        set xlo [wokinfo -n $fxlo]
        set lsrc   [osutils:tk:files $xlo osutils:am:compilable 0]
        foreach srcfile $lsrc {
          if { ![info exists written([file tail $srcfile])] } {
  	    set written([file tail $srcfile]) 1
	    append area2 "\t\"\$(INTDIR)\\[wokUtils:EASY:bs1 [file root [wokUtils:FILES:wtail $srcfile 1]]].obj\" \\\n"
          }
        }
    } 
 
    regsub -all -- {__FIELD2__} $temp1 $area2  temp2
	
    set area3 ""
    append area3 "\!IF \"\$(RECURSE)\" == \"0\" \n"
    append area3 "ALL : \"\$(OUTDIR)\\${tkloc}.dll\"\n"
    append area3 "\!ELSE\n"
    append area3 "ALL : "
    if {$tkused != ""} {
      foreach tkproj $tkused {
        append area3 "\"$tkproj - Win32 Debug\" " 
      }
    }
    append area3 " \"\$(OUTDIR)\\$tkloc.dll\"\n"
    append area3 "\!ENDIF \n"
    append area3 "\!IF \"\$(RECURSE)\" == \"1\"\n" 
    append area3 "CLEAN :"
    if {$tkused != ""} {
      foreach tkproj $tkused {
        append area3 "\"$tkproj - Win32 DebugCLEAN\"" 
      }
    }
    append area3 "\n" 
    append area3 "\!ELSE\n" 
    append area3 "CLEAN :\n"
    append area3 "\!ENDIF\n"
    if [array exists written] { unset written }
 
   foreach fxlo $resultloc {
      set xlo [wokinfo -n $fxlo]
      set lsrc   [osutils:tk:files $xlo osutils:am:compilable 0]

      foreach srcfile $lsrc {
        if { ![info exists written([file tail $srcfile])] } {
	  set written([file tail $srcfile]) 1
	  append area3 "\t-@erase \"\$(INTDIR)\\[wokUtils:EASY:bs1 [file root [wokUtils:FILES:wtail $srcfile 1]]].obj\"\n"
        }
      }
    } 
    regsub -all -- {__FIELD3__} $temp2 $area3  temp3

    set area4 "LINK32_FLAGS=-nologo -subsystem:windows -dll -incremental:no -machine:IX86 -debug -libpath:\"\$(LIBDIR)\"  -implib:\$(LIBDIR)\\$tkloc.lib -out:\$(OUTDIR)\\$tkloc.dll -pdb:\$(OUTDIR)\\$tkloc.pdb "
    foreach tk $libused {
      append area4 "$tk "
    }
    if {$tclused == 1} {
      append area4 "-libpath:\"\$(TCLHOME)\\lib\" "
    }

    append area4 "\n"
    append area4 "LINK32_OBJS= \\\n"
    if [array exists written] { unset written }
    foreach fxlo $resultloc {
        set xlo [wokinfo -n $fxlo]
        set lsrc   [osutils:tk:files $xlo osutils:am:compilable 0]
        foreach srcfile $lsrc {
          if { ![info exists written([file tail $srcfile])] } {
  	    set written([file tail $srcfile]) 1
	    append area4 "\t\"\$(INTDIR)\\[wokUtils:EASY:bs1 [file root [wokUtils:FILES:wtail $srcfile 1]]].obj\" \\\n"
          }
        }
    } 
 
    regsub -all -- {__FIELD4__} $temp3 $area4  temp4

    set area5 ""
    if [array exists written] { unset written }
    foreach fxlo $resultloc {
      set xlo [wokinfo -n $fxlo]
      set lsrc   [osutils:tk:files $xlo osutils:am:compilable 0]
      set fxlocxxparam [lindex [intersect3 [split [lindex [wokparam -v %CMPLRS_CXX_Options] 0]] [split [lindex [wokparam -v %CMPLRS_CXX_Options $fxlo] 0]] ] 2]
      set fxlocparam [lindex [intersect3 [split [lindex [wokparam -v %CMPLRS_C_Options] 0]] [split [lindex [wokparam -v %CMPLRS_C_Options $fxlo] 0]] ] 2]
      if {$tclused == 1} {
        set fxlocxxparam "-I\$(TCLHOME)\\include"
      }
      if {$javaused == 1} {
         set fxlocxxparam "-I\$(JAVAHOME)\\include -I\$(JAVAHOME)\\include\\win32"
      }
      set fxloparam "$fxlocparam $fxlocxxparam"
      #puts $fxloparam
      foreach srcfile $lsrc {
        if { ![info exists written([file tail $srcfile])] } {
	  set written([file tail $srcfile]) 1
          set pkname [wokUtils:EASY:bs1 [file root [wokUtils:FILES:wtail $srcfile 1]]]
          
	  append area5 "SOURCE=..\\..\\[wokUtils:EASY:bs1 [wokUtils:FILES:wtail $srcfile 3]]\n"
          append area5 "\!IF  \"\$(CFG)\" == \"$tkloc - Win32 Release\"\n"
	  append area5 "CPP_SWITCHES=\/nologo \/MD \/W3 \/GX \/O2 $fxloparam \/I \"..\\..\\inc\" \/I \"..\\..\\drv\\$xlo\" \/I \"..\\..\\src\\$xlo\" \/D \"WIN32\" \/D \"NDEBUG\" \/D \"_WINDOWS\" \/D \"WNT\" \/D \"No_Exception\" \/D \"__${xlo}_DLL\" \/Fo\"\$(INTDIR)\\\\\\\" \/Fd\"\$(INTDIR)\\\\\\\" \/FD \/D \"CSFDB\" \/c\n"
          append area5 "\"\$(INTDIR)\\$pkname.obj\" : \$(SOURCE) \"\$(INTDIR)\"\n"
          append area5 "\t\t\$(CPP) \$(CPP_SWITCHES) \$(SOURCE)\n"
          append area5 "\n"
          append area5 "\!ELSEIF  \"\$(CFG)\" == \"$tkloc - Win32 Debug\"\n"
	  append area5 "CPP_SWITCHES=\/nologo \/MDd \/W3 \/GX \/Zi \/Od $fxloparam \/I \"..\\..\\inc\" \/I \"..\\..\\drv\\$xlo\" \/I \"..\\..\\src\\$xlo\" \/D \"WIN32\" \/D \"DEB\" \/D \"_DEBUG\" \/D \"_WINDOWS\" \/D \"WNT\" \/D \"CSFDB\" \/D \"__${xlo}_DLL\" \/Fo\"\$(INTDIR)\\\\\\\" \/Fd\"\$(INTDIR)\\\\\\\" \/FD \/c \n"
          append area5 "\"\$(INTDIR)\\$pkname.obj\" : \$(SOURCE) \"\$(INTDIR)\"\n"
          append area5 "\t\t\$(CPP) \$(CPP_SWITCHES) \$(SOURCE)\n"
          append area5 "\n"
          append area5 "\!ENDIF \n"
        }
      }
    } 
    regsub -all -- {__FIELD5__} $temp4 $area5  temp5

    set area6 ""
    foreach tk $tkused {
      append area6 "\!IF  \"\$(CFG)\" == \"$tkloc - Win32 Release\"\n"
      append area6 "\"$tk - Win32 Release\" \: \n"
      append area6 "   \$(MAKE) \/NOLOGO \/\$(MAKEFLAGS) \/F .\\$tk.mak CFG=\"$tk - Win32 Release\" \n"
      append area6 "\"$tk - Win32 ReleaseCLEAN\" \: \n"
      append area6 "   \$(MAKE)\/NOLOGO  \/\$(MAKEFLAGS) \/F .\\$tk.mak CFG=\"$tk - Win32 Release\" RECURSE=1 CLEAN\n"
      append area6 "\!ELSEIF  \"\$(CFG)\" == \"$tkloc - Win32 Debug\"\n"
      append area6 "\"$tk - Win32 Debug\" \: \n"
      append area6 "   \$(MAKE) \/NOLOGO \/\$(MAKEFLAGS) \/F .\\$tk.mak CFG=\"$tk - Win32 Debug\" \n"
      append area6 "\"$tk - Win32 DebugCLEAN\" \: \n"
      append area6 "   \$(MAKE) \/NOLOGO \/\$(MAKEFLAGS) \/F .\\$tk.mak CFG=\"$tk - Win32 Debug\" RECURSE=1 CLEAN\n"
      append area6 "\!ENDIF\n"
    }
    regsub -all -- {__FIELD6__} $temp5 $area6  temp6
   
    if {$tclused == 1} {
       set tclwarning "\!IFNDEF TCLHOME \n\!MESSAGE Compilation of this toolkit requires tcl. Set TCLHOME environment variable for proper compilation\n\!ENDIF"
    } else {
       set tclwarning ""
    }
    regsub -all -- {__TCLUSED__} $temp6 $tclwarning  temp7

    if {$javaused == 1} {
       set javawarning "\!IFNDEF JAVAHOME \n\!MESSAGE Compilation of this toolkit requires java. Set JAVAHOME environment variable for proper compilation\n\!ENDIF"
    } else {
       set javawarning ""
    }
    regsub -all -- {__JAVAUSED__} $temp7 $javawarning  temp8
    puts $fp $temp8
    close $fp
    return $fdsp
}

proc osutils:mkmakx { dir tkloc {tmplat {} } {fmtcpp {} } } {
    if { $tmplat == {} } {set tmplat [osutils:mak:readtemplatex]}
    if { $fmtcpp == {} } {set fmtcpp [osutils:mak:fmtcppx]}
    foreach f [osutils:tk:files $tkloc osutils:am:compilable 0] {
        set tf [file rootname [file tail $f]]   
        set fp [open [set fdsp [file join $dir ${tf}.mak]] w]
        puts $fdsp
        set tclused 0
        fconfigure $fp -translation crlf
        set l_compilable [osutils:dsp:compilable]
        regsub -all -- {__XQTNAM__} $tmplat $tf  temp0
        set tkused ""
        puts [LibToLinkX [woklocate -u $tkloc] $tf]
        foreach tkx [LibToLinkX [woklocate -u $tkloc] $tf] {
	  if {[uinfo -t [woklocate -u $tkx]] == "toolkit"} {
	    append tkused "${tkx}.lib "
	  }
	  if {[woklocate -u $tkx] == "" } {
	      append tkused "${tkx}.lib "
	  }
        }
        foreach tk [LibToLinkX [woklocate -u $tkloc] $tf] {
	  foreach element [osutils:tk:hascsf [woklocate -p ${tk}:source:EXTERNLIB [wokcd]]] {
	    if {[wokparam -t %$element] != 0} {
                set elemlist [wokparam -v "%$element"]
		set felem [file tail [lindex $elemlist 0]] 
	      if {[lsearch $tkused $felem] == "-1"} {
		if {$felem != "\{\}"} {
                    #puts "was found $element $felem"	
                    if {$element == "CSF_TclLibs"} { set tclused 1}   
		    set tkused [concat $tkused $felem]
		}
	      }   
	    }
	 }
       }
 
       if {[wokparam -v %WOKSteps_exec_link [woklocate -u $tkloc]] == "#WOKStep_DLLink(exec.tks)" } { 
           set tkused [concat $tkused "\/dll"]
           if {$tclused != 1} {
             regsub -all -- {__COMPOPT__} $temp0 "\/MD" temp1 
             regsub -all -- {__COMPOPTD__} $temp1 "\/MDd" temp2 
           } else {
             regsub -all -- {__COMPOPT__} $temp0 "\/MD \/I \"\$(TCLHOME)\\include\"" temp1 
             regsub -all -- {__COMPOPTD__} $temp1 "\/MDd \/I \"\$(TCLHOME)\\include\"" temp2 
           }             
           regsub -all -- {__XQTNAMEX__} $temp2 "$tf.dll" temp3
       } else {
           if {$tclused != 1} {
	     regsub -all -- {__COMPOPT__} $temp0 "\/MD" temp1
	     regsub -all -- {__COMPOPTD__} $temp1 "\/MDd" temp2 
           } else {
	     regsub -all -- {__COMPOPT__} $temp0 "\/MD \/I \"\$(TCLHOME)\\include\"" temp1
	     regsub -all -- {__COMPOPTD__} $temp1 "\/MDd \/I \"\$(TCLHOME)\\include\"" temp2 
           }
           regsub -all -- {__XQTNAMEX__} $temp2 "$tf.exe" temp3
       }
       #puts "$tf requires  $tkused"
       if {$tclused == 1} {
          append tkused " -libpath:\"\$(TCLHOME)\\lib\" "
       }
       regsub -all -- {__TKDEP__} $temp3  $tkused temp4
       set files ""
       set field1 ""
       set field2 ""
       set field3 ""
       set field4 ""
       foreach tk [LibToLinkX [woklocate -u $tkloc] $tf] {

         append files "\!IF  \"\$(CFG)\" == \"$tf - Win32 Release\"\n"
         append files "\"$tk - Win32 Release\" \: \n"
         append files "   \$(MAKE) \/NOLOGO \/\$(MAKEFLAGS) \/F .\\$tk.mak CFG=\"$tk - Win32 Release\" \n"
         append files "\"$tk - Win32 ReleaseCLEAN\" \: \n"
         append files "   \$(MAKE) \/NOLOGO \/\$(MAKEFLAGS) \/F .\\$tk.mak CFG=\"$tk - Win32 Release\" RECURSE=1 CLEAN\n"
         append files "\!ELSEIF  \"\$(CFG)\" == \"$tf - Win32 Debug\"\n"
         append files "\"$tk - Win32 Debug\" \: \n"
         append files "   \$(MAKE) \/NOLOGO \/\$(MAKEFLAGS) \/F .\\$tk.mak CFG=\"$tk - Win32 Debug\" \n"
         append files "\"$tk - Win32 DebugCLEAN\" \: \n"
         append files "   \$(MAKE) \/NOLOGO \/\$(MAKEFLAGS) \/F .\\$tk.mak CFG=\"$tk - Win32 Debug\" RECURSE=1 CLEAN\n"
         append files "\!ENDIF\n"
 
         append field1 "\"$tk - Win32 Release\" "
         append field2 "\"$tk - Win32 ReleaseCLEAN\" "
         append field3 "\"$tk - Debug\" "
         append field4 "\"$tk - Win32 DebugCLEAN\" "
         
      }
      regsub -all -- {__FILES__} $temp4 $files temp5
      regsub -all -- {__FIELD1__} $temp5 $field1 temp6
      regsub -all -- {__FIELD2__} $temp6 $field2 temp7
      regsub -all -- {__FIELD3__} $temp7 $field3 temp8
      regsub -all -- {__FIELD4__} $temp8 $field4 temp9
      regsub -all -- {__XNAM__} $temp9 $tkloc temp10
      puts $fp $temp10
      close $fp
      set fout [lappend fout $fdsp]
    }
    return $fout
}


;# 
;# (((((((((((((((((((((((( AUTOMAKE/ PROJECTs )))))))))))))))))))))))
;#
;# Create in dir the Makefile.am associated with toolkit tkloc.
;# Returns the full path of the created file.
;#
proc osutils:tk:mkam { dir tkloc } {
    set pkgs [woklocate -p ${tkloc}:PACKAGES]
    if { $pkgs == {} } {
	puts stderr "osutils:tk:mkam : Error. File PACKAGES not found for toolkit $tkloc."
	return {}
    }

    set tmplat [osutils:am:readtemplate]
    set lpkgs  [osutils:justunix [wokUtils:FILES:FileToList $pkgs]]
    set close  [wokUtils:LIST:Purge [osutils:tk:close [woklocate -u $tkloc]]]
    set lsrc   [lsort [osutils:tk:files $tkloc osutils:am:compilable 1 osutils:justunix]]
    set lobj   [wokUtils:LIST:sanspoint $lsrc]

    set lcsf   [osutils:tk:hascsf [woklocate -p ${tkloc}:source:EXTERNLIB [wokcd]]]

    set final 0
    set externinc ""
    set externlib ""
    if { $lcsf != {} } {
	set final 1
	set fmtinc "\$(%s_INCLUDES) "
	set fmtlib "\$(%s_LIB) "
	set externinc [wokUtils:EASY:FmtSimple1 $fmtinc $lcsf 0]
	set externlib [wokUtils:EASY:FmtSimple1 $fmtlib $lcsf 0]
    }

    regsub -all -- {__TKNAM__} "$tmplat" "$tkloc"   temp0
    set vpath [osutils:am:__VPATH__ $lpkgs]
    regsub -all -- {__VPATH__} "$temp0" "$vpath"    temp1
    set inclu [osutils:am:__INCLUDES__ $lpkgs]
    regsub -all -- {__INCLUDES__} "$temp1" "$inclu" temp2
    if { $close != {} } {
	set libadd [osutils:am:__LIBADD__ $close $final]
    } else {
	set libadd ""
    }
    regsub -all -- {__LIBADD__} "$temp2" "$libadd"  temp3
    set source [osutils:am:__SOURCES__ $lsrc]
    regsub -all -- {__SOURCES__} "$temp3" "$source" temp4
    regsub -all -- {__EXTERNINC__} "$temp4" "$externinc" temp5
    set CXXFl [osutils:am:__CXXFLAG__ $lpkgs]
    regsub -all -- {__CXXFLAG__} "$temp5" "$CXXFl" temp6
    set CFl [osutils:am:__CFLAG__ $lpkgs]
    regsub -all -- {__CFLAG__} "$temp6" "$CFl" temp7

    regsub -all -- {__EXTERNLIB__} "$temp7" "$externlib" MakeFile_am

    wokUtils:FILES:StringToFile "$MakeFile_am" [set fmam [file join $dir Makefile.am]]

    catch { unset temp0 temp1 temp2 temp3 temp4 temp5 temp6 temp7}

    #set tmplat [osutils:in:readtemplate]
    
    #regsub -all -- {__TKNAM__} "$tmplat" "$tkloc"   temp0
    #if { $close != {} } {
	#set dpncies  [osutils:in:__DEPENDENCIES__ $close]
    #} else {
	#set dpncies ""
    #}
    #regsub -all -- {__DEPENDENCIES__} "$temp0" "$dpncies" temp1

    #set objects  [osutils:in:__OBJECTS__ $lobj]
    #regsub -all -- {__OBJECTS__} "$temp1" "$objects" temp2
    #set amdep    [osutils:in:__AMPDEP__ $lobj]
    #regsub -all -- {__AMPDEP__} "$temp2" "$amdep" temp3
    #set amdeptrue [osutils:in:__AMDEPTRUE__ $lobj]
    #regsub -all -- {__AMDEPTRUE__} "$temp3" "$amdeptrue" temp4
;#  so easy..    
    #regsub -all -- {__MAKEFILEIN__} "$temp4" "$MakeFile_am" MakeFile_in

    #wokUtils:FILES:StringToFile "$MakeFile_in" [set fmin [file join $dir Makefile.in]]

    return [list $fmam]
    #return [list $fmam $fmin]
}
;#
;# Create in dir the Makefile.am associated with toolkit tkloc.
;# Returns the full path of the created file.
;#
proc osutils:tk:mkamx { dir tkloc } {
  if   { [lsearch [uinfo -f -T source [woklocate -u $tkloc]] ${tkloc}_WOKSteps.edl] != "-1"} {
        set pkgs [woklocate -p ${tkloc}:EXTERNLIB]
        if { $pkgs == {} } {
	  puts stderr "osutils:tk:mkamx : Error. File EXTERNLIB not found for executable $tkloc."
	#return {}
    }
    set tmplat [osutils:am:readtemplatex]
    set close  [wokUtils:LIST:Purge [osutils:tk:close [woklocate -u $tkloc]]]
    set lsrc   [lsort [osutils:tk:files $tkloc osutils:am:compilable 1 osutils:justunix]]
    set lobj   [wokUtils:LIST:sanspoint $lsrc]
    set CXXList {}
    foreach SourceFile [uinfo -f -T source [woklocate -u $tkloc]] {	
     if {[file extension $SourceFile] == ".cxx"} {	
	  lappend CXXList [file rootname $SourceFile]
     }
    }
    set pkgs [LibToLinkX [woklocate -u $tkloc] [lindex $CXXList 0]]
    set lpkgs  [osutils:justunix [wokUtils:FILES:FileToList $pkgs]]
    puts "pkgs $pkgs"
    #set lcsf   [osutils:tk:hascsf [woklocate -p ${tkloc}:source:EXTERNLIB [wokcd]]]

    set lcsf {}
    foreach tk $pkgs {
	foreach element [osutils:tk:hascsf [woklocate -p ${tk}:source:EXTERNLIB [wokcd]]] {
	    if {[lsearch $lcsf $element] == "-1"} {	   
	   set lcsf [concat $lcsf $element]
	  }
	}
    }
    set final 0
    set externinc ""
    set externlib ""
    if { $lcsf != {} } {
	set final 1
	set fmtinc "\$(%s_INCLUDES) "
	set fmtlib "\$(%s_LIB) "
	set externinc [wokUtils:EASY:FmtSimple1 $fmtinc $lcsf 0]
	set externlib [wokUtils:EASY:FmtSimple1 $fmtlib $lcsf 0]
    }
    regsub -all -- {__XQTNAM__} "$tmplat" "$tkloc"   temp0
    set temp1 "$temp0 \nlib_LTLIBRARIES="
    foreach entity $CXXList {
	set temp1 "${temp1} lib${entity}.la"
    }
    set temp1 "${temp1}\n"
    set inclu [osutils:am:__INCLUDES__ $lpkgs]
    regsub -all -- {__INCLUDES__} "$temp1" "$inclu" temp2
    if { $pkgs != {} } {
	set libadd [osutils:am:__LIBADD__ $pkgs $final]
    } else {
	set libadd ""
    }
    regsub -all -- {__LIBADD__} "$temp2" "$libadd"  temp3
    set source [osutils:am:__SOURCES__ $CXXList]
    regsub -all -- {__SOURCES__} "$temp3" "$source" temp4
    regsub -all -- {__EXTERNINC__} "$temp4" "$externinc" MakeFile_am
    foreach entity $CXXList {
	set MakeFile_am "$MakeFile_am lib${entity}_la_SOURCES = @top_srcdir@/src/${tkloc}/${entity}.cxx \n"
    }
    foreach entity $CXXList {
        set MakeFile_am "$MakeFile_am lib${entity}_la_LIB_ADD = $libadd $externlib \n"
    }
    wokUtils:FILES:StringToFile "$MakeFile_am" [set fmam [file join $dir Makefile.am]]

    catch { unset temp0 temp1 temp2 temp3 temp4 temp5}
    return [list $fmam]

  } else {
    set pkgs [woklocate -p ${tkloc}:EXTERNLIB]
    if { $pkgs == {} } {
	puts stderr "osutils:tk:mkamx : Error. File EXTERNLIB not found for executable $tkloc."
	#return {}
    }
    set tmplat [osutils:am:readtemplatex]
    set close  [wokUtils:LIST:Purge [osutils:tk:close [woklocate -u $tkloc]]]
    set lsrc   [lsort [osutils:tk:files $tkloc osutils:am:compilable 1 osutils:justunix]]
    set lobj   [wokUtils:LIST:sanspoint $lsrc]
    set CXXList {}
    foreach SourceFile [uinfo -f -T source [woklocate -u $tkloc]] {	
     if {[file extension $SourceFile] == ".cxx"} {	
	  lappend CXXList [file rootname $SourceFile]
     }
    }
    set pkgs [LibToLinkX [woklocate -u $tkloc] [lindex $CXXList 0]]
    set lpkgs  [osutils:justunix [wokUtils:FILES:FileToList $pkgs]]
    set lcsf   [osutils:tk:hascsf [woklocate -p ${tkloc}:source:EXTERNLIB [wokcd]]]

    set lcsf {}
    foreach tk $pkgs {
	foreach element [osutils:tk:hascsf [woklocate -p ${tk}:source:EXTERNLIB [wokcd]]] {
	    if {[lsearch $lcsf $element] == "-1"} {	   
	   set lcsf [concat $lcsf $element]
	  }
	}
    }
    set final 0
    set externinc ""
    set externlib ""
    if { $lcsf != {} } {
	set final 1
	set fmtinc "\$(%s_INCLUDES) "
	set fmtlib "\$(%s_LIB) "
	set externinc [wokUtils:EASY:FmtSimple1 $fmtinc $lcsf 0]
	set externlib [wokUtils:EASY:FmtSimple1 $fmtlib $lcsf 0]
    }
    regsub -all -- {__XQTNAM__} "$tmplat" "$tkloc"   temp0
    set temp1 "$temp0 \nbin_PROGRAMS="
    foreach entity $CXXList {
	set temp1 "${temp1} ${entity}"
    }
 
    set temp1 "${temp1}\n"
    set inclu [osutils:am:__INCLUDES__ $lpkgs]
    regsub -all -- {__INCLUDES__} "$temp1" "$inclu" temp2
    if { $pkgs != {} } {
	set libadd [osutils:am:__LIBADD__ $pkgs $final]
    } else {
	set libadd ""
    }
    set source [osutils:am:__SOURCES__ $CXXList]
    regsub -all -- {__SOURCES__} "$temp2" "$source" temp3
    regsub -all -- {__EXTERNINC__} "$temp3" "$externinc" MakeFile_am
    foreach entity $CXXList {
	set MakeFile_am "$MakeFile_am ${entity}_SOURCES = @top_srcdir@/src/${tkloc}/${entity}.cxx \n"
    }
    foreach entity $CXXList {
        set MakeFile_am "$MakeFile_am ${entity}_LDADD = $libadd $externlib \n"
    }
    wokUtils:FILES:StringToFile "$MakeFile_am" [set fmam [file join $dir Makefile.am]]

    catch { unset temp0 temp1 temp2 temp3 temp4 temp5}

   # set tmplat [osutils:in:readtemplatex]
    
   # regsub -all -- {__XQTNAM__} "$tmplat" "$tkloc"   temp0
   # if { $close != {} } {
	#set dpncies  [osutils:in:__DEPENDENCIES__ $close]
   # } else {
	#set dpncies ""
   # }
   # regsub -all -- {__DEPENDENCIES__} "$temp0" "$dpncies" temp1

   # set objects  [osutils:in:__OBJECTS__ $lobj]
   # regsub -all -- {__OBJECTS__} "$temp1" "$objects" temp2
   # #set temp2 $temp1
   # set amdep    [osutils:in:__AMPDEP__ $lobj]
   # regsub -all -- {__AMPDEP__} "$temp2" "$amdep" temp3
    #set temp3 $temp2
   # set amdeptrue [osutils:in:__AMDEPTRUE__ $lobj]
   # regsub -all -- {__AMDEPTRUE__} "$temp3" "$amdeptrue" temp4
    #set temp4 $temp3
;#  so easy..    
   # regsub -all -- {__MAKEFILEIN__} "$temp4" "$MakeFile_am" MakeFile_in

    #wokUtils:FILES:StringToFile "$MakeFile_in" [set fmin [file join $dir Makefile.in]]
    return [list $fmam]
    #return [list $fmam $fmin]
  }
}

;#
;#  ((((((((((((( Formats in Makefile.am )))))))))))))
;#
;# List extensions of files compilable in automake
;#
proc osutils:am:compilable { } {
    return [list .c .cxx .cpp]
}
;#
;# Used to replace the string __VPATH__ in Makefile.am
;# l is the list of the units in a toolkit.
;#
proc osutils:am:__VPATH__ { l } {
    set fmt "@top_srcdir@/drv/%s : @top_srcdir@/src/%s:"
    return [wokUtils:EASY:FmtString2 $fmt $l 0 osutils:am:__VPATH__lastoccur]
}
;#
;# remove ":" from last item of dependencies list in target VPATH of Makefile.am
;#
proc osutils:am:__VPATH__lastoccur { str } {
    if { [regsub {:$} $str "" u] != 0 } {
	return $u
    }
}
proc osutils:am:PkCXXOption ppk {
 set CXXCOMMON [lindex [wokparam -e  %CMPLRS_CXX_Options [wokcd]] 0]
 set FoundFlag ""
 foreach pk $ppk {
  if {[lsearch [uinfo -f -T source [woklocate -u $pk]] ${pk}_CMPLRS.edl] != "-1"} {
	set CXXStr  [lindex [wokparam -e %CMPLRS_CXX_Options [woklocate -u $pk]] 0]
	set LastIndex [expr {[string length $CXXCOMMON ] - 1}]
	if {[string equal $CXXCOMMON [string range $CXXStr 0 $LastIndex]]} {
	  set CXXOption " "
	} else {
	  set CXXOption [string range $CXXStr 0 [expr {[string last $CXXCOMMON $CXXStr] - 1}]]
	}
	if {$CXXOption != " " && $CXXOption != "" && $CXXOption != "  " && $CXXOption != "   "} {
		set FoundList [split $CXXOption " "]
		foreach elem $FoundList {
		  if {$elem != ""} {
		    if {[string first "-I" $elem] == "-1"  } {
		        if {[string first $elem $FoundFlag] == "-1"} {
			   set FoundFlag "$FoundFlag $elem"
			}
		    }
		  }
		}
	 }
  }
 }
 return $FoundFlag
}

proc osutils:am:PkCOption ppk {
 set CCOMMON [lindex [wokparam -e  %CMPLRS_C_Options [wokcd]] 0]
 set FoundFlag ""
 foreach pk $ppk {
  if {[lsearch [uinfo -f -T source [woklocate -u $pk]] ${pk}_CMPLRS.edl] != "-1"} {
	set CStr  [lindex [wokparam -e %CMPLRS_C_Options [woklocate -u $pk]] 0]
	set LastIndex [expr {[string length $CCOMMON ] - 1}]
	if {[string equal $CCOMMON [string range $CStr 0 $LastIndex]]} {
	  set COption [string range  $CStr $LastIndex end ]
	} else {
	  set COption [string range $CStr 0 [expr {[string last $CCOMMON $CStr] - 1}]]
	}
	if {$COption != " " && $COption != "" && $COption != "  " && $COption != "   "} {
		set FoundList [split $COption " "]
		foreach elem $FoundList {
		  if {$elem != ""} {
		    if {[string first "-I" $elem] == "-1"  } {
		        if {[string first $elem $FoundFlag] == "-1"} {
			   set FoundFlag "$FoundFlag $elem"
			}
		    }
		  }
		}
	 }
  }
 } 
return $FoundFlag
}

proc osutils:am:__CXXFLAG__ { l } {
    set fmt "%s"
    #puts "l is: $l"
    return [wokUtils:EASY:FmtString1 $fmt [osutils:am:PkCXXOption $l]]
}
;#
;# Used to replace the string __CFLAG__ in Makefile.am
;# l is the list of all compilable files in a toolkit.
;#
proc osutils:am:__CFLAG__ { l } {
    set fmt "%s"
    return [wokUtils:EASY:FmtString1 $fmt [osutils:am:PkCOption $l]]
}

;#
;# Used to replace the string __INCLUDES__ in Makefile.am
;# l is the list of packages in a toolkit.
;#
proc osutils:am:__INCLUDES__ { l } {
    set fmt "-I@top_srcdir@/drv/%s -I@top_srcdir@/src/%s"
    return [wokUtils:EASY:FmtString2 $fmt $l] 
}
;#
;# Used to replace the string __LIBADD__ in Makefile.am
;# l is the toolkit closure list of a toolkit.
;#
proc osutils:am:__LIBADD__ { l {final 0} } {
    set fmt "../%s/lib%s.la"
    return [wokUtils:EASY:FmtString2 $fmt $l $final]
}
;#
;# Used to replace the string __SOURCES__ in Makefile.am
;# l is the list of all compilable files in a toolkit.
;#
proc osutils:am:__SOURCES__ { l } {
    set fmt "%s"
    return [wokUtils:EASY:FmtString1 $fmt $l]
}
;#
;#  ((((((((((((( Formats in Makefile.in )))))))))))))
;#
;#
;# Used to replace the string __DEPENDENCIES__ in Makefile.in
;# l is the toolkit closure list of a toolkit.
;# 
proc osutils:in:__DEPENDENCIES__ { l } {
    set fmt1 "../%s/lib%s.la"
    set fmt2 "\t../%s/lib%s.la"
    return [wokUtils:EASY:FmtFmtString2 $fmt1 $fmt2 $l]
}
;#
;# Used to replace the string __OBJECTS__ in Makefile.in
;# l is the list of objects files in toolkit.
;#
proc osutils:in:__OBJECTS__ { l } {
    set fmt1 "%s.lo"
    set fmt2 "\t%s.lo"
    return [wokUtils:EASY:FmtFmtString1 $fmt1 $fmt2 $l]
}
;#
;# Used to replace the string __AMDEP__ in Makefile.in
;# l is the list of objects files in toolkit.
;#
proc osutils:in:__AMPDEP__ { l } {
    set fmt1 "\$(DEPDIR)/%s.Plo"
    set fmt2 "@AMDEP_TRUE@\t\$(DEPDIR)/%s.Plo"
    return [wokUtils:EASY:FmtFmtString1 $fmt1 $fmt2 $l]
}
;#
;# Used to replace the string __AMDEPTRUE__ in Makefile.in
;# l is the list of objects files in toolkit.
;#
proc osutils:in:__AMDEPTRUE__ { l } {
    set fmt "@AMDEP_TRUE@@_am_include@ @_am_quote@\$(DEPDIR)/%s.Plo@_am_quote@"
    return [wokUtils:EASY:FmtSimple1 $fmt $l]
}


;#############################################################
;#
proc TESTAM { {root} {ll {}} } {
#    source [woklocate -p OS:source:OS.tcl]
#    source [woklocate -p WOKTclLib:source:osutils.tcl]
    set lesmodules [OS -lm]
    if { $ll != {} } {  set lesmodules $ll }
    foreach theModule $lesmodules {
	foreach unit [$theModule:toolkits] {
	    puts " toolkit: $unit ==> [woklocate -p ${unit}:source:EXTERNLIB]"
	    wokUtils:FILES:rmdir $root/$unit
	    wokUtils:FILES:mkdir $root/$unit
	    osutils:tk:mkam $root/$unit $unit
	}
	foreach unit [OS:executable $theModule] {
	    wokUtils:FILES:rmdir $root/$unit
	    wokUtils:FILES:mkdir $root/$unit
	    osutils:tk:mkamx $root/$unit $unit
	}
    }
}
