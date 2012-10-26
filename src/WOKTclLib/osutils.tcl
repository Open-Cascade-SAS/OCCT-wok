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
  } elseif { "$vcversion" == "vc8" || "$vcversion" == "vc9" || "$vcversion" == "vc10" } {
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
  } elseif { "$vcversion" == "vc8" || "$vcversion" == "vc9" || "$vcversion" == "vc10" } {
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
  } elseif { "$vcversion" == "vc8" || "$vcversion" == "vc9" || "$vcversion" == "vc10" } {
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
  } elseif { "$vcversion" == "vc10" } {
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

  # collect list of referred libraries to link with
  set aUsedToolKits ""
  foreach tkx [wokUtils:LIST:Purge [osutils:tk:close [woklocate -u $theToolKit]]] {
    append aUsedToolKits "${tkx}.lib "
  }

  wokparam -l CSF
  foreach tk [lappend [wokUtils:LIST:Purge [osutils:tk:close [woklocate -u $theToolKit]]] $theToolKit] {
    foreach element [osutils:tk:hascsf [woklocate -p ${tk}:source:EXTERNLIB [wokcd]]] {
      if {[wokparam -t %$element] == 0} {
        continue
      }
      foreach fl [split [wokparam -v %$element] \{\ \}] {
        if {[string first "-libpath" $fl] != "-1"} {
          # this is library search path, not the library name
          continue
        }
        set felem [file tail $fl]
        if {[lsearch $aUsedToolKits $felem] == "-1"} {
          if {$felem != "\{\}" & $felem != "lib"} {
            if {[lsearch -nocase [osutils:optinal_libs] $felem] == -1} {
              set aUsedToolKits [concat $aUsedToolKits $felem]
            }
          }
        }
      }
    }
  }

  # correct names of referred third-party libraries that are named with suffix
  # depending on VC version
  regsub -all -- {vc[0-9]+} $aUsedToolKits $theVcVer aUsedToolKits

  # and put this list to project file
  puts "$theToolKit requires  $aUsedToolKits"
  if { "$theVcVer" == "vc10" } { set aUsedToolKits [join $aUsedToolKits {;}] }
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

    # Format of projects in vc10 is different from vc7-9
    if { "$theVcVer" == "vc10" } {
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

  # write filters file for vc10
  if { "$theVcVer" == "vc10" } {
    lappend aVcFiles [osutils:vcxproj:filters $theOutDir $theToolKit aVcFilesX]
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

    set aUsedToolKits ""
    set aDepToolkits [LibToLinkX [woklocate -u $theToolKit] $aProjName]
    foreach tkx $aDepToolkits {
      if {[uinfo -t [woklocate -u $tkx]] == "toolkit"} {
        append aUsedToolKits "${tkx}.lib "
      }
      if {[lsearch [w_info -l] $tkx] == "-1"} {
        append aUsedToolKits "${tkx}.lib "
      }
    }

    wokparam -l CSF
    foreach tk $aDepToolkits {
      foreach element [osutils:tk:hascsf [woklocate -p ${tk}:source:EXTERNLIB [wokcd]]] {
        if {[wokparam -t %$element] == 0} {
          continue
        }
        foreach fl [split [wokparam -v %$element] \{\ \}] {
          if {[string first "-libpath" $fl] != "-1"} {
            # this is library search path, not the library name
            continue
          }
          set felem [file tail $fl]
          if {[lsearch $aUsedToolKits $felem] == "-1"} {
            if {$felem != "\{\}"} {
              if {[lsearch -nocase [osutils:optinal_libs] $felem] == -1} {
                  set aUsedToolKits [concat $aUsedToolKits $felem]
              }
            }
          }
        }
      }
    }

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
    if { "$theVcVer" == "vc10" } { set aUsedToolKits [join $aUsedToolKits {;}] }
    regsub -all -- {__TKDEP__} $aProjTmpl $aUsedToolKits aProjTmpl

    set aFilesSection ""
    set aVcFilesX(units) ""
    ;#set lsrc   [osutils:tk:files $theToolKit osutils:compilable 0]
    if { ![info exists written([file tail $f])] } {
      set written([file tail $f]) 1

      if { "$theVcVer" == "vc10" } {
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
    if { "$theVcVer" == "vc10" } {
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
;# Create file tkloc.mak for a shareable library (dll).
;# in dir return the full path of the created file
;#
proc osutils:mkmak { dir tkloc {tmplat {} } {fmtcpp {} } } {
  puts $tkloc
  if { $tmplat == {} } {set tmplat [osutils:readtemplate mak "MS VC++ makefile"]}
  if { $fmtcpp == {} } {set fmtcpp [osutils:mak:fmtcpp]}
  set fp [open [set fdsp [file join $dir ${tkloc}.mak]] w]
  fconfigure $fp -translation crlf
  set l_compilable [osutils:compilable]
  set tkused [wokUtils:LIST:Purge [osutils:tk:close [woklocate -u $tkloc]]]
  set listloc [osutils:tk:units [woklocate -u $tkloc]]
  set resultloc [osutils:justwnt $listloc]
  regsub -all -- {__TKNAM__} $tmplat $tkloc tmplat
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
    set lsrc   [osutils:tk:files $xlo osutils:compilable 0]
    set fxlocxxparam [lindex [osutils:intersect3 [split [lindex [wokparam -v %CMPLRS_CXX_Options] 0]] [split [lindex [wokparam -v %CMPLRS_CXX_Options $fxlo] 0]] ] 2]
    set fxlocparam [lindex [osutils:intersect3 [split [lindex [wokparam -v %CMPLRS_C_Options] 0]] [split [lindex [wokparam -v %CMPLRS_C_Options $fxlo] 0]] ] 2]
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
  regsub -all -- {__FIELD1__} $tmplat $area1 tmplat

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
    set xlo  [wokinfo -n $fxlo]
    set lsrc [osutils:tk:files $xlo osutils:compilable 0]
    foreach srcfile $lsrc {
      if { ![info exists written([file tail $srcfile])] } {
        set written([file tail $srcfile]) 1
        append area2 "\t\"\$(INTDIR)\\[wokUtils:EASY:bs1 [file root [wokUtils:FILES:wtail $srcfile 1]]].obj\" \\\n"
      }
    }
  }

  regsub -all -- {__FIELD2__} $tmplat $area2 tmplat

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
    set lsrc   [osutils:tk:files $xlo osutils:compilable 0]

    foreach srcfile $lsrc {
      if { ![info exists written([file tail $srcfile])] } {
        set written([file tail $srcfile]) 1
        append area3 "\t-@erase \"\$(INTDIR)\\[wokUtils:EASY:bs1 [file root [wokUtils:FILES:wtail $srcfile 1]]].obj\"\n"
      }
    }
  }
  regsub -all -- {__FIELD3__} $tmplat $area3 tmplat

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
    set lsrc   [osutils:tk:files $xlo osutils:compilable 0]
    foreach srcfile $lsrc {
      if { ![info exists written([file tail $srcfile])] } {
        set written([file tail $srcfile]) 1
        append area4 "\t\"\$(INTDIR)\\[wokUtils:EASY:bs1 [file root [wokUtils:FILES:wtail $srcfile 1]]].obj\" \\\n"
      }
    }
  }

  regsub -all -- {__FIELD4__} $tmplat $area4 tmplat

  set area5 ""
  if [array exists written] { unset written }
  foreach fxlo $resultloc {
    set xlo [wokinfo -n $fxlo]
    set lsrc   [osutils:tk:files $xlo osutils:compilable 0]
    set fxlocxxparam [lindex [osutils:intersect3 [split [lindex [wokparam -v %CMPLRS_CXX_Options] 0]] [split [lindex [wokparam -v %CMPLRS_CXX_Options $fxlo] 0]] ] 2]
    set fxlocparam [lindex [osutils:intersect3 [split [lindex [wokparam -v %CMPLRS_C_Options] 0]] [split [lindex [wokparam -v %CMPLRS_C_Options $fxlo] 0]] ] 2]
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

        append area5 "SOURCE=..\\..\\..\\[wokUtils:EASY:bs1 [wokUtils:FILES:wtail $srcfile 3]]\n"
        append area5 "\!IF  \"\$(CFG)\" == \"$tkloc - Win32 Release\"\n"
        append area5 "CPP_SWITCHES=\/nologo \/MD \/W3 \/GX \/O2 $fxloparam \/I \"..\\..\\..\\inc\" \/I \"..\\..\\..\\drv\\$xlo\" \/I \"..\\..\\..\\src\\$xlo\" \/D \"WIN32\" \/D \"NDEBUG\" \/D \"_WINDOWS\" \/D \"WNT\" \/D \"No_Exception\" \/D \"__${xlo}_DLL\" \/Fo\"\$(INTDIR)\\\\\\\" \/Fd\"\$(INTDIR)\\\\\\\" \/FD \/D \"CSFDB\" \/c\n"
        append area5 "\"\$(INTDIR)\\$pkname.obj\" : \$(SOURCE) \"\$(INTDIR)\"\n"
        append area5 "\t\t\$(CPP) \$(CPP_SWITCHES) \$(SOURCE)\n"
        append area5 "\n"
        append area5 "\!ELSEIF  \"\$(CFG)\" == \"$tkloc - Win32 Debug\"\n"
        append area5 "CPP_SWITCHES=\/nologo \/MDd \/W3 \/GX \/Zi \/Od $fxloparam \/I \"..\\..\\..\\inc\" \/I \"..\\..\\..\\drv\\$xlo\" \/I \"..\\..\\..\\src\\$xlo\" \/D \"WIN32\" \/D \"DEB\" \/D \"_DEBUG\" \/D \"_WINDOWS\" \/D \"WNT\" \/D \"CSFDB\" \/D \"__${xlo}_DLL\" \/Fo\"\$(INTDIR)\\\\\\\" \/Fd\"\$(INTDIR)\\\\\\\" \/FD \/c \n"
        append area5 "\"\$(INTDIR)\\$pkname.obj\" : \$(SOURCE) \"\$(INTDIR)\"\n"
        append area5 "\t\t\$(CPP) \$(CPP_SWITCHES) \$(SOURCE)\n"
        append area5 "\n"
        append area5 "\!ENDIF \n"
      }
    }
  }
  regsub -all -- {__FIELD5__} $tmplat $area5 tmplat

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
  regsub -all -- {__FIELD6__} $tmplat $area6 tmplat

  if {$tclused == 1} {
    set tclwarning "\!IFNDEF TCLHOME \n\!MESSAGE Compilation of this toolkit requires tcl. Set TCLHOME environment variable for proper compilation\n\!ENDIF"
  } else {
    set tclwarning ""
  }
  regsub -all -- {__TCLUSED__} $tmplat $tclwarning tmplat

  if {$javaused == 1} {
    set javawarning "\!IFNDEF JAVAHOME \n\!MESSAGE Compilation of this toolkit requires java. Set JAVAHOME environment variable for proper compilation\n\!ENDIF"
  } else {
    set javawarning ""
  }
  regsub -all -- {__JAVAUSED__} $tmplat $javawarning tmplat
  puts $fp $tmplat
  close $fp
  return $fdsp
}

proc osutils:mkmakx { dir tkloc {tmplat {} } {fmtcpp {} } } {
  if { $tmplat == {} } {set tmplat [osutils:readtemplate makx "MS VC++ makefile (executable)"]}
  if { $fmtcpp == {} } {set fmtcpp [osutils:mak:fmtcpp]}
  foreach f [osutils:tk:files $tkloc osutils:compilable 0] {
    set tf [file rootname [file tail $f]]
    set fp [open [set fdsp [file join $dir ${tf}.mak]] w]
    puts $fdsp
    set tclused 0
    fconfigure $fp -translation crlf
    set l_compilable [osutils:compilable]
    regsub -all -- {__XQTNAM__} $tmplat $tf tmplat
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

    set WOKSteps_exec_link [wokparam -v %WOKSteps_exec_link [woklocate -u $tkloc]]
    if { [regexp {WOKStep_DLLink} $WOKSteps_exec_link] || [regexp {WOKStep_Libink} $WOKSteps_exec_link] } {
      set tkused [concat $tkused "\/dll"]
      if {$tclused != 1} {
        regsub -all -- {__COMPOPT__} $tmplat "\/MD" tmplat
        regsub -all -- {__COMPOPTD__} $tmplat "\/MDd" tmplat
      } else {
        regsub -all -- {__COMPOPT__} $tmplat "\/MD \/I \"\$(TCLHOME)\\include\"" tmplat
        regsub -all -- {__COMPOPTD__} $tmplat "\/MDd \/I \"\$(TCLHOME)\\include\"" tmplat
      }
      regsub -all -- {__XQTNAMEX__} $tmplat "$tf.dll" tmplat
    } else {
      if {$tclused != 1} {
        regsub -all -- {__COMPOPT__} $tmplat "\/MD" tmplat
        regsub -all -- {__COMPOPTD__} $tmplat "\/MDd" tmplat
      } else {
        regsub -all -- {__COMPOPT__} $tmplat "\/MD \/I \"\$(TCLHOME)\\include\"" tmplat
        regsub -all -- {__COMPOPTD__} $tmplat "\/MDd \/I \"\$(TCLHOME)\\include\"" tmplat
      }
      regsub -all -- {__XQTNAMEX__} $tmplat "$tf.exe" tmplat
    }
    #puts "$tf requires  $tkused"
    if {$tclused == 1} {
      append tkused " -libpath:\"\$(TCLHOME)\\lib\" "
    }
    regsub -all -- {__TKDEP__} $tmplat $tkused tmplat
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
    regsub -all -- {__FILES__}  $tmplat $files  tmplat
    regsub -all -- {__FIELD1__} $tmplat $field1 tmplat
    regsub -all -- {__FIELD2__} $tmplat $field2 tmplat
    regsub -all -- {__FIELD3__} $tmplat $field3 tmplat
    regsub -all -- {__FIELD4__} $tmplat $field4 tmplat
    regsub -all -- {__XNAM__}   $tmplat $tkloc  tmplat
    puts $fp $tmplat
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
proc TESTAM { {root} {modules {}} {ll {}} } {
#    source [woklocate -p OS:source:OS.tcl]
#    source [woklocate -p WOKTclLib:source:osutils.tcl]

  set lesmodules [OS:listmodules $modules]

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

# Generate Code::Blocks project file for ToolKit
proc osutils:cbptk { theOutDir theToolKit } {
  set aWokStation "$::env(WOKSTATION)"
  set aWokArch    "$::env(ARCH)"

  # collect list of referred libraries to link with
  set aUsedToolKits [list]
  set anIncPaths    [list]
  set aTKDefines    [list]
  set aTKSrcFiles   [list]
  foreach tkx [wokUtils:LIST:Purge [osutils:tk:close [woklocate -u $theToolKit]]] {
    lappend aUsedToolKits "${tkx}"
  }
  wokparam -l CSF

  foreach tk [lappend [wokUtils:LIST:Purge [osutils:tk:close [woklocate -u $theToolKit]]] $theToolKit] {
    foreach element [osutils:tk:hascsf [woklocate -p ${tk}:source:EXTERNLIB [wokcd]]] {
      if {[wokparam -t %$element] == 0} {
        continue
      }
      foreach fl [split [wokparam -v %$element] \{\ \}] {
        if {[string first "-libpath" $fl] != "-1"} {
          # this is library search path, not the library name
          continue
        }
        set felem [file tail $fl]
        if {[lsearch $aUsedToolKits $felem] == "-1"} {
          if {$felem != "\{\}" & $felem != "lib"} {
            if {[lsearch -nocase [osutils:optinal_libs] $felem] == -1} {
              lappend aUsedToolKits [string trimleft "${felem}" "-l"]
            }
          }
        }
      }
    }
  }

  lappend anIncPaths "../../../inc"
  set listloc [osutils:tk:units [woklocate -u $theToolKit]]
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
        lappend aTKSrcFiles "../../../[wokUtils:EASY:bs1 [wokUtils:FILES:wtail $aSrcFile 3]]"
      } else {
        puts "Warning : more than one occurences for [file tail $aSrcFile]"
      }
    }

    # macros for correct DLL exports
    if { "$aWokStation" == "wnt" } {
      lappend aTKDefines "__${xlo}_DLL"
    }

    # common include paths
    lappend anIncPaths "../../../drv/${xlo}"
    lappend anIncPaths "../../../src/${xlo}"
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

  return [osutils:cbp $theOutDir $theToolKit $aTKSrcFiles $aUsedToolKits $anIncPaths $aTKDefines]
}

# Generate Code::Blocks project file for Executable
proc osutils:cbpx { theOutDir theToolKit } {
  set aWokStation "$::env(WOKSTATION)"
  set aWokArch    "$::env(ARCH)"

  set aCbpFiles {}
  foreach aSrcFile [osutils:tk:files $theToolKit osutils:compilable 0] {
    # collect list of referred libraries to link with
    set aUsedToolKits [list]
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
        foreach fl [split [wokparam -v %$element] \{\ \}] {
          if {[string first "-libpath" $fl] != "-1"} {
            # this is library search path, not the library name
            continue
          }
          set felem [file tail $fl]
          if {[lsearch $aUsedToolKits $felem] == "-1"} {
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

    lappend aCbpFiles [osutils:cbp $theOutDir $aProjName $aTKSrcFiles $aUsedToolKits $anIncPaths $aTKDefines $isExecutable]
  }

  return $aCbpFiles
}

proc osutils:cbp { theOutDir theProjName theSrcFiles theLibsList theIncPaths theDefines {theIsExe "false"} } {
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
    puts $aFile "\t\t\t\t<Option output=\"../../../${aWokStation}/cbp/lib/lib${theProjName}\" prefix_auto=\"1\" extension_auto=\"1\" />"
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
    puts $aFile "\t\t\t\t<Option output=\"../../../${aWokStation}/cbp/libd/lib${theProjName}\" prefix_auto=\"1\" extension_auto=\"1\" />"
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
  puts $aFile "\t\t\t<Add directory=\"$::env(WOK_LIBRARY)\" />"
  puts $aFile "\t\t</Compiler>"

  # COMMON linker options
  puts $aFile "\t\t<Linker>"
  foreach aLibName $theLibsList {
    puts $aFile "\t\t\t<Add library=\"$aLibName\" />"
  }
  puts $aFile "\t\t</Linker>"

  # list of sources
  foreach aSrcFile $theSrcFiles {
    if {[string equal -nocase [file extension $aSrcFile] ".c"]} {
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
