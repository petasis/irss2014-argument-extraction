# 
#        Gazetteer/creole_config.tcl - configuration file
#
#        Saturday September 07 11:49:25 (EEST) 2013
#        
#        $Id: template_config.tcl, Ellogon, version 1.9.3... 
#            (Georgios Petasis, 23/11/1998), petasis@iit.demokritos.gr   $


set creole_config(Gazetteer) \
{  
    title {NOMAD Gazetteer}
    pre_conditions {
        collection_attributes      {}
        document_attributes        {language_NOMAD}
        annotations                {}
    }
    post_conditions {
        collection_attributes      {}
        document_attributes        {Gazetteer }
        annotations                {lookup} 
    }
    viewers {
      {} AnnotationExplorer {Explore Annotations...}
    }
    parameters {
    }
    coupling loose
    description {Author: George, Sat Sep 07 11:48:19 EEST 2013}
    module_encoding utf-8
    type module
};# Gazetteer

## Compatibility Mode: Use 0 for Ellogon mode, 1 for GATE compatibility
## mode...
set ::CDM::ComponentMode(creole_Gazetteer) 0

#
# End of File
#
