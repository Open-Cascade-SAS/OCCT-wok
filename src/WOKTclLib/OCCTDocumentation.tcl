set OCCTDoc_DocLocation $env(OCCTDoc_Location)

set OCCTDoc_DescriptionUnit "OS"

proc OCCTDoc_UpdateDoxygenDocumentation {} {
    global OCCTDoc_RWorkbench
    global OCCTDoc_DescriptionUnit
    
    set path_RWorkbench [pwd]
    
    # verify is file Modules.tcl present in specific location
    if {[file exists $path_RWorkbench/src/$OCCTDoc_DescriptionUnit/Modules.tcl] != 1} {
	puts "File $path_RWorkbench/src/$OCCTDoc_DescriptionUnit/Modules.tcl is absent."
	puts "     It is impossible to continue the scripts."
	return
    }
    
    # get the list of modules
    set modulesList {}
    source $path_RWorkbench/src/$OCCTDoc_DescriptionUnit/Modules.tcl
    set modulesList [$OCCTDoc_DescriptionUnit:Modules]
    
    # processing the list of modules and prepare the list of toolkits
    set toolkitsListOfList {}
    foreach moduleName $modulesList {
	set toolkitsList {}
	if {[file exists $path_RWorkbench/src/$OCCTDoc_DescriptionUnit/$moduleName.tcl]==1} {
	    source $path_RWorkbench/src/$OCCTDoc_DescriptionUnit/$moduleName.tcl
	    set toolkitsList [$moduleName:toolkits]
	} else {
	    puts "File $path_RWorkbench/src/$OCCTDoc_DescriptionUnit/$moduleName.tcl is absent."
	    puts "     It is impossible to get information about toolkits in the module $moduleName."
	}
	lappend toolkitsListOfList $toolkitsList
    }
    
    # processing the list of toolkits and prepare the list of packages
    set packagesListOfListOfList {}
    foreach toolkitsListList $toolkitsListOfList {
	set packagesListOfList {}
	foreach toolkitName $toolkitsListList {
	    set packagesList {}
	    if {[file exists $path_RWorkbench/src/$toolkitName/PACKAGES] == 1} {
		set file_PACKAGES [open $path_RWorkbench/src/$toolkitName/PACKAGES RDONLY]
		while {[eof $file_PACKAGES] == 0} {
		    set packageName [string trim [gets $file_PACKAGES]]
		    if {[string length $packageName]!=0} {
			lappend packagesList $packageName
		    }
		}
		close $file_PACKAGES
	    } else {
		puts "File $path_RWorkbench/src/$toolkitName/PACKAGES is absent."
		puts "     It is impossible to get information about packages in the toolkit $toolkitName."
	    }
	    lappend packagesListOfList $packagesList
	}
	lappend packagesListOfListOfList $packagesListOfList
    }

    # creating of main HTML page
    set retValue [OCCTDoc_CreateMainDoc $modulesList $toolkitsListOfList $packagesListOfListOfList]
    if {$retValue == 1} {
	puts "It is impossible to update documentation created by doxygen."
	return
    }
}

proc OCCTDoc_CreateMainDoc {modulesList toolkitsListOfList packagesListOfListOfList} {
    global OCCTDoc_DocLocation
    set file_modulesHTML [open $OCCTDoc_DocLocation/index.html {CREAT TRUNC RDWR}]
    puts $file_modulesHTML "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">"
    puts $file_modulesHTML "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html;charset=iso-8859-1\">"
    puts $file_modulesHTML "<title>OpenCASCADE Modules</title>"
    puts $file_modulesHTML "<link href=\"doxygen.css\" rel=\"stylesheet\" type=\"text/css\">"
    puts $file_modulesHTML "</head><body>"
#    puts $file_modulesHTML "<div class=\"qindex\"><a class=\"qindex\" href=\"index.html\">OCC&nbsp;Main&nbsp;Page</a> | <a class=\"qindexHL\" href=\"modules.html\">OCC&nbsp;Modules</a></div>"
    puts $file_modulesHTML "<h1>OpenCASCADE<br>Modules</h1>"
    puts $file_modulesHTML "<hr size=\"1\">"
    puts $file_modulesHTML "<ul>"
    set isPrepared 0
    for {set indexOfList 0} {$indexOfList < [llength $modulesList]} {incr indexOfList 1} {
	set moduleName [lindex $modulesList $indexOfList]
	if {[file exists $OCCTDoc_DocLocation/$moduleName] == 1} {
	    if {[file exists $OCCTDoc_DocLocation/$moduleName/html/index.html] == 1} {
		if {[file exists $OCCTDoc_DocLocation/$moduleName/html/doxygen.css] == 1} {
		    exec cp $OCCTDoc_DocLocation/$moduleName/html/index.html $OCCTDoc_DocLocation/$moduleName/html/$moduleName\_index.html
		    puts $file_modulesHTML "<li><a class=\"el\" href=\"$moduleName/html/$moduleName\_index.html\">$moduleName</a>"
		    OCCTDoc_UpdateModuleIndex $moduleName
		    OCCTDoc_CreateToolkitHTML $moduleName [lindex $toolkitsListOfList $indexOfList] [lindex $packagesListOfListOfList $indexOfList]
		    OCCTDoc_CreatePackageHTML $moduleName [lindex $toolkitsListOfList $indexOfList] [lindex $packagesListOfListOfList $indexOfList]
		    if {$isPrepared == 0} {
			exec cp $OCCTDoc_DocLocation/$moduleName/html/doxygen.css $OCCTDoc_DocLocation/doxygen.css
			set isPrepared 1
		    }
		}
	    }
	} else {
	    puts "Dirrectory $OCCTDoc_DocLocation/$moduleName is absent."
	    puts "     It is impossible to create full documentation."
	}
    }
    puts $file_modulesHTML "</ul>"
    puts $file_modulesHTML "<hr size=\"1\">"
    puts $file_modulesHTML "</body>"
    puts $file_modulesHTML "</html>"
    close $file_modulesHTML
    if {$isPrepared == 0} {
	exec rm $OCCTDoc_DocLocation/index.html
	exec rm $OCCTDoc_DocLocation/doxygen.css
	return 1
    }
    return 0
}

proc OCCTDoc_UpdateModuleIndex {moduleName} {
    global OCCTDoc_DocLocation
    if {[file exists $OCCTDoc_DocLocation/$moduleName/html/$moduleName\_index.html] == 1} {
	set file_newModuleIndex [open $OCCTDoc_DocLocation/$moduleName/html/$moduleName\_index.html {TRUNC RDWR}]
	set file_oldModuleIndex [open $OCCTDoc_DocLocation/$moduleName/html/index.html RDONLY]
	while {[eof $file_oldModuleIndex] == 0} {
	    set isLineWrited 0
	    set line_OfFile [string trim [gets $file_oldModuleIndex]]
	    if {[string compare [string range $line_OfFile 0 6] "<title>"] == 0} {
		puts $file_newModuleIndex "<title>OpenCASCADE: $moduleName</title>"
		set isLineWrited 1
	    }
	    if {[string compare [string range $line_OfFile 0 6] "<div cl"] == 0} {
		puts $file_newModuleIndex "<div class=\"qindex\"><a class=\"qindex\" href=\"../../index.html\">OCC&nbsp;Main&nbsp;Page</a> | <a class=\"qindexHL\" href=\"$moduleName\_index.html\">$moduleName</a> | <a class=\"qindex\" href=\"toolkits.html\">Toolkits</a> | <a class=\"qindex\" href=\"packages.html\">Packages</a> | <a class=\"qindex\" href=\"hierarchy.html\">Class&nbsp;Hierarchy</a> | <a class=\"qindex\" href=\"annotated.html\">Data&nbsp;Structures</a> | <a class=\"qindex\" href=\"files.html\">File&nbsp;List</a> | <a class=\"qindex\" href=\"functions.html\">Data&nbsp;Fields</a> | <a class=\"qindex\" href=\"globals.html\">Globals</a></div>"
		set isLineWrited 1
	    }
	    if {[string compare [string range $line_OfFile 0 3] "<h1>"] == 0} {
		puts $file_newModuleIndex "<h1>$moduleName Documentation</h1>"
		set isLineWrited 1
	    }
	    if {$isLineWrited == 0} {
		puts $file_newModuleIndex $line_OfFile
	    }
	}
	close $file_oldModuleIndex
	close $file_newModuleIndex
	OCCTDoc_UpdateModuleHTMLFiles $moduleName
    } else {
	puts "File $OCCTDoc_DocLocation/$moduleName/html/$moduleName\_index.html is absent."
	puts "     Documentation for $moduleName is not updated."
    }
}

proc OCCTDoc_UpdateModuleHTMLFiles {moduleName} {
    global OCCTDoc_DocLocation
    # Processing the file annotated.html
    if {[file exists $OCCTDoc_DocLocation/$moduleName/html/annotated.html] == 1} {
	exec cp $OCCTDoc_DocLocation/$moduleName/html/annotated.html $OCCTDoc_DocLocation/$moduleName/html/annotated.html.old
	set isLineWrited 0
	set file_new [open $OCCTDoc_DocLocation/$moduleName/html/annotated.html {RDWR TRUNC}]
	set file_old [open $OCCTDoc_DocLocation/$moduleName/html/annotated.html.old RDONLY]
	while {[eof $file_old] == 0} {
	    set fileLine [string trim [gets $file_old]]
	    if {[string compare [string range $fileLine 0 6] "<div cl"] == 0} {
		if {$isLineWrited == 0} {
		    puts $file_new "<div class=\"qindex\"><a class=\"qindex\" href=\"../../index.html\">OCC&nbsp;Main&nbsp;Page</a> | <a class=\"qindex\" href=\"$moduleName\_index.html\">$moduleName</a> | <a class=\"qindex\" href=\"toolkits.html\">Toolkits</a> | <a class=\"qindex\" href=\"packages.html\">Packages</a> | <a class=\"qindex\" href=\"hierarchy.html\">Class&nbsp;Hierarchy</a> | <a class=\"qindexHL\" href=\"annotated.html\">Data&nbsp;Structures</a> | <a class=\"qindex\" href=\"files.html\">File&nbsp;List</a> | <a class=\"qindex\" href=\"functions.html\">Data&nbsp;Fields</a> | <a class=\"qindex\" href=\"globals.html\">Globals</a></div>"
		    set isLineWrited 1
		} else {
		    puts $file_new $fileLine
		}
	    } else {
		puts $file_new $fileLine
	    }
	}
	close $file_old
	close $file_new
    }
    # Processing the file files.html
    if {[file exists $OCCTDoc_DocLocation/$moduleName/html/files.html] == 1} {
	exec cp $OCCTDoc_DocLocation/$moduleName/html/files.html $OCCTDoc_DocLocation/$moduleName/html/files.html.old
	set isLineWrited 0
	set file_new [open $OCCTDoc_DocLocation/$moduleName/html/files.html {RDWR TRUNC}]
	set file_old [open $OCCTDoc_DocLocation/$moduleName/html/files.html.old RDONLY]
	while {[eof $file_old] == 0} {
	    set fileLine [string trim [gets $file_old]]
	    if {[string compare [string range $fileLine 0 6] "<div cl"] == 0} {
		if {$isLineWrited == 0} {
		    puts $file_new "<div class=\"qindex\"><a class=\"qindex\" href=\"../../index.html\">OCC&nbsp;Main&nbsp;Page</a> | <a class=\"qindex\" href=\"$moduleName\_index.html\">$moduleName</a> | <a class=\"qindex\" href=\"toolkits.html\">Toolkits</a> | <a class=\"qindex\" href=\"packages.html\">Packages</a> | <a class=\"qindex\" href=\"hierarchy.html\">Class&nbsp;Hierarchy</a> | <a class=\"qindex\" href=\"annotated.html\">Data&nbsp;Structures</a> | <a class=\"qindexHL\" href=\"files.html\">File&nbsp;List</a> | <a class=\"qindex\" href=\"functions.html\">Data&nbsp;Fields</a> | <a class=\"qindex\" href=\"globals.html\">Globals</a></div>"
		    set isLineWrited 1
		} else {
		    puts $file_new $fileLine
		}
	    } else {
		puts $file_new $fileLine
	    }
	}
	close $file_old
	close $file_new
    }
    # Processing the file functions.html
    if {[file exists $OCCTDoc_DocLocation/$moduleName/html/functions.html] == 1} {
	exec cp $OCCTDoc_DocLocation/$moduleName/html/functions.html $OCCTDoc_DocLocation/$moduleName/html/functions.html.old
	set isLineWrited 0
	set file_new [open $OCCTDoc_DocLocation/$moduleName/html/functions.html {RDWR TRUNC}]
	set file_old [open $OCCTDoc_DocLocation/$moduleName/html/functions.html.old RDONLY]
	while {[eof $file_old] == 0} {
	    set fileLine [string trim [gets $file_old]]
	    if {[string compare [string range $fileLine 0 6] "<div cl"] == 0} {
		if {$isLineWrited == 0} {
		    puts $file_new "<div class=\"qindex\"><a class=\"qindex\" href=\"../../index.html\">OCC&nbsp;Main&nbsp;Page</a> | <a class=\"qindex\" href=\"$moduleName\_index.html\">$moduleName</a> | <a class=\"qindex\" href=\"toolkits.html\">Toolkits</a> | <a class=\"qindex\" href=\"packages.html\">Packages</a> | <a class=\"qindex\" href=\"hierarchy.html\">Class&nbsp;Hierarchy</a> | <a class=\"qindex\" href=\"annotated.html\">Data&nbsp;Structures</a> | <a class=\"qindex\" href=\"files.html\">File&nbsp;List</a> | <a class=\"qindexHL\" href=\"functions.html\">Data&nbsp;Fields</a> | <a class=\"qindex\" href=\"globals.html\">Globals</a></div>"
		    set isLineWrited 1
		} else {
		    puts $file_new $fileLine
		}
	    } else {
		puts $file_new $fileLine
	    }
	}
	close $file_old
	close $file_new
    }
    # Processing the file functions_enum.html
    if {[file exists $OCCTDoc_DocLocation/$moduleName/html/functions_enum.html] == 1} {
	exec cp $OCCTDoc_DocLocation/$moduleName/html/functions_enum.html $OCCTDoc_DocLocation/$moduleName/html/functions_enum.html.old
	set isLineWrited 0
	set file_new [open $OCCTDoc_DocLocation/$moduleName/html/functions_enum.html {RDWR TRUNC}]
	set file_old [open $OCCTDoc_DocLocation/$moduleName/html/functions_enum.html.old RDONLY]
	while {[eof $file_old] == 0} {
	    set fileLine [string trim [gets $file_old]]
	    if {[string compare [string range $fileLine 0 6] "<div cl"] == 0} {
		if {$isLineWrited == 0} {
		    puts $file_new "<div class=\"qindex\"><a class=\"qindex\" href=\"../../index.html\">OCC&nbsp;Main&nbsp;Page</a> | <a class=\"qindex\" href=\"$moduleName\_index.html\">$moduleName</a> | <a class=\"qindex\" href=\"toolkits.html\">Toolkits</a> | <a class=\"qindex\" href=\"packages.html\">Packages</a> | <a class=\"qindex\" href=\"hierarchy.html\">Class&nbsp;Hierarchy</a> | <a class=\"qindex\" href=\"annotated.html\">Data&nbsp;Structures</a> | <a class=\"qindex\" href=\"files.html\">File&nbsp;List</a> | <a class=\"qindexHL\" href=\"functions.html\">Data&nbsp;Fields</a> | <a class=\"qindex\" href=\"globals.html\">Globals</a></div>"
		    set isLineWrited 1
		} else {
		    puts $file_new $fileLine
		}
	    } else {
		puts $file_new $fileLine
	    }
	}
	close $file_old
	close $file_new
    }
    # Processing the file functions_eval.html
    if {[file exists $OCCTDoc_DocLocation/$moduleName/html/functions_eval.html] == 1} {
	exec cp $OCCTDoc_DocLocation/$moduleName/html/functions_eval.html $OCCTDoc_DocLocation/$moduleName/html/functions_eval.html.old
	set isLineWrited 0
	set file_new [open $OCCTDoc_DocLocation/$moduleName/html/functions_eval.html {RDWR TRUNC}]
	set file_old [open $OCCTDoc_DocLocation/$moduleName/html/functions_eval.html.old RDONLY]
	while {[eof $file_old] == 0} {
	    set fileLine [string trim [gets $file_old]]
	    if {[string compare [string range $fileLine 0 6] "<div cl"] == 0} {
		if {$isLineWrited == 0} {
		    puts $file_new "<div class=\"qindex\"><a class=\"qindex\" href=\"../../index.html\">OCC&nbsp;Main&nbsp;Page</a> | <a class=\"qindex\" href=\"$moduleName\_index.html\">$moduleName</a> | <a class=\"qindex\" href=\"toolkits.html\">Toolkits</a> | <a class=\"qindex\" href=\"packages.html\">Packages</a> | <a class=\"qindex\" href=\"hierarchy.html\">Class&nbsp;Hierarchy</a> | <a class=\"qindex\" href=\"annotated.html\">Data&nbsp;Structures</a> | <a class=\"qindex\" href=\"files.html\">File&nbsp;List</a> | <a class=\"qindexHL\" href=\"functions.html\">Data&nbsp;Fields</a> | <a class=\"qindex\" href=\"globals.html\">Globals</a></div>"
		    set isLineWrited 1
		} else {
		    puts $file_new $fileLine
		}
	    } else {
		puts $file_new $fileLine
	    }
	}
	close $file_old
	close $file_new
    }
    # Processing the file functions_func.html
    if {[file exists $OCCTDoc_DocLocation/$moduleName/html/functions_func.html] == 1} {
	exec cp $OCCTDoc_DocLocation/$moduleName/html/functions_func.html $OCCTDoc_DocLocation/$moduleName/html/functions_func.html.old
	set isLineWrited 0
	set file_new [open $OCCTDoc_DocLocation/$moduleName/html/functions_func.html {RDWR TRUNC}]
	set file_old [open $OCCTDoc_DocLocation/$moduleName/html/functions_func.html.old RDONLY]
	while {[eof $file_old] == 0} {
	    set fileLine [string trim [gets $file_old]]
	    if {[string compare [string range $fileLine 0 6] "<div cl"] == 0} {
		if {$isLineWrited == 0} {
		    puts $file_new "<div class=\"qindex\"><a class=\"qindex\" href=\"../../index.html\">OCC&nbsp;Main&nbsp;Page</a> | <a class=\"qindex\" href=\"$moduleName\_index.html\">$moduleName</a> | <a class=\"qindex\" href=\"toolkits.html\">Toolkits</a> | <a class=\"qindex\" href=\"packages.html\">Packages</a> | <a class=\"qindex\" href=\"hierarchy.html\">Class&nbsp;Hierarchy</a> | <a class=\"qindex\" href=\"annotated.html\">Data&nbsp;Structures</a> | <a class=\"qindex\" href=\"files.html\">File&nbsp;List</a> | <a class=\"qindexHL\" href=\"functions.html\">Data&nbsp;Fields</a> | <a class=\"qindex\" href=\"globals.html\">Globals</a></div>"
		    set isLineWrited 1
		} else {
		    puts $file_new $fileLine
		}
	    } else {
		puts $file_new $fileLine
	    }
	}
	close $file_old
	close $file_new
    }
    # Processing the file functions_rela.html
    if {[file exists $OCCTDoc_DocLocation/$moduleName/html/functions_rela.html] == 1} {
	exec cp $OCCTDoc_DocLocation/$moduleName/html/functions_rela.html $OCCTDoc_DocLocation/$moduleName/html/functions_rela.html.old
	set isLineWrited 0
	set file_new [open $OCCTDoc_DocLocation/$moduleName/html/functions_rela.html {RDWR TRUNC}]
	set file_old [open $OCCTDoc_DocLocation/$moduleName/html/functions_rela.html.old RDONLY]
	while {[eof $file_old] == 0} {
	    set fileLine [string trim [gets $file_old]]
	    if {[string compare [string range $fileLine 0 6] "<div cl"] == 0} {
		if {$isLineWrited == 0} {
		    puts $file_new "<div class=\"qindex\"><a class=\"qindex\" href=\"../../index.html\">OCC&nbsp;Main&nbsp;Page</a> | <a class=\"qindex\" href=\"$moduleName\_index.html\">$moduleName</a> | <a class=\"qindex\" href=\"toolkits.html\">Toolkits</a> | <a class=\"qindex\" href=\"packages.html\">Packages</a> | <a class=\"qindex\" href=\"hierarchy.html\">Class&nbsp;Hierarchy</a> | <a class=\"qindex\" href=\"annotated.html\">Data&nbsp;Structures</a> | <a class=\"qindex\" href=\"files.html\">File&nbsp;List</a> | <a class=\"qindexHL\" href=\"functions.html\">Data&nbsp;Fields</a> | <a class=\"qindex\" href=\"globals.html\">Globals</a></div>"
		    set isLineWrited 1
		} else {
		    puts $file_new $fileLine
		}
	    } else {
		puts $file_new $fileLine
	    }
	}
	close $file_old
	close $file_new
    }
    # Processing the file functions_vars.html
    if {[file exists $OCCTDoc_DocLocation/$moduleName/html/functions_vars.html] == 1} {
	exec cp $OCCTDoc_DocLocation/$moduleName/html/functions_vars.html $OCCTDoc_DocLocation/$moduleName/html/functions_vars.html.old
	set isLineWrited 0
	set file_new [open $OCCTDoc_DocLocation/$moduleName/html/functions_vars.html {RDWR TRUNC}]
	set file_old [open $OCCTDoc_DocLocation/$moduleName/html/functions_vars.html.old RDONLY]
	while {[eof $file_old] == 0} {
	    set fileLine [string trim [gets $file_old]]
	    if {[string compare [string range $fileLine 0 6] "<div cl"] == 0} {
		if {$isLineWrited == 0} {
		    puts $file_new "<div class=\"qindex\"><a class=\"qindex\" href=\"../../index.html\">OCC&nbsp;Main&nbsp;Page</a> | <a class=\"qindex\" href=\"$moduleName\_index.html\">$moduleName</a> | <a class=\"qindex\" href=\"toolkits.html\">Toolkits</a> | <a class=\"qindex\" href=\"packages.html\">Packages</a> | <a class=\"qindex\" href=\"hierarchy.html\">Class&nbsp;Hierarchy</a> | <a class=\"qindex\" href=\"annotated.html\">Data&nbsp;Structures</a> | <a class=\"qindex\" href=\"files.html\">File&nbsp;List</a> | <a class=\"qindexHL\" href=\"functions.html\">Data&nbsp;Fields</a> | <a class=\"qindex\" href=\"globals.html\">Globals</a></div>"
		    set isLineWrited 1
		} else {
		    puts $file_new $fileLine
		}
	    } else {
		puts $file_new $fileLine
	    }
	}
	close $file_old
	close $file_new
    }
    # Processing the file globals.html
    if {[file exists $OCCTDoc_DocLocation/$moduleName/html/globals.html] == 1} {
	exec cp $OCCTDoc_DocLocation/$moduleName/html/globals.html $OCCTDoc_DocLocation/$moduleName/html/globals.html.old
	set isLineWrited 0
	set file_new [open $OCCTDoc_DocLocation/$moduleName/html/globals.html {RDWR TRUNC}]
	set file_old [open $OCCTDoc_DocLocation/$moduleName/html/globals.html.old RDONLY]
	while {[eof $file_old] == 0} {
	    set fileLine [string trim [gets $file_old]]
	    if {[string compare [string range $fileLine 0 6] "<div cl"] == 0} {
		if {$isLineWrited == 0} {
		    puts $file_new "<div class=\"qindex\"><a class=\"qindex\" href=\"../../index.html\">OCC&nbsp;Main&nbsp;Page</a> | <a class=\"qindex\" href=\"$moduleName\_index.html\">$moduleName</a> | <a class=\"qindex\" href=\"toolkits.html\">Toolkits</a> | <a class=\"qindex\" href=\"packages.html\">Packages</a> | <a class=\"qindex\" href=\"hierarchy.html\">Class&nbsp;Hierarchy</a> | <a class=\"qindex\" href=\"annotated.html\">Data&nbsp;Structures</a> | <a class=\"qindex\" href=\"files.html\">File&nbsp;List</a> | <a class=\"qindex\" href=\"functions.html\">Data&nbsp;Fields</a> | <a class=\"qindexHL\" href=\"globals.html\">Globals</a></div>"
		    set isLineWrited 1
		} else {
		    puts $file_new $fileLine
		}
	    } else {
		puts $file_new $fileLine
	    }
	}
	close $file_old
	close $file_new
    }
    # Processing the file globals_defs.html
    if {[file exists $OCCTDoc_DocLocation/$moduleName/html/globals_defs.html] == 1} {
	exec cp $OCCTDoc_DocLocation/$moduleName/html/globals_defs.html $OCCTDoc_DocLocation/$moduleName/html/globals_defs.html.old
	set isLineWrited 0
	set file_new [open $OCCTDoc_DocLocation/$moduleName/html/globals_defs.html {RDWR TRUNC}]
	set file_old [open $OCCTDoc_DocLocation/$moduleName/html/globals_defs.html.old RDONLY]
	while {[eof $file_old] == 0} {
	    set fileLine [string trim [gets $file_old]]
	    if {[string compare [string range $fileLine 0 6] "<div cl"] == 0} {
		if {$isLineWrited == 0} {
		    puts $file_new "<div class=\"qindex\"><a class=\"qindex\" href=\"../../index.html\">OCC&nbsp;Main&nbsp;Page</a> | <a class=\"qindex\" href=\"$moduleName\_index.html\">$moduleName</a> | <a class=\"qindex\" href=\"toolkits.html\">Toolkits</a> | <a class=\"qindex\" href=\"packages.html\">Packages</a> | <a class=\"qindex\" href=\"hierarchy.html\">Class&nbsp;Hierarchy</a> | <a class=\"qindex\" href=\"annotated.html\">Data&nbsp;Structures</a> | <a class=\"qindex\" href=\"files.html\">File&nbsp;List</a> | <a class=\"qindex\" href=\"functions.html\">Data&nbsp;Fields</a> | <a class=\"qindexHL\" href=\"globals.html\">Globals</a></div>"
		    set isLineWrited 1
		} else {
		    puts $file_new $fileLine
		}
	    } else {
		puts $file_new $fileLine
	    }
	}
	close $file_old
	close $file_new
    }
    # Processing the file globals_enum.html
    if {[file exists $OCCTDoc_DocLocation/$moduleName/html/globals_enum.html] == 1} {
	exec cp $OCCTDoc_DocLocation/$moduleName/html/globals_enum.html $OCCTDoc_DocLocation/$moduleName/html/globals_enum.html.old
	set isLineWrited 0
	set file_new [open $OCCTDoc_DocLocation/$moduleName/html/globals_enum.html {RDWR TRUNC}]
	set file_old [open $OCCTDoc_DocLocation/$moduleName/html/globals_enum.html.old RDONLY]
	while {[eof $file_old] == 0} {
	    set fileLine [string trim [gets $file_old]]
	    if {[string compare [string range $fileLine 0 6] "<div cl"] == 0} {
		if {$isLineWrited == 0} {
		    puts $file_new "<div class=\"qindex\"><a class=\"qindex\" href=\"../../index.html\">OCC&nbsp;Main&nbsp;Page</a> | <a class=\"qindex\" href=\"$moduleName\_index.html\">$moduleName</a> | <a class=\"qindex\" href=\"toolkits.html\">Toolkits</a> | <a class=\"qindex\" href=\"packages.html\">Packages</a> | <a class=\"qindex\" href=\"hierarchy.html\">Class&nbsp;Hierarchy</a> | <a class=\"qindex\" href=\"annotated.html\">Data&nbsp;Structures</a> | <a class=\"qindex\" href=\"files.html\">File&nbsp;List</a> | <a class=\"qindex\" href=\"functions.html\">Data&nbsp;Fields</a> | <a class=\"qindexHL\" href=\"globals.html\">Globals</a></div>"
		    set isLineWrited 1
		} else {
		    puts $file_new $fileLine
		}
	    } else {
		puts $file_new $fileLine
	    }
	}
	close $file_old
	close $file_new
    }
    # Processing the file globals_eval.html
    if {[file exists $OCCTDoc_DocLocation/$moduleName/html/globals_eval.html] == 1} {
	exec cp $OCCTDoc_DocLocation/$moduleName/html/globals_eval.html $OCCTDoc_DocLocation/$moduleName/html/globals_eval.html.old
	set isLineWrited 0
	set file_new [open $OCCTDoc_DocLocation/$moduleName/html/globals_eval.html {RDWR TRUNC}]
	set file_old [open $OCCTDoc_DocLocation/$moduleName/html/globals_eval.html.old RDONLY]
	while {[eof $file_old] == 0} {
	    set fileLine [string trim [gets $file_old]]
	    if {[string compare [string range $fileLine 0 6] "<div cl"] == 0} {
		if {$isLineWrited == 0} {
		    puts $file_new "<div class=\"qindex\"><a class=\"qindex\" href=\"../../index.html\">OCC&nbsp;Main&nbsp;Page</a> | <a class=\"qindex\" href=\"$moduleName\_index.html\">$moduleName</a> | <a class=\"qindex\" href=\"toolkits.html\">Toolkits</a> | <a class=\"qindex\" href=\"packages.html\">Packages</a> | <a class=\"qindex\" href=\"hierarchy.html\">Class&nbsp;Hierarchy</a> | <a class=\"qindex\" href=\"annotated.html\">Data&nbsp;Structures</a> | <a class=\"qindex\" href=\"files.html\">File&nbsp;List</a> | <a class=\"qindex\" href=\"functions.html\">Data&nbsp;Fields</a> | <a class=\"qindexHL\" href=\"globals.html\">Globals</a></div>"
		    set isLineWrited 1
		} else {
		    puts $file_new $fileLine
		}
	    } else {
		puts $file_new $fileLine
	    }
	}
	close $file_old
	close $file_new
    }
    # Processing the file globals_func.html
    if {[file exists $OCCTDoc_DocLocation/$moduleName/html/globals_func.html] == 1} {
	exec cp $OCCTDoc_DocLocation/$moduleName/html/globals_func.html $OCCTDoc_DocLocation/$moduleName/html/globals_func.html.old
	set isLineWrited 0
	set file_new [open $OCCTDoc_DocLocation/$moduleName/html/globals_func.html {RDWR TRUNC}]
	set file_old [open $OCCTDoc_DocLocation/$moduleName/html/globals_func.html.old RDONLY]
	while {[eof $file_old] == 0} {
	    set fileLine [string trim [gets $file_old]]
	    if {[string compare [string range $fileLine 0 6] "<div cl"] == 0} {
		if {$isLineWrited == 0} {
		    puts $file_new "<div class=\"qindex\"><a class=\"qindex\" href=\"../../index.html\">OCC&nbsp;Main&nbsp;Page</a> | <a class=\"qindex\" href=\"$moduleName\_index.html\">$moduleName</a> | <a class=\"qindex\" href=\"toolkits.html\">Toolkits</a> | <a class=\"qindex\" href=\"packages.html\">Packages</a> | <a class=\"qindex\" href=\"hierarchy.html\">Class&nbsp;Hierarchy</a> | <a class=\"qindex\" href=\"annotated.html\">Data&nbsp;Structures</a> | <a class=\"qindex\" href=\"files.html\">File&nbsp;List</a> | <a class=\"qindex\" href=\"functions.html\">Data&nbsp;Fields</a> | <a class=\"qindexHL\" href=\"globals.html\">Globals</a></div>"
		    set isLineWrited 1
		} else {
		    puts $file_new $fileLine
		}
	    } else {
		puts $file_new $fileLine
	    }
	}
	close $file_old
	close $file_new
    }
    # Processing the file globals_type.html
    if {[file exists $OCCTDoc_DocLocation/$moduleName/html/globals_type.html] == 1} {
	exec cp $OCCTDoc_DocLocation/$moduleName/html/globals_type.html $OCCTDoc_DocLocation/$moduleName/html/globals_type.html.old
	set isLineWrited 0
	set file_new [open $OCCTDoc_DocLocation/$moduleName/html/globals_type.html {RDWR TRUNC}]
	set file_old [open $OCCTDoc_DocLocation/$moduleName/html/globals_type.html.old RDONLY]
	while {[eof $file_old] == 0} {
	    set fileLine [string trim [gets $file_old]]
	    if {[string compare [string range $fileLine 0 6] "<div cl"] == 0} {
		if {$isLineWrited == 0} {
		    puts $file_new "<div class=\"qindex\"><a class=\"qindex\" href=\"../../index.html\">OCC&nbsp;Main&nbsp;Page</a> | <a class=\"qindex\" href=\"$moduleName\_index.html\">$moduleName</a> | <a class=\"qindex\" href=\"toolkits.html\">Toolkits</a> | <a class=\"qindex\" href=\"packages.html\">Packages</a> | <a class=\"qindex\" href=\"hierarchy.html\">Class&nbsp;Hierarchy</a> | <a class=\"qindex\" href=\"annotated.html\">Data&nbsp;Structures</a> | <a class=\"qindex\" href=\"files.html\">File&nbsp;List</a> | <a class=\"qindex\" href=\"functions.html\">Data&nbsp;Fields</a> | <a class=\"qindexHL\" href=\"globals.html\">Globals</a></div>"
		    set isLineWrited 1
		} else {
		    puts $file_new $fileLine
		}
	    } else {
		puts $file_new $fileLine
	    }
	}
	close $file_old
	close $file_new
    }
    # Processing the file globals_vars.html
    if {[file exists $OCCTDoc_DocLocation/$moduleName/html/globals_vars.html] == 1} {
	exec cp $OCCTDoc_DocLocation/$moduleName/html/globals_vars.html $OCCTDoc_DocLocation/$moduleName/html/globals_vars.html.old
	set isLineWrited 0
	set file_new [open $OCCTDoc_DocLocation/$moduleName/html/globals_vars.html {RDWR TRUNC}]
	set file_old [open $OCCTDoc_DocLocation/$moduleName/html/globals_vars.html.old RDONLY]
	while {[eof $file_old] == 0} {
	    set fileLine [string trim [gets $file_old]]
	    if {[string compare [string range $fileLine 0 6] "<div cl"] == 0} {
		if {$isLineWrited == 0} {
		    puts $file_new "<div class=\"qindex\"><a class=\"qindex\" href=\"../../index.html\">OCC&nbsp;Main&nbsp;Page</a> | <a class=\"qindex\" href=\"$moduleName\_index.html\">$moduleName</a> | <a class=\"qindex\" href=\"toolkits.html\">Toolkits</a> | <a class=\"qindex\" href=\"packages.html\">Packages</a> | <a class=\"qindex\" href=\"hierarchy.html\">Class&nbsp;Hierarchy</a> | <a class=\"qindex\" href=\"annotated.html\">Data&nbsp;Structures</a> | <a class=\"qindex\" href=\"files.html\">File&nbsp;List</a> | <a class=\"qindex\" href=\"functions.html\">Data&nbsp;Fields</a> | <a class=\"qindexHL\" href=\"globals.html\">Globals</a></div>"
		    set isLineWrited 1
		} else {
		    puts $file_new $fileLine
		}
	    } else {
		puts $file_new $fileLine
	    }
	}
	close $file_old
	close $file_new
    }
    # Processing the file graph_legend.html
    if {[file exists $OCCTDoc_DocLocation/$moduleName/html/graph_legend.html] == 1} {
	exec cp $OCCTDoc_DocLocation/$moduleName/html/graph_legend.html $OCCTDoc_DocLocation/$moduleName/html/graph_legend.html.old
	set isLineWrited 0
	set file_new [open $OCCTDoc_DocLocation/$moduleName/html/graph_legend.html {RDWR TRUNC}]
	set file_old [open $OCCTDoc_DocLocation/$moduleName/html/graph_legend.html.old RDONLY]
	while {[eof $file_old] == 0} {
	    set fileLine [string trim [gets $file_old]]
	    if {[string compare [string range $fileLine 0 6] "<div cl"] == 0} {
		if {$isLineWrited == 0} {
		    puts $file_new "<div class=\"qindex\"><a class=\"qindex\" href=\"../../index.html\">OCC&nbsp;Main&nbsp;Page</a> | <a class=\"qindex\" href=\"$moduleName\_index.html\">$moduleName</a> | <a class=\"qindex\" href=\"toolkits.html\">Toolkits</a> | <a class=\"qindex\" href=\"packages.html\">Packages</a> | <a class=\"qindex\" href=\"hierarchy.html\">Class&nbsp;Hierarchy</a> | <a class=\"qindex\" href=\"annotated.html\">Data&nbsp;Structures</a> | <a class=\"qindex\" href=\"files.html\">File&nbsp;List</a> | <a class=\"qindex\" href=\"functions.html\">Data&nbsp;Fields</a> | <a class=\"qindex\" href=\"globals.html\">Globals</a></div>"
		    set isLineWrited 1
		} else {
		    puts $file_new $fileLine
		}
	    } else {
		puts $file_new $fileLine
	    }
	}
	close $file_old
	close $file_new
    }
    # Processing the file hierarchy.html
    if {[file exists $OCCTDoc_DocLocation/$moduleName/html/hierarchy.html] == 1} {
	exec cp $OCCTDoc_DocLocation/$moduleName/html/hierarchy.html $OCCTDoc_DocLocation/$moduleName/html/hierarchy.html.old
	set isLineWrited 0
	set file_new [open $OCCTDoc_DocLocation/$moduleName/html/hierarchy.html {RDWR TRUNC}]
	set file_old [open $OCCTDoc_DocLocation/$moduleName/html/hierarchy.html.old RDONLY]
	while {[eof $file_old] == 0} {
	    set fileLine [string trim [gets $file_old]]
	    if {[string compare [string range $fileLine 0 6] "<div cl"] == 0} {
		if {$isLineWrited == 0} {
		    puts $file_new "<div class=\"qindex\"><a class=\"qindex\" href=\"../../index.html\">OCC&nbsp;Main&nbsp;Page</a> | <a class=\"qindex\" href=\"$moduleName\_index.html\">$moduleName</a> | <a class=\"qindex\" href=\"toolkits.html\">Toolkits</a> | <a class=\"qindex\" href=\"packages.html\">Packages</a> | <a class=\"qindexHL\" href=\"hierarchy.html\">Class&nbsp;Hierarchy</a> | <a class=\"qindex\" href=\"annotated.html\">Data&nbsp;Structures</a> | <a class=\"qindex\" href=\"files.html\">File&nbsp;List</a> | <a class=\"qindex\" href=\"functions.html\">Data&nbsp;Fields</a> | <a class=\"qindex\" href=\"globals.html\">Globals</a></div>"
		    set isLineWrited 1
		} else {
		    puts $file_new $fileLine
		}
	    } else {
		puts $file_new $fileLine
	    }
	}
	close $file_old
	close $file_new
    }
    # Processing the file inherits.html
    if {[file exists $OCCTDoc_DocLocation/$moduleName/html/inherits.html] == 1} {
	exec cp $OCCTDoc_DocLocation/$moduleName/html/inherits.html $OCCTDoc_DocLocation/$moduleName/html/inherits.html.old
	set isLineWrited 0
	set file_new [open $OCCTDoc_DocLocation/$moduleName/html/inherits.html {RDWR TRUNC}]
	set file_old [open $OCCTDoc_DocLocation/$moduleName/html/inherits.html.old RDONLY]
	while {[eof $file_old] == 0} {
	    set fileLine [string trim [gets $file_old]]
	    if {[string compare [string range $fileLine 0 6] "<div cl"] == 0} {
		if {$isLineWrited == 0} {
		    puts $file_new "<div class=\"qindex\"><a class=\"qindex\" href=\"../../index.html\">OCC&nbsp;Main&nbsp;Page</a> | <a class=\"qindex\" href=\"$moduleName\_index.html\">$moduleName</a> | <a class=\"qindex\" href=\"toolkits.html\">Toolkits</a> | <a class=\"qindex\" href=\"packages.html\">Packages</a> | <a class=\"qindex\" href=\"hierarchy.html\">Class&nbsp;Hierarchy</a> | <a class=\"qindex\" href=\"annotated.html\">Data&nbsp;Structures</a> | <a class=\"qindex\" href=\"files.html\">File&nbsp;List</a> | <a class=\"qindex\" href=\"functions.html\">Data&nbsp;Fields</a> | <a class=\"qindex\" href=\"globals.html\">Globals</a></div>"
		    set isLineWrited 1
		} else {
		    puts $file_new $fileLine
		}
	    } else {
		puts $file_new $fileLine
	    }
	}
	close $file_old
	close $file_new
    }
}

proc OCCTDoc_CreateToolkitHTML {moduleName toolkitsList packagesListOfList} {
    global OCCTDoc_DocLocation
    if {[file exists $OCCTDoc_DocLocation/$moduleName/html/toolkits] == 0} {
	exec mkdir $OCCTDoc_DocLocation/$moduleName/html/toolkits
    }
    set file_toolkitsHTML [open $OCCTDoc_DocLocation/$moduleName/html/toolkits.html {CREAT TRUNC RDWR}]
    puts $file_toolkitsHTML "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">"
    puts $file_toolkitsHTML "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html;charset=iso-8859-1\">"
    puts $file_toolkitsHTML "<title>$moduleName: Toolkits</title>"
    puts $file_toolkitsHTML "<link href=\"doxygen.css\" rel=\"stylesheet\" type=\"text/css\">"
    puts $file_toolkitsHTML "</head><body>"
    puts $file_toolkitsHTML "<div class=\"qindex\"><a class=\"qindex\" href=\"../../index.html\">OCC&nbsp;Main&nbsp;Page</a> | <a class=\"qindex\" href=\"$moduleName\_index.html\">$moduleName</a> | <a class=\"qindex\" href=\"toolkits.html\">Toolkits</a> | <a class=\"qindex\" href=\"packages.html\">Packages</a> | <a class=\"qindex\" href=\"hierarchy.html\">Class&nbsp;Hierarchy</a> | <a class=\"qindex\" href=\"annotated.html\">Data&nbsp;Structures</a> | <a class=\"qindex\" href=\"files.html\">File&nbsp;List</a> | <a class=\"qindex\" href=\"functions.html\">Data&nbsp;Fields</a> | <a class=\"qindex\" href=\"globals.html\">Globals</a></div>"
    puts $file_toolkitsHTML "<h1>$moduleName<br>Toolkits</h1>"
    puts $file_toolkitsHTML "<hr size=\"1\">"
    puts $file_toolkitsHTML "<ul>"
    for {set indexOfList 0} {$indexOfList < [llength $toolkitsList]} {incr indexOfList 1} {
	set toolkitName [lindex $toolkitsList $indexOfList]
	puts $file_toolkitsHTML "<li><a class=\"el\" href=\"toolkits/$toolkitName.html\">$toolkitName</a>"
	OCCTDoc_ProcessToolkitsHTML $moduleName $toolkitName [lindex $packagesListOfList $indexOfList]
    }
    puts $file_toolkitsHTML "</ul>"
    puts $file_toolkitsHTML "<hr size=\"1\">"
    puts $file_toolkitsHTML "</body>"
    puts $file_toolkitsHTML "</html>"
    close $file_toolkitsHTML
}

proc OCCTDoc_CreatePackageHTML {moduleName toolkitsList packagesListOfList} {
    global OCCTDoc_DocLocation
    if {[file exists $OCCTDoc_DocLocation/$moduleName/html/packages] == 0} {
	exec mkdir $OCCTDoc_DocLocation/$moduleName/html/packages
    }
    set file_packagesHTML [open $OCCTDoc_DocLocation/$moduleName/html/packages.html {CREAT TRUNC RDWR}]
    puts $file_packagesHTML "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">"
    puts $file_packagesHTML "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html;charset=iso-8859-1\">"
    puts $file_packagesHTML "<title>$moduleName: Packages</title>"
    puts $file_packagesHTML "<link href=\"doxygen.css\" rel=\"stylesheet\" type=\"text/css\">"
    puts $file_packagesHTML "</head><body>"
    puts $file_packagesHTML "<div class=\"qindex\"><a class=\"qindex\" href=\"../../index.html\">OCC&nbsp;Main&nbsp;Page</a> | <a class=\"qindex\" href=\"$moduleName\_index.html\">$moduleName</a> | <a class=\"qindex\" href=\"toolkits.html\">Toolkits</a> | <a class=\"qindexHL\" href=\"packages.html\">Packages</a> | <a class=\"qindex\" href=\"hierarchy.html\">Class&nbsp;Hierarchy</a> | <a class=\"qindex\" href=\"annotated.html\">Data&nbsp;Structures</a> | <a class=\"qindex\" href=\"files.html\">File&nbsp;List</a> | <a class=\"qindex\" href=\"functions.html\">Data&nbsp;Fields</a> | <a class=\"qindex\" href=\"globals.html\">Globals</a></div>"
    puts $file_packagesHTML "<h1>$moduleName<br>Packages</h1>"
    puts $file_packagesHTML "<hr size=\"1\">"
    puts $file_packagesHTML "<ul>"
    for {set indexOfList_1 0} {$indexOfList_1 < [llength $toolkitsList]} {incr indexOfList_1 1} {
	set toolkitName [lindex $toolkitsList $indexOfList_1]
	set packagesList [lindex $packagesListOfList $indexOfList_1]
	for {set indexOfList_2 0} {$indexOfList_2 < [llength $packagesList]} {incr indexOfList_2 1} {
	    set packageName [lindex $packagesList $indexOfList_2]
	    puts $file_packagesHTML "<li><a class=\"el\" href=\"packages/$packageName.html\">$packageName</a>"
	    OCCTDoc_ProcessPackagesHTML $moduleName $toolkitName $packageName
	}
    }
    puts $file_packagesHTML "</ul>"
    puts $file_packagesHTML "<hr size=\"1\">"
    puts $file_packagesHTML "</body>"
    puts $file_packagesHTML "</html>"
    close $file_packagesHTML
}

proc OCCTDoc_ProcessToolkitsHTML {moduleName toolkitName packagesList} {
    global OCCTDoc_DocLocation
    if {[file exists $OCCTDoc_DocLocation/$moduleName/html/toolkits] == 0} {
	exec mkdir $OCCTDoc_DocLocation/$moduleName/html/toolkits
    }
    set file_toolkitHTML [open $OCCTDoc_DocLocation/$moduleName/html/toolkits/$toolkitName.html {CREAT TRUNC RDWR}]
    puts $file_toolkitHTML "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">"
    puts $file_toolkitHTML "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html;charset=iso-8859-1\">"
    puts $file_toolkitHTML "<title>$moduleName: $toolkitName: Packages</title>"
    puts $file_toolkitHTML "<link href=\"../doxygen.css\" rel=\"stylesheet\" type=\"text/css\">"
    puts $file_toolkitHTML "</head><body>"
    puts $file_toolkitHTML "<div class=\"qindex\"><a class=\"qindex\" href=\"../../../index.html\">OCC&nbsp;Main&nbsp;Page</a> | <a class=\"qindex\" href=\"../$moduleName\_index.html\">$moduleName</a> | <a class=\"qindex\" href=\"../toolkits.html\">Toolkits</a> | <a class=\"qindex\" href=\"../packages.html\">Packages</a> | <a class=\"qindex\" href=\"../hierarchy.html\">Class&nbsp;Hierarchy</a> | <a class=\"qindex\" href=\"../annotated.html\">Data&nbsp;Structures</a> | <a class=\"qindex\" href=\"../files.html\">File&nbsp;List</a> | <a class=\"qindex\" href=\"../functions.html\">Data&nbsp;Fields</a> | <a class=\"qindex\" href=\"../globals.html\">Globals</a></div>"
    puts $file_toolkitHTML "<h1>$moduleName<br>$toolkitName<br>Packages</h1>"
    puts $file_toolkitHTML "<hr size=\"1\">"
    puts $file_toolkitHTML "<ul>"
    for {set indexOfList 0} {$indexOfList < [llength $packagesList]} {incr indexOfList 1} {
	set packageName [lindex $packagesList $indexOfList]
	puts $file_toolkitHTML "<li><a class=\"el\" href=\"../packages/$packageName.html\">$packageName</a>"
    }
    puts $file_toolkitHTML "</ul>"
    puts $file_toolkitHTML "<hr size=\"1\">"
    puts $file_toolkitHTML "</body>"
    puts $file_toolkitHTML "</html>"
    close $file_toolkitHTML
}

proc OCCTDoc_ProcessPackagesHTML {moduleName toolkitName packageName} {
    global OCCTDoc_DocLocation
    if {[file exists $OCCTDoc_DocLocation/$moduleName/html/packages] == 0} {
	exec mkdir $OCCTDoc_DocLocation/$moduleName/html/packages
    }
    set file_packageHTML [open $OCCTDoc_DocLocation/$moduleName/html/packages/$packageName.html {CREAT TRUNC RDWR}]
    puts $file_packageHTML "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">"
    puts $file_packageHTML "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html;charset=iso-8859-1\">"
    puts $file_packageHTML "<title>$moduleName: $toolkitName: $packageName: Classes</title>"
    puts $file_packageHTML "<link href=\"../doxygen.css\" rel=\"stylesheet\" type=\"text/css\">"
    puts $file_packageHTML "</head><body>"
    puts $file_packageHTML "<div class=\"qindex\"><a class=\"qindex\" href=\"../../../index.html\">OCC&nbsp;Main&nbsp;Page</a> | <a class=\"qindex\" href=\"../$moduleName\_index.html\">$moduleName</a> | <a class=\"qindex\" href=\"../toolkits.html\">Toolkits</a> | <a class=\"qindex\" href=\"../packages.html\">Packages</a> | <a class=\"qindex\" href=\"../hierarchy.html\">Class&nbsp;Hierarchy</a> | <a class=\"qindex\" href=\"../annotated.html\">Data&nbsp;Structures</a> | <a class=\"qindex\" href=\"../files.html\">File&nbsp;List</a> | <a class=\"qindex\" href=\"../functions.html\">Data&nbsp;Fields</a> | <a class=\"qindex\" href=\"../globals.html\">Globals</a></div>"
    puts $file_packageHTML "<h1>$moduleName<br><a href=\"../toolkits/$toolkitName.html\">$toolkitName</a><br>$packageName<br>Classes</h1>"
    puts $file_packageHTML "<hr size=\"1\">"
    puts $file_packageHTML "<ul>"
    set linksList {}
    if {[file exists $OCCTDoc_DocLocation/$moduleName/html/hierarchy.html] == 1} {
	set file_hierarchyHTML [open $OCCTDoc_DocLocation/$moduleName/html/hierarchy.html RDONLY]
	while {[eof $file_hierarchyHTML] == 0} {
	    set hierarchyLine [string trim [gets $file_hierarchyHTML]]
	    if {[string compare [string range $hierarchyLine 0 12] "<li><a class="] == 0} {
		if {[regexp $packageName $hierarchyLine] == 1} {
		    set className [string trim [string range $hierarchyLine 0 [expr {[string last < $hierarchyLine] - 1}]]]
		    set className [string trim [string range $className [expr {[string last > $className] + 1}] [string length $className]]]
		    set packageClassName [string trim [string range $className 0 [expr {[string first _ $className] - 1}]]]
		    if {[string compare $packageName $packageClassName] == 0} {
			set linkPath [string trim [string range $hierarchyLine 0 [expr {[string last \" $hierarchyLine] - 1}]]]
			set linkPath [string trim [ string range $linkPath [expr {[string last \" $linkPath] + 1}] [string length $linkPath]]]
			if {[string length $className] != 0} {
			    lappend linksList $className
			    OCCTDoc_UpdateClassDescriptionFile $linkPath $moduleName $toolkitName $packageName
			    puts $file_packageHTML "<li><a class=\"el\" href=\"../$linkPath\">$className</a>"
			}
		    }
		}
	    }
	}
	close $file_hierarchyHTML
    }
    puts $file_packageHTML "</ul>"
    puts $file_packageHTML "</ul>"
    puts $file_packageHTML "<hr size=\"1\">"
    puts $file_packageHTML "</body>"
    puts $file_packageHTML "</html>"
    close $file_packageHTML
}

proc OCCTDoc_UpdateClassDescriptionFile {pathToFile moduleName toolkitName packageName} {
    global OCCTDoc_DocLocation
    set updatedPath [string trim $pathToFile]
    set backPath ""
    set empty 0
    while {$empty == 0} {
	set positionNumber [string first / $updatedPath]
	if {$positionNumber == -1} {
	    break
	} else {
	    append backPath "../"
	    set updatedPath [string trim [string range $updatedPath [expr {$positionNumber + 1}] [string length $updatedPath]]]
	}
    }
    set file_ClassHTML_old "$OCCTDoc_DocLocation/$moduleName/html/$pathToFile.old"
    set file_ClassHTML_new "$OCCTDoc_DocLocation/$moduleName/html/$pathToFile"
    if {[file exists $file_ClassHTML_new] == 1} {
	exec cp $file_ClassHTML_new $file_ClassHTML_old
	set isLineWrited 0
	set file_classHTML_new [open $file_ClassHTML_new {RDWR TRUNC}]
	set file_classHTML_old [open $file_ClassHTML_old RDONLY]
	while {[eof $file_classHTML_old] == 0} {
	    set classLine [string trim [gets $file_classHTML_old]]
	    if {[string compare [string range $classLine 0 6] "<div cl"] == 0} {
		if {$isLineWrited == 0} {
#		    puts $file_classHTML_new "<div class=\"qindex\"><a class=\"qindex\" href=\"../../$backPath\index.html\">OCC&nbsp;Main&nbsp;Page</a> | <a class=\"qindex\" href=\"$backPath$moduleName\_index.html\">$moduleName</a> | <a class=\"qindex\" href=\"$backPath\toolkits.html\">Toolkits</a> | <a class=\"qindex\" href=\"$backPath\packages.html\">Packages</a> | <a class=\"qindex\" href=\"$backPath\hierarchy.html\">Class&nbsp;Hierarchy</a> | <a class=\"qindex\" href=\"$backPath\\annotated.html\">Data&nbsp;Structures</a> | <a class=\"qindex\" href=\"$backPath\\files.html\">File&nbsp;List</a> | <a class=\"qindex\" href=\"$backPath\\functions.html\">Data&nbsp;Fields</a> | <a class=\"qindex\" href=\"$backPath\globals.html\">Globals</a></div>"
		    puts $file_classHTML_new "<div class=\"qindex\"><a class=\"qindex\" href=\"../../index.html\">OCC&nbsp;Main&nbsp;Page</a> | <a class=\"qindex\" href=\"$moduleName\_index.html\">$moduleName</a> | <a class=\"qindex\" href=\"toolkits.html\">Toolkits</a> | <a class=\"qindex\" href=\"packages.html\">Packages</a> | <a class=\"qindex\" href=\"hierarchy.html\">Class&nbsp;Hierarchy</a> | <a class=\"qindex\" href=\"annotated.html\">Data&nbsp;Structures</a> | <a class=\"qindex\" href=\"files.html\">File&nbsp;List</a> | <a class=\"qindex\" href=\"functions.html\">Data&nbsp;Fields</a> | <a class=\"qindex\" href=\"globals.html\">Globals</a></div>"
		    puts $file_classHTML_new "<h1>$moduleName<br><a href=\"toolkits/$toolkitName.html\">$toolkitName</a><br><a href=\"packages/$packageName.html\">$packageName</a></h1>"
		    puts $file_classHTML_new "<hr size=\"1\">"
		    set isLineWrited 1
		} else {
		    puts $file_classHTML_new $classLine
		}
	    } else {
		puts $file_classHTML_new $classLine
	    }
	}
	close $file_classHTML_old
	close $file_classHTML_new
    } else {
	puts "$file_ClassHTML_new is absent"
    }
}
