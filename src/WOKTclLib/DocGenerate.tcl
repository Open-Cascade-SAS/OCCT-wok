

proc DocGenerate {theModule outDir} {

 global tcl_platform
 global env
 source [woklocate -p OS:source:OS.tcl]
 set filelist {}
 if {[lsearch [OS -lm] $theModule] != -1 } {
   set entity "module"
   foreach tk [$theModule:toolkits] {
       foreach pk [osutils:tk:units $tk] {
	   lappend filelist [uinfo -p -T pubinclude $pk]
       }
   }
 } else { 
    if {[lsearch [w_info -l] $theModule] != -1} {
      if {[uinfo -c $theModule] == "p"} {
        set entity "package"
        lappend filelist [uinfo -p -T pubinclude $theModule]
      } elseif {[uinfo -c $theModule] == "t"} {
          set entity "toolkit"
          foreach pk [osutils:tk:units $theModule] {
  	    lappend filelist [uinfo -p -T pubinclude $pk]
          }
      }
    } else {
         msgprint -e -c "WOKStep_DocGenerate:Execute" "Entity $theModule is unknown or unsupported. Choose among [OS -lm] or [w_info -l]"
         return 0
      } 
   } 
 if {$tcl_platform == "windows"} {
    set filename "$env(TMP)/Doxybuffer"
 } else {
    set filename "/tmp/Doxybuffer"
 }
 set fileid [open $filename "w"]
 set failed 0

 puts $fileid "PROJECT_NAME 	= Open CASCADE"
 puts $fileid "OUTPUT_DIRECTORY = $outDir/${theModule}"
 puts $fileid "CREATE_SUBDIRS   = YES"
 puts $fileid "OUTPUT_LANGUAGE  = English"
 puts $fileid "DETAILS_AT_TOP   = YES"
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
 puts $fileid "EXTRACT_PRIVATE	= YES"
 puts $fileid "EXTRACT_LOCAL_CLASSES = NO"
 puts $fileid "EXTRACT_LOCAL_METHODS = NO"
 puts $fileid "HIDE_FRIEND_COMPOUNDS = YES"
 puts $fileid "HIDE_UNDOC_MEMBERS = NO"
 puts $fileid "BRIEF_MEMBER_DESCR = NO"
 puts $fileid "INLINE_INFO = YES"
 puts $fileid "SHOW_DIRECTORIES	= NO"
 puts $fileid "VERBATIM_HEADERS = NO"
 puts $fileid "QUIET		= YES"
 puts $fileid "WARNINGS		= NO"
 puts $fileid "ENABLE_PREPROCESSING = YES"
 puts $fileid "GENERATE_HTML	= YES"
 puts $fileid "GENERATE_LATEX   = NO"
 puts $fileid "SEARCH_INCLUDES  = YES"
 puts $fileid "GENERATE_TAGFILE = $outDir/${theModule}.tag"
 puts $fileid "HAVE_DOT		= YES"
 puts $fileid "DOT_PATH		= [wokparam -v %CSF_GRAPHVIZ_HOME]"
 puts $fileid "COLLABORATION_GRAPH = NO"
 puts $fileid "ENABLE_PREPROCESSING = YES"
 puts $fileid "INCLUDE_FILE_PATTERNS = *.hxx *.pxx"
 puts $fileid "EXCLUDE_PATTERNS = Handle_*.hxx"
 puts $fileid "SKIP_FUNCTION_MACROS = YES"
 puts $fileid "INCLUDE_GRAPH = NO"
 puts $fileid "INCLUDED_BY_GRAPH = NO"
 puts $fileid "GROUP_GRAPH	= YES"
 puts $fileid "DOT_MULTI_TARGETS = YES"
 puts $fileid "DOT_IMAGE_FORMAT = png"
 puts $fileid "INLINE_SOURCES   = NO"
 puts $fileid "INPUT		= [wokparam -v %[wokinfo -n [wokinfo -w]]_Home]/inc"
 puts $fileid "FILE_PATTERNS	= \\"
 foreach ID $filelist {
     puts $fileid "               $ID \\"
 }   
 close $fileid
 msgprint -i -c "WOKStep_DocGenerate:Execute" "Processing $entity : $theModule. Writting to $outDir "
 catch {eval exec [lindex [wokparam -v %CSF_DOXIGEN] 0] $filename}
 return $failed
}
