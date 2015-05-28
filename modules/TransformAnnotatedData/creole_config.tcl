# 
#        TransformAnnotatedData/creole_config.tcl - configuration file
#
#        Monday August 19 12:58:55 (EEST) 2013
#        
#        $Id: template_config.tcl, Ellogon, version 1.9.3... 
#            (Georgios Petasis, 23/11/1998), petasis@iit.demokritos.gr   $


set creole_config(TransformAnnotatedData) \
{  
    title {Transform Annotated Data}
    pre_conditions {
        collection_attributes      {}
        document_attributes        {language_ArgumentMining}
        annotations                {}
    }
    post_conditions {
        collection_attributes      {}
        document_attributes        {TransformAnnotatedData}
        annotations                {} 
    }
    viewers {
      {} AnnotationExplorer {Explore Annotations...}
    }
    parameters {
      
    }
    coupling loose
    description {Author: George, Mon Aug 19 12:57:54 EEST 2013}
    module_encoding utf-8
    type module
};# TransformAnnotatedData

## Compatibility Mode: Use 0 for Ellogon mode, 1 for GATE compatibility
## mode...
set ::CDM::ComponentMode(creole_TransformAnnotatedData) 0

#
# End of File
#
