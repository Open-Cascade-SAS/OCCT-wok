;#
;# Open source Tcl utilities. This contains material to automatically create
;# MS project or automake builders from the OpenCascade modules definition.
;# This file requires:
;# 1. Tcl utilities of Wok.
;# 2. Wok commands and workbench environment.
;#
;# Author: yolanda_forbes@hotmail.com
;#

# intersect3 - perform the intersecting of two lists, returning a list containing three lists.
# The first list is everything in the first list that wasn't in the second,
# the second list contains the intersection of the two lists, the third list contains everything
# in the second list that wasn't in the first.
proc osutils:intersect3 {list1 list2} {
  set la1(0) {} ; unset la1(0)
  set lai(0) {} ; unset lai(0)
  set la2(0) {} ; unset la2(0)
  foreach v $list1 {
    set la1($v) {}
  }
  foreach v $list2 {
    set la2($v) {}
  }
  foreach elem [concat $list1 $list2] {
    if {[info exists la1($elem)] && [info exists la2($elem)]} {
      unset la1($elem)
      unset la2($elem)
      set lai($elem) {}
    }
  }
  list [lsort [array names la1]] [lsort [array names lai]] [lsort [array names la2]]
}

# Sort a list, returning the sorted version minus any duplicates
proc osutils:lrmdups list {
  if { [llength $list] == 0 } {
    return {}
  }
  set list [lsort $list]
  set last [lvarpop list]
  lappend result $last
  foreach element $list {
    if ![cequal $last $element] {
      lappend result $element
      set last $element
    }
  }
  return $result
}

# Return the logical union of two lists, removing any duplicates
proc osutils:union {theListA theListB} {
  return [osutils:lrmdups [concat $theListA $theListB]]
}

proc osutils:readtemplate {ext what} {
  global env
  set loc "$env(WOK_LIBRARY)/templates/template.$ext"
  #puts stderr "Info: Template for $what loaded from $loc"
  return [wokUtils:FILES:FileToString $loc]
}

# generate template name and load it for given version of Visual Studio and platform
proc osutils:vcproj:readtemplate {vc isexec} {
  set ext $vc
  set what "$vc"
  if { $isexec } {
    set ext "${ext}x"
    set what "$what executable"
  }
  return [osutils:readtemplate $ext "MS VC++ project ($what)"]
}

# Generate RC file content for ToolKit from template
proc osutils:readtemplate:rc {theOutDir theToolKit} {
  set aLoc "$::env(WOK_LIBRARY)/templates/template_dll.rc"
  set aBody [wokUtils:FILES:FileToString $aLoc]
  regsub -all -- {__TKNAM__} $aBody $theToolKit aBody

  set aFile [open "${theOutDir}/${theToolKit}.rc" "w"]
  fconfigure $aFile -translation lf
  puts $aFile $aBody
  close $aFile
  return "${theOutDir}/${theToolKit}.rc"
}

# Convert platform definition (win32 or win64) to appropriate configuration
# name in Visual C++ (Win32 and x64)
proc osutils:vcsolution:confname { vcversion plat } {
  if { "$plat" == "win32" } {
    set conf "Win32"
  } elseif { "$plat" == "win64" } {
    set conf "x64"
  } else {
    puts stderr "Error: Unsupported platform \"$plat\""
  }
  return $conf
}

# Generate header for VS solution file
proc osutils:vcsolution:header { vcversion } {
  if { "$vcversion" == "vc7" } {
    append var \
      "Microsoft Visual Studio Solution File, Format Version 8.00\n"
  } elseif { "$vcversion" == "vc8" } {
    append var \
      "Microsoft Visual Studio Solution File, Format Version 9.00\n" \
      "# Visual Studio 2005\n"
  } elseif { "$vcversion" == "vc9" } {
    append var \
      "Microsoft Visual Studio Solution File, Format Version 10.00\n" \
      "# Visual Studio 2008\n"
  } elseif { "$vcversion" == "vc10" } {
    append var \
      "Microsoft Visual Studio Solution File, Format Version 11.00\n" \
      "# Visual Studio 2010\n"
  } elseif { "$vcversion" == "vc11" } {
    append var \
      "Microsoft Visual Studio Solution File, Format Version 12.00\n" \
      "# Visual Studio 2012\n"
  } else {
    puts stderr "Error: Visual Studio version $vcversion is not supported by this function!"
  }
  return $var
}

# Generate start of configuration section of VS solution file
proc osutils:vcsolution:config:begin { vcversion } {
  if { "$vcversion" == "vc7" } {
    append var \
      "Global\n" \
      "\tGlobalSection(SolutionConfiguration) = preSolution\n" \
      "\t\tDebug = Debug\n" \
      "\t\tRelease = Release\n" \
      "\tEndGlobalSection\n" \
      "\tGlobalSection(ProjectConfiguration) = postSolution\n"
  } elseif { "$vcversion" == "vc8" || "$vcversion" == "vc9" || "$vcversion" == "vc10" || "$vcversion" == "vc11" } {
    append var \
      "Global\n" \
      "\tGlobalSection(SolutionConfigurationPlatforms) = preSolution\n" \
      "\t\tDebug|Win32 = Debug|Win32\n" \
      "\t\tRelease|Win32 = Release|Win32\n" \
      "\t\tDebug|x64 = Debug|x64\n" \
      "\t\tRelease|x64 = Release|x64\n" \
      "\tEndGlobalSection\n" \
      "\tGlobalSection(ProjectConfigurationPlatforms) = postSolution\n"
  } else {
    puts stderr "Error: Visual Studio version $vcversion is not supported by this function!"
  }
  return $var
}

# Generate part of configuration section of VS solution file describing one project
proc osutils:vcsolution:config:project { vcversion guid } {
  if { "$vcversion" == "vc7" } {
    append var \
      "\t\t$guid.Debug.ActiveCfg = Debug|Win32\n" \
      "\t\t$guid.Debug.Build.0 = Debug|Win32\n" \
      "\t\t$guid.Release.ActiveCfg = Release|Win32\n" \
      "\t\t$guid.Release.Build.0 = Release|Win32\n"
  } elseif { "$vcversion" == "vc8" || "$vcversion" == "vc9" || "$vcversion" == "vc10" || "$vcversion" == "vc11" } {
    append var \
      "\t\t$guid.Debug|Win32.ActiveCfg = Debug|Win32\n" \
      "\t\t$guid.Debug|Win32.Build.0 = Debug|Win32\n" \
      "\t\t$guid.Release|Win32.ActiveCfg = Release|Win32\n" \
      "\t\t$guid.Release|Win32.Build.0 = Release|Win32\n" \
      "\t\t$guid.Debug|x64.ActiveCfg = Debug|x64\n" \
      "\t\t$guid.Debug|x64.Build.0 = Debug|x64\n" \
      "\t\t$guid.Release|x64.ActiveCfg = Release|x64\n" \
      "\t\t$guid.Release|x64.Build.0 = Release|x64\n"
  } else {
    puts stderr "Error: Visual Studio version $vcversion is not supported by this function!"
  }
  return $var
}

# Generate start of configuration section of VS solution file
proc osutils:vcsolution:config:end { vcversion } {
  if { "$vcversion" == "vc7" } {
    append var \
      "\tEndGlobalSection\n" \
      "\tGlobalSection(ExtensibilityGlobals) = postSolution\n" \
      "\tEndGlobalSection\n" \
      "\tGlobalSection(ExtensibilityAddIns) = postSolution\n" \
      "\tEndGlobalSection\n"
  } elseif { "$vcversion" == "vc8" || "$vcversion" == "vc9" || "$vcversion" == "vc10" || "$vcversion" == "vc11" } {
    append var \
      "\tEndGlobalSection\n" \
      "\tGlobalSection(SolutionProperties) = preSolution\n" \
      "\t\tHideSolutionNode = FALSE\n" \
      "\tEndGlobalSection\n"
  } else {
    puts stderr "Error: Visual Studio version $vcversion is not supported by this function!"
  }
  return $var
}

proc osutils:mak:fmtcpp { } {
  return {CPP_SWITCHES=$(CPP_PROJ) /I ..\..\..\inc /I ..\..\..\drv\%s /I ..\..\..\src\%s /D "__%s_DLL"}
}

;#
;# List extensions of compilable files in OCCT
;#
proc osutils:compilable { } {
  set aWokStation "$::env(WOKSTATION)"
  if { "$aWokStation" == "mac" } {
    return [list .c .cxx .cpp .mm]
  }
  return [list .c .cxx .cpp]
}

proc osutils:optinal_libs { } {
  return [list tbb.lib tbbmalloc.lib FreeImage.lib FreeImagePlus.lib gl2ps.lib]
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
  # ImageUtility is required for support for old (<6.5.4) versions of OCCT
  set goaway [list Xdps Xw  ImageUtility WOKUnix]
  return [osutils:juststation $goaway $listloc]
}

;#
;# remove from listloc OpenCascade units indesirables on Unix
;#
proc osutils:justunix { listloc } {
  if { "$::tcl_platform(os)" == "Darwin" && "$::MACOSX_USE_GLX" != "true" } {
    set goaway [list Xw WNT WOKNT]
  } else {
    set goaway [list WNT WOKNT]
  }
  return [osutils:juststation $goaway $listloc]
}

;#
;# Define libraries to link using WOK generated dependencies files
;# (available after Obj,Dep building steps)
;#
proc LibToLinkFair {tkit} {
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
        #        set endid [ expr { [string wordend $x $startid] -1 } ]
        #        set fx [string range $x $startid $endid]
        #        lappend l $fx
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
;# Define libraries to link using WOK generated dependencies files
;# (available after Obj,Dep building steps)
;#
proc LibToLinkXFair {tkit name} {
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
        #        set endid [ expr { [string wordend $x $startid] -1 } ]
        #        set CSF_fx [string range $x $startid $endid]
        #    if { $CSF_fx != "-"} {
        #          puts $CSF_fx
        #          set fx [file tail [lindex [wokparam -v \%$CSF_fx $tkit] 0]]
        #          lappend l $fx
        #        }
        #}
      }
      close $id
    } else {
      puts $status
    }
    return $l
  }
}

# Search unit recursively
proc LocateRecur {theName} {
  set aBranch [wokinfo -w]
  set aFullPath "${aBranch}:${theName}"
  if {[wokinfo -x $aFullPath]} {
    return [wokinfo -u $aFullPath]
  }
  set aWkShop  [wokinfo -s]
  set aFParent [w_info -f $aBranch]
  while { "$aFParent" != "" } {
    set aBranch "${aWkShop}:${aFParent}"
    set aFullPath "${aBranch}:${theName}"
    if {[wokinfo -x $aFullPath]} {
      return [wokinfo -u $aFullPath]
    }
    set aFParent [w_info -f $aBranch]
  }
  return ""
}

;#
;# Define libraries to link using only EXTERNLIB file
;#
proc LibToLink {theTKit} {
  if {[uinfo -t $theTKit] != "toolkit"} {
    if {[uinfo -t $theTKit] != "executable"} {
      return
    }
  }

  set aToolkits {}
  set anExtLibList [osutils:tk:eatpk [woklocate -p [wokinfo -n [wokinfo -u $theTKit]]:source:EXTERNLIB [wokinfo -w $theTKit]]]
  foreach anExtLib $anExtLibList {
    set aFullPath [LocateRecur $anExtLib]
    if { "$aFullPath" != "" && [uinfo -t $aFullPath] == "toolkit" } {
      lappend aToolkits $anExtLib
    }
  }
  return $aToolkits
}

;#
;# Define libraries to link using only EXTERNLIB file
;#
proc LibToLinkX {thePackage theDummyName} {
  set aToolKits [LibToLink $thePackage]
  return $aToolKits
}

;#
;# This procedure checks EXTERNLIB file for missed dependences
;# using building information (at least wprocess -DGroups=Src,Xcpp,Obj,Dep)
;#
proc UpdateDepsTKit {theTKit} {
  if {[uinfo -t $theTKit] != "toolkit"} {
    if {[uinfo -t $theTKit] != "executable"} {
      return
    }
  }

  set anExtFile [woklocate -p [wokinfo -n [wokinfo -u $theTKit]]:source:EXTERNLIB [wokinfo -w $theTKit]]
  set anExtLibList [wokUtils:FILES:FileToList $anExtFile]
  set anTKList {}
  if {[uinfo -t $theTKit] == "toolkit"} {
    set anTKList [LibToLinkFair $theTKit]
  } else {
    foreach aSrcFile [osutils:tk:files $theTKit osutils:compilable 0] {
      set aTF [file rootname [file tail $aSrcFile]]
      set anXDepList [LibToLinkXFair $theTKit $aTF]
      foreach aDep $anXDepList {
        lappend anTKList $aDep
      }
    }
  }
  set aNotFoundList {}
  foreach aTKit $anTKList {
    if {[lsearch -exact $anExtLibList $aTKit] == -1} {
      lappend aNotFoundList $aTKit
    }
  }

  if { [llength $aNotFoundList]  > 0 } {
    puts "EXTERNAL file for ToolKit '$theTKit' is incomplete!"
    if { [file exists "$anExtFile"] != 0 } {
      file copy -force -- "$anExtFile" "${anExtFile}.bak"
    } else {
      set aSrcPath [woklocate -p [wokinfo -n [wokinfo -u $theTKit]]:source [wokinfo -w $theTKit]]
      set anExtFile "${aSrcPath}EXTERNLIB"
      set anFILESFile "${aSrcPath}FILES"
      if { [file exists "$anFILESFile"] != 0 } {
        set aWFile [open "$anFILESFile" "a"]
        fconfigure $aWFile -translation lf
        puts $aWFile "EXTERNLIB"
        close $aWFile
      } else {
        set aWFile [open "$anFILESFile" "w"]
        fconfigure $aWFile -translation lf
        puts $aWFile "EXTERNLIB"
        close $aWFile
      }
    }
    set anOutFile [open "$anExtFile" "w"]
    fconfigure $anOutFile -translation lf
    foreach aTKit $aNotFoundList {
      puts $anOutFile "$aTKit"
      puts "  missed ToolKit: $aTKit"
    }
    foreach anExtLib $anExtLibList {
      puts $anOutFile "$anExtLib"
    }
    close $anOutFile
  }
}

;#
;# This procedure checks EXTERNLIB file for all ToolKits for missed dependences
;# using building information (at least wprocess -DGroups=Src,Xcpp,Obj,Dep)
;#
proc UpdateDeps {} {
  set aTKList [w_info -T toolkit]
  foreach aTKit $aTKList {
    UpdateDepsTKit $aTKit
  }
  set anEXEList [w_info -T executable]
  foreach aPackageX $anEXEList {
    UpdateDepsTKit $aPackageX
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
  ;#if { [llength $recurse] != 0 } {
  ;#  set result [concat $result [osutils:tk:close $recurse]]
  ;#}
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

# Generate entry for one source file in Visual Studio 7 - 9 project file
proc osutils:vcproj:file { theVcVer theFile theOptions } {
  append aText "\t\t\t\t<File\n"
  append aText "\t\t\t\t\tRelativePath=\"..\\..\\..\\[wokUtils:EASY:bs1 [wokUtils:FILES:wtail $theFile 3]]\">\n"
  if { $theOptions == "" } {
    append aText "\t\t\t\t</File>\n"
    return $aText
  }

  append aText "\t\t\t\t\t<FileConfiguration\n"
  append aText "\t\t\t\t\t\tName=\"Release\|Win32\">\n"
  append aText "\t\t\t\t\t\t<Tool\n"
  append aText "\t\t\t\t\t\t\tName=\"VCCLCompilerTool\"\n"
  append aText "\t\t\t\t\t\t\tAdditionalOptions=\""
  foreach aParam $theOptions {
    append aText "$aParam "
  }
  append aText "\"\n"
  append aText "\t\t\t\t\t\t/>\n"
  append aText "\t\t\t\t\t</FileConfiguration>\n"

  append aText "\t\t\t\t\t<FileConfiguration\n"
  append aText "\t\t\t\t\t\tName=\"Debug\|Win32\">\n"
  append aText "\t\t\t\t\t\t<Tool\n"
  append aText "\t\t\t\t\t\t\tName=\"VCCLCompilerTool\"\n"
  append aText "\t\t\t\t\t\t\tAdditionalOptions=\""
  foreach aParam $theOptions {
    append aText "$aParam "
  }
  append aText "\"\n"
  append aText "\t\t\t\t\t\t/>\n"
  append aText "\t\t\t\t\t</FileConfiguration>\n"
  if { "$theVcVer" == "vc7" } {
    append aText "\t\t\t\t</File>\n"
    return $aText
  }

  append aText "\t\t\t\t\t<FileConfiguration\n"
  append aText "\t\t\t\t\t\tName=\"Release\|x64\">\n"
  append aText "\t\t\t\t\t\t<Tool\n"
  append aText "\t\t\t\t\t\t\tName=\"VCCLCompilerTool\"\n"
  append aText "\t\t\t\t\t\t\tAdditionalOptions=\""
  foreach aParam $theOptions {
    append aText "$aParam "
  }
  append aText "\"\n"
  append aText "\t\t\t\t\t\t/>\n"
  append aText "\t\t\t\t\t</FileConfiguration>\n"

  append aText "\t\t\t\t\t<FileConfiguration\n"
  append aText "\t\t\t\t\t\tName=\"Debug\|x64\">\n"
  append aText "\t\t\t\t\t\t<Tool\n"
  append aText "\t\t\t\t\t\t\tName=\"VCCLCompilerTool\"\n"
  append aText "\t\t\t\t\t\t\tAdditionalOptions=\""
  foreach aParam $theOptions {
    append aText "$aParam "
  }
  append aText "\"\n"
  append aText "\t\t\t\t\t\t/>\n"
  append aText "\t\t\t\t\t</FileConfiguration>\n"

  append aText "\t\t\t\t</File>\n"
  return $aText
}

# Generate entry for one source file in Visual Studio 10 project file
proc osutils:vcxproj:file { vcversion file params } {
  append text "    <ClCompile Include=\"..\\..\\..\\[wokUtils:EASY:bs1 [wokUtils:FILES:wtail $file 3]]\">\n"

  if { $params != "" } {
    append text "      <AdditionalOptions Condition=\"\'\$(Configuration)|\$(Platform)\'==\'Debug|Win32\'\">[string trim ${params}]  %(AdditionalOptions)</AdditionalOptions>\n"
  }

  if { $params != "" } {
    append text "      <AdditionalOptions Condition=\"\'\$(Configuration)|\$(Platform)\'==\'Release|Win32\'\">[string trim ${params}]  %(AdditionalOptions)</AdditionalOptions>\n"
  }

  if { $params != "" } {
    append text "      <AdditionalOptions Condition=\"\'\$(Configuration)|\$(Platform)\'==\'Debug|x64\'\">[string trim ${params}]  %(AdditionalOptions)</AdditionalOptions>\n"
  }

  if { $params != "" } {
    append text "      <AdditionalOptions Condition=\"\'\$(Configuration)|\$(Platform)\'==\'Release|x64\'\">[string trim ${params}]  %(AdditionalOptions)</AdditionalOptions>\n"
  }

  append text "    </ClCompile>\n"
  return $text
}

# Returns extension (without dot) for project files of given version of VC
proc osutils:vcproj:ext { vcversion } {
  if { "$vcversion" == "vc7" || "$vcversion" == "vc8" || "$vcversion" == "vc9" } {
    return "vcproj"
  } elseif { "$vcversion" == "vc10" || "$vcversion" == "vc11" } {
    return "vcxproj"
  } else {
    puts stderr "Error: Visual Studio version $vc is not supported by this function!"
  }
}

# Generate Visual Studio 2010 project filters file
proc osutils:vcxproj:filters { dir proj theFilesMap } {
  upvar $theFilesMap aFilesMap

  # header
  append text "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
  append text "<Project ToolsVersion=\"4.0\" xmlns=\"http://schemas.microsoft.com/developer/msbuild/2003\">\n"

  # list of "filters" (units)
  append text "  <ItemGroup>\n"
  append text "    <Filter Include=\"Source files\">\n"
  append text "      <UniqueIdentifier>[OS:genGUID]</UniqueIdentifier>\n"
  append text "    </Filter>\n"
  foreach unit $aFilesMap(units) {
    append text "    <Filter Include=\"Source files\\${unit}\">\n"
    append text "      <UniqueIdentifier>[OS:genGUID]</UniqueIdentifier>\n"
    append text "    </Filter>\n"
  }
  append text "  </ItemGroup>\n"

  # list of files
  append text "  <ItemGroup>\n"
  foreach unit $aFilesMap(units) {
    foreach file $aFilesMap($unit) {
      append text "    <ClCompile Include=\"..\\..\\..\\[wokUtils:EASY:bs1 [wokUtils:FILES:wtail $file 3]]\">\n"
      append text "      <Filter>Source files\\${unit}</Filter>\n"
      append text "    </ClCompile>\n"
    }
  }
  append text "  </ItemGroup>\n"

  # end
  append text "</Project>"

  # write file
  set fp [open [set fvcproj [file join $dir ${proj}.vcxproj.filters]] w]
  fconfigure $fp -translation crlf
  puts $fp $text
  close $fp

  return ${proj}.vcxproj.filters
}

# Generate Visual Studio 2011 project filters file
proc osutils:vcx1proj:filters { dir proj theFilesMap } {
  upvar $theFilesMap aFilesMap

  # header
  append text "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
  append text "<Project ToolsVersion=\"4.0\" xmlns=\"http://schemas.microsoft.com/developer/msbuild/2003\">\n"

  # list of "filters" (units)
  append text "  <ItemGroup>\n"
  append text "    <Filter Include=\"Source files\">\n"
  append text "      <UniqueIdentifier>[OS:genGUID]</UniqueIdentifier>\n"
  append text "    </Filter>\n"
  foreach unit $aFilesMap(units) {
    append text "    <Filter Include=\"Source files\\${unit}\">\n"
    append text "      <UniqueIdentifier>[OS:genGUID]</UniqueIdentifier>\n"
    append text "    </Filter>\n"
  }
  append text "  </ItemGroup>\n"

  # list of files
  append text "  <ItemGroup>\n"
  foreach unit $aFilesMap(units) {
    foreach file $aFilesMap($unit) {
      append text "    <ClCompile Include=\"..\\..\\..\\[wokUtils:EASY:bs1 [wokUtils:FILES:wtail $file 3]]\">\n"
      append text "      <Filter>Source files\\${unit}</Filter>\n"
      append text "    </ClCompile>\n"
    }
  }
  append text "  </ItemGroup>\n"

  append text "  <ItemGroup>\n"
  append text "    <ResourceCompile Include=\"${proj}.rc\" />"
  append text "  </ItemGroup>\n"

  # end
  append text "</Project>"

  # write file
  set fp [open [set fvcproj [file join $dir ${proj}.vcxproj.filters]] w]
  fconfigure $fp -translation crlf
  puts $fp $text
  close $fp

  return ${proj}.vcxproj.filters
}

# Generate Visual Studio project file for ToolKit
proc osutils:vcproj { theVcVer theOutDir theToolKit theGuidsMap {theProjTmpl {} } } {
  if { $theProjTmpl == {} } {set theProjTmpl [osutils:vcproj:readtemplate $theVcVer 0]}

  set l_compilable [osutils:compilable]
  regsub -all -- {__TKNAM__} $theProjTmpl $theToolKit theProjTmpl

  upvar $theGuidsMap aGuidsMap
  if { ! [info exists aGuidsMap($theToolKit)] } {
    set aGuidsMap($theToolKit) [OS:genGUID]
  }
  regsub -all -- {__PROJECT_GUID__} $theProjTmpl $aGuidsMap($theToolKit) theProjTmpl

  set aCommonUsedTK [list]
  foreach tkx [osutils:commonUsedTK  $theToolKit] {
    lappend aCommonUsedTK "${tkx}.lib"
  }
  
  set aUsedToolKits [concat $aCommonUsedTK [osutils:usedOsLibs $theToolKit "wnt"]]

  # correct names of referred third-party libraries that are named with suffix
  # depending on VC version
  regsub -all -- {vc[0-9]+} $aUsedToolKits $theVcVer aUsedToolKits

  # and put this list to project file
  puts "$theToolKit requires  $aUsedToolKits"
  if { "$theVcVer" == "vc10" || "$theVcVer" == "vc11" } { set aUsedToolKits [join $aUsedToolKits {;}] }
  regsub -all -- {__TKDEP__} $theProjTmpl $aUsedToolKits theProjTmpl

  set anIncPaths "..\\..\\..\\inc"
  set aTKDefines ""
  set aFilesSection ""
  set aVcFilesX(units) ""
  set listloc [osutils:tk:units [woklocate -u $theToolKit]]
  set resultloc [osutils:justwnt $listloc]
  if [array exists written] { unset written }
  set fxloparamfcxx [lindex [osutils:intersect3 [split [lindex [wokparam -v %CMPLRS_CXX_Options [w_info -f]] 0]] [split [lindex [wokparam -v %CMPLRS_CXX_Options] 0]] ] 2]
  set fxloparamfc   [lindex [osutils:intersect3 [split [lindex [wokparam -v %CMPLRS_C_Options   [w_info -f]] 0]] [split [lindex [wokparam -v %CMPLRS_C_Options]   0]] ] 2]
  set fxloparam    "[osutils:union [split $fxloparamfcxx] [split $fxloparamfc]]"
  foreach fxlo $resultloc {
    set xlo  [wokinfo -n $fxlo]
    set aSrcFiles [osutils:tk:files $xlo osutils:compilable 0]
    set fxloparam "$fxloparam [lindex [osutils:intersect3 [split [lindex [wokparam -v %CMPLRS_CXX_Options] 0]] [split [lindex [wokparam -v %CMPLRS_CXX_Options $fxlo] 0]] ] 2]"
    set fxloparam "$fxloparam [lindex [osutils:intersect3 [split [lindex [wokparam -v %CMPLRS_C_Options  ] 0]] [split [lindex [wokparam -v %CMPLRS_C_Options   $fxlo] 0]] ] 2]"
    set needparam ""
    foreach partopt $fxloparam {
      if {[string first "-I" $partopt] == "0"} {
        # this is an additional includes search path
        continue
      }
      set needparam "$needparam $partopt"
      #if { "-I[lindex [wokparam -v %CSF_TCL_INCLUDE] 0]" != "$partopt "} {
      #  if { "-I[lindex [wokparam -v %CSF_JAVA_INCLUDE] 0]" != "$partopt "} {
      #    set needparam "$needparam $partopt"
      #  }
      #}
    }

    # Format of projects in vc10 and vc11 is different from vc7-9
    if { "$theVcVer" == "vc10" || "$theVcVer" == "vc11" } {
      foreach aSrcFile [lsort $aSrcFiles] {
        if { ![info exists written([file tail $aSrcFile])] } {
          set written([file tail $aSrcFile]) 1
          append aFilesSection [osutils:vcxproj:file $theVcVer $aSrcFile $needparam]
        } else {
          puts "Warning : in vcproj more than one occurences for [file tail $aSrcFile]"
        }
        if { ! [info exists aVcFilesX($xlo)] } { lappend aVcFilesX(units) $xlo }
        lappend aVcFilesX($xlo) $aSrcFile
      }
    } else {
      append aFilesSection "\t\t\t<Filter\n"
      append aFilesSection "\t\t\t\tName=\"${xlo}\"\n"
      append aFilesSection "\t\t\t\t>\n"
      foreach aSrcFile [lsort $aSrcFiles] {
        if { ![info exists written([file tail $aSrcFile])] } {
          set written([file tail $aSrcFile]) 1
          append aFilesSection [osutils:vcproj:file $theVcVer $aSrcFile $needparam]
        } else {
          puts "Warning : in vcproj more than one occurences for [file tail $aSrcFile]"
        }
      }
      append aFilesSection "\t\t\t</Filter>\n"
    }

    # macros
    append aTKDefines ";__${xlo}_DLL"
    # common includes
    append anIncPaths ";..\\..\\..\\drv\\${xlo}"
    append anIncPaths ";..\\..\\..\\src\\${xlo}"
  }

  regsub -all -- {__TKINC__}  $theProjTmpl $anIncPaths theProjTmpl
  regsub -all -- {__TKDEFS__} $theProjTmpl $aTKDefines theProjTmpl
  regsub -all -- {__FILES__}  $theProjTmpl $aFilesSection theProjTmpl

  # write file
  set aFile [open [set aVcFiles [file join $theOutDir ${theToolKit}.[osutils:vcproj:ext $theVcVer]]] w]
  fconfigure $aFile -translation crlf
  puts $aFile $theProjTmpl
  close $aFile

  # write filters file for vc10 and vc11
  if { "$theVcVer" == "vc10" } {
    lappend aVcFiles [osutils:vcxproj:filters $theOutDir $theToolKit aVcFilesX]
  } elseif { "$theVcVer" == "vc11" } {
    lappend aVcFiles [osutils:vcx1proj:filters $theOutDir $theToolKit aVcFilesX]
  }

  # write resource file
  lappend aVcFiles [osutils:readtemplate:rc $theOutDir $theToolKit]

  return $aVcFiles
}

# Generate Visual Studio project file for executable
proc osutils:vcprojx { theVcVer theOutDir theToolKit theGuidsMap {theProjTmpl {} } } {
  set aVcFiles {}
  foreach f [osutils:tk:files $theToolKit osutils:compilable 0] {
    if { $theProjTmpl == {} } {
      set aProjTmpl [osutils:vcproj:readtemplate $theVcVer 1]
    } else {
      set aProjTmpl $theProjTmpl
    }
    set aProjName [file rootname [file tail $f]]
    set l_compilable [osutils:compilable]
    regsub -all -- {__XQTNAM__} $aProjTmpl $aProjName aProjTmpl

    upvar $theGuidsMap aGuidsMap
    if { ! [info exists aGuidsMap($aProjName)] } {
      set aGuidsMap($aProjName) [OS:genGUID]
    }
    regsub -all -- {__PROJECT_GUID__} $aProjTmpl $aGuidsMap($aProjName) aProjTmpl
    
    set aCommonUsedTK [list]
    foreach tkx [osutils:commonUsedTK  $theToolKit] {
      lappend aCommonUsedTK "${tkx}.lib"
    }
  
    set aUsedToolKits [concat $aCommonUsedTK [osutils:usedOsLibs $theToolKit "wnt"]]

    set WOKSteps_exec_link [wokparam -v %WOKSteps_exec_link [woklocate -u $theToolKit]]
    if { [regexp {WOKStep_DLLink} $WOKSteps_exec_link] || [regexp {WOKStep_Libink} $WOKSteps_exec_link] } {
      set aUsedToolKits [concat $aUsedToolKits "\/dll"]
      set binext 2
    } else {
      set binext 1
    }

    # correct names of referred third-party libraries that are named with suffix
    # depending on VC version
    regsub -all -- {vc[0-9]+} $aUsedToolKits $theVcVer aUsedToolKits

    puts "$aProjName requires  $aUsedToolKits"
    if { "$theVcVer" == "vc10" || "$theVcVer" == "vc11"  } { set aUsedToolKits [join $aUsedToolKits {;}] }
    regsub -all -- {__TKDEP__} $aProjTmpl $aUsedToolKits aProjTmpl

    set aFilesSection ""
    set aVcFilesX(units) ""
    ;#set lsrc   [osutils:tk:files $theToolKit osutils:compilable 0]
    if { ![info exists written([file tail $f])] } {
      set written([file tail $f]) 1

      if { "$theVcVer" == "vc10" || "$theVcVer" == "vc11" } {
        append aFilesSection [osutils:vcxproj:file $theVcVer $f ""]
        if { ! [info exists aVcFilesX($theToolKit)] } { lappend aVcFilesX(units) $theToolKit }
        lappend aVcFilesX($theToolKit) $f
      } else {
        append aFilesSection "\t\t\t<Filter\n"
        append aFilesSection "\t\t\t\tName=\"$theToolKit\"\n"
        append aFilesSection "\t\t\t\t>\n"
        append aFilesSection [osutils:vcproj:file $theVcVer $f ""]
        append aFilesSection "\t\t\t</Filter>"
      }
    } else {
      puts "Warning : in vcproj there are than one occurences for [file tail $f]"
    }
    #puts "$aProjTmpl $aFilesSection"
    set aTKDefines ";__${theToolKit}_DLL"
    set anIncPaths "..\\..\\..\\inc;..\\..\\..\\drv\\${theToolKit};..\\..\\..\\src\\${theToolKit}"
    regsub -all -- {__TKINC__}  $aProjTmpl $anIncPaths    aProjTmpl
    regsub -all -- {__TKDEFS__} $aProjTmpl $aTKDefines    aProjTmpl
    regsub -all -- {__FILES__}  $aProjTmpl $aFilesSection aProjTmpl
    regsub -all -- {__CONF__}   $aProjTmpl $binext        aProjTmpl
    if { $binext == 2 } {
      regsub -all -- {__XQTEXT__} $aProjTmpl "dll" aProjTmpl
    } else {
      regsub -all -- {__XQTEXT__} $aProjTmpl "exe" aProjTmpl
    }

    set aFile [open [set aVcFilePath [file join $theOutDir ${aProjName}.[osutils:vcproj:ext $theVcVer]]] w]
    fconfigure $aFile -translation crlf
    puts $aFile $aProjTmpl
    close $aFile

    lappend aVcFiles $aVcFilePath

    # write filters file for vc10
    if { "$theVcVer" == "vc10" || "$theVcVer" == "vc11" } {
      lappend aVcFiles [osutils:vcxproj:filters $theOutDir $aProjName aVcFilesX]
    }

    if { "$theVcVer" == "vc9" } {
      set aCommonSettingsFileTmpl "$::env(WOK_LIBRARY)/templates/vcproj.user.vc9x"
      set aCommonSettingsFile     "$aVcFilePath.user"
      file copy -force -- "$aCommonSettingsFileTmpl" "$aCommonSettingsFile"
      lappend aVcFiles "$aCommonSettingsFile"
    }
  }
  return $aVcFiles
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

  set tmplat [osutils:readtemplate mam "Makefile.am"]
  set lpkgs  [osutils:justunix [wokUtils:FILES:FileToList $pkgs]]
  set close  [wokUtils:LIST:Purge [osutils:tk:close [woklocate -u $tkloc]]]
  set lsrc   [lsort [osutils:tk:files $tkloc osutils:compilable 1 osutils:justunix]]
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

  regsub -all -- {__TKNAM__} $tmplat $tkloc tmplat
  set vpath [osutils:am:__VPATH__ $lpkgs]
  regsub -all -- {__VPATH__} $tmplat $vpath tmplat
  set inclu [osutils:am:__INCLUDES__ $lpkgs]
  regsub -all -- {__INCLUDES__} $tmplat $inclu tmplat
  if { $close != {} } {
    set libadd [osutils:am:__LIBADD__ $close $final]
  } else {
    set libadd ""
  }
  regsub -all -- {__LIBADD__} $tmplat $libadd tmplat
  set source [osutils:am:__SOURCES__ $lsrc]
  regsub -all -- {__SOURCES__} $tmplat $source tmplat
  regsub -all -- {__EXTERNINC__} $tmplat $externinc tmplat
  set CXXFl [osutils:am:__CXXFLAG__ $lpkgs]
  regsub -all -- {__CXXFLAG__} $tmplat $CXXFl tmplat
  set CFl [osutils:am:__CFLAG__ $lpkgs]
  regsub -all -- {__CFLAG__} $tmplat $CFl tmplat

  regsub -all -- {__EXTERNLIB__} $tmplat $externlib tmplat

  wokUtils:FILES:StringToFile $tmplat [set fmam [file join $dir Makefile.am]]

  return [list $fmam]
}

;#
;# Create in dir the Makefile.am associated with toolkit tkloc.
;# Returns the full path of the created file.
;#
proc osutils:tk:mkamx { dir tkloc } {
  if { [lsearch [uinfo -f -T source [woklocate -u $tkloc]] ${tkloc}_WOKSteps.edl] != "-1"} {
    set pkgs [woklocate -p ${tkloc}:EXTERNLIB]
    if { $pkgs == {} } {
      puts stderr "osutils:tk:mkamx : Error. File EXTERNLIB not found for executable $tkloc."
      #return {}
    }
    set tmplat [osutils:readtemplate mamx "Makefile.am (executable)"]
    set close  [wokUtils:LIST:Purge [osutils:tk:close [woklocate -u $tkloc]]]
    set lsrc   [lsort [osutils:tk:files $tkloc osutils:compilable 1 osutils:justunix]]
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
    regsub -all -- {__XQTNAM__} $tmplat $tkloc tmplat
    set tmplat "$tmplat \nlib_LTLIBRARIES="
    foreach entity $CXXList {
      set tmplat "$tmplat lib${entity}.la"
    }
    set tmplat "$tmplat\n"
    set inclu [osutils:am:__INCLUDES__ $lpkgs]
    regsub -all -- {__INCLUDES__} $tmplat $inclu tmplat
    if { $pkgs != {} } {
      set libadd [osutils:am:__LIBADD__ $pkgs $final]
    } else {
      set libadd ""
    }
    regsub -all -- {__LIBADD__} $tmplat $libadd tmplat
    set source [osutils:am:__SOURCES__ $CXXList]
    regsub -all -- {__SOURCES__} $tmplat $source tmplat
    regsub -all -- {__EXTERNINC__} $tmplat $externinc tmplat
    foreach entity $CXXList {
      set tmplat "$tmplat lib${entity}_la_SOURCES = @top_srcdir@/src/${tkloc}/${entity}.cxx \n"
    }
    foreach entity $CXXList {
      set tmplat "$tmplat lib${entity}_la_LIBADD = $libadd $externlib \n"
    }
    wokUtils:FILES:StringToFile $tmplat [set fmam [file join $dir Makefile.am]]

    unset tmplat

    return [list $fmam]

  } else {
    set pkgs [woklocate -p ${tkloc}:EXTERNLIB]
    if { $pkgs == {} } {
      puts stderr "osutils:tk:mkamx : Error. File EXTERNLIB not found for executable $tkloc."
      #return {}
    }
    set tmplat [osutils:readtemplate mamx "Makefile.am (executable)"]
    set close  [wokUtils:LIST:Purge [osutils:tk:close [woklocate -u $tkloc]]]
    set lsrc   [lsort [osutils:tk:files $tkloc osutils:compilable 1 osutils:justunix]]
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
    regsub -all -- {__XQTNAM__} $tmplat $tkloc tmplat
    set tmplat "$tmplat \nbin_PROGRAMS="
    foreach entity $CXXList {
      set tmplat "${tmplat} ${entity}"
    }

    set tmplat "${tmplat}\n"
    set inclu [osutils:am:__INCLUDES__ $lpkgs]
    regsub -all -- {__INCLUDES__} $tmplat $inclu tmplat
    if { $pkgs != {} } {
      set libadd [osutils:am:__LIBADD__ $pkgs $final]
    } else {
      set libadd ""
    }
    set source [osutils:am:__SOURCES__ $CXXList]
    regsub -all -- {__SOURCES__} $tmplat $source tmplat
    regsub -all -- {__EXTERNINC__} $tmplat $externinc tmplat
    foreach entity $CXXList {
      set tmplat "$tmplat ${entity}_SOURCES = @top_srcdir@/src/${tkloc}/${entity}.cxx \n"
    }
    foreach entity $CXXList {
      set tmplat "$tmplat ${entity}_LDADD = $libadd $externlib \n"
    }
    wokUtils:FILES:StringToFile $tmplat [set fmam [file join $dir Makefile.am]]

    return [list $fmam]
  }
}


;#
;# Create in dir the Makefile.am in $dir directory.
;# Returns the full path of the created file.
;#
proc osutils:am:adm { dir {lesmodules {}} } {

  set amstring "srcdir = @srcdir@\n\n"
  set subdirs "SUBDIRS ="
  set vpath "VPATH = @srcdir@ ${dir}: "
  set make ""
  set phony ".PHONY:"
  foreach theModule $lesmodules {
    set units [osutils:tk:sort [$theModule:toolkits]]
    set units [concat $units [OS:executable $theModule]]
    append amstring "${theModule}_PKGS ="
    append vpath "\\\n"
    foreach unit $units {
      append amstring " ${unit}"
      append vpath "${dir}/${unit}: "
    }
    set up ${theModule}
    if { [info procs ${theModule}:alias] != "" } {
      set up [${theModule}:alias]
    }
    set up [string toupper ${up}]
    append amstring "\n\nif ENABLE_${up}\n"
    append amstring "  ${theModule}_DIRS = \$(${theModule}_PKGS)\n"
    append amstring "else\n"
    append amstring "  ${theModule}_DIRS = \n"
    append amstring "endif\n\n"
    append subdirs " \$(${theModule}_DIRS)"
    append make "${theModule}:\n"
    append make "\tfor d in \$(${theModule}_PKGS); do \\\n"
    append make "\t\tcd \$\$d; \$(MAKE) \$(AM_MAKEFLAGS) lib\$\$d.la; cd ..; \\\n"
    append make "\tdone\n\n"
    append phony " ${theModule}"
  }
  append amstring "$subdirs\n\n"
  append amstring "$vpath\n\n"
  append amstring $make
  append amstring $phony
  wokUtils:FILES:StringToFile $amstring [set fmam [file join $dir Makefile.am]]
  return [list $fmam]
}

;#
;# Create in dir the Makefile.am and configure.ac in CASROOT directory.
;# Returns the full path of the created file.
;#
proc osutils:am:root { dir theSubPath {lesmodules {}} } {
  set amstring "srcdir = @srcdir@\n\n"
  append amstring "SUBDIRS = ${theSubPath}\n\n"
  append amstring "VPATH = @srcdir@ @top_srcdir@/${theSubPath}: @top_srcdir@/${theSubPath}:\n\n"

  set phony ".PHONY:"

  set acstring [osutils:readtemplate ac "Makefile.am"]
  set enablestr ""
  set confstr ""
  set condstr ""
  set repstr ""
  set acconfstr ""

  set exelocal "install-exec-local:\n"
  append exelocal "\t"
  append exelocal {$(INSTALL) -d $(prefix)/$(platform)}
  append exelocal "\n"
  foreach d {bin lib} {
    append exelocal "\t"
    append exelocal "if \[ -e \$(prefix)/${d} -a ! -e \$(prefix)/\$(platform)/${d} \]; then \\\n"
    append exelocal "\t\tcd \$(prefix)/\$(platform) && ln -s ../${d} ${d}; \\\n"
    append exelocal "\tfi\n"
  }
  append exelocal "\t"
  append exelocal {buildd=`pwd`; cd $(top_srcdir); sourced=`pwd`; cd $(prefix); installd=`pwd`; cd $$buildd;}
  append exelocal " \\\n"
  append exelocal "\t"
  append exelocal {if [ "$$installd" != "$$sourced" ]; then}
  append exelocal " \\\n"
  append exelocal "\t\t"
  append exelocal {$(INSTALL) -d $(prefix)/inc;}
  append exelocal " \\\n"
  append exelocal "\t\t"
  append exelocal {cp -frL $(top_srcdir)/inc $(prefix);}
  append exelocal " \\\n"
  append exelocal "\t\t"
  append exelocal {cp -frL $$buildd/config.h $(prefix);}
  append exelocal " \\\n"
  append exelocal "\t\tfor d in "

  foreach theModule $lesmodules {
    append amstring "${theModule}_PKGS ="
    foreach r [${theModule}:ressources] {
      if { "[lindex $r 1]" == "r" } {
	append amstring " [lindex $r 2]"
      }
    }
    set up ${theModule}
    if { [info procs ${theModule}:alias] != "" } {
      set up [${theModule}:alias]
    }
    set up [string toupper ${up}]
    set lower ${theModule}
    if { [info procs ${theModule}:alias] != "" } {
      set lower [${theModule}:alias]
    }
    set lower [string tolower ${lower}]

    append amstring "\n\nif ENABLE_${up}\n"
    append amstring "  ${theModule}_DIRS = \$(${theModule}_PKGS)\n"
    append amstring "else\n"
    append amstring "  ${theModule}_DIRS = \n"
    append amstring "endif\n\n"
    append amstring "${theModule}:\n"
    append amstring "\tcd \$(top_builddir)/${theSubPath} && \$(MAKE) \$(AM_MAKEFLAGS) ${theModule}\n\n"
    append phony " ${theModule}"

    append exelocal " \$(${theModule}_DIRS)"

    append enablestr "AC_ARG_ENABLE(\[${lower}\],\n"
    append enablestr "  \[AS_HELP_STRING(\[--disable-${lower}\],\[Disable ${theModule} components\])\],\n"
    append enablestr "  \[ENABLE_${up}=\${enableval}\],\[ENABLE_${up}=yes\])\n"

    set deplist [OS:lsdep ${theModule}]
    set acdeplist {}
    if { [info procs ${theModule}:acdepends] != "" } {
      set acdeplist [${theModule}:acdepends]
    }

    if { [llength $deplist] > 0 || [llength $acdeplist] > 0} {
      append confstr "if test \"xyes\" = \"x\$ENABLE_${up}\"; then\n"
    } else {
      append confstr "if test \"xyes\" != \"x\$ENABLE_${up}\"; then\n"
    }
    foreach dep $deplist {
      set dup ${dep}
      if { [info procs ${dep}:alias] != "" } {
	set dup [${dep}:alias]
      }
      set dup [string toupper ${dup}]
      append confstr "  if test \"xyes\" = \"x\$ENABLE_${up}\" -a \"xyes\" != \"x\$ENABLE_${dup}\"; then\n"
      append confstr "    AC_MSG_NOTICE(\[Disabling ${theModule}: not building ${dep} component\])\n"
      append confstr "    DISABLE_${up}_REASON=\"(${dep} component disabled)\"\n"
      append confstr "    ENABLE_${up}=no\n"
      append confstr "  fi\n"
    }
    foreach dep $acdeplist {
      append confstr "  if test \"xyes\" = \"x\$ENABLE_${up}\" -a \"xyes\" != \"x\$HAVE_${dep}\"; then\n"
      append confstr "    AC_MSG_NOTICE(\[Disabling ${theModule}: ${dep} not found\])\n"
      append confstr "    DISABLE_${up}_REASON=\"(${dep} not found)\"\n"
      append confstr "    ENABLE_${up}=no\n"
      append confstr "  fi\n"
    }
    if { [llength $deplist] > 0 || [llength $acdeplist] > 0 } {
      append confstr "else\n"
    }
    append confstr "  DISABLE_${up}_REASON=\"(Disabled)\"\n"
    append confstr "fi\n"

    append condstr "AM_CONDITIONAL(\[ENABLE_${up}\], \[test \"xyes\" = \"x\$ENABLE_${up}\"\])\n"
    append repstr [format "echo \"%-*s  \$ENABLE_${up} \$DISABLE_${up}_REASON\"" 26 ${theModule}]
    append repstr "\n"

    set units [$theModule:toolkits]
    set units [concat $units [OS:executable $theModule]]
    foreach unit $units {
      append acconfstr "${theSubPath}/${unit}/Makefile \\\n"
    }
  }

  append exelocal "; do \\\n"
  append exelocal "\t\t\t"
  append exelocal {$(INSTALL) -d $(prefix)/src/$$d;}
  append exelocal " \\\n"
  append exelocal "\t\t\t"
  append exelocal {cp -frL $(top_srcdir)/src/$$d $(prefix)/src;}
  append exelocal " \\\n"
  append exelocal "\t\tdone; \\\n"
  append exelocal "\tfi\n"
  append exelocal "\t"
  append exelocal {if [ -e $(prefix)/inc/config.h ]; then}
  append exelocal " \\\n"
  append exelocal "\t\t"
  append exelocal {unlink $(prefix)/inc/config.h;}
  append exelocal " \\\n"
  append exelocal "\tfi\n"
  append exelocal "\t"
  append exelocal {cd $(prefix)/inc && ln -s ../config.h config.h}
  append exelocal "\n"
  append exelocal "\t"
  append exelocal {cd $(top_srcdir) && cp *.sh $(prefix)}
  append exelocal "\n"
  append exelocal "\n"

  append amstring $exelocal
  append amstring $phony

  regsub -all -- {__ENABLEMODULES__} $acstring $enablestr acstring
  regsub -all -- {__CONFMODULES__} $acstring $confstr acstring
  regsub -all -- {__CONDMODULES__} $acstring $condstr acstring
  regsub -all -- {__REPMODULES__} $acstring $repstr acstring
  regsub -all -- {__ACCONFMODULES__} $acstring $acconfstr acstring

  wokUtils:FILES:StringToFile $amstring [set fmam [file join $dir Makefile.am]]
  wokUtils:FILES:StringToFile $acstring [set fmam [file join $dir configure.ac]]
  file copy -force -- [file join $::env(WOK_LIBRARY)/templates build_configure] [file join $dir build_configure]
  file copy -force -- [file join $::env(WOK_LIBRARY)/templates acinclude.m4] [file join $dir acinclude.m4]
  file copy -force -- [file join $::env(WOK_LIBRARY)/templates custom.sh.in] [file join $dir custom.sh.in]
  return [list $fmam]
}

;#
;#  ((((((((((((( Formats in Makefile.am )))))))))))))
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
  set CXXCOMMON  [lindex [wokparam -e  %CMPLRS_CXX_Options [wokcd]] 0]
  set FoundFlag "[lindex [osutils:intersect3 [split [lindex [wokparam -v %CMPLRS_CXX_Options [w_info -f]] 0]] [split [lindex [wokparam -v %CMPLRS_CXX_Options] 0]] ] 2]"
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
  set FoundFlag "[lindex [osutils:intersect3 [split [lindex [wokparam -v %CMPLRS_C_Options [w_info -f]] 0]] [split [lindex [wokparam -v %CMPLRS_C_Options] 0]] ] 2]"
  foreach pk $ppk {
    if {[lsearch [uinfo -f -T source [woklocate -u $pk]] ${pk}_CMPLRS.edl] != "-1"} {
      set aPkList   [split "[lindex [wokparam -e %CMPLRS_C_Options [woklocate -u $pk]] 0]" " "]
      set aCcomList [split "$CCOMMON" " "]

      foreach aPkItem $aPkList {
        if { [lsearch aCcomList $aPkItem] != -1 } {
          if {[string first "-I" $aPkItem] == "-1"  } {
            set FoundFlag "$FoundFlag $aPkItem"
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
proc osutils:am:__LIBADD__ { theIncToolkits {final 0} } {

  set aCurrentWorkBench [wokinfo -w]
  while { "[w_info -f]" != "" } {
    wokcd [w_info -f]
  }
  set aOriginModules [w_info -k]
  wokcd $aCurrentWorkBench

  set aLibString ""
  
  foreach aIncToolkit $theIncToolkits {
    if { [lsearch $aOriginModules $aIncToolkit] != -1} {
      append aLibString " \\\n-l$aIncToolkit"
    } else {
      append aLibString " \\\n../$aIncToolkit/lib$aIncToolkit.la"
    }
  }

  return $aLibString
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

proc osutils:mkCollectScript { theOutCfgFileName theProjectRootPath theIDE theBitness theBuildType } {
  set aCfgFileBuff [list]

  lappend aCfgFileBuff "cmdArg1=${theIDE}"
  lappend aCfgFileBuff "cmdArg2=${theBitness}"
  lappend aCfgFileBuff "cmdArg3=${theBuildType}"

  set aCfgFile [open [set fdsw [file join ${theProjectRootPath} $theOutCfgFileName]] w]
  fconfigure $aCfgFile -translation crlf
  puts $aCfgFile [join $aCfgFileBuff "\n"]
  close $aCfgFile
}

# Auxiliary function to achieve complete information to build Toolkit
# @param theRelativePath - relative path to CASROOT
# @param theToolKit      - Toolkit name
# @param theUsedLib      - dependencies (libraries  list)
# @param theFrameworks   - dependencies (frameworks list, Mac OS X specific)
# @param theIncPaths     - header search paths
# @param theTKDefines    - compiler macro definitions
# @param theTKSrcFiles   - list of source files
proc osutils:tkinfo { theRelativePath theToolKit theUsedLib theFrameworks theIncPaths theTKDefines theTKSrcFiles } {
  set aWokStation "$::env(WOKSTATION)"

  # collect list of referred libraries to link with
  upvar $theUsedLib    aUsedLibs
  upvar $theFrameworks aFrameworks
  upvar $theIncPaths   anIncPaths
  upvar $theTKDefines  aTKDefines
  upvar $theTKSrcFiles aTKSrcFiles

  set aDepToolkits [wokUtils:LIST:Purge [osutils:tk:close [woklocate -u $theToolKit]]]
  foreach tkx $aDepToolkits {
    lappend aUsedLibs "${tkx}"
  }

  wokparam -l CSF

  foreach tk [lappend aDepToolkits $theToolKit] {
    foreach element [osutils:tk:hascsf [woklocate -p ${tk}:source:EXTERNLIB [wokcd]]] {
      if {[wokparam -t %$element] == 0} {
        continue
      }
      set isFrameworkNext 0
      foreach fl [split [wokparam -v %$element] \{\ \}] {
        if {[string first "-libpath" $fl] != "-1"} {
          # this is library search path, not the library name
          continue
        } elseif {[string first "-framework" $fl] != "-1"} {
          set isFrameworkNext 1
          continue
        }

        set felem [file tail $fl]
        if {$isFrameworkNext == 1} {
          if {[lsearch $aFrameworks $felem] == "-1"} {
            lappend aFrameworks "${felem}"
          }
          set isFrameworkNext 0
        } elseif {[lsearch $aUsedLibs $felem] == "-1"} {
          if {$felem != "\{\}" & $felem != "lib"} {
            if {[lsearch -nocase [osutils:optinal_libs] $felem] == -1} {
              lappend aUsedLibs [string trimleft "${felem}" "-l"]
            }
          }
        }
      }
    }
  }

  lappend anIncPaths "$theRelativePath/inc"
  set listloc [osutils:tk:units [woklocate -u $theToolKit]]

  if { [llength $listloc] == 0 } {
    set listloc [woklocate -u $theToolKit]
  }

  if { "$aWokStation" == "wnt" } {
    set resultloc [osutils:justwnt  $listloc]
  } else {
    set resultloc [osutils:justunix $listloc]
  }
  if [array exists written] { unset written }
  foreach fxlo $resultloc {
    set xlo       [wokinfo -n $fxlo]
    set aSrcFiles [osutils:tk:files $xlo osutils:compilable 0]
    foreach aSrcFile [lsort $aSrcFiles] {
      if { ![info exists written([file tail $aSrcFile])] } {
        set written([file tail $aSrcFile]) 1
        lappend aTKSrcFiles "${theRelativePath}/[wokUtils:FILES:wtail $aSrcFile 3]"
      } else {
        puts "Warning : more than one occurences for [file tail $aSrcFile]"
      }
    }

    # macros for correct DLL exports
    if { "$aWokStation" == "wnt" } {
      lappend aTKDefines "__${xlo}_DLL"
    }

    # common include paths
    lappend anIncPaths "${theRelativePath}/drv/${xlo}"
    lappend anIncPaths "${theRelativePath}/src/${xlo}"
  }

  # macros for UNIX to use config.h file
  lappend aTKDefines "CSFDB"
  if { "$aWokStation" == "wnt" } {
    lappend aTKDefines "WNT"
    lappend aTKDefines "_CRT_SECURE_NO_DEPRECATE"
  } else {
    lappend aTKDefines "HAVE_WOK_CONFIG_H"
    lappend aTKDefines "HAVE_CONFIG_H"
    if { "$aWokStation" == "lin" } {
      lappend aTKDefines "LIN"
    }
    lappend aTKDefines "OCC_CONVERT_SIGNALS"
    #lappend aTKDefines "_GNU_SOURCE=1"
  }
}

proc osutils:commonUsedTK { theToolKit } {
  set anUsedToolKits [list]
  set aDepToolkits [LibToLink [woklocate -u $theToolKit]]
  foreach tkx $aDepToolkits {
    if {[uinfo -t [woklocate -u $tkx]] == "toolkit"} {
      lappend anUsedToolKits "${tkx}"
    }
  }

  return $anUsedToolKits
}

proc osutils:csfList { theOS  theCsfMap } {
  upvar $theCsfMap aCsfMap

  unset theCsfMap

  if { "$theOS" == "wnt" } {
    # -- WinAPI libraries
    set aCsfMap(CSF_kernel32)   "kernel32.lib"
    set aCsfMap(CSF_advapi32)   "advapi32.lib"
    set aCsfMap(CSF_gdi32)      "gdi32.lib"
    set aCsfMap(CSF_user32)     "user32.lib"
    set aCsfMap(CSF_glu32)      "glu32.lib"
    set aCsfMap(CSF_opengl32)   "opengl32.lib"
    set aCsfMap(CSF_wsock32)    "wsock32.lib"
    set aCsfMap(CSF_netapi32)   "netapi32.lib"
    set aCsfMap(CSF_AviLibs)    "ws2_32.lib vfw32.lib"
    set aCsfMap(CSF_OpenGlLibs) "opengl32.lib glu32.lib"

    # -- 3rd-parties precompiled libraries
    set aCsfMap(CSF_TclLibs)    "tcl85.lib"
    set aCsfMap(CSF_TclTkLibs)  "tk85.lib"
    set aCsfMap(CSF_QT)         "QtCore4.lib QtGui4.lib"

  } else {

    if { "$theOS" == "lin" } {
      set aCsfMap(CSF_ThreadLibs) "pthread rt"
      set aCsfMap(CSF_XwLibs)     "X11 Xext Xmu Xi"
      set aCsfMap(CSF_OpenGlLibs) "GLU GL"

    } elseif { "$theOS" == "mac" } {
      set aCsfMap(CSF_objc)     "objc"

      # frameworks
      set aCsfMap(CSF_Appkit)     "Appkit"
      set aCsfMap(CSF_IOKit)      "IOKit"
      set aCsfMap(CSF_OpenGlLibs) "OpenGL"
    }

    set aCsfMap(CSF_MotifLibs)  "X11"

    #-- Tcl/Tk configuration
    set aCsfMap(CSF_TclLibs)    "tcl8.5"
    set aCsfMap(CSF_TclTkLibs)  "tk8.5 X11"

    # variable is required for support for OCCT version that use fgtl
    #-- FTGL (font renderer for OpenGL)
    set aCsfMap(CSF_FTGL)       "ftgl"
    
    #-- FreeType
    set aCsfMap(CSF_FREETYPE)   "freetype"

    #-- optional 3rd-parties
    #-- TBB
    set aCsfMap(CSF_TBB)            "tbb tbbmalloc"

    #-- FreeImage
    set aCsfMap(CSF_FreeImagePlus)  "freeimage"

    #-- GL2PS
    set aCsfMap(CSF_GL2PS)          "gl2ps"
  }
}

proc osutils:usedOsLibs { theToolKit theOS } {
  set aUsedLibs [list]

  osutils:csfList $theOS anOsCsfList

  foreach element [osutils:tk:hascsf [woklocate -p ${theToolKit}:source:EXTERNLIB [wokcd]]] {
    # test if variable is not setted - continue
    if ![info exists anOsCsfList($element)] {
      continue
    }

    foreach aLib [split "$anOsCsfList($element)"] {
      if { [lsearch $aUsedLibs $aLib] == "-1"} {
        lappend aUsedLibs $aLib
      }
    }
  }

  return $aUsedLibs
}

proc osutils:incpaths { theUnits theRelatedPath } {
  set anIncPaths [list]

  foreach anUnit $theUnits {
    lappend anIncPaths "${theRelatedPath}/drv/${anUnit}"
    lappend anIncPaths "${theRelatedPath}/src/${anUnit}"
  }

  return $anIncPaths
}

proc osutils:tksrcfiles { theUnits  theRelatedPath } {
  set aTKSrcFiles [list]

  if [array exists written] { unset written }
  foreach anUnit $theUnits {
    set xlo       [wokinfo -n $anUnit]
    set aSrcFiles [osutils:tk:files $xlo osutils:compilable 0]
    foreach aSrcFile [lsort $aSrcFiles] {
      if { ![info exists written([file tail $aSrcFile])] } {
        set written([file tail $aSrcFile]) 1
        lappend aTKSrcFiles "${theRelatedPath}/[wokUtils:FILES:wtail $aSrcFile 3]"
      } else {
        puts "Warning : more than one occurences for [file tail $aSrcFile]"
      }
    }
  }

  return $aTKSrcFiles
}

proc osutils:tkdefs { theUnits } {
  set aTKDefines [list]

  foreach anUnit $theUnits {
    lappend aTKDefines "__${anUnit}_DLL"
  }

  return $aTKDefines
}

proc osutils:fileGroupName { theSrcFile } {
  set path [file dirname [file normalize ${theSrcFile}]]
  regsub -all [file normalize "${path}/.."] ${path} "" aGroupName

  return $aGroupName
}

proc osutils:cmktk { theOutDir theToolKit {theIsExec false} theModule} {
  set anOutFileName "CMakeLists.txt"

  set anCommonUsedToolKits [osutils:commonUsedTK  $theToolKit]
  set anUsedWntLibs        [osutils:usedOsLibs $theToolKit "wnt"]
  set anUsedUnixLibs       [osutils:usedOsLibs $theToolKit "lin"]
  set anUsedMacLibs        [osutils:usedOsLibs $theToolKit "mac"]

  set anUnits [list]
  foreach anUnitWithPath [osutils:tk:units [woklocate -u $theToolKit]] {
    lappend anUnits [wokinfo -n $anUnitWithPath]
  }

  if { [llength $anUnits] == 0 } {
    set anUnits [wokinfo -n [woklocate -u $theToolKit]]
  }

  set anCommonUnits [list]
  set aWntUnits     [osutils:justwnt  $anUnits]
  set anUnixUnits   [osutils:justunix  $anUnits]


  #remove duplicates from wntUnits and unixUnits and collect these duplicates in commonUnits variable
  foreach aWntUnit $aWntUnits {
    if { [set anIndex [lsearch -exact $anUnixUnits $aWntUnit]] != -1 } {
      #add to common list
      lappend anCommonUnits $aWntUnit

      #remove from wnt list
      set anUnixUnits [lreplace $anUnixUnits $anIndex $anIndex]

      #remove from unix list
      set anIndex [lsearch -exact $aWntUnits $aWntUnit]
      set aWntUnits [lreplace $aWntUnits $anIndex $anIndex]
    }
  }

  set aRelatedPath [relativePath "$theOutDir/$theToolKit" [pwd]]

  set anCommonIncPaths  [osutils:incpaths $anCommonUnits $aRelatedPath]
  set anWntIncPaths     [osutils:incpaths $aWntUnits $aRelatedPath]
  set anUnixIncPaths    [osutils:incpaths $anUnixUnits $aRelatedPath]

  set aCommonTKSrcFiles [osutils:tksrcfiles $anCommonUnits $aRelatedPath]
  set aWntTKSrcFiles    [osutils:tksrcfiles $aWntUnits  $aRelatedPath]
  set aUnixTKSrcFiles   [osutils:tksrcfiles $anUnixUnits $aRelatedPath]

  set aFileBuff [list "project(${theToolKit})\n"]

  # macros for wnt
  lappend aFileBuff "if (WIN32)"
  foreach aMacro [osutils:tkdefs [concat $anCommonUnits $aWntUnits]] {
    lappend aFileBuff "  list( APPEND ${theToolKit}_PRECOMPILED_DEFS \"-D${aMacro}\" )"
  }
  lappend aFileBuff "  string( REGEX REPLACE \";\" \" \" ${theToolKit}_PRECOMPILED_DEFS \"\$\{${theToolKit}_PRECOMPILED_DEFS\}\")"
  lappend aFileBuff "endif()"
  lappend aFileBuff ""

  # compiler directories
  lappend aFileBuff "  list( APPEND ${theToolKit}_COMPILER_DIRECTORIES \"\$\{WOK_LIB_PATH\}\" )"
  lappend aFileBuff "  list( APPEND ${theToolKit}_COMPILER_DIRECTORIES \"$aRelatedPath/inc\" )"
  foreach anCommonIncPath $anCommonIncPaths {
    lappend aFileBuff "  list( APPEND ${theToolKit}_COMPILER_DIRECTORIES \"$anCommonIncPath\" )"
  }
    lappend aFileBuff ""
  lappend aFileBuff "if (WIN32)"
  foreach anWntIncPath $anWntIncPaths {
    lappend aFileBuff "  list( APPEND ${theToolKit}_COMPILER_DIRECTORIES \"$anWntIncPath\" )"
  }
  lappend aFileBuff "else()"
  foreach anUnixIncPath $anUnixIncPaths {
    lappend aFileBuff "  list( APPEND ${theToolKit}_COMPILER_DIRECTORIES \"$anUnixIncPath\" )"
  }
  lappend aFileBuff "endif()"
  lappend aFileBuff ""

  # used libs
  foreach anCommonUsedToolKit $anCommonUsedToolKits {
    if { $anCommonUsedToolKit != "" } {
      lappend aFileBuff "  list( APPEND ${theToolKit}_USED_LIBS ${anCommonUsedToolKit} )"
    }
  }

  lappend aFileBuff "\nif (WIN32)"
  foreach anUsedWntLib $anUsedWntLibs {
    if { $anUsedWntLib != "" } {
      lappend aFileBuff "  list( APPEND ${theToolKit}_USED_LIBS ${anUsedWntLib} )"
    }
  }
  lappend aFileBuff "elseif(APPLE)"
  foreach anUsedMacLib $anUsedMacLibs {
    if { $anUsedMacLib == "tbb" || $anUsedMacLib == "tbbmalloc" } {
      lappend aFileBuff "  if(3RDPARTY_USE_TBB)"
      lappend aFileBuff "    list( APPEND ${theToolKit}_USED_LIBS ${anUsedMacLib} )"
      lappend aFileBuff "  endif()"
    } elseif { $anUsedMacLib == "freeimage" } {
      lappend aFileBuff "  if(3RDPARTY_USE_FREEIMAGE)"
      lappend aFileBuff "    list( APPEND ${theToolKit}_USED_LIBS ${anUsedMacLib} )"
      lappend aFileBuff "  endif()"
    } elseif { $anUsedMacLib == "gl2ps" } {
      lappend aFileBuff "  if(3RDPARTY_USE_GL2PS)"
      lappend aFileBuff "    list( APPEND ${theToolKit}_USED_LIBS ${anUsedMacLib} )"
      lappend aFileBuff "  endif()"
    } elseif { $anUsedMacLib == "X11" } {
      lappend aFileBuff "  if(3RDPARTY_USE_GLX)"
      lappend aFileBuff "    find_package(X11 COMPONENTS X11 Xext Xmu Xi)"
      lappend aFileBuff "    list( APPEND ${theToolKit}_USED_LIBS \$\{X11_LIBRARIES\} )"
      lappend aFileBuff "    list( APPEND ${theToolKit}_USED_LIBS \$\{X11_Xi_LIB\} )"
      lappend aFileBuff "    list( APPEND ${theToolKit}_USED_LIBS \$\{X11_Xmu_LIB\} )"
      lappend aFileBuff "  endif()"
    } elseif { $anUsedMacLib == "Appkit" } {
      lappend aFileBuff "  find_library(FRAMEWORKS_APPKIT NAMES Appkit)"
      lappend aFileBuff "  list( APPEND ${theToolKit}_USED_LIBS \$\{FRAMEWORKS_APPKIT\} )"
    } elseif { $anUsedMacLib == "IOKit" } {
      lappend aFileBuff "  find_library(FRAMEWORKS_IOKIT NAMES IOKit)"
      lappend aFileBuff "  list( APPEND ${theToolKit}_USED_LIBS \$\{FRAMEWORKS_IOKIT\} )"
    } elseif { $anUsedMacLib == "OpenGL" } {
      lappend aFileBuff "  find_library(FRAMEWORKS_OPENGL NAMES OpenGL)"
      lappend aFileBuff "  if(3RDPARTY_USE_GLX)"
      lappend aFileBuff "    list( APPEND ${theToolKit}_USED_LIBS GL )"
      lappend aFileBuff "    list( APPEND ${theToolKit}_USED_LIBS GLU )"
      lappend aFileBuff "  else()"
      lappend aFileBuff "    list( APPEND ${theToolKit}_USED_LIBS \$\{FRAMEWORKS_OPENGL\} )"
      lappend aFileBuff "  endif()"
    } elseif { $anUsedMacLib != "" } {
      lappend aFileBuff "  list( APPEND ${theToolKit}_USED_LIBS ${anUsedMacLib} )"
    }
  }
  lappend aFileBuff "else()"
  foreach anUsedUnixLib $anUsedUnixLibs {
    if { $anUsedUnixLib == "tbb" || $anUsedUnixLib == "tbbmalloc" } {
      lappend aFileBuff "  if(3RDPARTY_USE_TBB)"
      lappend aFileBuff "    list( APPEND ${theToolKit}_USED_LIBS ${anUsedUnixLib} )"
      lappend aFileBuff "  endif()"
    } elseif { $anUsedUnixLib == "freeimage" } {
      lappend aFileBuff "  if(3RDPARTY_USE_FREEIMAGE)"
      lappend aFileBuff "    list( APPEND ${theToolKit}_USED_LIBS ${anUsedUnixLib} )"
      lappend aFileBuff "  endif()"
    } elseif { $anUsedUnixLib == "gl2ps" } {
      lappend aFileBuff "  if(3RDPARTY_USE_GL2PS)"
      lappend aFileBuff "    list( APPEND ${theToolKit}_USED_LIBS ${anUsedUnixLib} )"
      lappend aFileBuff "  endif()"
    } elseif { $anUsedUnixLib != "" } {
      lappend aFileBuff "  list( APPEND ${theToolKit}_USED_LIBS ${anUsedUnixLib} )"
    }
  }
  lappend aFileBuff "endif()\n"

  #used source files
  foreach aCommonTKSrcFile $aCommonTKSrcFiles {
    lappend aFileBuff "  list( APPEND ${theToolKit}_USED_SRCFILES \"${aCommonTKSrcFile}\" )"
    lappend aFileBuff "  SOURCE_GROUP ([string range [osutils:fileGroupName $aCommonTKSrcFile] 1 end] FILES \"${aCommonTKSrcFile}\")\n"
  }

  lappend aFileBuff "if (WIN32)"
  foreach aWntTKSrcFile $aWntTKSrcFiles {
    lappend aFileBuff "  list( APPEND ${theToolKit}_USED_SRCFILES \"${aWntTKSrcFile}\" )"
    lappend aFileBuff "  SOURCE_GROUP ([string range [osutils:fileGroupName $aWntTKSrcFile] 1 end] FILES \"${aWntTKSrcFile}\")\n"
  }
  lappend aFileBuff "else()\n"
  foreach aUnixTKSrcFile $aUnixTKSrcFiles {
    lappend aFileBuff "  list( APPEND ${theToolKit}_USED_SRCFILES \"${aUnixTKSrcFile}\" )"
    lappend aFileBuff "  SOURCE_GROUP ([string range [osutils:fileGroupName $aUnixTKSrcFile] 1 end] FILES \"${aUnixTKSrcFile}\")\n"
  }
  lappend aFileBuff "endif()\n"

  #install instrutions
  lappend aFileBuff "if (\"\$\{USED_TOOLKITS\}\" STREQUAL \"\" OR DEFINED TurnONthe${theToolKit})"
  if { $theIsExec == true } {
    lappend aFileBuff " add_executable( ${theToolKit} \$\{${theToolKit}_USED_SRCFILES\} )"
    lappend aFileBuff ""
    lappend aFileBuff " set_property(TARGET ${theToolKit} PROPERTY FOLDER ${theModule})"
    lappend aFileBuff ""
    lappend aFileBuff " install( TARGETS ${theToolKit} DESTINATION \"\$\{INSTALL_DIR\}/bin\" )"
  } else {
    lappend aFileBuff " add_library( ${theToolKit} SHARED \$\{${theToolKit}_USED_SRCFILES\} )"
    lappend aFileBuff ""
    lappend aFileBuff " set_property(TARGET ${theToolKit} PROPERTY FOLDER ${theModule})"
    lappend aFileBuff ""
    lappend aFileBuff " install( TARGETS ${theToolKit}
                                 RUNTIME DESTINATION \"\$\{INSTALL_DIR\}/bin\"
                                 ARCHIVE DESTINATION \"\$\{INSTALL_DIR\}/lib\"
                                 LIBRARY DESTINATION \"\$\{INSTALL_DIR\}/lib\")"
    lappend aFileBuff ""
    lappend aFileBuff " if (MSVC)"
    lappend aFileBuff "  install( FILES  \$\{CMAKE_BINARY_DIR\}/out/bin/Debug/${theToolKit}.pdb CONFIGURATIONS Debug
                                  DESTINATION \"\$\{INSTALL_DIR\}/bin\")"
    lappend aFileBuff " endif()"
    lappend aFileBuff ""
  }
  lappend aFileBuff ""
  lappend aFileBuff " set_target_properties( ${theToolKit} PROPERTIES COMPILE_FLAGS \"\$\{${theToolKit}_PRECOMPILED_DEFS\}\" )"
  lappend aFileBuff " include_directories( \$\{${theToolKit}_COMPILER_DIRECTORIES\} )"
  lappend aFileBuff " target_link_libraries( ${theToolKit} \$\{${theToolKit}_USED_LIBS\} )"
  lappend aFileBuff "endif()"

  #generate cmake meta file
  set aFile [open "$theOutDir/$theToolKit/$anOutFileName" w]
  fconfigure $aFile -translation crlf
  puts $aFile [join $aFileBuff "\n"]
  close $aFile
}

# Generate Code::Blocks project file for ToolKit
proc osutils:cbptk { theOutDir theToolKit } {
  set aUsedToolKits [list]
  set aFrameworks   [list]
  set anIncPaths    [list]
  set aTKDefines    [list]
  set aTKSrcFiles   [list]

  osutils:tkinfo "../../.." $theToolKit aUsedToolKits aFrameworks anIncPaths aTKDefines aTKSrcFiles

  return [osutils:cbp $theOutDir $theToolKit $aTKSrcFiles $aUsedToolKits $aFrameworks $anIncPaths $aTKDefines]
}

# Generate Code::Blocks project file for Executable
proc osutils:cbpx { theOutDir theToolKit } {
  set aWokStation "$::env(WOKSTATION)"
  set aWokArch    "$::env(ARCH)"

  set aCbpFiles {}
  foreach aSrcFile [osutils:tk:files $theToolKit osutils:compilable 0] {
    # collect list of referred libraries to link with
    set aUsedToolKits [list]
    set aFrameworks   [list]
    set anIncPaths    [list]
    set aTKDefines    [list]
    set aTKSrcFiles   [list]
    set aProjName [file rootname [file tail $aSrcFile]]

    set aDepToolkits [LibToLinkX [woklocate -u $theToolKit] $aProjName]
    foreach tkx $aDepToolkits {
      if {[uinfo -t [woklocate -u $tkx]] == "toolkit"} {
        lappend aUsedToolKits "${tkx}"
      }
      if {[lsearch [w_info -l] $tkx] == "-1"} {
        lappend aUsedToolKits "${tkx}"
      }
    }

    wokparam -l CSF

    foreach tk $aDepToolkits {
      foreach element [osutils:tk:hascsf [woklocate -p ${tk}:source:EXTERNLIB [wokcd]]] {
        if {[wokparam -t %$element] == 0} {
          continue
        }
        set isFrameworkNext 0
        foreach fl [split [wokparam -v %$element] \{\ \}] {
          if {[string first "-libpath" $fl] != "-1"} {
            # this is library search path, not the library name
            continue
          } elseif {[string first "-framework" $fl] != "-1"} {
            set isFrameworkNext 1
            continue
          }

          set felem [file tail $fl]
          if {$isFrameworkNext == 1} {
            if {[lsearch $aFrameworks $felem] == "-1"} {
              lappend aFrameworks "${felem}"
            }
            set isFrameworkNext 0
          } elseif {[lsearch $aUsedToolKits $felem] == "-1"} {
            if {$felem != "\{\}" & $felem != "lib"} {
              if {[lsearch -nocase [osutils:optinal_libs] $felem] == -1} {
                lappend aUsedToolKits [string trimleft "${felem}" "-l"]
              }
            }
          }
        }
      }
    }

    set WOKSteps_exec_link [wokparam -v %WOKSteps_exec_link [woklocate -u $theToolKit]]
    if { [regexp {WOKStep_DLLink} $WOKSteps_exec_link] || [regexp {WOKStep_Libink} $WOKSteps_exec_link] } {
      set isExecutable "false"
    } else {
      set isExecutable "true"
    }

    if { ![info exists written([file tail $aSrcFile])] } {
      set written([file tail $aSrcFile]) 1
      lappend aTKSrcFiles $aSrcFile
    } else {
      puts "Warning : in cbp there are more than one occurences for [file tail $aSrcFile]"
    }

    # macros for correct DLL exports
    if { "$aWokStation" == "wnt" } {
      lappend aTKDefines "__${theToolKit}_DLL"
    }

    # common include paths
    lappend anIncPaths "../../../inc"
    lappend anIncPaths "../../../drv/${theToolKit}"
    lappend anIncPaths "../../../src/${theToolKit}"

    # macros for UNIX to use config.h file
    lappend aTKDefines "CSFDB"
    if { "$aWokStation" == "wnt" } {
      lappend aTKDefines "WNT"
      lappend aTKDefines "_CRT_SECURE_NO_DEPRECATE"
    } else {
      lappend aTKDefines "HAVE_WOK_CONFIG_H"
      lappend aTKDefines "HAVE_CONFIG_H"
      if { "$aWokStation" == "lin" } {
        lappend aTKDefines "LIN"
      }
      lappend aTKDefines "OCC_CONVERT_SIGNALS"
      #lappend aTKDefines "_GNU_SOURCE=1"
    }

    lappend aCbpFiles [osutils:cbp $theOutDir $aProjName $aTKSrcFiles $aUsedToolKits $aFrameworks $anIncPaths $aTKDefines $isExecutable]
  }

  return $aCbpFiles
}

# This function intended to generate Code::Blocks project file
# @param theOutDir     - output directory to place project file
# @param theProjName   - project name
# @param theSrcFiles   - list of source files
# @param theLibsList   - dependencies (libraries  list)
# @param theFrameworks - dependencies (frameworks list, Mac OS X specific)
# @param theIncPaths   - header search paths
# @param theDefines    - compiler macro definitions
# @param theIsExe      - flag to indicate executable / library target
proc osutils:cbp { theOutDir theProjName theSrcFiles theLibsList theFrameworks theIncPaths theDefines {theIsExe "false"} } {
  set aWokStation "$::env(WOKSTATION)"
  set aWokArch    "$::env(ARCH)"

  set aCbpFilePath "${theOutDir}/${theProjName}.cbp"
  set aFile [open $aCbpFilePath "w"]
  puts $aFile "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\" ?>"
  puts $aFile "<CodeBlocks_project_file>"
  puts $aFile "\t<FileVersion major=\"1\" minor=\"6\" />"
  puts $aFile "\t<Project>"
  puts $aFile "\t\t<Option title=\"$theProjName\" />"
  puts $aFile "\t\t<Option pch_mode=\"2\" />"
  if { "$aWokStation" == "wnt" } {
    puts $aFile "\t\t<Option compiler=\"msvc8\" />"
  } else {
    puts $aFile "\t\t<Option compiler=\"gcc\" />"
  }
  puts $aFile "\t\t<Build>"

  # Release target configuration
  puts $aFile "\t\t\t<Target title=\"Release\">"
  if { "$theIsExe" == "true" } {
    puts $aFile "\t\t\t\t<Option output=\"../../../${aWokStation}/cbp/bin/${theProjName}\" prefix_auto=\"1\" extension_auto=\"1\" />"
    puts $aFile "\t\t\t\t<Option type=\"1\" />"
  } else {
    if { "$aWokStation" == "wnt" } {
      puts $aFile "\t\t\t\t<Option output=\"../../../${aWokStation}/cbp/lib/${theProjName}\" prefix_auto=\"1\" extension_auto=\"1\" />"
    } else {
      puts $aFile "\t\t\t\t<Option output=\"../../../${aWokStation}/cbp/lib/lib${theProjName}\" prefix_auto=\"1\" extension_auto=\"1\" />"
    }
    puts $aFile "\t\t\t\t<Option type=\"3\" />"
  }
  puts $aFile "\t\t\t\t<Option object_output=\"../../../${aWokStation}/cbp/obj\" />"
  if { "$aWokStation" == "wnt" } {
    puts $aFile "\t\t\t\t<Option compiler=\"msvc8\" />"
  } else {
    puts $aFile "\t\t\t\t<Option compiler=\"gcc\" />"
  }
  puts $aFile "\t\t\t\t<Option createDefFile=\"1\" />"
  puts $aFile "\t\t\t\t<Option createStaticLib=\"1\" />"

  # compiler options per TARGET (including defines)
  puts $aFile "\t\t\t\t<Compiler>"
  if { "$aWokStation" == "wnt" } {
    puts $aFile "\t\t\t\t\t<Add option=\"-MD\" />"
    puts $aFile "\t\t\t\t\t<Add option=\"-EHsc\" />"
    puts $aFile "\t\t\t\t\t<Add option=\"-O2\" />"
    puts $aFile "\t\t\t\t\t<Add option=\"-W3\" />"
    puts $aFile "\t\t\t\t\t<Add option=\"-MP\" />"
  } else {
    puts $aFile "\t\t\t\t\t<Add option=\"-O2\" />"
  }
  foreach aMacro $theDefines {
    puts $aFile "\t\t\t\t\t<Add option=\"-D${aMacro}\" />"
  }
  puts $aFile "\t\t\t\t\t<Add option=\"-DNDEBUG\" />"
  puts $aFile "\t\t\t\t\t<Add option=\"-DNo_Exception\" />"

  puts $aFile "\t\t\t\t</Compiler>"

  puts $aFile "\t\t\t\t<Linker>"
  puts $aFile "\t\t\t\t\t<Add directory=\"../../../${aWokStation}/cbp/lib\" />"
  if { "$aWokStation" == "mac" && [ lsearch $theLibsList X11 ] >= 0} {
    puts $aFile "\t\t\t\t\t<Add directory=\"/usr/X11/lib\" />"
  }
  puts $aFile "\t\t\t\t\t<Add option=\"\$(CSF_OPT_LNK${aWokArch})\" />"
  puts $aFile "\t\t\t\t</Linker>"

  puts $aFile "\t\t\t</Target>"

  # Debug target configuration
  puts $aFile "\t\t\t<Target title=\"Debug\">"
  if { "$theIsExe" == "true" } {
    puts $aFile "\t\t\t\t<Option output=\"../../../${aWokStation}/cbp/bind/${theProjName}\" prefix_auto=\"1\" extension_auto=\"1\" />"
    puts $aFile "\t\t\t\t<Option type=\"1\" />"
  } else {
    if { "$aWokStation" == "wnt" } {
      puts $aFile "\t\t\t\t<Option output=\"../../../${aWokStation}/cbp/libd/${theProjName}\" prefix_auto=\"1\" extension_auto=\"1\" />"
    } else {
      puts $aFile "\t\t\t\t<Option output=\"../../../${aWokStation}/cbp/libd/lib${theProjName}\" prefix_auto=\"1\" extension_auto=\"1\" />"
    }
    puts $aFile "\t\t\t\t<Option type=\"3\" />"
  }
  puts $aFile "\t\t\t\t<Option object_output=\"../../../${aWokStation}/cbp/objd\" />"
  if { "$aWokStation" == "wnt" } {
    puts $aFile "\t\t\t\t<Option compiler=\"msvc8\" />"
  } else {
    puts $aFile "\t\t\t\t<Option compiler=\"gcc\" />"
  }
  puts $aFile "\t\t\t\t<Option createDefFile=\"1\" />"
  puts $aFile "\t\t\t\t<Option createStaticLib=\"1\" />"

  # compiler options per TARGET (including defines)
  puts $aFile "\t\t\t\t<Compiler>"
  if { "$aWokStation" == "wnt" } {
    puts $aFile "\t\t\t\t\t<Add option=\"-MDd\" />"
    puts $aFile "\t\t\t\t\t<Add option=\"-EHsc\" />"
    puts $aFile "\t\t\t\t\t<Add option=\"-Od\" />"
    puts $aFile "\t\t\t\t\t<Add option=\"-Zi\" />"
    puts $aFile "\t\t\t\t\t<Add option=\"-W3\" />"
    puts $aFile "\t\t\t\t\t<Add option=\"-MP\" />"
  } else {
    puts $aFile "\t\t\t\t\t<Add option=\"-O0\" />"
    puts $aFile "\t\t\t\t\t<Add option=\"-g\" />"
  }
  foreach aMacro $theDefines {
    puts $aFile "\t\t\t\t\t<Add option=\"-D${aMacro}\" />"
  }
  puts $aFile "\t\t\t\t\t<Add option=\"-D_DEBUG\" />"
  puts $aFile "\t\t\t\t\t<Add option=\"-DDEB\" />"
  puts $aFile "\t\t\t\t</Compiler>"

  puts $aFile "\t\t\t\t<Linker>"
  puts $aFile "\t\t\t\t\t<Add directory=\"../../../${aWokStation}/cbp/libd\" />"
  if { "$aWokStation" == "mac" && [ lsearch $theLibsList X11 ] >= 0} {
    puts $aFile "\t\t\t\t\t<Add directory=\"/usr/X11/lib\" />"
  }
  puts $aFile "\t\t\t\t\t<Add option=\"\$(CSF_OPT_LNK${aWokArch}D)\" />"
  puts $aFile "\t\t\t\t</Linker>"

  puts $aFile "\t\t\t</Target>"

  puts $aFile "\t\t</Build>"

  # COMMON compiler options
  puts $aFile "\t\t<Compiler>"
  puts $aFile "\t\t\t<Add option=\"-Wall\" />"
  puts $aFile "\t\t\t<Add option=\"-fexceptions\" />"
  puts $aFile "\t\t\t<Add option=\"-fPIC\" />"
  puts $aFile "\t\t\t<Add option=\"\$(CSF_OPT_CMPL)\" />"
  foreach anIncPath $theIncPaths {
    puts $aFile "\t\t\t<Add directory=\"$anIncPath\" />"
  }
  puts $aFile "\t\t</Compiler>"

  # COMMON linker options
  puts $aFile "\t\t<Linker>"
  foreach aFrameworkName $theFrameworks {
    if { "$aFrameworkName" != "" } {
      puts $aFile "\t\t\t<Add option=\"-framework $aFrameworkName\" />"
    }
  }
  foreach aLibName $theLibsList {
    if { "$aLibName" != "" } {
      puts $aFile "\t\t\t<Add library=\"$aLibName\" />"
    }
  }
  puts $aFile "\t\t</Linker>"

  # list of sources
  foreach aSrcFile $theSrcFiles {
    if {[string equal -nocase [file extension $aSrcFile] ".mm"]} {
      puts $aFile "\t\t<Unit filename=\"$aSrcFile\">"
      puts $aFile "\t\t\t<Option compile=\"1\" />"
      puts $aFile "\t\t\t<Option link=\"1\" />"
      puts $aFile "\t\t</Unit>"
    } elseif {[string equal -nocase [file extension $aSrcFile] ".c"]} {
      puts $aFile "\t\t<Unit filename=\"$aSrcFile\">"
      puts $aFile "\t\t\t<Option compilerVar=\"CC\" />"
      puts $aFile "\t\t</Unit>"
    } else {
      puts $aFile "\t\t<Unit filename=\"$aSrcFile\" />"
    }
  }

  puts $aFile "\t</Project>"
  puts $aFile "</CodeBlocks_project_file>"
  close $aFile

  return $aCbpFilePath
}

# Prepare relative path
proc relativePath {thePathFrom thePathTo} {
  if { [file isdirectory "$thePathFrom"] == 0 } {
    return ""
  }

  set aPathFrom [file normalize "$thePathFrom"]
  set aPathTo   [file normalize "$thePathTo"]

  set aCutedPathFrom "${aPathFrom}/dummy"
  set aRelatedDeepPath ""

  while { "$aCutedPathFrom" != [file normalize "$aCutedPathFrom/.."] } {
    set aCutedPathFrom [file normalize "$aCutedPathFrom/.."]
    # does aPathTo contain aCutedPathFrom?
    regsub -all $aCutedPathFrom $aPathTo "" aPathFromAfterCut
    if { "$aPathFromAfterCut" != "$aPathTo" } { # if so
      if { "$aCutedPathFrom" == "$aPathFrom" } { # just go higher, for example, ./somefolder/someotherfolder
        set aPathTo ".${aPathTo}"
      } elseif { "$aCutedPathFrom" == "$aPathTo" } { # remove the last "/"
        set aRelatedDeepPath [string replace $aRelatedDeepPath end end ""]
      }
      regsub -all $aCutedPathFrom $aPathTo $aRelatedDeepPath aPathToAfterCut
      regsub -all "//" $aPathToAfterCut "/" aPathToAfterCut
      return $aPathToAfterCut
    }
    set aRelatedDeepPath "$aRelatedDeepPath../"

  }

  return $thePathTo
}

# Generates dependencies section for Xcode project files.
proc osutils:xcdtk:deps {theToolKit theTargetType theGuidsMap theFileRefSection theDepsGuids theDepsRefGuids} {
  upvar $theGuidsMap         aGuidsMap
  upvar $theFileRefSection   aFileRefSection
  upvar $theDepsGuids        aDepsGuids
  upvar $theDepsRefGuids     aDepsRefGuids

  set aBuildFileSection ""
  set aFrameworks       [list]
  set aUsedToolKits     [wokUtils:LIST:Purge [osutils:tk:close [woklocate -u $theToolKit]]]
  set aDepToolkits      [lappend [wokUtils:LIST:Purge [osutils:tk:close [woklocate -u $theToolKit]]] $theToolKit]
  
  if { "$theTargetType" == "executable" } {
    set aFile [osutils:tk:files $theToolKit osutils:compilable 0]
    set aProjName [file rootname [file tail $aFile]]
    set aDepToolkits [LibToLinkX [woklocate -u $theToolKit] $aProjName]
  }
 
  wokparam -l CSF

  foreach tk $aDepToolkits {
    foreach element [osutils:tk:hascsf [woklocate -p ${tk}:source:EXTERNLIB [wokcd]]] {
      if {[wokparam -t %$element] == 0} {
        continue
      }
      set isFrameworkNext 0
      foreach fl [split [wokparam -v %$element] \{\ \}] {
        if {[string first "-libpath" $fl] != "-1"} {
          # this is library search path, not the library name
          continue
        } elseif {[string first "-framework" $fl] != "-1"} {
          set isFrameworkNext 1
          continue
        }
        set felem [file tail $fl]
        if {$isFrameworkNext == 1} {
          lappend aFrameworks "${felem}"
          set isFrameworkNext 0
        }
        if {[lsearch $aUsedToolKits $felem] == "-1"} {
          if {$felem != "\{\}" & $felem != "lib"} {
            if {[lsearch -nocase [osutils:optinal_libs] $felem] == -1} {
              set aLibName [string trimleft "${felem}" "-l"]
              if { [string length $aLibName] > 0 && [lsearch $aUsedToolKits $aLibName] == "-1" } {
                lappend aUsedToolKits $aLibName
              }
            }
          }
        }
      }
    }
  }

  foreach tkx $aUsedToolKits {
    set aDepLib    "${tkx}_Dep"
    set aDepLibRef "${tkx}_DepRef"

    if { ! [info exists aGuidsMap($aDepLib)] } {
      set aGuidsMap($aDepLib) [OS:genGUID "xcd"]
    }
    if { ! [info exists aGuidsMap($aDepLibRef)] } {
      set aGuidsMap($aDepLibRef) [OS:genGUID "xcd"]
    }

    append aBuildFileSection "\t\t$aGuidsMap($aDepLib) = \{isa = PBXBuildFile; fileRef = $aGuidsMap($aDepLibRef) ; \};\n"
    if {[lsearch -nocase $aFrameworks $tkx] == -1} {
      append aFileRefSection   "\t\t$aGuidsMap($aDepLibRef) = \{isa = PBXFileReference; lastKnownFileType = file; name = lib${tkx}.dylib; path = lib${tkx}.dylib; sourceTree = \"<group>\"; \};\n"
    } else {
      append aFileRefSection   "\t\t$aGuidsMap($aDepLibRef) = \{isa = PBXFileReference; lastKnownFileType = wrapper.framework; name = ${tkx}.framework; path = /System/Library/Frameworks/${tkx}.framework; sourceTree = \"<absolute>\"; \};\n"
    }
    append aDepsGuids        "\t\t\t\t$aGuidsMap($aDepLib) ,\n"
    append aDepsRefGuids     "\t\t\t\t$aGuidsMap($aDepLibRef) ,\n"
  }

  return $aBuildFileSection
}

# Generates PBXBuildFile and PBXGroup sections for project file.
proc osutils:xcdtk:sources {theToolKit theTargetType theSrcFileRefSection theGroupSection thePackageGuids theSrcFileGuids theGuidsMap theIncPaths} {
  upvar $theSrcFileRefSection aSrcFileRefSection
  upvar $theGroupSection      aGroupSection
  upvar $thePackageGuids      aPackagesGuids
  upvar $theSrcFileGuids      aSrcFileGuids
  upvar $theGuidsMap          aGuidsMap
  upvar $theIncPaths          anIncPaths

  set listloc [osutils:tk:units [woklocate -u $theToolKit]]
  set resultloc [osutils:justunix $listloc]
  set aBuildFileSection ""
  set aPackages [lsort -nocase $resultloc]
  if { "$theTargetType" == "executable" } {
    set aPackages [list "$theToolKit"]
  }

  # Generating PBXBuildFile, PBXGroup sections and groups for each package.
  foreach fxlo $aPackages {
    set xlo [wokinfo -n $fxlo]
    set aPackage "${xlo}_Package"
    set aSrcFileRefGuids ""
    lappend anIncPaths "../../../drv/${xlo}"
    lappend anIncPaths "../../../src/${xlo}"
    if { ! [info exists aGuidsMap($aPackage)] } {
      set aGuidsMap($aPackage) [OS:genGUID "xcd"]
    }

    set aSrcFiles [osutils:tk:files $xlo osutils:compilable 0]
    foreach aSrcFile [lsort $aSrcFiles] {
      set aFileExt "sourcecode.cpp.cpp"

      if { [file extension $aSrcFile] == ".c" } {
        set aFileExt "sourcecode.c.c"
      } elseif { [file extension $aSrcFile] == ".mm" } {
        set aFileExt "sourcecode.cpp.objcpp"
      }

      if { ! [info exists aGuidsMap($aSrcFile)] } {
        set aGuidsMap($aSrcFile) [OS:genGUID "xcd"]
      }
      set aSrcFileRef "${aSrcFile}_Ref"
      if { ! [info exists aGuidsMap($aSrcFileRef)] } {
        set aGuidsMap($aSrcFileRef) [OS:genGUID "xcd"]
      }
      if { ! [info exists written([file tail $aSrcFile])] } {
        set written([file tail $aSrcFile]) 1
        append aBuildFileSection  "\t\t$aGuidsMap($aSrcFile) = \{isa = PBXBuildFile; fileRef = $aGuidsMap($aSrcFileRef) ;\};\n"
        append aSrcFileRefSection "\t\t$aGuidsMap($aSrcFileRef) = \{isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = ${aFileExt}; name = [wokUtils:FILES:wtail $aSrcFile 1]; path = ../../../[wokUtils:FILES:wtail $aSrcFile 3]; sourceTree = \"<group>\"; \};\n"
        append aSrcFileGuids      "\t\t\t\t$aGuidsMap($aSrcFile) ,\n"
        append aSrcFileRefGuids   "\t\t\t\t$aGuidsMap($aSrcFileRef) ,\n"
      } else {
        puts "Warning : more than one occurences for [file tail $aSrcFile]"
      }
    }

    append aGroupSection "\t\t$aGuidsMap($aPackage) = \{\n"
    append aGroupSection "\t\t\tisa = PBXGroup;\n"
    append aGroupSection "\t\t\tchildren = (\n"
    append aGroupSection $aSrcFileRefGuids
    append aGroupSection "\t\t\t);\n"
    append aGroupSection "\t\t\tname = $xlo;\n"
    append aGroupSection "\t\t\tsourceTree = \"<group>\";\n"
    append aGroupSection "\t\t\};\n"

    # Storing packages IDs for adding them later as a child of toolkit
    append aPackagesGuids "\t\t\t\t$aGuidsMap($aPackage) ,\n"
  }

  # Removing unnecessary newline character from the end.
  set aPackagesGuids [string replace $aPackagesGuids end end]

  return $aBuildFileSection
}

# Creates folders structure and all necessary files for Xcode project.
proc osutils:xcdtk { theOutDir theToolKit theGuidsMap {theTargetType "dylib"} } {
  set aPBXBuildPhase "Headers"
  set aRunOnlyForDeployment "0"
  set aProductType "library.dynamic"
  set anExecExtension "\t\t\t\tEXECUTABLE_EXTENSION = dylib;"
  set anExecPrefix "\t\t\t\tEXECUTABLE_PREFIX = lib;"
  set aWrapperExtension "\t\t\t\tWRAPPER_EXTENSION = dylib;"
  set aTKDefines [list "CSFDB" "HAVE_WOK_CONFIG_H" "HAVE_CONFIG_H" "OCC_CONVERT_SIGNALS"]

  if { "$theTargetType" == "executable" } {
    set aPBXBuildPhase "CopyFiles"
    set aRunOnlyForDeployment "1"
    set aProductType "tool"
    set anExecExtension ""
    set anExecPrefix ""
    set aWrapperExtension ""
  }

  set aUsername [exec whoami]

  # Creation of folders for Xcode projectP.
  set aToolkitDir "${theOutDir}/${theToolKit}.xcodeproj"
  OS:mkdir $aToolkitDir
  if { ! [file exists $aToolkitDir] } {
    puts stderr "Error: Could not create project directory \"$aToolkitDir\""
    return
  }

  set aUserDataDir "${aToolkitDir}/xcuserdata"
  OS:mkdir $aUserDataDir
  if { ! [file exists $aUserDataDir] } {
    puts stderr "Error: Could not create xcuserdata directorty in \"$aToolkitDir\""
    return
  }

  set aUserDataDir "${aUserDataDir}/${aUsername}.xcuserdatad"
  OS:mkdir $aUserDataDir
  if { ! [file exists $aUserDataDir] } {
    puts stderr "Error: Could not create ${aUsername}.xcuserdatad directorty in \"$aToolkitDir\"/xcuserdata"
    return
  }

  set aSchemesDir "${aUserDataDir}/xcschemes"
  OS:mkdir $aSchemesDir
  if { ! [file exists $aSchemesDir] } {
    puts stderr "Error: Could not create xcschemes directorty in \"$aUserDataDir\""
    return
  }
  # End of folders creation.

  # Generating GUID for tookit.
  upvar $theGuidsMap aGuidsMap
  if { ! [info exists aGuidsMap($theToolKit)] } {
    set aGuidsMap($theToolKit) [OS:genGUID "xcd"]
  }

  # Creating xcscheme file for toolkit from template.
  set aXcschemeTmpl [osutils:readtemplate "xcscheme" "xcd"]
  regsub -all -- {__TOOLKIT_NAME__} $aXcschemeTmpl $theToolKit aXcschemeTmpl
  regsub -all -- {__TOOLKIT_GUID__} $aXcschemeTmpl $aGuidsMap($theToolKit) aXcschemeTmpl
  set aXcschemeFile [open "$aSchemesDir/${theToolKit}.xcscheme"  "w"]
  puts $aXcschemeFile $aXcschemeTmpl
  close $aXcschemeFile

  # Creating xcschememanagement.plist file for toolkit from template.
  set aPlistTmpl [osutils:readtemplate "plist" "xcd"]
  regsub -all -- {__TOOLKIT_NAME__} $aPlistTmpl $theToolKit aPlistTmpl
  regsub -all -- {__TOOLKIT_GUID__} $aPlistTmpl $aGuidsMap($theToolKit) aPlistTmpl
  set aPlistFile [open "$aSchemesDir/xcschememanagement.plist"  "w"]
  puts $aPlistFile $aPlistTmpl
  close $aPlistFile

  # Creating project.pbxproj file for toolkit.
  set aPbxprojFile [open "$aToolkitDir/project.pbxproj" "w"]
  puts $aPbxprojFile "// !\$*UTF8*\$!"
  puts $aPbxprojFile "\{"
  puts $aPbxprojFile "\tarchiveVersion = 1;"
  puts $aPbxprojFile "\tclasses = \{"
  puts $aPbxprojFile "\t\};"
  puts $aPbxprojFile "\tobjectVersion = 46;"
  puts $aPbxprojFile "\tobjects = \{\n"

  # Begin PBXBuildFile section
  set aPackagesGuids ""
  set aGroupSection ""
  set aSrcFileRefSection ""
  set aSrcFileGuids ""
  set aDepsFileRefSection ""
  set aDepsGuids ""
  set aDepsRefGuids ""
  set anIncPaths [list "../../../inc" $::env(WOK_LIBRARY)]
  puts $aPbxprojFile [osutils:xcdtk:sources $theToolKit $theTargetType aSrcFileRefSection aGroupSection aPackagesGuids aSrcFileGuids aGuidsMap anIncPaths]
  puts $aPbxprojFile [osutils:xcdtk:deps    $theToolKit $theTargetType aGuidsMap aDepsFileRefSection aDepsGuids aDepsRefGuids]
  # End PBXBuildFile section

  # Begin PBXFileReference section
  set aToolkitLib "lib${theToolKit}.dylib"
  set aPath "$aToolkitLib"
  if { "$theTargetType" == "executable" } {
    set aPath "$theToolKit"
  }

  if { ! [info exists aGuidsMap($aToolkitLib)] } {
    set aGuidsMap($aToolkitLib) [OS:genGUID "xcd"]
  }

  puts $aPbxprojFile "\t\t$aGuidsMap($aToolkitLib) = {isa = PBXFileReference; explicitFileType = \"compiled.mach-o.${theTargetType}\"; includeInIndex = 0; path = $aPath; sourceTree = BUILT_PRODUCTS_DIR; };\n"
  puts $aPbxprojFile $aSrcFileRefSection
  puts $aPbxprojFile $aDepsFileRefSection
  # End PBXFileReference section


  # Begin PBXFrameworksBuildPhase section
  set aTkFrameworks "${theToolKit}_Frameworks"
  if { ! [info exists aGuidsMap($aTkFrameworks)] } {
    set aGuidsMap($aTkFrameworks) [OS:genGUID "xcd"]
  }

  puts $aPbxprojFile "\t\t$aGuidsMap($aTkFrameworks) = \{"
  puts $aPbxprojFile "\t\t\tisa = PBXFrameworksBuildPhase;"
  puts $aPbxprojFile "\t\t\tbuildActionMask = 2147483647;"
  puts $aPbxprojFile "\t\t\tfiles = ("
  puts $aPbxprojFile $aDepsGuids
  puts $aPbxprojFile "\t\t\t);"
  puts $aPbxprojFile "\t\t\trunOnlyForDeploymentPostprocessing = 0;"
  puts $aPbxprojFile "\t\t\};\n"
  # End PBXFrameworksBuildPhase section

  # Begin PBXGroup section
  set aTkPBXGroup "${theToolKit}_PBXGroup"
  if { ! [info exists aGuidsMap($aTkPBXGroup)] } {
    set aGuidsMap($aTkPBXGroup) [OS:genGUID "xcd"]
  }

  set aTkSrcGroup "${theToolKit}_SrcGroup"
  if { ! [info exists aGuidsMap($aTkSrcGroup)] } {
    set aGuidsMap($aTkSrcGroup) [OS:genGUID "xcd"]
  }

  puts $aPbxprojFile $aGroupSection
  puts $aPbxprojFile "\t\t$aGuidsMap($aTkPBXGroup) = \{"
  puts $aPbxprojFile "\t\t\tisa = PBXGroup;"
  puts $aPbxprojFile "\t\t\tchildren = ("
  puts $aPbxprojFile $aDepsRefGuids
  puts $aPbxprojFile "\t\t\t\t$aGuidsMap($aTkSrcGroup) ,"
  puts $aPbxprojFile "\t\t\t\t$aGuidsMap($aToolkitLib) ,"
  puts $aPbxprojFile "\t\t\t);"
  puts $aPbxprojFile "\t\t\tsourceTree = \"<group>\";"
  puts $aPbxprojFile "\t\t\};"
  puts $aPbxprojFile "\t\t$aGuidsMap($aTkSrcGroup) = \{"
  puts $aPbxprojFile "\t\t\tisa = PBXGroup;"
  puts $aPbxprojFile "\t\t\tchildren = ("
  puts $aPbxprojFile $aPackagesGuids
  puts $aPbxprojFile "\t\t\t);"
  puts $aPbxprojFile "\t\t\tname = \"Source files\";"
  puts $aPbxprojFile "\t\t\tsourceTree = \"<group>\";"
  puts $aPbxprojFile "\t\t\};\n"
  # End PBXGroup section

  # Begin PBXHeadersBuildPhase section
  set aTkHeaders "${theToolKit}_Headers"
  if { ! [info exists aGuidsMap($aTkHeaders)] } {
    set aGuidsMap($aTkHeaders) [OS:genGUID "xcd"]
  }

  puts $aPbxprojFile "\t\t$aGuidsMap($aTkHeaders) = \{"
  puts $aPbxprojFile "\t\t\tisa = PBX${aPBXBuildPhase}BuildPhase;"
  puts $aPbxprojFile "\t\t\tbuildActionMask = 2147483647;"
  puts $aPbxprojFile "\t\t\tfiles = ("
  puts $aPbxprojFile "\t\t\t);"
  puts $aPbxprojFile "\t\t\trunOnlyForDeploymentPostprocessing = ${aRunOnlyForDeployment};"
  puts $aPbxprojFile "\t\t\};\n"
  # End PBXHeadersBuildPhase section

  # Begin PBXNativeTarget section
  set aTkBuildCfgListNativeTarget "${theToolKit}_BuildCfgListNativeTarget"
  if { ! [info exists aGuidsMap($aTkBuildCfgListNativeTarget)] } {
    set aGuidsMap($aTkBuildCfgListNativeTarget) [OS:genGUID "xcd"]
  }

  set aTkSources "${theToolKit}_Sources"
  if { ! [info exists aGuidsMap($aTkSources)] } {
    set aGuidsMap($aTkSources) [OS:genGUID "xcd"]
  }

  puts $aPbxprojFile "\t\t$aGuidsMap($theToolKit) = \{"
  puts $aPbxprojFile "\t\t\tisa = PBXNativeTarget;"
  puts $aPbxprojFile "\t\t\tbuildConfigurationList = $aGuidsMap($aTkBuildCfgListNativeTarget) ;"
  puts $aPbxprojFile "\t\t\tbuildPhases = ("
  puts $aPbxprojFile "\t\t\t\t$aGuidsMap($aTkSources) ,"
  puts $aPbxprojFile "\t\t\t\t$aGuidsMap($aTkFrameworks) ,"
  puts $aPbxprojFile "\t\t\t\t$aGuidsMap($aTkHeaders) ,"
  puts $aPbxprojFile "\t\t\t);"
  puts $aPbxprojFile "\t\t\tbuildRules = ("
  puts $aPbxprojFile "\t\t\t);"
  puts $aPbxprojFile "\t\t\tdependencies = ("
  puts $aPbxprojFile "\t\t\t);"
  puts $aPbxprojFile "\t\t\tname = $theToolKit;"
  puts $aPbxprojFile "\t\t\tproductName = $theToolKit;"
  puts $aPbxprojFile "\t\t\tproductReference = $aGuidsMap($aToolkitLib) ;"
  puts $aPbxprojFile "\t\t\tproductType = \"com.apple.product-type.${aProductType}\";"
  puts $aPbxprojFile "\t\t\};\n"
  # End PBXNativeTarget section

  # Begin PBXProject section
  set aTkProjectObj "${theToolKit}_ProjectObj"
  if { ! [info exists aGuidsMap($aTkProjectObj)] } {
    set aGuidsMap($aTkProjectObj) [OS:genGUID "xcd"]
  }

  set aTkBuildCfgListProj "${theToolKit}_BuildCfgListProj"
  if { ! [info exists aGuidsMap($aTkBuildCfgListProj)] } {
    set aGuidsMap($aTkBuildCfgListProj) [OS:genGUID "xcd"]
  }

  puts $aPbxprojFile "\t\t$aGuidsMap($aTkProjectObj) = \{"
  puts $aPbxprojFile "\t\t\tisa = PBXProject;"
  puts $aPbxprojFile "\t\t\tattributes = \{"
  puts $aPbxprojFile "\t\t\t\tLastUpgradeCheck = 0430;"
  puts $aPbxprojFile "\t\t\t\};"
  puts $aPbxprojFile "\t\t\tbuildConfigurationList = $aGuidsMap($aTkBuildCfgListProj) ;"
  puts $aPbxprojFile "\t\t\tcompatibilityVersion = \"Xcode 3.2\";"
  puts $aPbxprojFile "\t\t\tdevelopmentRegion = English;"
  puts $aPbxprojFile "\t\t\thasScannedForEncodings = 0;"
  puts $aPbxprojFile "\t\t\tknownRegions = ("
  puts $aPbxprojFile "\t\t\t\ten,"
  puts $aPbxprojFile "\t\t\t);"
  puts $aPbxprojFile "\t\t\tmainGroup = $aGuidsMap($aTkPBXGroup);"
  puts $aPbxprojFile "\t\t\tproductRefGroup = $aGuidsMap($aTkPBXGroup);"
  puts $aPbxprojFile "\t\t\tprojectDirPath = \"\";"
  puts $aPbxprojFile "\t\t\tprojectRoot = \"\";"
  puts $aPbxprojFile "\t\t\ttargets = ("
  puts $aPbxprojFile "\t\t\t\t$aGuidsMap($theToolKit) ,"
  puts $aPbxprojFile "\t\t\t);"
  puts $aPbxprojFile "\t\t\};\n"
  # End PBXProject section

  # Begin PBXSourcesBuildPhase section
  puts $aPbxprojFile "\t\t$aGuidsMap($aTkSources) = \{"
  puts $aPbxprojFile "\t\t\tisa = PBXSourcesBuildPhase;"
  puts $aPbxprojFile "\t\t\tbuildActionMask = 2147483647;"
  puts $aPbxprojFile "\t\t\tfiles = ("
  puts $aPbxprojFile $aSrcFileGuids
  puts $aPbxprojFile "\t\t\t);"
  puts $aPbxprojFile "\t\t\trunOnlyForDeploymentPostprocessing = 0;"
  puts $aPbxprojFile "\t\t\};\n"
  # End PBXSourcesBuildPhase section

  # Begin XCBuildConfiguration section
  set aTkDebugProject "${theToolKit}_DebugProject"
  if { ! [info exists aGuidsMap($aTkDebugProject)] } {
    set aGuidsMap($aTkDebugProject) [OS:genGUID "xcd"]
  }

  set aTkReleaseProject "${theToolKit}_ReleaseProject"
  if { ! [info exists aGuidsMap($aTkReleaseProject)] } {
    set aGuidsMap($aTkReleaseProject) [OS:genGUID "xcd"]
  }

  set aTkDebugNativeTarget "${theToolKit}_DebugNativeTarget"
  if { ! [info exists aGuidsMap($aTkDebugNativeTarget)] } {
    set aGuidsMap($aTkDebugNativeTarget) [OS:genGUID "xcd"]
  }

  set aTkReleaseNativeTarget "${theToolKit}_ReleaseNativeTarget"
  if { ! [info exists aGuidsMap($aTkReleaseNativeTarget)] } {
    set aGuidsMap($aTkReleaseNativeTarget) [OS:genGUID "xcd"]
  }

  puts $aPbxprojFile "\t\t$aGuidsMap($aTkDebugProject) = \{"
  puts $aPbxprojFile "\t\t\tisa = XCBuildConfiguration;"
  puts $aPbxprojFile "\t\t\tbuildSettings = \{"
  puts $aPbxprojFile "\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;"
  puts $aPbxprojFile "\t\t\t\tARCHS = \"\$(ARCHS_STANDARD_64_BIT)\";"
  puts $aPbxprojFile "\t\t\t\tCOPY_PHASE_STRIP = NO;"
  puts $aPbxprojFile "\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu99;"
  puts $aPbxprojFile "\t\t\t\tGCC_DYNAMIC_NO_PIC = NO;"
  puts $aPbxprojFile "\t\t\t\tGCC_ENABLE_OBJC_EXCEPTIONS = YES;"
  puts $aPbxprojFile "\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;"
  puts $aPbxprojFile "\t\t\t\tGCC_PREPROCESSOR_DEFINITIONS = ("
  puts $aPbxprojFile "\t\t\t\t\t\"DEBUG=1\","
  puts $aPbxprojFile "\t\t\t\t\t\"\$\(inherited\)\","
  puts $aPbxprojFile "\t\t\t\t);"
  puts $aPbxprojFile "\t\t\t\tGCC_SYMBOLS_PRIVATE_EXTERN = NO;"
  puts $aPbxprojFile "\t\t\t\tGCC_VERSION = com.apple.compilers.llvm.clang.1_0;"
  puts $aPbxprojFile "\t\t\t\tGCC_WARN_64_TO_32_BIT_CONVERSION = YES;"
  puts $aPbxprojFile "\t\t\t\tGCC_WARN_ABOUT_RETURN_TYPE = YES;"
  puts $aPbxprojFile "\t\t\t\tGCC_WARN_UNINITIALIZED_AUTOS = YES;"
  puts $aPbxprojFile "\t\t\t\tGCC_WARN_UNUSED_VARIABLE = YES;"
  puts $aPbxprojFile "\t\t\t\tOTHER_LDFLAGS = \"\$(CSF_OPT_LNK64)\"; "
  puts $aPbxprojFile "\t\t\t\tONLY_ACTIVE_ARCH = YES;"
  puts $aPbxprojFile "\t\t\t\};"
  puts $aPbxprojFile "\t\t\tname = Debug;"
  puts $aPbxprojFile "\t\t\};"
  puts $aPbxprojFile "\t\t$aGuidsMap($aTkReleaseProject) = \{"
  puts $aPbxprojFile "\t\t\tisa = XCBuildConfiguration;"
  puts $aPbxprojFile "\t\t\tbuildSettings = \{"
  puts $aPbxprojFile "\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;"
  puts $aPbxprojFile "\t\t\t\tARCHS = \"\$(ARCHS_STANDARD_64_BIT)\";"
  puts $aPbxprojFile "\t\t\t\tCOPY_PHASE_STRIP = YES;"
  puts $aPbxprojFile "\t\t\t\tDEBUG_INFORMATION_FORMAT = \"dwarf-with-dsym\";"
  puts $aPbxprojFile "\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu99;"
  puts $aPbxprojFile "\t\t\t\tGCC_ENABLE_OBJC_EXCEPTIONS = YES;"
  puts $aPbxprojFile "\t\t\t\tGCC_VERSION = com.apple.compilers.llvm.clang.1_0;"
  puts $aPbxprojFile "\t\t\t\tGCC_WARN_64_TO_32_BIT_CONVERSION = YES;"
  puts $aPbxprojFile "\t\t\t\tGCC_WARN_ABOUT_RETURN_TYPE = YES;"
  puts $aPbxprojFile "\t\t\t\tGCC_WARN_UNINITIALIZED_AUTOS = YES;"
  puts $aPbxprojFile "\t\t\t\tGCC_WARN_UNUSED_VARIABLE = YES;"
  puts $aPbxprojFile "\t\t\t\tOTHER_LDFLAGS = \"\$(CSF_OPT_LNK64D)\";"
  puts $aPbxprojFile "\t\t\t\};"
  puts $aPbxprojFile "\t\t\tname = Release;"
  puts $aPbxprojFile "\t\t\};"
  puts $aPbxprojFile "\t\t$aGuidsMap($aTkDebugNativeTarget) = \{"
  puts $aPbxprojFile "\t\t\tisa = XCBuildConfiguration;"
  puts $aPbxprojFile "\t\t\tbuildSettings = \{"
  puts $aPbxprojFile "${anExecExtension}"
  puts $aPbxprojFile "${anExecPrefix}"
  puts $aPbxprojFile "\t\t\t\tGCC_PREPROCESSOR_DEFINITIONS = ("
  foreach aMacro $aTKDefines {
    puts $aPbxprojFile "\t\t\t\t\t${aMacro} ,"
  }
  puts $aPbxprojFile "\t\t\t\t);"
  puts $aPbxprojFile "\t\t\t\tHEADER_SEARCH_PATHS = ("
  foreach anIncPath $anIncPaths {
    puts $aPbxprojFile "\t\t\t\t\t${anIncPath},"
  }
  puts $aPbxprojFile "\t\t\t\t\t\"\$(CSF_OPT_INC)\","
  puts $aPbxprojFile "\t\t\t\t);"
  puts $aPbxprojFile "\t\t\t\tLIBRARY_SEARCH_PATHS = /usr/X11/lib;"
  puts $aPbxprojFile "\t\t\t\tOTHER_CFLAGS = ("
  puts $aPbxprojFile "\t\t\t\t\t\"\$(CSF_OPT_CMPL)\","
  puts $aPbxprojFile "\t\t\t\t);"
  puts $aPbxprojFile "\t\t\t\tOTHER_CPLUSPLUSFLAGS = ("
  puts $aPbxprojFile "\t\t\t\t\t\"\$(OTHER_CFLAGS)\","
  puts $aPbxprojFile "\t\t\t\t);"
  puts $aPbxprojFile "\t\t\t\tPRODUCT_NAME = \"\$(TARGET_NAME)\";"
  set anUserHeaderSearchPath "\t\t\t\tUSER_HEADER_SEARCH_PATHS = \""
  foreach anIncPath $anIncPaths {
    append anUserHeaderSearchPath " ${anIncPath}"
  }
  append anUserHeaderSearchPath "\";"
  puts $aPbxprojFile $anUserHeaderSearchPath
  puts $aPbxprojFile "${aWrapperExtension}"
  puts $aPbxprojFile "\t\t\t\};"
  puts $aPbxprojFile "\t\t\tname = Debug;"
  puts $aPbxprojFile "\t\t\};"
  puts $aPbxprojFile "\t\t$aGuidsMap($aTkReleaseNativeTarget) = \{"
  puts $aPbxprojFile "\t\t\tisa = XCBuildConfiguration;"
  puts $aPbxprojFile "\t\t\tbuildSettings = \{"
  puts $aPbxprojFile "${anExecExtension}"
  puts $aPbxprojFile "${anExecPrefix}"
  puts $aPbxprojFile "\t\t\t\tGCC_PREPROCESSOR_DEFINITIONS = ("
  foreach aMacro $aTKDefines {
    puts $aPbxprojFile "\t\t\t\t\t${aMacro} ,"
  }
  puts $aPbxprojFile "\t\t\t\t);"
  puts $aPbxprojFile "\t\t\t\tHEADER_SEARCH_PATHS = ("
  foreach anIncPath $anIncPaths {
    puts $aPbxprojFile "\t\t\t\t\t${anIncPath},"
  }
  puts $aPbxprojFile "\t\t\t\t\t\"\$(CSF_OPT_INC)\","
  puts $aPbxprojFile "\t\t\t\t);"
  puts $aPbxprojFile "\t\t\t\tLIBRARY_SEARCH_PATHS = /usr/X11/lib;"
  puts $aPbxprojFile "\t\t\t\tOTHER_CFLAGS = ("
  puts $aPbxprojFile "\t\t\t\t\t\"\$(CSF_OPT_CMPL)\","
  puts $aPbxprojFile "\t\t\t\t);"
  puts $aPbxprojFile "\t\t\t\tOTHER_CPLUSPLUSFLAGS = ("
  puts $aPbxprojFile "\t\t\t\t\t\"\$(OTHER_CFLAGS)\","
  puts $aPbxprojFile "\t\t\t\t);"
  puts $aPbxprojFile "\t\t\t\tPRODUCT_NAME = \"\$(TARGET_NAME)\";"
  puts $aPbxprojFile $anUserHeaderSearchPath
  puts $aPbxprojFile "${aWrapperExtension}"
  puts $aPbxprojFile "\t\t\t\};"
  puts $aPbxprojFile "\t\t\tname = Release;"
  puts $aPbxprojFile "\t\t\};\n"
  # End XCBuildConfiguration section

  # Begin XCConfigurationList section
  puts $aPbxprojFile "\t\t$aGuidsMap($aTkBuildCfgListProj) = \{"
  puts $aPbxprojFile "\t\t\tisa = XCConfigurationList;"
  puts $aPbxprojFile "\t\tbuildConfigurations = ("
  puts $aPbxprojFile "\t\t\t\t$aGuidsMap($aTkDebugProject) ,"
  puts $aPbxprojFile "\t\t\t\t$aGuidsMap($aTkReleaseProject) ,"
  puts $aPbxprojFile "\t\t\t);"
  puts $aPbxprojFile "\t\t\tdefaultConfigurationIsVisible = 0;"
  puts $aPbxprojFile "\t\t\tdefaultConfigurationName = Release;"
  puts $aPbxprojFile "\t\t\};"
  puts $aPbxprojFile "\t\t$aGuidsMap($aTkBuildCfgListNativeTarget) = \{"
  puts $aPbxprojFile "\t\t\tisa = XCConfigurationList;"
  puts $aPbxprojFile "\t\t\tbuildConfigurations = ("
  puts $aPbxprojFile "\t\t\t\t$aGuidsMap($aTkDebugNativeTarget) ,"
  puts $aPbxprojFile "\t\t\t\t$aGuidsMap($aTkReleaseNativeTarget) ,"
  puts $aPbxprojFile "\t\t\t);"
  puts $aPbxprojFile "\t\t\tdefaultConfigurationIsVisible = 0;"
  puts $aPbxprojFile "\t\t\tdefaultConfigurationName = Release;"
  puts $aPbxprojFile "\t\t\};\n"
  # End XCConfigurationList section

  puts $aPbxprojFile "\t\};"
  puts $aPbxprojFile "\trootObject = $aGuidsMap($aTkProjectObj) ;"
  puts $aPbxprojFile "\}"

  close $aPbxprojFile
}

proc osutils:xcdx { theOutDir theExecutable theGuidsMap } {
  set aUsername [exec whoami]

  # Creating folders for Xcode project file.
  set anExecutableDir "${theOutDir}/${theExecutable}.xcodeproj"
  OS:mkdir $anExecutableDir
  if { ! [file exists $anExecutableDir] } {
    puts stderr "Error: Could not create project directory \"$anExecutableDir\""
    return
  }

  set aUserDataDir "${anExecutableDir}/xcuserdata"
  OS:mkdir $aUserDataDir
  if { ! [file exists $aUserDataDir] } {
    puts stderr "Error: Could not create xcuserdata directorty in \"$anExecutableDir\""
    return
  }

  set aUserDataDir "${aUserDataDir}/${aUsername}.xcuserdatad"
  OS:mkdir $aUserDataDir
  if { ! [file exists $aUserDataDir] } {
    puts stderr "Error: Could not create ${aUsername}.xcuserdatad directorty in \"$anExecutableDir\"/xcuserdata"
    return
  }

  set aSchemesDir "${aUserDataDir}/xcschemes"
  OS:mkdir $aSchemesDir
  if { ! [file exists $aSchemesDir] } {
    puts stderr "Error: Could not create xcschemes directorty in \"$aUserDataDir\""
    return
  }
  # End folders creation. 

  # Generating GUID for tookit.
  upvar $theGuidsMap aGuidsMap
  if { ! [info exists aGuidsMap($theExecutable)] } {
    set aGuidsMap($theExecutable) [OS:genGUID "xcd"]
  }

  # Creating xcscheme file for toolkit from template.
  set aXcschemeTmpl [osutils:readtemplate "xcscheme" "xcode"]
  regsub -all -- {__TOOLKIT_NAME__} $aXcschemeTmpl $theExecutable aXcschemeTmpl
  regsub -all -- {__TOOLKIT_GUID__} $aXcschemeTmpl $aGuidsMap($theExecutable) aXcschemeTmpl
  set aXcschemeFile [open "$aSchemesDir/${theExecutable}.xcscheme"  "w"]
  puts $aXcschemeFile $aXcschemeTmpl
  close $aXcschemeFile

  # Creating xcschememanagement.plist file for toolkit from template.
  set aPlistTmpl [osutils:readtemplate "plist" "xcode"]
  regsub -all -- {__TOOLKIT_NAME__} $aPlistTmpl $theExecutable aPlistTmpl
  regsub -all -- {__TOOLKIT_GUID__} $aPlistTmpl $aGuidsMap($theExecutable) aPlistTmpl
  set aPlistFile [open "$aSchemesDir/xcschememanagement.plist"  "w"]
  puts $aPlistFile $aPlistTmpl
  close $aPlistFile

}
