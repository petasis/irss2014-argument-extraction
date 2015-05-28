#!/bin/bash
# The next line is executed by /bin/sh, but not tcl \
export ELLOGON=${ELLOGON_HOME:=/opt/Ellogon}
# The next line is executed by /bin/sh, but not tcl \
exec tclsh8.6 "$0" ${1+"$@"}

cd [file dirname [file normalize [info script]]]
puts "Current working directory: [pwd]"

# Extend Tcl's module path, to include Ellogon's modules
tcl::tm::path add $::env(ELLOGON)/ellogon2.0/tm

# Load Ellogon...
package require ellogon
# Load some packages we are going to use...
package require ELEP::Macros::ComponentRunner
package require ELEP::MachineLearning::Applications::NERCWord2Vec
# Load our Ellogon modules from the "modules" directory...
PUL_LoadPluginsInDir ./modules

# Prepare our data: Run module TransformAnnotatedData on collection
# ArgumentMin1...
if {1} {
  set collection [tip_OpenCollectionFixName ./data/ArgumentMin1]
  set runner     [ELEP::Macros::ComponentRunner new]
  $runner run $collection TransformAnnotatedData Gazetteer
  $runner destroy
  # Save the collection...
  tip_Sync  $collection
  tip_Close $collection
}

proc apply_trainer {trainer file} {
  $trainer reset 
  $trainer configure -save_instances_all_O 1
  set neg [file rootname $file].neg.txt
  $trainer init_training_file $file $neg
  set col [tip_OpenCollectionFixName ./data/ArgumentMin1]
  for {set doc [tip_FirstDocument $col]} {$doc ne ""} \
      {set doc [tip_NextDocument  $col]} {
    $trainer train_add_document $doc
    tip_Close $doc
  }
  tip_Close $col
  puts "  Generated [$trainer cget -instances] instances..."
  puts "  Generated [$trainer cget -instances_O] instances (negative)..."
  puts "  Instances saved in: $file"
  puts "  Negatives saved in: $neg"
  $trainer reset 
};# apply_trainer

# Generate the base-case: CRF with words & POS tags...
if {0} {
  puts "Generating base classifier training data..."
  set trainer [ELEP::MachineLearning::Applications::NERC::Serialise new \
    -ne_type segment -ne_constraints {ann::type in {claim support argument}} \
    -templates_U {w pos}    \
    -templates_B {}         \
    -context_before  0      \
    -context_after   0      \
  ]
  apply_trainer $trainer ./data/crf/words-pos-context-0.txt
  $trainer configure -context_before -2 -context_after 2
  apply_trainer $trainer ./data/crf/words-pos-context-2.txt
  $trainer configure -context_before -5 -context_after 5
  apply_trainer $trainer ./data/crf/words-pos-context-5.txt
  $trainer configure -context_before -2 -context_after 2 -skip_instances_all_O 0
  apply_trainer $trainer ./data/crf/neg-words-pos-context-2.txt
  ## Only support...
  $trainer configure -ne_constraints {ann::type in {support}} \
                     -context_before 0 -context_after 0 -skip_instances_all_O 1
  apply_trainer $trainer ./data/crf/only-support-words-pos-context-0.txt
  $trainer configure -context_before -2 -context_after 2
  apply_trainer $trainer ./data/crf/only-support-words-pos-context-2.txt
  $trainer configure -context_before -5 -context_after 5
  apply_trainer $trainer ./data/crf/only-support-words-pos-context-5.txt
  $trainer destroy
}

# Use word2vec...
if {0} {
  puts "Generating word2vec classifier training data..."
  set trainer [ELEP::MachineLearning::Applications::NERCWord2Vec::Serialise new\
    -ne_type segment -ne_constraints {ann::type in {claim support argument}} \
    -templates_U {w pos}    \
    -templates_B {}         \
    -context_before  0      \
    -context_after   0      \
  ]
  $trainer load_vectors ./representations/model.bin
  apply_trainer $trainer ./data/crf/words-pos-w2v-context-0.txt
  $trainer configure -context_before -2 -context_after 2
  apply_trainer $trainer ./data/crf/words-pos-w2v-context-2.txt
  $trainer configure -context_before -5 -context_after 5
  apply_trainer $trainer ./data/crf/words-pos-w2v-context-5.txt
  ## Only support...
  $trainer configure -ne_constraints {ann::type in {support}} \
                     -context_before 0 -context_after 0
  apply_trainer $trainer ./data/crf/only-support-words-pos-w2v-context-0.txt
  $trainer configure -context_before -2 -context_after 2
  apply_trainer $trainer ./data/crf/only-support-words-pos-w2v-context-2.txt
  $trainer configure -context_before -5 -context_after 5
  apply_trainer $trainer ./data/crf/only-support-words-pos-w2v-context-5.txt
  $trainer destroy
}

if {1} {
  puts "Generating word2vec classifier training data (+lookup)..."
  set trainer [ELEP::MachineLearning::Applications::NERCWord2Vec::Serialise new\
    -ne_type segment -ne_constraints {ann::type in {claim support argument}} \
    -templates_U {w pos chk}    \
    -templates_B {}         \
    -context_before  0      \
    -context_after   0      \
    -skip_instances_duplicate 1 \
    -generate_disjunctive_features 0 \
  ]
  $trainer load_vectors ./representations/model.bin
  apply_trainer $trainer ./data/crf/words-pos-lookup-w2v-context-0.txt
  # $trainer configure -context_before -2 -context_after 2
  # apply_trainer $trainer ./data/crf/words-pos-lookup-w2v-context-2.txt
  # $trainer configure -context_before -5 -context_after 5
  # apply_trainer $trainer ./data/crf/words-pos-lookup-w2v-context-5.txt
  ## Only support...
#  $trainer configure -ne_constraints {ann::type in {support}} \
#                     -context_before 0 -context_after 0
#  # apply_trainer $trainer ./data/crf/only-support-words-pos-lookup-w2v-context-0.txt
#  $trainer configure -context_before -2 -context_after 2
#  apply_trainer $trainer ./data/crf/only-support-words-pos-lookup-w2v-context-2.txt
#  $trainer configure -context_before -5 -context_after 5
#  apply_trainer $trainer ./data/crf/only-support-words-pos-lookup-w2v-context-5.txt
  $trainer destroy
}



# vim: syntax=tcl
