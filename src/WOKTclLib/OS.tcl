proc OSUsage {} {
  puts stderr \
    {
  Usage : OS [ options ] [ module ]

  Options :

  -lsource : Liste les sources de module.

  -lshare  : Liste les shareables de module

  -lressource : Liste des ressources de module

  -lwokadm : Liste des sources d'administration de wok pour module

  -lfreefiles  : Liste les fichiers isoles d'un module.
                (i.e. ceux qui n'appartiennent pas a une UD.)
                peut etre utilisee avec -type pour savoir dans quel type d'archive
                ils sont embarques.

  -v  :  Verbose mode.

  -alias  :  Donne le nom court de module.

  -type  :  Specifie le type de l'archive a faire. <source> ou <runtime>

  -os    :  Specifie le nom de la plateforme a traiter.

  -make dir: Fabrique les makefile de <module> et les place dans dir.
             Cette option doit etre utilisee avec -os.

  -makadm dir : Fabrique les fichiers d'admin de <module> et les place dans dir
  Cette option doit etre utilisee avec -os, -substr str1,str2
  Retourne une liste utilisable par mktree.

  -substr str1,str2   : Substitue str1 par str2 dans les fichiers d'admin ci dessus.
  -subdone file       : Ecrit dans file la liste des noms de fichiers dans lesquels
                        la substitution a ete effectivement faite.

  -outdir dir: Path to directory where Visual Studio projects will be created;
                     default is ros/adm/<-os>/<-vc>

  -tksort  : retourne la liste triee des toolkits de(s) module(s)

  -dest <string> file : Specifie que les fichiers listes dans file iront dans le sous
  repertorie de l'archive <string>.

  -from f1,f2,.. : Utilise les fichiers fi pour fabrique  l'archive. Chacun de ces fichiers
  contient sur chaque ligne 2 champs separes par un blanc. <path-origine> <sous-dir>.
  <path-origine> est le full path du fichier a embarquer.
  <sous-dir>     est un nom de sous directory ou sera place le fichier dans l'archive donc
  dans la version une fois downloadee.

  -o          : Met la sortie ( s'il y en a une ) dans le fichier specifie.

  -mktree     : fabrique une arborescence a partir d'une liste. (genere par -lsource)

  -mode       : Specifie que les fichiers de l'arborescence sont copies(cp),lies(ln)
                      lors du mktree.

  -mkar       : fabrique une archive a partir d'une arborescence

  -fmtar      : specifie le type de l'archive a creer ( defaut :tar.gz ) par traite encore.

  -tmpdir dir : Cree la racine de l'arborescence pour mktree dans dir. ( Voir -root)

  -root r     : Designe r comme racine de l'archive  (de fait dir/r)

  -l          : Liste sur stdout les modules connus.

  -ll         : Liste des toolkits dans l'ordre de fabrication.

  -lm         : Liste des modules and products

  -L          : Idem que ci dessus avec un peu plus de details.(utilise WOK)

  -cvsmod     : Cree une liste de definition de module CVS. Ne
                Utiliser ca avec -o modules, puis faire checkin de modules.
                Ne sont pris en compte que les modules pour lesquels la methode Export
                retourne (au moins) "source".

  -u  key     : Liste les UDs d'un module.
                Si key = "ucreate" imprime la liste des ud precedees de leur type. (utilise WOK)
                Si key = "list"  retourne une liste des ud
                Si key = "udlist" retourne une liste "UDLIST like"

  -info       : Donne dezinfo sur les modules.

  -xml        : Ecrit un fichier contenant la description xml du ou des modules concernes.
                OS -xml list-de-Modules -o /tmp/occ.xml

  -ask        : Cree un questionnaire utilisable pour l'installation. ( utiliser avec -o )

  -box        : Donne le nom du repertoire ou sont crees les listes de fichiers a archiver
                dans CVS. ( repertoire adm ...)

  -wpack      : Cree une archive au format wpack avec tous les sources de <module>.
                L'archive cree s'appellera <module>.bck.Z
                L'argument suivant wpack est le nom du directory ou on cree l'archive.

  Exemples:
        1. Fabriquer toutes les makefiles de FoundationClasses dans le directory /adv_11/...
  et dire que ces procedures iront dans un sous repertoire adm .
  > OS -make /adv_11.../transfert -o /tmp/Liste1 FoundationClasses

        2. Specifie que les fichiers listes dans /tmp/Liste1 iront dans adm
  > OS -dest adm /tmp/Liste1
  (ecrit dans le fichier /tmp/Liste1 <path-origine> adm)

        3. Fabriquer la liste des sources de FoundationClasses (cette option utilise WOK)
  > OS -lsource -o /tmp/Liste2 FoundationClasses

        4. Fabriquer une arborescence avec les 2 listes (fabriquees avec OS -dest)
  > OS -mktree  -from /tmp/Liste1,/tmp/Liste2 -tmpdir /tmp -root CASXXX

        Ce qui suit est nettement plus utile:

  5. Utilisation des procedures pour tout fabriquer. (sur une seule plateforme avec Gnu tar)
           Ceci se fait depuis une plateforme avec Gnu tar
  OS:MKPRC            : Fabrique et edite les procs compil/link. ([OS-box]/Platform)
  OS:PKGSRC {}        : Fabrique toutes les archives source
  OS:PKGRTL {} {}     : Fabrique toutes les archives runtime (tt plat.)
  Comtper plus de 2 heures pour tout faire.

  Pour ne refaire que des bouts:

  OS:PKGRTL {} Draw                   ; runtime ttes ptfm pour Draw
  OS:PKGRTL Linux {}                  ; runtime Linux tous modules
  OS:PKGRTL {} {Draw Viewer}          ; runtime ttes ptfm pour Draw et Viewer
  OS:PKGRTL Linux Draw                ; runtime Linux pour Draw

        5bis. Creation des archives pour les fichiers d'adm de WOK. Il faut
        se logger ecffectivement sur la machine comme explique ci dessous.

   ( sur SunOS : telnet h2ox ; tclsh ; wokcd KAS:C30:ref)
   > OS:PKGADM SunOS
   ( sur Linux : telnet archimex ; tclsh ; wokcd KAS:C30:ref)
   > OS:PKGADM Linux
   ( sur IRIX  : telnet <ask-to-pop>; tclsh ; wokcd KAS:C30:ref)
   > OS:PKGADM IRIX
   ( sur AIX   : telnet bourin ; tclsh ; wokcd KAS:C30:ref)
   > OS:PKGADM AIX

  7. Dans 5 si on ne specifie pas de nom de module, la liste
           des modules traites est obtenue par la commande "OS -lm".

  8. Rien ici.

  9. Fabrication d'une image CD OpenSource:
     Cette image se trouve dans le directory pointe par la commande OS -cdrom.
     Elle contient un ensemble de fichiers (noms 8.3) destines a aller sur le CD.
     ( Liens sur le tar.gz de [OS -distrib] )
     Cette image se creer par la commande :
     > OS:MKCDOS

  }
  return
}

;#
;# Fabrique et remplit l'arborescence d'un module
;#
proc OS { args } {

    global OpenSource

    set tblreq(-h)         {}
    set tblreq(-v)         {}
    set tblreq(-box)       {}

    set tblreq(-o)          value_required:file

    set tblreq(-mode)       value_required:string
    set tblreq(-archtype)   value_required:string
    set tblreq(-type)       value_required:string
    set tblreq(-keep)       {}

    set tblreq(-l)          {}
    set tblreq(-ll)         {}
    set tblreq(-lm)         {}

    set tblreq(-L)          {}
    set tblreq(-cvsmod)     {}
    set tblreq(-u)          value_required:string

    set tblreq(-param)      {}

    set tblreq(-make)       value_required:file
    set tblreq(-makadm)     value_required:file
    set tblreq(-substr)     value_required:list
    set tblreq(-subdone)    value_required:file
    set tblreq(-outdir)     value_required:file
    set tblreq(-tksort)     {}
    set tblreq(-plat)       value_required:string
    set tblreq(-wpack)      value_required:file
    set tblreq(-os)         value_required:string
    set tblreq(-xml)        value_required:string
    set tblreq(-dest)       value_required:string

    set tblreq(-tmpdir)     value_required:string
    set tblreq(-root)       value_required:string

    set tblreq(-lsource)    {}
    set tblreq(-LSOURCE)    {}
    set tblreq(-lshare)     {}
    set tblreq(-LSHARE)     {}
    set tblreq(-lressource) {}
    set tblreq(-LRESSOURCE) {}
    set tblreq(-lwokadm)    {}
    set tblreq(-lfreefiles) {}
    set tblreq(-LFREEFILES) {}

    set tblreq(-since)      value_required:string

    set tblreq(-from)       value_required:list

    set tblreq(-mktree)     {}
    set tblreq(-mkar)       value_required:string
    set tblreq(-info)       {}

    set tblreq(-alias)      {}

    set tblreq(-ask)        {}

    set param {}
    if { [wokUtils:EASY:GETOPT param tabarg tblreq OSUsage $args] == -1 } {
	puts stderr "Error: incorrect options for command OS: $args"
	return
    }

    if [info exists tabarg(-h)] {
	OSUsage
	return
    }

    set os "" ;# default
    if [info exists tabarg(-os)] {
	set os $tabarg(-os)
    }

    ;#
    ;# debut: Options ne dependant pas d'un nom de module
    ;#

    if [info exists tabarg(-param)] {
	if { [OS:init $os] == {} } { return }
	parray OpenSource
	OS:end
	return
    }

    if [info exists tabarg(-box)] {
	if { [OS:init $os] == {} } { return }
	set h $OpenSource(box)
	OS:end
	return $h
    }

    set verbose 0
    if [info exists tabarg(-v)] {
	set verbose 1
    }


    if [info exists tabarg(-dest)] {
	if { [llength $param] != 1 } {
	    puts stderr "Error: argument should contain single module name; call OS -h for help"
	    return
	}
	set l {}
	foreach x [wokUtils:FILES:FileToList [lindex $param 0]] {
	    lappend l "$x [file join $tabarg(-dest) [file tail $x]]"
	}
	if [info exists tabarg(-o)] {
	    wokUtils:FILES:ListToFile $l $tabarg(-o)
	} else {
	    wokUtils:FILES:ListToFile $l [lindex $param 0]
	}
	return
    }


    if [info exists tabarg(-ask)] {
	set l {}
	set i 0
	set w {}
	foreach module [OS -lm] {
	    lappend l [format " (%d) : %s" [incr i] $module]
	    set w [concat $w $i ${module}]
	}
	if [info exists tabarg(-o)] {
	    wokUtils:FILES:ListToFile $l $tabarg(-o)
	    set dir [file dirname $tabarg(-o)]
	    foreach plat [OS:plats_disponibles] {
		set all {}
		foreach [list i m] $w {
		    set ldp $m
		    set all [concat $all [OS:all8 $m $plat rtl]]
		    foreach dp [OS:lsdep $m] {
			lappend ldp $dp
		    }
		    set lw {}
		    foreach dp $ldp {
			set lw [concat $lw [OS:all8 $dp $plat rtl]]
		    }
		    wokUtils:FILES:ListToFile $lw [file join $dir bin$plat$i.aws]
		    puts stderr " File [file join $dir bin$plat$i.aws] has been created"
		}
		wokUtils:FILES:ListToFile $all [file join $dir bin${plat}all.aws]
	    }
	    set all {}
	    foreach [list i m] $w {
		set ldp $m
		set all [concat $all [OS:all8 $m $plat src]]
		foreach dp [OS:lsdep $m] {
		    lappend ldp $dp
		}
		set lw {}
		foreach dp $ldp {
		    set lw [concat $lw [OS:all8 $dp $plat src]]
		}
		wokUtils:FILES:ListToFile $lw [file join $dir src$i.aws]
		puts stderr " File [file join $dir src$i.aws] has been created"
	    }
	    wokUtils:FILES:ListToFile $all [file join $dir srcall.aws]
	} else {
	    foreach u $l {
		puts $u
	    }
	}
	return
    }

    set mode copy
    if [info exists tabarg(-mode)] {
	set mode $tabarg(-mode)
    }

    if [info exists tabarg(-l)] {
	if { [OS:init $os] == {} } { return }
	OS:lsmodule 0
	OS:end
	return
    }

    if [info exists tabarg(-L)] {
	if { [OS:init $os] == {} } { return }
	OS:lsmodule 1
	OS:end
	return
    }

    if [info exists tabarg(-lm)] {
	if { [OS:init $os] == {} } { return }
	set lm {}
	# load OS modules
	if { [info proc OS:Modules] != {} } {
	    if [info exists tabarg(-plat)] {
		eval lappend lm [OS:Modules $tabarg(-plat)]
	    } else {
		eval lappend lm [OS:Modules]
	    }
	}
	# load products
	if { [info proc VAS:Products] != {} } {
	    if [info exists tabarg(-plat)] {
		eval lappend lm [VAS:Products $tabarg(-plat)]
	    } else {
		eval lappend lm [VAS:Products]
	    }
	}
	OS:end
	return $lm
    }

    if [info exists tabarg(-cvsmod)] {
	if { [OS:init $os] == {} } { return }
	if [info exists tabarg(-o)] {
	    set id [ open $tabarg(-o) w ]
	    OS:lsmodule 2 $id
	    close $id
	} else {
	    OS:lsmodule 2
	}
	OS:end
	return
    }

    if [info exists tabarg(-mkar)] {
	set namar $tabarg(-mkar)
	if { [OS:init $os] == {} } { return }
	set keep [info exists tabarg(-keep)]
	set artype gzip
	if [info exists tabarg(-archtype)] {
	    set artype $tabarg(-archtype)
	}
	if [info exists tabarg(-tmpdir)] {
	    if [info exists tabarg(-root)] {
		if { [set root [OS:mkdir [file join $tabarg(-tmpdir) $tabarg(-root)]]] != {} } {
		    set savpwd [pwd]
		    cd  $tabarg(-tmpdir)
		    set fgz ${namar}.gz
		    exec $OpenSource(tar) cfh ${namar} $tabarg(-root)
		    exec gzip -f9 ${namar}
		    if { $keep == 0 } {
			exec rm -rf $root
			if [file exists $root] {
			    puts "Erreur nettoyage de $root"
			    return $fgz
			}
		    }
		    cd $savpwd
		    puts "Le fichier $fgz a ete cree"
		    return $fgz
		} else {
		    puts "Erreur : Impossible de creer directory $root dans $tabarg(-tmpdir)"
		    return {}
		}
	    } else {
		puts "erreur : Option -root requise"
		return {}
	    }
	} else {
	    puts stderr "Erreur Option -tmpdir requise."
	    return {}
	}
    }


    if [info exists tabarg(-mktree)] {
	if [info exists tabarg(-tmpdir)] {
	    if [info exists tabarg(-root)] {
		if { [set root [OS:mkdir [file join $tabarg(-tmpdir) $tabarg(-root) ]]] != {} } {
		    if [info exists tabarg(-from)] {
			if { [OS:init $os] == {} } { return }
			foreach lf $tabarg(-from) {
			    if [file exists $lf] {
				foreach lin [wokUtils:FILES:FileToList $lf] {
				    set from [lindex $lin 0]
				    set to [file join $root [lindex $lin 1]]
				    OS:mkfile $from $to $mode $verbose
				}
			    } else {
				puts stderr "Erreur : Le fichier $lf existe pas"
			    }
			}
			OS:end
			return $root
		    } else {
			puts stderr "Erreur Option -from requise."
			return
		    }
		} else {
		    puts stderr "Impossible de creer $root"
		    return
		}
	    } else {
		puts stderr "Erreur Option -root requise."
		return
	    }
	} else {
	    puts stderr "Erreur Option -tmpdir requise."
	    return
	}
    }

    ;#
    ;# fin: Options ne dependant pas d'un nom de module
    ;#

    ;#
    ;# deb: Options  qui prennent soit un nom de module soit rien .
    ;#

    set module [lindex $param 0]

    if [info exists tabarg(-ll)] {
	if { [OS:init $os] == {} } { return }
	set lm $module
	if { $lm == {} } {
	    set lm [OS -lm]
	}
	if [info exists tabarg(-o)] {
	    wokUtils:FILES:ListToFile [OS:lstk $lm] $tabarg(-o)
	    if [file exists $tabarg(-o)] {
		puts stderr "File $tabarg(-o) a ete cree."
	    } else {
		puts stderr "Erreur : Impossible de creer $tabarg(-o)"
	    }
	} else {
	    foreach x [OS:lstk $lm] {
		puts $x
	    }
	}
	OS:end
	return
    }

    if [info exists tabarg(-info)] {
	if { [OS:init $os] == {} } { return }
	set lm $module
	if { $lm == {} } {
	    set lm [OS -lm]
	}
	if [info exists tabarg(-o)] {
	    set id [ open $tabarg(-o) w ]
	    OS:info $lm $id
	    close $id
	} else {
	    OS:info $lm
	}
	OS:end
	return
    }


    if [info exists tabarg(-tksort)] {
	if { [OS:init $os] == {} } { return }
	set lm $module
	if { $lm == {} } {
	    set lm [OS -lm]
	}
	set lret {}
	foreach m $lm {
	    lappend lret [list $m [osutils:tk:sort [${m}:toolkits]]]
	}
	OS:end
	return $lret
    }


    if [info exists tabarg(-u)] {
	if { [OS:init $os] == {} } { return }
	set lm $module
	if { $lm == {} } {
	    set lm [OS -lm]
	}

	switch -- $tabarg(-u) {

	    ucreate {
		set out [pwd]/UCREATE
		if [info exists tabarg(-o)] { set out $tabarg(-o) }
		set l {}
		foreach mod $lm {
		    foreach tkloc  [${mod}:toolkits] {
			lappend l "ucreate -t $tkloc"
 			foreach u [osutils:tk:units [woklocate -u $tkloc] 1] {
			    lappend l "ucreate -$u"
			}
		    }
		    foreach add [${mod}:ressources] {
			lappend l "ucreate -[lindex $add 1] [lindex $add 2]"
		    }
		}
		wokUtils:FILES:ListToFile [lsort $l] $out
		if [file exists $out] {
		    puts stderr "File $out a ete cree."
		} else {
		    puts stderr "Erreur : Impossible de creer $out"
		}
		OS:end
		return
	    }

	    udlist {
		if [info exists tabarg(-o)] {
		    set out $tabarg(-o)
		}
		set l {}
		foreach mod $lm {
		    foreach tkloc  [${mod}:toolkits] {
			lappend l "t $tkloc"
			foreach u [osutils:tk:units [woklocate -u $tkloc] 1] {
			    lappend l "$u"
			}
		    }
		    foreach add [${mod}:ressources] {
			lappend l "[lindex $add 1] [lindex $add 2]"
		    }
		}
		if [info exists out] {
		    wokUtils:FILES:ListToFile [lsort $l] $out
		    if [file exists $out] {
			puts stderr "File $out a ete cree."
		    } else {
			puts stderr "Erreur : Impossible de creer $out"
		    }
		} else {
		    foreach u [lsort $l] {
			puts $u
		    }
		}
		OS:end
		return
	    }


	    list {
		set l {}
		foreach mod $lm {
		    foreach tkloc  [${mod}:toolkits] {
			lappend l $tkloc
			foreach u [osutils:tk:units [woklocate -u $tkloc] 1] {
			    lappend l [lindex $u 1]
			}
		    }
		    foreach add [${mod}:ressources] {
			lappend l [lindex $add 2]
		    }
		}
		OS:end
		return [lsort $l]
	    }
	}
    }


    if [info exists tabarg(-xml)] {
	if { [OS:init $os] == {} } { return }
	set lm $module
	if { $lm == {} } {
	    set lm [OS -lm]
	}
	if [info exists tabarg(-o)] {
	    wokUtils:FILES:StringToFile [OS:xml $lm] $tabarg(-o)
	} else {
	    puts stderr "Erreur : Specifier -o pour donner un nom de fichier. "
	}

	return
    }




    if [info exists tabarg(-wpack)] {
	if { [OS:init $os] == {} } { return }
	set dir $tabarg(-wpack)
	OS:mkdir $dir
	if ![file exists $dir] {
	    puts stderr "OS:wpack: Le directory $dir ne peut etre cree."
	    return
	}

	set lm $module
	if { $lm == {} } {
	    set lm [OS -lm]
	}

	foreach module $lm {
	    if { $verbose } { puts "Processing module $module" }
	    OS:wpack $module $dir $verbose
	}

	OS:end
	return
    }

    ;#
    ;# fin: Options  qui prennent soit un nom de module soit rien .
    ;#
    ;#
    ;# deb: Option qui requiert un nom de module.
    ;#

    if { [llength $param] == 0 } {
	puts stderr "Error: missing module argument; call \"OS -h\" for help"
	return
    }

    if { [OS:init $os] == {} } { return }
    if { [lsearch [OS -lm] $module] == -1 } {
	puts stderr "Error: unknown module \"$module\"."
	puts stderr "Call \"OS -lm\" for a complete list of available modules"
	OS:end
	return
    }

    ;# requiert -os
    ;#
    if [info exists tabarg(-make)] {
	if [info exists tabarg(-os)] {
	    if { [set dir [OS:mkdir $tabarg(-make)]] != {} } {
		set since {}
		if [info exists tabarg(-since)] {
		    set since $tabarg(-since)
		}
		if { [OS:init $os] == {} } { return }
		set mkfiles [OS:mkmk $module $dir $tabarg(-os) $since]
		if [info exists tabarg(-o)] {
		    wokUtils:FILES:ListToFile $mkfiles $tabarg(-o)
		    if [file exists $tabarg(-o)] {
			puts stderr "File $tabarg(-o) a ete cree."
		    } else {
			puts stderr "Erreur : Impossible de creer $tabarg(-o)"
		    }
		}
		OS:end
	    } else {
		puts stderr "OS:make: Le directory $dir ne peut etre cree."
		return
	    }
	} else {
	    puts stderr "Erreur : Specifier -os "
	}
	return
    }

    ;# requiert -os
    ;#
    if [info exists tabarg(-makadm)] {
	if [info exists tabarg(-os)] {
	    if { [set dir [OS:mkdir $tabarg(-makadm)]] != {} } {
		set since {}
		if [info exists tabarg(-since)] {
		    set since $tabarg(-since)
		}
		if [info exists tabarg(-substr)] {
		    set ls1s2 $tabarg(-substr)
		    if { [OS:init $os] == {} } { return }
		    set resadm [OS:admadm $module $dir $tabarg(-os) $since $ls1s2 $verbose]
		    set admfiles [lindex $resadm 0]
		    if [info exists tabarg(-subdone)] {
			set lsb {}
			lappend lsb "#! /bin/csh -f"
			foreach s [lindex $resadm 1] {
			    lappend lsb [format "\${CASROOT}/adm/treplace TOSUBSTITUTE \$argv\[1\] \${CASROOT}/%s" [lindex $s 1]]
			}
			wokUtils:FILES:ListToFile $lsb $tabarg(-subdone)
		    }
		    if [info exists tabarg(-o)] {
			wokUtils:FILES:ListToFile $admfiles $tabarg(-o)
			if [file exists $tabarg(-o)] {
			    puts stderr "File $tabarg(-o) a ete cree."
			} else {
			    puts stderr "Erreur : Impossible de creer $tabarg(-o)"
			}
		    }
		} else {
		  puts stderr "Erreur : Specifier -substr string1,string2 "
		}
		OS:end
	    } else {
		puts stderr "OS:make: Le directory $dir ne peut etre cree."
		return
	    }
	} else {
	    puts stderr "Erreur : Specifier -os "
	}
	return
    }


    if [info exists tabarg(-lsource)] {
	if { [OS:init $os] == {} } { return }
	set lso [OS:sources ${module} $verbose]
	if [info exists tabarg(-o)] {
	    if [info exists tabarg(-since)] {
		set lsi {}
		foreach z $lso {
		    set f [lindex [split $z] 0]
		    if { [file mtime $f] > $tabarg(-since) } {
			lappend lsi $z
		    }
		}
		wokUtils:FILES:ListToFile $lsi $tabarg(-o)
	    } else {
		wokUtils:FILES:ListToFile $lso $tabarg(-o)
	    }
	    if [file exists $tabarg(-o)] {
		puts stderr "File $tabarg(-o) a ete cree."
	    } else {
		puts stderr "Erreur : Impossible de creer $tabarg(-o)"
	    }
	} else {
	    foreach z $lso {
		if [info exists tabarg(-since)] {
		    set f [lindex [split $z] 0]
		    if { [file mtime $f] > $tabarg(-since) } {
			puts $z
		    }
		} else {
		    puts $z
		}
	    }
	}
	OS:end
	return
    }

    if [info exists tabarg(-LSOURCE)] {
	if { [OS:init $os] == {} } { return }
	set lso [OS:SOURCES ${module} $verbose]
	OS:end
	if [info exists tabarg(-o)] {
	    if [info exists tabarg(-since)] {
		set lsi {}
		foreach f $lso {
		    if { [file mtime $f] > $tabarg(-since) } {
			lappend lsi $f
		    }
		}
		wokUtils:FILES:ListToFile $lsi $tabarg(-o)
	    } else {
		wokUtils:FILES:ListToFile $lso $tabarg(-o)
	    }
	    if [file exists $tabarg(-o)] {
		puts stderr "File $tabarg(-o) a ete cree."
	    } else {
		puts stderr "Erreur : Impossible de creer $tabarg(-o)"
	    }
	} else {
	    if [info exists tabarg(-since)] {
		set lret {}
		foreach f $lso {
		    if { [file mtime $f] > $tabarg(-since) } {
			lappend lret $f
		    }
		}
		return $lret
	    } else {
		return $lso
	    }
	}
	return
    }


    if [info exists tabarg(-lshare)] {
	if { [OS:init $os] == {} } { return }
	if [info exists tabarg(-os)] {
	    if [info exists tabarg(-o)] {
		wokUtils:FILES:ListToFile [OS:share ${module} $tabarg(-os) $verbose] $tabarg(-o)
		if [file exists $tabarg(-o)] {
		    puts stderr "File $tabarg(-o) a ete cree."
		} else {
		    puts stderr "Erreur : Impossible de creer $tabarg(-o)"
		}
	    } else {
		foreach z [OS:share ${module} $tabarg(-os) $verbose] {
		    puts $z
		}
	    }
	} else {
	    puts stderr "Erreur : Specifier -os avec -lshare"
	}
	OS:end
	return
    }

    if [info exists tabarg(-LSHARE)] {
	if { [OS:init $os] == {} } { return }
	if [info exists tabarg(-os)] {
	    if [info exists tabarg(-o)] {
		wokUtils:FILES:ListToFile [OS:SHARE ${module} $tabarg(-os) $verbose] $tabarg(-o)
		if [file exists $tabarg(-o)] {
		    puts stderr "File $tabarg(-o) a ete cree."
		} else {
		    puts stderr "Erreur : Impossible de creer $tabarg(-o)"
		}
	    } else {
		return [OS:SHARE ${module} $tabarg(-os) $verbose]
	    }
	} else {
	    puts stderr "Erreur : Specifier -os avec -lshare"
	}
	OS:end
	return
    }

    if [info exists tabarg(-lressource)] {
	if [info exists tabarg(-type)] {
	    set type $tabarg(-type)
	    if { $type == "runtime" } {
		if ![info exists tabarg(-os)] {
		    puts stderr "Erreur : Specifier -os avec -lressource -type runtime"
		    return
		}
	    }
	    if [info exists tabarg(-os)] {
		set plat $tabarg(-os)
	    } else {
		set plat {}
	    }
	    if { [OS:init $os] == {} } { return }
	    set lso [OS:ressources ${module} $plat $type $verbose]
	    if [info exists tabarg(-o)] {
		if [info exists tabarg(-since)] {
		    set lsi {}
		    foreach z $lso {
			set f [lindex [split $z] 0]
			if { [file mtime $f] > $tabarg(-since) } {
			    lappend lsi $z
			}
		    }
		    wokUtils:FILES:ListToFile $lsi $tabarg(-o)
		} else {
		    wokUtils:FILES:ListToFile $lso $tabarg(-o)
		}
		if [file exists $tabarg(-o)] {
		    puts stderr "File $tabarg(-o) a ete cree."
		} else {
		    puts stderr "Erreur : Impossible de creer $tabarg(-o)"
		}
	    } else {
		foreach z $lso {
		    if [info exists tabarg(-since)] {
			set f [lindex [split $z] 0]
			if { [file mtime $f] > $tabarg(-since) } {
			    puts $z
			}
		    } else {
			puts $z
		    }
		}
	    }
	    OS:end
	} else {
	    puts stderr "Erreur : Specifier -type avec -lressource"
	}
	return
    }

    if [info exists tabarg(-LRESSOURCE)] {
	if [info exists tabarg(-type)] {
	    set type $tabarg(-type)
	    if { $type == "runtime" } {
		if ![info exists tabarg(-os)] {
		    puts stderr "Erreur : Specifier -os avec -lressource -type runtime"
		    return
		}
	    }
	    if [info exists tabarg(-os)] {
		set plat $tabarg(-os)
	    } else {
		set plat {}
	    }
	    if { [OS:init $os] == {} } { return }
	    set lso [OS:RESSOURCES ${module} $plat $type $verbose]
	    OS:end
	    if [info exists tabarg(-o)] {
		if [info exists tabarg(-since)] {
		    set lsi {}
		    foreach z $lso {
			set f [lindex [split $z] 0]
			if { [file mtime $f] > $tabarg(-since) } {
			    lappend lsi $z
			}
		    }
		    wokUtils:FILES:ListToFile $lsi $tabarg(-o)
		} else {
		    wokUtils:FILES:ListToFile $lso $tabarg(-o)
		}
		if [file exists $tabarg(-o)] {
		    puts stderr "File $tabarg(-o) a ete cree."
		} else {
		    puts stderr "Erreur : Impossible de creer $tabarg(-o)"
		}
	    } else {
		return $lso
	    }
	} else {
	    puts stderr "Erreur : Specifier -type avec -LRESSOURCE"
	}
	return
    }


    if [info exists tabarg(-lwokadm)] {
	if ![info exists tabarg(-os)] {
	    puts stderr "Erreur : Specifier -os avec -lwokadm"
	    return
	}
	if [info exists tabarg(-os)] {
	    set plat $tabarg(-os)
	} else {
	    set plat {}
	}
	if { [OS:init $os] == {} } { return }
	set lso [OS:wokadm ${module} $plat $verbose]
	if [info exists tabarg(-o)] {
	    if [info exists tabarg(-since)] {
		set lsi {}
		foreach z $lso {
		    set f [lindex [split $z] 0]
		    if { [file mtime $f] > $tabarg(-since) } {
			lappend lsi $z
		    }
		}
		wokUtils:FILES:ListToFile $lsi $tabarg(-o)
	    } else {
		wokUtils:FILES:ListToFile $lso $tabarg(-o)
	    }
	    if [file exists $tabarg(-o)] {
		puts stderr "File $tabarg(-o) a ete cree."
	    } else {
		puts stderr "Erreur : Impossible de creer $tabarg(-o)"
	    }
	} else {
	    foreach z $lso {
		if [info exists tabarg(-since)] {
		    set f [lindex [split $z] 0]
		    if { [file mtime $f] > $tabarg(-since) } {
			puts $z
		    }
		} else {
		    puts $z
		}
	    }
	}
	OS:end
	return
    }

    if [info exists tabarg(-lfreefiles)] {
	if { [OS:init $os] == {} } { return }
	set type both
	set check 1
	if [info exists tabarg(-type)] {set type $tabarg(-type)}
	if { [lsearch [list both runtime source] $type] != -1 } {
	    set lfree [OS:freefiles ${module} $type $check $verbose]
	    if { $lfree != {} } {
		if [info exists tabarg(-o)] {
		    wokUtils:FILES:ListToFile $lfree $tabarg(-o)
		    if [file exists $tabarg(-o)] {
			puts stderr "File $tabarg(-o) a ete cree."
		    } else {
			puts stderr "Erreur : Impossible de creer $tabarg(-o)"
		    }
		} else {
		    foreach z $lfree {
			puts $z
		    }
		}
	    } else {
		puts stderr "Information: pas de freefiles pour $module ($type)"
	    }
	} else {
	    puts stderr "Type inconnu. Essayer <both> <source> ou <runtime>."
	}
	return
	OS:end
    }
    if [info exists tabarg(-LFREEFILES)] {
	if { [OS:init $os] == {} } { return }
	set type both
	set check 1
	if [info exists tabarg(-type)] {set type $tabarg(-type)}
	if { [lsearch [list both runtime source] $type] != -1 } {
	    set lfree [OS:FREEFILES ${module} $type $check $verbose]
	    if { $lfree != {} } {
		if [info exists tabarg(-o)] {
		    wokUtils:FILES:ListToFile $lfree $tabarg(-o)
		    if [file exists $tabarg(-o)] {
			puts stderr "File $tabarg(-o) a ete cree."
		    } else {
			puts stderr "Erreur : Impossible de creer $tabarg(-o)"
		    }
		} else {
		    return $lfree
		}
	    } else {
		puts stderr "Information: pas de freefiles pour $module ($type)"
	    }
	} else {
	    puts stderr "Type inconnu. Essayer <both> <source> ou <runtime>."
	}
	return {}
	OS:end
    }

    if [info exists tabarg(-alias)] {
	if { [OS:init $os] == {} } { return }
	set a ""
	if { "[info procs ${module}:alias]" != "" } {
	    set a [${module}:alias]
	}
	OS:end
	return $a
    }

}

;# ((((((((((((((((((((((((((((( O S )))))))))))))))))))))))))))))
;#
;# Noms 8 caracteres cdrom
;# retourne sur 8 caracteres toutes les archives concernant module sur une plateforme
proc OS:all8 { module plat type } {
    set a [${module}:alias]
    set l {}
    if { "$type" == "rtl" } {
	switch -- $plat {

	    SunOS {
		set litm  [list sun wsn]
	    }

	    Linux {
		set litm  [list lin wln]
	    }

	    HP-UX {
		set litm [list hpu whp]
	    }

	    IRIX {
		set litm  [list sil wsl]
	    }

	    AIX {
		set litm [list aix wax]
	    }

	    WindowsNT {
		set litm [list win32 wwt]
	    }

	    default {
		set litm {}
	    }

	}
    } else {
	set litm [list src]
    }

    foreach itm $litm {
	set l [concat $l ${itm}${a}[OS:simple_version].tgz]
    }
    return $l
}
;#
;# retourne la liste de dependances de module.
;#
proc OS:lsdep { m } {
    set res {}
    set l [${m}:depends]
    if { $l != {} } {
	set res [concat $res $l]
	foreach h $l {
	    set res [concat $res [OS:lsdep ${h}]]
	}
    }
    return $res
}

;#
;#
;# retourne la liste des fichiers d'administration wok de module
;# A lancer sur la plateforme Cible
;# DE FAIT PLAT N'EST PAS UTILISE:
;# On rajoute de force Standard.ImplDep
proc OS:wokadm { module plat {verbose 0} } {
    global OpenSource

    set lret {}
    set sourceType [list dbadmfile stadmfile admfile]

    foreach tkloc  [${module}:toolkits] {

	set listloc [concat [osutils:tk:units [woklocate -u $tkloc]] [woklocate -u $tkloc]]

	foreach loc $listloc {

	    set utyp [uinfo -t [woklocate -u $loc]]

	    ;# Le worbench ou est l'ud

	    ;# 1. recup des pathes de tous les fichiers de loc
	    osutils:tk:loadunit $loc map

	    ;# 2. Selection des types "wokadm" associes a l'UD
	    ;# (semblent ne pas dependre du type de l'UD)

	    foreach typ [array names map] {
		if { [lsearch $sourceType $typ] == -1 } {
		    unset map($typ)
		}
	    }

	    ;# 3.
	    set count 0
	    set destart ""
	    set wborig [wokinfo -w [woklocate -u $loc]]
	    foreach typ [lsort [array names map]] {
		foreach f $map($typ) {
		    if { [set rr [join [OS:strparseloc $f $wborig 0 right] /]] != {} } {
			lappend lret "$f [file join $destart  $rr]"
			incr count
		    } else {
			puts "Erreur wokadm : peu pas strparseloc $f"
		    }
		}
	    }
	    if { $verbose } {
		puts "$loc ( Source Copies : $count )"
	    }
	    if { $count == 0 } {
		puts "Erreur : Rien a copier pour $loc"
	    }
	}
    }
    ;#
    ;# Les ressources:
    if { "[info procs ${module}:ressources]" != "" } {
	foreach XXX  [${module}:ressources] {
	    set artyp  [lindex $XXX 0]
	    set dectyp [lindex $XXX 1]
	    set loc    [woklocate -u [lindex $XXX 2]]
	    set destin [lindex $XXX 3]

	    osutils:tk:loadunit $loc map

	    foreach typ [array names map] {
		if { [lsearch $sourceType $typ] == -1 } {
		    unset map($typ)
		}
	    }

	    ;# 3.
	    set count 0
	    set destart ""
	    set wborig [wokinfo -w [woklocate -u $loc]]
	    foreach typ [lsort [array names map]] {
		foreach f $map($typ) {
		    if { [set rr [join [OS:strparseloc $f $wborig 0 right] /]] != {} } {
			lappend lret "$f [file join $destart  $rr]"
			incr count
		    } else {
			puts "Erreur wokadm : peu pas strparseloc $f"
		    }
		}
	    }
	    if { $verbose } {
		puts "$loc ( Wokadm ressources Copiees : $count )"
	    }
	    if { $count == 0 } {
		puts "Wokadm ressources : Rien a copier pour $loc"
	    }
	}
    }
    return $lret
}
;#
;# retourne la liste des executables de module.
;#
proc OS:executable { module } {
    set lret {}
    foreach XXX  [${module}:ressources] {
	if { "[lindex $XXX 1]" == "x" } {
	    lappend lret [lindex $XXX 2]
	}
    }
    return $lret
}
;#
;# retourne la liste des fichiers de ressource de module
;# un item XXX ressemble a : [list both x TTOPOLOGY {}]
;# Si reqtyp est "source" on retourne les sources des UD de type resource
;# sinon on retourne tout car dans le cas d'une archive runtime il faut
;# aussi embarquer les shells de lancement qui sont des sources.
;#
proc OS:ressources { module plat reqtyp {verbose 0} } {
    global OpenSource
    set lret {}
    if { $verbose } { puts "OS:ressources : reqtyp = $reqtyp " }
    if { "[info procs ${module}:ressources]" != "" } {

	foreach XXX  [${module}:ressources] {
	    set artyp  [lindex $XXX 0]
	    set dectyp [lindex $XXX 1]
	    set loc    [lindex $XXX 2]
	    set destin [lindex $XXX 3]
	    set utyp [uinfo -t [woklocate -u $loc]]
	    set wborig [wokinfo -w [woklocate -u $loc]]
	    osutils:tk:loadunit [woklocate -u $loc] map
	    set LType $OpenSource(${reqtyp},${utyp})
	    if { $verbose } { puts " Liste des types conserves: $LType " }
	    foreach typ [array names map] {
		if { [lsearch $LType $typ] == -1 } {
		    unset map($typ)
		}
	    }

	    ;# 3.
	    set count 0
	    foreach typ [lsort [array names map]] {

		set wbt  $OpenSource(${typ},wbtype)

		if { $destin == {} } {
		    set destart  $OpenSource(${typ},artype)
		} else {
		    set destart $destin
		}
		set root [wokinfo -p ${wbt}:. $wborig]/

		foreach f $map($typ) {
		    if { "$typ" != "executable" } {
			if { "$typ" != "library" } {
			    set rr [OS:wbparseloc $f ${wbt} $wborig]
			    if { $rr != {} } {
				set dst [lindex $rr 0]
				lappend lret "$f [file join $destart  $dst]"
				incr count
				if { $verbose} {puts "ress: $dst ([lindex $rr 1])"}
			    } else {
				puts "ress: loc = $loc  wbt = $wbt root = $root"
				puts "Erreur : peu pas parser ????? $f"
			    }
			} else {
			    regsub -- {^lib}  [file root [file tail $f]] "" vtmp
			    set libf [OS:getshare $vtmp $plat]
			    if { [file exists $libf] } {
				lappend lret "$libf [wokUtils:FILES:wtail $libf 2]"
				incr count
			    } else {
				puts stderr "Erreur : Pas de $libf"
			    }
			}
		    } else {
			if [file exists [set fulp [OS:getx [file tail $f] $plat]]] {
			    lappend lret "$fulp [file join bin [file tail $f]]"
			    puts "Pour $plat : Ressource exec on embarque : $fulp"
			} else {
			    puts "Erreur : executable [file tail $f] introuvable sur $plat"
			}
		    }
		}
	    }
	    if { $verbose } {
		puts "$loc ( Ressources Copies : $count )"
	    }
	    if { $count == 0 } {
		if { "$reqtyp" == "source" } {
		    puts "Erreur  (OS:ressources) : Pas de source a copier pour $loc"
		} else {
		    puts "Information (OS:ressources) : Rien a copier pour $loc"
		}
	    }
	}
    }
    return $lret
}
proc OS:RESSOURCES { module plat reqtyp {verbose 0} } {
    global OpenSource
    set lret {}
    if { $verbose } { puts "OS:ressources : reqtyp = $reqtyp " }
    if { "[info procs ${module}:ressources]" != "" } {

	foreach XXX  [${module}:ressources] {
	    set artyp  [lindex $XXX 0]
	    set dectyp [lindex $XXX 1]
	    set loc    [lindex $XXX 2]
	    set destin [lindex $XXX 3]
	    set utyp [uinfo -t [woklocate -u $loc]]
	    set wborig [wokinfo -w [woklocate -u $loc]]
	    osutils:tk:loadunit [woklocate -u $loc] map
	    set LType $OpenSource(${reqtyp},${utyp})
	    foreach typ [array names map] {
		if { [lsearch $LType $typ] == -1 } {
		    unset map($typ)
		} else {
		    if { $verbose } { puts " Unit $loc : types conserve : $typ " }
		}
	    }

	    ;# 3.
	    set count 0
	    foreach typ [lsort [array names map]] {

		set wbt  $OpenSource(${typ},wbtype)

		if { $destin == {} } {
		    set destart  $OpenSource(${typ},artype)
		} else {
		    set destart $destin
		}
		set root [wokinfo -p ${wbt}:. $wborig]/

		foreach f $map($typ) {
		    if { "$typ" != "executable" } {
			if { "$typ" != "library" } {
			    lappend lret $f
			    incr count
			    if { $verbose} {puts "ress($loc): $f"}
			} else {
			    regsub -- {^lib}  [file root [file tail $f]] "" vtmp
			    set libf [OS:getshare $vtmp $plat]
			    if { $libf != {} } {
				lappend lret $libf
				incr count
			    } else {
				puts stderr "Erreur (ress) : Pas de $libf"
			    }
			}
		    } else {
			if [file exists [set fulp [OS:getx [file tail $f] $plat]]] {
			    lappend lret $fulp
			    incr count
			    puts "Pour $plat : Ressource exec on embarque : $fulp"
			} else {
			    puts "Erreur : executable [file tail $f] introuvable sur $plat"
			}
		    }
		}
	    }
	    if { $verbose } {
		puts "$loc ( Ressources Copies : $count )"
	    }
	    if { $count == 0 } {
		if { "$reqtyp" == "source" } {
		    puts "Erreur  (OS:ressources) : Pas de source a copier pour $loc"
		} else {
		    puts "Information (OS:ressources) : Rien a copier pour $loc"
		}
	    }
	}
    }
    return $lret
}
;#
;# utilise WOK pour creer la liste des sources d'un module
;# retourne une liste de string de la forme "f1 f2"
;# f1 est le full path du fichier d'origine
;# f2 est le nom du sous directory ou on accrochera ca
;#
;#
proc OS:sources { module {verbose 0 } } {

    global OpenSource

    set lret {}
    foreach tkloc  [${module}:toolkits] {

	set listloc [concat [osutils:tk:units [woklocate -u $tkloc]] [woklocate -u $tkloc]]

	foreach loc $listloc {

	    set utyp [uinfo -t [woklocate -u $loc]]

	    ;# Le worbench ou est l'ud
	    set wborig [wokinfo -w [woklocate -u $loc]]
	    ;# 1. recup des pathes de tous les fichiers de loc
	    osutils:tk:loadunit $loc map

	    ;# 2. Selection des types "sources" associes a l'UD
	    set sourceType $OpenSource(source,${utyp})
	    foreach typ [array names map] {
		if { [lsearch $sourceType $typ] == -1 } {
		    unset map($typ)
		}
	    }

	    ;# 3.
	    set count 0
	    foreach typ [lsort [array names map]] {
		set wbt  $OpenSource(${typ},wbtype)
		set destart  $OpenSource(${typ},artype)
		set root [wokinfo -p ${wbt}:. $wborig]/

		foreach f $map($typ) {
		    set rr [OS:wbparseloc $f ${wbt} $wborig]
		    if { $rr != {} } {
			set dst [lindex $rr 0]
			lappend lret "$f [file join $destart  $dst]"
			incr count
			if { $verbose } { puts "File $dst ([lindex $rr 1])" }
		    } else {
			puts " loc = $loc wbt = $wbt root = $root "
			puts "Erreur : peu pas parser ????? $f"
		    }
		}
	    }
	    if { $verbose } {
		puts "$loc ( Source Copies : $count )"
	    }
	    if { $count == 0 } {
		puts "Erreur : Rien a copier pour $loc"
	    }
	}
    }
    return $lret
}
;#
proc OS:SOURCES { module {verbose 0 } } {

    global OpenSource

    set lret {}
    foreach tkloc  [${module}:toolkits] {

	set listloc [concat [osutils:tk:units [woklocate -u $tkloc]] [woklocate -u $tkloc]]

	foreach loc $listloc {

	    set utyp [uinfo -t [woklocate -u $loc]]

	    ;# 1. recup des pathes de tous les fichiers de loc
	    osutils:tk:loadunit $loc map

	    ;# 2. Selection des types "sources" associes a l'UD
	    set sourceType $OpenSource(source,${utyp})

	    foreach typ [array names map] {
		if { [lsearch $sourceType $typ] == -1 } {
		    unset map($typ)
		}
	    }

	    ;# 3. Cumul des full pathes
	    set count 0
	    foreach typ [lsort [array names map]] {
		foreach f $map($typ) {
		    if { $verbose } { puts "OS:SOURCES: File $f" }
		    lappend lret $f
		    incr count

		}
	    }
	    if { $verbose } {puts "OS:SOURCES: ( $loc -> Source Copies : $count )" }
	    if { $count == 0 } { puts "Erreur : Rien a copier pour $loc" }
	}
    }

    return $lret
}
;# recherche a partir de wbfom en remontant les ancetres,
;# le workbench qui contient le fichier donne par <f> et ce en
;# utilisant le type <wbt> (type associe a un wb evidemment.)
;# retourne la partie de f qui ne depend pas de ce wb.
;# OS:wbparseloc /adv_11/KAS/C30/ref/src/gp/gp.cdl srcdir OpenSource
;#
proc OS:wbparseloc { f wbt wbfrom } {
    set res {}
    foreach wborig [w_info -A $wbfrom] {
	set root [wokinfo -p ${wbt}:. $wborig]/
	if [regsub $root $f "" dst] {
	    set res [list $dst $wborig]
	    break
	}
    }
    return $res
}
;#
;# meme chose que OS:wbparseloc mais au lieu de retirer une string
;# on utilise trimpath pour couper le path
;#
proc OS:strparseloc { f wbfrom included direction} {
    set res {}
    foreach wborig [w_info -A $wbfrom] {
	if { [set res [OS:trimpath $f $wborig $included $direction]]  != {} } {
	    break
	}
    }
    return $res
}

;#
;# utilise WOK pour creer la liste des shareables d'un module
;# i. e. les shareables de chaque toolkit du module.
;# les autres shareables et executables sont donnees dans les ressources.
;# retourne une liste de string de la forme "f1 f2"
;# f1 est le full path du fichier d'origine
;# f2 est le nom du sous directory ou on accrochera ca
;#
proc OS:share { module plat {verbose 0} } {

    set lret {}
    foreach tkloc  [${module}:toolkits] {
	foreach shr [OS:getshare $tkloc $plat] {
	    if {[file exists $shr] } {
		lappend lret "$shr [file join lib [file tail $shr]]"
	    } else {
		puts stderr "Erreur : Pas de shareable pour ${tkloc}."
	    }
	}
    }

    if { "[info procs ${module}:ressources]" != "" } {
	foreach XXX  [${module}:ressources] {
	    set artyp  [lindex $XXX 0]
	    set dectyp [lindex $XXX 1]
	    set tkloc  [lindex $XXX 2]
	    set destin [lindex $XXX 3]
	    foreach shr [OS:getshare $tkloc $plat] {
		if {[file exists $shr] } {
		    lappend lret "$shr [file join lib [file tail $shr]]"
		} else {
		    puts stderr "Information : Pas de shareable pour ${tkloc}."
		}
	    }
	}
    }
    return $lret
}
proc OS:SHARE { module plat {verbose 0} } {

    set lret {}
    foreach tkloc  [${module}:toolkits] {
	foreach shr [OS:getshare $tkloc $plat] {
	    if {[file exists $shr] } {
		lappend lret $shr
	    } else {
		puts stderr "Erreur : Pas de shareable pour ${tkloc}."
	    }
	}
    }

    if { "[info procs ${module}:ressources]" != "" } {
	foreach XXX  [${module}:ressources] {
	    set artyp  [lindex $XXX 0]
	    set dectyp [lindex $XXX 1]
	    set tkloc  [lindex $XXX 2]
	    set destin [lindex $XXX 3]
	    foreach shr [OS:getshare $tkloc $plat] {
		if {[file exists $shr] } {
		    lappend lret $shr
		} else {
		    puts stderr "Information : Pas de shareable pour ${tkloc}."
		}
	    }
	}
    }
    return $lret
}
;#
;# retourne les fichiers mentionnes dans l'item freefiles
;# d'un module. En aucun cas n'utilise WOK.
;#
proc OS:freefiles { module {artyp both} {check 0} {verbose 0} } {
    global OpenSource
    set lret {}
    if { "[info procs ${module}:freefiles]" != "" } {
	foreach XXX  [${module}:freefiles] {
	    set typ [lindex $XXX 0]
	    set loc [lindex $XXX 1]
	    set dst [lindex $XXX 2]
	    if { "$artyp" == "both" } {
		if { "$typ" == "both" || "$typ" == "runtime" || "$typ" == "source" } {
		    lappend lret "$loc $dst"
		    if { $check && ![file exists $loc] } {
			puts stderr "Error : File $loc not found"
		    }
		} else {
		    puts stderr "Format error in proc ${module}:freefiles. Return either \"source\" \"runtime\" or \"both\" "
		}
	    } else {
		if { "$typ" == "$artyp" || "$typ" == "both" } {
		    lappend lret "$loc $dst"
		    if { $check && ![file exists $loc] } {
			puts stderr "Error : File $loc not found"
		    }
		}
	    }
	}
    } else {
	if { $verbose } {
	    puts "proc ${module}:freefiles not defined. Define it in file ${module}.tcl and source it."
	}
    }
    return $lret
}
;#
;# retourne les fichiers mentionnes dans l'item freefiles
;# d'un module. En aucun cas n'utilise WOK.
;#
proc OS:FREEFILES { module {artyp both} {check 0} {verbose 0} } {
    global OpenSource
    set lret {}
    if { "[info procs ${module}:freefiles]" != "" } {
	foreach XXX  [${module}:freefiles] {
	    set typ [lindex $XXX 0]
	    set loc [lindex $XXX 1]
	    set dst [lindex $XXX 2]
	    if { "$artyp" == "both" } {
		if { "$typ" == "both" || "$typ" == "runtime" || "$typ" == "source" } {
		    lappend lret $loc
		    if { $check && ![file exists $loc] } {
			puts stderr "Error : File $loc not found"
		    }
		} else {
		    puts stderr "Format error in proc ${module}:freefiles. Return either \"source\" \"runtime\" or \"both\" "
		}
	    } else {
		if { "$typ" == "$artyp" || "$typ" == "both" } {
		    lappend lret $loc
		    if { $check && ![file exists $loc] } {
			puts stderr "Error : File $loc not found"
		    }
		}
	    }
	}
    } else {
	if { $verbose } {
	    puts "proc ${module}:freefiles not defined. Define it in file ${module}.tcl and source it."
	}
    }
    return $lret
}

;#
;# wbfile : Full path du fichier d'origine
;# tofile : la ou ca doit aller
;# mode: faire une copie, un lien, envoyer un message, copier que si different
;#
proc OS:mkfile { wbfile tofile {mode copy} {verbose 0} } {

    OS:mkdir [file dirname $tofile]

    switch -- $mode {

	copy {
	    if { [file exists $tofile] && ![file writable $tofile] } {
		set chmded 1
		chmod u+w $tofile
	    }
	    if { [OS:copy $wbfile $tofile] != -1 } {
		if {$verbose} { puts "copied $wbfile $tofile" }
		if [info exists chmded] {
		    chmod u-w $tofile
		    unset chmded
		}
		return 1
	    } else {
		return -1
	    }
	}

	jact {
	    puts "$wbfile $tofile"
	    return 1
	}

	link {
	    if { ![file exists $wbfile] } {
		puts stderr "OS:mkfile : File $wbfile existe pas."
		return -1
	    }
	    if [file exists $tofile] {
		OS:delete $tofile
	    }
	    if [file exists $tofile] {
		puts stderr "OS:mkfile :Impossible detruire $tofile avant de faire ln -s"
		return -1
	    }

	    if ![catch { exec ln -s $wbfile $tofile } staln ] {
		return 1
	    } else {
		puts stderr "OS:mkfile : $staln"
		return -1
	    }
	}

	diffcopy {
	    if [file exists $tofile] {
		if { [wokUtils:FILES:AreSame $wbfile $tofile] == 0 } {
		    OS:mkfile $wbfile $tofile copy $verbose
		}
	    } else {
		OS:mkfile $wbfile $tofile copy $verbose
	    }
	}
    }
}
;#
;#
;#
proc OS:parray { a {id stdout} {sep "" } } {
    upvar 1 $a array
    set maxl 0
    set pattern *
    foreach name [lsort [array names array $pattern]] {
	if {[string length $name] > $maxl} {
	    set maxl [string length $name]
	}
    }
    set maxl [expr {$maxl + 2}]
    foreach name [lsort [array names array $pattern]] {
	set nameString [format %s $name]
	if { "$array($name)" != "" } {
	    puts $id [format "%-*s %s %s" $maxl $nameString $sep $array($name)]
	}
    }
}
;#
;# Liste la definition des modules pour CVS, sinon fait un affichage pourri mais suffizant.
;#
proc OS:lsmodule { {long 1} {id stdout} } {
    set openmod {}
    foreach mo [OS -lm] {
	if { [lsearch [${mo}:Export] source] != -1 } {
	    lappend openmod $mo
	}
    }
    if { $long == 2 } {
	set ltk {}
	puts $id "#    "
	puts $id "# Modules.   "
	puts $id "#    "
	foreach m $openmod {
	    set str ""
	    foreach tk  [${m}:toolkits] {
		lappend ltk $tk
		append str "&${tk} "
	    }
	    set array($m) $str
	}
	OS:parray array $id "-a"
	puts $id "#    "
	puts $id "# Toolkits.   "
	puts $id "#    "
	if [info exist array] { unset array }
	set lun {}
	foreach tk  $ltk {
	    set str ""
	    foreach u [lsort [osutils:tk:units [woklocate -u $tk]]] {
		set n [wokinfo -n [woklocate -u $u]]
		lappend lun $n
		append str "src/${n} "
	    }
	    set array($tk) $str
	}
	OS:parray array $id "-a"
	puts $id "#    "
	puts $id "# Development units.   "
	puts $id "#    "
	if [info exist array] { unset array }
	foreach u $lun {
	    set array($u) "src/$u"
	}
	OS:parray array $id "-a"
	if [info exist array] { unset array }


    } else {
	foreach m $openmod {
	    puts "Module : $m"
	    foreach tk  [${m}:toolkits] {
		puts "  Toolkit ${tk} "
		if { $long } {
		    if { [woklocate -u $tk] != {} } {
			foreach u [lsort [osutils:tk:units [woklocate -u $tk]]] {
			    set n [wokinfo -n [woklocate -u $u]]
			    puts stdout [format "    %-20s %-30s " $n ([wokinfo -w [woklocate -u $u]])]
			}
		    } else {
			puts stdout "Erreur locate toolkit $tk"
		    }
		}
	    }
	}
    }
}
;#
;# retourne laiste les tk dans l'ordre de fabrication
;#
proc OS:lstk { lm } {
    set lret {}
    foreach m $lm {
	foreach tk  [${m}:toolkits] {
	    lappend lret $tk
	}
    }
    return $lret
}

;#
;# Les types du workbench qu'il faut exporter:
;# sttmpdir workdir HomeDir pubincdir drvdir objdir libdir tmpdir
;# bindir AdmDir DefinitionFile srcdir UnitListFile dbtmpdir admfile
;#;#;sttmpdir:       /adv_11/KAS/C40/ref/sun/obj/.tmp
;#
proc OS:end { } {
    global OpenSource
    if [info exists OpenSource] {
	unset OpenSource
    }
}
proc OS:init {{os {}}} {
    global env
    global tcl_platform
    global OpenSource
    if [info exists OpenSource] {
      unset OpenSource
    }
    
    set askplat $os
    if { "$os" == "" } {
      set os $tcl_platform(os)
    }

    if { [wokcd] == {} } {
      puts stderr " Pas de definition pour [wokcd]. Adm du wb courant "
      return {}
    }

    ;#
    ;# ou se trouve tout ce bordel.
    ;#
    set OpenSource(box)       [OS:defbox]
    
    ;# On utilise gtar si possible. =>
    ;#
    
    set OpenSource(tar)  tar
    if { $tcl_platform(os) == "SunOS"} { set OpenSource(tar) [file join $env(WOK_LIBRARY) sun gtar] }
    if { $tcl_platform(os) == "IRIX" } { set OpenSource(tar) [file join $env(WOK_LIBRARY) sil gtar] }
    set OpenSource(gtar) yes
    
    ;#
    ;# Load list of OCCT modules and their definitions
    ;#
    set Modules [woklocate -p OS:source:Modules.tcl]
    if { "$Modules" != "" } {
	source "$Modules"
	foreach module [OS:Modules] {
	    set f [woklocate -p OS:source:${module}.tcl]
	    if [file exists $f] {
		source $f
	    } else {
		puts stderr "Definition file for module $module is not found in unit OS"
	    }
	}
    }

    ;#
    ;# Load list of products and their definitions
    ;#
    set Products [woklocate -p VAS:source:Products.tcl]
    if { "$Products" != "" } {
	source "$Products"
	foreach product [VAS:Products] {
	    set f [woklocate -p VAS:source:${product}.tcl]
	    if [file exists $f] {
		source $f
	    } else {
		puts stderr "Definition file for product $product is not found in unit VAS"
	    }
	}
    }

    ;# -------------------- FICHIERS "SOURCES" c,cxx,hxx,_0.cxx,ixx,jxx,etc.. -------------
    ;#
    ;# 1. Definitions de l'origine des fichiers
    ;#
    set OpenSource(source,package)       {source derivated privinclude pubinclude drvfile}
    set OpenSource(source,nocdlpack)     {source pubinclude drvfile}
    set OpenSource(source,schema)        {source derivated privinclude pubinclude drvfile}
    set OpenSource(source,interface)     {}
    set OpenSource(source,client)        {}
    set OpenSource(source,engine)        {}
    set OpenSource(source,executable)    {source}
    set OpenSource(source,toolkit)       {source}
    set OpenSource(source,delivery)      {}
    set OpenSource(source,documentation) {}
    set OpenSource(source,resource)      {source}
    set OpenSource(source,jini)          {source}
    set OpenSource(source,frontal)       {}
    set OpenSource(source,idl)           {}
    set OpenSource(source,server)        {}
    set OpenSource(source,ccl)           {}

    ;# -------------------- FICHIERS "RUNTIME" .so,executable,etc.. -------------
    ;#
    ;# 1. Definitions de l'origine des fichiers
    ;#
    set OpenSource(runtime,package)       {library}
    set OpenSource(runtime,nocdlpack)     {library}
    set OpenSource(runtime,schema)        {}
    set OpenSource(runtime,interface)     {}
    set OpenSource(runtime,client)        {}
    set OpenSource(runtime,engine)        {}
    set OpenSource(runtime,executable)    {executable}
    set OpenSource(runtime,toolkit)       {library}      ;# signifie que l'on peut avoir un toolkit
    set OpenSource(runtime,delivery)      {}             ;# dans une ressource.
    set OpenSource(runtime,documentation) {}
    set OpenSource(runtime,resource)      {source}
    set OpenSource(runtime,jini)          {source}
    set OpenSource(runtime,frontal)       {}
    set OpenSource(runtime,idl)           {}
    set OpenSource(runtime,server)        {}
    set OpenSource(runtime,ccl)           {}

    ;# -------------------------------------------------------------------------------------
    ;# pour chaque type d'une UD il faut savoir ou elle est accrochee dans le workbench
    ;# d'origine
    ;# Exemple : c'est dans le drvdir qu'est accroche le type derivated.
    ;# Si on sait pas on prend HomeDir et on suppose que c'est Ud independant

    set OpenSource(source,wbtype)      srcdir
    set OpenSource(derivated,wbtype)   drvdir
    set OpenSource(drvfile,wbtype)     drvdir      ;# ExprIntrp.tab.c (lex,yacc)
    set OpenSource(privinclude,wbtype) drvdir
    set OpenSource(pubinclude,wbtype)  pubincdir

    set OpenSource(library,wbtype)     libdir
    set OpenSource(executable,wbtype)  bindir
    ;#
    ;# Defintion de la destination des fichiers d'un module dans l'archive.
    ;# Les memes que au dessus chaque racine des workbenchs , il faut savoir ou la mettre a l'arrivee
    ;#
    set OpenSource(source,artype)      src
    set OpenSource(derivated,artype)   drv
    set OpenSource(drvfile,artype)     drv
    set OpenSource(privinclude,artype) drv
    set OpenSource(pubinclude,artype)  inc
    ;#
    set OpenSource(library,artype)     lib
    set OpenSource(executable,artype)  bin

    ;# -------------------- DEFINITION de l'adresse et de la structure des archives.
    ;#
    ;# Nom de la racine ou on accroche l'arborescence en fonction du type de l'archive (source/runtime)
    ;#
    set OpenSource(dest,root)    /dn01/KAS/dev/ros/work
    ;#
    ;# Noms des sous repertoires ou seront stockees les archives sur le site.
    ;#
    set OpenSource(dest,source)  src
    set OpenSource(dest,runtime) $askplat

    ;# les lignes ci dessus signifient que:
    ;# une archive source  sera cree dans X = /adv_11/KAS/C30/OSROOT/src
    ;# une archive runtime sera cree dans X = /adv_11/KAS/C30/OSROOT/Linux
    ;#
    ;# les sources sont directement accroches sous la racine
    ;#
    set OpenSource(inar,source)   ""
    ;#
    ;# les runtime sont sont sous le nom de la plateforme cible
    ;#
    set OpenSource(inar,runtime) $OpenSource(dest,runtime)
    ;#

    ;# -------------------- CORRESPONDANCE WOK-uname et convention pour les noms court.
    ;# L'index dans le tableau est le resltat de uname. Le reste c'est MDTV-tambouille.
    ;#set OpenSource(misc,Linux) lin
    ;#set OpenSource(misc,wokadm,Linux) LIN
    ;#set OpenSource(misc,SunOS) sun
    ;#set OpenSource(misc,wokadm,SunOS) SUN
    ;#set OpenSource(misc,IRIX) sil
    ;#set OpenSource(misc,wokadm,IRIX) SIL
    return 1
}
;#
;#
;#
;#
proc OS:info { lm {id stdout} } {
    global OpenSource
    foreach m $lm {
	puts $id "Module: $m (defined in [woklocate -p OS:source:${m}.tcl][woklocate -p VAS:source:${m}.tcl] ) "
	foreach t [info procs ${m}:*] {
	    puts $id " [lindex [split $t :] 1] :"
	    foreach r [$t] {
		puts $id "   $r"
	    }
	}
    }
}
;#
;# retourne pour un module donne la liste des procs de compils et de links
;# a modifier et a embarquer.
;# les conventions sont: u.comp compilations de l'ud u => editee par edcomp.
;#                       u.lnk  link (.so ou exe) de u => editee par edlnk.
;# liste de retour = { {type tk udname path} ... }
;# PKGS appelle direct PACKAGES car sur archimex pas WOK pour l'instant.
;#
proc OS:procs { module plat} {

    set lret {}
    foreach tkloc [${module}:toolkits] {
	set PKGS [woklocate -p ${tkloc}:PACKAGES]
	if [file exist $PKGS] {
	    set listloc [wokUtils:FILES:FileToList $PKGS]
	    foreach loc $listloc {
		set comp [OS:getcomp $loc $plat]
		if [file exists $comp] {
		    lappend lret [list compilation $tkloc $loc $comp]
		}
	    }
	} else {
	    puts stderr "Erreur: Pas de fichier PACKAGES pour $tkloc"
	}
	if [file exists [set lnkf [OS:getlinkso $tkloc $plat]]] {
	    lappend lret [list link $tkloc $tkloc $lnkf]
	} else {
	    puts stderr "Erreur: Pas de fichier $lnkf"
	}
    }
    ;# autres UDs en plus des toolkits.
    ;#
    foreach d2  [${module}:ressources] {
	set artyp [lindex $d2 0]
	set dectyp [lindex $d2 1]
	set loc [lindex $d2 2]
	set tgt [lindex $d2 3]
	if { "$dectyp" == "x" } {
	      set cxxlist [uinfo -f -T source [woklocate -u $loc]]
              foreach listent $cxxlist {
	 	set pureitem [file rootname $listent]
		set extitem [file extension $listent]
		if {$extitem == ".cxx"} {
		   #puts $pureitem
	           set comp [OS:getcompx $loc $plat $pureitem]
                   #puts "comp is $comp"
		   if { $comp != {} } {
		       lappend lret [list compilation $loc $loc $comp]
		   } else {
		       puts stderr "Information: Pas de fichier $comp"
		   }
		}
	      }
	} else {
	    set comp [OS:getcomp $loc $plat]
	    if { $comp != {} } {
		lappend lret [list compilation {} $loc $comp]
	    } else {
		puts stderr "Information: Pas de fichier $comp"
	    }
	}
	if { "$dectyp" == "x" } {
	    set cxxlist [uinfo -f -T source [woklocate -u $loc]]
            foreach listent $cxxlist {
		set pureitem [file rootname $listent]
		set extitem [file extension $listent]
		if {$extitem == ".cxx"} {
		    ;#puts $pureitem
	           if [file exists [set lnkf [OS:getlinkx $loc $plat $pureitem]]] {
		       lappend lret [list executable $loc $pureitem $lnkf]
		   } else {
		       puts stderr "Information: Pas de fichier de $lnkf"
		   }
                }
            }
	} else {
	    if [file exists [set lnkf [OS:getlinkso $loc $plat]]] {
		lappend lret [list link {} $loc $lnkf]
	    } else {
		puts stderr "Information: Pas de fichier $lnkf"
	    }
	}
    }
    return $lret
}

##
# Returns location of root workbench or value of CASROOT variable if defined
#
proc OS:casroot {} {
    global env
    if { [info exists env(CASROOT)] } {
      return $env(CASROOT)
    }

    return [wokinfo -p HomeDir [lindex [w_info -A [wokcd]] end]]
}
;#
;#
;#
proc OS:pfmroot { askplat } {
    if { [set d [OS:casroot $askplat]] != {} } {
	return [file join $d $askplat]
    }
}
;#
;# The file tree definition ( platform dependant parts )
;#
proc OS:admroot { askplat } {
    if { [set d [OS:casroot $askplat]] != {} } {
	return [file join $d adm $askplat]
    }
}

proc OS:objroot { askplat } {
    if { [set d [OS:pfmroot $askplat]] != {} } {
	return [file join $d  obj]
    }
}

proc OS:libroot { askplat } {
    if { [set d [OS:pfmroot $askplat]] != {} } {
	return [file join $d  lib]
    }
}

proc OS:binroot { askplat } {
    if { [set d [OS:pfmroot $askplat]] != {} } {
	return [file join $d  bin]
    }
}

;#
;# The file tree definition ( platform independant parts )
;#
proc OS:srcroot { askplat } {
    if { [set d [OS:casroot $askplat]] != {} } {
	return [file join $d  src]
    }
}
proc OS:drvroot { askplat } {
    if { [set d [OS:casroot $askplat]] != {} } {
	return [file join $d  drv]
    }
}
proc OS:incroot { askplat } {
    if { [set d [OS:casroot $askplat]] != {} } {
	return [file join $d  inc]
    }
}
;#
;#
;#
;#
proc OS:admadm { module dir plat since ls1s2 {verbose 0} } {
    set lret     {}
    set ldon     {}
    foreach d2 [OS:wokadm $module $plat $verbose] {
	regsub -all -- {[/\.]} [lindex $d2 1] _ tnam
	if { $verbose } { puts "Traitement de [lindex $d2 0]" }
	if ![file exists [file join $dir $tnam]] {
	    set done [wokUtils:EASY:lreplace  [lindex $d2 0] [file join $dir $tnam] $ls1s2]
	    lappend lret "[file join $dir $tnam] [lindex $d2 1]"
	    if { $done } {
		lappend ldon "[file join $dir $tnam] [lindex $d2 1]"
	    }
	} else {
	    puts stderr "Plusieurs occurences de $tnam dans $dir"
	    return {}
	}
    }
    return [list $lret $ldon]
}
;#
;# fabrique la proc pour reconstruire un module a partir du format
;# retourne par OS:procs { {type tk ud path} }
;# retourne la liste des fulls paths des fichiers fabriques.
;# ainsi que celui les invoquant tous a la queue leu leu
;# option since genere des .COMP INCOMPLETS !!
;#
proc OS:mkmk { module dir plat since {verbose 0} } {

    set lret     {}
    set lnk      {}
    set lothcmp  {}  ;# il ya 2 listes pour lancer les compils d'abord
    set lothlnk  {}  ;# puis les links ensuite. Les UD listes dans ressources
                     ;# peuvent ainsi etre listees dans un ordre quelconque.
    set exceptso [${module}:LinksoWith]
    set exceptcc [${module}:CompileWith]
    set do_nothing_here [list IRIX AIX HP-UX] ;# ne pas toucher aux .lnk de pop ici
    ;#puts "plat $plat"
    if { "$plat" == "SunOS"} { set OsName "solaris" }
    if { "$plat" == "Linux"} { set OsName "linux" }
    if { "$plat" == "WindowsNT"} {set OsName "win32"}
    if { "$plat" == "win32"} {set OsName "win32"}
    if { "$plat" == "win64"} {set OsName "win64"}
    ;#puts [OS:procs $module $plat]
    set lothcmp {}

    foreach d3 [OS:procs $module $plat] {
	if { $verbose } { puts  "Modification de $d3" }
	set type  [lindex $d3 0]
	set tkloc [lindex $d3 1]
	set loc   [lindex $d3 2]
	set pfile [lindex $d3 3]

	if { ($since == {}) || ($since != {} && ([file mtime $pfile] > $since)) } {

	    switch -- $type {

		compilation {
		    set incstr " -I[OS:srcroot $plat]/$loc -I[OS:drvroot $plat]/$loc -I[OS:incroot $plat] -I[OS:srcroot $plat]/WOKTclLib -I\${JAVAHOME}/include -I\${JAVAHOME}/include/${OsName}"
		    set tcstr [OS:casroot $plat]/
		    set tostr ""
		    if { [uinfo -t [woklocate -u $tkloc]] == "toolkit" } {
                        set hdr {}
			lappend hdr [format "echo 'Compiling $loc'"]
			lappend hdr [format "source \$\{CASROOT\}/adm/${plat}/init"]
			lappend hdr [format "mkdir -p [OS:objroot $plat]/%s  >& /dev/null" $loc]
			lappend hdr [format "pushd [OS:objroot $plat]/%s >& /dev/null " $loc]
			set lwr [OS:edcomp $plat $hdr $pfile $exceptcc $incstr $tcstr $tostr]
			lappend lwr "popd >& /dev/null"
		    } else {
                        if [info exists CLOC($loc)] {
			} else {
			    set lwr {}
			    set hdr {}
			    lappend lwr [format "echo 'Compiling $loc'"]
			    lappend lwr [format "source \$\{CASROOT\}/adm/${plat}/init"]
			    lappend lwr [format "mkdir -p [OS:objroot $plat]/%s  >& /dev/null" $loc]
			  set CLOC($loc) $lwr
			}
  		        lappend lwr [format "pushd [OS:objroot $plat]/%s >& /dev/null " $loc]
			set lwr [concat $lwr [OS:edcomp $plat $hdr $pfile $exceptcc $incstr $tcstr $tostr]]
			lappend lwr "popd >& /dev/null"
		    }
		    wokUtils:FILES:ListToFile $lwr [file join $dir ${loc}.comp]
		    lappend lret [file join $dir ${loc}.comp]
		    if { [uinfo -t [woklocate -u $tkloc]] == "toolkit" } {
			if [info exists TLOC($tkloc)] {
			    set mktk $TLOC($tkloc)
			    lappend mktk "csh -f [OS:admroot $plat]/${loc}.comp"
			    set TLOC($tkloc) $mktk
			} else {
			    set mktk {}
			    lappend  mktk "csh -f [OS:admroot $plat]/${loc}.comp"
			    set TLOC($tkloc) $mktk
			}
		    } else {
                        if [info exists XLOC($loc)] {
                          #set lothcmp $XLOC($loc)
			  ;# Procedure de compils d'uds non dans le toolkit.
			  ;#lappend lothcmp "csh -f [OS:admroot $plat]/${loc}.comp"
			  #set XLOC($loc) $lothcmp
			} else {
			  lappend lothcmp "csh -f [OS:admroot $plat]/${loc}.comp"
			  set XLOC($loc) $lothcmp
                          #puts "$loc $lothcmp "
			}
		    }
		}

		link {
		    if { [lsearch $do_nothing_here $plat] == -1 } {
			set hdrl {}
			lappend hdrl [format "echo 'Linking $loc'"]
			lappend hdrl [format "source  \$\{CASROOT\}/adm/${plat}/init"]
			lappend hdrl [format "mkdir -p [OS:libroot $plat]  >& /dev/null" ]
			wokUtils:FILES:ListToFile \
				[OS:edlnkso $plat $hdrl $pfile $exceptso [OS:libroot $plat] [OS:pfmroot $plat] [OS:libroot $plat] ] \
				[file join $dir ${loc}.lnk]
			;# mettre [file tail $pfile plutot que ${loc}.lnk TOPOLOGY ??
			lappend lnk [file join $dir ${loc}.lnk]
		    } else {
			lappend lnk $pfile
		    }
		    if { $tkloc == {} } {
			lappend lothlnk "csh -f [OS:admroot $plat]/${loc}.lnk"
		    }
		}

		executable {
		    if { [lsearch $do_nothing_here $plat] == -1 } {
			set hdrl {}
			lappend hdrl [format "echo 'Linking $loc'"]
			lappend hdrl [format "source  \$\{CASROOT\}/adm/${plat}/init"]
			lappend hdrl [format "mkdir -p [OS:binroot $plat]  >& /dev/null" ]
                        if {[wokparam -v %WOKSteps_exec_link [woklocate -u $tkloc]] != "#WOKStep_LibLink(exec.tks)"} {
			    wokUtils:FILES:ListToFile \
				[OS:edlnkx $plat $hdrl $pfile $exceptso [OS:libroot $plat] [OS:pfmroot $plat] [OS:binroot $plat] ] \
				[file join $dir ${loc}.lnk]
			} else {
			    wokUtils:FILES:ListToFile \
				[OS:edlnkso $plat $hdrl $pfile $exceptso [OS:libroot $plat] [OS:pfmroot $plat] [OS:libroot $plat] ] \
				[file join $dir ${loc}.lnk]
			}
			lappend lnk [file join $dir ${loc}.lnk]
			;# mettre [file tail $pfile plutot que ${loc}.lnk TOPOLOGY ??
		    } else {
			lappend lnk $pfile
		    }
			lappend lothlnk "csh -f [OS:admroot $plat]/${loc}.lnk"
		}

                default {
		    puts "format invalide dans OS:MKPRC"
		}
	    }
	} else {
	    puts "bof du since"
	}
    }

    ;# Fab d'un TK Compilations + link du Tk apres ces compils.
    ;#
    if [info exists TLOC] {
	foreach tk [array names TLOC] {
	    set do [lsort $TLOC($tk)]
	    lappend do "csh -f [OS:admroot $plat]/${tk}.lnk"
	    wokUtils:FILES:ListToFile $do [file join $dir ${tk}.comp]
	    lappend lret [file join $dir ${tk}.comp]
	}
    }
    ;# faisons suivre les links dans le bon s'il vous plait
    ;#
    set lmak {}
    foreach tk [${module}:toolkits] {
	lappend lmak "csh -f [OS:admroot $plat]/${tk}.comp"
    }
    ;# les autres procs (executables packages) si elles existent.
    ;#
	if { $lothcmp != {} } {
	    set lmak  [concat $lmak $lothcmp]
	}
    if { $lothlnk != {} } {
	set lmak [concat $lmak $lothlnk]
    }
    wokUtils:FILES:ListToFile $lmak [file join $dir ${module}.COMP]
    lappend lret [file join $dir ${module}.COMP]
    return [concat $lret $lnk]
}
;#
;# modifie un fichier de compil Linux pour retirer les pathes
;# -I completement remplaces par incDirectories => include systems BOUM!!
;# -c path -o path. je remplace tout sauf la derniere composante du path
;# de facon a garder drv et src (on compile aussi dans drv)
;#
proc OS:edcomp { plat lhdr comp {except {}} {incstr <incDirectories>} {tcstr ""} {tostr ""} } {
    set lret $lhdr
    foreach lin [wokUtils:FILES:FileToList $comp] {
	set str {}
	set done 0
	set tc 0
	set to 0
	if {$plat == "Linux"} {
	    set compiler [lindex $lin 3]
	} else {
	    set compiler [lindex $lin 0]
	}
	set compstring ""
        if {$plat == "SunOS"} {
	    if [regexp -- {/CC} $compiler all find] {
		set compstring "\${CXXCOMP} "
	    }
	    if [regexp -- {/cc} $compiler all find] {
		set compstring "\${CCOMP} "
	    }
	}
	if {$plat == "Linux"} {
	    if [regexp -- {/gcc} $compiler all find] {
		set compstring "\${CCOMP} "
	    } else {
		set compstring "\${CXXCOMP} "
	    }
	}
        append str "$compstring"
	foreach tok [split $lin] {
	    if [regexp -- {-I(.*)}  $tok all new] {
		#puts "tok is |$new | '|[lindex [wokparam -v %CSF_X11_INCLUDE] 0]|'"
		#puts "$except"
		if { [lsearch $except $new] != -1 } {
		    set CXXINC [lindex [wokparam -v %CSF_CXX_INCLUDE] 0]
		    set TCLINC "[lindex [wokparam -v %CSF_TCL_INCLUDE] 0]"
		    if { "$new " == $CXXINC} {
			append str "-I\${COMPINCLUDE} "
		    } elseif  {"-I$new " == $TCLINC} {
			append str "-I\${TCLHOME}/include "
		    } elseif  {"$tok " == "[lindex [wokparam -v %CSF_X11_INCLUDE] 0]"} {
			#puts "X11 was captured"
			append str "-I\${X11_INCLUDE} "
		    } elseif {"$new " =="[lindex [wokparam -v %CSF_JavaHome] 0]"} {

		    } else {
			append str "$tok "
		    }

		} else {
		    if { $done == 0 } {
			    append str "$incstr"
			    set done 1
			}
	        }

	    } elseif { $tok == "-o" } {
		set to 1
	    } elseif { $tok == "-c" } {
		set tc 1
	    }  else {
		if { $to != 1 && $tc != 1 } {
		    if { "$plat" == "SunOS" || "$plat" == "Linux" } {
			set TrueCond [expr {"$tok" != "-H" && "$tok" != "/usr/bin/g++" && "$tok" != "/usr/bin/gcc" && ![regexp -- {/CC} $tok all find] && ![regexp -- {/cc} $tok all find] && "$tok" != "cd" && "$tok" != "&&" && ![regexp -- {/obj/.tmp/} $tok all find]}]
			if { $TrueCond } {
				append str $tok " "
			}
		    } else {
			append str $tok " "
		    }
		} else {
		    if { $tc == 1 } {
			set tail [wokUtils:FILES:wtail $tok 3]
			append str " -c ${tcstr}$tail"
			set tc 0
		    }
		    if { $to == 1 } {
			append str " -o ${tostr}[file tail $tok]"
			set to 0
		    }

		}

	    }

	}
	lappend lret $str
    }
    return $lret
}
;#
;# idem que edcomp mais modifie un fichier .lnk Linux d'un executable
;# ici incstr est utilise pour la directive -L
;# i.e -L/un/path devient -L$incstr
;#
proc OS:edlnkx { plat lhdr lnkf { except {} } {incstr <incDirectories>} {tcstr ""} {tostr ""}} {
    set lret $lhdr
    foreach lin [wokUtils:FILES:FileToList $lnkf] {
	set str {}
	set str {}
        set compiler [lindex $lin 0]
	set compstring ""
        if {$plat == "SunOS"} {
	    if [regexp -- {/CC} $compiler all find] {
		set compstring "\${CXXCOMP} "
	    }
	}
	if {$plat == "Linux"} {
	    if [regexp -- {/g} $compiler all find] {
		set compstring "\${CXXCOMP} "
	    }
	}
	lappend str $compstring
	if ![regexp {^#![ ]*/bin/csh} $lin all uu] {
	    if ![regexp {^cd } $lin] {
		if [regexp {([^ ]*\.o) \\} ${lin} all tt] {
		    lappend lret [format "%s/%s \\" $tcstr [wokUtils:FILES:wtail $tt 3]]
		} else {
		    set to 0
 		    set TCLLIB [expr {$lin == " [lindex [wokparam -v %CSF_TclLibs] 0] \\"}]
	 	    set TKLIB [expr {$lin == " [lindex [wokparam -v %CSF_TclTkLibs] 0] \\"}]
                    set SetExpr [expr { $lin == "set CSF_CXX_COMPILER = \"[lindex [wokparam -v %CSF_CXX_COMPILER] 0]\""}]
		    if { $TCLLIB} {
			lappend str " -L\${TCLHOME}/lib -ltcl \\"
		    } elseif {$TKLIB} {
			lappend str " -L\${TCLHOME}/lib -ltk \\"
		    } elseif {$SetExpr} {
			lappend str " set CSF_CXX_COMPILER = \$\{CXXCOMP\}"
		    } else {
		    foreach tok [split $lin] {
			if { $tok == "-o" } {
			    set to 1
			    lappend str $tok
			} else {
			    if { $to == 1 } {
				set nam [file tail $tok]
				if { "$nam" != "null" } {
				    lappend str [format "%s/%s" $tostr $nam]
				} else {
				    lappend str $tok
				}
				set to 0
			    } else {
				if [regexp {^[ ]*-L(.*)} $tok all dir] {
				    if { [lsearch $except $dir] == -1 } {
					lappend str -L${incstr}
				    } else {
					lappend str $tok
				    }
				} else {
				    set Truetok [string compare $tok [string trimright [lindex [wokparam -v %CSF_CXX_COMPILER] 0]]]
                                    if {$Truetok} {
                                        lappend str $tok
                                    }
                                }
			    }
			}
		    }
		    }
		    lappend lret [join $str " "]
		}
	    }
	}
    }
    return $lret
}
;#
;# idem que edcomp mais modifie un fichier .lnk Linux d'un toolkit
;# ici incstr est utilise pour la directive -L
;# i.e -L/un/path devient -L$incstr si il n'est pas dans except
;#
proc OS:edlnkso { plat lhdr lnkf { except {} } {incstr <incDirectories>} {tcstr ""} {tostr ""}} {
    set lret $lhdr
    foreach lin [wokUtils:FILES:FileToList $lnkf] {
	set str {}
        set compiler [lindex $lin 0]
	set compstring ""
        if {$plat == "SunOS"} {
	    if [regexp -- {/CC} $compiler all find] {
		set compstring "\${CXXCOMP} "
	    }
	}
	if {$plat == "Linux"} {
	    if [regexp -- {/g} $compiler all find] {
		set compstring "\${CXXCOMP} "
	    }
	}
	lappend str $compstring
	if ![regexp {^#![ ]*/bin/csh} $lin all uu] {
	    if ![regexp {^cd } $lin] {
		if [regexp {([^ ]*\.o) \\} ${lin} all tt] {
		    lappend lret [format "%s/%s \\" $tcstr [wokUtils:FILES:wtail $tt 3]]
		} else {
		    set to 0
		    set TCLLIB [expr {$lin == " [lindex [wokparam -v %CSF_TclLibs] 0] \\"}]
		    set TKLIB [expr {$lin == " [lindex [wokparam -v %CSF_TclTkLibs] 0] \\"}]
                    set X11LIB [expr {$lin == " [lindex [wokparam -v %CSF_XwLibs] 0] \\"}]
		    if { $TCLLIB} {
			lappend str " -L\${TCLHOME}/lib -ltcl \\"
		    } elseif { $TKLIB } {
	    		lappend str " -L\${TCLHOME}/lib -ltk \\"
		    } elseif { $X11LIB} {
                      	lappend str " -L\${X11_LIB} -lX11 -lXext -lXmu \\"
                    } elseif { [expr {$lin == " [lindex [wokparam -v %CSF_dpsLibs] 0] \\"}]} {
                        if { $plat == "SunOS" } {
                      	   lappend str " -L\${X11_LIB} -ldps \\"
			}
                    } else {
		    foreach tok [split $lin] {
			if { $tok == "-o" } {
			    set to 1
			    lappend str $tok
			} else {
			    if { $to == 1 } {
				set nam [file tail $tok]
				if { "$nam" != "null" } {
				    lappend str [format "%s/%s" $tostr $nam]
				} else {
				    lappend str $tok
				}
				set to 0
			    } else {
				if [regexp {^[ ]*-L(.*)} $tok all dir] {
				    if { [lsearch $except $dir] == -1 } {
					lappend str -L${incstr}
				    } else {
					lappend str $tok
				    }
				} else {
				    set Truetok [string compare $tok [string trimright [lindex [wokparam -v %CSF_CXX_COMPILER] 0]]]
 				    if {$Truetok} {
                                        lappend str $tok
                                    }
                                }
			    }
			}
		    }
		    }
		    set str [join $str " "]
		    if {![regexp {^[ ]*$} $str all find]} {
			lappend lret $str
		    } else {
			lappend lret " \\"
		    }
		}
	    }
	}
    }
    set res {}
    set inx 0
    foreach x $lret {
	lappend res $x
	incr inx
	if [regexp -- {[^;]*;} $x] {
	    break
	}
    }
    return $res
}
;# retourne la composante de path avec la partie a gauchae
;# ou a droite de str
;#
;#
proc OS:trimpath { path str {included 1} {from left} } {
    set l [file split $path]
    if { [set i [lsearch $l $str]] != -1 } {
	if { $from == "left" } {
	    if { $included } {
		return [lrange $l 0 $i]
	    } else {
		return [lrange $l 0 [incr i -1]]
	    }
	} elseif { $from == "right" } {
	    if { $included } {
		return [lrange $l $i end]
	    } else {
		return [lrange $l [incr i 1] end]
	    }
	}
    } else {
	return {}
    }
}
;#
;# on est en retard avec tcl 7.5
;#
proc OS:mkdir { d } {
    global tcl_version
    if ![file exists $d] {
	if { "$tcl_version" == "7.5" } {
	    mkdir -path $d
	} else {
	    file mkdir $d
	}
	if [file exists $d] {
	    return $d
	} else {
	    return {}
	}
    } else {
	return $d
    }
}
;#
;#
;#
proc OS:delete { f } {
    global tcl_version
    if { "$tcl_version" == "7.5" } {
	unlink $f
    } else {
	file delete $f
    }
}
;#
;#
;#
proc OS:copy { fin fout } {
    global tcl_version
    if { "$tcl_version" == "7.5" } {
	if { [catch { set in [ open $fin r ] } errin] == 0 } {
	    if { [catch { set out [ open $fout w ] } errout] == 0 } {
		set nb [copyfile $in $out]
		close $in
		close $out
		return 1
	    } else {
		puts stderr "Error: $errout"
		return -1
	    }
	} else {
	    puts stderr "Error: $errin"
	    return -1
	}

    } else {
	if { "[file type $fin]" == "link" } {
	    file copy -force [file readlink $fin] $fout
	} else {
	    file copy -force $fin $fout
	}
	return 1
    }
}
;#
;#
;#
proc OS:wpack { module dir {verbose 0} } {
    set lret {}
    foreach m  $module {
	set fbck [file join $dir ${m}.bck]
        if { $verbose } {
	    wpack -v -c -f $fbck -u [join [OS -u list $m] ,]
	} else  {
	    wpack -c -f $fbck -u [join [OS -u list $m] ,]
	}
	lappend lret $fbck
    }
    return $lret
}

;#
;#   ((((((( GENERATION OF PROJECT FILES FOR VISUAL STUDIO )))))))
;#
;# fabrique le sln de module et le place dans dir. Retourne le
;# full path du fichier cree.
;# Si tklist est {} utilise module pour la calculer.
;# Sinon utilise tklist donnee en argument.
;# Dans ce cas module est seulement utilise pour le nom de fichier .sln
;# Avec ca je fais un OCC.sln qui concatene plusieurs modules dans le bon ordre.
;#
proc OS:genGUID { {theIDE "vc"} } {
  if { "$theIDE" == "vc" } {
    set p1 "[format %07X [expr { int(rand() * 268435456) }]][format %X [expr { int(rand() * 16) }]]"
    set p2 "[format %04X [expr { int(rand() * 6536) }]]"
    set p3 "[format %04X [expr { int(rand() * 6536) }]]"
    set p4 "[format %04X [expr { int(rand() * 6536) }]]"
    set p5 "[format %06X [expr { int(rand() * 16777216) }]][format %06X [expr { int(rand() * 16777216) }]]"
    return "{$p1-$p2-$p3-$p4-$p5}"
  } else {
    set p1 "[format %04X [expr { int(rand() * 6536) }]]"
    set p2 "[format %04X [expr { int(rand() * 6536) }]]"
    set p3 "[format %04X [expr { int(rand() * 6536) }]]"
    set p4 "[format %04X [expr { int(rand() * 6536) }]]"
    set p5 "[format %04X [expr { int(rand() * 6536) }]]"
    set p6 "[format %04X [expr { int(rand() * 6536) }]]"
    #set p1 "[format %06X [expr { int(rand() * 16777216) }]][format %06X [expr { int(rand() * 16777216) }]]"
    #set p2 "[format %06X [expr { int(rand() * 16777216) }]][format %06X [expr { int(rand() * 16777216) }]]"
    return "$p1$p2$p3$p4$p5$p6"
  }
}

# generate Visual Studio solution file
# if module is empty, generates one solution for all known modules
proc OS:vcsolution { theVcVer theSolName theModules theOutDir theGuidsMap } {
  upvar $theGuidsMap aGuidsMap

  # collect list of projects to be created
  set aProjects {}
  set aDependencies {}
  foreach aModule $theModules {
    # toolkits
    foreach aToolKit [osutils:tk:sort [${aModule}:toolkits]] {
      lappend aProjects $aToolKit
      lappend aProjectsInModule($aModule) $aToolKit
      lappend aDependencies [LibToLink [woklocate -u $aToolKit]]
    }

    # executables, assume one project per cxx file...
    foreach aUnit [OS:executable ${aModule}] {
      set aUnitLoc [woklocate -u $aUnit]
      set aSrcFiles [uinfo -f -T source $aUnitLoc]
      foreach aSrcFile $aSrcFiles {
        set aFileExtension [file extension $aSrcFile]
        if { $aFileExtension == ".cxx" } {
          set aPrjName [file rootname $aSrcFile]
          lappend aProjects $aPrjName
          lappend aProjectsInModule($aModule) $aPrjName
          if {[wokinfo -x $aUnitLoc] != "0"} {
            lappend aDependencies [LibToLinkX $aUnitLoc [file rootname $aSrcFile]]
          } else {
            lappend aDependencies {}
          }
        }
      }
    }
  }

  # generate GUIDs for projects (unless already known)
  foreach aProject $aProjects {
    if { ! [info exists aGuidsMap($aProject)] } {
      set aGuidsMap($aProject) [OS:genGUID]
    }
  }

  # generate solution file
  puts "Generating Visual Studio ($theVcVer) solution file for $theSolName ($aProjects)"
  append aFileBuff [osutils:vcsolution:header $theVcVer]

  # GUID identifying group projects in Visual Studio
  set VC_GROUP_GUID "{2150E333-8FDC-42A3-9474-1A3956D46DE8}"

  # generate group projects -- one per module
  if { "$theVcVer" != "vc7" && [llength "$theModules"] > 1 } {
    foreach aModule $theModules {
      if { ! [info exists aGuidsMap(_$aModule)] } {
        set aGuidsMap(_$aModule) [OS:genGUID]
      }
      set aGuid $aGuidsMap(_$aModule)
      append aFileBuff "Project(\"${VC_GROUP_GUID}\") = \"$aModule\", \"$aModule\", \"$aGuid\"\nEndProject\n"
    }
  }

  # extension of project files
  set aProjExt [osutils:vcproj:ext $theVcVer]

  # GUID identifying C++ projects in Visual Studio
  set VC_CPP_GUID "{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}"

  # generate project "All"
  # set allGUID \{570118B7-F56D-41C9-A838-29464CD03149\}
  # append aFileBuff  "Project(\"${VC_CPP_GUID}\") = \"All\", \"All.${aProjExt}\", \"$allGUID\"\n"
  # if { [llength $aGuidsMap] > 0 } {
  #	  append aFileBuff  "\tProjectSection(ProjectDependencies) = postProject\n"
  #	  foreach aGuid $aGuidsMap {
  #	    append aFileBuff "\t\t$aGuid = $aGuid\n"
  #	  }
  #	  append aFileBuff "\tEndProjectSection\n"
  # }
  # append aFileBuff "EndProject\n"

  # generate normal projects
  set aProjsNb [llength $aProjects]
  for {set aProjId 0} {$aProjId < $aProjsNb} {incr aProjId} {
    set aProj [lindex $aProjects $aProjId]
    set aGuid $aGuidsMap($aProj)
    append aFileBuff "Project(\"${VC_CPP_GUID}\") = \"$aProj\", \"$aProj.${aProjExt}\", \"$aGuid\"\n"
    # write projects dependencies information (vc7 to vc9)
    set aDepGuids ""
    foreach aDepLib [lindex $aDependencies $aProjId] {
      if { $aDepLib != $aProj && [lsearch $aProjects $aDepLib] != "-1" } {
        set depGUID $aGuidsMap($aDepLib)
        append aDepGuids "\t\t$depGUID = $depGUID\n"
      }
    }
    if { "$aDepGuids" != "" } {
      append aFileBuff "\tProjectSection(ProjectDependencies) = postProject\n"
      append aFileBuff "$aDepGuids"
      append aFileBuff "\tEndProjectSection\n"
    }
    append aFileBuff "EndProject\n"
  }

  # generate configuration section
  if { "$theVcVer" == "vc8" } {
    append aFileBuff [osutils:vcsolution:config:begin $theVcVer]
    foreach aProj $aProjects {
      append aFileBuff [osutils:vcsolution:config:project $theVcVer $aGuidsMap($aProj)]
    }
    append aFileBuff [osutils:vcsolution:config:end $theVcVer]
  } else {
    append aFileBuff [osutils:vcsolution:config:begin $theVcVer]
    # append aFileBuff [osutils:vcsolution:config:project $theVcVer $allGUID]
    foreach aProj $aProjects {
      append aFileBuff [osutils:vcsolution:config:project $theVcVer $aGuidsMap($aProj)]
    }
    append aFileBuff [osutils:vcsolution:config:end $theVcVer]
  }

  # write information of grouping of projects by module
  if { "$theVcVer" != "vc7" && [llength "$theModules"] > 1 } {
    append aFileBuff "	GlobalSection(NestedProjects) = preSolution\n"
    foreach aModule $theModules {
      if { ! [info exists aProjectsInModule($aModule)] } { continue }
      foreach aProject $aProjectsInModule($aModule) {
        append aFileBuff "		$aGuidsMap($aProject) = $aGuidsMap(_$aModule)\n"
      }
    }
    append aFileBuff "	EndGlobalSection\n"
  }

  # final word (footer)
  append aFileBuff "EndGlobal"

  # write solution
  set aFile [open [set fdsw [file join $theOutDir ${theSolName}.sln]] w]
  fconfigure $aFile -translation crlf
  puts $aFile $aFileBuff
  close $aFile
  return [file join $theOutDir ${theSolName}.sln]
}

# Generate Visual Studio projects for specified version
proc OS:vcproj { theVcVer theModules theOutDir theGuidsMap } {
  upvar $theGuidsMap aGuidsMap

  set aProjectFiles {}

  foreach aModule $theModules {
    foreach aToolKit [${aModule}:toolkits] {
      lappend aProjectFiles [osutils:vcproj  $theVcVer $theOutDir $aToolKit     aGuidsMap]
    }
    foreach anExecutable [OS:executable ${aModule}] {
      lappend aProjectFiles [osutils:vcprojx $theVcVer $theOutDir $anExecutable aGuidsMap]
    }
  }
  return $aProjectFiles
}

# Function to generate Visual Studio solution and project files
proc OS:MKVC { theOutDir {theModules {}} {theAllSolution ""} {theVcVer "vc8"} } {

  puts stderr "Generating VS project files for $theVcVer"

  # generate projects for toolkits and separate solution for each module
  foreach aModule $theModules {
    OS:vcsolution $theVcVer $aModule $aModule $theOutDir ::THE_GUIDS_LIST
    OS:vcproj     $theVcVer $aModule          $theOutDir ::THE_GUIDS_LIST
  }

  # generate single solution "OCCT" containing projects from all modules
  if { "$theAllSolution" != "" } {
    OS:vcsolution $theVcVer $theAllSolution $theModules $theOutDir ::THE_GUIDS_LIST
  }

  puts "The Visual Studio solution and project files are stored in the $theOutDir directory"
}

# Function to generate CMake meta file
proc OS:MKCMK { theOutDir {theModules {}} {theAllSolution ""} } {
  puts stderr "Generating CMake meta project"

  set aSubPath "adm/cmake"
  set aModulesFileName       "occt_modules.cmake"
  set aBeingIncludedToolkits "occt_inc_toolkits.cmake"
  set aBeingUsedToolkits     "occt_toolkits.cmake"

  set aModulesTmpl       [osutils:readtemplate cmake_modules       "OCCT modules"]
  set aToolkitsTmpl      [osutils:readtemplate cmake_toolkits      "toolkit dependencies"]
  set anIncToolkitsTmpl  [osutils:readtemplate cmake_inc_toolkits  "toolkits including"]

  # modules of occt
  set aBuff [list]
  foreach aModule $theModules {
    if {$aModule == "Draw"} {
      lappend aBuff "if (NOT DEFINED ANDROID)"
    }
    
    lappend aBuff "set (BUILD_${aModule} ON CACHE BOOL \"include ${aModule}\"  )"
    
    if {$aModule == "Draw"} {
      lappend aBuff "ENDIF()"
    }
  }
  regsub -all -- {__MODULE_LIST__}  $aModulesTmpl  [join $aBuff "\n"] aModulesTmpl

  # dynamic content of occt
  set aBuff [list]
  foreach aModule $theModules {
    foreach aToolKit [${aModule}:toolkits] {
      set aDepToolkits [join [LibToLink [woklocate -u $aToolKit]] ";"]
      lappend aBuff "set(${aToolKit}_DEPS \"${aDepToolkits}\")"
    }
    foreach anExecutable [OS:executable ${aModule}] {
      set aDepToolkits [join [LibToLink [woklocate -u $anExecutable]] ";"]
      lappend aBuff "set(${anExecutable}_DEPS \"${aDepToolkits}\")"
    }
  }
  regsub -all -- {__TOOLKIT_DEPS__} $aToolkitsTmpl  [join $aBuff "\n"] aToolkitsTmpl

  set aBuff [list]
  foreach aModule $theModules {
    lappend aBuff ""
    lappend aBuff "if (BUILD_${aModule})"
    foreach aToolKit [${aModule}:toolkits] {
      set isVTK 0
      set anIndent ""
      if {[regexp -nocase {.*vtk.*} $aToolKit]} {
        set isVTK 1
        set anIndent "  "
      }
      if {$isVTK} {
        lappend aBuff "  if (USE_VTK)"
      }
      lappend aBuff "${anIndent}  list (APPEND USED_TOOLKITS ${aToolKit} )"
      lappend aBuff "${anIndent}  foreach( TK \$\{${aToolKit}_DEPS\})"
      lappend aBuff "${anIndent}    LIST(APPEND USED_TOOLKITS \$\{TK\} )"
      lappend aBuff "${anIndent}  endforeach()"
      if {$isVTK} {
        lappend aBuff " endif()"
      }
    }
    foreach anExecutable [OS:executable ${aModule}] {
      lappend aBuff "  if (\"\$\{BUILD_LIBRARY_TYPE\}\" STREQUAL \"Shared\")"
      lappend aBuff "    list (APPEND USED_TOOLKITS ${anExecutable} )"
      lappend aBuff "    foreach( TK \$\{${anExecutable}_DEPS\})"
      lappend aBuff "      list (APPEND USED_TOOLKITS \$\{TK\} )"
      lappend aBuff "    endforeach()"
      lappend aBuff "  else()"
      lappend aBuff "    message (STATUS \"Info: ${anExecutable} is not included due to \$\{BUILD_LIBRARY_TYPE\} build library type\")"
      lappend aBuff "  endif()"
      lappend aBuff ""
    }
    lappend aBuff "endif()"
  }
  regsub -all -- {__MODULE_DEPS__}  $aToolkitsTmpl  [join $aBuff "\n"] aToolkitsTmpl

  set aBuff [list]
  foreach aModule $theModules {
    foreach aToolKit [${aModule}:toolkits] {
      #create directory
      if {![file exists "$theOutDir/$aSubPath/$aToolKit"]} {
        file mkdir "$theOutDir/$aSubPath/$aToolKit"
      }

      set isVTK 0
      set anIndent ""
      if {[regexp -nocase {.*vtk.*} $aToolKit]} {
        set isVTK 1
        set anIndent "  "
      }
      if {$isVTK} {
        lappend aBuff "IF (USE_VTK)"
      }
      #add directory to main cmake metafile
      lappend aBuff "${anIndent}if (EXISTS \"\$\{TK_ROOT_DIR\}/$aSubPath/${aToolKit}\")"
      lappend aBuff "${anIndent}  add_subdirectory(\$\{TK_ROOT_DIR\}/$aSubPath/${aToolKit})"
      lappend aBuff "${anIndent}else()"
      lappend aBuff "${anIndent}  list (APPEND UNSUBDIRS \"$aSubPath/${aToolKit}\")"
      lappend aBuff "${anIndent}endif()"
      if {$isVTK} {
        lappend aBuff "ENDIF()"
      }

      # create cmake metafile into target subdir
      osutils:cmktk $theOutDir/$aSubPath $aToolKit false ${aModule}
    }
    foreach anExecutable [OS:executable ${aModule}] {
      #create directory
      if {![file exists "$theOutDir/$aSubPath/$anExecutable"]} {
        file mkdir "$theOutDir/$aSubPath/$anExecutable"
      }

      #add directory to main cmake metafile
      lappend aBuff "if (EXISTS \"\$\{TK_ROOT_DIR\}/$aSubPath/${anExecutable}\")"
      lappend aBuff "  add_subdirectory(\$\{TK_ROOT_DIR\}/$aSubPath/${anExecutable})"
      lappend aBuff "else()"
      lappend aBuff "  list (APPEND UNSUBDIRS \"$aSubPath/${anExecutable}\")"
      lappend aBuff "endif()\n"

      # create cmake metafile into target subdir
      osutils:cmktk $theOutDir/$aSubPath $anExecutable true ${aModule}
    }
  }
  regsub -all -- {__INCLUDE_TOOLKITS__} $anIncToolkitsTmpl  [join $aBuff "\n"] anIncToolkitsTmpl

  #generate cmake files
  set aFile [open [set fdsw [file join "$theOutDir/$aSubPath" $aModulesFileName]] w]
  fconfigure $aFile -translation crlf
  puts $aFile $aModulesTmpl
  close $aFile

  set aFile [open [set fdsw [file join "$theOutDir/$aSubPath" $aBeingUsedToolkits]] w]
  fconfigure $aFile -translation crlf
  puts $aFile $aToolkitsTmpl
  close $aFile
  
  set aFile [open [set fdsw [file join "$theOutDir/$aSubPath" $aBeingIncludedToolkits]] w]
  fconfigure $aFile -translation crlf
  puts $aFile $anIncToolkitsTmpl
  close $aFile

  puts "The Cmake meta-files are stored in the [file normalize $theOutDir/$aSubPath] directories"
}

# Generates Code Blocks workspace.
proc OS:cworkspace { theSolName theModules theOutDir } {
  set aWsFilePath "${theOutDir}/${theSolName}.workspace"
  set aFile [open $aWsFilePath "w"]
  set isActiveSet 0
  puts $aFile "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\" ?>"
  puts $aFile "<CodeBlocks_workspace_file>"
  puts $aFile "\t<Workspace title=\"${theSolName}\">"

  # collect list of projects to be created
  foreach aModule $theModules {
    # toolkits
    foreach aToolKit [osutils:tk:sort [${aModule}:toolkits]] {
      set aDependencies [LibToLink [woklocate -u $aToolKit]]
      if { [llength $aDependencies] == 0 } {
        puts $aFile "\t\t<Project filename=\"${aToolKit}.cbp\" />"
      } else {
        puts $aFile "\t\t<Project filename=\"${aToolKit}.cbp\" >"
        foreach aDepTk $aDependencies {
          puts $aFile "\t\t\t<Depends filename=\"${aDepTk}.cbp\" />"
        }
        puts $aFile "\t\t</Project>"
      }
    }

    # executables, assume one project per cxx file...
    foreach aUnit [OS:executable ${aModule}] {
      set aUnitLoc [woklocate -u $aUnit]
      set aSrcFiles [uinfo -f -T source $aUnitLoc]
      foreach aSrcFile $aSrcFiles {
        set aFileExtension [file extension $aSrcFile]
        if { $aFileExtension == ".cxx" } {
          set aPrjName [file rootname $aSrcFile]
          set aDependencies [list]
          if {[wokinfo -x $aUnitLoc] != "0"} {
            set aDependencies [LibToLinkX $aUnitLoc [file rootname $aSrcFile]]
          }
          set anActiveState ""
          if { $isActiveSet == 0 } {
            set anActiveState " active=\"1\""
            set isActiveSet 1
          }
          if { [llength $aDependencies] == 0 } {
            puts $aFile "\t\t<Project filename=\"${aPrjName}.cbp\"${anActiveState}/>"
          } else {
            puts $aFile "\t\t<Project filename=\"${aPrjName}.cbp\"${anActiveState}>"
            foreach aDepTk $aDependencies {
              puts $aFile "\t\t\t<Depends filename=\"${aDepTk}.cbp\" />"
            }
            puts $aFile "\t\t</Project>"
          }
        }
      }
    }
  }

  puts $aFile "\t</Workspace>"
  puts $aFile "</CodeBlocks_workspace_file>"
  close $aFile

  return $aWsFilePath
}

# Generate Code Blocks projects
proc OS:cbp { theModules theOutDir } {
  set aProjectFiles {}
  foreach aModule $theModules {
    foreach aToolKit [${aModule}:toolkits] {
      lappend aProjectFiles [osutils:cbptk $theOutDir $aToolKit ]
    }
    foreach anExecutable [OS:executable ${aModule}] {
      lappend aProjectFiles [osutils:cbpx  $theOutDir $anExecutable]
    }
  }
  return $aProjectFiles
}

proc OS:MKAMK { theOutDir {theModules {}} theSubPath} {
  wokUtils:FILES:mkdir $theOutDir

  foreach aModule $theModules {
    foreach aToolKit [$aModule:toolkits] {
      puts " toolkit: $aToolKit ==> [woklocate -p ${aToolKit}:source:EXTERNLIB]"
      wokUtils:FILES:rmdir $theOutDir/$aToolKit
      wokUtils:FILES:mkdir $theOutDir/$aToolKit
      osutils:tk:mkam $theOutDir/$aToolKit $aToolKit
    }
    foreach anExecutable [OS:executable $aModule] {
      wokUtils:FILES:rmdir $theOutDir/$anExecutable
      wokUtils:FILES:mkdir $theOutDir/$anExecutable
      osutils:tk:mkamx $theOutDir/$anExecutable $anExecutable
    }
  }

  osutils:am:adm $theOutDir $theModules
  osutils:am:root [wokinfo -p HomeDir] $theSubPath $theModules

  puts "The automake files are stored in the $theOutDir directory"
}

# Function to generate Code Blocks workspace and project files
proc OS:MKCBP { theOutDir {theModules {}} {theAllSolution ""} } {

  puts stderr "Generating project files for Code Blocks"

  # Generate projects for toolkits and separate workspace for each module
  foreach aModule $theModules {
    OS:cworkspace $aModule $aModule $theOutDir
    OS:cbp        $aModule          $theOutDir
  }

  # Generate single workspace "OCCT" containing projects from all modules
  if { "$theAllSolution" != "" } {
    OS:cworkspace $theAllSolution $theModules $theOutDir
  }

  puts "The Code Blocks workspace and project files are stored in the $theOutDir directory"
}

# Generates toolkits sections for Xcode workspace file.
proc OS:xcworkspace:toolkits { theModule } {
  set aBuff ""

  # Adding toolkits for module in workspace.
  foreach aToolKit [osutils:tk:sort [${theModule}:toolkits]] {
    append aBuff "         <FileRef\n"
    append aBuff "            location = \"group:${aToolKit}.xcodeproj\">\n"
    append aBuff "         </FileRef>\n"
  }

  # Adding executables for module, assume one project per cxx file...
  foreach aUnit [OS:executable ${theModule}] {
    set aUnitLoc [woklocate -u $aUnit]
    set aSrcFiles [uinfo -f -T source $aUnitLoc]
    foreach aSrcFile $aSrcFiles {
      set aFileExtension [file extension $aSrcFile]
      if { $aFileExtension == ".cxx" } {
        set aPrjName [file rootname $aSrcFile]
        append aBuff "         <FileRef\n"
        append aBuff "            location = \"group:${aPrjName}.xcodeproj\">\n"
        append aBuff "         </FileRef>\n"
      }
    }
  }

  # Removing unnecessary newline character from the end.
  set aBuff [string replace $aBuff end end]
  return $aBuff
}

# Generates workspace files for Xcode.
proc OS:xcworkspace { theWorkspaceName theModules theOutDir } {
  # Creating workspace directory for Xcode.
  set aWorkspaceDir "${theOutDir}/${theWorkspaceName}.xcworkspace"
  OS:mkdir $aWorkspaceDir
  if { ! [file exists $aWorkspaceDir] } {
    puts stderr "Error: Could not create workspace directory \"$aWorkspaceDir\""
    return
  }

  # Creating workspace file.
  set aWsFilePath "${aWorkspaceDir}/contents.xcworkspacedata"
  set aFile [open $aWsFilePath "w"]
  
  # Adding header and section for main Group.
  puts $aFile "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
  puts $aFile "<Workspace"
  puts $aFile "   version = \"1.0\">"
  puts $aFile "   <Group"
  puts $aFile "      location = \"container:\""
  puts $aFile "      name = \"${theWorkspaceName}\">"
  
  # Adding modules.
  if { [llength "$theModules"] > 1 } {
    foreach aModule $theModules {
      puts $aFile "      <Group"
      puts $aFile "         location = \"container:\""
      puts $aFile "         name = \"${aModule}\">"
      puts $aFile [OS:xcworkspace:toolkits $aModule]
      puts $aFile "      </Group>"
    }
  } else {
    puts $aFile [OS:xcworkspace:toolkits $theModules]
  }

  # Adding footer.
  puts $aFile "   </Group>"
  puts $aFile "</Workspace>"
  close $aFile
}

# Generates Xcode project files.
proc OS:xcodeproj { theModules theOutDir theGuidsMap theLibType thePlatform} {
  upvar $theGuidsMap aGuidsMap

  set isStatic 0
  if { "$theLibType" == "static" } {
    set isStatic 1
  } elseif { "$thePlatform" == "ios" } {
    set isStatic 1
  }

  set aProjectFiles {}
  foreach aModule $theModules {
    foreach aToolKit [${aModule}:toolkits] {
      lappend aProjectFiles [osutils:xcdtk $theOutDir $aToolKit     aGuidsMap $isStatic $thePlatform "dylib"]
    }
    foreach anExecutable [OS:executable ${aModule}] {
      lappend aProjectFiles [osutils:xcdtk $theOutDir $anExecutable aGuidsMap $isStatic $thePlatform "executable"]
    }
  }
  return $aProjectFiles
}

# Function to generate Xcode workspace and project files
proc OS:MKXCD { theOutDir {theModules {}} {theAllSolution ""} {theLibType "dynamic"} {thePlatform ""} } {

  puts stderr "Generating project files for Xcode"

  # Generate projects for toolkits and separate workspace for each module
  foreach aModule $theModules {
    OS:xcworkspace $aModule $aModule $theOutDir
    OS:xcodeproj   $aModule          $theOutDir ::THE_GUIDS_LIST $theLibType $thePlatform
  }

  # Generate single workspace "OCCT" containing projects from all modules
  if { "$theAllSolution" != "" } {
    OS:xcworkspace $theAllSolution $theModules $theOutDir
  }
}

# Store global GUIDs map to reproduce same values on sequential calls
set aTKNullKey "TKNull"
set THE_GUIDS_LIST($aTKNullKey) "{00000000-0000-0000-0000-000000000000}"

# Entry function to generate project files and solutions for IDE
proc OS:MKPRC { {theOutDir {}} {theProjectType {}} {theIDE ""} {theLibType "dynamic"} {thePlatform ""} } {
  set aSupportedIDE { "vc7" "vc8" "vc9" "vc10" "vc11" "vc12" "cbp" "cmake" "amk" "xcd"}

  if { [lsearch $aSupportedIDE $theIDE] < 0 } {
    puts stderr "WOK does not support generation of project files for the selected IDE: $theIDE\nSupported IDEs: [join ${aSupportedIDE} " "]"
    return
  }
  
  set anOutRoot $theOutDir
  if { $anOutRoot == "" } {
    set anOutRoot [OS -box]
  }

  # read map of already generated GUIDs
  set aGuidsFilePath [file join $::env(WOK_SESSIONID) "wok_${theIDE}_guids.txt"]
  if [file exists "$aGuidsFilePath"] {
    set aFileIn [open "$aGuidsFilePath" r]
    set aFileDataRaw [read $aFileIn]
    close $aFileIn
    set aFileData [split $aFileDataRaw "\n"]
    foreach aLine $aFileData {
      set aLineSplt [split $aLine "="]
      if { [llength $aLineSplt] == 2 } {
        set ::THE_GUIDS_LIST([lindex $aLineSplt 0]) [lindex $aLineSplt 1]
      }
    }
  }

  # make list of modules and platforms
  set aModules [OS:listmodules $theProjectType {win32}]

  # generate one solution for all projects if complete OS or VAS is processed
  set anAllSolution ""
  if { $theProjectType == "OS" } {
    set anAllSolution "OCCT"
  } elseif { $theProjectType == "VAS" } {
    set anAllSolution "Products"
  }

  # Create output directory
  set aWokStation "$::env(WOKSTATION)"

  if { [lsearch -exact {vc7 vc8 vc9 vc10 vc11 vc12} $theIDE] != -1 } {
    set aWokStation "msvc"
  }

  set anOutDir "${anOutRoot}/${aWokStation}/${theIDE}"

  if { "$theIDE" == "cmake" } {
    set anOutDir "${anOutRoot}/${theIDE}"
  }
  
  OS:mkdir $anOutDir
  if { ! [file exists $anOutDir] } {
    puts stderr "Error: Could not create output directory \"$anOutDir\""
    return
  }

  # Generating project files for the selected IDE
  switch -exact -- "$theIDE" {
    "vc7"   -
    "vc8"   -
    "vc9"   -
    "vc10"   -
    "vc11"   -
    "vc12"  { OS:MKVC  $anOutDir $aModules $anAllSolution $theIDE }
    "cbp"   { OS:MKCBP $anOutDir $aModules $anAllSolution }
    "cmake" { OS:MKCMK "${anOutRoot}/.." $aModules $anAllSolution }
    "amk"   { OS:MKAMK $anOutDir $aModules "adm/${aWokStation}/${theIDE}"}
    "xcd"   {
      set ::THE_GUIDS_LIST($::aTKNullKey) "000000000000000000000000" 
      OS:MKXCD $anOutDir $aModules $anAllSolution $theLibType $thePlatform
    }
  }

  # generate config.txt file
  if { ${anAllSolution} == "Products" && "$::env(WOKSTATION)" == "wnt" } {
    osutils:mkCollectScript "collect_binary.cfg" "$anOutRoot/../" ${theIDE} $::env(ARCH) "release"
  }

  # Store generated GUIDs map
  set anOutFile [open "$aGuidsFilePath" "w"]
  fconfigure $anOutFile -translation lf
  foreach aKey [array names ::THE_GUIDS_LIST] {
    set aValue $::THE_GUIDS_LIST($aKey)
    puts $anOutFile "${aKey}=${aValue}"
  }
  close $anOutFile
}

;#
;# Fabrication des archives "source" :
;# Pas de plateforme a specifier.
;#
proc  OS:PKGSRC { {ll {} } {mode link} } {

    set BOX  [OS -box]
    set lmodules [OS -lm]
    if { $ll != {} } { set lmodules $ll }
    set lesmodules {}
    foreach mo $lmodules {
	if { [lsearch [${mo}:Export] source] != -1 } {
	    lappend lesmodules $mo
	}
    }

    ;# La ou on cree l'arborescence pour l'archive.
    ;# et le nom de la racine contenue dans l'archive
    ;#
    set TMPDIR /dn01/KAS/dev/ros/work
    set ROOT   [OS:archive_root]
    ;# La ou on met le tar.gz avec le nom desire.
    ;#
    set DISTRIB [OS -distrib]
    set fmtnam "$DISTRIB/source%s-[OS:dotted_version].tar"

    if { [lsearch [list copy link] $mode] == -1 } {
	puts stderr "OS:PKGSRC erreur: mode=copy ou mode=link"
	return
    }


    foreach module $lesmodules {
	puts stderr "OS:PKGSRC($module)"
	set LISTE {}

	;#OS -lsource $module -v -o $BOX/$module.sources
	OS -lsource $module -o $BOX/$module.sources
	OS -u udlist $module -o $BOX/$module.UDLIST
	set lx [wokUtils:FILES:FileToList $BOX/$module.sources]
	lappend lx "$BOX/$module.UDLIST [file join adm $module.UDLIST]"
	wokUtils:FILES:ListToFile $lx $BOX/${module}.sources
	if [file exists $BOX/${module}.sources] {
	    lappend LISTE $BOX/${module}.sources
	} else {
	    puts stderr "Erreur : pas de fichier $BOX/${module}.sources"
	    return
	}
	;# Pour embarquer les projets Visual.
	;#
	foreach plats [concat [OS:plats_disponibles] WindowsNT] {
	    if [file exists $BOX/$plats/${module}.admfiles] {
		lappend LISTE $BOX/$plats/${module}.admfiles
	    } else {
		puts stderr "Note : pas de fichier $BOX/$plats/${module}.admfiles"
	    }
	}
	;#OS -lressource $module -v -type source -o $BOX/$module.ressources
	OS -lressource $module  -type source -o $BOX/$module.ressources
	if [file exists $BOX/${module}.ressources] {
	    lappend LISTE $BOX/${module}.ressources
	}

	OS -lfreefiles ${module} -type source -o $BOX/${module}.freefiles
	if [file exists $BOX/${module}.freefiles] {
	    lappend LISTE $BOX/${module}.freefiles
	} else {
	    puts stderr "Erreur : Pas de fichier $BOX/${module}.freefiles"
	}

	set tmpdir [file join $TMPDIR $module src]

	set r [OS -mktree -mode $mode -from [join $LISTE ,] -tmpdir $tmpdir -root $ROOT]

	set znam [format $fmtnam [${module}:name]]
	set z [OS -mkar $znam $module -tmpdir $tmpdir -root $ROOT]

    }
}


proc  OS:EXTRSRC { {ll {} } {mode link} } {

    set BOX  [OS -box]
    set lmodules [OS -lm]
    if { $ll != {} } { set lmodules $ll }
    set lesmodules {}
    foreach mo $lmodules {
	if { [lsearch [${mo}:Export] source] != -1 } {
	    lappend lesmodules $mo
	}
    }

    set lx ""
    set ff [open [wokinfo -p AdmDir :OS:OCC:RELEASE]/UDLIST w]
    foreach module $lesmodules {
	OS -u udlist $module -o /tmp/UDLIST
        for_file Ustr /tmp/UDLIST {
	    puts $ff $Ustr
	}

    }
   close $ff
}
;#
;# Fabrique les archives RunTime
;# OS:PKGRTL Linux Draw 1 1
;#
proc  OS:PKGRTL { {llplat {}} {ll {} } { mode link } } {

    set BOX  [OS -box]

    set lesplats [OS:plats_disponibles]
    if { $llplat != {} } { set lesplats $llplat }
    set lmodules [OS -lm]
    if { $ll != {} } {  set lmodules $ll }

    set lesmodules {}
    foreach mo $lmodules {
	if { [lsearch [${mo}:Export] runtime] != -1 } {
	    lappend lesmodules $mo
	}
    }

    set TMPDIR /dn01/KAS/dev/ros/work
    set ROOT   [OS:archive_root]

    set DISTRIB [OS -distrib]
    set fmtnam "$DISTRIB/%s%s-[OS:dotted_version].tar"

    foreach plat $lesplats {
	puts stderr "OS:PKGRTL: $plat"
	foreach module $lesmodules {
	    set LISTE {}
	    OS -os $plat -lshare $module -o $BOX/$plat/$module.share
	    lappend LISTE $BOX/$plat/$module.share
	    ;#
	    ;#  Si le module a des ressources runtime.
	    ;#
	    OS -os $plat -lressource $module -type runtime -o $BOX/$plat/$module.ressources
	    lappend LISTE $BOX/$plat/$module.ressources
	    OS -lfreefiles ${module} -type runtime -o $BOX/$plat/${module}.freefiles
	    lappend LISTE $BOX/$plat/${module}.freefiles
	    set tmpdir [file join $TMPDIR $module $plat]

	    puts "mktree: "
	    set r [OS -v -mktree -mode $mode -from [join $LISTE ,] -tmpdir $tmpdir -root [file join $ROOT $plat]]
	    if [file exists $r/src ] {
		set savpwd [pwd]
		cd $r/..
		puts stderr "Dans [pwd] on renomme $plat/src ."
		exec mv $plat/src .
		cd $savpwd
	    }

	    puts "mkar: "
	    set znam [format $fmtnam $plat [${module}:name]]
	    set z [OS -mkar $znam -tmpdir $tmpdir -root $ROOT]

	}
    }
}

# Administration de wok
proc OS:PKGADM { plat { ll {} } } {
  ;#
  ;# ce qui suit veut dire que:
  ;# on substitue /adv_11/KAS/C30/ref par TOSUBSTITUTE ET /adv_11/KAS/C30/UpdateC31 par TOSUBSTITUTE etc..
  ;# sur la plateforme correspondante.
  ;#
  set TOTRIM(wokadm,WindowsNT) nothing,nothing
  set TOTRIM(wokadm,SunOS)     \
    /dn01/KAS/dev/roc,TOSUBSTITUTE,/adv_11/KAS/C30/UpdateC31,TOSUBSTITUTE,/adv_10/KAS/C30/UpdateC31,TOSUBSTITUTE
  set TOTRIM(wokadm,IRIX)      \
    /dn01/KAS/dev/ros,TOSUBSTITUTE,/adv_11/KAS/C30/UpdateC31,TOSUBSTITUTE,/adv_10/KAS/C30/UpdateC31,TOSUBSTITUTE
  set TOTRIM(wokadm,Linux)     \
    /dn01/KAS/dev/ros,TOSUBSTITUTE,/adv_11/KAS/C30/UpdateC31,TOSUBSTITUTE,/adv_10/KAS/C30/UpdateC31,TOSUBSTITUTE
  set TOTRIM(wokadm,AIX)       \
    /dn01/KAS/dev/ros,TOSUBSTITUTE,/adv_11/KAS/C30/UpdateC31,TOSUBSTITUTE,/adv_10/KAS/C30/UpdateC31,TOSUBSTITUTE

  set BOX [OS -box]
  set lmodules [OS -lm]
  if { $ll != {} } {  set lmodules $ll }
  set lesmodules {}
  foreach mo $lmodules {
    if { [lsearch [${mo}:Export] wokadm] != -1 } {
      lappend lesmodules $mo
    }
  }

  set TMPDIR /dn01/KAS/dev/ros/work/ADM
  set ROOT   [OS:archive_root]

  set DISTRIB [OS -distrib]
  set fmtnam "$DISTRIB/%swokadm%s-[OS:dotted_version].tar"

  puts stderr "OS:PKGADM: $plat . On retire $TOTRIM(wokadm,$plat) des fichiers wokadm"

  foreach module $lesmodules {
    set tmpdir [file join $TMPDIR $module $plat]
    catch { exec rm -rf $tmpdir }
    OS -os $plat -makadm $tmpdir $module -substr $TOTRIM(wokadm,$plat) \
    -subdone [file join $tmpdir $module.TOSUBSTITUTE] -o $BOX/$plat/$module.wokadm
    OS -u udlist $module -o [file join $tmpdir $module.UDLIST]
    set lx [wokUtils:FILES:FileToList $BOX/$plat/$module.wokadm]
    lappend lx "[file join $tmpdir $module.UDLIST] [file join adm $module.UDLIST]"
    lappend lx "[file join $tmpdir $module.TOSUBSTITUTE] [file join adm $plat $module.TOSUBSTITUTE]"
    wokUtils:FILES:ListToFile $lx $BOX/$plat/$module.wokadm
    set r [OS -mktree -from $BOX/$plat/$module.wokadm -tmpdir $tmpdir -root $ROOT]
    set znam [format $fmtnam $plat [${module}:name]]
    set z [OS -mkar $znam -tmpdir $tmpdir -root $ROOT]
  }
}

# Sources des modules compactes a la wok
proc OS:SRCBCK { {ll {}} }  {

  set BOX  [OS -box]
  set lmodules [OS -lm]
  if { $ll != {} } { set lmodules $ll }
  set lesmodules {}
  foreach mo $lmodules {
    if { [lsearch [${mo}:Export] source] != -1 } {
      lappend lesmodules $mo
    }
  }
  ;# La ou on cree l'arborescence pour l'archive.
  ;# et le nom de la racine contenue dans l'archive
  ;#
  ;# La ou on met le tar.gz avec le nom desire.
  ;#
  set DISTRIB [OS -distrib]
  set fmtnam "$DISTRIB/%s-[OS:dotted_version].bck"

  foreach module $lesmodules {
    wokcd KAS:dev:ros
    puts stderr "OS:SRCBCK($module)"
    OS:wpack $module $DISTRIB 1
  }
}

# Fabrication des tar.gz avec option --files de tar. + rapide , + sur, + simple, + elegant.
proc OSPKGS { {ll {} } } {

  set BOX  [OS -box]
  set lmodules [OS -lm]
  if { $ll != {} } { set lmodules $ll }
  set lesmodules {}
  foreach mo $lmodules {
    if { [lsearch [${mo}:Export] source] != -1 } {
      lappend lesmodules $mo
    }
  }

  ;# La ou on cree l'arborescence pour l'archive.
  ;# et le nom de la racine contenue dans l'archive
  ;#
  set ROOT   [OS:archive_root]
  ;# La ou on met le tar.gz avec le nom desire.
  ;#
  set DISTRIB [OS -distrib]
  ;#set fmtnam "$DISTRIB/source%s-[OS:dotted_version].tar"
  set fmtnam "$DISTRIB/SOURCE%s-[OS:dotted_version].tar"

  set LISTOFROOTS [list /dn01/KAS/dev/ros/ /adv_11/KAS/C30/UpdateC31/ /dn01/KAS/dev/ros/drv/ /adv_11/KAS/C30/ros/ ]

  foreach module $lesmodules {
    puts stderr "OS:PKGS($module)"
    ;# Init de lsource par module.
    set lsource {}
    set lsource [concat $lsource [OS -LSOURCE $module]]
    OS -u udlist $module -o $BOX/$module.UDLIST
    set lsource [concat $lsource $BOX/$module.UDLIST]
    ;#
    ;# Pour embarquer les projets Visual.
    ;#
    foreach plats [concat [OS:plats_disponibles] WindowsNT] {
      if [file exists $BOX/$plats/${module}.admfiles] {
        puts " ADM = $BOX/$plats/${module}.admfiles "
        foreach proc [wokUtils:FILES:FileToList $BOX/$plats/${module}.admfiles] {
          ;#puts " proc = [lindex $proc 0]"
          set lsource [concat $lsource [lindex $proc 0]]
        }
        ;#lappend LISTE $BOX/$plats/${module}.admfiles
      } else {
        puts stderr "Note : pas de fichier $BOX/$plats/${module}.admfiles"
      }
    }

    set lsource [concat $lsource [OS -LRESSOURCE $module  -type source]]
    set lsource [concat $lsource [OS -LFREEFILES $module  -type source]]

    set znam [format $fmtnam [${module}:name]]
    set r3 [wokUtils:EASY:gnutar $LISTOFROOTS $lsource $znam]
    if { [set ignored    [lindex $r3 0]] == {} } {
      set script     [lindex $r3 1]
      wokUtils:FILES:ListToFile $script [set command [wokUtils:FILES:tmpname ${module}]]
      if ![catch { eval exec csh -f $command } status ] {
        puts stderr $status
        unlink $command
      } else {
        puts "Ex ERROR: $status"
      }
      foreach f [lindex $r3 2] {
        OS:delete $f
      }
    } else {
      puts "OSPKGS : Fatal ( $module ): Impossible de traiter :"
      foreach f $ignored {
        puts $f
      }
    }
  }

  return
}

# Fabrique les archives RunTime
# OS:PKGRTL Linux Draw 1 1
proc  OSPKGR { {llplat {}} {ll {} } } {

  set BOX [OS -box]

  set lesplats [OS:plats_disponibles]
  if { $llplat != {} } { set lesplats $llplat }
  set lmodules [OS -lm]
  if { $ll != {} } { set lmodules $ll }

  set lesmodules {}
  foreach mo $lmodules {
    if { [lsearch [${mo}:Export] runtime] != -1 } {
      lappend lesmodules $mo
    }
  }

  set ROOT    [OS:archive_root]
  set DISTRIB [OS -distrib]
  set fmtnam "$DISTRIB/NEW%s%s-[OS:dotted_version].tar"

  set LISTOFROOTS [list /dn01/KAS/dev/ros/ /adv_11/KAS/C30/UpdateC31/ /adv_10/KAS/C30/UpdateC31/ /adv_11/KAS/C30/ros/ ]

  foreach plat $lesplats {
    puts stderr "OS:PKGR: $plat"
    foreach module $lesmodules {
      set lruntime {}
      set lruntime [concat $lruntime [OS -os $plat -LSHARE $module]]
      set lruntime [concat $lruntime [OS -os $plat -LRESSOURCE $module  -type runtime]]
      set lruntime [concat $lruntime [OS -LFREEFILES ${module} -type runtime ]]
      puts "$module : "
      foreach rtl [lsort $lruntime] {
        puts $rtl
      }
      set znam [format $fmtnam $plat [${module}:name]]
      set r3 [wokUtils:EASY:gnutar $LISTOFROOTS $lruntime $znam]
      if { [set ignored    [lindex $r3 0]] == {} } {
        set script [lindex $r3 1]
        wokUtils:FILES:ListToFile $script [set command [wokUtils:FILES:tmpname ${plat}${module}]]
        if ![catch { eval exec csh -f $command } status ] {
          puts stderr $status
          unlink $command
        } else {
          puts "Ex ERROR: $status"
        }
        foreach f [lindex $r3 2] {
          OS:delete $f
        }
      } else {
        puts "OSPKGR : Fatal ( $module ): Impossible de traiter :"
        foreach f $ignored {
          puts $f
        }
      }
    }
  }
}

##############
# just for test
proc OS:xml { lm } {
  set doc [::dom::DOMImplementation create]
  set top [::dom::document createElement $doc OpenCascade]
  foreach m $lm {
    puts stderr " module $m ... "
    set mnode [::dom::document createElement $top module]
    dom::element setAttribute $mnode name $m
    foreach tkloc [${m}:toolkits] {
      set tknod [::dom::document createElement $mnode toolkit]

      set lcsf  [osutils:tk:hascsf [woklocate -p ${tkloc}:source:EXTERNLIB [wokcd]]]
      if { $lcsf != {} } {
        dom::element setAttribute $tknod externlibs [join $lcsf ,]
      }
      ;#set lclose  [wokUtils:LIST:Purge [osutils:tk:close [woklocate -u $tkloc]]]
      ;#if { $lclose != {} } {
      ;#dom::element setAttribute $tknod usedtk [join $lclose ,]
      ;#}
      set ids [woklocate -p [wokinfo -n [wokinfo -u $tkloc]]:source:EXTERNLIB [wokinfo -w [woklocate -u $tkloc]]]
      set eated [osutils:tk:eatpk $ids]
      if { $eated != {} } {
        dom::element setAttribute $tknod usedtk [join $eated ,]
      }
      dom::element setAttribute $tknod name $tkloc
      set lun [osutils:tk:units [woklocate -u $tkloc] 3]
      foreach namu $lun {
        set unode [::dom::document createElement $tknod devunit]
        dom::element setAttribute $unode name [lindex $namu 1]
        dom::element setAttribute $unode type [lindex $namu 0]
        foreach fil [osutils:tk:files [lindex $namu 1] {} 1] {
          set fnode [::dom::document createElement $unode source]
          dom::element setAttribute $fnode name $fil
        }
      }
    }
  }
  return [::dom::DOMImplementation serialize $doc -newline toolkit]
}

# ABV 30.07.2010: remains of eliminated OSDEF.tcl put below

# retourne l'adresse du fichier .comp pour l'ud <loc>
# le fichier .comp contient les phrases de compils
# pour tous les sources de l'UD.
# Les procs Linux sont maintenant sur le serveur.
proc OS:getcomp { loc askplat } {
  set f [woklocate -p ${loc}:stadmfile:${loc}.comp]
  if { [file exists $f] } {
    return $f
  }
  puts stderr "Error (OS:getcomp): Could not locate file ${loc}.comp"
  return ""
}

# debug temporaire je n'ai pas le temps.
# ce machin n'est pas coherent avec la nomination WOK des UD exec
# Ud U => U_a.comp et a.lnk pour l'executable a de U
# je verrais ca plus tard.
proc OS:getcompx { loc askplat name } {
  set f [woklocate -p ${loc}:stadmfile:${loc}_${name}.comp]
  if { [file exists $f] } {
    return $f
  }
  puts stderr "Error (OS:getcompx): Could not locate file ${loc}_${name}.comp"
  return ""
}

# toolkits mis dans une shareable.
# retourne l'adresse du fichier .lnk pour l'ud <tkloc>
# le fichier .lnk contient la phrase de link
proc OS:getlinkso { tkloc askplat } {
  set f [woklocate -p ${tkloc}:stadmfile:${tkloc}.lnk]
  if { [file exists $f] } {
    return $f
  }
  puts stderr "Error (OS:getlinkso): Could not locate file ${tkloc}.lnk"
  return ""
}

# toolkits mis dans une shareable.
# retourne l'adresse du fichier .lnk pour l'ud <tkloc>
# le fichier .lnk contient la phrase de link
proc OS:getlinkx { loc askplat name} {
  set f [woklocate -p ${loc}:stadmfile:${name}.lnk]
  if { [file exists $f] } {
    return $f
  }
  puts stderr "Error (OS:getlinkx): Could not locate file ${name}.lnk"
  return ""
}

# Peut maintenant retourner une liste d'items.
# Pour les .exp de pop sur IBM
proc OS:getshare { tkloc askplat } {
  switch -- $askplat {

    IRIX {
      return [woklocate -p ${tkloc}:library:lib${tkloc}.so]
    }

    Linux {
      return [woklocate -p ${tkloc}:library:lib${tkloc}.so]
    }

    #HP-UX {
    #  return [woklocate -p ${tkloc}:library:lib${tkloc}.sl]
    #}

    SunOS {
      return [woklocate -p ${tkloc}:librarylib${tkloc}.so]
    }

    #AIX {
    #    return [list [woklocate -p ${tkloc}:library:lib${tkloc}.so] \
    #           [woklocate -p ${tkloc}:library:lib${tkloc}.exp]
    #}

    WindowsNT {
      return [list [woklocate -p ${tkloc}:library:${tkloc}.dll] [woklocate -p ${tkloc}:library:${tkloc}.lib]]
    }

    win32 {
      return [list [woklocate -p ${tkloc}:library:${tkloc}.dll] [woklocate -p ${tkloc}:library:${tkloc}.lib]]
    }

    win64 {
      return [list [woklocate -p ${tkloc}:library:${tkloc}.dll] [woklocate -p ${tkloc}:library:${tkloc}.lib]]
    }

    default {
      puts "Completer getshare sur $askplat."
      return {}
    }
  }
}

#
proc OS:getx { tkloc askplat } {
  set f [woklocate -p ${tkloc}:executable:${tkloc}]
  if { [file exists $f] } {
    return $f
  }
  puts stderr "Error (OS:getx): Could not locate file ${tkloc}"
  return ""
}

# Retourne la liste des plateformes
# Note: WindowsNT n'est pas mentionne car:
#
# 1. Les archives de sources sont plateforme independantes
# 2. Les procs de refab (placees dans les archives de source) sont
# fabriques specifiquement mais TOUT est fait sur Unix.(voir OS:MKPRC)
# 3. Les run-time sont traites directement depuis une machine NT.
# On specifie alors la plateforme desirees.
proc OS:plats_disponibles { } {
# return [list Linux SunOS IRIX AIX HP-UX]
  return [list SunOS Linux ]
}

# Nom de la racine dans l'archive.
proc OS:archive_root {} {
  return CAS[OS:dotted_version]
}

#
proc OS:dotted_version {} {
  return 6.5.3
}

#
proc OS:simple_version {} {
  return 653
}

#
proc OS:defbox {} {
  return [OS:casroot]/adm
}

# If "what" is OS or VAS, returns list of modules or projects, respectively;
# if it is empty, returns list of both modules and products,
# otherwise returns input value (assumed to be already a list of modules)
proc OS:listmodules {what {platforms {}}} {
  OS:init

  if { "$what" == "" } {
    if { "$platforms" != "" } {
      return [OS -lm -plat $platforms]
    } else {
      return [OS -lm]
    }
    return [OS -lm]
  } elseif { "$what" == "OS" } {
    return [OS:Modules $platforms]
  } elseif { "$what" == "VAS" } {
    return [VAS:Products]
  }
  return "$what"
}
