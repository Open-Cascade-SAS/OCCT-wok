#
# Convert a date 
# 07/03/96 11:55 => "07 Mar 96 11:55"
#
proc wokUtils:TIME:dpe { dpedateheure } {
    set dt(01) Jan;set dt(02) Feb;set dt(03) Mar;set dt(04) Apr;set dt(05) May;set dt(06) Jun 
    set dt(07) Jul;set dt(08) Aug;set dt(09) Sep;set dt(10) Oct;set dt(11) Nov;set dt(12) Dec
    regexp {(.*)/(.*)/(.*) (.*)} $dpedateheure ignore day mth yea hour
    return [convertclock "$day $dt($mth) $yea $hour"]
}
#
# Returs the list of files in dir newer than date
#
proc wokUtils:FILES:Since { dir {date "00:00:00" }} {
    set lim [clock scan $date]
    set l {}
    foreach file [ readdir $dir ] {
	if { [file mtime $dir/$file] > $lim } {
	    lappend l $file
	}
    }
    return $l
}
#
# returns a list:
# First is the date and time of more recent file in dir
# Second is the accumulate size of all files
#
proc wokUtils:FILES:StatDir { dir } {
    set s 0
    set m [file mtime $dir]
    foreach f [glob -nocomplain $dir/*] {
	incr s [file size $f]
	if { [set mf [file mtime $f]] > $m } {
	    set m $mf
	}
    }
    return [list $m $s]
}
#
# Returns results > 0 if f1 newer than f2 
#
proc wokUtils:FILES:IsNewer { f1 f2 } {
    return [ expr [file mtime $f1] - [file mtime $f2] ]
}
#
# Write in table(file) the list of directories of ldir that contains file
#
proc wokUtils:FILES:Intersect { ldir table } {
    upvar $table TLOC
    foreach r $ldir {
	foreach f [readdir $r] {
	    if [info exists TLOC($f)] {
		set l $TLOC($f)
	    } else {
		set l {}
	    }
	    lappend l $r
	    set TLOC($f) $l
	}
    }
    return
}
#
# Returns 1 if name does not begin with -
#
proc wokUtils:FILES:ValidName { name } {
    return [expr ([regexp {^-.*} $name]) ? 0 : 1]
}
#
# Read file pointed to by path
# 1. sort = 1 tri 
# 2. trim = 1 plusieurs blancs => 1 seul blanc
# 3. purge= not yet implemented.
# 4. emptl= dont process blank lines
#
proc wokUtils:FILES:FileToList { path {sort 0} {trim 0} {purge 0} {emptl 1} } {
    if ![ catch { set id [ open $path r ] } ] {
	set l  {}
	while {[gets $id line] >= 0 } {
	    if { $trim } {
		regsub -all {[ ]+} $line " " line
	    }
	    if { $emptl } {
		if { [string length ${line}] != 0 } {
		    lappend l $line
		}
	    } else {
		lappend l $line
	    }
	}
	close $id
	if { $sort } {
	    return [lsort $l]
	} else {
	    return $l
	}
    } else {
	return {}
    }
}
;#
;# Unix like find, return a list of names.
;#
proc wokUtils:FILES:find { dirlist gblist } {
    set result {}
    set recurse {}
    foreach dir $dirlist {
        foreach ptn $gblist {
            set result [concat $result [glob -nocomplain -- $dir/$ptn]]
        }
        foreach file [readdir $dir] {
            set file $dir/$file
            if [file isdirectory $file] {
                set fileTail [file tail $file]
                if {!(($fileTail == ".") || ($fileTail == ".."))} {
                    lappend recurse $file
                }
            }
        }
    }
    if ![lempty $recurse] {
        set result [concat $result [wokUtils:FILES:find $recurse $gblist]]
    }
    return $result
}
;#
;# Returns a list representation for a directory tree 
;# l = { r {sub1 .. subn} } where sub1 .. subn as l
;#
proc wokUtils:FILES:DirToTree { d } { 
    set flst ""
    set pat [file join $d *]
    foreach f [ lsort [ glob -nocomplain $pat]] {
	if [file isdirectory $f] { 
	    set cts [wokUtils:FILES:DirToTree $f]
	} else {
	    set cts ""
	}
	lappend flst [list [file tail $f] $cts]
    } 
    return $flst
}
;#
;# Write in map all directories under d. Each index is a directory name ( trimmed by d).
;# Contents of index is the list of files in that directory
;#
proc wokUtils:FILES:DirToMap { d map {tail 0} } { 
    upvar $map TLOC
    catch { unset TLOC }
    set l [wokUtils:FILES:find $d *]
    set TLOC(.) {}
    foreach e $l {
	if { [file isdirectory $e] } {
	    if [regsub -- $d $e "" k] {
		set TLOC($k) {}
	    } else {
		puts "Error regsub  -- $d $e"
	    }
	} else {
	    set dir [file dirname $e]
	    if [regsub -- $d $dir "" k] {
		if { $k == {} } {
		    set k .
		}
		if [info exists TLOC($k)] {
		    set l $TLOC($k)
		    lappend l $e
		    set TLOC($k) $l
		} else {
		    set TLOC($k) $e
		}
	    } else {
		puts "Error regsub  -- $d $dir"
	    }
	}
    }

    if { $tail == 0 } { return }

    foreach x [array names TLOC] {
	set l {}
	foreach e $TLOC($x) {
	    lappend l [file tail $e]
	}
	set TLOC($x) $l
    }

    return
}
;#
;# Same as above but write a Tcl proc to perform it. Proc has 1 argument. the name of the map.
;# 
proc wokUtils:FILES:DirMapToProc { d TclFile ProcName } { 
    catch { unset TLOC }
    wokUtils:FILES:DirToMap $d TLOC 1
    if ![ catch { set id [ open $TclFile w ] } errout ] {
	puts $id "proc $ProcName { map } {"
	puts $id "upvar \$map TLOC"
	foreach x [array names TLOC] {
	    puts $id "set TLOC($x) {$TLOC($x)}"
	}
	puts $id "return"
	puts $id "}"
	close $id
	return 1
    } else {
	puts stderr "$errout"
	return -1
    }
}

#
# Concat all files in lsfiles. Writes the result in result
#
proc wokUtils:FILES:concat { result lstfile } {
    if ![ catch { set id1 [ open $result a ] } errout ] {
	foreach file2 $lstfile {
	    if ![ catch { set id2 [ open $file2 r ] } ] {
		puts $id1 [read -nonewline $id2]
	    }
	    close $id2
	}
	close $id1
	return 1
    } else {
	puts stderr "$errout"
	return -1
    }
}
#
# returns the concatenation of lines in file <path> i.e. with the following rules:
# If a line has format:<mark> <string> then calls func with args to get a full path
# In all the case, append the string as is.
#
# Ex: wokUtils:FILES:rconcat [pwd]/file @ myfunc MS source
# 
# with 
#
#proc myfunc { basename_file args } {
#    set  ud  [lindex $args 0]
#    set type [lindex $args 1]
#    return   [woklocate -f ${ud}:${type}:${basename_file}]
#}
#
proc wokUtils:FILES:rconcat { path mark func args } {
    if ![ catch { set id [ open $path r ] } errin ] {
	while {[gets $id line] >= 0 } {
	    set sl [split $line]
	    if { "[lindex $sl 0]" == "$mark" } {
		set file [eval $func [lindex $sl 1] $args]
		append str [eval wokUtils:FILES:rconcat $file $mark $func $args] 
	    } else {
		append str $line \n
	    }
	}
	close $id
	return $str
    } else {
	puts stderr "Error : $errin"
	return ""
    }
}
#
# Creates a file. If string is not {} , writes it.
# 
proc wokUtils:FILES:touch { path { string {} } { nonewline {} } } {
    if [ catch { set id [ open $path w ] } status ] {
	puts stderr "$status"
	return 0
    } else {
	if { $string != {} } {
	    if { $nonewline != {} } {
		puts -nonewline $id $string
	    } else {
		puts $id $string
	    }
	}
	close $id
	return 1
    }
}
#
# Writes a list in path.
# 
proc wokUtils:FILES:ListToFile { liste path } {
    if [ catch { set id [ open $path w ] } ] {
	return 0
    } else {
	foreach e $liste {
	    puts $id $e
	}
	close $id
	return 1
    }
}
#
# l1 U l2 
#
proc wokUtils:LIST:union { l1 l2 } {
    set l {}
    foreach e [concat $l1 $l2] {
	if { [lsearch $l $e] == -1 } {
	    lappend l $e
	} 
    }
    return $l
}
#
# l1 - l2
#
proc wokUtils:LIST:moins { l1 l2 } {
    set l {}
    foreach e $l1 {
	if { [lsearch $l2 $e] == -1 } {
	    lappend l $e
	}
    }
    return $l
}
#
# Do something i cannot remenber, 
# 
proc wokUtils:LIST:subls { list } {
    set l {}
    set len [llength $list]
    for {set i 0} {$i < $len} {incr i 1} {
	lappend l [lrange $list 0 $i]
    }
    return $l
}
#
# { 1 2 3 } =>  { 3 2 1 }
#
proc wokUtils:LIST:reverse { list } { 
    set ll [llength $list]
    if { $ll == 0 } {
	return
    } elseif { $ll == 1 } {
	return $list
    } else {
	return [concat [wokUtils:LIST:reverse [lrange $list 1 end]] [list [lindex $list 0]]]
    }
}
#
# flat a list: { a {b c} {{{{d}}}e } etc.. 
#            =>   { a b c d e }
#
proc wokUtils:LIST:flat { list } {
    if { [llength $list] == 0 } {
	return {}
    } elseif { [llength [lindex $list 0]] == 1 } {
	return [concat [lindex $list 0] [wokUtils:LIST:flat [lrange $list 1 end]]]
    } elseif { [llength [lindex $list 0]] > 1 } {
	return [concat [wokUtils:LIST:flat [lindex $list 0]] [wokUtils:LIST:flat [lrange $list 1 end]]]
    }
}
#
# returns 3 lists l1-l2 l1-inter-l2 l2-l1
#
proc wokUtils:LIST:i3 { l1 l2 } {
    set a1(0) {} ; unset a1(0)
    set a2(0) {} ; unset a2(0)
    set a3(0) {} ; unset a3(0)
    foreach v $l1 {
        set a1($v) {}
    }
    foreach v $l2 {
        if [info exists a1($v)] {
            set a2($v) {} ; unset a1($v)
        } {
            set a3($v) {}
        }
    }
    list [lsort [array names a1]] [lsort [array names a2]]  [lsort [array names a3]]
}
#
# returns all elements of list matching of the expr in lexpr
# Ex: GM [glob *] [list *.tcl *.cxx A*.c]
#
proc wokUtils:LIST:GM { list lexpr } {
    set l {}
    foreach expr $lexpr {
	foreach e $list {
	    if [string match $expr $e] {
		if { [lsearch $l $e] == -1 } {
		    lappend l $e
		}
	    }
	}
    }
    return $l
}
#
# returns the longer prefix that begin with str in inlist ( Completion purpose.)
#
proc wokUtils:LIST:POF { str inlist } {
    set list {}
    foreach e $inlist {
	if {[string match $str* $e]} {
	    lappend list $e
	}
    }
    if { $list == {} } {
	return [list {} {}]
    }
    set l [expr [string length $str] -1]
    set miss 0
    set e1 [lindex $list 0]
    while {!$miss} {
	incr l
	if {$l == [string length $e1]} {
	    break
	}
	set new [string range $e1 0 $l]
	foreach f $list {
	    if ![string match $new* $f] {
		set miss 1
		incr l -1
		break
	    }
	}
    }
    set match [string range $e1 0 $l]
    set newlist {}
    foreach e $list {
	if {[string match $match* $e]} {
	    lappend newlist $e
	}
    }
    return [list $match $newlist]
}
#
# pos = 1 {{a b c } x} => { {x a} {x b} {x c} } default
# pos = 2 {{a b c } x} => { {a x} {a x} {a x} }
#
proc wokUtils:LIST:pair { l e {pos 1}} {
    set r {}
    if { $pos == 1 } {
	foreach x $l {
	    lappend r [list $e $x ]
	}
    } else {
	foreach x $l {
	    lappend r [list $x $e ]
	}
    }

    return $r
}
#
# { {x a} {x b} {x c} } => {a b c}
#
proc wokUtils:LIST:unpair { ll } {
    set r {}
    foreach x $ll {
	lappend r [lindex $x 1]
    }
    return $r
}
#
# keep in list of form ll = { {x a} {x b} {x c} } all elements which "cdr lisp" is in l
#
proc wokUtils:LIST:selectpair { ll l } {
    set rr {}
    foreach x $ll {

	if { [lsearch $l [lindex $x 1]] != -1 } {
	    lappend rr $x
	}
    }
    return $rr
}
#
# sort a list of pairs
#
proc wokUtils:LIST:Sort2 { ll } {
    catch { unset tw }
    foreach x $ll {
	set e [lindex $x 0]
	if [info exists tw($e)] {
	    set lw $tw($e)
	    lappend lw [lindex $x 1]
	    set tw($e) $lw
	} else {
	    set tw($e) [lindex $x 1]
	}
    }
    set l {}
    foreach x  [lsort [array names tw]] {
	foreach y [lsort $tw($x)] {
	    lappend l [list $x $y]
	}
    }
    return $l
}
#
# Purge a list. Dont modify order
#
proc wokUtils:LIST:Purge { l } {
    set r {}
     foreach e $l {
	 if ![info exist tab($e)] {
	     lappend r $e
	     set tab($e) {}
	 } 
     }
     return $r
}
#
# trim a list
#
proc wokUtils:LIST:Trim { l } {
    set r {}
    foreach e $l {
	if { $e != {} } {
	    set r [ concat $r $e]
	}
    }
    return $r
}
#
# truncates all strings in liststr which length exceed nb char
# 
proc wokUtils:LIST:cut { liststr {nb 10} } {
    set l {}
    foreach str $liststr {
	set len [string length $str]
	if { $len <= [expr $nb + 2 ]} {
	    lappend l $str
	} else {
	    lappend l [string range $str 0 $nb]..
	}
    }
    return $l
}
#
# compares 2 lists of fulls pathes (master and revision) and fill table with the following format
# table(simple.nam) {flag path1 path2}
# flag = + => simple.nam in master but not in revision 
# flag = ? => simple.nam in master and in revision (files should be further compared)
# flag = - => simple.nam in revision but not in master 
#
proc wokUtils:LIST:SimpleDiff { table master revision {gblist {}} } {
    upvar $table TLOC
    catch {unset TLOC}
    foreach e $master {
	set key [file tail $e]
	if { $gblist == {} } {
	    set TLOC($key) [list - [file dirname $e]]
	} elseif { [lsearch $gblist [file extension $key]]  != -1 } { 
	    set TLOC($key) [list - [file dirname $e]]
	}
    }
    foreach e $revision {
	set key [file tail $e]
	set dir [file dirname $e]
	if { $gblist == {} } {
	    if { [expr { ( [lsearch -exact [array names TLOC] $key] == -1 ) ? 0 : 1 }] } {
		set TLOC($key) [list ? [lindex $TLOC($key) 1] $dir]
	    } else {
		set TLOC($key) [list + $dir]
	    }
	} elseif { [lsearch $gblist [file extension $key]]  != -1 } { 
	    if { [expr { ( [lsearch -exact [array names TLOC] $key] == -1 ) ? 0 : 1 }] } {
		set TLOC($key) [list ? [lindex $TLOC($key) 1] $dir]
	    } else {
		set TLOC($key) [list + $dir]
	    }
	}
    }
    return
}
#
# modify table ( created by wokUtils:LIST:SimpleDiff) as follows:
# substitues flag ? by = if function(path1,path2) returns 1 , by # if not
# all indexes in tbale are processed.
#
proc wokUtils:LIST:CompareAllKey { table function } {
    upvar $table TLOC
    foreach e [array names TLOC] {
	set flag [lindex $TLOC($e) 0]
	set f1 [lindex $TLOC($e) 1]/$e
	set f2 [lindex $TLOC($e) 2]/$e
	if { [string compare $flag ?] == 0 } {
	    if { [$function $f1 $f2] == 1 } {
		set TLOC($e) [list = $f1 $f2]
	    } else {
		set TLOC($e) [list # $f1 $f2]
	    }
	}
    }
}
#
# Same as above but only indexex in keylist are processed.
# This proc to avoid testing each key in the above procedure
#  
proc wokUtils:LIST:CompareTheseKey { table function keylist } {
    upvar $table TLOC
    foreach e [array names TLOC] {
	if  { [expr { ([lsearch -exact $keylist $e] != -1) ? 1 : 0}] } {
	    set flag [lindex $TLOC($e) 0]
	    set f1 [lindex $TLOC($e) 1]/$e
	    set f2 [lindex $TLOC($e) 2]/$e
	    if { [string compare $flag ?] == 0 } {
		if { [$function $f1 $f2] == 1 } {
		    set TLOC($e) [list = $f1 $f2]
		} else {
		    set TLOC($e) [list # $f1 $f2]
		}
	    }
	} else {
	    unset TLOC($e)
	}
    }
    return
}
#
# same as array set, i guess
#
proc wokUtils:LIST:ListToMap { name list2 } {
    upvar $name TLOC 
    foreach f $list2 {
	set TLOC([lindex $f 0]) [lindex $f 1]
    }
    return
}
#
# reverse 
#
proc wokUtils:LIST:MapToList { name {reg *}} {
    upvar $name TLOC 
    set l {}
    foreach f [array names TLOC $reg] {
	lappend l [list $f $TLOC($f)]
    }
    return $l
}
#
# Same as wokUtils:LIST:ListToMap. For spurious reason
#
proc wokUtils:LIST:MapList { name list2 } {
    upvar $name TLOC 
    foreach f $list2 {
	set TLOC([lindex $f 0]) [lindex $f 1]
    }
    return
}

# 
# Applique le test Func sur l'element index de list 
#
proc wokUtils:LIST:Filter { list Func {index 0} } {
    set l {}
    foreach e $list {
	if { [$Func [lindex $e $index]] } {
	    lappend l $e
	}
    }
    return $l
}
#
# Compares 2 full pathes for TEXT ASCII files. Returs 1 if identicals 0 ifnot
#
proc wokUtils:FILES:AreSame { f1 f2 } {
    set ls1 [file size $f1]
    set ls2 [file size $f2]
    if { $ls1 == $ls2 } {
	set id1 [open $f1 r] 
	set id2 [open $f2 r]
	set s1 [read $id1 $ls1]
	set s2 [read $id2 $ls2]
	close $id1
	close $id2
	if { $s1 == $s2 } {
	    return 1
	} else {
	    return 0
	}
	
    } else {
	return 0 
    }
}
#
# Renvoie 1 si wb est une racine 0 sinon
#
proc wokUtils:WB:IsRoot { wb } {
    return [expr { ( [llength [w_info -A $wb]] > 1 ) ? 0 : 1 }]
}
#
# Copy file
#
proc wokUtils:FILES:copy { fin fout } {
    if { [catch { set in [ open $fin r ] } errin] == 0 } {
        if { [catch { set out [ open $fout w ] } errout] == 0 } {
	    set nb [copyfile $in $out]
	    close $in 
	    close $out
	    return $nb
	} else {
	    puts stderr "Error: $errout"
	    return -1
	}
    } else {
	    puts stderr "Error: $errin"
	return -1
    }
}
#
# Returns a list of selected files
#
proc wokUtils:FILES:ls  { dir {select all} } {
    set l {}
    if { [file exists $dir] } {
	foreach f [readdir $dir] {
	    set e [file extension $f]
	    switch -- $select {
		all {
		    if {![regexp {[^~]~$} $f] && ![string match *.*-sav* $e]} {
			lappend l $f 
		    }
		}
		
		cdl {
		    if { [string compare $e .cdl] == 0 } {
			lappend l $f 
		    }
		}
		
		cxx {
		    if { [string compare $e .cxx] == 0 } {
			lappend l $f
		    }
		}
		
		others {
		    if { [string compare $e .cdl] !=0 && [string compare $e .cxx] != 0 } {
			lappend l $f
		    }
		}
		
	    }
	}
    }
    return  [lsort $l]
}
#
# Compress /decompress fullpath
#
proc wokUtils:FILES:compress { fullpath } {
    if [catch {exec compress -f $fullpath} status] {
	puts stderr "Error while compressing ${fullpath}: $status"
	return -1
    } else {
	return 1
    }
}
proc wokUtils:FILES:uncompress { fullpath } {
    if [catch {exec uncompress -f $fullpath} status] {
	puts stderr "Error while uncompressing ${fullpath}: $status"
	return -1
    } else {
	return 1
    }
}

#
# Uncompresse if applicable Zin in dirout, returns the full path of uncompressed file
# ( if Zin is not compresses returns Zin)
# returns -1 if an error occured
#
proc wokUtils:FILES:SansZ { Zin } {
    if { [file exists $Zin] } {
	if {[string compare [file extension $Zin] .Z] == 0 } {
	    set dirout [wokUtils:FILES:tmpname {}]
	    set bnaz [file tail $Zin]
	    if { [string compare $Zin $dirout/$bnaz] != 0 } {
		wokUtils:FILES:copy $Zin $dirout/$bnaz
	    }
	    if { [wokUtils:FILES:uncompress $dirout/$bnaz] != -1 } {
		return $dirout/[file root $bnaz]
	    } else {
		return -1
	    }
	} else {
	    return $Zin
	}
    } else {
	puts stderr "Error: $Zin does not exists."
	return -1
    }
}
#
# uuencode
#
proc wokUtils:FILES:uuencode { fullpathin fullpathout {codename noname}} {
    if {[string compare $codename noname] == 0} {
	set codename [file tail $fullpathin]
    }
    if [catch {exec uuencode $fullpathin $codename > $fullpathout } status] {
	puts stderr "Error while encoding ${fullpathin}: $status"
	return -1
    } else {
	return 1
    }
}
#
# uudecode
#
proc wokUtils:FILES:uudecode { fullpathin {dirout noname}} {
    if {[string compare $dirout noname] == 0} {
	set dirout [file dirname $fullpathin]
    }
    set savpwd [pwd]
    cd $dirout
    if [catch {exec uudecode $fullpathin} status] {
	set ret -1
    } else {
	set ret 1
    }
    cd $savpwd
    return $ret
}
#
# Returns something != -1 if file must be uuencoded
#
proc wokUtils:FILES:Encodable { file } {
    return [lsearch {.xwd .rgb .o .exe .a .so .out .Z .tar} [file extension $file]]
}
# 
# remove a directory. One level. Very ugly procedure. Do not use.
# Bricolage pour que ca marche sur NT.
# 
proc wokUtils:FILES:removedir { d } {
    global env
    global tcl_platform
    if { "$tcl_platform(platform)" == "unix" } {
	if { [file exists $d] } {
	    foreach f [readdir $d] {
		unlink -nocomplain $d/$f
	    }
	    rmdir -nocomplain $d 
	}
    } elseif { "$tcl_platform(platform)" == "windows" } {
	if { [file exists $d] } {
	    foreach f [readdir $d] {
		file delete $d/$f
	    }
	    file delete $d 
	    
	}
    }
    return 
}
#
# returns a string used for temporary directory name
#
proc wokUtils:FILES:tmpname { name } {
    global env
    global tcl_platform
    if { "$tcl_platform(platform)" == "unix" } {
	return [file join /tmp $name]
    } elseif { "$tcl_platform(platform)" == "windows" } {
	return [file join $env(TMP) $name]
    }
    return {}
}
#
# userid. 
#
proc wokUtils:FILES:Userid { file } {
    global env
    global tcl_platform
    if { "$tcl_platform(platform)" == "unix" } {
	file stat $file myT
	if ![ catch { id convert userid $myT(uid) } result ] {
	    return $result
	} else {
	    return unknown
	}
    } elseif { "$tcl_platform(platform)" == "windows" } {
	return unknown
    }
}
#
# Try to supply a nice diff utility name
#
proc wokUtils:FILES:MoreDiff { } {
    global tcl_platform
    if { "$tcl_platform(platform)" == "unix" } {
	if [wokUtils:EASY:INPATH xdiff] {
	    return xdiff
	} else {
	    return {}
	}
    } elseif { "$tcl_platform(platform)" == "windows" } {
	return windiff
    } else {
	return {}
    }
}
#
# dirtmp one level
#
proc wokUtils:FILES:dirtmp { tmpnam } {
    if [file exist $tmpnam] {
	wokUtils:FILES:removedir $tmpnam
    }
    mkdir $tmpnam
    return 
}    
#
# Doc
#
proc wokH { reg } {
    global auto_index
    set maxl 0
    set l {}
    foreach name [lsort [array names auto_index $reg]] {
	lappend l $name
	if {[string length $name] > $maxl} {
	    set maxl [string length $name]
	}
    }
    foreach name [lsort $l] {
	puts stdout [format "%-*s = %s" $maxl  $name [lindex $auto_index($name) 1]]
    }
    return
}
#
# Easy  1. Stupid. Dont use
#
proc wokUtils:EASY:Apply { f l } {
    if { $l != {} } {
	$f [lindex $l 0]
	wokUtils:EASY:Apply $f [lrange $l 1 end]
	return
    }
}
#
# Very,very,very,very,very useful
#
proc wokUtils:EASY:GETOPT { prm table tablereq usage listarg } {

    upvar $table TLOC $tablereq TRQ $prm PARAM
    catch {unset TLOC}

    set fill 0

    foreach e $listarg {
	if [regexp {^-.*} $e opt] {
	    if [info exists TRQ($opt)] {
		set TLOC($opt) {}
		set fill 1
	    } else {
		puts stderr "Error: Unknown option $e"
		eval $usage
		return -1
	    }
	} else {
	    if [info exist opt] {
		set fill [regexp {value_required:(.*)} $TRQ($opt) all typ]
		if { $fill } {
		    if { $TLOC($opt) == {} } {
			set TLOC($opt) $e
			set fill 0
		    } else {
			lappend PARAM $e
		    }
		} else {
		    lappend PARAM $e
		}
	    } else {
		lappend PARAM $e
	    }
	}
    }

    if [array exists TLOC] {
	foreach e [array names TLOC] {
	    if { [regexp {value_required:(.*)} $TRQ($e) all typ ] == 1 } {
		if { $TLOC($e) == {} } {
		    puts "Error: Option $e requires a value"
		    eval $usage
		    return -1
		}
		switch -- $typ {
		    
		    file {
		    }
		    
		    string {
		    }
		    
		    date {
		    }
		    
		    list {
			set TLOC($e) [split $TLOC($e) ,]
		    }
		    
		    number {
			if ![ regexp {^[0-9]+$} $TLOC($e) n ] {
			    puts "Error: Option $e requires a number."
			    eval $usage
			    return -1
			}
		    }
		    
		}
		
	    }
	}
    } else {
	foreach d [array names TRQ] {
	    if { "$TRQ($d)" == "default" } {
		set TLOC($d) {}
	    }
	}
    }
    
    return
}
;#
;# Disallow 2 qualifiers
;#
proc wokUtils:EASY:DISOPT  { tabarg tbldis usage } {
    upvar $tabarg TARG $tbldis TDIS
    set largs [array names TARG]
    foreach o $largs {
	if [info exists TDIS($o)] {
	    set lo $TDIS($o)
	    foreach y $largs {
		if { [set inx [lsearch $lo $y]] != -1 } {
		    puts "Option $o and [lindex $lo $inx] are mutually exclusive."
		    eval $usage
		    return -1
		}
	    }
	}
    }
    return
}
;#
;#
;#
proc wokUtils:EASY:Check_auto_path { auto_path } {
    foreach d [wokUtils:LIST:Purge $auto_path] {
	if [file exists $d/tclIndex] {
	    puts "tclIndex     in  $d"
	} elseif [file exists $d/pkgIndex.tcl] {
	    puts "pkgIndex.tcl in  $d"
	} else {
	    puts "ERROR:       $d"
	}
    }
    return
}

#
# string trim does not work. Do it 
# 
proc wokUtils:EASY:sb { str } {
    set a ""
    set len [string length $str]
    for {set i 0} {$i < $len} {incr i 1} {
	set x [string index $str $i]
	if { $x != " " } {
	    append a $x
	}
    }
    return $a
}
#
# returns 1 if exec is in the path
#
proc wokUtils:EASY:INPATH { exec } {
    if { [set x [auto_execok $exec]] != {} } {
	if { $x != 0 } {
	    return 1
	}
    }
    return 0
}
#
# Insert a MAP in an other MAP to the index here
#
proc wokUtils:EASY:MAD { table here t } {
    upvar $table TLOC $t tin
    foreach hr [array names TLOC ${here}*] {
	catch { unset TLOC($hr)}
    }
    foreach v [array names tin] {
	set TLOC($here,$v) $tin($v)
    }
}
#
# Exec command. VERBOSE = 1 et WATCHONLY 1 => display but dont execute
#
proc wokUtils:EASY:command { command {VERBOSE 0} {WATCHONLY 0} } {
    if { $VERBOSE } {
	puts stderr "Exec: $command"
    }
    if { $WATCHONLY } {
	return [list 1 1]
    }
    if [catch {eval exec $command} status] {
	puts stderr "Error in command: $command"
	puts stderr "Status          : $status"
	return [list -1 $status]
    } else {
	return [list 1 $status]
    }
}
#
# tar
# Examples:
#
#  tarfromroot: 
#
#               wokUtils:EASY:tar tarfromroot  /tmp/yan.tar .
#               wokUtils:EASY:tar tarfromroot  [glob ./*.tcl]
#
#  tarfromlist: 
#
#               wokUtils:EASY:tar tarfromliste /tmp/yan.tar /tmp/LISTE
#               (si LISTE = basenames => tous les fichiers dans le repertoire courant)
#               (si LISTE = fullpathes => ya des fulls path dans le tar)
#
#  untar      :
#
#               wokUtils:EASY:tar untar /tmp/yan.tar 
#               
#  untarZ     : 
#
#               wokUtils:EASY:tar untarZ /tmp/yan.tarZ
# 
proc wokUtils:EASY:tar { option args } {
    
    catch { unset command return_output }
    
    switch -- $option {
	
	tarfromroot {
	    set name [lindex $args 0]
	    set root [lindex $args 1]
	    append command {tar cf } $name " " $root
	}
	
	tarfromliste {
	    set name [lindex $args 0]
	    set list [lindex $args 1]
	    if [file exists $list] {
		set liste [wokUtils:FILES:FileToList [lindex $args 1]]
		append command  {tar cf } $name
		foreach f $liste {
		    append command " " $f
		}
	    } else {
		error "File $list not found"
		return -1
	    }
	}
	
	untar {
	    set name [lindex $args 0]
	    append command {tar xof } $name
	}
	
	untarZ {
	    set name [lindex $args 0]
	    append command uncompress { -c } $name { | tar xof - >& /dev/null }
	}


	ls {
	    set return_output 1
	    set name [lindex $args 0]
	    append command {tar tvf } $name
	}

	lsZ {
	    set return_output 1
	    set name [lindex $args 0]
	    append command uncompress { -c } $name { | tar tvf - }
	}

    }
    
    ;#puts "command = $command"
    
    if [catch {eval exec $command} status] {
	puts stderr "Tar Error in command: $command"
	puts stderr "Status          : $status"
	set statutar -1
    } else {
	if [info exist return_output] {
	    set statutar $status
	} else {
	    set statutar 1
	}
    }

    return $statutar
}
;#
;# topological sort. returns a list.
;#wokUtils:EASY:tsort {  {a h} {b g} {c f} {c h} {d i}  }
;#               => { d a b c i g f h }
proc wokUtils:EASY:tsort { listofpairs } {
    foreach x $listofpairs {
	set e1 [lindex $x 0]
	set e2 [lindex $x 1]
	if ![info exists pcnt($e1)] {
	    set pcnt($e1) 0
	}
	if ![ info exists pcnt($e2)] {
	    set pcnt($e2) 1
	} else {
	    incr pcnt($e2)
	}
	if ![info exists scnt($e1)] {
	    set scnt($e1) 1
	} else {
	    incr scnt($e1)
	}
	set l {}
	if [info exists slist($e1)] {
	    set l $slist($e1)
	}
	lappend l $e2
	set slist($e1) $l
    }
    set nodecnt 0
    set back 0
    foreach node [array names pcnt] {
	incr nodecnt
	if { $pcnt($node) == 0 } {
	    incr back
	    set q($back) $node
	}
	if ![info exists scnt($node)] {
	    set scnt($node) 0
	}
    }
    set res {}
    for {set front 1} { $front <= $back } { incr front } {
	lappend res [set node $q($front)]
	for {set i 1} {$i <= $scnt($node) } { incr i } {
	    set ll $slist($node)
	    set j [expr {$i - 1}]
	    set u [expr { $pcnt([lindex $ll $j]) - 1 }]
	    if { [set pcnt([lindex $ll $j]) $u] == 0 } {
		incr back
		set q($back) [lindex $ll $j]
	    }
	}
    }
    if { $back != $nodecnt } {
	puts stderr "input contains a cycle"
	return {}
    } else {
	return $res
    }
}
#
#
#
proc wokUtils:EASY:OneHead { str len } {
    return  $str[replicate " " [expr { $len - [string length $str] }]]
}
#
# Sho call stack
#
proc wokUtils:EASY:ShowCall {{file stdout}} {
    puts $file "Tcl call trace"
    for  { set l [expr [info level]-1] } { $l > 0 } { incr l -1 } {
	puts $file "$l : [info level $l]"
    }
}

;#
;# search for each element in dfile if it belongs to a directory of dlist
;#
proc wokUtils:EASY:yfind { dfile dlist } {
    set ret {}
    foreach file $dfile {
	set f {}
	foreach dir $dlist {
	    if [file exists $dir/$file] {
		set f $dir
		break
	    }
	}
	lappend ret [list $file $f]
    }
    return $ret
}
;#
;# returns the list of all directories under dir
;#
proc wokUtils:EASY:seadir { dir } {
    set l $dir
    foreach f [readdir $dir] {
	if [file isdirectory $dir/$f] { 
	    set l [concat $l [wokUtils:EASY:seadir $dir/$f]]
	}
    }
    return $l
}

proc wokUtils:EASY:NiceList { a sep } {
    set maxl 0
    foreach x $a {
	if { [set lc [string length [lindex $x 0]]] > $maxl } {
	    set maxl $lc
	}
    }
    incr maxl ; set ret ""
    foreach x $a {
	set value [lindex $x 1]
	if { [set name  [lindex $x 0]] == "separator" } {
	    append ret \n
	} else {
	    append ret [format "%-*s %s" $maxl $name$sep $value]\n
	}
    }
    return $ret
}

proc  wokUtils:FILES:html { file } {
    global tcl_platform
    if { "$tcl_platform(platform)" == "unix" } {
	set cmd "exec netscape -remote \"openFile($file)\""
	if { [catch $cmd] != 0 } {
	    exec netscape &
	    while { [catch $cmd] != 0 } { 
		after 500
	    }
	}
    } elseif { "$tcl_platform(platform)" == "windows" } {
	set cmd [list exec netscape $file &]
	if { [catch $cmd] != 0 } {
	    set prog [tk_getOpenFile -title "Where is Netscape ?"]
	    if { $prog != "" } {
		puts $prog
		exec $prog $file &
	    }
	}
    }
    return    
}
;# essais
;# 
;#proc wokUtils:FILES:lcprp { listorig target } {
;#    foreach r $listorig {
;#	puts "Copying $r onto $target"
;#	catch { exec cp -rp $r $target} status
;#	puts "$status"
;#    }
;#}

;#proc wokUtils:FILES:cprp { d1 d2 } {
;#    set cmd "tar cf - . | ( cd $d2 ; tar xf - )"
;#    return 
;#}
