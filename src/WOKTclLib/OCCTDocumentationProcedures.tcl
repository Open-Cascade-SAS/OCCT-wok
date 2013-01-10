# main graph dependency of modules  
proc OCCDoc_CreateModulesDependencyGraph {dir filename modules mpageprefix} {
  global module_dependency

  if {![catch {open $dir/$filename.dot "w"} file]} {
    puts $file "digraph $filename"
    puts $file "\{"
    
    foreach mod $modules {
      puts $file "\t$mod \[ URL = \"[string tolower $mpageprefix$mod.html]\" \]"
      foreach mod_depend $module_dependency($mod) {
	puts $file "\t$mod_depend -> $mod \[ dir = \"back\", color = \"midnightblue\", style = \"solid\" \]"
      }
    }
    
    puts $file "\}"
    close $file

    return $filename
  }
}

# dependency of all toolkits in module
proc OCCDoc_CreateModuleToolkitsDependencyGraph {dir filename modulename tpageprefix} {
  global toolkits_in_module
  global toolkit_dependency
  global toolkit_parent_module
  
  if {![catch {open $dir/$filename.dot "w"} file]} {
    puts $file "digraph $filename"
    puts $file "\{"
    
    #vertex
    foreach tk $toolkits_in_module($modulename) {
      puts $file "\t$tk \[ URL = \"[string tolower $tpageprefix$tk.html]\"\ ]"
      foreach tkd $toolkit_dependency($tk) {
        if {$toolkit_parent_module($tkd) == $modulename} {
          puts $file "\t$tkd -> $tk \[ dir = \"back\", color = \"midnightblue\", style = \"solid\" \]"    
        }
      }
    }
    
    puts $file "\}"
    close $file
    
    return $filename
  }
}

# dependency of current toolkit to other toolkits
proc OCCDoc_CreateToolkitDependencyGraph {dir filename toolkitname tpageprefix} {
  global toolkit_dependency
  
  if {![catch {open $dir/$filename.dot "w"} file]} {
    puts $file "digraph $filename"
    puts $file "\{"
    
    puts $file "\t$toolkitname \[ URL = \"[string tolower $tpageprefix$toolkitname.html]\"\, shape = box ]"
    foreach tkd $toolkit_dependency($toolkitname) {
      puts $file "\t$tkd \[ URL = \"[string tolower $tpageprefix$tkd.html]\"\ , shape = box ]"
      puts $file "\t$toolkitname -> $tkd \[ color = \"midnightblue\", style = \"solid\" \]"    
    }
    
    if {[llength $toolkit_dependency($toolkitname)] > 1} {
	puts $file "\taspect = 1"
    }
    
    puts $file "\}"
    close $file
    
    return $filename
  }
}

# fill arrays of modules, toolkits, dependency of modules/toolkits etc 
proc OCCDoc_LoadData {} {
  global toolkits_in_module
  global toolkit_dependency
  global toolkit_parent_module
  global module_dependency
  
  source [woklocate -p OS:source:Modules.tcl]
  set modules [OS:Modules]
  foreach mod $modules {
    source [woklocate -p OS:source:$mod.tcl]
    # get toolkits of current module
    set toolkits_in_module($mod) [$mod:toolkits]
    # get all dependence of current toolkit 
    foreach tk $toolkits_in_module($mod) {
      
      # set parent module of current toolkit
      set toolkit_parent_module($tk) $mod
      #puts "$tk $mod"
      
      set exlibfile [open [woklocate -p $tk:source:EXTERNLIB] r]
        set exlibfile_data [read $exlibfile]
        set exlibfile_data [split $exlibfile_data "\n"]
        
        set toolkit_dependency($tk) {}
        foreach dtk $exlibfile_data {
        if {[string first TK $dtk 0] == 0} {
          lappend toolkit_dependency($tk) $dtk
        }
      }
      close $exlibfile
    }
  }
  
  # get modules dependency
  foreach mod $modules {
    set module_dependency($mod) {}
    foreach tk $toolkits_in_module($mod) {
      foreach tkd $toolkit_dependency($tk) {
	if { $toolkit_parent_module($tkd) != $mod &&
	      [lsearch $module_dependency($mod) $toolkit_parent_module($tkd)] == -1} {
	  lappend module_dependency($mod) $toolkit_parent_module($tkd)
        }
      }
    }
  }
}

#parse line like "-arg1=val1 -arg2=val2 ..." to array args_names and map args_values
proc OCCDoc_ParseArguments {arguments} {
    global args_names
    global args_values
    set args_names {}
    array set args_values {}

    #puts "$arguments"
    foreach arg $arguments {
	#puts "$arg"
	if {[regexp {^(-)[a-z]+$} $arg] == 1} {
	    set name [string range $arg 1 [string length $arg]-1]
	    lappend args_names $name
	    set args_values($name) "NULL"
	    continue
	} elseif {[regexp {^(-)[a-z]+=.+$} $arg] == 1} {
	    set equal_symbol_position [string first "=" $arg]
	    set name [string range $arg 1 $equal_symbol_position-1]
	    lappend args_names $name
	    set args_values($name) [string range $arg $equal_symbol_position+1 [string length $arguments]-1]
	} else {
	    puts "Error in argument $arg"
	    return 1
	}
    }
    return 0
}


