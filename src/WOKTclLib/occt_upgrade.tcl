# This script contains procedures used for upgrade of OCCT and products
# to version 7.0:
# - conversion of instances of TCollection classes to NCollection equivalents
# - changes required after conversion of RTTI and Handles to templates
# - removal of CDL, elimination of IXX and JXX, and putting all generated HXX 
#   to src
#
# See history of changes in OCCT Git to see how this script has been applied;
# relevant issues are: 24830, 24806, 24947, 24750, 24859, 24023, 24002 
# (and related)
# 
# Note that upgrade tool in OCCT (see 24816) is based on this script, but
# does not include procedures related to CDL and WOK processing, while other 
# procedures are extended to handle cases found in other projects.

# Puts information message to logger.
proc loginfo {a} {
    _logcommon $a ""
}

# Puts warning message to logger.
proc logwarn {a} {
    _logcommon $a "pink"
}

# Puts error message to logger.
proc logerr {a} {
    _logcommon $a "red"
}

# Extracts package names to the given file.
proc extract_package_names {OCCT_path resfile} {
  loginfo "Extracting OCCT package names into $resfile..."
  loginfo "OCCT root: $OCCT_path"
  check_path "$OCCT_path/src"

  # Loop over toolkits to gather package names from PACKAGES files
  foreach TK_dir [lappend {*}[glob -nocomplain -directory $OCCT_path/src -type d TK*]] {
      loginfo "Next found toolkit: $TK_dir"
      foreach package [_open_file $TK_dir/PACKAGES] {
          if { $package == "" } continue
          loginfo "\t$package"
          lappend packages $package
      }
  }
  set packages_str [join $packages ",\n"]

  # Save comma-separated package names to the destination file
  loginfo "Writing package names to $resfile..."
  set contents "occt_packages=\n$packages_str"
  _save_file $resfile $contents
}

# Main tool, accepts path to location of source tree to be upgraded.
proc occt_upgrade {path args} {
  loginfo "Invoked occt_upgrade $path $args"

  # parse arguments to get inc and src directories
  set inc [_get_args_for_option "-incdir" args "${path}/inc"]
  set src [_get_args_for_option "-srcdir" args "${path}/src"]
  check_path ${inc}
  check_path ${src}

  # parse arguments
  set process_tcollection 0
  set process_rtti 0
  set process_rtti_nocdl 0
  set process_handle 0
  set process_downcast 0
  set process_mutable 0
  set process_all 0
  set process_includes 0
  set compat_mode 0
  set fix_mode 1
  set nl_format unix
  set info_file ""
  set occt_packages {}
  foreach arg $args {
    if { $arg == "-nocdl" } {
      occt_upgrade_nocdl ${path} -incdir ${inc} -srcdir ${src}
      return
    } elseif { $arg == "-tcollection" } {
      set process_tcollection 1
    } elseif { $arg == "-rtti" } {
      set process_rtti 1
    } elseif { $arg == "-handle" } {
      set process_handle 1
    } elseif { $arg == "-downcast" } {
      set process_downcast 1
    } elseif { $arg == "-mutable" } {
      set process_mutable 1
    } elseif { $arg == "-all" } {
      set process_all 1
    } elseif { $arg == "-compat" } {
      set compat_mode 1
    } elseif { $arg == "-check" } {
      set fix_mode 0
    } elseif { $arg == "-rtti_nocdl" } {
      set process_rtti_nocdl 1
      set process_rtti 1
    } elseif { $arg == "-ui" } {
      _create_logger
    } elseif { $arg == "-nlf_dos" } {
      set nl_format dos
    } elseif { $arg == "-inc" } {
      set process_includes 1
    } elseif { [regexp -- {-info=(.*)} $arg location match] } {
      set info_file $match
      set occt_packages [_info_extract_packages $info_file]
    } else {
      error "Error: Unrecognized option $arg"
    }
  }

  loginfo "Working dir: $src"
  loginfo "Information file: $info_file"

  set dirs $src
  while {[llength $dirs]} {
    set dirs [lassign $dirs name]
    lappend dirs {*}[glob -nocomplain -directory $name -type d *]
    loginfo "Processing: $name"

    if { $process_all || $process_tcollection } {
      occt_upgrade_tcollection $name ncollection_duplicates -incdir ${inc}
    }
    if { $process_all || $process_rtti } {
      occt_upgrade_rtti $name $fix_mode $compat_mode $nl_format $process_rtti_nocdl -incdir ${inc} -srcdir ${src}
    }
    if { $process_all || $process_handle } {
      occt_upgrade_handle $name $fix_mode
    }
    if { $process_all || $process_downcast } {
      occt_upgrade_downcast $name $fix_mode
    }
    if { $process_all || $process_mutable } {
      occt_upgrade_mutable $name $fix_mode
    }
    if { $process_includes } {
      occt_upgrade_includes $name $occt_packages
    }
  }
}

# Upgrades include style from '#include <occtClass.hxx>' to
# '#include <occtPackage/occtClass.hxx>'.
proc occt_upgrade_includes {pkpath packages} {
  loginfo ">>> Upgrade includes"
  foreach file [_find_files "$pkpath" "*" 0] { # zero means non-recursive search
    set filelist [_open_file $file]
    set index -1
    set wasChanged false
    set _isMulti false
    set _cmnt ""
    foreach line $filelist {
      incr index
      set line [_check_line $line]
      if {[regexp -indices {\#(?:\s)*include(?:\s)*[\"<]+([A-Za-z0-9_/\.]+hxx)[\">]*} $line dummy indexs]} {
        set first [lindex $indexs 0]
        set last [lindex $indexs 1]
        set name [string range $line $first $last]
        if { [regexp {([\!/A-Za-z0-9]+)(?:[\!/_A-Za-z0-9]*).*} $name include_all include_prefix] } {
          set entry_index [lsearch -exact $packages $include_prefix]
          if { $entry_index == -1 } {
            continue
          }

          set wasChanged true
          set newline [string replace $line $first $last "$include_prefix/$name"]
          set filelist [lreplace $filelist $index $index $newline]
        }
      }
    }
    if { $wasChanged } {
      loginfo "$file was modified..."
      _save_file $file $filelist
    }
  }
}

# Replace CDL instantiations of TCollection generic classes by instantiation of
# equivalent NCollection template (defined as C typedef in separate header file
# and as imported type in CDL).
proc occt_upgrade_tcollection {pkpath _duplicates args} {
  loginfo ">>> Upgrade TCollection"

  if { $_duplicates != "" } {
    upvar $_duplicates duplicates
  }

  # parse arguments to get inc and src directories
  set _inc [_get_args_for_option "-incdir" args "${pkpath}/../../inc"]
  check_path ${_inc}

  set UpdatedTColConverted {}
  set UpdatedTColTransient {}

  set package [file tail $pkpath]
  set pkcdl $pkpath/${package}.cdl
  lappend incdir [file normalize $_inc]

  # skip non-CDL packages
  if { ! [file exists $pkcdl] } {
    return
  }

  # load main CDL file
  if { [catch {set fd [open $pkcdl rb]}] } {
    logerr "Error: cannot open $pkcdl"
    return
  }
  set cdl [read $fd]
  close $fd

  # find all instantiations of TCollection generics in CDL and 
  # prepare list of substitutes to new definitions
  set index 0
  set change_flag 0
  set hxxlist {}
  set pattern {^(\s*)(private\s+)?class\s+([A-Za-z_0-9]+)\s+(from\s+[A-Za-z_0-9]+\s+)?instantiates\s+([A-Za-z_0-9]+)\s+from\s+TCollection\s*\(([^\)]+)\)\s*;}
  while { [regexp -start $index -indices -lineanchor $pattern \
                  $cdl location indent private class from collection params] } {
    set index [lindex $location 1]
    set instance [eval string range \$cdl $location]
    loginfo "Found: $instance"
#    loginfo "Parameters: $params"

    set indent     [eval string range \$cdl $indent]
    set class      [eval string range \$cdl $class]
    set collection [eval string range \$cdl $collection]
    set params     [eval string range \$cdl $params]

    # check that equivalent NCollection collection class exists,
    # and decide if we need to have separate typedef for iterator
    if { $collection == "List" ||
         $collection == "Map" ||
         $collection == "DataMap" ||
         $collection == "DoubleMap" } {
      set iterator "${collection}IteratorOf$class"
    } elseif { 
         $collection == "Stack" ||
         $collection == "Sequence" ||
         $collection == "HSequence" ||
         $collection == "Array1" ||
         $collection == "Array2" ||
         $collection == "HArray1" ||
         $collection == "HArray2" ||
         $collection == "IndexedMap" ||
         $collection == "IndexedDataMap" } {
      set iterator ""
    } elseif { 
         $collection == "MapHasher" } {
      # special case: equivalent of TCollection_MapHasher is NCollection_DefaultHasher
      set collection "DefaultHasher"
      set iterator ""
    } else {
      logwarn "Warning: TCollection class $collection has no counterpart in NCollection;"
      logwarn "         class ${package}_$class will not be converted"
      continue
    }

    # convert list of template arguments from CDL to C++ format
    set cppparams {}
    foreach type [split $params ","] {
      if { [llength $type] == 1 } {
        set name [string trim $type]
        # types from Standard are often referenced without "from Standard"...
        if { $name == "Transient" || 
             $name == "Persistent" || 
             $name == "Address" || 
             $name == "Integer" || 
             $name == "Boolean" || 
             $name == "Real" || 
             $name == "ShortReal" || 
             $name == "Character" || 
             $name == "Byte" } {
          lappend cppparams "Standard_$name"
        } else {
          lappend cppparams "${package}_$name"
        }
      } elseif { [llength $type] == 3 && [lindex $type 1] == "from" } {
        lappend cppparams "[lindex $type 2]_[lindex $type 0]"
      } else {
        logerr "Error: cannot recognize CDL type $type"
        set cppparams {}
        break
      }
    }
    if { [llength $cppparams] == 0 } {
      logerr "Error: cannot convert CDL definition to C++"
      continue
    }

    # generate definition of the equivalent class or typedef with
    # all necessary #include statements;
    # note that classes manipulated by handle (starting with 'H')
    # in NCollection are defined as normal classes using macro
    set cppdef ""
    set cppparamshandle {}
    foreach param $cppparams {
      append cppdef "#include <${param}.hxx>\n"

      # check if class is operated by handle, then use handle in collection
      if { [_is_transient $incdir $param] } {
        lappend cppparamshandle Handle\($param\)
      } else {
        lappend cppparamshandle $param
      }
    }
    if { $collection == "HSequence" || 
         $collection == "HArray1" ||  
         $collection == "HArray2" } { 
      set template [string range $collection 1 end]
      append cppdef "#include <NCollection_Define${collection}.hxx>\n\n"
      append cppdef "DEFINE_[string toupper $collection](${package}_$class, [join [lrange $cppparamshandle 1 end] ,])\n"
      set cdldef "${indent}imported transient class $class;"
      lappend UpdatedTColTransient "${package}_${class}"
    } else {
      append cppdef "#include <NCollection_${collection}.hxx>\n\n"
      append cppdef "typedef NCollection_$collection<[join $cppparamshandle ,]> ${package}_$class;\n"
      set cdldef "${indent}imported $class;"
      lappend UpdatedTColConverted "${package}_${class}"
      if { $iterator != "" } {
        append cppdef "typedef NCollection_$collection<[join $cppparamshandle ,]>::Iterator ${package}_$iterator;\n"
        append cdldef "\n${indent}imported $iterator;"
      }
    }
#    puts "----------\n$cppdef\n----------"

    # check for duplicate definitions
    set dupdef "$collection,[join $cppparamshandle ,]"
    if { [info exists duplicates($dupdef)] } {
      logwarn "Warning: definition of ${package}_$class duplicates $duplicates($dupdef)"
    } else {
      set duplicates($dupdef) ${package}_$class
    }

    # create header file(s) defining a collection class
    _make_hxx $pkpath ${package}_$class $cppdef [_extract_top_comment $cdl {--} {//}]
    lappend hxxlist ${package}_${class}.hxx

    # create shortcut header file for iterator, where needed
    if { $iterator != "" } {
      _make_hxx $pkpath ${package}_$iterator "#include <${package}_${class}.hxx>" ""
      lappend hxxlist ${package}_${iterator}.hxx
    }

    # generate replacement string for CDL
    _apply_substitution cdl $location $cdldef index change_flag
#    puts "-> imported $class"
  }
  # update list of converted to NCollection
  set TColConvertedFilePath "$pkpath/../../adm/TColConverted"
  set UpdatedTColConverted [concat $UpdatedTColConverted $UpdatedTColTransient]
  if {[file exists $TColConvertedFilePath]} {
    set UpdatedTColConverted [concat $UpdatedTColConverted [_open_file $TColConvertedFilePath]]
  }
  set UpdatedTColConverted [lsort -unique -dictionary $UpdatedTColConverted]
  while { [lsearch $UpdatedTColConverted ""] == 0 } { set UpdatedTColConverted [lreplace $UpdatedTColConverted 0 0] }
  _save_file $TColConvertedFilePath $UpdatedTColConverted

  # update list of TCollection Transient classes
  set TColTransientFilePath "$pkpath/../../adm/TColTransient"
  if {[file exists $TColTransientFilePath]} {
    set UpdatedTColTransient [concat $UpdatedTColTransient [_open_file $TColTransientFilePath]]
  }
  set UpdatedTColTransient [lsort -unique -dictionary $UpdatedTColTransient]
  while { [lsearch $UpdatedTColTransient ""] == 0 } { set UpdatedTColTransient [lreplace $UpdatedTColTransient 0 0] }
  _save_file $TColTransientFilePath $UpdatedTColTransient

  # apply changes to the package CDL file
  if { $change_flag } {
    _save_text $pkcdl $cdl

    # add headers to FILES
    if { ! [catch {set fd [open $pkpath/FILES r]}] } {
      set hxxlist [concat [split [string trim [read $fd]] \n] $hxxlist]
      close $fd
    }
    _save_text $pkpath/FILES "[join $hxxlist \n]\n"
    catch {exec git add $pkpath/FILES}
  }
}

# Parse source files and:
#
# - add second argument to macro DEFINE_STANDARD_RTTI specifying first base 
#   class found in the class declaration;
# - replace includes of Standard_DefineHandle.hxx by Standard_Type.hxx;
# - add #includes for all classes used as argument to macro
#   STANDARD_TYPE(), except of already included ones
#
# If compat is false, in addition:
# - removes macros IMPLEMENT_DOWNCAST() and IMPLEMENT_STANDARD_*();
proc occt_upgrade_rtti {pkpath fix compat nl_format _is_nocdl args} {
  set package [file tail $pkpath]
  # skip package Standard -- it should be already Ok but contains definitions 
  # of the macros edited by the script
  if { $package == "Standard" } {
    return
  }

  # parse arguments to get inc and src directories
  set _inc [_get_args_for_option "-incdir" args "${pkpath}/../../inc"]
  set _src [_get_args_for_option "-srcdir" args "${pkpath}/../../src"]
  check_path ${_inc}
  check_path ${_src}

  loginfo ">>> Upgrade RTTI"

  lappend incdir [file normalize $_inc]

  # iterate by header and source files
  foreach hxxfile [glob -nocomplain -type f -directory $pkpath *.{?xx,?pp,h,c}] {
    set hxxname [file tail $hxxfile]

    # load HXX file
    if { [catch {set fd [open $hxxfile rb]}] } {
      logerr "Error: cannot open $hxxfile"
      continue
    }
    set hxx [read $fd]
    close $fd

    # find all declarations of classes with public base in this header file;
    # the result is stored in array inherits(class)
    set index 0
    array unset inherits
    set pattern_class {^\s*class\s+([A-Za-z_0-9:]+)\s*:[^;\{]*(public|protected|private)?\s+([A-Za-z_0-9:]+)}
    while { [regexp -start $index -indices -lineanchor $pattern_class \
                    $hxx location class modifier base] } {
      set index [lindex $location 1]

      set class [eval string range \$hxx $class]
      set base  [eval string range \$hxx $base]
#      puts "Found in $hxxname: $class -> $base"

      if { [info exists inherits($class)] } {
        logwarn "Warning in $hxxname: class $class already declared (inheriting $inherits($class))"
      } else {
        set inherits($class) $base
      }
    }

    set change_flag 0

    # find all instances of DEFINE_STANDARD_RTTI with single or two arguments
    set index 0
    set pattern_rtti {^(\s*DEFINE_STANDARD_RTTI\s*)\(\s*([A-Za-z_0-9,\s]+)\s*\)}
    while { [regexp -start $index -indices -lineanchor $pattern_rtti \
                    $hxx location start clist] } {
      set index [lindex $location 1]

      set start [eval string range \$hxx $start]
      set clist [split [eval string range \$hxx $clist] ,]

#      puts "DEFINE_STANDARD_RTTI($clist)"

      if { [llength $clist] == 1 } {
        set class [string trim [lindex $clist 0]]
        if { [info exists inherits($class)] } {
          if { $fix } {
            _apply_substitution hxx $location "${start}($class, $inherits($class))" index change_flag
          }
        } else {
          logwarn "Error in $hxxfile: Macro DEFINE_STANDARD_RTTI used for class $class whose declaration is not found in this file, cannot fix"
        }
      } elseif { [llength $clist] == 2 } {
        set class [string trim [lindex $clist 0]]
        set base  [string trim [lindex $clist 1]]
        if { ! [info exists inherits($class)] } {
          logwarn "Warning in $hxxfile: Macro DEFINE_STANDARD_RTTI used for class $class whose declaration is not found in this file"
        } elseif { $base != $inherits($class) } {
          logwarn "Warning in $hxxfile: Second argument in macro DEFINE_STANDARD_RTTI for class $class is $base while $class seems to inherit from $inherits($class)"
          if { $fix } {
            _apply_substitution hxx $location "${start}($class, $inherits($class))" index change_flag
          }
        }
      }
    }


    # replace includes of Standard_DefineHandle.hxx by Standard_Type.hxx
    set index 0
    set nocdl_replace ""
    if {${_is_nocdl}} {
      set nocdl_replace "Standard/"
      set pattern_definehandle {\#\s*include\s*<\s*Standard/Standard_DefineHandle.hxx\s*>}
    } else {
      set pattern_definehandle {\#\s*include\s*<\s*Standard_DefineHandle.hxx\s*>}
    }
    while { [regexp -start $index -indices -lineanchor $pattern_definehandle $hxx location] } {
      set index [lindex $location 1]
      if { $fix } {
        _apply_substitution hxx $location "\#include <${nocdl_replace}Standard_Type.hxx>" index change_flag
        incr index -1
      } else {
        logwarn "Warning: $hxxfile contains obsolete forward declarations of Handle classes"
        break
      }
    }

    # remove macros IMPLEMENT_DOWNCAST() and IMPLEMENT_STANDARD_*();
    if { ! $compat } {
      set index 0
      set first_newline \n\n
      set pattern_implement {\\?\n\s*IMPLEMENT_(DOWNCAST|STANDARD_[A-Z_]+|HARRAY1|HARRAY2|HUBTREE|HEBTREE|HSEQUENCE)\s*\([A-Za-z0-9_ ,]*\)\s*;?}
      while { [regexp -start $index -indices -lineanchor $pattern_implement $hxx location] } {
        set index [lindex $location 1]
        if { $fix } {
          _apply_substitution hxx $location $first_newline index change_flag
#          set first_newline ""
          incr index -1
        } else {
          logwarn "Warning: $hxxfile contains deprecated macros IMPLEMENT_*"
          break
        }
      }
    }

    # find all uses of macro STANDARD_TYPE and method DownCast and ensure that
    # argument class is explicitly included
    set index 0
    set addtype {}
    set pattern_type1 {STANDARD_TYPE\s*\(\s*([A-Za-z0-9_]+)\s*\)}
    if {${_is_nocdl}} {
      set nocdl_replace "${package}/"
    }
    while { [regexp -start $index -indices $pattern_type1 $hxx location name] } {
      set index [lindex $location 1]
      set name [eval string range \$hxx $name]
      if { ! [regexp -lineanchor "^\\s*#\\s*include\\s*<\\s*${nocdl_replace}$name\[.\].xx\\s*>" $hxx] &&
           [lsearch -exact $addtype $name] <0 &&
           [file exists $incdir/$name.hxx] } {
        lappend addtype $name
      }
    }
    set pattern_type2 {Handle\s*\(\s*([A-Za-z0-9_]+)\s*\)\s*::\s*DownCast}
    while { [regexp -start $index -indices $pattern_type2 $hxx location name] } {
      set index [lindex $location 1]
      set name [eval string range \$hxx $name]
      if { ! [regexp -lineanchor "^\\s*#\\s*include\\s*<\\s*${nocdl_replace}$name\[.\].xx\\s*>" $hxx] &&
           [lsearch -exact $addtype $name] <0 &&
           [file exists $incdir/$name.hxx] } {
        lappend addtype $name
      }
    }
    if { [llength $addtype] > 0 } {
      if { $fix } {
        set addinc ""
        foreach type $addtype {
          if {${_is_nocdl}} {
            set nocdl_replace "[_find_package ${type}.hxx "${_src}" 1]/"
          }
          append addinc "\n#include <$nocdl_replace$type.hxx>"
        }
        if { [regexp -indices {.*\n\s*\#\s*include\s*<\s*[A-Za-z0-9_/]+[.].xx\s*>} $hxx location] } {
          set pos [lindex $location end] 
          _apply_substitution hxx [list $pos $pos] ">$addinc" index change_flag
        } else {
          logerr "Error: $hxxfile: Cannot find #include statement to add more includes..."
        }
      } else {
        logwarn "Warning: $hxxfile: The following class names are used as arguments of STANDARD_TYPE"
        logwarn "         macro, but not included directly: $addtype"
        break
      }
    }

    # apply changes to the header file
    if { $change_flag } {
      _save_text $hxxfile $hxx
      _change_format $hxxfile $nl_format
    }
  }
}

# Replaces IDs starting with Handle_ by use of macro Handle()
# and removes all forward declarations of "class Handle(...)"
proc occt_upgrade_handle {pkpath fix} {
  loginfo ">>> Upgrade Handles"

  # iterate by header files
  foreach afile [glob -nocomplain -type f -directory $pkpath *.?xx] {

    # skip gxx files, as names Handle_xxx used there are in most cases 
    # placeholders of the argument types substituted by #define
    if { [file extension $afile] == ".gxx" } {
      continue
    }

    # load HXX file
    if { [catch {set fd [open $afile rb]}] } {
      logerr "Error: cannot open $afile"
      continue
    }
    set hxx [read $fd]
    close $fd  

    set change_flag 0

    # replace all IDs with prefix Handle_ by use of Handle() macro
    set newhxx {}
    set pattern_handle {\mHandle_([A-Za-z0-9_]+)}
    foreach line [split $hxx \n] {
      # do not touch #include and #if... statements
      if { [regexp {\s*\#\s*include} $line] || [regexp {\s*\#\s*if} $line] } {
        lappend newhxx $line
        continue
      }

      # in other preprocessor statements, skip first expression to avoid
      # replacements in #define Handle_... and similar cases 
      set index 0
      if { [regexp -indices {\s*#\s*[A-Za-z]+\s+[^\s]+} $line location] } {
        set index [expr 1 + [lindex $location 1]]
      }

      # replace Handle_T by Handle(T)
      while { [regexp -start $index -indices $pattern_handle $line location class] } {
        set index [lindex $location 1]

        set class [eval string range \$line $class]
#        puts "Found: [eval string range \$hxx $location]"
        if { $fix } {
          _apply_substitution line $location "Handle($class)" index change_flag
        } else {
          logwarn "Warning: $afile refers to IDs starting with \"Handle_\" which are likely"
          logwarn "  instances of OCCT Handle classes (e.g. \"$class\"); these are to be "
          logwarn "  replaced by template opencascade::handle<> or legacy macro Handle()"
          set index -1 ;# to break outer cycle
          break
        }
      }
      lappend newhxx $line

      if { $index < 0 } { 
        set change_flag 0
        break
      }
    }
    set hxx [join $newhxx \n]

    # remove all forward declarations of Handle classes
    # remove all typedefs using Handle() macro to generate typedefed name
    # remove all #include statements for files starting with "Handle_"
    set newhxx {}
    set pattern_fwdhandle {^\s*class\s+Handle[_\(][A-Za-z0-9_]+[\)]?\s*\;\s*$}
    set pattern_tdfhandle {^\s*typedef\s+[_A-Za-z\<\>, \s]+\s+Handle\([A-Za-z0-9_]+\)\s*\;\s*$}
    set pattern_handleinc {^\s*\#\s*include\s+[\<\"]\s*Handle[\(_][A-Za-z0-9_.]+[\)]?\s*[\>\"]\s*$}
    foreach line [split $hxx \n] {
      if { [regexp $pattern_fwdhandle $line res] || 
           [regexp $pattern_tdfhandle $line res] || 
           [regexp $pattern_handleinc $line res] } {
        if { $fix } {
          set change_flag 1
          continue
        } else {
          logwarn "Warning: $hxxfile contains suspicious statement involving Handle macro or header:"
          logwarn "$res"
        }
      }
      lappend newhxx $line
    }
    set hxx [join $newhxx \n]

    # apply changes to the header file
    if { $change_flag } {
      _save_text $afile $hxx
    }
  }
}

# Replaces C-style casts of Handle object to Handle to derived type by 
# by call to DownCast() method
proc occt_upgrade_downcast {pkpath fix} {
  loginfo ">>> Upgrade C-style casts"

  # iterate by header files
  foreach afile [glob -nocomplain -type f -directory $pkpath *.?xx] {

    # load a file
    if { [catch {set fd [open $afile rb]}] } {
      logerr "Error: cannot open $afile"
      continue
    }
    set hxx [read $fd]
    close $fd  

    set change_flag 0

    # replace ((Handle(A)&)b) by Handle(A)::DownCast(b)
    set index 0
    set pattern_refcast1 {\(\(\s*Handle\s*\(\s*([A-Za-z0-9_]+)\s*\)\s*[&]\s*\)\s*([A-Za-z0-9_]+)\)}
    while { [regexp -start $index -indices -lineanchor $pattern_refcast1 $hxx location class var]} {
      set index [lindex $location 1]

      set class [eval string range \$hxx $class]
      set var   [eval string range \$hxx $var]

      if { $fix } {
        _apply_substitution hxx $location "Handle($class)::DownCast ($var)" index change_flag
      } else {
        logwarn "Warning in $afile: C-style cast: [eval string range \$hxx $location]"
      }
    }

    # replace  (Handle(A)&)b, by Handle(A)::DownCast(b),
    # replace  (Handle(A)&)b; by Handle(A)::DownCast(b);
    # replace  (Handle(A)&)b) by Handle(A)::DownCast(b))
    set index 0
    set pattern_refcast2 {\(\s*Handle\s*\(\s*([A-Za-z0-9_]+)\s*\)\s*[&]\s*\)\s*([A-Za-z0-9_]+)(\s*[,;\)])}
    while { [regexp -start $index -indices -lineanchor $pattern_refcast2 $hxx location class var end]} {
      set index [lindex $location 1]

      set class [eval string range \$hxx $class]
      set var   [eval string range \$hxx $var]
      set end   [eval string range \$hxx $end]

      if { $fix } {
        _apply_substitution hxx $location "Handle($class)::DownCast ($var)$end" index change_flag
      } else {
        logwarn "Warning in $afile: C-style cast: [eval string range \$hxx $location]"
      }
    }

    # replace (*((Handle(A)*)&b)) by Handle(A)::DownCast(b)
    set index 0
    set pattern_ptrcast1 {([^A-Za-z0-9_]\s*)\(\s*[*]\s*\(\(Handle\s*\(\s*([A-Za-z0-9_]+)\s*\)\s*[*]\s*\)\s*[&]\s*([A-Za-z0-9_]+)\s*\)\s*\)}
    while { [regexp -start $index -indices -lineanchor $pattern_ptrcast1 $hxx location start class var] } {
      set index [lindex $location 1]

      set start [eval string range \$hxx $start]
      set class [eval string range \$hxx $class]
      set var   [eval string range \$hxx $var]

      if { $fix } {
        _apply_substitution hxx $location "${start}Handle($class)::DownCast ($var)" index change_flag
      } else {
        logwarn "Warning in $afile: C-style cast: [eval string range \$hxx $location]"
      }
    }

    # replace  *((Handle(A)*)&b)  by Handle(A)::DownCast(b)
    set index 0
    set pattern_ptrcast2 {[*]\s*\(\(Handle\s*\(\s*([A-Za-z0-9_]+)\s*\)\s*[*]\s*\)\s*[&]\s*([A-Za-z0-9_]+)\s*\)}
    while { [regexp -start $index -indices -lineanchor $pattern_ptrcast2 $hxx location class var] } {
      set index [lindex $location 1]

      set class [eval string range \$hxx $class]
      set var   [eval string range \$hxx $var]

      if { $fix } {
        _apply_substitution hxx $location "Handle($class)::DownCast ($var)" index change_flag
      } else {
        logwarn "Warning in $afile: C-style cast: [eval string range \$hxx $location]"
      }
    }

    # replace (*(Handle(A)*)&b) by Handle(A)::DownCast(b)
    set index 0
    set pattern_ptrcast3 {([^A-Za-z0-9_]\s*)\(\s*[*]\s*\(Handle\s*\(\s*([A-Za-z0-9_]+)\s*\)\s*[*]\s*\)\s*[&]\s*([A-Za-z0-9_]+)\s*\)}
    while { [regexp -start $index -indices -lineanchor $pattern_ptrcast3 $hxx location start class var] } {
      set index [lindex $location 1]

      set start [eval string range \$hxx $start]
      set class [eval string range \$hxx $class]
      set var   [eval string range \$hxx $var]

      if { $fix } {
        _apply_substitution hxx $location "${start}Handle($class)::DownCast ($var)" index change_flag
      } else {
        logwarn "Warning in $afile: C-style cast: [eval string range \$hxx $location]"
      }
    }

    # replace  *(Handle(A)*)&b,  by Handle(A)::DownCast(b),
    # replace  *(Handle(A)*)&b;  by Handle(A)::DownCast(b);
    # replace  *(Handle(A)*)&b)  by Handle(A)::DownCast(b))
    set index 0
    set pattern_ptrcast4 {[*]\s*\(Handle\s*\(\s*([A-Za-z0-9_]+)\s*\)\s*[*]\s*\)\s*[&]\s*([A-Za-z0-9_]+)(\s*[,;\)])}
    while { [regexp -start $index -indices -lineanchor $pattern_ptrcast4 $hxx location class var end] } {
      set index [lindex $location 1]

      set class [eval string range \$hxx $class]
      set var   [eval string range \$hxx $var]
      set end   [eval string range \$hxx $end]

      if { $fix } {
        _apply_substitution hxx $location "Handle($class)::DownCast ($var)$end" index change_flag
      } else {
        logwarn "Warning in $afile: C-style cast: [eval string range \$hxx $location]"
      }
    }

    # just warn if some casts to & are still there
    set index 0
    set pattern_refcast0 {\(\s*Handle\s*\(\s*([A-Za-z0-9_]+)\s*\)\s*[&]\s*\)\s*([A-Za-z0-9_]+)}
    while { [regexp -start $index -indices -lineanchor $pattern_refcast0 $hxx location class var] } {
      set index [lindex $location 1]

      logwarn "Warning in $afile: C-style cast: [eval string range \$hxx $location]"
    }

    # replace const Handle(A)& a = Handle(B)::DownCast (b); by 
    #               Handle(A)  a ( Handle(B)::DownCast (b) );
    set index 0
    set pattern_refvar {\mconst\s+Handle\s*\(\s*([A-Za-z0-9_]+)\s*\)\s*[&]\s*([A-Za-z0-9_]+)\s*=\s*(Handle\s*\(\s*[A-Za-z0-9_]+\s*\)\s*::\s*DownCast\s*\([^;]+);}
    while { [regexp -start $index -indices -lineanchor $pattern_refvar $hxx location class var hexpr] } {
      set index [lindex $location 1]

      set class [eval string range \$hxx $class]
      set var   [eval string range \$hxx $var]
      set hexpr [eval string range \$hxx $hexpr]

      if { $fix } {
        _apply_substitution hxx $location "Handle($class) $var ($hexpr);" index change_flag
      } else {
        logwarn "Warning in $afile: C-style cast: [eval string range \$hxx $location]"
      }
    }

    # apply changes to the header file
    if { $change_flag } {
      _save_text $afile $hxx
    }
  }
}

# Remove keyword 'mutable' in CDL declarations except in declaration of first 
# argument of class methods, "me: mutable". In other cases (return statements,
# declaration of method arguments) this keyword is redundant and causes 
# problems if corresponding type is not a CDL class.
proc occt_upgrade_mutable {pkpath fix} {
  loginfo ">>> Upgrade mutable"
  
  # iterate by CDL files
  foreach afile [glob -nocomplain -type f -directory $pkpath *.cdl] {

    # load CDL file
    if { [catch {set fd [open $afile rb]}] } {
      logerr "Error: cannot open $afile"
      continue
    }
    set cdl [read $fd]
    close $fd  

    set change_flag 0

    # remove "mutable" from "returns" statement
    set index 0
    set pattern_returns {\mreturns\s+mutable}
    while { [regexp -start $index -indices -lineanchor $pattern_returns $cdl location] } {
      set index [lindex $location 1]

      if { $fix } {
        _apply_substitution cdl $location "returns" index change_flag
      } else {
        logwarn "Warning: found \"returns mutable\""
        break
      }
    }

    # remove "mutable" from method argument declaration, except for "me"
    set index 0
    set pattern_arg {\m([A-Za-z0-9_]+)\s*:(\s*in)?(\s*out)?(\s*mutable)\s+}
    while { [regexp -start $index -indices -lineanchor $pattern_arg $cdl \
                    location name in out mutable] } {
      set index [lindex $location 1]

      # keep only declarations of the kind "me: mutable"
      if { [eval string range \$cdl $name] == "me" } {
        continue
      }
      if { $fix } {
        _apply_substitution cdl $mutable "" index change_flag
      } else {
        logwarn "Warning: found \"[eval string range \$cdl $location]\""
        break
      }
    }

    # apply changes to the header file
    if { $change_flag } {
      _save_text $afile $cdl
    }
  }
}

# auxiliary: generate header file with specified name and content
proc _make_hxx {path name content copyright} {
  # generate header file for typedef
  if { [catch {set fdhxx [open $path/${name}.hxx wb]}] } {
    logerr "Error: cannot open file $path/${name}.hxx for writing"
    return 0
  }

  puts $fdhxx $copyright
  puts $fdhxx "\n#ifndef ${name}_HeaderFile"
  puts $fdhxx   "#define ${name}_HeaderFile"
  puts $fdhxx "\n$content"
  puts $fdhxx "\n#endif"
  close $fdhxx 

  # add to git if we are working in git environment
  catch {exec git add $path/${name}.hxx}

  return 1
}

# auxiliary: check if class is to be operated by Handle
# (by the moment this is checked by presence of DEFINE_STANDARD_RTTI macro in hxx file)
proc _is_transient {incdir_list class} {
  # Standard_Transient and Standard_Persistent are known root classes
  if { $class == "Standard_Transient" || $class == "Standard_Persistent" } {
    return 1
  }

  # for other classes check header files
  foreach incdir $incdir_list {
    if { ! [file exists $incdir/${class}.hxx] } {
      continue
    }

    if { [catch {set fd [open $incdir/${class}.hxx]}] } {
      logerr "Error: cannot open file $incdir/${class}.hxx"
      continue
    }

    set hxx [read $fd]
    close $fd

    return [regexp "DEFINE_STANDARD_RTTI\s*\\\(\s*$class\[,\\\)\]" $hxx]
  }

  logwarn "Warning: cannot find ${class}.hxx, assuming $class is not transient"
  return 0
}

# auxiliary: extracts first block of one-line comments in the text
# (until first empty line), optionally replacing comment marker
proc _extract_top_comment {text comment_start comment_new} {
  set block ""
  foreach line [split $text "\n"] {
    if { ! [regexp "^${comment_start}(.*)" $line dummy str] } {
      break
    }
    lappend block "${comment_new}$str"
  }
  return [join $block "\n"]
}

# auxiliary: modifies variable text_var replacing part defined by two indices
# given in location by string str, and updates index_var variable to point to
# the end of the replaced string. Variable flag_var is set to 1.
proc _apply_substitution {text_var location str index_var flag_var} {
  upvar $text_var text
  upvar $index_var index
  upvar $flag_var flag

  set flag 1  
  set start [lindex $location 0]
  set end   [lindex $location 1]
  set text  [string replace "$text" $start $end "$str"]
  set index [expr $start + [string length $str]]
}

# Save file
proc _save_text {filename text} {
  if { [catch {set fd [open $filename wb]}] } {
    logerr "Error: cannot open file $filename for writing"
    return 0
  } else {
    catch {puts -nonewline $fd "$text"}
    close $fd
    loginfo "File $filename modified"
    return 1
  }
}

###
# main function to replace includes of ixx and jxx files by their content.
# accepts path to location of source tree to be upgraded.
###
proc replace_xx { path srcpath incpath } {
  loginfo "Replace includes of ixx and jxx files by their content..."
  check_path "${srcpath}"
  check_path "${incpath}"
  set all_files [_find_files "$srcpath" "*"]
  foreach filename $all_files {
    if { ![regexp {\.[ij]xx$} $filename] } {
      set fileContent [_open_file $filename]
      set wasChanged false
      set newContent [_replace_includes $fileContent $incpath $srcpath]
      if { $wasChanged } {
        _save_file $filename $newContent
      }
    }
  }
}
###
# main function to check includes if they are already included
# accepts path to location of source tree to be upgraded
# if "_fix" is equal to 1, problems will be fixed.
###
proc check_duplicates { _inc _src {_fix 0} } {
  # check args
  check_path "${_src}"
  check_path "${_inc}"
  if { $_fix } {
    loginfo "All problems will be fixed"
  }
  set src_files [_find_files ${_src} "*"]
  set errors {}
  foreach file $src_files {
    if {[regexp {\..xx} $file]} {
      set inc {}
      set warns {}
      set init_file [lindex [split $file "/"] end]
      _check_tree $file 0 $_inc $_src
      loginfo $file
      _print_list $warns
    }
  }
  loginfo ""
  set errors [lsort -dictionary -unique $errors]
  _print_list $errors
}
###
# Main function to check the header files from directory ${srcpath)
# if "_fix" is equal to 1, problems will be fixed
# if "_show_log" is equal to 1, log will be shown
###
proc check_headers { srcpath {_fix 0} {_show_log 0} } {
  # check args
  check_path "${srcpath}"
  if { $_fix } {
    loginfo "All problems will be fixed"
  } else {
    loginfo "Problems will be shown but not fixed"
  }
  if { $_show_log } {
    loginfo "Log is ON"
  } else {
    loginfo "Log is OFF"
  }
  # get all files from src folder
  set src_files [_find_files ${srcpath} "*"]
  foreach file $src_files {
    # if hxx file
    if { [regexp {/([^/]*)\.hxx$} $file dummy filename] } {
      set fileContent [_open_file $file]
      # check if the first line after comments has ifndef statement
      set _has_directive true
      set _isMulti false
      set warnings {}
      set index -1
      foreach line $fileContent {
        incr index 1
        set _cmnt ""
        set line [_check_line $line]
        # skipping empty line and comments
        if { ![regexp {^[\s]*$} $line] } {
          # line has "ifndef"
          if { [regexp {^[\s]*\#[\s]*ifndef ([a-zA-Z0-9_]*)} $line ifndef_line ifndef] } {
            set define_index [_has_define $ifndef $fileContent $index]
            # ifndef covers all content of file and has define directive
            if {[_is_full_directive $fileContent $index] && $define_index} {
              set ifndef_index $index
              set define_line [lindex $fileContent $define_index]
              # ifndef has wrong filename
              if { ![regexp "\\s_?${filename}_HeaderFile" $ifndef_line]} {
                logerr "Error : file \"${file}\""
                if { ${_fix} } {
                  set fileContent [lreplace $fileContent $ifndef_index $ifndef_index "\#ifndef ${filename}_HeaderFile"]
                  set fileContent [lreplace $fileContent $define_index $define_index "\#define ${filename}_HeaderFile"]
                  if { $_show_log } {
                    loginfo "\tLine \#${ifndef_index} was changed:"
                    loginfo "\t\tOld line: \"${ifndef_line}\""
                    loginfo "\t\tNew line: \"[lindex $fileContent $ifndef_index]\""
                    loginfo "\tLine \#${define_index} was changed:"
                    loginfo "\t\tOld line: \"${define_line}\""
                    loginfo "\t\tNew line: \"[lindex $fileContent $define_index]\""
                    loginfo ""
                  }
                  _save_file $file $fileContent
                }
              }
              if {[llength $warnings]} {
                logwarn "Warning : $file"
                logwarn "\tLines are placed before \"${ifndef_line}\":"
                foreach warn $warnings {
                  logwarn "\t\t\"$warn\""
                }
              }
              break
            } else {
              # current ifndef does not correspond to the conditions, try to search another ifndef
              continue
            }
          } else {
            # skipping directive while searching ifndef
            if {[regexp {^[\s]*#} $line]} {
              lappend warnings $line
              continue
            } else {
              # file does not have normal ifndef directives
              set _has_directive false
              break
            }
          }
        }
      }
      # create ifndef directives
      if { !$_has_directive } {
        logerr "Error : file \"${file}\" have no directives for header file"
        if {$_fix} {
          set commentsLength [llength [_get_comment $fileContent]]
          set newContent [lrange $fileContent 0 [expr $commentsLength - 1]]
          lappend newContent ""
          lappend newContent "#ifndef ${filename}_HeaderFile"
          lappend newContent "#define ${filename}_HeaderFile"
          set newContent [concat $newContent [lrange $fileContent $commentsLength end]]
          lappend newContent "#endif"
          if {$_show_log} {
            loginfo "\tDirectives for header file were added"
            loginfo ""
          }
          _save_file $file $newContent
        }
      }
    }
  }
}
# auxiliary: find includes of ixx and jxx files and replace by their content
proc _replace_includes { file_content {_inc ""} {_src ""}} {
  upvar wasChanged wasChanged
  upvar path path

  if {"${_inc}" == ""} { set _inc ${path}/inc }
  if {"${_src}" == ""} { set _src ${path}/src }

  set _isMulti false
  set index 0
  foreach line $file_content {
    set _cmnt ""
    set line [_check_line $line]
    if { [ regexp {^[\s]*\#[\s]*include[\"<\s]+([A-Za-z0-9_]+\.[ij]xx)} $line dummy inc_name] } {
      set wasChanged true
      # get full path of included file
      set path_to_include [_get_path $inc_name $path $_inc $_src]
      if {$path_to_include == ""} {
        logwarn "\tWarning: cannot find \"$inc_name\""
        return [_replace_includes [concat [lrange $file_content 0 [expr $index-1]] [lrange $file_content [expr $index+1] end]] $_inc $_src]
      }
      # open file to include
      set includes [_open_file $path_to_include]
      # check upper strings
      set Comments {}
      set up_index [_go_through $file_content [expr $index-1] [expr [llength [_get_comment $file_content]]-1]]
      set Comments [lreverse $Comments]
      set resContent {}
      set resContent [concat $resContent [lrange $file_content 0 $up_index] {""} $Comments]
      # check lower strings
      set Comments {}
      set down_index [_go_through $file_content [expr $index+1] [expr [llength $file_content]]]
      set includes [_prepare_includes $includes]
      set resContent [concat $resContent $includes $Comments [lrange $file_content $down_index end]]
      return [_replace_includes $resContent $_inc $_src]
    }
    incr index
  }
  return $file_content
}

# auxiliary: check strings from "begin" to "end" if they have "#include ..."
proc _go_through { file_content begin end } {
  upvar includes includes
  upvar Comments Comments
  set incr_sign "+"
  if { $end < $begin } {
    set incr_sign "-"
  }
  set index ${begin}
  set _isMulti false
  for {set i ${begin}} {$i != ${end}} {incr i ${incr_sign}1} {
    set curLine [lindex $file_content $i]
    set _cmnt ""
    set curLine [_check_line $curLine]
    # looking for line with includes
    if { [regexp {\#[\s]*include.*} $curLine]} {
      if {[regexp {include[\"<\s]+windows.h[\">\s]*} $curLine]} { break }
      lappend includes $curLine
      if {![regexp {^[\s]*$} $_cmnt]} {
        lappend Comments $_cmnt
      }
    } elseif {[regexp {^[\s]*$} $curLine]} {
      if {![regexp {^[\s]*$} $_cmnt]} {
        lappend Comments $curLine$_cmnt
      }
    } else {
      break
    }
    set index [expr ${i}${incr_sign}1]
  }
  return $index
}
# auxiliary: to get the list of files with specific extension
# basedir - the directory to start looking in
# pattern - A pattern (extension), that the files must match
proc _find_files { basedir pattern {recursive 1} } {
  # Fix the directory name (to native format)
  set basedir [string trimright [file join [file normalize $basedir] { }]]
  set fileList {}
  # Look in the current directory
  foreach fileName [glob -nocomplain -type {f r} -path $basedir $pattern] {
    lappend fileList $fileName
  }
  # Look for any sub direcories in the current directory
  if { $recursive } {
    foreach dirName [glob -nocomplain -type {d  r} -path $basedir *] {
      # Recusively call the routine on the sub directory
      set subDirList [_find_files $dirName $pattern]
      if { [llength $subDirList] > 0 } {
        foreach subDirFile $subDirList {
          lappend fileList $subDirFile
        }
      }
    }
  }
  return $fileList
}

# auxiliary: split lines to includes and macros, sorts includes and removes duplicates from them
proc _prepare_includes { list } {
  set includes_std {}
  set includes_occ {}
  set macros {}
  set _isMulti false
  foreach line $list {
    set _cmnt ""
    set line [_check_line $line]
    if {![regexp "\#ifndef" $line] && ![regexp "\#endif" $line]} {
      if {[regexp {\#[\s]*include} $line]} {
        if { ![regexp {([\s]*)\#[\s]*include[\s]*([\"<]?)[\s]*([A-Za-z0-9_\./]+)[\s]*([\">]?)} $line dummy indent open_bkt name close_bkt] } {
          error "Error : line \"${line}\" has wrong format"
        }
        set fline "${indent}\#include ${open_bkt}${name}${close_bkt}"
        if { ![regexp {\..xx} $name] } {
          lappend includes_std $fline
        } else {
          lappend includes_occ $fline
        }
      } elseif {![regexp {^[\s\n]*$} $line]} {
        lappend macros $line
      }
    }
  }
  return [concat {""} [lsort -dictionary -unique $includes_occ] {""} [lsort -dictionary -unique $includes_std]]
}

# auxiliary: opens file and returns its content
proc _open_file { filename {_ending "\n"}} {
  if { [catch {set fd [open $filename rb]}] } {
    logerr "Error: cannot open \"${filename}\""
  }
  set fileContent [read $fd]
  close $fd
  return [split $fileContent "${_ending}"]
}

# auxiliary: saves content of "list" to "filename" path
proc _save_file { filename list_to_save {_ending "\n"}} {
  if { [catch {set file [open ${filename} wb]}] } {
    logerr "Error: cannot open file \"${filename}\" for writing"
  }
  set index 0
  foreach line $list_to_save {
    if { $index == [expr [llength $list_to_save]-1] && $line == ""} {
      puts -nonewline $file $line
    } else {
      puts -nonewline $file "$line${_ending}"
    }
    incr index
  }
  close $file
}

# auxiliary: return top comment
proc _get_comment { list } {
  set aComment {}
  foreach line $list {
    if {![regexp {//.*} $line]} { break }
    lappend aComment $line
  }
  return $aComment
}

# auxiliary: check if current ifndef directive cover all content of file
proc _is_full_directive { list start } {
  set nb 0
  for {set i $start} {$i < [llength $list]} {incr i} {
    set line [lindex $list $i]
    if {[regexp {^\s*\#\s*if} $line]} { incr nb 1 }
    if {[regexp {^\s*\#\s*endif} $line]} { incr nb -1 }
    if {$nb == 0} {
      foreach curLine [lrange $list [expr $i + 1] end] {
        if {![regexp {^[\s\n]*$} $curLine] && ![regexp {^\s*\#} $curLine]} {
          return false
        }
      }
      break
    }
  }
  return true
}
# auxiliary: check if current ifndef directive has define directive
proc _has_define { ifndef list start } {
  for {set i [expr $start+1]} {$i < [llength $list]} {incr i} {
    set line [lindex $list $i]
    if { ![regexp {^[\s]*$} $line] } {
      if { [regexp "^\\s*\#\\s*define $ifndef" $line] } {
        return $i
      }
      return false
    }
  }
  return false
}
# auxiliary: print all items from the list
proc _print_list { list } {
  if {[llength $list]} {
    foreach item $list {
      puts $item
    }
  }
}
# auxiliary: get full path to file with name "filename"
# filename - file name to search
proc _get_path { filename path {_inc ""} {_src ""}} {
  if {"${_inc}" == ""} { set _inc ${path}/inc }
  if {"${_src}" == ""} { set _src ${path}/src }
  set name [lindex [split $filename "."] 0]
  regexp {^[Hh]andle_(.*)} $name dummy name
  set dir [lindex [split $name "_"] 0]
  set path_arr {}
  lappend path_arr ${_src}/${dir}/${filename}
  lappend path_arr ${_inc}/${filename}
  lappend path_arr ${path}/drv/${dir}/${filename}
  foreach res $path_arr {
    if {[file exists $res]} {
      return $res
    }
  }
  return ""
}
# auxiliary: calculate number of duplicates in the list
proc _count { item list } {
  set nb 0
  foreach i $list {
    if { $item == $i } {
      incr nb
    }
  }
  return $nb
}
# auxiliary: recursively check all files from "file" and comment duplicated header files
proc _check_tree { file nb _inc _src} {
  upvar inc inc
  upvar errors errors
  upvar warns warns
  upvar _fix _fix
  upvar path path
  upvar init_file init_file
  set content [_open_file $file]
  set should_save false
  set _isMulti false
  set index -1
  set defines {}
  set skip false
  foreach line $content {
    incr index 1
    set _cmnt ""
    set line [_check_line $line]
    if { [regexp {^[\s]*\#[\s]*if} $line] } {
      if { [regexp "_HeaderFile" $line] } {
        lappend defines "header"
      } else {
        lappend defines "skip"
        set skip true
      }
    } elseif { [regexp {^[\s]*\#[\s]*endif} $line] } {
      set defines [lreplace $defines end end]
      if { [_count "skip" $defines] == 0 } {
        set skip false
      }
    }
    if { $skip } { continue }
    if { [regexp {^[\s]*\#[\s]*include[\"<\s]+([A-Za-z0-9_\./]+)[\">\s]*} $line dummy name]} {
      set nextfile [_get_path $name $path $_inc $_src]
      lappend inc $name
      if { $nextfile != "" && $name != $init_file && [regexp ".*.hxx$" $name]} {
        if { $file != $nextfile } {
          if { [_count $name $inc] == 1 } {
            _check_tree $nextfile [expr $nb+1] $_inc $_src
          } else {
            if { $nb == 0 } {
              set should_save true
              lappend warns "\tWarning : file \"$name\" was already included"
              if {$_fix} {
                set content [lreplace $content $index $index "//[lindex ${content} ${index}]"]
              }
            }
          }
        } else {
          lappend errors "Error : file \"$file\" includes himself"
        }
      }
    }
  }
  if { $should_save && $_fix} {
    _save_file $file $content
  }
  return
}
# auxiliary: parse the string to comment and not comment parts
# variable "_cmnt" should be created before using the operation, it will save comment part of line
# variable "_isMulti" should be created before the loop, equal to "false" if first line in the loop is not multi-comment line
proc _check_line { line } {
  upvar _isMulti _isMulti
  upvar _cmnt _cmnt
  set string_length [string length $line]
  set c_b $string_length
  set mc_b $string_length
  set mc_e $string_length
  regexp -indices {//} $line c_b
  regexp -indices {/\*} $line mc_b
  regexp -indices {\*/} $line mc_e
  if {!${_isMulti}} {
    if {[lindex $c_b 0] < [lindex $mc_b 0] && [lindex $c_b 0] < [lindex $mc_e 0]} {
      set notComment_c [string range $line 0 [expr [lindex $c_b 0]-1]]
      set Comment_c [string range $line [lindex $c_b 0] end]
      set _cmnt $_cmnt$Comment_c
      return $notComment_c
    } elseif {[lindex $mc_b 0] < [lindex $c_b 0] && [lindex $mc_b 0] < [lindex $mc_e 0]} {
      set _isMulti true
      set _cmnt "${_cmnt}/*"
      set notComment_mc [string range $line 0 [expr [lindex $mc_b 0]-1]]
      set Comment_mc [string range $line [expr [lindex $mc_b 1]+1] end]
      return [_check_line "${notComment_mc}[_check_line ${Comment_mc}]"]
    } elseif {[lindex $mc_e 0] < [lindex $c_b 0] && [lindex $mc_e 0] < [lindex $mc_b 0]} {
      set notComment_mc [string range $line [expr [lindex $mc_e 1]+1] end]
      set Comment_mc [string range $line 0 [expr [lindex $mc_e 0]-1]]
      set _cmnt "${_cmnt}${Comment_mc}*/"
      set chk [_check_line ${notComment_mc}]
      set _isMulti true
      return $chk
    }
  } else {
    if {[lindex $mc_e 0] < [lindex $mc_b 0]} {
      set _isMulti false
      set Comment_mc [string range $line 0 [lindex $mc_e 1]]
      set notComment_mc [string range $line [expr [lindex $mc_e 1]+1] end]
      set _cmnt $_cmnt$Comment_mc
      return [_check_line $notComment_mc]
    } elseif {[lindex $mc_b 0] < [lindex $mc_e 0] } {
      set notComment_mc [string range $line 0 [expr [lindex $mc_b 0]-1]]
      set Comment_mc [string range $line [expr [lindex $mc_b 1]+1] end]
      set _cmnt "${_cmnt}/*"
      set chk [_check_line "${notComment_mc}[_check_line ${Comment_mc}]"]
      set _isMulti false
      return $chk
    } else {
      set _cmnt $_cmnt$line
      return ""
    }
  }
  return $line
}

###
# function to put generated files from drv directory to src directory
###
proc restore_gxx { path {_src ""}} {
  loginfo "Copying of cxx files from drv to src..."

  if {"${_src}" == ""} { set _src ${path}/src }

  check_path "${_src}"
  check_path "${path}/drv"
  set nb_exception 0
  set nb_inst 0
  foreach file [_find_files "$path/drv" "*.c*"] {
    set name [file tail $file]
    set pack [file tail [file dirname $file]]
    set file_src_path "$_src/$pack/$name"
    if {![file isfile $file_src_path] } {
      set is_exception false
      set is_schema false
      if {![regexp {\_(.+)\_0.cxx} $name dummy inst]} {
        set is_schema true
      }
      set pack_cdl_path "$_src/$pack/$pack.cdl"
      if {[file isfile $pack_cdl_path] && !$is_schema} {
        set pack_cdl [_open_file $pack_cdl_path]
        foreach line $pack_cdl {
          if {[regexp "exception $inst" $line] } {
            set is_exception true
            break
          }
        }
      }
      if {!$is_exception || $is_schema} {
        file copy $file $file_src_path
        _change_format $file_src_path unix
        incr nb_inst
        catch {exec git add $file_src_path}
      } else {
        loginfo "\tskip (exc) $file"
        incr nb_exception
      }
    }
  }
  loginfo "\tNumber of copied files (inst): $nb_inst"
  loginfo "\tNumber of skipped files (exceptions): $nb_exception"
}

###
# function to put generated files from inc directory to src directory
###
proc restore_hxx { path {_inc ""} {_src ""}} {
  loginfo "Copying of hxx files from inc to src..."

  if {"${_inc}" == ""} { set _inc ${path}/inc }
  if {"${_src}" == ""} { set _src ${path}/src }

  check_path "${_inc}"
  check_path "${_src}"

  set nb_inc 0
  foreach file [_find_files "$_inc" "*.h*"] {
    set name [file tail $file]
    set pack [_find_package $name $_src]
    if {$pack == ""} { continue }
    set file_src_path "$_src/$pack/$name"
    if {![file isfile $file_src_path] } {
      file copy $file $file_src_path
      _change_format $file_src_path unix
      incr nb_inc
      catch {exec git add $file_src_path}
    }
  }
  loginfo "\tNumber of copied files (inc): $nb_inc"
}
# Updating of "UDLIST_path" file...
proc update_UDLIST {path} {
  set UDLIST_path $path/adm/UDLIST
  loginfo "Updating of \"$UDLIST_path\" file..."
  set UDLIST_path "$path/adm/UDLIST"
  if {![file exists $UDLIST_path]} {
    error "Error : file \"$UDLIST_path\" does not exist"
  }
  set UDLIST [_open_file $UDLIST_path]
  set ud_i 0
  foreach line $UDLIST {
    if {[regexp {^[sp] (.*)} $line dummy name]} {
      set UDLIST [lreplace $UDLIST $ud_i $ud_i "n $name"]
    }
    incr ud_i
  }
  _save_file $UDLIST_path $UDLIST
}

# Remove files by pattern from directory
proc remove_files { _src pattern } {
  loginfo "Removing '${pattern}' files from directory '${_src}'..."
  foreach file [_find_files "${_src}" "${pattern}"] {
    catch {exec git rm --cached $file}
    catch {file delete $file}
    set FILES_path "$_src/[file tail [file dirname $file]]/FILES"
    if {[file isfile $FILES_path]} {
      set FILES [_open_file $FILES_path]
      set name [file tail $file]
      if {[lsearch -regexp $FILES "\s*$name\s*"] != -1} {
        set FILES [lsearch -inline -all -not -exact $FILES ""]
        set FILES [lsearch -inline -all -not -regexp $FILES "\s*$name\s*"]
        _save_file $FILES_path $FILES
      }
    }
  }
}

# check path directory
proc check_path { path } {
  if { ![file isdirectory ${path}] } {
    logerr "Error: directory '${path}' does not exist!"
  }
}

# get value by key from 'args'
proc _get_args_for_option {key args_list_name {def_value "null"}} {
  upvar ${args_list_name} args
  set index [lsearch ${args} "${key}"]
  if {${def_value} != "null"} {
    if {${index} != -1} {
      set result [lindex ${args} [expr ${index}+1]]
      if {[regexp {^-} ${result}]} {
        logerr "Error: wrong value '${result}' for key '${key}'"
      }
      set args [lreplace ${args} ${index} [expr ${index}+1]]
      return ${result}
    }
    return ${def_value}
  } else {
    return [expr ${index} != -1]
  }
}

proc update_FILES { _src } {
  loginfo "Updating FILES file in '${_src}' directory..."
  check_path "$_src"
  foreach dir [glob -tails -directory "$_src" -types d *] {
    set FILES {}
    set FILES_path "$_src/$dir/FILES"
    set newFILES {}
    if {[file exists $FILES_path]} {
      set FILES [_open_file $FILES_path]
      set FILES [lsearch -inline -all -not -exact $FILES ""]
      foreach f $FILES {
        set f [lindex [split $f] 0]
        if {[lsearch -nocase $newFILES $f] == -1} {
          lappend newFILES $f
        }
      }
    }
    set files1 [glob -nocomplain -tails -directory "$_src/$dir" -types f "*.*xx"]
    set files2 [glob -nocomplain -tails -directory "$_src/$dir" -types f "*.h"]
    set files3 [glob -nocomplain -tails -directory "$_src/$dir" -types f "*.c"]
    set all_files [concat $files1 $files2 $files3]
    foreach f $all_files {
      if {[lsearch -nocase $newFILES $f] == -1} {
        lappend newFILES $f
      }
    }
    _save_file $FILES_path [lsort -dictionary -unique $newFILES]
    catch {exec git add $FILES_path}
  }
}

# Update includes in files from src directory
proc _update_includes { _src {OCC_path ""}} {
  loginfo "Updating includes in files from directory '${_src}'..."
  check_path "${_src}"
  foreach file [_find_files "$_src" "*"] {
    set filelist [_open_file $file]
    set index -1
    set wasChanged false
    set _isMulti false
    foreach line $filelist {
      incr index
      set _cmnt ""
      set line [_check_line $line]
      if {[regexp -indices {\#.+[\"<]+([A-Za-z0-9_/\.]+)[\">]*} $line dummy indexs]} {
        set first [lindex $indexs 0]
        set last [lindex $indexs 1]
        set name [string range $line $first $last]
        set pack ""
        if {[file isfile "$_src/$name"]} { continue }
        if {$OCC_path != ""} {
          if {[file isfile "$OCC_path/src/$name"]} { continue }
        }
        set pack [_find_package $name "$_src" true]
        if {$pack == "" && $OCC_path != "" } {
          set pack [_find_package $name "$OCC_path/src"]
        }
        if {$pack != ""} {
          set wasChanged true
          set newline [string replace $line $first $last "$pack/$name"]
          set filelist [lreplace $filelist $index $index $newline]
        }
      }
    }
    if {$wasChanged} {
      _save_file $file $filelist
    }
  }
}

# Update wrong forward declarations of NCollection typedefs to includes
proc _update_forward_declarations {_src tcolfile} {
  loginfo "Updating forward declarations in files from directory '${_src}'..."
  check_path "${_src}"
  if {[file exists $tcolfile]} {
    set tcollist [_open_file ${tcolfile}]
  } else {
    logerr "Error: file '${tcolfile}' does not exists"
    logerr "       abort proc _update_forward_declarations"
    return
  }
  foreach file [_find_files "$_src" "*"] {
    set filelist [_open_file $file]
    set index -1
    set wasChanged false
    set _isMulti false
    foreach line $filelist {
      incr index
      set _cmnt ""
      set line [_check_line $line]
      if {[regexp {^ *class *([A-Za-z0-9_/\.]+) *;} $line dummy name]} {
        if {[lsearch $tcollist $name] != -1} {
          set wasChanged true
          set newline "\#include <$name.hxx>"
          loginfo "file: '$file', line: [expr $index+1]"
          loginfo "\tFound:\t\t'$line'"
          loginfo "\tReplaced to:\t'$newline'"
          set filelist [lreplace $filelist $index $index $newline]
        }
      }
    }
    if {$wasChanged} {
      _save_file $file $filelist
    }
  }
}

# Update includes for transient classes
proc _update_transient_includes {_src tcolfile} {
  loginfo "Updating includes for transient classes in files from directory '${_src}'..."
  check_path "${_src}"
  if {[file exists $tcolfile]} {
    set tcollist [_open_file ${tcolfile}]
  } else {
    logerr "Error: file '${tcolfile}' does not exists"
    logerr "       abort proc _update_transient_includes"
    return
  }
  foreach file [_find_files "$_src" "*"] {
    set filelist [_open_file $file]
    set index -1
    set wasChanged false
    set _isMulti false
    foreach line $filelist {
      incr index
      set _cmnt ""
      set line [_check_line $line]
      if {[regexp {\#.+[\"<]+Handle_([A-Za-z0-9_/]+).hxx[\">]*} $line dummy name]} {
        if {[lsearch $tcollist $name] != -1} {
          set wasChanged true
          set newline "\#include <${name}.hxx>"
          loginfo "file: '$file', line: [expr $index+1]"
          loginfo "\tFound:\t\t'$line'"
          loginfo "\tReplaced to:\t'$newline'"
          set filelist [lreplace $filelist $index $index $newline]
        }
      }
    }
    if {$wasChanged} {
      _save_file $file $filelist
    }
  }
}

# auxiliary: return package of the file "name"
# "error"   - file has several locations in src dir
# "warning" - file was not found in src dir
proc _find_package { name _src {isExist false}} {
  if {![regexp {\.} $name]} {
    return ""
  }
  set loc {}
  set pack $name
  regexp {^[Hh]andle_(.*)} $pack dummy pack
  set pack [lindex [split $pack "_."] 0]
  if {[file isfile "$_src/$pack/$name"] || (!$isExist && [file isdirectory "$_src/$pack"])} {
    return $pack
  }
  foreach dir [glob -tails -directory "$_src" -types d *] {
    if {[file isfile "$_src/$dir/$name"]} {
      lappend loc $dir
    }
  }
  if {[llength $loc] == 1} {
    return [lindex $loc 0]
  } else {
    if { [llength $loc] } {
      logerr "\tError : file \"$name\" located in:"
      foreach loc $loc {
        logerr "\t        - $loc/$name"
      }
    }
    if {[regexp {(.+\.)([^\.]+)} $name dummy name_no_ext ext] && !$isExist} {
      set newExt ""
      switch $ext {
        "h"       {set newExt "c"}
        "c"       {set newExt "h"}
        "hxx"     {set newExt "cxx"}
        "cxx"     {set newExt "hxx"}
        default {return ""}
      }
      foreach dir [glob -tails -directory "$_src" -types d *] {
        set files [glob -nocomplain -tails -directory "$_src/$dir" -types f "*.$newExt"]
        foreach file $files {
          if {[regexp "$name_no_ext$newExt" $file]} {
            return $dir
          }
        }
      }
    }
#    puts "Warning : source package of \"$name\" file was not found"
    return ""
  }
}

# Convert pre-processed WOK workbench to non-CDL variant
proc occt_upgrade_nocdl { path args } {
  # parse arguments to get inc and src directories
  set _inc     [_get_args_for_option "-incdir" args "${path}/inc"]
  set _src     [_get_args_for_option "-srcdir" args "${path}/src"]
  set OCC_path [_get_args_for_option "-casroot" args ""]

  if {${OCC_path} != ""} { check_path ${OCC_path} }
  check_path ${_inc}
  check_path ${_src}

  # copy .c* files from drv to src
  restore_gxx $path $_src
  # copy .h* files from inc to src
  restore_hxx $path $_inc $_src
  # update copyrights
  update_copyrights $_src
  # update FILES for each package in src
  update_FILES $_src
  # replace ixx and jxx includes (mostly in files moved from drv)
  replace_xx $path $_src $_inc
  # update includes in files "#include <gp.hxx>" -> "#include <gp/gp.hxx>"
  # _update_includes $_src $OCC_path
  # run occt_upgrade_rtti for files moved from drv
  # occt_upgrade $path -rtti_nocdl -incdir $_inc -srcdir $_src
  # removes all cdl files
  remove_files $_src "*.cdl"
  # removes all edl files
  remove_files $_src "*.edl"
  # update UDLIST file, all changed packages will be replaced to nocdlpack
  update_UDLIST $path
  # remove wrong macros STANDARD_TYPE() for files moved from drv
  _remove_standard_type $_src
}

# Tool to convert line breaks in a .hxx(.h) and .cxx(.c) files (Unix/Dos)
# path         - path to working directory
# format       - all string will have this line breaks format (\n  or \r\n)
# _ignore_file - filepath with list of ignored files
proc _change_format { path format {_ignore_file ""}} {
  if {[string tolower  ${format}] != "unix" && [string tolower ${format}] != "dos"} {
    error "Error : File format is wrong (2 argument).\n        Possible formats: \"unix\" and \"dos\"."
  }
  set files {}
  if {[file isdirectory $path]} {
    foreach ext {"*.c" "*.cxx" "*.h" "*.hxx"} {
      set files [concat $files [_find_files "$path" "${ext}"]]
    }
  } else {
    lappend files ${path}
  }
  set ignorelist {}
  if {[file exists $_ignore_file]} {
    set ignorelist [_open_file $_ignore_file "\n\r"]
  }
  foreach file $files {
    set filename [file tail $file]
    if { [lsearch $ignorelist ${filename}] != -1 } { continue }
    set filelist [_open_file $file]
    if {[lsearch -glob $filelist "*\r*"] != -1} {
      if {[string tolower  ${format}] == "dos"} {
        continue
      }
      set i 0
      foreach line $filelist {
        if { [regexp -indices "\r" $line index] } {
          set filelist [lreplace $filelist ${i} ${i} [string range $line 0 [expr [lindex ${index} 0 ] - 1]]]
        }
        incr i
      }
      set ending "\n"
    } else {
      if {[string tolower  ${format}] == "unix"} {
        continue
      }
      set ending "\r\n"
    }
    _save_file $file $filelist "$ending"
  }
}

proc _remove_standard_type {_src {template "*_0.cxx"}} {
  loginfo "Removing wrong STANDARD_TYPE() macros in directory '${_src}'..."
  check_path "${_src}"
  foreach file [_find_files "${_src}" "${template}"] {
    set filelist [_open_file $file]
    set pattern_type1 {^\s*STANDARD_TYPE\s*\(\s*[A-Za-z0-9_]+\s*\),\s*$}
    set index [lsearch -regexp $filelist "$pattern_type1"]
    while { $index != -1 } {
      set filelist [lreplace $filelist ${index} ${index}]
      set index [lsearch -regexp $filelist "$pattern_type1"]
    }
    _save_file $file $filelist
  }
}

# Puts the passed string into Tk-based logger highlighting it with the
# given color for better view. If no logger exists (-ui option was not
# activated), the standard output is used.
proc _logcommon {msg color} {
    if { ! [catch {winfo exists .h} res] && $res } {
        .h.t insert end "$msg\n"

        if { $color != "" } {
            # We use the current number of lines to generate unique tag in the text
            set numlines [lindex [split [.h.t index "end - 1 line"] "."] 0]

            .h.t tag add my_tag_$numlines end-2l end-1l
            .h.t tag configure my_tag_$numlines -background $color
        }

        update
    } else {
        puts $msg
    }
}

# Create Tk-based logger which allows convenient consulting the upgrade process.
proc _create_logger {} {
    if { [catch {winfo exists .h}] } {
        logerr "Error: Tk commands are not available, cannot create UI!"
        return
    }

    if { ![winfo exists .h ] } {
        toplevel .h
        wm title .h "Conversion log"
        wm geometry .h +320+200
        wm resizable .h 0 0

        text .h.t -yscrollcommand {.h.sbar set}
        scrollbar .h.sbar -orient vertical -command {.h.t yview}

        pack .h.sbar -side right -fill y
        pack .h.t
    }
}

# Extracts package names from the given information file.
proc _info_extract_packages {info_file} {
    loginfo ">>> Extracting OCCT package names from $info_file..."

    # Read auxiliary data from specific upgrade information file
    set info_contents [_open_file $info_file]

    # Pattern for extracting the contents of 'occt_packages' variable
    set occt_packages_pattern {occt_packages=([A-Za-z0-9,\s]*)}
    regexp -all $occt_packages_pattern $info_contents all captured
    set packages $captured

    # Pattern for extracting a single package name
    set occt_one_package_pattern {[!_A-Za-z0-9]+}
    set result_list [regexp -line -inline -all $occt_one_package_pattern $packages]

    # Logging
    foreach package $result_list {
        loginfo "\t$package"
    }

    return $result_list
}

# updates copyrights from generated by WOK to original.
proc update_copyrights { _src } {
  loginfo "Updating copyrights in '${_src}' directory..."
  check_path "${_src}"

  foreach file [concat [_find_files "${_src}" "*.\[ch\]*"]] {
    set filelist [_open_file ${file}]
    if {[lsearch -exact ${filelist} "// This file is generated by WOK (CPPExt)."] == 0} {
      set top_comment_end [lsearch -regexp -not ${filelist} "//"]
      set cdl_path [file rootname ${file}].cdl
      set package [file tail [file dirname ${file}]]
      set package_cdl_path [file dirname ${file}]/${package}.cdl
      if {[file exists ${cdl_path}]} {
        set cdl [_open_file ${cdl_path}]
      } elseif {[file exists ${package_cdl_path}]} {
        set cdl [_open_file ${package_cdl_path}]
      } else {
        logerr "Error: unable to update copyrights in file '${file}'"
        logerr "       cdl files '${cdl_path}' and '${package_cdl_path}' do not exist"
        continue
      }
      set new_top_comment {}
      foreach line ${cdl} {
        if {[regexp {\-\-(.*)} ${line} full comment]} {
          lappend new_top_comment "//${comment}"
        } else {
          break
        }
      }
      set filelist [concat ${new_top_comment} [lrange ${filelist} ${top_comment_end} end]]
      _save_file ${file} ${filelist}
    }
  }
}
