
global tcl_platform
if { $tcl_platform(os) == "Linux" }  {
package ifneeded Woktools 2.0 "tclPkgSetup $dir/lin Woktools 2.0 {
                                        {libTKWOKLibswoktoolscmd.so load {
					    msgprint msgisset msgissetcmd msgissetlong msgset msgsetcmd 
					    msgsetlong msgunset msgunsetcmd msgunsetlong msgsetheader 
					    msgunsetheader msgissetheader msginfo}}}"

package ifneeded Wokutils 2.0 "tclPkgSetup $dir Wokutils 2.0 {
    {libwokutilscmd.so load { wokcmp} } }"

package ifneeded Wok 2.0 "package require Woktools; 
                             tclPkgSetup $dir/lin Wok 2.0 {
				 {libTKWOKLibswokcmd.so load {
				     Sinfo Wcreate Winfo Wrm Wdeclare fcreate finfo frm pinfo screate 
				     sinfo srm ucreate uinfo umpmake umake urm w_info wcreate 
				     wokcd wokclose wokinfo wokparam wokprofile wokenv wrm wmove 
				     stepinputaddstepinputinfo stepoutputadd stepoutputinfo stepaddexecdepitem }}}"

package ifneeded Ms 2.0 "package require Woktools; 
                             tclPkgSetup $dir/lin Ms 2.0 {
				 {libTKWOKLibsmscmd.so load {
				     mscheck msclear msclinfo msextract msgeninfo msinfo msinstinfo 
				     msmmthinfo msmthinfo mspkinfo msschinfo msrm msstdinfo 
				     mstranslate msxmthinfo}}}"


				 }

###########################################

if { $tcl_platform(os) == "SunOS" }  {
package ifneeded Woktools 2.0 "tclPkgSetup $dir/sun Woktools 2.0 {
                                        {libTKWOKLibswoktoolscmd.so load {
					    msgprint msgisset msgissetcmd msgissetlong msgset msgsetcmd 
					    msgsetlong msgunset msgunsetcmd msgunsetlong msgsetheader 
					    msgunsetheader msgissetheader msginfo}}}"

package ifneeded Wokutils 2.0 "tclPkgSetup $dir Wokutils 2.0 {
    {libwokutilscmd.so load { wokcmp} } }"

package ifneeded Wok 2.0 "package require Woktools; 
                             tclPkgSetup $dir/sun Wok 2.0 {
				 {libTKWOKLibswokcmd.so load {
				     Sinfo Wcreate Winfo Wrm Wdeclare fcreate finfo frm pinfo screate 
				     sinfo srm ucreate uinfo umpmake umake urm w_info wcreate 
				     wokcd wokclose wokinfo wokparam wokprofile wokenv wrm wmove 
				     stepinputaddstepinputinfo stepoutputadd stepoutputinfo stepaddexecdepitem }}}"

package ifneeded Ms 2.0 "package require Woktools; 
                             tclPkgSetup $dir/sun Ms 2.0 {
				 {libTKWOKLibsmscmd.so load {
				     mscheck msclear msclinfo msextract msgeninfo msinfo msinstinfo 
				     msmmthinfo msmthinfo mspkinfo msschinfo msrm msstdinfo 
				     mstranslate msxmthinfo}}}"


				 }

###########################################


if { $tcl_platform(os) == "WindowsNT" }  {
package ifneeded Woktools 2.0 "tclPkgSetup $dir/wnt Woktools 2.0 {
                                        {TKWOKLibswoktoolscmd.dll load {
					    msgprint msgisset msgissetcmd msgissetlong msgset msgsetcmd 
					    msgsetlong msgunset msgunsetcmd msgunsetlong msgsetheader 
					    msgunsetheader msgissetheader msginfo}}}"

package ifneeded Wokutils 2.0 "tclPkgSetup $dir/wnt Wokutils 2.0 {
    {wokutilscmd.dll load { wokcmp wokfind} } }"

package ifneeded Wok 2.0 "package require Woktools; 
                             tclPkgSetup $dir/wnt Wok 2.0 {
				 {TKWOKLibswokcmd.dll load {
				     Sinfo Wcreate Winfo Wrm Wdeclare fcreate finfo frm pinfo screate 
				     sinfo srm ucreate uinfo umpmake umake urm w_info wcreate wprocess
				     wokcd wokclose wokinfo wokparam wokprofile wokenv wrm wmove 
				     stepinputaddstepinputinfo stepoutputadd stepoutputinfo stepaddexecdepitem }}}"

package ifneeded Ms 2.0 "package require Woktools; 
                             tclPkgSetup $dir/wnt Ms 2.0 {
				 {TKWOKLibsmscmd.dll load {
				     mscheck msclear msclinfo msextract msgeninfo msinfo msinstinfo 
				     msmmthinfo msmthinfo mspkinfo msschinfo msrm msstdinfo 
				     mstranslate msxmthinfo}}}"

				 }
