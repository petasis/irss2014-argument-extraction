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
package require math

proc run {file} {
  file mkdir ./data/tag
  file mkdir ./data/fold_eval
  set root [file rootname [file tail $file]]
  set results   [dict create]
  set per_class [dict create]
  for {set fold 0} {$fold < 10} {incr fold} {
    set train [file normalize ./data/folds/$root.fold$fold.train.txt]
    set test  [file normalize ./data/folds/$root.fold$fold.test.txt]
    set model [file normalize ./data/models/$root.fold$fold.model]
    set log   [file normalize ./data/logs/$root.fold$fold.log]
    set tag   [file normalize ./data/tag/$root.fold$fold.txt]
    set ev    [file normalize ./data/fold_eval/$root.fold$fold.txt]
    set evl   [file normalize ./data/fold_eval/$root.fold$fold.tex]
    # puts "  Fold $fold: $root.fold$fold.train.txt"
    exec crfsuite tag -r --model $model $test > $tag
    set fd [open $tag]
    fconfigure $fd -encoding utf-8
    set data [string map {\t ,} [string trim [read $fd]]]
    close $fd
    set fd [open $tag w]
    fconfigure $fd -encoding utf-8
    foreach line [split $data \n] {
      if {[string length $line]} {puts $fd w,$line} else {puts $fd $line}
    }
    close $fd
    exec perl ./conlleval.pl -d , -l < $tag > $evl
    exec perl ./conlleval.pl -d ,    < $tag > $ev
    set fd [open $ev]
    fconfigure $fd -encoding utf-8
    set data [string trim [read $fd]]
    close $fd
    # puts $data
    foreach line [split $data \n] {
      set word [string trim [lindex [split $line :\;] 0]]
      set line [string map {% {} \; {} : {}} $line]
      switch -glob $word {
        processed* {}
        accuracy {
          lassign $line _ accuracy _ precision _ recall _ f1
          # puts "A: $accuracy P: $precision, R: $recall, F1: $f1"
          dict lappend results Accuracy  $accuracy
          dict lappend results Precision $precision
          dict lappend results Recall    $recall
          dict lappend results F1        $f1
        }
        default {
          lassign $line _  _ precision _ recall _ f1 t
          # puts "C: $word P: $precision, R: $recall, F1: $f1 ($t)"
        }
      }
    }
  }
  ## Calculate average...
  foreach k {Accuracy Precision Recall F1} {
    lassign [::math::stats {*}[dict get $results $k]] mean stddev
    puts "$k: [format %.2f $mean] +/- [format %.2f $stddev]"
  }
};# run

foreach data [lsort -dictionary [glob -nocomplain ./data/crf/*.txt]] {
  if {[string match *.neg.txt $data]} {continue}
  puts $data
  run $data
}


# vim: syntax=tcl
