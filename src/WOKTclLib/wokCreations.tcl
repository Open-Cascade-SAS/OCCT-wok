proc wokCreate { dir loc {asked_type {}} } { 
    global IWOK_GLOBALS

    if ![wokinfo -x $loc] return

    set mw .wokcreate
    if [winfo exists $mw] {
	destroy $mw
    }

    toplevel $mw
    wm geometry $mw +60+120

    set ent_type {}
    if { $asked_type == {} } {
	set tab([set tab([set tab([set tab(factory) workshop]) workbench]) devunit]) description
	set ent_type $tab([wokinfo -t $loc])
    } else {
	set ent_type $asked_type
    }
    
    
    set IWOK_GLOBALS(scratch) {}

    tixLabelFrame $mw.f -relief raised
    pack $mw.f -expand yes -fill both -padx 1 -pady 1

    set w [$mw.f subwidget frame]

    set img [label $w.img]

    tixLabelEntry $w.e -label "Name: " \
	    -options {
	entry.width 20
	entry.textVariable IWOK_GLOBALS(scratch)
    }

    tixButtonBox $w.box -orientation horizontal
    $w.box add ok -text Ok -underline 0 \
	    -command [list wokCreate:action $mw $dir $loc $ent_type] -width 6
    $w.box add cancel -text Cancel -underline 0 -command "destroy $mw" -width 6

    bind [$w.e subwidget entry]  <Return> {
	focus [[[winfo toplevel %W].f subwidget frame].box subwidget ok]
    }

    switch $ent_type {
	
	factory {
	}

	devunit {
	    $mw.f configure -label "Adding a unit in $loc."
	    tixOptionMenu $w.qt -command wokCreate:SetType -label "Type : " 
	    set mbu [$w.qt subwidget menubutton]
	    foreach I [linsert $IWOK_GLOBALS(ucreate-P)  end {z Zfile...}] {
		$w.qt  add command "$I $mbu" -label [lindex $I 1]
	    }
	    $w.qt subwidget menubutton configure -height 25 -width 136
	    tixForm $w.e -top 20
	    tixForm $w.qt -top $w.e -left 2 -bottom $w.box
	}

	workbench {
	    tixBusy $mw on
	    set image [tix getimage workbench]
	    $img configure -image $image
	    $mw.f configure -label "Adding a workbench in $loc."
	    set tree [tixTree $w.tree -options {hlist.separator "^" hlist.selectMode single }]
	    $tree config -browsecmd [list wokWbtree:UpdLab $tree]
	    set hli [$tree subwidget hlist]
	    set father [wokWbtree:LoadSons $loc [wokinfo -p WorkbenchListFile $loc]]
	    $hli delete all
	    $hli add ^
	    update
	    tixComboBox $w.fh -label "Father:" -variable IWOK_GLOBALS(scratch,father)
	    set IWOK_GLOBALS(scratch,father) $father
	    foreach ww [sinfo -w $loc] {
		$w.fh insert end $ww
	    }
	    $w.box add shotree -text "Show Tree" -underline 0 -width 8 \
		    -command [list wokWbtree:Tree $tree $hli "" $father $image]
	    tixForm $w.tree -left 2 -right %99 -top 20 -bottom $w.e 
	    tixForm $w.e -bottom $w.fh
	    tixForm $w.fh -bottom $w.box
	    tixBusy $mw off
	}

	workshop {
	    $img configure -image [tix getimage workshop]
	    $mw.f configure -label "Adding a workshop in $loc."
	    tixForm $img -left 2 -right %99 -top 8
	    tixForm $w.e -top $img -bottom $w.box 
	}

    }
    tixForm $w.box  -left 2 -right %99 -bottom %99

    return
}
#
# ent est l'adresse dans la hlist
#
proc wokWbtree:UpdLab { tree ent } {
    global IWOK_GLOBALS
    set hli [$tree subwidget hlist]
    set IWOK_GLOBALS(scratch,father) [$hli info data $ent]
    return
}

proc wokWbtree:Tree { tree hli ent name ima } {
    if {![$hli info exists ${ent}^${name}] } {
	$hli add ${ent}^${name} -itemtype imagetext -text $name -image $ima -data $name
	update
    }
    set lson [wokWbtree:GetSons $name] 
    foreach son $lson {
	if { "$son" != "$name" } {
	    if {![$hli info exists ${ent}^${name}^${son}] } {
		$hli add ${ent}^${name}^${son} -itemtype imagetext -text $son -image $ima -data $son
		wokWbtree:Tree $tree $hli ${ent}^${name} $son $ima
	    }
	}
    }
    return
}

proc wokWbtree:GetSons { wb } {
    if { [info procs ${wb}.woksons] != {} } {
	return [eval ${wb}.woksons]
    } else {
	return {}
    }
}

proc wokWbtree:LoadSons { ent WBLIST } {
    catch {unset TLOC}
    if [ file exists $WBLIST ] {
	set f [ open $WBLIST r ]
	while {[gets $f line] >= 0} {
	    set ll [split $line]
	    set son [lindex $ll 0]
	    set dad [lindex $ll 1]
	    if { $dad != {} } {
		if { ![info exists TLOC($dad)] } {
		    set TLOC($dad) $son
		} else {
		    set ii $TLOC($dad)
		    lappend ii $son
		    set TLOC($dad) $ii
		}   
	    } else {
		set TLOC($son) {}
		set root $son
	    }
	}
	close $f
    } else {
	set root {}
    }
    foreach x [array names TLOC] {
	eval "proc $x.woksons {} { return [list $TLOC($x)] }" 
    }
    return $root
}

proc wokCreate:action  { w dir loc cmd } {
    global IWOK_GLOBALS

    tixBusy $w on
    update
    if { $IWOK_GLOBALS(scratch) != {} } {
	
	switch $cmd {

	    factory {
	    }

	    devunit {
		if ![ catch { ucreate -$IWOK_GLOBALS(scratch,wokType) ${loc}:$IWOK_GLOBALS(scratch) } helas ] {
		    wbuild:Update
		    set s $IWOK_GLOBALS(scratch,wokType)
		    set type $IWOK_GLOBALS(S_L,$s)
		    wokNAV:Initdevunit ${loc}
		    wokNAV:Tree:Add $dir ${loc}:$IWOK_GLOBALS(scratch) $IWOK_GLOBALS(scratch) $type
		} else {
		    puts stderr "$helas"
		}
	    }

	    workbench {
		if { [string compare $IWOK_GLOBALS(scratch,father) -] == 0 } {
		    if ![ catch { wcreate -d $IWOK_GLOBALS(scratch)} helas ] {
			wokNAV:Tree:Add $dir ${loc}:$IWOK_GLOBALS(scratch) $IWOK_GLOBALS(scratch) $cmd
		    } else {
			puts stderr "$helas"
		    }
		} else {
		    set father ${loc}:$IWOK_GLOBALS(scratch,father)
		    if ![ catch { wcreate -f $father -d ${loc}:$IWOK_GLOBALS(scratch)} helas ] {
			wokNAV:Tree:Add $dir ${loc}:$IWOK_GLOBALS(scratch) $IWOK_GLOBALS(scratch) $cmd
		    } else {
			puts stderr "$helas"
		    }   
		}
	    }

	    workshop {
		if ![ catch { screate -d ${loc}:$IWOK_GLOBALS(scratch)} helas ] {
		    wokNAV:Tree:Add $dir ${loc}:$IWOK_GLOBALS(scratch) $IWOK_GLOBALS(scratch) $cmd
		} else {
		    puts stderr "$helas"
		}
	    }
	    
	}
	set IWOK_GLOBALS(scratch) {}
    } 
    tixBusy $w off
    destroy $w
    return
}

proc wokCreate:SetType { string } {
    global IWOK_GLOBALS
    regexp {(.*) (.*) (.*)} $string ignore IWOK_GLOBALS(scratch,wokType) longname w
    if { [string compare $IWOK_GLOBALS(scratch,wokType) z] != 0 } {
	set img [image create compound -window $w]
	$img add text -text $longname -underline 0
	$img add image -image [tix getimage $longname]
	$w config -image $img
    } else {
	wokCreate:Zfile $w
    }
    return
}

proc wokCreate:Zfile { ww } {
    global IWOK_GLOBALS
    global IWOK_WINDOWS
    set w [winfo toplevel $ww]
    foreach f [winfo children $w] {
	destroy $f
    }
    set fact [Sinfo -f]
    wm geometry $w 972x551
    menubutton $w.file -menu $w.file.m -text File -underline 0 -takefocus 0
    menu $w.file.m 
    $w.file.m add command -label "Close     " -underline 0 -command [list wokCreate:ZKill $w]

    frame $w.top -relief sunken -bd 1 
    label $w.lab -relief raised
    
    tixPanedWindow $w.top.pane -orient horizontal -paneborderwidth 0 -separatorbg gray50
    pack $w.top.pane -side top -expand yes -fill both -padx 10 -pady 10
    
    set p1 [$w.top.pane add tree -min 70 -size 250]
    set p2 [$w.top.pane add text -min 70]
    
    set tree  [tixTree  $p1.tree -options {separator "^" hlist.selectMode single}]
    $tree config -browsecmd "wokCreate:ZBrowse $w $tree" \
	    -opencmd "wokCreate:ZOpen $w $tree" \
	    -closecmd "wokCreate:ZClose $w $tree"
    
    tixScrolledText    $p2.text ; 
    set texte [$p2.text subwidget text]
    $texte config -font $IWOK_GLOBALS(font)

    pack $p1.tree -expand yes -fill both -padx 1 -pady 1
    pack $p2.text -expand yes -fill both -padx 1 -pady 1

    tixButtonBox $w.but -orientation horizontal -relief flat -padx 0 -pady 0
    set but [list \
	    {download  "DownLoad"          disabled  wokCreate:DownLoad} \
	    {list      "List contents"     disabled  wokCreate:List} ]

    foreach b $but {
	$w.but add [lindex $b 0] -text [lindex $b 1] 
	[$w.but subwidget [lindex $b 0]] configure -state [lindex $b 2] -command [list [lindex $b 3] $w]
    }

    tixForm $w.file
    ;#tixForm $w.help -right -2
    tixForm $w.top  -top $w.file -left 2 -right %99 -bottom $w.but
    tixForm $w.but -left 2 -bottom %99
    tixForm $w.lab -left $w.but -right %99 -bottom %99

    set IWOK_WINDOWS($w,hlist)  [$tree subwidget hlist]
    set IWOK_WINDOWS($w,text)   $texte
    set IWOK_WINDOWS($w,bag)    [wokinfo -f]:[finfo -W $fact]
    set IWOK_WINDOWS($w,curwb)  [wokinfo -w]
    set IWOK_WINDOWS($w,label)  $w.lab
    set IWOK_WINDOWS($w,button) $w.but

    set hlist [$tree subwidget hlist]
    $hlist delete all
    set image [tix getimage parcel]

    set bag $IWOK_WINDOWS($w,bag)
    set LB [Winfo -p $bag]
    foreach parcel $LB {
	if ![$IWOK_WINDOWS($w,hlist) info exists ${parcel}] {
	    $IWOK_WINDOWS($w,hlist) add ${parcel} -itemtype imagetext -text $parcel -image $image \
		    -data [list P $bag $parcel]
	    $tree setmode ${parcel} open
	}
    }
    return
}

proc wokCreate:ZClose { w tree ent } { 
    set hlist [$tree subwidget hlist]
    foreach kid [$hlist info children $ent] {
	$hlist hide entry $kid
    }
    $hlist entryconfigure $ent -image [tix getimage parcel]
    return
}

proc wokCreate:ZOpen { w tree ent } { 
    global IWOK_WINDOWS
    global IWOK_GLOBALS
    set hlist [$tree subwidget hlist]

    tixBusy $w on
    
    update
    if {[$hlist info children $ent] == {}} {
	set data [$hlist info data $ent]
	switch -- [lindex $data 0] {
	    
	    P {
		set bag [lindex $data 1]
		set pcl [lindex $data 2]
		foreach unit [pinfo -a ${bag}:${pcl}] {
		    set type [lindex $unit 0]
		    set name [lindex $unit 1]
		    $hlist add  ${ent}^${name} -itemtype imagetext -text $name \
			    -image $IWOK_GLOBALS(image,$type) \
			    -data $bag:${pcl}:$name
		}
	    }
	}
    }
    foreach kid [$hlist info children $ent] {
	$hlist show entry $kid
    }
    $hlist entryconfigure $ent -image [tix getimage delivery]
    tixBusy $w off
    return
}

proc wokCreate:ZBrowse { w tree args }  {
    global IWOK_WINDOWS
    set hlist [$tree subwidget hlist]
    set sc [split $args ^]
    set lsc [llength $sc]

    if { $lsc == 1 } {
	return
    }

    set ent   [$hlist info anchor]
    if {$ent == ""} {
	return
    }

    set kid [$hlist info children $ent]
    if {$kid == {} } {
	$IWOK_WINDOWS($w,text) delete 1.0 end	
	set Zf [wokCreate:Zsearch [uinfo -Fp -Tsource [$hlist info data $ent]]]
	if { [set IWOK_WINDOWS($w,Zpath) $Zf] != {} } {
	    set IWOK_WINDOWS($w,Zpath) $Zf
	    if [info exists IWOK_WINDOWS($w,Zwork)] {
		catch {unlink $IWOK_WINDOWS($w,Zwork)}
	    }
	    set IWOK_WINDOWS($w,Zwork) [wokUtils:FILES:SansZ $IWOK_WINDOWS($w,Zpath)]
	    $IWOK_WINDOWS($w,button) subwidget download configure -state active
	    $IWOK_WINDOWS($w,button) subwidget list     configure -state active
	} else {
	    $IWOK_WINDOWS($w,label) configure -text "This unit has no Z file"
	    $IWOK_WINDOWS($w,button) subwidget download configure -state disabled
	    $IWOK_WINDOWS($w,button) subwidget list     configure -state disabled
	}
    }
    return
}

proc wokCreate:DownLoad { w } {
    global IWOK_GLOBALS
    global IWOK_WINDOWS
    $IWOK_WINDOWS($w,text) delete 1.0 end
    tixBusy $w on
    update
    msgsetcmd wokMessageInText $IWOK_WINDOWS($w,text)
    if ![info exists IWOK_WINDOWS($w,Zwork)] {
	set IWOK_WINDOWS($w,Zwork) [wokUtils:FILES:SansZ $IWOK_WINDOWS($w,Zpath)]
    }
    set Z $IWOK_WINDOWS($w,Zwork)
    set lnam [split [file tail $Z] .]
    set udname [lindex $lnam 0]
    set tyname [lindex $lnam 1]
    set l_units [w_info -l $IWOK_WINDOWS($w,curwb)]
    if { [lsearch $l_units $udname] != -1 } {
	set retval [wokDialBox .wokcd {Already exists } \
		"The $tyname $udname already exists in $IWOK_WINDOWS($w,curwb)" \
		warning 1 {Overwrite} {Abort}]
	if { $retval } {
	    $IWOK_WINDOWS($w,label) configure -text "Abort..."
	    msgunsetcmd
	    tixBusy $w off
	    return
	}
    }
    
    if ![info exists retval] {
	msgprint -i "Creating $tyname $udname in $IWOK_WINDOWS($w,curwb)"
	if [catch { ucreate -$IWOK_GLOBALS(L_S,$tyname) $IWOK_WINDOWS($w,curwb):$udname }] {
	    msgprint -e "Unable to create $tyname $udname in $IWOK_WINDOWS($w,curwb)"
	    msgunsetcmd
	    tixBusy $w off
	    return
	}
    }

    set savloc [wokcd]
    wokcd $IWOK_WINDOWS($w,curwb):$udname
    catch { upack -v -r $Z }
    msgunsetcmd
    wokcd $savloc

    if [info exists IWOK_WINDOWS($w,Zwork)] {
	catch {unlink $IWOK_WINDOWS($w,Zwork)}
	unset IWOK_WINDOWS($w,Zwork)
    }

    tixBusy $w off
    return
}

proc wokCreate:List { w } {
    global IWOK_WINDOWS
    $IWOK_WINDOWS($w,text) delete 1.0 end
    if [info exists IWOK_WINDOWS($w,Zwork)] {
	tixBusy $w on
	update
	puts "1"
	msgsetcmd wokMessageInText $IWOK_WINDOWS($w,text)
	puts "2 $IWOK_WINDOWS($w,Zwork)"
	upack -l $IWOK_WINDOWS($w,Zwork)
	puts "3"
	msgunsetcmd
	$IWOK_WINDOWS($w,label) configure -text "Contents of file $IWOK_WINDOWS($w,Zpath)"
	tixBusy $w off
    }
    return
}

proc wokCreate:ZKill { w } {
    global IWOK_WINDOWS
    if [info exists IWOK_WINDOWS($w,Zwork)] {
	catch {unlink $IWOK_WINDOWS($w,Zwork)}
    }
    foreach v [array names IWOK_WINDOWS $w,*] {
	unset IWOK_WINDOWS($v)
    }
    destroy $w
    return
}

proc wokCreate:Zsearch { l } {
    foreach f $l {
	if { "[file extension [lindex $f 1]]" == ".Z" } {
	    return [lindex $f 2]
	}
    }
    return {}
}
