#! /bin/csh -f

if ( !($?TCLHOME) ) then

    echo " " 
    echo " " 
    echo " ---- Open Cascade : requirement " 
    echo " --------------------------------"
    echo " " 
    echo " " 
    echo " TclTk is needed to Run Test Harness ( Topology , Viewer or DataExchange ) "
    echo " This product is available at : http://dev.scriptics.com "
    echo " "
    echo " on SunOS , IRIX : "
    echo "   libtcl7.5i.so and libtk4.1i.so "
    echo "   source distribution available at http://dev.scriptics.com/software/tcltk/7.5.html"
    echo " "
    echo " on Windows_NT : "
    echo "   libtcl7.6i.so and libtk4.1i.so "
    echo "   source distribution available at http://dev.scriptics.com/software/tcltk/7.6.html"
    echo " "
    echo " on Linux :  "
    echo "   libtcl8.0.so and libtk8.0.so "
    echo "   source distribution available at http://dev.scriptics.com/software/tcltk/8.0.html"
    echo " "
    echo " on AIX : " 
    echo "   libtcl8.1.so and libtk8.1.so "
    echo "   source distribution available at http://dev.scriptics.com/software/tcltk/8.1.html"
    echo " "
endif

if (! ($?STATION)) then

    setenv STATION `uname`
    if ( ${STATION} == "IRIX64" ) setenv STATION IRIX

endif
set notDefine = 1

    switch ( ${STATION} ) 

    case "IRIX"
    case "SunOS"
	set tclLib = libtcl7.5i.so
	set tkLib  = libtk4.1i.so
	breaksw
    case "AIX" :
	set tclLib = libtcl8.1.so
	set tkLib  = libtk8.1.so
	breaksw
    case "Linux" :
	set tclLib = libtcl.so
	set tkLib  = libtk.so
#	set tclLib = libtcl8.0.so
#	set tkLib  = libtk8.0.so
	breaksw
    endsw
endif

set WhereITcl = `which tclsh | awk '{print $1}' `
if ( ${WhereITcl} != "no" && ${WhereITcl} != "which:" ) then
    set defaultTcl = ${WhereITcl}
    set dir = `dirname ${WhereITcl}`
    if ( `basename ${dir}` == "bin" ) then
	set defaultTcl = `dirname ${dir}`
    else
	set defaultTcl = ""
    endif
endif

while ( ${notDefine} == 1 )
    if (!($?TCLHOME)) then
	echo -n " Please define the Path where you have installed your Tcl/TK distribution [${defaultTcl}] :"
	set rep = $<
	if ( ${rep} == "" ) then 
	    setenv TCLHOME ${defaultTcl}
        else 
	    if (!(-e ${rep})) then
		echo "This Directory doen't exist "
		echo "Please try again"
	    else
		setenv TCLHOME ${rep}
	    endif
	    unset rep
 	endif    
    endif
    if ( $?TCLHOME) then
	if (! (-e ${TCLHOME}/lib/${tclLib})) then
	    echo "${tclLib} not found in  ${TCLHOME}/lib"
	    if ($?TCLHOME) unsetenv TCLHOME
	else 
	    if (!(-e ${TCLHOME}/lib/${tkLib})) then
		echo "${tkLib} not found in  ${TCLHOME}/lib"
		if ($?TCLHOME) unsetenv TCLHOME
	    else 
		# cas specifique IRIX N32
		if ( ${STATION} == "IRIX" ) then
		    set typename = `file ${TCLHOME}/lib/${tclLib} | awk ' {print $3 } '`
		    if ( ${typename} == "N32") then
			    set notDefine = 0
		    else
			echo " ${TCLHOME}/lib/${tclLib} is not N32"
			if ($?TCLHOME) unsetenv TCLHOME 
		    endif
		else
		    set notDefine = 0
		endif
	    endif
	endif
    endif
end

if ($?tclLib)     unset tclLib
if ($?tkLib)      unset tkLib
if ($?rep)        unset rep
if ($?defaultTcl) unset defaultTcl

echo "TCLHOME ${TCLHOME} " > $argv[1]

