#! /bin/csh -f

if ( !($?JAVAHOME) ) then

    echo " " 
    echo " " 
    echo " ---- Open Cascade : requirement " 
    echo " --------------------------------"
    echo " " 
    echo " the JDK 1.2.2 ( Java 2 )is needed to run and install the Samples Application and the ShapeViewer"
    echo "  and the ShapeViewer demonstration application "
    echo " " 
    echo "  Java 2 can be downloaded from : http://developer.java.sun.com "
    echo " "
    echo " "
    echo " Please refer to Distributor pages to know if some system patch are required"
    echo " the Distribution can be downloaded at :"
    echo " on SunOS :"
    echo " http://www.sun.com/software/solaris/java/download.html"
    echo " on Linux :"
    echo " http://java.sun.com/products/jdk/1.2/download-linux.html"
    echo " on IRIX :"
    echo " http://www.sgi.com/developers/devtools/languages/java2_122.html"
    echo " on AIX : " 
    echo " http://www6.software.ibm.com/dl/dka/dka-p"
    echo " " 
    echo " " 

endif

# Verification

set WhereITcl = `which java | awk '{print $1}' `
set defaultTcl = ""
    
if ( ${WhereITcl} != "no" && ${WhereITcl} != "which:" ) then
	set defaultTcl = ${WhereITcl}
	set dir = `dirname ${WhereITcl}`
	if ( `basename ${dir}` == "bin" ) then
	    set defaultTcl = `dirname ${dir}`
	endif
endif
set notDefine = 1

while ( ${notDefine} == 1 )
    if (! ($?JAVAHOME)) then

	echo " " 
	echo " " 
	echo -n " Please define the Path where you have installed your JAVA  distribution :[$defaultTcl]"
	set rep = $<
	if ( ${rep} == "" ) then 
	    setenv JAVAHOME ${defaultTcl}
        else 
	
	    if (!(-e ${rep})) then
		echo "This Directory doen't exist "
		echo "Please try again"
	    else
		setenv JAVAHOME ${rep}
	    endif
	    unset rep
	endif

    endif       
    if ($?JAVAHOME) then
	if (! (-e ${JAVAHOME}/bin/java)) then
	    echo "java not found in  ${JAVAHOME}/bin"
	    if ($?JAVAHOME) unsetenv JAVAHOME
	else
	    set notDefine = 0
	endif
    endif	
end

echo "JAVAHOME ${JAVAHOME} " > $argv[1]
exit

