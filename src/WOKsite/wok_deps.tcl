#!/usr/bin/tclsh

set ARCH "32"

if { "$tcl_platform(platform)" == "unix" } {
  set SYS_PATH_SPLITTER ":"
  set SYS_LIB_PREFIX    "lib"
  set SYS_EXE_SUFFIX    ""
  if { "$tcl_platform(os)" == "Darwin" } {
    set SYS_LIB_SUFFIX "dylib"
  } else {
    set SYS_LIB_SUFFIX "so"
  }
  set VCVER "gcc"
  set VCVARS ""
} elseif { "$tcl_platform(platform)" == "windows" } {
  set SYS_PATH_SPLITTER ";"
  set SYS_LIB_PREFIX    ""
  set SYS_LIB_SUFFIX    "lib"
  set SYS_EXE_SUFFIX    ".exe"
  set VCVER  "vc8"
  set VCVARS ""
  #set VCVARS "%VS80COMNTOOLS%..\\..\\VC\\vcvarsall.bat"
}

set HAVE_FREEIMAGE "false"
set HAVE_GL2PS     "false"
set HAVE_TBB       "false"
set CHECK_QT4      "true"
set CHECK_JDK      "true"
set PRODUCTS_PATH ""
set CSF_OPT_INC   [list]
set CSF_OPT_LIB32 [list]
set CSF_OPT_LIB64 [list]
set CSF_OPT_BIN32 [list]
set CSF_OPT_BIN64 [list]

if { [info exists ::env(ARCH)] } {
  set ARCH "$::env(ARCH)"
}
if { [info exists ::env(VCVER)] } {
  set VCVER "$::env(VCVER)"
}
if { [info exists ::env(VCVARS)] } {
  set VCVARS "$::env(VCVARS)"
}
if { [info exists ::env(HAVE_FREEIMAGE)] } {
  set HAVE_FREEIMAGE "$::env(HAVE_FREEIMAGE)"
}
if { [info exists ::env(HAVE_GL2PS)] } {
  set HAVE_GL2PS "$::env(HAVE_GL2PS)"
}
if { [info exists ::env(HAVE_TBB)] } {
  set HAVE_TBB "$::env(HAVE_TBB)"
}
if { [info exists ::env(CHECK_QT4)] } {
  set CHECK_QT4 "$::env(CHECK_QT4)"
}
if { [info exists ::env(CHECK_JDK)] } {
  set CHECK_JDK "$::env(CHECK_JDK)"
}
if { [info exists ::env(PRODUCTS_PATH)] } {
  set PRODUCTS_PATH "$::env(PRODUCTS_PATH)"
}
if { [info exists ::env(CSF_OPT_INC)] } {
  set CSF_OPT_INC [split "$::env(CSF_OPT_INC)" $::SYS_PATH_SPLITTER]
}
if { [info exists ::env(CSF_OPT_LIB32)] } {
  set CSF_OPT_LIB32 [split "$::env(CSF_OPT_LIB32)" $::SYS_PATH_SPLITTER]
}
if { [info exists ::env(CSF_OPT_LIB64)] } {
  set CSF_OPT_LIB64 [split "$::env(CSF_OPT_LIB64)" $::SYS_PATH_SPLITTER]
}
if { [info exists ::env(CSF_OPT_BIN32)] } {
  set CSF_OPT_BIN32 [split "$::env(CSF_OPT_BIN32)" $::SYS_PATH_SPLITTER]
}
if { [info exists ::env(CSF_OPT_BIN64)] } {
  set CSF_OPT_BIN64 [split "$::env(CSF_OPT_BIN64)" $::SYS_PATH_SPLITTER]
}

# Search header file in $::CSF_OPT_INC and standard paths
proc wokdep:SearchHeader {theHeader} {
  # search in custom paths
  foreach anIncPath $::CSF_OPT_INC {
    set aPath "${anIncPath}/${theHeader}"
    if { [file exists "$aPath"] } {
      return "$aPath"
    }
  }

  # search in system
  set aPath "/usr/include/${theHeader}"
  if { [file exists "$aPath"] } {
    return "$aPath"
  }
  return ""
}

# Search library file in $::CSF_OPT_LIB* and standard paths
proc wokdep:SearchLib {theLib theBitness {theSearchPath ""}} {
  if { "$theSearchPath" != "" } {
    set aPath "${theSearchPath}/${::SYS_LIB_PREFIX}${theLib}.${::SYS_LIB_SUFFIX}"
    if { [file exists "$aPath"] } {
      return "$aPath"
    } else {
      return ""
    }
  }

  # search in custom paths
  foreach aLibPath [set ::CSF_OPT_LIB$theBitness] {
    set aPath "${aLibPath}/${::SYS_LIB_PREFIX}${theLib}.${::SYS_LIB_SUFFIX}"
    if { [file exists "$aPath"] } {
      return "$aPath"
    }
  }

  # search in system
  if { "$::ARCH" == "$theBitness"} {
    set aPath "/usr/lib/${::SYS_LIB_PREFIX}${theLib}.${::SYS_LIB_SUFFIX}"
    if { [file exists "$aPath"] } {
      return "$aPath"
    }
  }

  return ""
}

# Search file in $::CSF_OPT_BIN* and standard paths
proc wokdep:SearchBin {theBin theBitness {theSearchPath ""}} {
  if { "$theSearchPath" != "" } {
    set aPath "${theSearchPath}/${theBin}"
    if { [file exists "$aPath"] } {
      return "$aPath"
    } else {
      return ""
    }
  }

  # search in custom paths
  foreach aBinPath [set ::CSF_OPT_BIN$theBitness] {
    set aPath "${aBinPath}/${theBin}"
    if { [file exists "$aPath"] } {
      return "$aPath"
    }
  }

  # search in system
  if { "$::ARCH" == "$theBitness"} {
    set aPath "/usr/bin/${theBin}"
    if { [file exists "$aPath"] } {
      return "$aPath"
    }
  }

  return ""
}

# Detect compiler C-runtime version 'vc*' and architecture '32'/'64'
# to determine preferred path.
proc wokdep:Preferred {theList theCmpl theArch} {
  if { [llength $theList] == 0 } {
    return ""
  }

  set aShortList {}
  foreach aPath $theList {
    if { [string first "$theCmpl" "$aPath"] != "-1" } {
      lappend aShortList "$aPath"
    }
  }

  if { [llength $aShortList] == 0 } {
    #return [lindex $theList 0]
    set aShortList $theList
  }

  set aVeryShortList {}
  foreach aPath $aShortList {
    if { [string first "$theArch" "$aPath"] != "-1" } {
      lappend aVeryShortList "$aPath"
    }
  }
  if { [llength $aVeryShortList] == 0 } {
    return [lindex [lsort -decreasing $aShortList] 0]
  }

  return [lindex [lsort -decreasing $aVeryShortList] 0]
}

# Search Tcl/Tk libraries placement
proc wokdep:SearchTclTk {theErrInc theErrLib32 theErrLib64 theErrBin32 theErrBin64} {
  upvar $theErrInc   anErrInc
  upvar $theErrLib32 anErrLib32
  upvar $theErrLib64 anErrLib64
  upvar $theErrBin32 anErrBin32
  upvar $theErrBin64 anErrBin64

  set isFound "true"
  set aTclHPath [wokdep:SearchHeader "tcl.h"]
  set aTkHPath  [wokdep:SearchHeader "tcl.h"]
  if { "$aTclHPath" == "" || "$aTkHPath" == "" } {
    if { [file exists "/usr/include/tcl8.5/tcl.h"]
      && [file exists "/usr/include/tcl8.5/tk.h" ] } {
      lappend ::CSF_OPT_INC "/usr/include/tcl8.5"
    } else {
      set aPath [wokdep:Preferred [glob -nocomplain -directory "$::PRODUCTS_PATH" -type d *{tcl}*] "$::VCVER" "$::ARCH" ]
      if { "$aPath" != "" && [file exists "$aPath/include/tcl.h"] && [file exists "$aPath/include/tk.h"] } {
        lappend ::CSF_OPT_INC "$aPath/include"
      } else {
        lappend anErrInc "Error: 'tcl.h' or 'tk.h' not found (Tcl/Tk)"
        set isFound "false"
      }
    }
  }

  if { "$::tcl_platform(platform)" == "windows" } {
    set aTclLibName "tcl85"
    set aTkLibName  "tk85"
  } else {
    set aTclLibName "tcl8.5"
    set aTkLibName  "tk8.5"
  }

  foreach anArchIter {64 32} {
    set aTclLibPath [wokdep:SearchLib "$aTclLibName" "$anArchIter"]
    set aTkLibPath  [wokdep:SearchLib "$aTkLibName"  "$anArchIter"]
    if { "$aTclLibPath" == "" || "$aTkLibPath" == "" } {
      set aPath [wokdep:Preferred [glob -nocomplain -directory "$::PRODUCTS_PATH" -type d *{tcl}*] "$::VCVER" "$anArchIter" ]
      set aTclLibPath [wokdep:SearchLib "$aTclLibName" "$anArchIter" "$aPath/lib"]
      set aTkLibPath  [wokdep:SearchLib "$aTkLibName"  "$anArchIter" "$aPath/lib"]
      if { "$aTclLibPath" != "" && "$aTkLibPath" != "" } {
        lappend ::CSF_OPT_LIB$anArchIter "$aPath/lib"
      } else {
        lappend anErrLib$anArchIter "Error: '${::SYS_LIB_PREFIX}${aTclLibName}.${::SYS_LIB_SUFFIX}' or '${::SYS_LIB_PREFIX}${aTkLibName}.${::SYS_LIB_SUFFIX}' not found (Tcl/Tk)"
        if { "$::ARCH" == "$anArchIter"} { set isFound "false" }
      }
    }

    if { "$::tcl_platform(platform)" == "windows" } {
      set aTclDllPath [wokdep:SearchBin "${aTclLibName}.dll" "$anArchIter"]
      set aTkDllPath  [wokdep:SearchBin "${aTkLibName}.dll"  "$anArchIter"]
      if { "$aTclDllPath" == "" || "$aTkDllPath" == "" } {
        set aPath [wokdep:Preferred [glob -nocomplain -directory "$::PRODUCTS_PATH" -type d *{tcl}*] "$::VCVER" "$anArchIter" ]
        set aTclDllPath [wokdep:SearchBin "${aTclLibName}.dll" "$anArchIter" "$aPath/bin"]
        set aTkDllPath  [wokdep:SearchBin "${aTkLibName}.dll"  "$anArchIter" "$aPath/bin"]
        if { "$aTclDllPath" != "" && "$aTkDllPath" != "" } {
          lappend ::CSF_OPT_BIN$anArchIter "$aPath/bin"
        } else {
          lappend anErrBin$anArchIter "Error: '${aTclLibName}.dll' or '${aTkLibName}.dll' not found (Tcl/Tk)"
          if { "$::ARCH" == "$anArchIter"} { set isFound "false" }
        }
      }
    }
  }

  return "$isFound"
}

# Search FreeType library placement
proc wokdep:SearchFreeType {theErrInc theErrLib32 theErrLib64 theErrBin32 theErrBin64} {
  upvar $theErrInc   anErrInc
  upvar $theErrLib32 anErrLib32
  upvar $theErrLib64 anErrLib64
  upvar $theErrBin32 anErrBin32
  upvar $theErrBin64 anErrBin64

  set isFound "true"
  set aFtPath      [wokdep:SearchHeader "freetype/freetype.h"]
  set aFtBuildPath [wokdep:SearchHeader "ft2build.h"]
  if { "$aFtPath"  == "" || "$aFtBuildPath" == "" } {
    # TODO - use `freetype-config --cflags` instead
    set aSysFreeType "/usr/include/freetype2"
    if { [file exists "$aSysFreeType/freetype/freetype.h"] } {
      lappend ::CSF_OPT_INC "$aSysFreeType"
    } else {
      set aSysFreeType "/usr/X11/include/freetype2"
      if { [file exists "$aSysFreeType/freetype/freetype.h"] } {
        lappend ::CSF_OPT_INC "/usr/X11/include"
        lappend ::CSF_OPT_INC "$aSysFreeType"
      } else {
        set aPath [wokdep:Preferred [glob -nocomplain -directory "$::PRODUCTS_PATH" -type d *{freetype}*] "$::VCVER" "$::ARCH" ]
        if { "$aPath" != "" && [file exists "$aPath/include/freetype/freetype.h"] && [file exists "$aPath/include/ft2build.h"] } {
          lappend ::CSF_OPT_INC "$aPath/include"
        } else {
          lappend anErrInc "Error: 'freetype.h' not found (FreeType2)"
          set isFound "false"
        }
      }
    }
  }

  # parse 'freetype-config --libs'
  set aConfLibPath ""
  if { [catch { set aConfLibs [exec freetype-config --libs] } ] == 0 } {
    foreach aPath [split $aConfLibs " "] {
      if { [string first "-L" "$aPath"] == 0 } {
        set aConfLibPath [string range "$aPath" 2 [string length "$aPath"]]
      }
    }
  }

  foreach anArchIter {64 32} {
    set aFtLibPath [wokdep:SearchLib "freetype" "$anArchIter"]
    if { "$aFtLibPath" == "" } {
      set aPath [wokdep:Preferred [glob -nocomplain -directory "$::PRODUCTS_PATH" -type d *{freetype}*] "$::VCVER" "$anArchIter" ]
      set aFtLibPath [wokdep:SearchLib "freetype" "$anArchIter" "$aPath/lib"]
      if { "$aFtLibPath" != "" } {
        lappend ::CSF_OPT_LIB$anArchIter "$aPath/lib"
      } else {
        set aFtLibPath [wokdep:SearchLib "freetype" "$anArchIter" "$aConfLibPath"]
        if { "$aFtLibPath" != "" } {
          lappend ::CSF_OPT_LIB$anArchIter "$aConfLibPath"
        } else {
          lappend anErrLib$anArchIter "Error: '${::SYS_LIB_PREFIX}freetype.${::SYS_LIB_SUFFIX}' not found (FreeType2)"
          if { "$::ARCH" == "$anArchIter"} { set isFound "false" }
        }
      }
    }
    if { "$::tcl_platform(platform)" == "windows" } {
      set aFtDllPath [wokdep:SearchBin "freetype.dll" "$anArchIter"]
      if { "$aFtDllPath" == "" } {
        set aPath [wokdep:Preferred [glob -nocomplain -directory "$::PRODUCTS_PATH" -type d *{freetype}*] "$::VCVER" "$anArchIter" ]
        set aFtDllPath [wokdep:SearchBin "freetype.dll" "$anArchIter" "$aPath/bin"]
        if { "$aFtDllPath" != "" } {
          lappend ::CSF_OPT_BIN$anArchIter "$aPath/bin"
        } else {
          set aFtDllPath [wokdep:SearchBin "freetype.dll" "$anArchIter" "$aPath/lib"]
          if { "$aFtDllPath" != "" } {
            lappend ::CSF_OPT_BIN$anArchIter "$aPath/lib"
          } else {
            lappend anErrBin$anArchIter "Error: 'freetype.dll' not found (FreeType2)"
            if { "$::ARCH" == "$anArchIter"} { set isFound "false" }
          }
        }
      }
    }
  }

  return "$isFound"
}

# Search FTGL library placement
proc wokdep:SearchFTGL {theErrInc theErrLib32 theErrLib64 theErrBin32 theErrBin64} {
  upvar $theErrInc   anErrInc
  upvar $theErrLib32 anErrLib32
  upvar $theErrLib64 anErrLib64
  upvar $theErrBin32 anErrBin32
  upvar $theErrBin64 anErrBin64

  # The path in the case of building VS project on windows
  set aWinBuildPath "msvc/Build"

  set isFound "true"
  set aFtglFontPath  [wokdep:SearchHeader "FTGL/FTGLTextureFont.h"]
  set aFtglFtLibPath [wokdep:SearchHeader "FTGL/ftgl.h"]
  if { "$aFtglFontPath"  == "" || "$aFtglFtLibPath"  == "" } {
    set aPath [wokdep:Preferred [glob -nocomplain -directory "$::PRODUCTS_PATH" -type d *{ftgl,FTGL}*] "$::VCVER" "$::ARCH" ]
    if { "$aPath" != "" && [file exists "$aPath/include/FTGL/ftgl.h"] } {
      lappend ::CSF_OPT_INC "$aPath/include"
    } else {
      lappend anErrInc "Error: 'FTGL/ftgl.h' not found (FTGL)"
      set isFound "false"
    }
  }

  foreach anArchIter {64 32} {
    set aFtglLibPath [wokdep:SearchLib "ftgl" "$anArchIter"]
    if { "$aFtglLibPath" == "" } {
      set aPath [wokdep:Preferred [glob -nocomplain -directory "$::PRODUCTS_PATH" -type d *{ftgl,FTGL}*] "$::VCVER" "$anArchIter" ]
      set aFtglLibPath [wokdep:SearchLib "ftgl" "$anArchIter" "$aPath/lib"]
      if { "$aFtglLibPath" != "" } {
        lappend ::CSF_OPT_LIB$anArchIter "$aPath/lib"
      } else {
        set aFtglLibPath [wokdep:SearchLib "ftgl" "$anArchIter" "$aPath/$aWinBuildPath"]
        if { "$::tcl_platform(platform)" == "windows" && "$aFtglLibPath" != "" } {
          lappend ::CSF_OPT_LIB$anArchIter "$aPath/$aWinBuildPath"
        } else {
          lappend anErrLib$anArchIter "Error: '${::SYS_LIB_PREFIX}ftgl.${::SYS_LIB_SUFFIX}' not found (FTGL)"
          if { "$::ARCH" == "$anArchIter"} { set isFound "false" }
        }
      }
    }
    if { "$::tcl_platform(platform)" == "windows" } {
      set aFtglDllPath    [wokdep:SearchBin "ftgl.dll"             "$anArchIter"]
      if { "$aFtglDllPath" == "" } {
        set aPath [wokdep:Preferred [glob -nocomplain -directory "$::PRODUCTS_PATH" -type d *{ftgl}*] "$::VCVER" "$anArchIter" ]
        set aFtglDllPath     [wokdep:SearchBin "ftgl.dll" "$anArchIter" "$aPath/bin"]
        set aFtglWinDllPath  [wokdep:SearchBin "ftgl.dll" "$anArchIter" "$aPath/$aWinBuildPath"]
        if { "$aFtglDllPath" != "" } {
          lappend ::CSF_OPT_BIN$anArchIter "$aPath/bin"
        } elseif { "$aFtglWinDllPath" != "" } {
          lappend ::CSF_OPT_BIN$anArchIter "$aPath/$aWinBuildPath"
        } else {
          lappend anErrBin$anArchIter "Error: 'ftgl.dll' not found (FTGL)"
          if { "$::ARCH" == "$anArchIter"} { set isFound "false" }
        }
      }
    }
  }

  return "$isFound"
}

# Search FreeImage library placement
proc wokdep:SearchFreeImage {theErrInc theErrLib32 theErrLib64 theErrBin32 theErrBin64} {
  upvar $theErrInc   anErrInc
  upvar $theErrLib32 anErrLib32
  upvar $theErrLib64 anErrLib64
  upvar $theErrBin32 anErrBin32
  upvar $theErrBin64 anErrBin64

  # binary distribution has another layout
  set aFImageDist     "Dist"
  set aFImagePlusDist "Wrapper/FreeImagePlus/dist"

  set isFound "true"
  set aFImageHPath     [wokdep:SearchHeader "FreeImage.h"]
  set aFImagePlusHPath [wokdep:SearchHeader "FreeImagePlus.h"]
  if { "$aFImageHPath" == "" || "$aFImagePlusHPath"  == "" } {
    set aPath [wokdep:Preferred [glob -nocomplain -directory "$::PRODUCTS_PATH" -type d *{freeimage}*] "$::VCVER" "$::ARCH" ]
    if { "$aPath" != "" && [file exists "$aPath/include/FreeImage.h"] && [file exists "$aPath/include/FreeImagePlus.h"] } {
      lappend ::CSF_OPT_INC "$aPath/include"
    } elseif { "$aPath" != "" && [file exists "$aPath/$aFImageDist/FreeImage.h"] && [file exists "$aPath/$aFImagePlusDist/FreeImagePlus.h"] } {
      lappend ::CSF_OPT_INC "$aPath/$aFImageDist"
      lappend ::CSF_OPT_INC "$aPath/$aFImagePlusDist"
    } else {
      lappend anErrInc "Error: 'FreeImage.h' or 'FreeImagePlus.h' not found (FreeImage)"
      set isFound "false"
    }
  }

  foreach anArchIter {64 32} {
    set aFImageLibPath     [wokdep:SearchLib "freeimage"     "$anArchIter"]
    set aFImagePlusLibPath [wokdep:SearchLib "freeimageplus" "$anArchIter"]
    if { "$aFImageLibPath" == "" || "$aFImagePlusLibPath"  == "" } {
      set aPath [wokdep:Preferred [glob -nocomplain -directory "$::PRODUCTS_PATH" -type d *{freeimage}*] "$::VCVER" "$anArchIter" ]
      set aFImageLibPath     [wokdep:SearchLib "freeimage"     "$anArchIter" "$aPath/lib"]
      set aFImagePlusLibPath [wokdep:SearchLib "freeimageplus" "$anArchIter" "$aPath/lib"]
      if { "$aFImageLibPath" != "" && "$aFImagePlusLibPath"  != "" } {
        lappend ::CSF_OPT_LIB$anArchIter "$aPath/lib"
      } else {
        set aFImageLibPath     [wokdep:SearchLib "freeimage"     "$anArchIter" "$aPath/$aFImageDist"]
        set aFImagePlusLibPath [wokdep:SearchLib "freeimageplus" "$anArchIter" "$aPath/$aFImagePlusDist"]
        if { "$aFImageLibPath" != "" && "$aFImagePlusLibPath"  != "" } {
          lappend ::CSF_OPT_LIB$anArchIter "$aPath/$aFImageDist"
          lappend ::CSF_OPT_LIB$anArchIter "$aPath/$aFImagePlusDist"
        } else {
          lappend anErrLib$anArchIter "Error: '${::SYS_LIB_PREFIX}freeimage.${::SYS_LIB_SUFFIX}' or '${::SYS_LIB_PREFIX}freeimageplus.${::SYS_LIB_SUFFIX}' not found (FreeImage)"
          if { "$::ARCH" == "$anArchIter"} { set isFound "false" }
        }
      }
    }
    if { "$::tcl_platform(platform)" == "windows" } {
      set aFImageDllPath     [wokdep:SearchBin "freeimage.dll"     "$anArchIter"]
      set aFImagePlusDllPath [wokdep:SearchBin "freeimageplus.dll" "$anArchIter"]
      if { "$aFImageDllPath" == "" || "$aFImagePlusDllPath" == "" } {
        set aPath [wokdep:Preferred [glob -nocomplain -directory "$::PRODUCTS_PATH" -type d *{freeimage}*] "$::VCVER" "$anArchIter" ]
        set aFImageDllPath     [wokdep:SearchBin "freeimage.dll"     "$anArchIter" "$aPath/bin"]
        set aFImagePlusDllPath [wokdep:SearchBin "freeimageplus.dll" "$anArchIter" "$aPath/bin"]
        if { "$aFImageDllPath" != "" && "$aFImagePlusDllPath" != "" } {
          lappend ::CSF_OPT_BIN$anArchIter "$aPath/bin"
        } else {
          set aFImageDllPath     [wokdep:SearchBin "freeimage.dll"     "$anArchIter" "$aPath/$aFImageDist"]
          set aFImagePlusDllPath [wokdep:SearchBin "freeimageplus.dll" "$anArchIter" "$aPath/$aFImagePlusDist"]
          if { "$aFImageDllPath" != "" && "$aFImagePlusDllPath" != "" } {
            lappend ::CSF_OPT_BIN$anArchIter "$aPath/$aFImageDist"
            lappend ::CSF_OPT_BIN$anArchIter "$aPath/$aFImagePlusDist"
          } else {
            lappend anErrBin$anArchIter "Error: 'freeimage.dll' or 'freeimageplus.dll' not found (FreeImage)"
            if { "$::ARCH" == "$anArchIter"} { set isFound "false" }
          }
        }
      }
    }
  }

  return "$isFound"
}

# Search GL2PS library placement
proc wokdep:SearchGL2PS {theErrInc theErrLib32 theErrLib64 theErrBin32 theErrBin64} {
  upvar $theErrInc   anErrInc
  upvar $theErrLib32 anErrLib32
  upvar $theErrLib64 anErrLib64
  upvar $theErrBin32 anErrBin32
  upvar $theErrBin64 anErrBin64

  set isFound "true"
  set aGl2psHPath [wokdep:SearchHeader "gl2ps.h"]
  if { "$aGl2psHPath"  == "" } {
    set aPath [wokdep:Preferred [glob -nocomplain -directory "$::PRODUCTS_PATH" -type d *{gl2ps}*] "$::VCVER" "$::ARCH" ]
    if { "$aPath" != "" && [file exists "$aPath/include/gl2ps.h"] } {
      lappend ::CSF_OPT_INC "$aPath/include"
    } else {
      lappend anErrInc "Error: 'gl2ps.h' not found (GL2PS)"
      set isFound "false"
    }
  }

  foreach anArchIter {64 32} {
    set aGl2psLibPath [wokdep:SearchLib "gl2ps" "$anArchIter"]
    if { "$aGl2psLibPath" == "" } {
      set aPath [wokdep:Preferred [glob -nocomplain -directory "$::PRODUCTS_PATH" -type d *{gl2ps}*] "$::VCVER" "$anArchIter" ]
      set aGl2psLibPath [wokdep:SearchLib "gl2ps" "$anArchIter" "$aPath/lib"]
      if { "$aGl2psLibPath" != "" } {
        lappend ::CSF_OPT_LIB$anArchIter "$aPath/lib"
      } else {
        lappend anErrLib$anArchIter "Error: '${::SYS_LIB_PREFIX}gl2ps.${::SYS_LIB_SUFFIX}' not found (GL2PS)"
        if { "$::ARCH" == "$anArchIter"} { set isFound "false" }
      }
    }
    if { "$::tcl_platform(platform)" == "windows" } {
      set aGl2psDllPath [wokdep:SearchBin "gl2ps.dll" "$anArchIter"]
      if { "$aGl2psDllPath" == "" } {
        set aPath [wokdep:Preferred [glob -nocomplain -directory "$::PRODUCTS_PATH" -type d *{gl2ps}*] "$::VCVER" "$anArchIter" ]
        set aGl2psDllPath [wokdep:SearchBin "gl2ps.dll" "$anArchIter" "$aPath/bin"]
        if { "$aGl2psDllPath" != "" } {
          lappend ::CSF_OPT_BIN$anArchIter "$aPath/bin"
        } else {
          set aGl2psDllPath [wokdep:SearchBin "gl2ps.dll" "$anArchIter" "$aPath/lib"]
          if { "$aGl2psDllPath" != "" } {
            lappend ::CSF_OPT_BIN$anArchIter "$aPath/lib"
          } else {
            lappend anErrBin$anArchIter "Error: 'gl2ps.dll' not found (GL2PS)"
            if { "$::ARCH" == "$anArchIter"} { set isFound "false" }
          }
        }
      }
    }
  }

  return "$isFound"
}

# Search TBB library placement
proc wokdep:SearchTBB {theErrInc theErrLib32 theErrLib64 theErrBin32 theErrBin64} {
  upvar $theErrInc   anErrInc
  upvar $theErrLib32 anErrLib32
  upvar $theErrLib64 anErrLib64
  upvar $theErrBin32 anErrBin32
  upvar $theErrBin64 anErrBin64

  set isFound "true"
  set aTbbHPath [wokdep:SearchHeader "tbb/scalable_allocator.h"]
  if { "$aTbbHPath"  == "" } {
    set aPath [wokdep:Preferred [glob -nocomplain -directory "$::PRODUCTS_PATH" -type d *{tbb}*] "$::VCVER" "$::ARCH" ]
    if { "$aPath" != "" && [file exists "$aPath/include/tbb/scalable_allocator.h"] } {
      lappend ::CSF_OPT_INC "$aPath/include"
    } else {
      lappend anErrInc "Error: 'tbb/scalable_allocator.h' not found (Intel TBB)"
      set isFound "false"
    }
  }

  foreach anArchIter {64 32} {
    set aSubDir "ia32"
    if { "$anArchIter" == "64"} {
      set aSubDir "intel64"
    }

    set aTbbLibPath [wokdep:SearchLib "tbb" "$anArchIter"]
    if { "$aTbbLibPath" == "" } {
      set aPath [wokdep:Preferred [glob -nocomplain -directory "$::PRODUCTS_PATH" -type d *{tbb}*] "$::VCVER" "$anArchIter" ]
      set aTbbLibPath [wokdep:SearchLib "tbb" "$anArchIter" "$aPath/lib/$aSubDir/${::VCVER}"]
      if { "$aTbbLibPath" == "" } {
        # Set the path to the TBB library for Linux
        if { "$::tcl_platform(platform)" != "windows" } {
          set aSubDir "$aSubDir/cc4.1.0_libc2.4_kernel2.6.16.21"
        }
        set aTbbLibPath [wokdep:SearchLib "tbb" "$anArchIter" "$aPath/lib/$aSubDir"]
        if { "$aTbbLibPath" != "" } {
          lappend ::CSF_OPT_LIB$anArchIter "$aPath/lib/$aSubDir"
        }
      } else {
        lappend ::CSF_OPT_LIB$anArchIter "$aPath/lib/$aSubDir/${::VCVER}"
      }
      if { "$aTbbLibPath" == "" } {
        lappend anErrLib$anArchIter "Error: '${::SYS_LIB_PREFIX}tbb.${::SYS_LIB_SUFFIX}' not found (Intel TBB)"
        if { "$::ARCH" == "$anArchIter"} { set isFound "false" }
      }
    }
    if { "$::tcl_platform(platform)" == "windows" } {
      set aTbbDllPath [wokdep:SearchBin "tbb.dll" "$anArchIter"]
      if { "$aTbbDllPath" == "" } {
        set aPath [wokdep:Preferred [glob -nocomplain -directory "$::PRODUCTS_PATH" -type d *{tbb}*] "$::VCVER" "$anArchIter" ]
        set aTbbDllPath [wokdep:SearchBin "tbb.dll" "$anArchIter" "$aPath/bin/$aSubDir/${::VCVER}"]
        if { "$aTbbDllPath" != "" } {
          lappend ::CSF_OPT_BIN$anArchIter "$aPath/bin/$aSubDir/${::VCVER}"
        } else {
          lappend anErrBin$anArchIter "Error: 'tbb.dll' not found (Intel TBB)"
          if { "$::ARCH" == "$anArchIter"} { set isFound "false" }
        }
      }
    }
  }

  return "$isFound"
}

# Search Qt4 libraries placement
proc wokdep:SearchQt4 {theErrInc theErrLib32 theErrLib64 theErrBin32 theErrBin64} {
  upvar $theErrInc   anErrInc
  upvar $theErrLib32 anErrLib32
  upvar $theErrLib64 anErrLib64
  upvar $theErrBin32 anErrBin32
  upvar $theErrBin64 anErrBin64

  set isFound "true"
  set aQMsgBoxHPath [wokdep:SearchHeader "QtGui/qmessagebox.h"]
  if { "$aQMsgBoxHPath" == "" } {
    set aPath [wokdep:Preferred [glob -nocomplain -directory "$::PRODUCTS_PATH" -type d *{qt4}*] "$::VCVER" "$::ARCH" ]
    if { "$aPath" != "" && [file exists "$aPath/include/QtGui/qmessagebox.h"] } {
      lappend ::CSF_OPT_INC "$aPath/include"
      lappend ::CSF_OPT_INC "$aPath/include/Qt"
      lappend ::CSF_OPT_INC "$aPath/include/QtGui"
      lappend ::CSF_OPT_INC "$aPath/include/QtCore"
    } else {
      if { [file exists "/usr/include/qt4/QtGui/qmessagebox.h"] } {
        lappend ::CSF_OPT_INC "/usr/include/qt4"
        lappend ::CSF_OPT_INC "/usr/include/qt4/Qt"
        lappend ::CSF_OPT_INC "/usr/include/qt4/QtGui"
        lappend ::CSF_OPT_INC "/usr/include/qt4/QtCore"
      } else {
        lappend anErrInc "Error: 'QtGui/qmessagebox.h' not found (Qt4)"
        set isFound "false"
      }
    }
  }

  set aQtGuiLibName "QtGui"
  if { "$::tcl_platform(platform)" == "windows" } {
    set aQtGuiLibName "QtGui4"
  }

  foreach anArchIter {64 32} {
    set aQMsgBoxLibPath [wokdep:SearchLib "${aQtGuiLibName}" "$anArchIter"]
    if { "$aQMsgBoxLibPath" == "" } {
      set aPath [wokdep:Preferred [glob -nocomplain -directory "$::PRODUCTS_PATH" -type d *{qt4}*] "$::VCVER" "$anArchIter" ]
      set aQMsgBoxLibPath [wokdep:SearchLib "${aQtGuiLibName}" "$anArchIter" "$aPath/lib"]
      if { "$aQMsgBoxLibPath" != "" } {
        lappend ::CSF_OPT_LIB$anArchIter "$aPath/lib"
      } else {
        lappend anErrLib$anArchIter "Error: '${::SYS_LIB_PREFIX}${aQtGuiLibName}.${::SYS_LIB_SUFFIX}' not found (Qt4)"
        if { "$::ARCH" == "$anArchIter"} { set isFound "false" }
      }
    }
    if { "$::tcl_platform(platform)" == "windows" } {
      set aQMsgBoxDllPath [wokdep:SearchBin "QtGui4.dll" "$anArchIter"]
      if { "$aQMsgBoxDllPath" == "" } {
        set aPath [wokdep:Preferred [glob -nocomplain -directory "$::PRODUCTS_PATH" -type d *{qt4}*] "$::VCVER" "$anArchIter" ]
        set aQMsgBoxDllPath [wokdep:SearchBin "QtGui4.dll" "$anArchIter" "$aPath/bin"]
        if { "$aQMsgBoxDllPath" != "" } {
          lappend ::CSF_OPT_BIN$anArchIter "$aPath/bin"
        } else {
          lappend anErrBin$anArchIter "Error: 'QtGui4.dll' not found (Qt4)"
          if { "$::ARCH" == "$anArchIter"} { set isFound "false" }
        }
      }
    }
  }

  return "$isFound"
}

# Search JDK placement
proc wokdep:SearchJDK {theErrInc theErrLib32 theErrLib64 theErrBin32 theErrBin64} {
  upvar $theErrInc   anErrInc
  upvar $theErrLib32 anErrLib32
  upvar $theErrLib64 anErrLib64
  upvar $theErrBin32 anErrBin32
  upvar $theErrBin64 anErrBin64

  set isFound "true"
  set aJniHPath   [wokdep:SearchHeader "jni.h"]
  set aJniMdHPath [wokdep:SearchHeader "jni_md.h"]
  if { "$aJniHPath" == "" || "$aJniMdHPath" == "" } {
    set aPath [wokdep:Preferred [glob -nocomplain -directory "$::PRODUCTS_PATH" -type d *{jdk,java}*] "$::VCVER" "$::ARCH" ]
    if { "$aPath" != "" && [file exists "$aPath/include/jni.h"] } {
      lappend ::CSF_OPT_INC "$aPath/include"
      if { "$::tcl_platform(platform)" == "windows" } {
        lappend ::CSF_OPT_INC "$aPath/include/win32"
      } elseif { [file exists "$aPath/include/linux"] } {
        lappend ::CSF_OPT_INC "$aPath/include/linux"
      }
    } else {
      if { [file exists "/System/Library/Frameworks/JavaVM.framework/Home/include/jni.h"] } {
        lappend ::CSF_OPT_INC "/System/Library/Frameworks/JavaVM.framework/Home/include"
      } else {
        lappend anErrInc "Error: 'jni.h' or 'jni_md.h' not found (JDK)"
        set isFound "false"
      }
    }
  }

  foreach anArchIter {64 32} {
    set aJavacPath [wokdep:SearchBin "javac${::SYS_EXE_SUFFIX}" "$anArchIter"]
    if { "$aJavacPath" == "" } {
      set aPath [wokdep:Preferred [glob -nocomplain -directory "$::PRODUCTS_PATH" -type d *{jdk,java}*] "$::VCVER" "$anArchIter" ]
      set aJavacPath [wokdep:SearchBin "javac${::SYS_EXE_SUFFIX}" "$anArchIter" "$aPath/bin"]
      if { "$aJavacPath" != "" } {
        lappend ::CSF_OPT_BIN$anArchIter "$aPath/bin"
      } else {
        if { "$::ARCH" == "$anArchIter" && [file exists "/System/Library/Frameworks/JavaVM.framework/Home/bin/javac${::SYS_EXE_SUFFIX}"] } {
          lappend ::CSF_OPT_BIN$anArchIter "/System/Library/Frameworks/JavaVM.framework/Home/bin"
        } else {
          lappend anErrBin$anArchIter "Error: 'javac${::SYS_EXE_SUFFIX}' not found (JDK)"
          if { "$::ARCH" == "$anArchIter"} { set isFound "false" }
        }
      }
    }
  }

  return "$isFound"
}

# Search X11 libraries placement
proc wokdep:SearchX11 {theErrInc theErrLib32 theErrLib64 theErrBin32 theErrBin64} {
  upvar $theErrInc   anErrInc
  upvar $theErrLib32 anErrLib32
  upvar $theErrLib64 anErrLib64
  upvar $theErrBin32 anErrBin32
  upvar $theErrBin64 anErrBin64

  set isFound "true"
  if { "$::tcl_platform(platform)" == "windows" } {
    return "$isFound"
  }

  set aXmuLibPath [wokdep:SearchLib "Xmu" "$::ARCH"]
  if { "$aXmuLibPath" == "" } {
    set aXmuLibPath [wokdep:SearchLib "Xmu" "$::ARCH" "/usr/X11/lib"]
    if { "$aXmuLibPath" != "" } {
      #lappend ::CSF_OPT_LIB$::ARCH "/usr/X11/lib"
    } else {
      lappend anErrLib$::ARCH "Error: '${::SYS_LIB_PREFIX}Xmu.${::SYS_LIB_SUFFIX}' not found (X11)"
      set isFound "false"
    }
  }

  return "$isFound"
}

# Generate (override) custom environment file
proc wokdep:SaveCustom {} {
  if { "$::tcl_platform(platform)" == "windows" } {
    set aCustomFilePath "$::env(WOKHOME)/site/custom.bat"
    set aFile [open $aCustomFilePath "w"]
    puts $aFile "@echo off"
    puts $aFile "rem This environment file was generated by wok_depsgui.tcl script at [clock format [clock seconds] -format "%Y.%m.%d %H:%M"]"

    puts $aFile ""
    puts $aFile "set VCVER=$::VCVER"
    puts $aFile "set ARCH=$::ARCH"
    puts $aFile "set VCVARS=$::VCVARS"

    puts $aFile ""
    puts $aFile "set \"PRODUCTS_PATH=$::PRODUCTS_PATH\""

    puts $aFile ""
    puts $aFile "rem Optional 3rd-parties switches"
    puts $aFile "set HAVE_FREEIMAGE=$::HAVE_FREEIMAGE"
    puts $aFile "set HAVE_GL2PS=$::HAVE_GL2PS"
    puts $aFile "set HAVE_TBB=$::HAVE_TBB"
    puts $aFile "set CHECK_QT4=$::CHECK_QT4"
    puts $aFile "set CHECK_JDK=$::CHECK_JDK"

    set aStringInc [join $::CSF_OPT_INC $::SYS_PATH_SPLITTER]
    puts $aFile ""
    puts $aFile "rem Additional headers search paths"
    puts $aFile "set \"CSF_OPT_INC=$aStringInc\""

    set aStringLib32 [join $::CSF_OPT_LIB32 $::SYS_PATH_SPLITTER]
    puts $aFile ""
    puts $aFile "rem Additional libraries (32-bit) search paths"
    puts $aFile "set \"CSF_OPT_LIB32=$aStringLib32\""

    set aStringLib64 [join $::CSF_OPT_LIB64 $::SYS_PATH_SPLITTER]
    puts $aFile ""
    puts $aFile "rem Additional libraries (64-bit) search paths"
    puts $aFile "set \"CSF_OPT_LIB64=$aStringLib64\""

    set aStringBin32 [join $::CSF_OPT_BIN32 $::SYS_PATH_SPLITTER]
    puts $aFile ""
    puts $aFile "rem Additional (32-bit) search paths"
    puts $aFile "set \"CSF_OPT_BIN32=$aStringBin32\""

    set aStringBin64 [join $::CSF_OPT_BIN64 $::SYS_PATH_SPLITTER]
    puts $aFile ""
    puts $aFile "rem Additional (64-bit) search paths"
    puts $aFile "set \"CSF_OPT_BIN64=$aStringBin64\""

    close $aFile
  } else {
    set aCustomFilePath "$::env(WOKHOME)/site/custom.sh"
    set aFile [open $aCustomFilePath "w"]
    puts $aFile "#!/bin/bash"
    puts $aFile "# This environment file was generated by wok_depsgui.tcl script at [clock format [clock seconds] -format "%Y.%m.%d %H:%M"]"

    #puts $aFile ""
    #puts $aFile "export ARCH=$::ARCH"

    puts $aFile ""
    puts $aFile "export PRODUCTS_PATH=\"$::PRODUCTS_PATH\""

    puts $aFile ""
    puts $aFile "# Optional 3rd-parties switches"
    puts $aFile "export HAVE_FREEIMAGE=$::HAVE_FREEIMAGE"
    puts $aFile "export HAVE_GL2PS=$::HAVE_GL2PS"
    puts $aFile "export HAVE_TBB=$::HAVE_TBB"
    puts $aFile "export CHECK_QT4=$::CHECK_QT4"
    puts $aFile "export CHECK_JDK=$::CHECK_JDK"

    set aStringInc [join $::CSF_OPT_INC $::SYS_PATH_SPLITTER]
    puts $aFile ""
    puts $aFile "# Additional headers search paths"
    puts $aFile "export CSF_OPT_INC=\"$aStringInc\""

    set aStringLib$::ARCH [join [set ::CSF_OPT_LIB$::ARCH] $::SYS_PATH_SPLITTER]
    puts $aFile ""
    puts $aFile "# Additional libraries ($::ARCH-bit) search paths"
    puts $aFile "export CSF_OPT_LIB$::ARCH=\"[set aStringLib$::ARCH]\""

    set aStringBin$::ARCH [join [set ::CSF_OPT_BIN$::ARCH] $::SYS_PATH_SPLITTER]
    puts $aFile ""
    puts $aFile "# Additional ($::ARCH-bit) search paths"
    puts $aFile "export CSF_OPT_BIN$::ARCH=\"[set aStringBin$::ARCH]\""

    close $aFile
  }

  puts "Configuration saved to file '$aCustomFilePath'"
}
