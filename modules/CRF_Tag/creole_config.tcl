# 
#        CRF_Tag/creole_config.tcl - configuration file
#
#        Thursday November 24 01:42:50 (EET) 2011
#        
#        $Id: template_config.tcl, Ellogon, version 1.9.2... 
#            (Georgios Petasis, 23/11/1998), petasis@iit.demokritos.gr   $


set creole_config(CRF_Tag) \
{  
    title {CRF Tag}
    pre_conditions {
        collection_attributes      {}
        document_attributes        {language_any}
        annotations                {}
    }
    post_conditions {
        collection_attributes      {}
        document_attributes        {CRF_Tag}
        annotations                {crf_segment} 
    }
    viewers {
      {} AnnotationExplorer {Explore Annotations...}
    }
    parameters {
      {NE Annotation Type} %ENTRY% crf_segment
      {Templates U} %ENTRY% {
           w pos chk
      }
      {Templates B} %ENTRY% {}
      {Additional token features} %ENTRY% {}
      {Additional sentence features} %ENTRY% {
      }
      {Context before} %NUMBER% -5
      {Context after} %NUMBER%   3
      {Generate disjunctive_features} %BOOLEAN% 0
    }
    coupling loose
    description {Author: George, Thu Nov 24 01:42:06 EET 2011}
    module_encoding utf-8
    type module
};# CRF_Tag

## Compatibility Mode: Use 0 for Ellogon mode, 1 for GATE compatibility
## mode...
set ::CDM::ComponentMode(creole_CRF_Tag) 0

#
# End of File
#
