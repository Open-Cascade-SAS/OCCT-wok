proc CDLFront_Replace:AdmFileType {} {
    return "dbadmfile";
}

proc CDLFront_Replace:OutputDirTypeName {} {
    return "dbtmpfile";
}


proc CDLFront_Replace:HandleInputFile { ID } { 

    scan $ID "%\[^:\]:%\[^:\]:%\[^:\]"  unit type name
    
    switch $name {
         CDL.tab.c  {return 1;} 
	default {
	    return 0;
	}
    }
}

proc CDLFront_Replace:Execute { unit args } {
    
    msgprint -i -c "CDLFront_Replace::Execute" "Copying of CDLFront derivated files  $unit $args "

    global tcl_interactive

    set tcl_interactive 1
    package require Wokutils


    if { [wokparam -e %Station $unit] != "wnt" } {
	set copycmd "cp -p "
	set replstr "/"
    } else {
	set copycmd "cmd /c copy"
	set replstr "\\\\\\\\"
    }
    

	set sourcename CDL.tab.c
	set name       CDL.tab.c

	set source    [woklocate -p CDLFront:source:$sourcename     [wokinfo -N $unit]]
	set vistarget [woklocate -p CDLFront:privinclude:$name [wokinfo -N $unit]]
#	set target    [wokinfo   -p CDLFront:privinclude:$name [wokinfo -N $unit]]
msgprint -i -c "$source "
	regsub -all "/" " $source $vistarget" $replstr  TheArgs

        if { [file exist $vistarget] } {
	  set A [catch {eval "wokcmp $TheArgs"} result ]
        } else {
          set result 0 }
	
	if { ! $result } {
	    msgprint -i -c "CDLFront_Replace::Execute" "Copy $source to $vistarget"
	    if { [file exist $vistarget] && [wokparam -e %Station ] != "wnt" } {
		eval exec "chmod u+w $vistarget"
	    }
	    eval exec "$copycmd $TheArgs"
	} else {
	    msgprint -i -c "CDLFront_Replace::Execute" "No change in $source"
	}

    return 0;
}



