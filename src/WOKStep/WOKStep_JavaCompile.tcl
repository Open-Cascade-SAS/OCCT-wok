proc WOKStep_JavaCompile:AdmFileType {} {
    
 return dbadmfile;

}

proc WOKStep_JavaCompile:OutputDirTypeName {} {

 return dbtmpdir;

}

proc WOKStep_JavaCompile:HandleInputFile { ID } {
    
 scan $ID "%\[^:\]:%\[^:\]:%\[^:\]"  unit type name
    
 if { [file extension $name] == ".java" } {

  return 1;

 } 

 return 0;

}

proc WOKStep_JavaCompile:ComputeIncludeDir { unit } {

 global env
 global tcl_platform

 if { $tcl_platform(platform) == "windows" } {
  set ps "\\;"
 } else {
  set ps ":"
 }

 set fJava [info exists env(WOK_USE_JAVA_DIRECTORY)]
    
 set allwb [w_info -A $unit]
 set unitname [wokinfo -n $unit]
 set result ""
    
 set themax [llength $allwb]
 for { set i $themax } { [expr $i != 0] } { incr i -1 } {
  set awb [lindex $allwb [expr $i - 1]]
  if { $fJava } {
   set addinc [wokparam -e WOKEntity_javadir ${awb}]
  } else {
   set addinc [wokparam -e WOKEntity_drvdir ${awb}]
  }

  set result ${addinc}$ps$result

 }

 set result $env(WOKHOME)$ps$result

 return $result

}

proc WOKStep_JavaCompile:Execute { theunit args } {

 global env
 global tcl_platform
    
 msgprint -i -c "WOKStep_JavaCompile:Execute" "Processing unit : $theunit"
 msgprint -i -c "WOKStep_JavaCompile:Execute"
    
 set fJava [info exists env(WOK_USE_JAVA_DIRECTORY)]

 set unitname [wokinfo -n $theunit]
 set failed 0
 set incdir [WOKStep_JavaCompile:ComputeIncludeDir $theunit]
 wokparam -s%IncludeDir=$incdir

 if { $fJava } {
  set outdir [wokUtils:EASY:stobs2 [wokparam -e WOKEntity_javadir [wokinfo -w]]]
 } else {
  set outdir [wokUtils:EASY:stobs2 [[wokparam -e WOKEntity_drvdir [wokinfo -w]]]
 }

 wokparam -s%OutDir=$outdir

 foreach ID $args {

  scan $ID "%\[^:\]:%\[^:\]:%\[^:\]"  unit type name
  set infile [wokUtils:EASY:stobs2 [woklocate -p $ID]]

  if { $tcl_platform(platform) == "windows" } {
   regsub -all "/" $infile "\\\\\\" infile
  }

  wokparam -s%Source=$infile
  set thecommand [wokparam -e JAVA_Compiler]
  set outfileid [file rootname $name]
  set outfileid ${outfileid}.class
	
  msgprint -i -c "WOKStep_JavaCompile:Execute" "Compiling $name"

  if { [catch {eval exec [lindex $thecommand 0]} res] } {
   msgprint -e -c "WOKStep_JavaCompile:Execute" $res
   set failed 1

  } else {

   if { $fJava } {
    stepoutputadd $unitname:javafile:$outfileid
    stepaddexecdepitem $ID $unitname:javafile:$outfileid
   } else {
    stepoutputadd $unitname:derivated:$outfileid
    stepaddexecdepitem $ID $unitname:derivated:$outfileid
   }

  }

 }
    
 return $failed

}
