


proc WOKStep_TclLibIdep:AdmFileType {} {
    return "stadmfile";
}

proc WOKStep_TclLibIdep:OutputDirTypeName {} {
    return "sttmpfile";
}


proc WOKStep_TclLibIdep:HandleInputFile { ID } { 
    
    scan $ID "%\[^:\]:%\[^:\]:%\[^:\]"  unit type name
    if {$name == "PACKAGES"} {
	return 1
    }
    
    return 0
}

proc WOKStep_TclLibIdep:Execute { unit args } {

    msgprint -i -c "WOKStep_TclLibIdep:Execute" "Build ImplDep"

    set unitname [wokinfo -n $unit]

    set file [lindex $args 0]
    scan $file "%\[^:\]:%\[^:\]:%\[^:\]"  Unit type name
    set packfile [woklocate -p $file $unit]
    
    if {[clength $packfile] == 0} {
	msgprint -e -c "WOKStep_TclLibIdep:Execute" "Could not locate PACKAGES for unit $unit"
	return 1;
    } else {
	for_file anud $packfile {
	    set curud [string trim $anud]
	    if {$curud != ""} {	
		set alluds($curud) 1
		set impin [woklocate -p ${curud}:stadmfile:${curud}.ImplDep]
		if {[clength $impin] == 0} {
		    msgprint -i "No ImplDep file for unit $curud"
		} else {
		    for_file adep $impin {
			set curud [string trim $adep]
			set alluds($curud) 1
		    }
		}
	    }
	}
# remove PACKAGES content from ImplDep
	for_file anud $packfile {
	    set curud [string trim $anud]
	    if {$curud != ""} {	
		unset alluds($curud)
	    }
	}
	set impfile [wokinfo -p stadmfile:${unitname}.ImplDep $unit]
	set impid [open $impfile "w"]
	for_array_keys anud alluds {
	    puts $impid $anud
        }
	close $impid
	stepoutputadd ${unitname}:stadmfile:${unitname}.ImplDep
	stepaddexecdepitem -d $file ${unitname}:stadmfile:${unitname}.ImplDep
    }
    return 0;
}
