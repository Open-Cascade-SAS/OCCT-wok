#! /bin/csh -f


set neededLibrary = "libGL.so libGLU.so libglut.so"
set MesaDirectory = /usr/X11R6/lib

foreach lib (${neededLibrary})

    if (!(-e ${MesaDirectory}/${lib})) then
	echo "${MesaDirectory}/${lib} not exist "
	echo "  Mesa is required to Run OpenCascade "
	echo "    Mesa-3.1 or Mesa3.2 is recommended "
	echo "    you can download it on : http://sourceforge.net/project/showfiles.php?group_id=3"
	echo "        MesaLib-3.1.tar.gz and MesaDemos-3.1.tar.gz "
	echo "    or "
	echo "       MesaLib-3.2.tar.gz and MesaDemos-3.2.tar.gz "
	echo " Rq: if you use a Mesa3.0 you can use it with some link "
	echo "     cd ${MesaDirectory}"
	echo "     ln -s libGL.so  libMesaGL.so "
	echo "     ln -s libGLU.so libMesaGLU.so "
    endif

end
