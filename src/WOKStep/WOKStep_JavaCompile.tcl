
proc WOKStep_JavaCompile:AdmFileType {} {
    
    return dbadmfile;
}

proc WOKStep_JavaCompile:OutputDirTypeName {} {
    return dbtmpdir;
}

proc WOKStep_JavaCompile:HandleInputFile { ID } {
    
    scan $ID "%\[^:\]:%\[^:\]:%\[^:\]"  unit type name
    
    if {[file extension $name] == ".java"} {
	return 1;
    } 
    return 0;
}

proc WOKStep_JavaCompile:ComputeIncludeDir { unit } {
    
    set allwb [w_info -A $unit]
    set unitname [wokinfo -n $unit]
    set result ""
    
    set themax [llength $allwb]
    
    for {set i $themax} {[expr $i != 0]} {incr i -1} {
	set awb [lindex $allwb [expr $i - 1]]
	if {![wokinfo -x ${awb}:$unitname]} {
	    set pseudounit [lindex [w_info -l $awb] 0]
	    set addinc [wokinfo -p derivated:.. ${awb}:$pseudounit]
	    set result ${addinc}:$result
	} else {
	    set addinc [wokinfo -p derivated:.. ${awb}:$unitname]
	    set result ${addinc}:$result
	    set addinc [wokinfo -p source:. ${awb}:$unitname]
	    set result ${addinc}:$result
	}
    }
    return $result
}

proc WOKStep_JavaCompile:Execute { theunit args } {
    
    msgprint -i -c "WOKStep_JavaCompile::Execute" "Processing unit : $theunit"
    msgprint -i -c "WOKStep_JavaCompile::Execute"
    
    set unitname [wokinfo -n $theunit]
    set failed 0
    set incdir [WOKStep_JavaCompile:ComputeIncludeDir $theunit]
    wokparam -s%IncludeDir=$incdir
    set outdir [wokinfo -p derivated:.. $theunit]
    wokparam -s%OutDir=$outdir

    foreach ID $args {
	scan $ID "%\[^:\]:%\[^:\]:%\[^:\]"  unit type name
	set infile [woklocate -p $ID]
	wokparam -s%Source=$infile
	set thecommand [wokparam -e JAVA_Compiler]
	
	set outfileid [file rootname $name]
	set outfileid ${outfileid}.class
	
	msgprint -i -c "WOKStep_JavaCompile::Execute" "Compiling $name"
	if {[catch {eval exec [lindex $thecommand 0]} res]} {
	    msgprint -e -c "WOKStep_JavaCompile::Execute" $res
	    set failed 1
	} else {
	    stepoutputadd $unitname:derivated:$outfileid
	    stepaddexecdepitem $ID $unitname:derivated:$outfileid
	}
    }
    
    return $failed
}
