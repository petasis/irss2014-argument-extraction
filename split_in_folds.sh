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

proc split_in_folds {file} {
  file mkdir ./data/folds
  set fd [open $file]
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
  set kf [ELEP::MachineLearning::Evaluation::KFold new \
              -n [llength $vectors] -n_folds 10 -shuffle 1]
  set fold 0
  set root [file rootname [file tail $file]]
  foreach {train test} [$kf train_test_indices $vectors] {
    set fd [open ./data/folds/$root.fold$fold.train.txt w]
    fconfigure $fd -encoding utf-8
    foreach v $train {
      puts $fd [join $v \n]\n
    }
    close $fd
    set fd [open ./data/folds/$root.fold$fold.test.txt w]
    fconfigure $fd -encoding utf-8
    foreach v $test {
      puts $fd [join $v \n]\n
    }
    close $fd
    incr fold
  }
  $kf destroy
  puts "[llength $vectors] vectors"
};# split_in_folds

foreach data [lsort -dictionary [glob -nocomplain ./data/crf/*.txt]] {
  puts $data
  split_in_folds $data
}


# vim: syntax=tcl
