#! /bin/csh -f
##
##
## This is a template to launch wokprocess
## you should edit this file to set 
## WOKHOME variable.
##
setenv WOKHOME  /adv_22/WOK/BAG/wok-K2-1A
##
##
##
setenv WOK_SESSIONID "/tmp/[id user]_[id process]"
setenv LD_LIBRARY_PATH "/home/hourax/home_users/jga/wb/jgak2/sil/lib:/adv_23/WOK/k2dev/ref/sil/lib:/adv_22/WOK/BAG/KERNEL-K2-1-WOK/sil/lib"
setenv WOK_LIBRARY     "/adv_23/WOK/k2dev/jgak2/src/WOKTclLib"

setenv WOK_LIBPATH    "/adv_23/WOK/k2dev/jgak2/prod/WOKTclLib/src:/adv_23/WOK/k2dev/jgak2/src/WOKernel:/adv_23/WOK/k2dev/ref/src/WOKernel:/adv_23/WOK/k2dev/jgak2/src/WOKBuilder:/adv_23/WOK/k2dev/jgak2/src/WOKMake/edls:/adv_23/WOK/k2dev/jgak2/src/WOKMake:/home/hourax/home_users/jga/wb/jgak2/sil/lib:/adv_23/WOK/k2dev/ref/sil/lib:/adv_23/WOK/k2dev/ref/src/CPPExt:/adv_23/WOK/k2dev/ref/sil/lib:/adv_22/WOK/BAG/wok-K2-1/lib:/adv_22/WOK/BAG/wok-K2-1/lib/sil"


/home/hourax/home_users/jga/wb/jgak2/sil/bin/wokprocess $argv
