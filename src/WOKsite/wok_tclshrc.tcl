#
# This is a template file for a Tcl/Tk user startup file.
#
# To use it you must:
#
# On Unix/Linux system, place or invoke it in a file named .wishrc on your home directory.
# Wish, the Tcl/Tk windowing shell will automatically invoke this file.
#
# On Windows system, place this file in the directory pointed to by the variable HOME.
# Name it tclshrc.tcl or wishrc.tcl depending on the shell you want to use.
# You can then click on the Tclsh or Wish icon to start Wok.
#
# This file assumes that:
#
# On Linux platforms the variable LD_LIBRARY_PATH is setted to the name
# of the directory where Wok shareable resides. For example if you have
# downloaded Wok on /home/me/wok-C40 of a Linux system, you must set
# LD_LIBRARY_PATH to /home/me/wok-C40/lib/lin because wok shareable resides
# in this directory. See also the INSTALL file.
#
# In the same way:
#
# On SunOS platforms you set LD_LIBRARY_PATH to /home/me/wok-C40/lib/sun.
# On Windows system you set the variable PATH to C:\home\me\wok-C40\lib\wnt.
#
# The following operation are done:
#
# 1. Traversing the LD_LIBRARY_PATH or PATH variable we find where you have installed Wok.
# 2. We can:
#       a) Compute the location of EDL files Wok needs for working.
#       b) Modify the Tcl variable auto_path in order to add our packages: Wok and Ms
#       c) In the case of a first installation, setup the directory wok_entities where
#          Wok will manage to create its entities.
#
# IMPORTANT RESTRICTIONS:
#
# The purpose of this file is to provide a simple and uniform way of using Wok on Unix/Linux and on Windows.
# Be aware that if you use other Tcl tools, this can be conflicting.
# In this case you can make up a Tcl proc from this file and invoke it at the moment you choose.
#
global env tcl_platform

if { "$tcl_platform(platform)" == "unix" } {
  if { ! [file exists "/bin/csh"] } {
    puts stderr "C shell is required for WOK but not found on path '/bin/csh'!"
    exit
  }

  if { "$tcl_platform(os)" == "HP-UX" } {
    set ldpathvar SHLIB_PATH
  } elseif { "$tcl_platform(os)" == "Darwin" } {
    set ldpathvar DYLD_LIBRARY_PATH
  } else {
    set ldpathvar LD_LIBRARY_PATH
  }
  if { ![info exists env($ldpathvar)] } {
    puts stderr "You must set $ldpathvar to point where you have installed Wok"
    exit
  }
} elseif { "$tcl_platform(platform)" == "windows" && ![info exists env(Path)] } {
  puts stderr "You must set PATH to point where you have installed Wok"
  exit
}

if [info exists wm] {
  wm withdraw .
}

if { "$tcl_platform(platform)" == "unix" } {
  set sprtor ":"
  set fmtshr "lib%s.so"
  if { $tcl_platform(os) == "HP-UX"  } { set fmtshr "lib%s.sl" }
  if { $tcl_platform(os) == "Darwin" } { set fmtshr "lib%s.dylib" }
} elseif { "$tcl_platform(platform)" == "windows" } {
  set sprtor ";"
  set fmtshr "%s.dll"
}

# Wok's here we can set up our niche.
lappend auto_path $::env(WOK_LIBRARY)
package require Wok
package require Ms

# Where tcl and edl file of wok reside
set wok_library $env(WOK_LIBRARY)
set wok_ptfm    $env(WOKSTATION)
set woksite [file join $env(WOKHOME) site]

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

# Load 3rd-party dependencies info
source "$::env(WOKHOME)/site/wok_deps.tcl"

# Show WOK configuration
set aStartDate [clock format [clock seconds] -format "%Y.%m.%d %H:%M"]
puts "Session started: $aStartDate"
puts "WOK environment configured to:"

# Prepare 3rd-parties paths
if { "$tcl_platform(platform)" == "windows" } {
  if { $env(VCVER) == "vc8" } {
    puts "  Visual Studio 2005 (vc8), win${env(ARCH)}"
  } elseif { $env(VCVER) == "vc9" } {
    puts "  Visual Studio 2008 (vc9), win${env(ARCH)}"
  } elseif { $env(VCVER) == "vc10" } {
    puts "  Visual Studio 2010 (vc10), win${env(ARCH)}"
  } elseif { $env(VCVER) == "vc11" } {
    puts "  Visual Studio 2012 (vc11), win${env(ARCH)}"
  } else {
    puts "  Visual Studio ???? ($env(VCVER)), win${env(ARCH)}"
  }
} else {
  puts "   WOK Workstation: ${env(WOKSTATION)}"
}
if { "$PRODUCTS_PATH" != "" } {
  puts "  3rd-parties root: '$::env(PRODUCTS_PATH)'"
}

set anErrs {}
if { [wokdep:SearchTclTk anErrs anErrs anErrs anErrs anErrs] == "false" } {
  puts "  not found: Tcl/Tk (Major!)"
}
if { [wokdep:SearchFreeType anErrs anErrs anErrs anErrs anErrs] == "false" } {
  puts "  not found: FreeType2 (Major!)"
}
if { "$::HAVE_FREEIMAGE" == "true" } {
  if { [wokdep:SearchFreeImage anErrs anErrs anErrs anErrs anErrs] == "false" } {
    puts "  not found: FreeImage (Optional, enabled)"
  }
}
if { "$::HAVE_GL2PS" == "true" } {
  if { [wokdep:SearchGL2PS anErrs anErrs anErrs anErrs anErrs] == "false" } {
    puts "  not found: GL2PS (Optional, enabled)"
  }
}
if { "$::HAVE_TBB" == "true" } {
  if { [wokdep:SearchTBB anErrs anErrs anErrs anErrs anErrs] == "false" } {
    puts "  not found: Intel TBB (Optional, enabled)"
  }
}
if { "$::CHECK_QT4" == "true" } {
  if { [wokdep:SearchQt4 anErrs anErrs anErrs anErrs anErrs] == "false" } {
    puts "  not found: Qt4 (Optional, set to check)"
  }
}
if { "$::CHECK_JDK" == "true" } {
  if { [wokdep:SearchJDK anErrs anErrs anErrs anErrs anErrs] == "false" } {
    puts "  not found: JDK (Optional, set to check)"
  }
}

# Compiler search path to the libraries
if { "$tcl_platform(platform)" == "windows" } {
  # MSVC
  set aEnvVarCLib "LIB"
  set aEnvVarCInc "INCLUDE"
} else {
  # gcc
  set aEnvVarCLib "LIBRARY_PATH"
  set aEnvVarCInc "CPATH"
}

if { "$::ARCH" == "32"} {
  set aCLibPaths [join $::CSF_OPT_LIB32 $::SYS_PATH_SPLITTER]
} else {
  set aCLibPaths [join $::CSF_OPT_LIB64 $::SYS_PATH_SPLITTER]
}

if { [array names env $aEnvVarCLib] == "" } {
  set env($aEnvVarCLib) "${aCLibPaths}${::SYS_PATH_SPLITTER}"
} else {
  set env($aEnvVarCLib) "${aCLibPaths}${::SYS_PATH_SPLITTER}$env($aEnvVarCLib)"
}

# Compiler search path to the headers
set aCIncPaths [join $::CSF_OPT_INC $::SYS_PATH_SPLITTER]
if { [array names env $aEnvVarCInc] == "" } {
  set env($aEnvVarCInc) "${aCIncPaths}${::SYS_PATH_SPLITTER}"
} else {
  set env($aEnvVarCInc) "${aCIncPaths}${::SYS_PATH_SPLITTER}$env($aEnvVarCInc)"
}

# Search path to the libraries
if { "$::tcl_platform(platform)" != "windows" } {
  # LD_LIBRARY_PATH and so on
  set env($ldpathvar) "${aCLibPaths}${::SYS_PATH_SPLITTER}$env($ldpathvar)"
}

# Executables search path
if { "$::ARCH" == "32"} {
  set aBinPaths [join $::CSF_OPT_BIN32 $::SYS_PATH_SPLITTER]
} else {
  set aBinPaths [join $::CSF_OPT_BIN64 $::SYS_PATH_SPLITTER]
}
set env(PATH) "${aBinPaths}${::SYS_PATH_SPLITTER}$env(PATH)"

# Function to generate environment scripts files
if { [file exists "$::env(WOKHOME)/lib/OS.tcl"] } {
  source "$::env(WOKHOME)/lib/OS.tcl"
}
proc wgenprojbat {thePath theIDE} {
  source "$::env(WOKHOME)/lib/osutils.tcl"
  source "$::env(WOKHOME)/lib/OS.tcl"

  set aWokCD [wokcd]
  wokcd [LocateRecur OS]
  winc [wokinfo -w]
  set anOsIncPath [pwd]
  wokcd -P Home
  set anOsRootPath [pwd]
  wokcd $aWokCD

  set aTargetPlatform "lin"
  if { "$::tcl_platform(platform)" == "windows" } {
    set aTargetPlatform "wnt"
  }

  switch -exact -- "$theIDE" {
    "vc7"   -
    "vc8"   -
    "vc9"   -
    "vc10"  -
    "vc11"  { set aTargetPlatform wnt }
    "amk"   { set aTargetPlatform lin  }
  }
  
  set aTargetPlatformExt sh
  if { "$aTargetPlatform" == "wnt" } {
    set aTargetPlatformExt bat
  }

  set aBox [file normalize "$thePath/.."]

  if { "$aTargetPlatform" != "wnt" } {
    file copy -force -- "$::env(WOKHOME)/lib/config.h" "$aBox/inc/config.h"
  }

  if {"$theIDE" == "cmake"} {
    file copy -force -- "$::env(WOKHOME)/lib/templates/draw.${aTargetPlatformExt}" "$aBox/adm/cmake/draw.${aTargetPlatformExt}"
    file copy -force -- "$::env(WOKHOME)/lib/templates/env.${aTargetPlatformExt}.in" "$aBox/adm/cmake/env.${aTargetPlatformExt}.in"
  } else {

    set anEnvTmplFile [open "$::env(WOKHOME)/lib/templates/env.${aTargetPlatformExt}" "r"]
    set anEnvTmpl [read $anEnvTmplFile]
    close $anEnvTmplFile

    set aCasRoot ""
    if { [file normalize "$anOsRootPath"] != "$aBox" } {
      set aCasRoot [relativePath "$aBox" "$anOsRootPath"]
    }
    set anOsIncPath [relativePath "$aBox" "$anOsRootPath"]

    regsub -all -- {__CASROOT__}   $anEnvTmpl "$aCasRoot" anEnvTmpl

    set anEnvFile [open "$aBox/env.${aTargetPlatformExt}" "w"]
    puts $anEnvFile $anEnvTmpl
    close $anEnvFile

    catch {file copy -- "$::env(WOKHOME)/site/custom.${aTargetPlatformExt}"        "$aBox/custom.${aTargetPlatformExt}"}
    file copy -force -- "$::env(WOKHOME)/lib/templates/draw.${aTargetPlatformExt}" "$aBox/draw.${aTargetPlatformExt}"
  }

  switch -exact -- "$theIDE" {
    "vc7"   -
    "vc8"   -
    "vc9"   -
    "vc10"  -
    "vc11"  { file copy -force -- "$::env(WOKHOME)/lib/templates/msvc.bat" "$aBox/msvc.bat" }
    "cbp"   { file copy -force -- "$::env(WOKHOME)/lib/templates/codeblocks.sh" "$aBox/codeblocks.sh" }
    "xcd"   { file copy -force -- "$::env(WOKHOME)/lib/templates/xcode.sh" "$aBox/xcode.sh" }

  }
}

proc removeAllOccurrencesOf { theObject theList } {
  set aSortIndices [lsort -decreasing [lsearch -all -nocase $theList $theObject]]
  foreach anIndex $aSortIndices {
    set theList [lreplace $theList $anIndex $anIndex]
  }
  return $theList
}

# Wrapper-function to generate VS project files
proc wgenproj { args } {
  set aSupportedTargets { "vc7" "vc8" "vc9" "vc10" "vc11" "cbp" "cmake" "amk" "xcd" }
  set anArgs $args

  # Setting default IDE.
  # For Windows - Visual Studio (vc), Linux - Code Blocks (cbp), Mac OS X - Xcode (cmake).
  set anTarget ""
  switch -exact -- "$::env(WOKSTATION)" {
    "wnt"   {set anTarget "$::VCVER"}
    "lin"   {set anTarget "cmake"}
    "mac"   {set anTarget "cmake"}
  }

  set isTargetDefault true
  set willWProcessStart true
  if { [lsearch -nocase $anArgs -no_wprocess] != -1 } {
    set anArgs [removeAllOccurrencesOf -no_wprocess $anArgs]
    set willWProcessStart false
  }

  if { [set anIndex [lsearch -nocase $anArgs -ide=*]] != -1 } {
    regsub -nocase "\\-ide=" [lindex $anArgs $anIndex] "" anTarget
    set anArgs [removeAllOccurrencesOf -ide=* $anArgs]
    set isTargetDefault false
  }

  if { [set anIndex [lsearch -nocase $anArgs -target=*]] != -1 } {
    regsub -nocase "\\-target=" [lindex $anArgs $anIndex] "" anTarget
    set anArgs [removeAllOccurrencesOf -target=* $anArgs]
    set isTargetDefault false
  }

  if { [llength $anArgs] == 0 && $isTargetDefault == true } {
    puts "the default \'$anTarget\' target has been applied"
  }

  set isHelpRequire false
  if { [lsearch -nocase $anArgs -h] != -1} {
    set anArgs [removeAllOccurrencesOf -h $anArgs]
    set isHelpRequire true
  }

  if { [lsearch -nocase $aSupportedTargets $anTarget] == -1} {
    puts "the \'$anTarget\' is wrong TARGET"
    set isHelpRequire true
  }

  if {[llength $anArgs] > 0} {
    set isHelpRequire true

    foreach anArg $anArgs {
      puts "wgenproj: unrecognized option \'$anArg\'"
    }
  }

  if {  $isHelpRequire == true } {
    puts "usage: wgenproj \[ -target=<TARGET> \] \[ -no_wprocess \]
    -no_wprocess - skip wprocess
    TARGET:
      vc8   -  Visual Studio 2005
      vc9   -  Visual Studio 2008
      vc10  -  Visual Studio 2010
      vc11  -  Visual Studio 2012
      cbp   -  CodeBlocks
      cmake -  CMake
      amk   -  AutoMake
      xcd   -  Xcode"
      return
  }

  puts "the \'$anTarget\' target has been applied"

  source "$::env(WOKHOME)/lib/osutils.tcl"
  source "$::env(WOKHOME)/lib/OS.tcl"

  # change station if it is necessary
  set anOldStation "$::env(WOKSTATION)"
  if { [lsearch -exact {vc7 vc8 vc9 vc10 vc11} $anTarget] != -1 && "$anOldStation" != "wnt"} {
      changeStationAndDependentEnvironment wnt
  } elseif { "$anTarget" == "amk" && "$anOldStation" != "lin"} {
    changeStationAndDependentEnvironment lin
  }

  # create the inc directory. The directory should be created by wprocess function.
  wokcd -P Home
  file mkdir [file join [pwd] inc]
  #

  if { $willWProcessStart == true } {
    puts "run wprocess -DGroups=Src,Xcpp"
    wprocess -DGroups=Src,Xcpp
  } else {
    puts "skip wprocess"
  }

  set aWokCD [wokcd]
  wadm [wokinfo -w]
  set anAdmPath [pwd]
  wokcd $aWokCD

  if { [wokinfo -x OS] } {
    OS:MKPRC "$anAdmPath" "OS"  "$anTarget"
  }
  if { [wokinfo -x VAS] } {
    OS:MKPRC "$anAdmPath" "VAS" "$anTarget"
  }

  wgenprojbat "$anAdmPath" "$anTarget"
  
  # change back station if it is require
  changeStationAndDependentEnvironment "$anOldStation"
}

# Function to prepare environment
proc wenv {} {
  # will prepend WOK branch bin / lib paths into PATH
  wokenv -s

  # this staff needed to launch DRAWEXE
  global env
  if { $env(WOKSTATION) != "wnt" && $env(WOKSTATION) != "nil" } {
    global env
    set env(STATION) $env(WOKSTATION)
  }
  global env
  set env(TARGET_DBMS) "DFLT"
  set aStdRes [woklocate -u StdResource]
  if { $aStdRes != "" } {
    set env(CSF_PluginDefaults)       [string range [wokinfo -p source:. [woklocate -u StdResource]] 0 [expr {[string length [wokinfo -p source:. $aStdRes]] - 3}]]
    set env(CSF_StandardDefaults)     [string range [wokinfo -p source:. [woklocate -u StdResource]] 0 [expr {[string length [wokinfo -p source:. $aStdRes]] - 3}]]
    set env(CSF_StandardLiteDefaults) [string range [wokinfo -p source:. [woklocate -u StdResource]] 0 [expr {[string length [wokinfo -p source:. $aStdRes]] - 3}]]
  } else {
    puts "Warning! 'StdResource'   package not found!"
  }

  set aTextures [woklocate -u Textures]
  if { $aTextures != "" } {
    set env(CSF_MDTVTexturesDirectory) [string range [wokinfo -p source:. [woklocate -u Textures]] 0 [expr {[string length [wokinfo -p source:. $aTextures]] - 3}]]
  } else {
    puts "Warning! 'Textures'      package not found!"
  }

  set aXSMsg [woklocate -u XSMessage]
  if { $aXSMsg != "" } {
    set env(CSF_XSMessage) [string range [wokinfo -p source:. [woklocate -u XSMessage]] 0 [expr {[string length [wokinfo -p source:. $aXSMsg]] - 3}]]
  } else {
    puts "Warning! 'XSMessage'     package not found!"
  }
  set aSHMsg [woklocate -u SHMessage]
  if { $aSHMsg != "" } {
    set env(CSF_SHMessage) [string range [wokinfo -p source:. [woklocate -u SHMessage]] 0 [expr {[string length [wokinfo -p source:. $aSHMsg]] - 3}]]
  } else {
    puts "Warning! 'SHMessage'     package not found!"
  }

  if { $aStdRes != "" } {
    set env(CSF_XCAFDefaults) [string range [wokinfo -p source:. $aStdRes] 0 [expr {[string length [wokinfo -p source:. $aStdRes]] - 3}]]
  }
  set aStepRes [woklocate -u XSTEPResource]
  if { $aStepRes != "" } {
    set env(CSF_STEPDefaults) [string range [wokinfo -p source:. $aStepRes] 0 [expr {[string length [wokinfo -p source:. $aStepRes]] - 3}]]
    set env(CSF_IGESDefaults) [string range [wokinfo -p source:. $aStepRes] 0 [expr {[string length [wokinfo -p source:. $aStepRes]] - 3}]]
  } else {
    puts "Warning! 'XSTEPResource' package not found!"
  }

  # main DRAWEXE commands
  set aDrawRes [woklocate -u DrawResources]
  if { $aDrawRes != "" } {
    set env(DRAWHOME) [string range [wokinfo -p source:. $aDrawRes] 0 [expr {[string length [wokinfo -p source:. $aDrawRes]] - 3}]]
    set env(CSF_DrawPluginDefaults) $env(DRAWHOME)
    set env(DRAWDEFAULT) $env(DRAWHOME)/DrawDefault
  } else {
    puts "Warning! 'DrawResources' package not found!"
  }

  # products DRAWEXE commands (optional)
  set aDrawProdsRes [woklocate -u DrawResourcesProducts]
  if { $aDrawProdsRes != "" } {
    set env(CSF_DrawPluginProductsDefaults) [string range [wokinfo -p source:. $aDrawProdsRes] 0 [expr {[string length [wokinfo -p source:. $aDrawProdsRes]] - 3}]]
    #Usage: pload -DrawPluginProducts ALL
  } else {
    #puts "Warning! 'DrawResourcesProducts' package not found!"
  }

  if { $env(WOKSTATION) == "wnt" } {
    set aTkGlLib [woklocate -p TKOpenGl:library:TKOpenGl.dll]
  } elseif { $env(WOKSTATION) == "mac" } {
    set aTkGlLib [woklocate -p TKOpenGl:library:libTKOpenGl.dylib]
  } else {
    set aTkGlLib [woklocate -p TKOpenGl:library:libTKOpenGl.so]
  }
  if { $aTkGlLib != "" } {
    set env(CSF_GraphicShr) $aTkGlLib
  } else {
    puts "Warning! 'TKOpenGl'      library not found!"
  }

  puts "Environment configured"
}

# Search branch using filter
proc wbranch {theFilter} {
  set aBranchesAll [sinfo -w]
  set anIndices [lsearch -all ${aBranchesAll} $theFilter]
  set aResult {}
  foreach aBranchId $anIndices {
    lappend aResult [lindex $aBranchesAll $aBranchId]
  }
  return $aResult
}

# Where the files ATLIST, DEFAULT.edl and SESSION.edl reside
if {![info exists env(WOK_ROOTADMDIR)] } {
  set env(WOK_ROOTADMDIR) [file normalize $env(WOKHOME)/wok_entities]
  if ![file exists $env(WOK_ROOTADMDIR)] {
    if [file writable $env(WOKHOME)] {
      puts stderr "Creating directory $env(WOK_ROOTADMDIR) for wok entities..."
      if [catch { wokUtils:FILES:mkdir $env(WOK_ROOTADMDIR) } status] {
        puts stderr "Error : $status"
        return
      }
      if ![file exists $env(WOK_ROOTADMDIR)] {
        return
      }
    } else {
      puts stderr "The directory $env(WOK_ROOTADMDIR) cannot be created because $env(WOKHOME) is not writable."
      puts stderr "Please give write access to this directory."
      return
    }
  } else {
    #puts stderr "Using $env(WOKHOME)/wok_entities for working entities."
  }
} else {
  if ![file exists $env(WOK_ROOTADMDIR)] {
    puts stderr "The directory $env(WOK_ROOTADMDIR) can not be found"
    return
  }
  #puts stderr "Using variable WOK_ROOTADMDIR = $env(WOK_ROOTADMDIR) for working entities."
}

# Check if  Wok stuff is correct. If not set it up silently.
if ![file exists  [set woksession [file join $env(WOK_ROOTADMDIR) WOKSESSION.edl]]] {
    set str1 [wokUtils:FILES:FileToString [file join $woksite WOKSESSION.edl]]
    regsub -all -- {TOSUBSTITUTE} "$str1" "[file normalize $env(WOK_ROOTADMDIR)]" result1
    wokUtils:FILES:StringToFile $result1 $woksession
    if [file exists $woksession] {
	puts stderr "File $woksession has been created. "
    }
}

#
if ![file exists [set default [file join $env(WOK_ROOTADMDIR) DEFAULT.edl]]] {
  set str2 [wokUtils:FILES:FileToString [file join $woksite DEFAULT.edl]]
  regsub -all -- {__DEFHOME__}     "$str2" "[file normalize $::env(WOK_ROOTADMDIR)]" result2
  regsub -all -- {__DEFSTATION__}  $result2 "$::env(WOKSTATION)" result2
  wokUtils:FILES:StringToFile $result2 $default
  if [file exists $default] {
    puts stderr "File $default has been created. "
  }
}

# Where to read/write the current working entity
set env(WOK_SESSIONID) $env(HOME)/.wok

# Everything seems OK. Display a nice prompt:
set tcl_prompt1 {if {[info commands wokcd] != ""}  then \
  {puts -nonewline stdout "[wokcd]> "} else \
  {puts -nonewline stdout "tclsh> "}}
cd $env(WOK_ROOTADMDIR)
wokclose -a
