;#
;# Appele quand on browse la hlist wprepare
;#
proc  wokDisplayCook { item w } {
    global IWOK_WINDOWS
    global IWOK_GLOBALS

    set litm [split $item ^]
    if { [llength $litm] == 2 } {
	set data [$IWOK_WINDOWS($w,hlist) info data $item]
	set item [lindex $litm 1]
    } else {
	return
    }

    set unit [$IWOK_WINDOWS($w,hlist) info parent [$IWOK_WINDOWS($w,hlist) info anchor]]

    set flag [lindex $item 0]
    set name [lindex $item 1]
    set d1   [lindex $item 2]
    set twb  [wokgetWB $d1 $unit $IWOK_WINDOWS($w,shop) $IWOK_WINDOWS($w,LWB)]

    if { [lindex $data 0] } {
	$IWOK_WINDOWS($w,warbut) subwidget warwhy configure -state active -fg orange
    } else {
	$IWOK_WINDOWS($w,warbut) subwidget warwhy configure -state disabled
	$IWOK_WINDOWS($w,warbut) subwidget warget configure -state disabled
    }


    if { $IWOK_GLOBALS(comment,entered) } {
	set IWOK_GLOBALS(comment,string) [wokTextToString $IWOK_WINDOWS($w,text)]
	set IWOK_GLOBALS(comment,entered) 0
    }
    
    [$IWOK_WINDOWS($w,button) subwidget search] configure -state active

    switch -- $flag {
	+ {
	    wokReadFile $IWOK_WINDOWS($w,text) $d1/$name
	    $IWOK_WINDOWS($w,label) configure -text \
		    "ADDED: File ${twb}:${name}" -fg yellow
	    [$IWOK_WINDOWS($w,button) subwidget editcopy] configure -state active
	    [$IWOK_WINDOWS($w,button) subwidget xdiff] configure -state disabled
	    eval "proc wokeditcopy { args } {wokEDF:EditFile $d1/$name}"
	}

	- {
	    wokReadFile $IWOK_WINDOWS($w,text) $d1/$name
	    $IWOK_WINDOWS($w,label) configure -text \
		    "REMOVED: File ${twb}:${name}" -fg yellow
	    [$IWOK_WINDOWS($w,button) subwidget editcopy] configure -state active
	    [$IWOK_WINDOWS($w,button) subwidget xdiff] configure -state disabled
	    eval "proc wokeditcopy { args } {wokEDF:EditFile $d1/$name}"
	}

	= {
	    wokReadFile $IWOK_WINDOWS($w,text) $d1/$name
	    $IWOK_WINDOWS($w,label) configure -text \
		    "NOT MODIFIED: File ${twb}:${name}" -fg yellow
	    [$IWOK_WINDOWS($w,button) subwidget editcopy] configure -state active
	    [$IWOK_WINDOWS($w,button) subwidget xdiff] configure -state disabled
	    eval "proc wokeditcopy { args } {wokEDF:EditFile $d1/$name}"
	}

	# {
	    [$IWOK_WINDOWS($w,button) subwidget editcopy] configure -state disabled
	    set d2 [lindex $item 3]
	    set twb2 [wokgetWB $d2 $unit $IWOK_WINDOWS($w,shop) $IWOK_WINDOWS($w,LWB)]
	    wokDiffInText $IWOK_WINDOWS($w,text) $d2/$name $d1/$name 
	    if { [set xdiff [wokUtils:FILES:MoreDiff]] != {} } {
		[$IWOK_WINDOWS($w,button) subwidget xdiff] configure -state active
		eval "proc wokxdiff { args } {exec $xdiff $d2/$name $d1/$name &}"
	    }
	    $IWOK_WINDOWS($w,label) configure -text \
		    "File ${twb2}:${name} <       > ${twb}:${name}"  -fg yellow
	    
	}
    }
    return
}

proc wokgetWB { dirpath ud shop lwb } {
    foreach wb $lwb {
	if { [wokinfo -x ${shop}:${wb}:$ud] } {
	    if { [string trimright [wokinfo -p source:. ${shop}:$wb:$ud] /.] == "$dirpath" } {
		return $wb
	    }
	}
    }
    return {}
}
#
# Edition d'un report depuis IWOK. Seuls les fichiers sont traites.
#
proc WOKCOOK { opt args } {
    global IWOK_GLOBALS

    set H $IWOK_GLOBALS(CookHlist)

    switch $opt {
	
	files {
	    set e  [lindex $args 2]
	    set d1 [lindex $args 3]
	    set udname $IWOK_GLOBALS(CookHlist,Unit)
	    set key ${e}:$IWOK_GLOBALS(CookHlist,Key)
	    set suspect [info exists IWOK_GLOBALS(CookHlist,dupl,list,$key)]
	    switch -- [lindex $args 0] {
		+ {
		    if { $suspect } {
			set IWOK_GLOBALS(CookHlist,dupl,suspect) 1
			$H add ${udname}^[list + $e $d1] -text [format "+ %-30s" $e] \
				-data [list 1 $IWOK_GLOBALS(CookHlist,dupl,list,$key)] -itemtype text \
				-style $IWOK_GLOBALS(CookHlist,dupl,style)
		    } else {
			$H add ${udname}^[list + $e $d1] -text [format "+ %-30s" $e] \
				-data [list 0 {}] -itemtype text
		    }
		}
		- {
		    if { $suspect } {
			set IWOK_GLOBALS(CookHlist,dupl,suspect) 1
			$H add ${udname}^[list - $e $d1] -text [format "- %-30s" $e] \
				-data [list 1 $IWOK_GLOBALS(CookHlist,dupl,list,$key)] -itemtype text \
				-style $IWOK_GLOBALS(CookHlist,dupl,style)
		    } else {
			$H add ${udname}^[list - $e $d1] -text [format "- %-30s" $e] \
				-data [list 0 {}] -itemtype text
		    }
		}
		= {
		    if { $suspect } {
			set IWOK_GLOBALS(CookHlist,dupl,suspect) 1
			$H add ${udname}^[list = $e $d1 [lindex $args 4]] -text [format "= %-30s" $e] \
				-data [list 1 $IWOK_GLOBALS(CookHlist,dupl,list,$key)] -itemtype text \
				-style $IWOK_GLOBALS(CookHlist,dupl,style)
		    } else {
			$H add ${udname}^[list = $e $d1 [lindex $args 4]] -text [format "= %-30s" $e] \
				-data [list 0 {}] -itemtype text
		    }
		    set IWOK_GLOBALS(scratch) 1

		}
		# {
		    if { $suspect } {
			set IWOK_GLOBALS(CookHlist,dupl,suspect) 1
			$H add ${udname}^[list # $e $d1 [lindex $args 4]] -text [format "# %-30s" $e] \
				-data [list 1 $IWOK_GLOBALS(CookHlist,dupl,list,$key)] -itemtype text \
				-style $IWOK_GLOBALS(CookHlist,dupl,style)
		    } else {
			$H add ${udname}^[list # $e $d1 [lindex $args 4]] -text [format "# %-30s" $e] \
				-data [list 0 {}] -itemtype text
		    }
		}
	    }
	}
	
	uheader {
	    regexp {(.*)\.(.*)} [lindex $args 0] all udname type
	    $H add $udname -itemtype imagetext -text $udname \
		    -style $IWOK_GLOBALS(CookHlist,dupl,ustyle) -image [tix getimage $type]
	    set IWOK_GLOBALS(CookHlist,Unit) ${udname}
	    set IWOK_GLOBALS(CookHlist,Key)  ${udname}.$IWOK_GLOBALS(CookHlist,stype,$type)
	    $H see $udname
	}

   }
   update
}

proc wokPrepareExit { w } {
    global IWOK_GLOBALS
    destroy $w
    foreach e [array names IWOK_GLOBALS CookHlist,*] {
	catch { unset IWOK_GLOBALS($e) }
    }
    wokButton delw [list prepare $w]
    return
}

proc wokPrepare { {loc {}} {les_uds {}} } {
    global IWOK_GLOBALS
    global IWOK_WINDOWS

   

    if { $loc == {} } {
	set verrue [wokCWD readnocell]
    } else {
	set verrue $loc
    }
    if ![wokinfo -x $verrue] {
	wokDialBox .wokcd {Unknown location} "Location $verrue is unknown" {} -1 OK
	return
    }
    set shop [wokinfo -s $verrue]
    set wb   [wokinfo -n [wokinfo -w $verrue]]


    set w [wokTPL wprepare${verrue}]
    if [winfo exists $w ] {
	wm deiconify $w
	raise $w
	return 
    }
    
    toplevel $w 
    wm title $w "Comparing workbenches in $shop"
    wokButton setw [list prepare $w]

    wm geometry $w 960x720+461+113
    
    foreach type $IWOK_GLOBALS(ucreate-P) {
	set tn [lindex $type 1]
	set IWOK_GLOBALS(CookHlist,stype,$tn) [lindex $type 0]
    }
    set IWOK_WINDOWS($w,WBFils)   $wb
    set IWOK_WINDOWS($w,LWB)      [w_info -A ${shop}:$wb]
    if { [llength $IWOK_WINDOWS($w,LWB)] > 1 } {
	set IWOK_WINDOWS($w,WBPere)   [lindex $IWOK_WINDOWS($w,LWB) 1]
    } else {
	set IWOK_WINDOWS($w,WBPere) $wb
    }
    
    set func1 wokHliAdd
    set func2 wokHliDel
    set function wokDisplayCook

    menubutton $w.file -menu $w.file.m -text File -underline 0 -takefocus 0
    menu $w.file.m 
    $w.file.m add command -label "Close     " -underline 1 -command [list wokPrepareExit $w]
    menubutton $w.admin -menu $w.admin.m -text Admin -underline 0 -takefocus 0 
    menu $w.admin.m 

    $w.admin.m add command -label "Check for init" -underline 1 -command [list wokPrepareCheck $w]
    $w.admin.m  entryconfigure 1 -state disabled
    $w.admin.m  configure -postcommand [list wokPostCheck $w]

    menubutton $w.help -menu $w.help.m -text Help -underline 0 -takefocus 0
    menu $w.help.m 
    $w.help.m add command -label "Help" -underline 1 -command [list wokPrepareHelp $w]

    frame $w.top -relief sunken -bd 1 
    label $w.lab -relief sunken 
    
    tixScrolledHList $w.h1 -width 8c   ; set hlist1 [$w.h1 subwidget hlist]
    set locfunc1 ${func1}_$w  ; set body {$item} ; eval "proc $locfunc1 { item } { $func1 $body $w}"
    $hlist1 config -separator ^ -drawbranch 0 -browsecmd $locfunc1 -selectmode single

    tixScrolledHList $w.h2 -width 8c   ; set hlist2 [$w.h2 subwidget hlist]
    set locfunc2 ${func2}_$w  ; set body {$item} ; eval "proc $locfunc2 { item } { $func2 $body $w}"
    $hlist2 config -separator ^ -drawbranch 0 -browsecmd $locfunc2 -selectmode single

    tixPanedWindow $w.top.pane -orient horizontal -paneborderwidth 0 -separatorbg gray50
    pack $w.top.pane -side top -expand yes -fill both -padx 1 -pady 1
    
    set p1 [$w.top.pane add list -min 70 -size 200]
    set p2 [$w.top.pane add text -min 70]
    
    tixScrolledHList   $p1.list ; set hlist [$p1.list subwidget hlist]
    set locfunc ${function}_$w  ; set body {$item} ; eval "proc $locfunc { item } { $function $body $w}"
    $hlist config -font $IWOK_GLOBALS(font) -separator ^ -drawbranch 0 -browsecmd $locfunc -selectmode single
    tixScrolledText    $p2.text ; $p2.text subwidget text    config -font $IWOK_GLOBALS(font)
    set texte [$p2.text subwidget text]

    pack $p1.list -expand yes -fill both -padx 1 -pady 1
    pack $p2.text -expand yes -fill both -padx 1 -pady 1 -padx 3

    frame $w.wbs -relief sunken -bd 1 
    tixLabelEntry $w.wbs.mas -label "Workbench 1"  -labelside left -options {
	label.anchor n
    }

    tixLabelEntry $w.wbs.rev -label "Workbench 2"  -labelside left -options {
	label.anchor n
    }

    tixForm $w.wbs.mas -top 0 -left 0 -right -0
    tixForm $w.wbs.rev -top $w.wbs.mas -left 0 -right -0
    $w.wbs.mas subwidget entry configure -textvariable IWOK_WINDOWS($w,WBPere)
    $w.wbs.rev subwidget entry configure -textvariable IWOK_WINDOWS($w,WBFils)

    tixButtonBox $w.but -orientation horizontal -relief raised -padx 0 -pady 0

    set buttons [list \
	    {addall   "Add all"   active    wokHliAddall} \
	    {delall   "Del all"   active    wokDelall} \
	    {prepare  "Compare"   active    wokRunPrepar} \
	    {exclude  "Exclude"   disabled  wokExcludeItem} \
	    {hide     "Hide="     disabled  wokHideEq} \
	    {rmeq     "rm ="      disabled  wokrmEq} \
	    {editcopy "To Editor" disabled  wokeditcopy} \
	    {search   "Search"    disabled  wokeditsearch} \
	    {xdiff    "More Diff" disabled  wokxdiff} \
	    {comment  "Comments"  disabled  wokEnterComment} \
	    {saveas   "Save "     disabled  wokSaveas} \
	    ]

    foreach b $buttons {
	$w.but add [lindex $b 0] -text [lindex $b 1] 
	[$w.but subwidget [lindex $b 0]] configure -state [lindex $b 2] -command [list [lindex $b 3] $w] 
    }

    tixButtonBox $w.warbut -orientation horizontal -relief flat -padx 0 -pady 0

    set warbut [list  \
	    {warshow "Show warnings" disabled wokDupEntryShow} \
	    {warwhy  "Queue diff"    disabled wokDupEntryWhy}  \
	    {warget  "Get from Queue" disabled wokDupEntryGet} \
	    ]

    foreach b $warbut {
	$w.warbut add [lindex $b 0] -text [lindex $b 1] 
	[$w.warbut subwidget [lindex $b 0]] configure \
	-state [lindex $b 2] -command [list [lindex $b 3] $w] -width 11
    }

    if [wokStore:Queue:Enabled $shop $IWOK_WINDOWS($w,WBPere)] {
	set trigger [wokStore:Trigger:Exists $shop]    
	button $w.stor  -text "Store"
	$w.stor configure -state disabled -command [list wokStoreThat $w]
	
	tixForm $w.file ; tixForm $w.admin -left $w.file
	if { $trigger != {} } {
	    menubutton $w.shrt -menu $w.shrt.m -text Trigger -underline 0 -takefocus 0
	    menu $w.shrt.m
	    $w.shrt.m add command -label "Show content" -underline 0 -command [list wokShowTrig $w $trigger]
	    tixForm $w.shrt -left $w.admin
	}

	tixForm $w.help -right -2
	tixForm $w.h1  -top $w.file -left 2 -right %28
	tixForm $w.wbs -top $w.file -left $w.h1 -right $w.h2 
	tixForm $w.h2  -top $w.file -right -2 -left %78
	tixForm $w.but -top $w.h1 -left 2 
	
	set IWOK_WINDOWS($w,trig) 0 
	
	if { $trigger != {} } {
	    checkbutton  $w.trig -text "Trigger" -variable  IWOK_WINDOWS($w,trig)
	    $w.trig configure -state disabled
	    tixForm $w.trig -top $w.h1 -left $w.but 
	    tixForm $w.stor -top $w.h1 -left $w.trig -right -1
	} else {
	    tixForm $w.stor -top $w.h1 -left $w.but -right -1
	}
    } else {
	button $w.stor  -text "Update $IWOK_WINDOWS($w,WBPere)"
	$w.stor configure -state disabled -command [list wokUpdateThat $w]
	tixForm $w.file 
	tixForm $w.admin -left $w.file
	tixForm $w.help  -right -2
	tixForm $w.h1    -top $w.file -left 2 -right %32
	tixForm $w.wbs   -top $w.file -left $w.h1 -right $w.h2 
	tixForm $w.h2    -top $w.file -right -2 -left %68
	tixForm $w.but   -top $w.h1 -left 2 
	tixForm $w.stor  -top $w.h1 -left $w.but -right -1
    }

    tixForm $w.top -top $w.but -left 2 -right -2 -bottom  $w.warbut
    tixForm $w.warbut -bottom -0 -left %66 -right %100
    tixForm $w.lab -left 0 -bottom -0  -right $w.warbut

    set IWOK_WINDOWS($w,menu)   $w.file.m
    set IWOK_WINDOWS($w,admin)  $w.admin.m 
    set IWOK_WINDOWS($w,label)  $w.lab
    set IWOK_WINDOWS($w,hlist)  $hlist
    set IWOK_WINDOWS($w,text)   $texte
    set IWOK_WINDOWS($w,hlist1) $hlist1
    set IWOK_WINDOWS($w,hlist2) $hlist2
    set IWOK_WINDOWS($w,button) $w.but
    set IWOK_WINDOWS($w,warbut) $w.warbut
    set IWOK_WINDOWS($w,actrig) $w.trig
    set IWOK_WINDOWS($w,store)  $w.stor
    set IWOK_WINDOWS($w,shop)   $shop
    set IWOK_WINDOWS($w,qroot)  [wokStore:Report:GetRootName $shop 0]

    set allUnits  [wokPreparInitFils $w $wb]
    wokPreparInitPere $w $wb
    
    if { $les_uds != {} } {
	wokHliAdd $les_uds  $w
    }

    update
    set IWOK_GLOBALS($w,popup) [tixPopupMenu $w.popmenu -title "Select"]
    $w.popmenu subwidget menubutton configure -font $IWOK_GLOBALS(font)
    set IWOK_GLOBALS($w,popup,menu) [$IWOK_GLOBALS($w,popup) subwidget menu]
    $IWOK_GLOBALS($w,popup,menu)  configure -font $IWOK_GLOBALS(font)
    foreach t [linsert $IWOK_GLOBALS(ucreate-P) 0 [list All All] ] {
	$IWOK_GLOBALS($w,popup,menu) add command -label [lindex $t 1] \
		-command [list wokPreparFilter $hlist1 [lindex $t 1] $allUnits]
    }

    $IWOK_GLOBALS($w,popup) bind $hlist1

    bind $IWOK_WINDOWS($w,hlist) <Control-f> {
	wokGetDoublon %W
    }

    bind $IWOK_WINDOWS($w,hlist) <Control-x> {
	catch {
	    set next [%W info next [%W info anchor]]
	    %W delete entry [%W info anchor]
	    %W anchor set $next
	    unset next
	}
    }

    bind $IWOK_WINDOWS($w,hlist) <Control-k> {
	catch {
	    set next [%W info next [%W info anchor]]
	    %W delete entry [%W info anchor]
	    %W anchor set $next
	    unset next
	}
    }

    bind [$w.wbs.mas subwidget entry] <Return> {
	wokPreparInitPere [winfo toplevel %W] [%W get]
	update
    }

    bind [$w.wbs.rev subwidget entry] <Return> {
	wokPreparInitFils [winfo toplevel %W] [%W get]
	update
    }

    ;#bind $w <Destroy>  { if [winfo exists %W]  { wokPrepareExit %W }}

    return
}
proc wokGetDoublon { hli } {
    set item [$hli info anchor] ;#WOKTclLib^# Mkf.tcl //wok/src/WOKTclLib /adv_23/WOK/ef/src/WOKTclLib
    set data [$hli info data $item]
    set suspect [lindex $data 0]
    if { $suspect } {
	puts "suspect"
    } else {
	puts "ok"
    }
    return
}

proc wokeditsearch { w  } {
    global IWOK_WINDOWS
    wokSEA $IWOK_WINDOWS($w,text)
    return
}

proc wokPostCheck { w  } {
    global IWOK_WINDOWS
    if { [llength [$IWOK_WINDOWS($w,hlist2) info children]] != 0 } {
	$IWOK_WINDOWS($w,admin) entryconfigure 1 -state active
    } else {
	$IWOK_WINDOWS($w,admin) entryconfigure 1 -state disabled
    }
    return
}

proc wokClearHlist { w listh } {
    global IWOK_WINDOWS
    foreach hl $listh {
	$IWOK_WINDOWS($w,$hl) delete all
    }
    return
}
proc wokDelall { w } {
    global IWOK_WINDOWS
    wokHliDelall $w
    wokClearHlist $w hlist
    return
}

proc wokPreparInitPere { w wb } {
    global IWOK_WINDOWS 
    global IWOK_GLOBALS
    set fwb $IWOK_WINDOWS($w,shop):$wb
    if [wokinfo -x $fwb] {
	wokActiveStore $w disabled
	wokClearHlist $w [list hlist hlist2]
    } else {
	wokClearHlist $w [list hlist hlist1 hlist2]
	wokDialBox .notawb {Not a workbench} "The workbench $fwb does not exist" {} -1 OK
    }
    return
}
;#
;# Init de la hlist de gauche avec les Units du fils
;#
proc wokPreparInitFils { w wb } {
    global IWOK_WINDOWS 
    global IWOK_GLOBALS
    set allUnits  {}
    set fwb $IWOK_WINDOWS($w,shop):$wb
    set IWOK_WINDOWS($w,LWB) [w_info -A $fwb]
    if [wokinfo -x $fwb] {
	$IWOK_WINDOWS($w,hlist1) delete all
	foreach i [ lsort [w_info -a $fwb]] {
	    $IWOK_WINDOWS($w,hlist1) add $i -itemtype imagetext \
		    -text [lindex $i 1] -image $IWOK_GLOBALS(image,[lindex $i 0])
	    lappend allUnits [list [lindex $i 0] [lindex $i 1] $IWOK_GLOBALS(image,[lindex $i 0])]
	}
	wokClearHlist $w [list hlist hlist2]
    } else {
	wokDialBox .notawb {Not a workbench} "The workbench $fwb does not exist" {} -1 OK
    }
    return $allUnits
}

proc wokPreparFilter { hlist t allUnits } {
    $hlist delete all
    foreach i $allUnits {
	set type  [lindex $i 0]
	set name  [lindex $i 1]
	set image [lindex $i 2]
	if { "$t" != "All" } {
	    if { "$type" == "$t" } {
		$hlist add [list $type $name] -itemtype imagetext -text $name -image $image
	    }
	} else {
	    $hlist add [list $type $name] -itemtype imagetext -text $name -image $image
	}
    }
    return
}
proc wokDupEntryGet { w } {
    global IWOK_WINDOWS
    set file $IWOK_WINDOWS($w,warfile)
    set U    $IWOK_WINDOWS($w,warunit)
    set dest [wokinfo -p source:. $IWOK_WINDOWS($w,WBFils):$U]
    if [file writable $dest] {
	wokUtils:FILES:copy $file $dest/queue,[file tail $file]
	$IWOK_WINDOWS($w,label) configure -text "File $dest/queue,[file tail $file] created." -fg orange
    } else {
	$IWOK_WINDOWS($w,label) configure -text "Cannot write in directory $dest." -fg orange
    }
    return
}
proc wokDupEntryWhy  { w } {
    global IWOK_WINDOWS
    global IWOK_GLOBALS
    set hli $IWOK_WINDOWS($w,hlist)
    set item [$hli info anchor]
    if { $item != {} } {
	set data [$hli info data $item]
	if { [set suspect [lindex $data 0]] } {
	    set flag [lindex $item 0]
	    set name [lindex $item 1]
	    set d1   [lindex $item 2]
	    if { "$flag" != "-" } {
		if { [set lqueue [llength [set queue [lindex $data 1]]]] == 1 } {
		    tixBusy $w on
		    update
		    set report_path $d1/$name
		    set IWOK_WINDOWS($w,warfile) [set queue_path [lindex $queue 0]/$name]
		    set IWOK_WINDOWS($w,warunit) [lindex [split $item ^] 0]
		    wokDiffInText $IWOK_WINDOWS($w,text) $report_path $queue_path
		    set head [wokStore:Report:Head $queue_path]
		    set num  [wokStore:Report:Index $IWOK_WINDOWS($w,qroot) $head]
		    set text "File $IWOK_WINDOWS($w,WBFils):$name <      > File $name in Report $num"
		    $IWOK_WINDOWS($w,warbut) subwidget warget configure -state active -fg orange
		    $IWOK_WINDOWS($w,label) configure -text $text -fg orange
		    tixBusy $w off
		    if { [set xdiff [wokUtils:FILES:MoreDiff]] != {} } {
			[$IWOK_WINDOWS($w,button) subwidget xdiff] configure -state active
			eval "proc wokxdiff { args } {exec $xdiff  $report_path $queue_path &}"
		    }
		} else {
		    puts "plus d'une duplication: toplevel"
		}
	    }
	}

    }
    return
}
proc  wokDupEntryShow { w } {
    global IWOK_WINDOWS
    global IWOK_GLOBALS
    set hli $IWOK_WINDOWS($w,hlist)
    foreach U [$hli info children] {
	foreach f [$hli info children $U] {
	    set data [$hli info data $f]
	    if { $IWOK_GLOBALS(CookHlist,dupl,show) == 0 } {

		if { [lindex $data 0] == 0 } {
		    $hli hide entry $f
		} else {
		    $hli show entry $f
		}
	    } else {
		$hli show entry $f
	    }
	}
    }
    if { $IWOK_GLOBALS(CookHlist,dupl,show) == 1 } {
	set IWOK_GLOBALS(CookHlist,dupl,show) 0
	$IWOK_WINDOWS($w,warbut) subwidget warshow  configure -text "Show warnings"
    } else {
	set IWOK_GLOBALS(CookHlist,dupl,show) 1
	$IWOK_WINDOWS($w,warbut) subwidget warshow  configure -text "Show all files"
    }
    return
}

proc wokDBGPrepare { {root {}} } { 
    set hli .woktopl:iwok.top.pane.list.list.f1.hlist
    foreach c [$hli info children $root] {
	puts "$c   :  data <[$hli info data $c]>"
	wokDBGPrepare $c
    }
    return
}


proc wokRunPrepar { w } {
    global IWOK_WINDOWS
    global IWOK_GLOBALS
    tixBusy $w on 
    update


    set IWOK_GLOBALS(CookHlist) $IWOK_WINDOWS($w,hlist)

    $IWOK_WINDOWS($w,hlist) delete all
    $IWOK_WINDOWS($w,text) delete 0.0 end
    $IWOK_WINDOWS($w,label) configure -text "" -fg yellow

    foreach e [array names IWOK_GLOBALS CookHlist,dupl,*] {
	catch { unset IWOK_GLOBALS($e) }
    }

    catch { unset tabqueue }
    wokStore:Report:DumpQueue $IWOK_WINDOWS($w,qroot) tabqueue
    if [array exists tabqueue] {
	wokUtils:EASY:MAD IWOK_GLOBALS CookHlist,dupl,list tabqueue
    }
    set IWOK_GLOBALS(CookHlist,dupl,suspect) 0
    set IWOK_GLOBALS(CookHlist,dupl,show)    0
    set IWOK_GLOBALS(CookHlist,dupl,style)   [tixDisplayStyle text -fg orange -font $IWOK_GLOBALS(boldfont)]
    set IWOK_GLOBALS(CookHlist,dupl,ustyle)  [tixDisplayStyle imagetext -font $IWOK_GLOBALS(boldfont)]

    set IWOK_GLOBALS(comment,entered) 0
    set IWOK_GLOBALS(comment,string) [wokIntegre:Journal:ReleaseNotes -1]

    set lud {}
    foreach item [$IWOK_WINDOWS($w,hlist2) info children] {
	lappend lud [lindex $item 1]
    }

    set IWOK_GLOBALS(scratch) 0
    if { $lud != {} } {
	set ffils $IWOK_WINDOWS($w,shop):$IWOK_WINDOWS($w,WBFils)
	set ffper $IWOK_WINDOWS($w,shop):$IWOK_WINDOWS($w,WBPere)
	wokclose -a
	if { "[w_info -A $ffils]" == "$IWOK_WINDOWS($w,WBFils)" } {
	    wokPrepare:Unit:Ref  WOKCOOK $ffils [lsort $lud]
	} else {
	    wokPrepare:Unit:Loop  WOKCOOK $ffper $ffils [lsort $lud]
	}
	[$IWOK_WINDOWS($w,button) subwidget exclude] configure -state active
	if { "$IWOK_WINDOWS($w,WBPere)" == "[lindex $IWOK_WINDOWS($w,LWB) 1]" } {
	    [$IWOK_WINDOWS($w,button) subwidget comment] configure -state active
	} else {
	    [$IWOK_WINDOWS($w,button) subwidget comment] configure -state disabled
	}
	[$IWOK_WINDOWS($w,button) subwidget saveas]  configure -state active
	if $IWOK_GLOBALS(scratch) { 
	    [$IWOK_WINDOWS($w,button) subwidget hide] configure -state active
	    [$IWOK_WINDOWS($w,button) subwidget rmeq] configure -state active
	    set IWOK_GLOBALS(scratch) 0
	}
    }
    tixBusy $w off

    if { $IWOK_GLOBALS(CookHlist,dupl,suspect) == 1 } {
	$IWOK_WINDOWS($w,warbut) subwidget warshow  configure -state active -fg orange 
	$IWOK_WINDOWS($w,label) configure -text \
		"CAUTION: Some files in your report are already in the integration queue." -fg orange 
    }

    return
}
;#
;# Retire l'item designe de la Hlist
;#
proc wokExcludeItem { w } {
    global IWOK_WINDOWS
    set hli $IWOK_WINDOWS($w,hlist)
    set entry [lindex [$hli info selection] 0]
    if { $entry != "" } {
	$hli delete entry $entry
    }
    return
}
;# 
;# retire les = dans la hlist de wprepare
;# 
proc wokHideEq { w } {
    global IWOK_WINDOWS
    set hli $IWOK_WINDOWS($w,hlist)
    foreach U [$hli info children] {
	foreach f [$hli info children $U] {
	    set e [lindex [split $f ^] 1]
	    set flag [lindex [split $e] 0]
	    if { [string compare $flag =] == 0} {
		$hli delete entry $U^$e
	    }
	}
    }
    foreach U [$hli info children] {
	if { [llength [$hli info children $U] ] == 0 } {
	    $hli delete entry $U
	}
    }
    return
}
;# 
;# detruit les fichiers marques = dans la hlist de wprepare
;# 
proc wokrmEq { w } {
    global IWOK_WINDOWS
    set hli $IWOK_WINDOWS($w,hlist)
    $IWOK_WINDOWS($w,text) delete 1.0 end
    set lrm {}
    foreach U [$hli info children] {
	foreach f [$hli info children $U] {
	    set l [split  [lindex [split $f ^] 1]]
	    if { [string compare [lindex $l 0]  =] == 0} {
		lappend lrm "rm [lindex $l 2]/[lindex $l 1]"
	    }
	}
    }
    set but [wokDangerDialBox .wokrmeq {Remove same files} {Really do that ?} $lrm danger 0 {Apply} {Cancel}]
    if { $but == 0 } {
	foreach f $lrm {
	    unlink [lindex $f 1]
	    $IWOK_WINDOWS($w,text) insert end "File [lindex $f 1] has been removed.\n"
	}
	wokHideEq $w
    }
    return
}
;#
;#;+ xxx.tcl  /adv_23/WOK/k1dev/subiwok/prod/WOKTclLib/src
;# met a jour le workbench pere avec le contenu du report. Pas de store
;#;# Mkf.tcl  /adv_23/WOK/k1dev/subiwok/prod/WOKTclLib/src
;#
proc wokUpdateThat { w } {
    global IWOK_WINDOWS
    global IWOK_GLOBALS

    $IWOK_WINDOWS($w,text) delete 0.0 end
    msgsetcmd wokMessageInText $IWOK_WINDOWS($w,text)
    set hli $IWOK_WINDOWS($w,hlist)
    set lpere [w_info -l $IWOK_WINDOWS($w,shop):$IWOK_WINDOWS($w,WBPere)]
    foreach U [$hli info children] {
	if { [lsearch $lpere $U] == -1 } {
	    set T $IWOK_GLOBALS(L_S,[uinfo -t $U])
	    catch { ucreate -${T} $IWOK_WINDOWS($w,WBPere):$U }
	}
	set dest [wokinfo -p source:. $IWOK_WINDOWS($w,shop):$IWOK_WINDOWS($w,WBPere):$U]
	if { [file exist $dest] && [file writable $dest] } {
	    foreach f [$hli info children $U] {
		set e [lindex [split $f ^] 1]
		if { "[lindex $e 0]" == "#" || "[lindex $e 0]" == "+" } {
		    set from [lindex $e 2]/[lindex $e 1]
		    set to $dest/[lindex $e 1]
		    if { [file exists $to] } {
			if { [file writable $to] } {
			    msgprint -c WOKVC -i "Saving file $to in ${to}-sav"
			    wokUtils:FILES:copy $to ${to}-sav
			    msgprint -c WOKVC -i "Copying $from to $to"
			    wokUtils:FILES:copy $from $to
			} else {
			    msgprint -c WOKVC -e "File $to cannot be overwritten"
			}
		    } else {
			msgprint -c WOKVC -i "Copying $from to $to"
			wokUtils:FILES:copy $from $to
		    }
		}
	    }
	}
    }
    msgunsetcmd
    $IWOK_WINDOWS($w,label) configure -text "Workbench $IWOK_WINDOWS($w,WBPere) has been updated."
    return
}
;#
;# fait wstore avec comme report le contenu du texte 
;#
proc wokStoreThat { args } { 
    global IWOK_WINDOWS
    global IWOK_GLOBALS
    global wokfileid
    global env

    set w [lindex $args 0]
    set asfile [expr { ([lindex $args 1] != {}) ? 1 : 0 } ]

    set rep $env(HOME)/$IWOK_WINDOWS($w,WBFils).[id user].report
    set wokfileid [open $rep w]

    wokPrepare:Report:Output banner $IWOK_WINDOWS($w,shop) $IWOK_WINDOWS($w,WBFils)

    set suspect 0
    tixBusy $w on 
    update
    set hli $IWOK_WINDOWS($w,hlist)
    set pfx $IWOK_WINDOWS($w,shop):$IWOK_WINDOWS($w,WBFils)
    foreach U [$hli info children] {
	set T [uinfo -t ${pfx}:$U]
	wokPrepare:Report:Output uheader $U.$T
	foreach f [$hli info children $U] {
	    if { [lindex [$hli info data $f] 0] } {
		set suspect 1
	    }
	    set e [lindex [split $f ^] 1]
	    set fl [lindex $e 2]/[lindex $e 1]
	    set dat [fmtclock [file mtime $fl] "%d/%m/%y %R"]
	    eval wokPrepare:Report:Output files [linsert $e 1 $dat]
	}
    }

    tixBusy $w off
    catch { unset dummyvar }
    if { $IWOK_GLOBALS(comment,entered) } {
	puts  $wokfileid [append dummyvar is \n [wokTextToString $IWOK_WINDOWS($w,text)] end\; \n]
    } else {
	puts  $wokfileid [append dummyvar is \n $IWOK_GLOBALS(comment,string) end\; \n]
    }
    
    close $wokfileid
    catch {unset wokfileid}

    if { $asfile } { 
	$IWOK_WINDOWS($w,label) configure -text "File $rep has been created."
    } else {
	if { $suspect } {
	    set retval [wokDialBox .wokcd {Duplicate entries} \
		    "Storing this report will possibly erase entries in the integration queue." \
		    warning 1 {Store anyway} {Abort}]
	    if { $retval } {
		$IWOK_WINDOWS($w,label) configure -text "Abort..."
		return
	    }
	}
	tixBusy $w on
	$IWOK_WINDOWS($w,text) delete 0.0 end
	msgsetcmd wokMessageInText $IWOK_WINDOWS($w,text)
	if { $IWOK_WINDOWS($w,trig) != 0 } {
	     wstore -ws $IWOK_WINDOWS($w,shop) -trig $rep
	} else {
	    catch { wstore -ws $IWOK_WINDOWS($w,shop) $rep }
	}
	msgunsetcmd
	$IWOK_WINDOWS($w,label) configure -text "Report $rep has been stored."
	tixBusy $w off
    }

    return
}
;#
;# Bof ..
;#
proc wokSaveas { w } {
    wokStoreThat $w asfile
    return
}
;#
;#  
;#
proc wokEnterComment { w } {
    global IWOK_WINDOWS
    global IWOK_GLOBALS
    wokReadString $IWOK_WINDOWS($w,text) $IWOK_GLOBALS(comment,string)
    set IWOK_GLOBALS(comment,entered) 1
    wokActiveStore $w active
    return
}
;#
;#
;#
proc wokActiveStore { w state } {
    global IWOK_WINDOWS
    set IWOK_WINDOWS($w,trig) 0
    if [wokStore:Queue:Enabled $IWOK_WINDOWS($w,shop) $IWOK_WINDOWS($w,WBPere)] { 
	$IWOK_WINDOWS($w,store) configure -state $state -text "Store" \
		-command [list wokStoreThat $w]
	if { [info commands $IWOK_WINDOWS($w,actrig)] != {} } {
	    $IWOK_WINDOWS($w,actrig) configure -state $state
	}
    } else {
	$IWOK_WINDOWS($w,store) configure \
		-state $state -text "Update $IWOK_WINDOWS($w,WBPere)" \
		-command [list wokUpdateThat $w]
    }
    return
}


proc wokPrepareCheck { w } {
    global IWOK_WINDOWS
    $IWOK_WINDOWS($w,hlist) delete all
    $IWOK_WINDOWS($w,text) delete 1.0 end
    msgsetcmd wokMessageInText $IWOK_WINDOWS($w,text)
    tixBusy $w on
    update
    foreach item [$IWOK_WINDOWS($w,hlist2) info children] {
	set ud $IWOK_WINDOWS($w,shop):$IWOK_WINDOWS($w,WBFils):[lindex $item 1]
	wcheck  [uinfo -plTsource $ud]
    }
    tixBusy $w off
    msgunsetcmd
    [$IWOK_WINDOWS($w,button) subwidget search] configure -state active
    return
}



proc wokPrepareHelp { w } {
    global IWOK_GLOBALS
    global IWOK_WINDOWS
    global env

    set IWOK_WINDOWS($w,help) [set wh .wokPrepareHelp]
    if {[info exist IWOK_GLOBALS(windows)]} {
	if {[lsearch $IWOK_GLOBALS(windows) $wh ] == -1} {
	    lappend IWOK_GLOBALS(windows) $wh 
	}
    }

    set whelp [wokHelp $wh "About preparing a workbench"]
    set texte [lindex $whelp 0] ; set label [lindex $whelp 1]
    wokReadFile $texte  $env(WOK_LIBRARY)/wokPrepareHelp.hlp
    wokFAM $texte <.*> { $texte tag add big first last }
    $texte tag configure big -background Bisque3 -foreground black -borderwidth 2 \
	    -font -Adobe-Helvetica-Medium-R-Normal--*-120-* -relief raised
    update
    $texte configure -state disabled
    return
}
