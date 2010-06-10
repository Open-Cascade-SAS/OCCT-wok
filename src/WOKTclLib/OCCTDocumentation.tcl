
# generate Doxygen configuration file for specified OCCT module of toolkit
proc OCCDoc_MakeDoxyfile {outDir {modules {}} {graphvizPath {}} {useSearch YES} {tagFiles {}}} {

    # by default take all modules
    if { [llength $modules] <= 0 } {
	set modules [OS -lm]
    }

    # create target directory
    if { ! [file exists $outDir] } {
	mkdir $outDir
    }
 
    # set context
    set one_module [expr [llength $modules] == 1]
    if { $one_module } {
	set title "OCCT [$modules:name]"
	set name $modules
    } else {
	set title "Open CASCADE Technology"
	set name OCCT
    }

    # get list of header files in the specified modules
    set filelist {}
    foreach module $modules {
	if {[lsearch [OS -lm] $module] == -1 } {
	    puts "Error: no module $module is known in current workbench"
	    continue
	}
	foreach tk [$module:toolkits] {
	    foreach pk [osutils:tk:units [woklocate -u $tk]] {
		lappend filelist [uinfo -p -T pubinclude $pk]
	    }
	}
    } 

    # filter out files Handle_*.hxx and *.lxx
    set hdrlist {}
    foreach fileset $filelist {
        set hdrset {}
        foreach hdr $fileset {
	    if { ! [regexp {Handle_.*[.]hxx} $hdr] && ! [regexp {.*[.]lxx} $hdr] } {
		lappend hdrset $hdr
	    }
	}
	lappend hdrlist $hdrset
    }
    set filelist $hdrlist

    # get OCCT version number
    set occt_version ""
    set verfile [woklocate -p "Standard:source:Standard_Version.hxx"]
    if { "$verfile" != "" && [file readable $verfile] } {
	set vfd [open $verfile "r"]
	set vmajor ""
	set vminor ""
	set vpatch ""
	set vbuild ""
	while { [gets $vfd line] >= 0 } {
	    if { [regexp {^[ \t]*\#define[ \t]*OCC_VERSION_MAJOR[ \t]*([0-9]+)} $line str num] } {
		set vmajor $num
	    } elseif { [regexp {^[ \t]*\#define[ \t]*OCC_VERSION_MINOR[ \t]*([0-9]+)} $line str num] } {
		set vminor $num
	    } elseif { [regexp {^[ \t]*\#define[ \t]*OCC_VERSION_MAINTENANCE[ \t]*([0-9]+)} $line str num] ||
                        [regexp {^[ \t]*\#define[ \t]*OCC_VERSION_PATCH[ \t]*([0-9]+)} $line str num] } {
		set vpatch $num
	    } elseif { [regexp {^[ \t]*\#define[ \t]*OCC_VERSION_BUILD[ \t]*([0-9]+)} $line str num] } {
		set vbuild .$num
	    }
	}
	close $vfd
        set occt_version $vmajor.$vminor.$vpatch$vbuild
    }

    set filename "$outDir/$name.Doxyfile"
    msgprint -i -c "WOKStep_DocGenerate:Execute" "Generating Doxygen file for $title in $filename"
    set fileid [open $filename "w"]

    set path_prefix "$outDir/"

    puts $fileid "PROJECT_NAME = \"$title\""
    puts $fileid "PROJECT_NUMBER = $occt_version "
    puts $fileid "OUTPUT_DIRECTORY = ${path_prefix}."
    puts $fileid "CREATE_SUBDIRS   = NO"
    puts $fileid "OUTPUT_LANGUAGE  = English"
    puts $fileid "MULTILINE_CPP_IS_BRIEF = YES"
    puts $fileid "INHERIT_DOCS           = YES"
    puts $fileid "REPEAT_BRIEF           = NO"
    puts $fileid "ALWAYS_DETAILED_SEC    = NO"
    puts $fileid "INLINE_INHERITED_MEMB  = NO"
    puts $fileid "FULL_PATH_NAMES        = NO"
    puts $fileid "OPTIMIZE_OUTPUT_FOR_C  = YES"
    puts $fileid "SUBGROUPING      = YES"
    puts $fileid "DISTRIBUTE_GROUP_DOC   = YES"
    puts $fileid "EXTRACT_ALL	= YES"
    puts $fileid "EXTRACT_PRIVATE	= NO"
    puts $fileid "EXTRACT_LOCAL_CLASSES = NO"
    puts $fileid "EXTRACT_LOCAL_METHODS = NO"
    puts $fileid "HIDE_FRIEND_COMPOUNDS = YES"
    puts $fileid "HIDE_UNDOC_MEMBERS = NO"
    puts $fileid "INLINE_INFO = YES"
    puts $fileid "SHOW_DIRECTORIES	= NO"
    puts $fileid "VERBATIM_HEADERS = NO"
    puts $fileid "QUIET		= YES"
    puts $fileid "WARNINGS		= NO"
    puts $fileid "ENABLE_PREPROCESSING = YES"
    puts $fileid "MACRO_EXPANSION = YES"
    puts $fileid "EXPAND_ONLY_PREDEF = YES"
    puts $fileid "PREDEFINED = Standard_EXPORT __Standard_API __Draw_API Handle(a):=Handle<a>"
    puts $fileid "GENERATE_HTML	= YES"
    puts $fileid "GENERATE_LATEX   = NO"
    puts $fileid "SEARCH_INCLUDES  = YES"
    puts $fileid "GENERATE_TAGFILE = ${path_prefix}${name}.tag"
    puts $fileid "ALLEXTERNALS = NO"
    puts $fileid "EXTERNAL_GROUPS = NO"
    
    # add tag files for OCCT modules (except current one and depending);
    # this is based on file Modules.tcl in unit "OS" which defines list of modules
    # in the order of their dependency
    if { [llength $tagFiles] > 0 } {
	set tagdef {}
	foreach tagfile $tagFiles {
	    if [file exists ${path_prefix}$tagname.tag] {
		set tagdef "$tagdef \\\n           ${path_prefix}${tagname}.tag=../../${tagname}/html"
	    }
	}
	puts $fileid "TAGFILES = $tagdef"
    }

    if { $useSearch } {
	puts $fileid "SEARCHENGINE     = $useSearch"
#	puts $fileid "SERVER_BASED_SEARCH = NO"
    }
    if { "$graphvizPath" == "" && [info exists env(GRAPHVIZ_HOME)] } {
	set graphvizPath $env(GRAPHVIZ_HOME)
    }
    if { "$graphvizPath" != "" } {
	puts $fileid "HAVE_DOT		= YES"
	puts $fileid "DOT_PATH		= $graphvizPath"
    } else {
	puts "Warning: DOT is not found; use environment variable GRAPHVIZ_HOME or command argument to specify its location"
	puts $fileid "HAVE_DOT		= NO"
	puts $fileid "DOT_PATH		= "
    }

    puts $fileid "COLLABORATION_GRAPH = NO"
    puts $fileid "ENABLE_PREPROCESSING = YES"
    puts $fileid "INCLUDE_FILE_PATTERNS = *.hxx *.pxx"
    puts $fileid "EXCLUDE_PATTERNS = */Handle_*.hxx"
    puts $fileid "SKIP_FUNCTION_MACROS = YES"
    puts $fileid "INCLUDE_GRAPH = NO"
    puts $fileid "INCLUDED_BY_GRAPH = NO"
    puts $fileid "DOT_MULTI_TARGETS = YES"
    puts $fileid "DOT_IMAGE_FORMAT = png"
    puts $fileid "INLINE_SOURCES   = NO"

    # include dirs
    set incdirs ""
    foreach wb [w_info -A] {
	set incdirs "$incdirs [wokparam -v %${wb}_Home]/inc"
    }
    puts $fileid "INCLUDE_PATH = $incdirs"

    # list of files to generate
    set mainpage [OCCDoc_MakeMainPage $outDir/$name.dox $modules]
    puts $fileid "INPUT		= $mainpage \\"
    foreach header $filelist {
	puts $fileid "               $header \\"
    } 
    puts $fileid ""

    close $fileid

    return $filename
}

# generate main page file describing module structure
proc OCCDoc_MakeMainPage {outFile modules} {
    set one_module [expr [llength $modules] == 1]

    set fd [open $outFile "w"]

    # main page: list of modules
    if { ! $one_module } {
	puts $fd "/**"
	puts $fd "\\mainpage Open CASCADE Technology"
	foreach mod $modules {
	    puts $fd "\\li \\subpage [string tolower module_$mod]"
	}
	puts $fd "**/\n"
    }

    # one page per module: list of toolkits
    set toolkits {}
    foreach mod $modules {
        puts $fd "/**"
	if { $one_module } {
	    puts $fd "\\mainpage OCCT Module [$mod:name]"
	} else {
	    puts $fd "\\page [string tolower module_$mod] Module [$mod:name]"
	}
	foreach tk [lsort [$mod:toolkits]] {
	    lappend toolkits $tk
	    puts $fd "\\li \\subpage [string tolower toolkit_$tk]"
	}
        puts $fd "**/\n"
    }

    # one page per toolkit: list of packages
    set packages {}
    foreach tk $toolkits {
        puts $fd "/**"
	puts $fd "\\page [string tolower toolkit_$tk] Toolkit $tk"
	foreach pk [lsort [osutils:tk:units [woklocate -u $tk]]] {
	    lappend packages $pk
	    set u [wokinfo -n $pk]
	    puts $fd "\\li \\subpage [string tolower package_$u]"
	}
	puts $fd "**/\n"
    }

    # one page per package: list of classes
    foreach pk $packages {
	set u [wokinfo -n $pk]
        puts $fd "/**"
	puts $fd "\\page [string tolower package_$u] Package $u"
	foreach hdr [lsort [uinfo -f -T pubinclude $pk]] {
	    if { ! [regexp {^Handle_} $hdr] && [regexp {(.*)[.]hxx} $hdr str obj] } {
		puts $fd "\\li \\subpage $obj"
	    }
	}
	puts $fd "**/\n"
    }

    # one page per class: set reference to package
#    foreach pk $packages {
#	set u [wokinfo -n $pk]
#	foreach hdr [uinfo -f -T pubinclude $pk] {
#	    if { ! [regexp {^Handle_} $hdr] && [regexp {(.*)[.]hxx} $hdr str obj] } {
#		puts $fd "/**"
#		puts $fd "\\class $obj"
#		puts $fd "Contained in \\ref [string tolower package_$u]"
##		puts $fd "\\addtogroup package_$u"
#		puts $fd "**/\n"
#	    }
#	}
#    }

    close $fd
    return $outFile
}
