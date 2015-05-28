##########################################################################
# 
#	Gazetteer.tcl - Saturday September 07 11:49:25 (EEST) 2013
#       This is a loosed coupled (Tcl) Component for use with 
#       Ellogon, version 1.9.3...
#
##########################################################################


# Location of this module (Gazetteer)
global creole_Gazetteer_home
package require ELEP::DocumentUtilities::HashTableGazetteer

## creole_Gazetteer
#  
proc creole_Gazetteer {doc args} {
  $::creole_Gazetteer(lookup) processDocument $doc
  tip_PutAttribute $doc [tip_CreateAttribute Gazetteer \
                             [tip_CreateAttributeValue GDM_STRING {}]]
};# creole_Gazetteer


## Procedure: creole_Gazetteer_Initialize
proc creole_Gazetteer_Initialize {col doc args} {
  global creole_Gazetteer_home \
         creole_Gazetteer
  if {[info exists creole_Gazetteer(lookup)]} {return}
  set lookup [ELEP::DocumentUtilities::HashTableGazetteer new]
  set creole_Gazetteer(lookup) $lookup

  ## Load categories...
  foreach file [lsort -dict [glob -nocomplain \
                $creole_Gazetteer_home/lists/*.txt]] {
    set category [file rootname [file tail $file]]
    set fd [open $file]
    fconfigure $fd -encoding utf-8
    while {[gets $fd line] > 0} {
      $lookup addStringToModel $line $category
    }
    close $fd
  }
};# creole_Gazetteer_Initialize

## Procedure: creole_Gazetteer_Finish
proc creole_Gazetteer_Finish {col doc args} {
};# creole_Gazetteer_Finish

#
# End of File Gazetteer.tcl
#
