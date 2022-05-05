# hpx2ma.tcl - .hpx to .ma conversion utility
#
# This TCL script converts a .hpx file to a .ma file.  A
# .hpx file is a text based file which describes a 
# Petri Net created using the HPSIM Petri Net creation
# and simulation tool.  A .ma file is a text base model 
# definition file used as input by the CD++ tool.
#
# The main goal of this conversion script is to allow
# the modeler to create PNs using the nice GUI of HPSIM
# and then use CD++ to simulate the PN.
#
# An attempt was made to document the code as much as
# practically possible so that a separate document 
# to describe the tool was not necessary.
#
# WARNING: This tool was tested using .hpx files 
# version 0.9 which can be created using HPSIM 1.1.
# It is unknown if it will work properly with other
# versions.
#
# AUTHOR: Christian Jacques
#
# EMAIL: chris.jacques@videotron.ca
#
# DATE: 26 July 2002
############################################################


############################################################
# usage - Display how to use this tool
#
proc usage {prgName} {
    puts "********************************************************"
    puts "* Usage: wish $prgName <file.hpx> <file.ma>"
    puts "*"
    puts "* Where file.hpx is a Petri Net model definition file"
    puts "* created with the HPSIM tool.  file.ma is a model"
    puts "* definition file used as input to the CD++ tool"
    puts "* The order in which the files are specified is not"
    puts "* important.  The tool uses the file extensions to"
    puts "* determine the input (.hpx) and output (.ma) files."
    puts "********************************************************"
}

#### END OF usage

############################################################
# objAttrListProcess - Process the attributes list of an
#		       object
#
# This procedure is called from the main procedure to
# process the attributes of an object.  These attributes
# are stored in the objAttrList list which is maintained
# by the main procedure.  The list is arranged as so:
#
# {attribute1 attribute1_value attribute2 attribute2_value}
#
# hence the value of an attribute always follows the attribute
# itself.
#
# This procedure determines the class of the object and based 
# on that it stores relevant information about the object in 
# arrays using the object's ID as an index.  This is possible 
# because all objects have a unique ID.  The arrays are later
# used by the main procedure to create the .ma file.
#
# The following arrays exist:
#
# objType(ID)
#   Stores the type of object identified by ID.  The possible 
#   values are "pnPlace", "pnTrans" and "arc".
#
# tokens(ID)
#   Stores the number of tokens in the place identified by ID.
#	
# arcType(ID)
#   Stores the type of the arc identified by ID.  The value can
#   be 0 (single or multiple arc) or 1 (inhibitor arc).
#	
# arcWeight(ID)
#   Stores the weight of the arc identified by ID.  The weight
#   describes the number of tokens the arc takes from a place/
#   deposits in a place when a transition fires.  Single and
#   inhibitor arcs have a weight of 1.  Multiple arcs have a 
#   weight > 1.  Note that because the Petri Net library used
#   by the CD++ tool can't handle weight > 4, this procedure
#   will throw an error if the .hpx contains such arcs.
#	
# arcSrc(ID)
#   Stores the source of the arc identified by ID.  The source
#   is always the ID of either a transition or a place.
#
# arcTgt(ID)
#   Stores the destination of the arc identified by ID.  The 
#   destinationsource is always the ID of either a transition or 
#   a place.
#
# objName(ID)
#   Stores the name of the object identified by ID.  The value
#   is always the name of the transition or place given by
#   the user when the PN was created using HPSIM
#
# In addition to creating arrays, this procedure creates three
# lists of IDs used by the main procedure to create the .ma
# file:
#
# placeIdList
#   List of place IDs in the PN
#
# transIdList
#   List of transition IDs in the PN
#
# arcIdList
#   List of arc IDs in the PN
#
# A note about labels.  The .hpx file considers labels as
# distinct objects.  However, for the purpose of creating
# a .ma file, the only information we need from labels is
# the owner of a label and the value (TEXT) of the label.
# This is so we can assign names to places and transitions
#
# Finally, note that the caller is responsible for clearing the
# objAttrList.  Failure to do so would cause duplicate
# information to be stored in the arrays.
#
proc objAttrListProcess { } {
    global objAttrList objType objName tokens arcType arcWeight \
    	   arcSrc arcTgt arcIdList transIdList placeIdList

    set ix [lsearch -exact $objAttrList RUNTIME_CLASS]
    incr ix

    set objClass [lindex $objAttrList $ix]

    # Process the list based on the class of object
    switch -exact -- $objClass {

	CHPosition {
	   
	    # Get the position ID.  It will be used as an index
	    # to store the info into an array
	    set ix [lsearch -exact $objAttrList POSITION_ID]
	    set id [lindex $objAttrList [incr ix]]

	    # Store type of object in the objType array
	    set objType($id) pnPlace	     

	    # Get the number of tokens the place initially has
	    # and store it into the token array
	    set ix [lsearch -exact $objAttrList TOKENS_START]
	    set tokens($id) [lindex $objAttrList [incr ix]]

	    lappend placeIdList $id

	}

	CHTransition {

	    # Get the transition ID.  It will be used as an index
	    # to store the info into an array
	    set ix [lsearch -exact $objAttrList TRANSITION_ID]
	    set id [lindex $objAttrList [incr ix]]

	    # Store type of object in the objType array
	    set objType($id) pnTrans	     

	    lappend transIdList $id

	}

	CHConnector {

	    # Get the connector ID.  It will be used as an index
	    # to store the info into the various arrays
	    set ix [lsearch -exact $objAttrList ARC_ID]
	    set id [lindex $objAttrList [incr ix]]

	    # Store type of object in the objType array
	    set objType($id) arc	     

	    # Get the arc type and store it into the arcType array
	    set ix [lsearch -exact $objAttrList ARC_TYP]
	    set arcType($id) [lindex $objAttrList [incr ix]]

	    # Get the arc weight and store it into the arcWeight array
	    set ix [lsearch -exact $objAttrList ARC_WEIGHT]
	    set arcWeight($id) [lindex $objAttrList [incr ix]]

	    if {$arcWeight($id) > 4} {
	    	puts "\n$argv0: ERROR - Cannot translate arcs with a weight > 4"
	    	return -code error INVALID_NET_DEFINITION 
    	    }

	    # Get the source ID and store it into the arcSrc array
	    set ix [lsearch -exact $objAttrList SOURCE_ID]
	    set arcSrc($id) [lindex $objAttrList [incr ix]]

	    # Get the target ID and store it into the arcTgt array
	    set ix [lsearch -exact $objAttrList TARGET_ID]
	    set arcTgt($id) [lindex $objAttrList [incr ix]]

	    lappend arcIdList $id

	}

	CHLabel {

	    # Get the id of the label owner and make sure it is
	    # either a place or a transition.  We don't care
	    # about labels belonging to other type of objects.
	    # We also don't care unless the SUB_IDENT attribute
	    # is 0.
	    set ix [lsearch -exact $objAttrList OWNER_IDENT]
	    set id [lindex $objAttrList [incr ix]]

	    if { [string compare pnPlace $objType($id)] == 0 || \
		 [string compare pnTrans $objType($id)] == 0 } {

	        set ix [lsearch -exact $objAttrList SUB_IDENT]
	        set subId [lindex $objAttrList [incr ix]]

		if {$subId == 0} { 

	            set ix [lsearch -exact $objAttrList TEXT]
	            set objName($id) [lindex $objAttrList [incr ix]]
		    
		}

	    }

	} 
		
	default {

	    puts "\n$argv0: ERROR - unrecognized object $objClass"
	    return -code error UNRECOGNIZED_OBJECT
	}
	} 
}

#### END OF objAttrListProcess

############################################################
# main - Main body of the tool
#
# This is the main procedure of the hpx2ma.tcl tool.  Its
# purpose is to convert a .hpx file to a .ma file.  It does
# so by parsing the .hpx and creating a .ma suitable for the
# CD++ tool to use as a model definition file.  The format of
# the .hpx is as follows:
#
# -----
# [DOCUMENT]
# ...
# [OBJECT 1]
# attribute1=attribute1_value
# attribute2=attribute2_value
# ...
# [OBJECT 2]
# ...
# -----
#
# The steps involved in the conversion are:
#
# 1. Validating the arguments used to invoke this tool
# 2. Opening the .hpx and .ma file
# 3. Parsing the .hpx file
# 4. Generating the .ma file
# 5. Closing the .hpx and .ma file.
#
# Steps 3 and 4 warrant additional descriptions.
#
# Parsing the .hpx file
#   The .hpx file is parsed line by line such that the attributes
#   of a single object are gathered into the objAttrList.  All 
#   attributes are put in the list even though most of them are not
#   used.  This is because a .hpx file contains much more information
#   (e.g. graphical info) than needed to create a .ma file.  When
#   the main procedure detects that all attibutes for a single object
#   have been gathered in the list, it call the objAttrListProcess
#   procedure to process the list.  This results in the creation of
#   arrays and lists describing the places, transitions and arcs
#   that make up the PN.  The objAttrListProcess procedure is described
#   in details earlier in this file.
#
# Generating the .ma file
#   The .ma file is generated by processing the arrays and lists that
#   were created during the parsing process.  The aim being to create
#   a file like so:
#
# ------
# [top]
# components : place1@pnPlace place2@pnPlace
# components : trans1@pnTran
# 
# Link : out@place1	in1@trans1
# Link : fired@trans1	in@place1
# Link : out2d@trans1	in@place2
#
# [place1]
# tokens : 5
# 
# [trans1]
# inputplaces : 1
# -----
#

#
# STEP 1 - Check the validity of the arguments
#
if {$argc != 2} {
    puts "\n$argv0: ERROR - $argv0 invoked with an invalid number of arguments ***\n"
    usage $argv0
    exit -1
} else {
    set file1 [lindex $argv 0]
    set file2 [lindex $argv 1]
}

# Determine which file is the .hpx and the .ma
    if {[string match *.hpx $file1] == 1} {
	set hpxFile $file1
    } elseif {[string match *.ma $file1] == 1} {
	set maFile $file1
    } else {
	puts "\n$argv0: ERROR - $file1 is not a .hpx or a .ma file ***\n"
	usage $argv0
	exit -1
    }

    if {[string match *.ma $file2] == 1} {
	if {[info exists maFile]} {
	    puts "\n$argv0: ERROR - $file1 and $file2 cannot both be .ma files ***\n"
	    usage $argv0
	    exit -1
	} else {
	    set maFile $file2
	}
    } elseif {[string match *.hpx $file2] == 1} {
	if {[info exists hpxFile]} {
	    puts "\n$argv0: ERROR - $file1 and $file2 cannot both be .hpx files ***\n"
	    usage $argv0
	    exit -1
	} else {
	    set hpxFile $file2
        }
    } else {
	puts "\n$argv0: ERROR - $file2 is not a .ma or a .hpx file ***\n"
	usage $argv0
	exit -1
    }

#
# STEP 2 - Open/create the files
#
if {[catch {open $hpxFile r} hpxFileId]} {
    puts "\n$argv0: ERROR - Cannot open $hpxFile ***\n"
    exit -1
}

if {[file exists $maFile] == 1} {
    puts -nonewline "\n$argv0: WARNING - $maFile exists.  Contents will "
    puts            "be destroyed."
}

if {[catch {open $maFile w} maFileId]} {
    puts "\n$argv0: ERROR - Cannot open/create $maFile ***\n"
    close $hpxFileId
    exit -1
}

#
# STEP 3 - Parse the .hpx file
#
puts -nonewline "\n$argv0: Parsing $hpxFile ... "

# Set some variables
set objPattern {\[OBJECT *\]}
set objFound FALSE

while {[gets $hpxFileId line] >= 0} {

    # Process the line.  We take one of four decisions:
    # 1. Disregard (almost) the line until we find the very
    #    frist object definition in the file.
    # 2. Set objFound to TRUE to indicate we found the very
    #    first object definition in the file
    # 3. Split the line into two elements using the '=' character
    #    for splitting then add the elements to the objAttrList.
    # 4. Determine that we've processed the last attribute belonging
    #    to an object and call the objAttrListProcess to process the
    #    objAttrList.  Then delete the list.

    if {[string compare FALSE $objFound] == 0 && \
   	[string match $objPattern $line] != 1} { 

	# Processing the first few lines of the file.
	# Let's make sure the version number is OK.
	if {[string compare VERSION [lindex [split $line =] 0]] == 0}  {
	
	    if {[string compare 0.9 [lindex [split $line =] 1]] != 0} {

		puts "\n$argv0: WARNING - $hpxFile is not version 0.9"
		puts "\n$argv0: WARNING - Conversion to .ma may fail or be erroneous"
	    }
	}

    } elseif {[string compare FALSE $objFound] == 0} {

	# Flag the fact we found the very first line containing the 
	# $objPattern pattern.  Then continue with the next line.
	set objFound TRUE

    } elseif {[string match $objPattern $line] != 1} {

	# Store all attributes of the object into a list
	lappend objAttrList [lindex [split $line =] 0]
	lappend objAttrList [lindex [split $line =] 1]

    } else {

	# We just found the start of the next object definition
	# Need to process the attributes list of the object
	# before proceeding to the next one.
	objAttrListProcess

	# Delete the objAttrList so a new one is started for the 
	# next object
	unset objAttrList
    }
} 

# End of while loop


# Indicate parsing of .hpx file is completed
puts "DONE"

#
# STEP 4 - Generate the .ma file
#
puts -nonewline "$argv0: Generating $maFile ... "

# "[top]" is always the very first line in the .ma
puts $maFileId "\[top\]"

# Create the components list so it looks like:
# ---
# components : P1@pnPlace P2@pnPlace 
# components : T1@pnTrans T2@pnTrans
# ---

# List the places first.
puts -nonewline $maFileId "components : "

foreach id $placeIdList {
    	puts -nonewline $maFileId "$objName($id)@$objType($id) "
    }

# List the transitions
puts -nonewline $maFileId "\ncomponents : "

foreach id $transIdList {
    	puts -nonewline $maFileId "$objName($id)@$objType($id) "
    }

puts $maFileId "\n"

# Create the links so it looks like:
# ---
# Link : out@P1		in1@T1
# Link : fired@T1	in@P1
# Link : out4@T2	in@P2
# ---
foreach id $arcIdList {
    
    set src $arcSrc($id)
    set tgt $arcTgt($id)
    set inPortName in
    set outPortName out

    if {[string compare pnTrans $objType($tgt)] == 0 && \
    	$arcType($id) == 0} {

	# The target of the arc is a transition and it may or may
	# not be a multiple arc.
	append inPortName $arcWeight($id)	
	puts $maFileId "Link : out@$objName($src)\t\t$inPortName@$objName($tgt)"
	puts $maFileId "Link : fired@$objName($tgt)\t\tin@$objName($src)"
    } elseif {$arcType($id) == 1} {

    	# The arc is an inhibitor (target is always a transition) 
	puts $maFileId "Link : out@$objName($src)\t\tin0@$objName($tgt)"

    } else {

	# The target of the arc is a place
	append outPortName $arcWeight($id)	
	puts $maFileId "Link : $outPortName@$objName($src)\t\tin@$objName($tgt)"
    }
}

# Indicate places that have non zero initial tokens
# Should look like this:
# ---
# [P1]
# tokens : 5
# ---

foreach id $placeIdList {
    
    if {$tokens($id) != 0} {

    	puts $maFileId "\n\[$objName($id)\]"
    	puts $maFileId "tokens : $tokens($id)"
    }
}

# Indicate the number of input places each transition has.
# This info is required in the .ma only if a transition
# has more than than 10 input places so the Petri Net
# library used in the CD++ tool knows to allocate more
# memory than the default value
#
# Should look like this:
# ---
# [T2]
# inputplaces : 11
# ---

# First we calculate the number of input places
foreach id $arcIdList {
    
    set tgtId $arcTgt($id)

    if {[string compare pnTrans $objType($tgtId)] == 0} {

	# Increment the number of input places for the transition
	if {[info exists inputPlaces($tgtId)]} {
	    incr inputPlaces($tgtId)
	} else {
	    set inputPlaces($tgtId) 1	
	}
    }
}

# Store the info in the .ma
foreach id $transIdList {

    if {[info exists inputPlaces($id)] &&
        $inputPlaces($id) > 10} {

    	puts $maFileId "\n\[$objName($id)\]"
    	puts $maFileId "inputplaces : $inputPlaces($id)"
    }
}


#
# STEP 5 - Close the .hpx and .ma files
#
close $hpxFileId
close $maFileId

# Indicate we are done generating the .ma file
puts "DONE"

exit 0


