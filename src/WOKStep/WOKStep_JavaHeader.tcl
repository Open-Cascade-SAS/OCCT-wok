
proc WOKStep_JavaHeader:AdmFileType {} {
    
    return dbadmfile;
}

proc WOKStep_JavaHeader:OutputDirTypeName {} {
    return dbtmpdir;
}

proc WOKStep_JavaHeader:HandleInputFile { ID } {

    scan $ID "%\[^:\]:%\[^:\]:%\[^:\]"  unit type name
    
    if {[file extension $name] == ".java"} {
	    return 1;
    } 
    return 0;
}

proc WOKStep_JavaHeader:ComputeIncludeDir { unit } {
    
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
	}
    }
    return $result
}

proc WOKStep_JavaHeader:Execute { theunit args } {

    msgprint -i -c "WOKStep_JavaHeader::Execute" "Processing unit : $theunit"
    msgprint -i -c "WOKStep_JavaHeader::Execute"

    set unitname [wokinfo -n $theunit]
    set failed 0
    set incdir [WOKStep_JavaHeader:ComputeIncludeDir $theunit]
    wokparam -s%IncludeDir=$incdir

    foreach ID $args {
	scan $ID "%\[^:\]:%\[^:\]:%\[^:\]"  unit type name
	set infile [woklocate -p $ID]
	
	set outfileid [file rootname $name]
	wokparam -s%Class=${unitname}.$outfileid
	set outfileid ${unitname}_${outfileid}.h
	set outfile [wokinfo -p pubinclude:$outfileid $theunit]
	wokparam -s%OutFile=$outfile

	set thecommand [wokparam -e JAVA_Header]
	
	msgprint -i -c "WOKStep_JavaCompile::Execute" "Building header $outfileid"
	if {[catch {eval exec [lindex $thecommand 0]} res]} {
	    msgprint -e -c "WOKStep_JavaCompile::Execute" $res
	    set failed 1
	} else {
	    stepoutputadd $unitname:pubinclude:$outfileid
	    stepaddexecdepitem $ID $unitname:pubinclude:$outfileid
	}
    }
    
    return $failed
}
