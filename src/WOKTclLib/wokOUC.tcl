
proc wokOUC:DBG { {root {}} } {
    global IWOK_GLOBALS
    global IWOK_WINDOWS
    set w .oucewokk4dev
    set hli $IWOK_WINDOWS($w,OUC,hlist)
    foreach c [$hli info children $root] {
	puts "$c : data <[$hli info data $c]>"
	wokOUC:DBG $c
    }
    return
}



#############################################################################
#
#                              O U C
#                              _____
#
#############################################################################
proc wokOUC:Exit { w } {
    global IWOK_WINDOWS
    destroy $w
    wokButton delw [list ouce $w]
    foreach var [array names IWOK_WINDOWS $w,OUC,*] {
	unset IWOK_WINDOWS($var)
    }
    return
}

proc wokOUC:Help { w } {
    return
}

proc wokOUC:Create { {loc {}} } {
    global IWOK_WINDOWS
    global IWOK_GLOBALS

    if { $loc == {} } {
	set verrue [wokCWD readnocell]
    } else {
	regexp {(.*):OUCE} $loc all verrue 
    }

    if ![wokinfo -x $verrue] {
	wokDialBox .wokcd {Unknown location} "Location $verrue is unknown" {} -1 OK
	return
    }
    set fshop [wokinfo -s $verrue]

    set w  [wokTPL ouce${verrue}]
    if [winfo exists $w ] {
	wm deiconify $w
	raise $w
	return 
    }
    
    toplevel $w
    wm title $w "OUCE of $fshop"
    wm geometry $w 880x555+515+2

    wokButton setw [list ouce $w]
    
    menubutton $w.file -menu $w.file.m -text File -underline 0 -takefocus 0
    menu $w.file.m 
    $w.file.m add command -label "Exit     " -underline 1 -command [list wokOUC:Exit $w]

    menubutton $w.help -menu $w.help.m -text Help -underline 0 -takefocus 0
    menu $w.help.m
    $w.help.m add command -label "Help"      -underline 1 -command [list wokOUC:Help $w]

    frame $w.top -relief sunken -bd 1 
     
    tixPanedWindow $w.top.pane -orient horizontal -paneborderwidth 0 -separatorbg gray50
    pack $w.top.pane -side top -expand yes -fill both -padx 10 -pady 10
    
    set p1 [$w.top.pane add tree -min 70 -size 200]
    set p2 [$w.top.pane add text -min 70]
    
    set tree [tixTree $p1.tree  -options {hlist.separator "^" hlist.selectMode single }]
    set text [tixScrolledText $p2.text ] ; $text subwidget text    config -font $IWOK_GLOBALS(font)

    $tree config -opencmd  [list wokOUC:Tree:Open $w] -browsecmd [list wokOUC:Tree:Browse $w]

    pack $p1.tree -expand yes -fill both -padx 1 -pady 1
    pack $p2.text -expand yes -fill both -padx 1 -pady 1

    set IWOK_WINDOWS($w,OUC,tree)     $tree
    set IWOK_WINDOWS($w,OUC,hlist)    [$tree subwidget hlist]
    set IWOK_WINDOWS($w,OUC,text)     [$text subwidget text]
    set IWOK_WINDOWS($w,OUC,label)    [label $w.lab]
    set IWOK_WINDOWS($w,OUC,shop)     $fshop
    set IWOK_WINDOWS($w,OUC,root)     [wokOUC:GetRootName $fshop]
    set IWOK_WINDOWS($w,OUC,dupstyle) [tixDisplayStyle imagetext -fg orange]

    tixButtonBox $w.act -orientation horizontal -relief flat -padx 0 -pady 0
    

    tixForm $w.file ; tixForm $w.help -right -2
    tixForm $w.act -top $w.file -left 2
    tixForm $w.top -top $w.act -left 2 -right  %99 -bottom $w.lab 
    tixForm $w.lab -left 2 -right %99  -bottom %99

    bind $IWOK_WINDOWS($w,OUC,hlist) <Control-Button-1> {
	wokOUC:Tree:diff [winfo toplevel %W]
    }
    bind $IWOK_WINDOWS($w,OUC,hlist) <Control-Button-1> {
	wokOUC:Tree:diff [winfo toplevel %W]
    }
    wokOUC:Tree:Fill $w 
    
    return
}

proc wokOUC:Tree:diff { w } {
    global IWOK_WINDOWS
    if ![info exists IWOK_WINDOWS($w,OUC,v1)] {
	set IWOK_WINDOWS($w,OUC,v1) [$IWOK_WINDOWS($w,OUC,hlist) info anchor]
    } else {
	if ![info exists IWOK_WINDOWS($w,OUC,v2)] {
	    set IWOK_WINDOWS($w,OUC,v2) [$IWOK_WINDOWS($w,OUC,hlist) info anchor]
	    set pth1 [lindex [lindex [$IWOK_WINDOWS($w,OUC,hlist) info data $IWOK_WINDOWS($w,OUC,v1)] 1] 2]
	    set pth2 [lindex [lindex [$IWOK_WINDOWS($w,OUC,hlist) info data $IWOK_WINDOWS($w,OUC,v2)] 1] 2]
	    if { [file exists $pth1] && [file exists $pth2] } {
		wokDiffInText $IWOK_WINDOWS($w,OUC,text) $pth1 $pth2 
		if [wokUtils:EASY:INPATH xdiff] {
		}
	    }
	}
    }
    return
}
#;>
# Pour iwok Ecrit la table dans un tree
#;<
proc wokOUC:Tree:Fill { w } {
    global IWOK_WINDOWS
    tixBusy $w on
    set fshop $IWOK_WINDOWS($w,OUC,shop)
    set root  $IWOK_WINDOWS($w,OUC,root)
    set hlist $IWOK_WINDOWS($w,OUC,hlist)
    set filima [tix getimage textfile]
    foreach e [lsort [readdir $root]] {
	set ldup [llength [set lem [wokUtils:FILES:FileToList $root/$e]]]
	if { $lem != {} } {
	    if { $ldup == 1 } {
		$hlist add $e -itemtype imagetext -text $e \
			-image $filima \
			-data [list HEADER [list $ldup $lem]]
	    } else {
		$hlist add $e -itemtype imagetext -text $e -style $IWOK_WINDOWS($w,OUC,dupstyle) \
			-image $filima \
			-data [list HEADER [list $ldup $lem]]
	    }
	    $IWOK_WINDOWS($w,OUC,tree) setmode $e open
	    update
	} else {
	   unlink $root/$e 
	}
    }
    tixBusy $w off
    return
}


proc wokOUC:Tree:Open { w dir } {
    global IWOK_WINDOWS
    global IWOK_GLOBALS
     if {[$IWOK_WINDOWS($w,OUC,hlist) info children $dir] != {}} {
	foreach kid [$IWOK_WINDOWS($w,OUC,hlist) info children $dir] {
	    $IWOK_WINDOWS($w,OUC,hlist) show entry $kid
	}
    } else {
	tixBusy $w on
	set lem [lindex [lindex [$IWOK_WINDOWS($w,OUC,hlist) info data $dir] 1] 1]
	set upd {}
	foreach f $lem {
	    set lf [split $f]
	    if { [file exists [lindex $lf 2]] } {
		lappend upd $f
		set adr [lindex $lf 0]
		$IWOK_WINDOWS($w,OUC,hlist) add ${dir}^${adr} -itemtype imagetext \
			-text [join [lrange [split $adr :] 2 3] :] \
			-image $IWOK_GLOBALS(image,[lindex $lf 1]) \
			-data [list PATH [list $adr [lindex $lf 1] [lindex $lf 2]]]
	    }
	}
	update
	if { $upd != {} } {
	    wokUtils:FILES:ListToFile $upd $IWOK_WINDOWS($w,OUC,root)/$dir	    
	} else {
	    unlink $IWOK_WINDOWS($w,OUC,root)/$dir
	}
	tixBusy $w off
    }
    return
}

proc wokOUC:Tree:Browse { w dir } {
    global IWOK_WINDOWS

    ;# parce qu'elle est aussi appelee  dans le bind
    if { [info exists IWOK_WINDOWS($w,OUC,v1)] && [info exists IWOK_WINDOWS($w,OUC,v2)] } {
	unset IWOK_WINDOWS($w,OUC,v1) IWOK_WINDOWS($w,OUC,v2)
	return
    }

    set data [$IWOK_WINDOWS($w,OUC,hlist) info data $dir]
    set type [lindex $data 0]
    
    switch -- $type {

	PATH   {
	    set dd  [lindex $data 1]
	    set adr [lindex $dd 0]
	    set typ [lindex $dd 1]
	    set pth [lindex $dd 2]
	    wokReadFile $IWOK_WINDOWS($w,OUC,text) $pth
	}

	HEADER {
	}
    }
    
    return
}

#
#;>
# Ajoute une entry pour lname { nam1 nam2 ..} a l'adresse adr
# wokOUC:Add WOK:k4dev k4dev:adnk4:WOKAPI package /adv_23/WOK/k4dev/adnk4/src/WOKAPI WOKAPI_Command.c
# Dans le cad d'une duplication update GetDupName
#;<
proc wokOUC:Add { fshop adr typ dir lname } {
    set root [wokOUC:GetRootName $fshop 1]
    set dupl [wokOUC:GetDupName  $fshop 1]
    foreach name $lname {
	set entry $root/$name
	if { [file exists $entry] == 1 } {
	    set lem [wokUtils:FILES:FileToList $entry]
	    set new {}
	    set add 1
	    set nbe 0
	    foreach f $lem {
		set lf [split $f]
		set a  [lindex $lf 0]
		set t  [lindex $lf 1]
		set p  [lindex $lf 2]
		if { [file exist $p] } {
		    lappend new $f
		    incr nbe
		}
		if { "$a" == "$adr" && "$t" == "$typ" && "$p" == "$dir"} {
		    set add 0
		}
	    }
	    if { $add } { 
		lappend new "$adr $typ $dir/$name" 
	    }
	    wokUtils:FILES:ListToFile $new $entry
	    if { $nbe > 1 } {
		wokUtils:FILES:touch $dupl/$name
	    }
	} else {
	    wokUtils:FILES:ListToFile [list "$adr $typ $dir/$name"] $entry
	    chmod 0777 $entry
	}
    }
    return 
}
#;>
# Teste si une entry existe, la detruit sinon. 
# 
#;<
proc wokOUC:Exists { fshop adr typ name } {
    set root [wokOUC:GetRootName $fshop]
    set entry $root/$name
    if { [file exists $entry] } {
	set lem [wokUtils:FILES:FileToList $entry]
	set new {}
	set x 0
	foreach f $lem {
	    set lf [split $f]
	    set a  [lindex $lf 0]
	    set t  [lindex $lf 1]
	    set p  [lindex $lf 2]
	    if [file exist $p] {
		lappend new $f
	    }
	    if { "$a" == "$adr" && "$t" == "$typ" } {
		set x 1
	    }
	}
	if { $new != {} } {
	    wokUtils:FILES:ListToFile $new $entry	    
	} else {
	    set x 0
	    unlink $entry
	}
	return $x
    } else {
	return 0
    }
}
#;>
# Retourne le full path du repertoire d'administration de wsee pour un ilot donne.
#  1. Si create = 1 le cree dans le cas ou il n'existe pas.
#;<
proc wokOUC:GetRootName { fshop {create 0} } {
    set diradm [wokparam -e %VC_ROOT $fshop]/adm/[wokinfo -n [wokinfo -s $fshop]]/OUC_ENTRIES
    if [file exists $diradm] {
	return $diradm
    } else {
	if { $create } {
	    msgprint -c WOKVC -i "Creating file $diradm"
	    mkdir -path $diradm
	    chmod 0777 $diradm
	    return $diradm
	} else {
	    return {}
	}
    }
}
proc wokOUC:GetDupName { fshop {create 0} } {
    set diradm [wokparam -e %VC_ROOT $fshop]/adm/[wokinfo -n [wokinfo -s $fshop]]/OUC_DUP
    if [file exists $diradm] {
	return $diradm
    } else {
	if { $create } {
	    msgprint -c WOKVC -i "Creating file $diradm"
	    mkdir -path $diradm
	    chmod 0777 $diradm
	    return $diradm
	} else {
	    return {}
	}
    }
}
 
#;>
# remplit root avec le contenu de fshop sauf le workbench appele ref.
# prevoir de faire mv root ->root-sav et d'ecrire dans root neuve.
#;<
proc wokOUC:Make { fshop {wr ref} } {
    set wr ref
    set root [wokOUC:GetRootName $fshop 1]
    foreach adr [wokFind $fshop] {
	if {"[wokinfo -t $adr]" == "devunit" } {
	    if { "[wokinfo -n [wokinfo -w $adr]]" != "$wr" } {
		set typ [uinfo -t $adr]
		set dir [wokinfo -p source:. ${adr}]
		set lname {}
		foreach f [glob -nocomplain $dir/*] {
		    if { "[set n [wokOUC:Valid $f]]" != {} } {
			lappend lname $n
		    }
		}
		puts "Creer les entries de $adr avec:"
		;#puts "lname = $lname"
		wokOUC:Add $fshop $adr $typ $dir $lname
	    }
	}
    }
    return 
}

proc wokOUC:Clean { fshop {type entries} } {
    switch -- $type {
	entries {
	    set root [wokOUC:GetRootName $fshop]
	    foreach f [glob -nocomplain $root/*] {
		if [catch { unlink $f } status] {
		    puts "Clean: $status"
		}
	    }
	}

	dup {
	    set duproot [wokOUC:GetDupName $fshop]
	     foreach f [glob -nocomplain $duproot/*] {
		if [catch { unlink $f } status] {
		    puts "Clean: $status"
		}
	    }
	}
    }
    return
}

proc wokOUC:Dump { fshop {type entries} } {
    switch -- $type {
	
	entries {
	    set root [wokOUC:GetRootName $fshop]
	    foreach f [glob -nocomplain $root/*] {
		puts $f
	    }
	}

	dup {
	    set duproot [wokOUC:GetDupName $fshop]
	    foreach f [glob -nocomplain $duproot/*] {
		puts $f
	    }
	}
    }
    return
}

proc wokOUC:Valid { p } {
    if { ![file isdirectory $p] } {
	set e [file extension [set n [file tail $p]]]
	if { ![string match {*~} $n] } {
	    if { ![string match {*~} $e] } {
		if { ![string match {#*#} $n] } {
		    if { ![string match {*-sav} $e] } {
			return $n
		    } else {
			return {}
		    }
		} else {
		    return {}
		}
	    } else {
		return {}
	    }
	} else {
	    return {}
	}
    } else {
	return {}
    }


}





#;>
# Pour la commande
#;<
proc wokOUC:Tree:Print { w } {
    global IWOK_WINDOWS
    global IWOK_GLOBALS
    set fshop $IWOK_WINDOWS($w,OUC,shop)
    set root  $IWOK_WINDOWS($w,OUC,root)
    set hlist $IWOK_WINDOWS($w,OUC,hlist)
    set filima [tix getimage textfile]
    foreach e [lsort [readdir $root]] {
	set lem [wokUtils:FILES:FileToList $root/$e]
	if { $lem != {} } {
	    $hlist add $e -itemtype imagetext -text $e \
		    -image $filima \
		    -data [list HEADER {}]
	    set upd {}
	    foreach f $lem {
		set lf [split $f]
		if { [file exists [lindex $lf 2]] } {
		    lappend upd $f
		    set adr [lindex $lf 0]
		    $hlist add ${e}^${adr} -itemtype imagetext \
			    -text [join [lrange [split $adr :] 1 2] :] \
			    -image $IWOK_GLOBALS(image,[lindex $lf 1]) \
			    -data [list PATH [list $adr lindex $lf 2]]
		}
	    }
	    update 
	    if { $upd != {} } {
		wokUtils:FILES:ListToFile $upd $root/$e	    
	    } else {
		unlink $root/$e
	    }
	} else {
	    unlink $root/$e
	}
    }
    return
}
