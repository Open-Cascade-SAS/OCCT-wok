proc pinstallUsage {} {
    puts stderr { usage : pinstall parcelname }
}

proc pinstall {args} {

    set tblreq(-h) {}
    set param {}

    if { [wokUtils:EASY:GETOPT param table tblreq pinstallUsage $args] == -1 } return
    
    if { [info exists table(-h)] } {
	pinstallUsage
	return
    }

    set ULNAME [lindex $param 0]
    if { $ULNAME == {} } {
	pinstallUsage
	return
    }

    set thefact [Sinfo -f]
    set theware [finfo -W $thefact]
    puts "Installing $ULNAME from Warehouse ${thefact}:${theware}"
    wokcd ${thefact}:${theware}
    wokcd $ULNAME
    set theullibdir [wokparam -e WOKEntity_libdir ${thefact}:${theware}:${ULNAME}]
    cd $theullibdir
    foreach atempld [glob *.ldt] {
	source $atempld
	set goodlen [expr [string length $atempld] - 2]
	set aldfile [crange $atempld 0 $goodlen]
	set ldfileid [open $aldfile w]
	puts $ldfileid [WOKDeliv_Makeld $thefact]
	if {![catch {set esvers [wokparam -e %ENV_EngineStarterVersion]}]} {
	    puts $ldfileid $esvers
	}
	close $ldfileid
    }
}
