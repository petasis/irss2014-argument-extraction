##########################################################################
# 
#	TransformAnnotatedData.tcl - Monday August 19 12:58:55 (EEST) 2013
#       This is a loosed coupled (Tcl) Component for use with 
#       Ellogon, version 1.9.3...
#
##########################################################################


# Location of this module (TransformAnnotatedData)
global creole_TransformAnnotatedData_home

## creole_TransformAnnotatedData
#  
proc creole_TransformAnnotatedData {doc args} {
  ## Remove duplicates and overlapping ones...
  set anns [tip_SelectAnnotations $doc argument+polarity]
  foreach ann $anns {
    set span [tip_GetValueValue [tip_GetAttribute $ann argument]]
    lassign $span start end
    incr seen($span)
    set overlapping [tip_AnnotationsContaining $anns $start $end]
    if {[llength $overlapping] > 1 || $seen($span) > 1} {
      set id [tip_GetId $ann]
      set anns [tip_RemoveAnnotation $anns $id]
    }
  }

  ## Make the annotations explicit on texts...
  tip_DeleteAnnotations $doc entity_manual
  tip_DeleteAnnotations $doc support_manual
  tip_DeleteAnnotations $doc claim_manual
  tip_DeleteAnnotations $doc argument_manual
  tip_DeleteAnnotations $doc segment
  tip_DeleteAnnotations $doc crf_segment
  set text [tip_GetRawData $doc]
  foreach ann $anns {
    set modelid [tip_GetAttribute $ann modelid]
    set attrs {}
    set spans {}
    foreach attr {argument       claim        entity1       entity2       entity3} \
            type {support_manual claim_manual entity_manual entity_manual entity_manual} {
      set $attr {}; set ${attr}_txt {}
      catch {
        set span  [tip_GetValueValue [tip_GetAttribute $ann $attr]]
        set new   [tip_CreateAnnotation $type [list $span] [list $modelid]]
        set $attr [tip_AddAnnotation $doc $new]
        tip_AddAnnotation $doc [tip_CreateAnnotation segment [list $span] \
          [list [tip_CreateAttribute type \
                     [tip_CreateAttributeValue GDM_STRING [string map {argument support} $attr]]] $modelid \
                [tip_CreateAttribute constituents \
                     [tip_CreateAttributeValue GDM_STRING_SET [set $attr]]]]]
        lassign $span start end; incr end -1
        set ${attr}_txt [string range $text $start $end]
        lappend spans $span
      }
      lappend attrs [tip_CreateAttribute $attr \
                         [tip_CreateAttributeValue GDM_STRING [set $attr]]] \
                    [tip_CreateAttribute ${attr}_txt \
                         [tip_CreateAttributeValue GDM_STRING [set ${attr}_txt]]]
    }
    tip_AddAnnotation $doc [tip_CreateAnnotation argument_manual $spans $attrs]
  }
  tip_PutAttribute $doc [tip_CreateAttribute TransformAnnotatedData \
                             [tip_CreateAttributeValue GDM_STRING {}]]
};# creole_TransformAnnotatedData


## Procedure: creole_TransformAnnotatedData_Initialize
proc creole_TransformAnnotatedData_Initialize {col doc args} {
};# creole_TransformAnnotatedData_Initialize

## Procedure: creole_TransformAnnotatedData_Finish
proc creole_TransformAnnotatedData_Finish {col doc args} {
};# creole_TransformAnnotatedData_Finish

#
# End of File TransformAnnotatedData.tcl
#
