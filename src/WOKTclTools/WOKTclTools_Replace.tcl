

proc WOKTclTools_Replace:AdmFileType {} {
    return "dbadmfile";
}

proc WOKTclTools_Replace:OutputDirTypeName {} {
    return "dbtmpfile";
}


proc WOKTclTools_Replace:HandleInputFile { ID } { 

    scan $ID "%\[^:\]:%\[^:\]:%\[^:\]"  unit type name

    switch $name {
	WOKTclTools_Interpretor.hxx {return 1;}
	default {
	    return 0;
	}
    }
}

proc WOKTclTools_Replace:Execute { unit args } {
    
    global tcl_interactive

    set tcl_interactive 1
    package require Wokutils

    msgprint -i -c "WOKTclTools_Replace::Execute" "Copying of WOKTclTools includes"

    if { [wokparam -e %Station $unit] != "wnt" } {
	set copycmd "cp -p "
	set replstr "/"
    } {
	set copycmd "cmd /c copy"
	set replstr "\\\\\\\\"
    }
    
    foreach file  $args {
	scan $file "%\[^:\]:%\[^:\]:%\[^:\]"  Unit type name
	
	regsub ".hxx" $name "_proto.hxx" sourcename

	set source    [woklocate -p WOKTclTools:source:$sourcename     [wokinfo -N $unit]]
	set vistarget [woklocate -p WOKTclTools:pubinclude:$name [wokinfo -N $unit]]
	set target    [wokinfo   -p pubinclude:$name          $unit]

	regsub -all "/" " $source $target" $replstr  TheArgs

        if { [file exist $target] } {
	  set A [catch {eval "wokcmp $TheArgs"} result ]
        } else {
          set result 0 }
	
	if { ! $result } {
	    msgprint -i -c "WOKTclTools_Replace::Execute" "Copy $source to $target"
	    if { [file exist $target] && [wokparam -e %Station $unit] != "wnt" } {
		eval exec "chmod u+w $target"
	    }
	    eval exec "$copycmd $TheArgs"
	} else {
	    msgprint -i -c "WOKTclTools_Replace::Execute" "No change in $source"
	}
    }
    return 0;
}
