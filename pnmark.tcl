#
#
#
#


############################################################
# usage - Display how to use this tool
#
proc usage {prgName} {
    puts "********************************************************"
    puts "* Usage: wish $prgName <file.ma> <file.log> \[file.pn\]"
    puts "*"
    puts "* Where file.ma is the Petri Net model definition file"
    puts "* Where file.log is the log file resulting from the"
    puts "* simulation of the Petri Net."
    puts "* And where file.pn is the file where this tool saves"
    puts "* the Petri Net marking information.  If the .pn file is"
    puts "* not specified the tool sends the output to stdout"
    puts "********************************************************"
}


############################################################
#
# Main body of the tool
#

#
# Check the arguments
#
if {$argc != 2 && $argc != 3} {
    puts "\n*** $argv0 invoked with an invalid number of arguments ***\n"
    usage $argv0
    exit -1
} else {
    set file1 [lindex $argv 0]
    set file2 [lindex $argv 1]
    if {$argc == 3} {set file3 [lindex $argv 2]}
}

#
# Determine which file is the .ma, the .log and the .pn
#
    if {[string match *.ma $file1] == 1} {
	set maFile $file1
    } elseif {[string match *.log $file1] == 1} {
	set logFile $file1
    } elseif {[string match *.pn $file1] == 1} {
	set pnFile $file1
    } else {
	puts "\n*** File $file1 is not a .ma, .log or .pn file ***\n"
	usage $argv0
	exit -1
    }

    if {[string match *.ma $file2] == 1} {
	if {[info exists maFile]} {
	    puts "\n*** $file1 and $file2 cannot both be .ma files ***\n"
	    usage $argv0
	    exit -1
	} else {
	    set maFile $file2
	}
    } elseif {[string match *.log $file2] == 1} {
	if {[info exists logFile]} {
	    puts "\n*** $file1 and $file2 cannot both be .log files ***\n"
	    usage $argv0
	    exit -1
	} else {
	    set logFile $file2
	}
    } elseif {[string match *.pn $file2] == 1} {
	if {[info exists pnFile]} {
	    puts "\n*** $file1 and $file2 cannot both be .pn files ***\n"
	    usage $argv0
	    exit -1
	} else {
	    set pnFile $file2
	}
    } else {
	puts "\n*** File $file2 is not a .ma, .log or .pn file ***\n"
	usage $argv0
	exit -1
    }

    if {[info exists file3]} {
    if {[string match *.ma $file3] == 1} {
	if {[info exists maFile]} {
	    puts "\n*** $file3 and $maFile cannot both be .ma files ***\n"
	    usage $argv0
	    exit -1
	} else {
	    set maFile $file3
	}
    } elseif {[string match *.log $file3] == 1} {
	if {[info exists logFile]} {
	    puts "\n*** $file3 and $logFile cannot both be .log files ***\n"
	    usage $argv0
	    exit -1
	} else {
	    set logFile $file3
	}
    } elseif {[string match *.pn $file3] == 1} {
	if {[info exists pnFile]} {
	    puts "\n*** $file3 and $pnFile cannot both be .pn files ***\n"
	    usage $argv0
	    exit -1
	} else {
	    set pnFile $file3
	}
    } else {
	puts "\n*** File $file3 is not a .ma, .log or .pn file ***\n"
	usage $argv0
	exit -1
    }
    }

#
# Make sure we have at least one .ma and one .log file.
#
    if {![info exists maFile] || ![info exists logFile]} {
	puts "\n*** Must have one .ma and one .log file ***\n"
	usage $argv0
	exit -1
    }

#
# Open/create the files
#
if [catch {open $maFile r} maFileId] {
    puts "\n*** Error - Cannot open $maFile ***\n"
    exit -1
}

if [catch {open $logFile r} logFileId] {
    puts "\n*** Error - Cannot open $logFile ***\n"
    close $maFileId
    exit -1
}

if [info exists pnFile] {
    if [catch {open $pnFile w} pnFileId] {
    	puts "\n*** Error - Cannot open/create $pnFile ***\n"
    	close $maFileId
    	close $logFileId
    	exit -1
    }
} else {
    set pnFileId stdout
}

#
# We are done validating the file names provided as inputs
# lets do some meaningful work.
#

#
# Only print this message if we're sending the results
# to a .pn file
#
if {[info exists pnFile]} {
    puts -nonewline "\nGenerating marking for Petri Net model ... "
}

#
# set some variables
#
set pnPlace pnPlace
set pnTrans pnTrans
set firedTime 0

#
# Parse the .ma file
#
while {[gets $maFileId line] >= 0} {

    # Process the line.  Don't process lines which are comments
    if {[string match #* $line] != 1} {

	set lst [split $line :]
	set field [lindex $lst 0]

	# Don't process lines which are not defining components
	if {[string compare [string trim $field] components] == 0} {
	    
	    set compList [split [lindex $lst 1]]

	    # Check for components which are Petri Net places
	    # or transitions
	    foreach comp $compList {
		set compName [lindex [split $comp @] 0]
		set compType [lindex [split $comp @] 1]

		if {[string compare [string trim $compType] $pnPlace] == 0} {
		    lappend placeList [string tolower [string trim $compName]]
		} elseif {[string compare [string trim $compType] $pnTrans] \
			   == 0} {
		    lappend transList [string tolower [string trim $compName]]
		}


	    } ;# End of foreach
	}
    }
} ;# End of while loop

#
# Parsing of .ma file complete. Print the information we found
#
puts -nonewline $pnFileId "\nPetri Net places: "

foreach comp $placeList {
    lappend placeListValue 0
    puts -nonewline $pnFileId "$comp "
    }

puts -nonewline $pnFileId "\nPetri Net transitions: "

foreach comp $transList {
    puts -nonewline $pnFileId "$comp "
    }
puts $pnFileId "\n"

while {[gets $logFileId line] >= 0} {

    # Process the line. It is broken in sections using the
    # "/" character as a delimiter
    set lst [split $line /]
    set msgType [string trim [lindex $lst 0]]

    # Only output messages are of interest
    if {[string compare $msgType "Mensaje Y"] != 0} {
	continue
	}

    # Get the time, component name, port name and value of the
    # output message.
    set time [string trim [lindex $lst 1]]
    set compName [string trimright [string trimright [string trim \
		 [lindex $lst 2]] ?)0123456789?] ?(?]
    set portName [string trim [lindex $lst 3]]
    set value [lindex [split [string trim [lindex $lst 4]]] 0]

    # Check to see if a transition fired or if a place advertized
    # its new contents

    if {[string compare $portName fired] == 0} {

	# A transition fired.  It may send more than one message
	# out of the <fired> port.  Therefore make sure we only
	# detect the first <fired> message.  We use the timing information
	# to do that.
   	if {[string compare $time $firedTime] != 0} {

	# This fired message has a different time than the last
	# one we processed therefore it is not a duplicate

	set firedTime $time
	set index [lsearch $transList $compName]
	set lstLen [llength $placeListValue]

	if {$index != -1} {
	    set firedTrans [lindex $transList $index]
	    set index 0

	    puts -nonewline $pnFileId "("
	    foreach value $placeListValue {
		incr index
		puts -nonewline $pnFileId "$value"
		if {$index != $lstLen} {
		    puts -nonewline $pnFileId ","
		} else {puts -nonewline $pnFileId ")"}
	    }
	    puts $pnFileId "\n\t|\n\t|\n\t$firedTrans\n\t|\n\tV"

	    }
	}
    } elseif {[string compare $portName out] == 0} {

	set index [lsearch $placeList $compName]

	if {$index != -1} {

	    # A place sent a message to advertise its contents.  The value
	    # of the message contains the model ID of the place and the number
	    # of tokens in the place.  We only care about the latter value
	    # so we have to remove the ID as well as any decimals.  For example
	    # if the value is "5003.000" (meaning ID 5 has 3 tokens) we want 
	    # to change that to "3"

	    set value [string trimright [string trimright $value ?0?] ?.?]
	    set value [expr $value % 1000]
	    set placeListValue [lreplace $placeListValue $index $index $value]
	    }
    }

} ;# End of while loop

#
# Display the value of the places for the last time
#
set index 0
set lstLen [llength $placeListValue]
puts -nonewline $pnFileId "("

foreach value $placeListValue {
    incr index
    puts -nonewline $pnFileId "$value"
    if {$index != $lstLen} {
	puts -nonewline $pnFileId ","
    } else {puts $pnFileId ")"}
}

#
# Clean up.  Close all files 
#
close $maFileId
close $logFileId
if [info exists pnFile] {close $pnFileId}

#
# Only indicate we are done if the output was 
# sent to a .pn file
#
if {[info exists pnFile]} {puts "DONE"}

exit 0


