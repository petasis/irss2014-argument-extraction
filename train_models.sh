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
package require ELEP::MachineLearning::Evaluation::CrossValidation

proc load_vectors {filename} {
  set fd [open $filename]
  fconfigure $fd -encoding utf-8
  set data [string trim [read $fd]]\n
  close $fd
  set vectors [list]
  set vector  [list]
  foreach line [split $data \n] {
    if {[string length $line]} {lappend vector $line} else {
      lappend vectors $vector
      set vector [list]
    }
  }
  return $vectors
};# load_vectors

proc run_train {model log train} {
  set fd [open $log.run.txt w]
  fconfigure $fd -encoding utf-8
  exec crfsuite learn --model $model --log-to-file --logbase=$log \
       --algorithm=lbfgs \
       -p feature.possible_states=1 \
       -p feature.possible_transitions=1 \
       $train >&@ $fd
  close $fd
};# run_train

proc run_eval {model neg tag train neg2} {
  # Evaluate on neg, and select the "problematic" ones...
  exec crfsuite tag -r --model $model $neg > $tag
  # Load negatives...
  set V [list]
  set vectors [load_vectors $neg]
  set fd [open $tag]
  fconfigure $fd -encoding utf-8
  foreach X $vectors {
    set labels [dict create]
    foreach x $X {
      set t [lindex [split $x \t] 0]
      gets $fd line
      lassign [split $line \t] lt lp
      if {$t ne $lt} {error "$t -> $line"}
      dict incr labels $lp
    }
    gets $fd line
    if {[llength [dict keys $labels]] > 1} {
      lappend V $X
    }
  }
  close $fd
  puts "          [llength $vectors] -> [llength $V]"
  unset vectors
  set fd [open $neg2 a]
  fconfigure $fd -encoding utf-8
  foreach X $V {
    puts $fd [join $X \n]
    puts $fd {}
  }
  close $fd
};# run_eval

proc run {file} {
  file mkdir ./data/models
  file mkdir ./data/logs
  file mkdir ./data/tag
  set root [file rootname [file tail $file]]
  for {set fold 0} {$fold < 10} {incr fold} {
    set train [file normalize ./data/folds/$root.fold$fold.train.txt]
    set test  [file normalize ./data/folds/$root.fold$fold.test.txt]
    set neg   [file normalize ./data/folds/$root.neg.fold$fold.train.txt]
    set neg2  [file normalize ./data/folds/$root.neg2.fold$fold.train.txt]
    set model [file normalize ./data/models/$root.fold$fold.model]
    set log   [file normalize ./data/logs/$root.fold$fold.log]
    set tag   [file normalize ./data/tag/$root.fold$fold.txt]
    puts "  Fold $fold: $root.fold$fold.train.txt"
    puts "          [file tail $neg]"
    file copy -force $train $neg2
    if {1} {
      run_train $model $log $train
    }
    if {0} {
      run_eval $model $neg $tag $train $neg2
      run_train $model $log $neg2
    }
  }
};# run

foreach data [lsort -dictionary [glob -nocomplain ./data/crf/*.txt]] {
  if {[string match *.neg.txt $data]} {continue}
  puts $data
  run $data
}

# vim: syntax=tcl
