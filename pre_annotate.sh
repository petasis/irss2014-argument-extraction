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
if {0} {
  set collection [tip_OpenCollectionFixName ./data/ArgumentMin1]
  set runner     [ELEP::Macros::ComponentRunner new]
  $runner run $collection TransformAnnotatedData Gazetteer
  $runner destroy
  # Save the collection...
  tip_Sync  $collection
  tip_Close $collection
}

proc apply_trainer {trainer file} {
  $trainer init_training_file $file
  set col [tip_OpenCollectionFixName ./data/ArgumentMin1]
  for {set doc [tip_FirstDocument $col]} {$doc ne ""} \
      {set doc [tip_NextDocument  $col]} {
    $trainer train_add_document $doc
    tip_Close $doc
  }
  tip_Close $col
  puts "  Generated [$trainer cget -instances] instances..."
  puts "  Instances saved in: $file"
  $trainer reset 
};# apply_trainer

proc train {file} {
  file mkdir ./data/models
  file mkdir ./data/logs
  set root  [file rootname [file tail $file]]
  set train $file
  set model [file normalize ./data/models/$root.model]
  set log   [file normalize ./data/logs/$root.log]
  set fd [open $log.train.txt w]
  fconfigure $fd -encoding utf-8
  puts "Training on: $root..."
  exec crfsuite learn --model $model --log-to-file --logbase=$log \
       --algorithm=lbfgs \
       -p feature.possible_states=1 \
       -p feature.possible_transitions=1 \
       $train >&@ $fd
  close $fd
  return $model
};# train

# Use word2vec...
if {0} {
  puts "Generating word2vec classifier training data (+lookup)..."
  set trainer [ELEP::MachineLearning::Applications::NERCWord2Vec::Serialise new\
    -ne_type segment -ne_constraints {ann::type in {claim support argument}} \
    -templates_U {w pos chk}         \
    -templates_B {}                  \
    -context_before  -5              \
    -context_after    3              \
    -skip_instances_duplicate 0      \
    -generate_disjunctive_features 0 \
  ]
  $trainer load_vectors ./representations/model.bin
  apply_trainer $trainer\
   ./data/crf/pre-annotate-words-pos-lookup-w2v-context-5-3.txt
  ## Only support...
  $trainer configure -ne_constraints {ann::type in {support}}
  apply_trainer $trainer\
   ./data/crf/pre-annotate-support-words-pos-lookup-w2v-context-5-3.txt
  $trainer configure -ne_constraints {ann::type in {claim}}
  apply_trainer $trainer\
   ./data/crf/pre-annotate-claim-words-pos-lookup-w2v-context-5-3.txt
  $trainer destroy
}

if {0} {
  set model [train ./data/crf/pre-annotate-words-pos-lookup-w2v-context-5-3.txt]
  file copy -force $model $::creole_CRF_Tag_home/models/crf.model
  file copy -force ./representations/model.bin \
                          $::creole_CRF_Tag_home/models/w2v.model
}

if {0} {
  set collection [tip_OpenCollectionFixName ./data/ArgumentMin1]
  set runner     [ELEP::Macros::ComponentRunner new]
  $runner run $collection CRF_Tag
  $runner destroy
  # Save the collection...
  tip_Sync  $collection
  tip_Close $collection
}

# vim: syntax=tcl
