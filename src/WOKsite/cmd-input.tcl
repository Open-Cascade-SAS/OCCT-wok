 namespace eval CmdInput {

        # We want to allow shell commands to execute automatically
        # as in normal interactive use.  The "unknown" proc checks
        # that "info script" returns "", before it enables that
        # behaviour, so we subclass "info".  In Tcl 8.4 we could simply
        # call 'info script ""' I believe, but 8.3 and earlier don't do
        # that.
        variable this_script [info script]
        proc info {args} {
                set result [uplevel [concat __org_info $args]]
                set cmd [lindex $args 0]

                variable this_script
                if {"script" == $cmd && "$result" == $this_script} {
                        return ""
                } else {
                        return $result
                }
        }
        rename ::info ::__org_info ;# using a namespace proc here cores
        proc ::info {args} "uplevel \[concat [namespace which info] \$args\]"

        proc loop {} {
                # preparations
                fconfigure stdin  -buffering line
                fconfigure stdout -buffering line
                fconfigure stderr -buffering line
                set ::tcl_interactive 1

                if {[file exists ~/tclshrc_WOK8.0]} {
                        namespace eval :: {uplevel \#0 source ~/tclshrc_WOK8.3}
                }

                # input loop
                while {1} {
                        catch {uplevel \#0 $::tcl_prompt1}
                        flush stdout
                        set cmd {}
                        while {1} {
                                append cmd [gets stdin] "\n"
                                if {[info complete $cmd]} {
                                        break
                                }
                                catch {uplevel \#0 $::tcl_prompt2}
                                flush stdout
                        }
                        history add $cmd
                        catch {uplevel \#0 $cmd} result
                        puts $result
                }
                return ""
        }
 }

 catch {CmdInput::loop} result
 puts $result
 exit 0
