##########################################################################
# 
#	CRF_Tag.tcl - Thursday November 24 01:42:50 (EET) 2011
#       This is a loosed coupled (Tcl) Component for use with 
#       Ellogon, version 1.9.2...
#
##########################################################################


# Location of this module (CRF_Tag)
global creole_CRF_Tag_home
package require ELEP::MachineLearning::Applications::NERCWord2Vec

## creole_CRF_Tag
proc creole_CRF_Tag {doc args} {
  global creole_CRF_Tag
  lassign $args ne_type
  tip_DeleteAnnotations $doc $ne_type
  $creole_CRF_Tag(tagger) tag_document $doc
  tip_PutAttribute $doc [tip_CreateAttribute CRF_Tag \
                             [tip_CreateAttributeValue GDM_STRING {}]]
};# creole_CRF_Tag

proc creole_CRF_Tag_Initialize {col doc args} {
  lassign $args ne_type templates_U templates_B \
                token_features sentence_features \
                context_before context_after \
                generate_disjunctive_features

  global creole_CRF_Tag creole_CRF_Tag_home

  catch {$creole_CRF_Tag(tagger) destroy}
  set model   $creole_CRF_Tag_home/models/crf.model
  set vectors $creole_CRF_Tag_home/models/w2v.model
  ## Create a CRF tagger...
  set creole_CRF_Tag(tagger) \
     [ELEP::MachineLearning::Applications::NERCWord2Vec::Tag new -pos_name pos \
     -ne_type $ne_type -templates_U $templates_U -templates_B $templates_B \
     -token_attribute_names $token_features \
     -sentence_attribute_names $sentence_features \
     -context_before $context_before -context_after $context_after \
     -generate_disjunctive_features $generate_disjunctive_features]
  $creole_CRF_Tag(tagger) load_model   $model
  $creole_CRF_Tag(tagger) load_vectors $vectors
};# creole_CRF_Tag_Initialize

proc creole_CRF_Tag_Finish {col doc args} {
  global creole_CRF_Tag
  $creole_CRF_Tag(tagger) destroy
  unset -nocomplain creole_CRF_Tag
};# creole_CRF_Tag_Finish

#
# End of File CRF_Tag.tcl
#
