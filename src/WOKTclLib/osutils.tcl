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
proc osutils:dsp:readtemplate { } {
    puts stderr "Info : readtemplate : Template for MS project from [set loc /adv_20/KAS/C40/ros/src/OS/template.dsp]"
    return [wokUtils:FILES:FileToString $loc]
}
proc osutils:dsp:readtemplatex { } {
    puts stderr "Info : readtemplate : Template for MS project from [set loc /adv_20/KAS/C40/ros/src/OS/template.dspx]"
    return [wokUtils:FILES:FileToString $loc]
}
proc osutils:am:readtemplate { } {
    puts stderr "Info : readtemplate : Template for Makefile.am from [set loc /adv_20/KAS/C40/ros/src/WOKTclLib/template.mam]"
    return [wokUtils:FILES:FileToString $loc]

}
proc osutils:am:readtemplatex { } {
    puts stderr "Info : readtemplatex : Template for Makefile.am from [set loc /adv_20/KAS/C40/ros/src/WOKTclLib/template.mamx]"
    return [wokUtils:FILES:FileToString $loc]

}
proc osutils:in:readtemplate { } {
    puts stderr "Info : readtemplate : Template for Makefile.in from [set loc /adv_20/KAS/C40/ros/src/WOKTclLib/template.min]"
    return [wokUtils:FILES:FileToString $loc]

}
proc osutils:in:readtemplatex { } {
    puts stderr "Info : readtemplatex : Template for Makefile.in from [set loc /adv_20/KAS/C40/ros/src/WOKTclLib/template.minx]"
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
	    "\{\{\{" "\n" \
	    "    Begin Project Dependency" "\n" \
	    "    Project_Dep_Name $Dep_Name" "\n" \
	    "    End Project Dependency" "\n" \
	    "\}\}\}" "\n" \
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
;#
;# An item for compiling a c++ main
;#
proc osutils:dsp:fmtcppx { } {
    return {# ADD CPP /I ..\..\inc /I ..\..\drv\%s /I ..\..\src\%s /D "__%s_DLL"}
}
;#
;# List extensions of files devoted to be eaten by cl.exe compiler.
;#
proc osutils:dsp:compilable { } {
    return [list .c .cxx .cpp]
}
;#
;# remove from listloc OpenCascade units indesirables on NT
;#
proc osutils:justwnt { listloc } {
    set lret {}
    set goaway [list Xdps Xw ImageUtility WOKUnix]
    foreach u $listloc {
	if { [lsearch $goaway [wokinfo -n $u]] == -1 } {
	    lappend lret $u
	}
    }
    return $lret
}
;#
;# remove from listloc OpenCascade units indesirables on Unix
;#
proc osutils:justunix { listloc } {
    set lret {}
    set goaway [list WNT]
    foreach u $listloc {
	if { [lsearch $goaway [wokinfo -n $u]] == -1 } {
	    lappend lret $u
	}
    }
    return $lret
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
	set ids [woklocate -p [wokinfo -n [wokinfo -u $dir]]:source:EXTERNLIB [wokinfo -w $dir]]
	set eated [osutils:tk:eatpk $ids]
	set result [concat $result $eated]
	;#puts "EXTERNLIB dir = $dir ids = $ids result = $result"
	foreach file $eated {
	    ;#puts "file = $file"
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
    ;#puts " listloc = $listloc"
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
	;#puts " loc = $loc === > [array names map]"
	set LType $Tfiles(source,${utyp})
	foreach typ [array names map] {
	    if { [lsearch $LType $typ] == -1 } {
		unset map($typ)
	    }
	}
	foreach type [array names map] {
	    foreach f $map($type) {
		if { [lsearch $l_comp [file extension $f]] != -1 } {
		    if { $justail == 1 } {
			lappend lret [file tail $f]
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
    set lret  {}
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
	set lsrc   [osutils:tk:files $xlo osutils:am:compilable 0]
	foreach f $lsrc {
	    ;#puts " f = $f"
	    if { ![info exists written([file tail $f])] } {
		set written([file tail $f]) 1
		append files "# Begin Source File" "\n"
		append files "SOURCE=..\\..\\" [wokUtils:EASY:bs1 [wokUtils:FILES:wtail $f 3]] "\n"
		append files [format $fmtcpp $xlo $xlo $xlo] "\n"
		append files "# End Source File" "\n"
	    } else {
		puts "Warning : in dsp more than one occurences for [file tail $f]"
	    }
	}
    }
    
    regsub -all -- {__FILES__} $temp1 $files temp2
    puts $fp $temp2
    close $fp
    return $fdsp
}
;#
;# Create file tkloc.dsp for a executable "console" application
;# in dir return the full path of the created file
;#
proc osutils:mkdspx { dir tkloc {tmplat {} } {fmtcpp {} } } {
    if { $tmplat == {} } {set tmplat [osutils:dsp:readtemplatex]}
    if { $fmtcpp == {} } {set fmtcpp [osutils:dsp:fmtcppx]}
    set fp [open [set fdsp [file join $dir ${tkloc}.dsp]] w]
    fconfigure $fp -translation crlf
    set l_compilable [osutils:dsp:compilable]
    regsub -all -- {__XQTNAM__} $tmplat $tkloc  temp0
    set tkused ""
    foreach tkx [wokUtils:LIST:Purge [osutils:tk:close [woklocate -u $tkloc]]] {
	append tkused "${tkx}.lib "
    }
    puts "$tkloc requires  $tkused"
    regsub -all -- {__TKDEP__} $temp0  $tkused temp1
    set files ""
    set lsrc   [osutils:tk:files $tkloc osutils:am:compilable 0]
    foreach f $lsrc {
	if { ![info exists written([file tail $f])] } {
	    set written([file tail $f]) 1
	    append files "# Begin Source File" "\n"
	    append files "SOURCE=..\\..\\" [wokUtils:EASY:bs1 [wokUtils:FILES:wtail $f 3]] "\n"
	    append files [format $fmtcpp $tkloc $tkloc $tkloc] "\n"
	    append files "# End Source File" "\n"
	} else {
	    puts "Warning : in dsp more than one occurences for [file tail $f]"
	}
    }
    
    regsub -all -- {__FILES__} $temp1 $files temp2
    puts $fp $temp2
    close $fp
    return $fdsp
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
    regsub -all -- {__EXTERNLIB__} "$temp5" "$externlib" MakeFile_am

    wokUtils:FILES:StringToFile "$MakeFile_am" [set fmam [file join $dir Makefile.am]]

    catch { unset temp0 temp1 temp2 temp3 temp4 temp5}

    set tmplat [osutils:in:readtemplate]
    
    regsub -all -- {__TKNAM__} "$tmplat" "$tkloc"   temp0
    if { $close != {} } {
	set dpncies  [osutils:in:__DEPENDENCIES__ $close]
    } else {
	set dpncies ""
    }
    regsub -all -- {__DEPENDENCIES__} "$temp0" "$dpncies" temp1

    set objects  [osutils:in:__OBJECTS__ $lobj]
    regsub -all -- {__OBJECTS__} "$temp1" "$objects" temp2
    set amdep    [osutils:in:__AMPDEP__ $lobj]
    regsub -all -- {__AMPDEP__} "$temp2" "$amdep" temp3
    set amdeptrue [osutils:in:__AMDEPTRUE__ $lobj]
    regsub -all -- {__AMDEPTRUE__} "$temp3" "$amdeptrue" temp4
;#  so easy..    
    regsub -all -- {__MAKEFILEIN__} "$temp4" "$MakeFile_am" MakeFile_in

    wokUtils:FILES:StringToFile "$MakeFile_in" [set fmin [file join $dir Makefile.in]]

    return [list $fmam $fmin]
}
;#
;# Create in dir the Makefile.am associated with toolkit tkloc.
;# Returns the full path of the created file.
;#
proc osutils:tk:mkamx { dir tkloc } {
    set pkgs [woklocate -p ${tkloc}:EXTERNLIB]
    if { $pkgs == {} } {
	puts stderr "osutils:tk:mkamx : Error. File EXTERNLIB not found for executable $tkloc."
	return {}
    }

    set tmplat [osutils:am:readtemplatex]
    set lpkgs  [osutils:justunix [wokUtils:FILES:FileToList $pkgs]]
    set close  [wokUtils:LIST:Purge [osutils:tk:close [woklocate -u $tkloc]]]
    set lsrc   [lsort [osutils:tk:files $tkloc osutils:am:compilable 1 osutils:justunix]]
    set lobj   [wokUtils:LIST:sanspoint $lsrc]

    set lcsf   [osutils:tk:hascsf [woklocate -p ${tkloc}:source:EXTERNLIB [wokcd]]]

    set lcsf {}
    foreach tk $close {
	set lcsf [concat $lcsf [osutils:tk:hascsf [woklocate -p ${tk}:source:EXTERNLIB [wokcd]]]]
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
    set temp1 $temp0
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
    regsub -all -- {__EXTERNLIB__} "$temp5" "$externlib" MakeFile_am

    wokUtils:FILES:StringToFile "$MakeFile_am" [set fmam [file join $dir Makefile.am]]

    catch { unset temp0 temp1 temp2 temp3 temp4 temp5}

    set tmplat [osutils:in:readtemplatex]
    
    regsub -all -- {__XQTNAM__} "$tmplat" "$tkloc"   temp0
    if { $close != {} } {
	set dpncies  [osutils:in:__DEPENDENCIES__ $close]
    } else {
	set dpncies ""
    }
    regsub -all -- {__DEPENDENCIES__} "$temp0" "$dpncies" temp1

    ;#set objects  [osutils:in:__OBJECTS__ $lobj]
    ;#regsub -all -- {__OBJECTS__} "$temp1" "$objects" temp2
    set temp2 $temp1
    ;#set amdep    [osutils:in:__AMPDEP__ $lobj]
    ;#regsub -all -- {__AMPDEP__} "$temp2" "$amdep" temp3
    set temp3 $temp2
    ;#set amdeptrue [osutils:in:__AMDEPTRUE__ $lobj]
    ;#regsub -all -- {__AMDEPTRUE__} "$temp3" "$amdeptrue" temp4
    set temp4 $temp3
;#  so easy..    
    regsub -all -- {__MAKEFILEIN__} "$temp4" "$MakeFile_am" MakeFile_in

    wokUtils:FILES:StringToFile "$MakeFile_in" [set fmin [file join $dir Makefile.in]]

    return [list $fmam $fmin]
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
;#
;# Used to replace the string __INCLUDES__ in Makefile.am
;# l is the list of packages in a toolkit.
;#
proc osutils:am:__INCLUDES__ { l } {
    set fmt "-I@top_srcdir@/drv/%s"
    return [wokUtils:EASY:FmtString1 $fmt $l]
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
proc TESTAM { {root home/AUTOCONF/src} } {

    ;#set root /adv_21/KAS/C40/yan/work/auto/src

    wokcd  KAS:C40:ros
    set ltk [w_info  -T toolkit [wokcd]]
    ;#set ltk TKernel
    foreach tkloc $ltk {
	puts " toolkit: $tkloc ==> [woklocate -p ${tkloc}:source:EXTERNLIB KAS:C40:ros]"
	wokUtils:FILES:mkdir $root/$tkloc
	osutils:tk:mkam $root/$tkloc $tkloc 
    }
}
