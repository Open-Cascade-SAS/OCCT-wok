

proc wcd { args } {
    if { [llength $args] !=0 } {
	wokcd -PSrc $args
    } else {
	puts stdout {Usage: wcd  <unit>}
	foreach u [w_info -l] {
	    puts $u
	}
    }
    return

}

proc wsrc {{entity ""}} {
    if { $entity != "" } { wokcd -Tsource $entity } {wokcd -Tsource}
}

proc wdrv {{entity ""}} {
    if { $entity != "" } { wokcd -Tderivated $entity } {wokcd -Tderivated}
}

proc wlib {{entity ""}} {
    if { $entity != "" } { wokcd -Tlibrary $entity } {wokcd -Tlibrary}
}

proc wbin {{entity ""}} {
    if { $entity != "" } { wokcd -Texecutable $entity } {wokcd -Texecutable}
}
proc wobj {{entity ""}} {
    if { $entity != "" } { wokcd -Tobject $entity } {wokcd -Tobject}
}
proc winc {{entity ""}} {
    if { $entity != "" } { wokcd -Tpubinclude $entity } {wokcd -Tpubinclude}
}
proc wadm {{entity ""}} {
    if { $entity != "" } { wokcd -Tadmfile $entity } {wokcd -Tadmfile}
}


proc wls { args } {
    set f [lsearch -regexp $args {-[pniCtexscfOrd]} ]
    if { $f != -1 } {
	set ft [lindex [split [lindex $args $f] -] 1]
	set lx {}
	set len [string length $ft]
	foreach cc [ucreate -P] {
	    set SLONG([lindex $cc 0]) [lindex $cc 1]
	}

	for {set i 0} {$i < $len} {incr i 1} {
	    set x [string index $ft $i]
	    if [info exists SLONG($x)] {
		lappend lx $SLONG($x)
	    }
	}

	foreach ud [lsort [w_info -a]] {
	    if { [lsearch $lx [lindex $ud 0]] != -1 } {
		puts [lindex $ud 1]
	    }
	}
    } else {
	set l [lsearch -regexp $args {-l}]
	if { $l == -1 } {
	    set retargs $args
	    set act {w_info -l}
	} else {
	    set retargs [lreplace $args $l $l]
	    set act {w_info -a}
	}
	foreach ff [lsort [eval $act $retargs]] {
	    puts $ff
	}
    }
}



