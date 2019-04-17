#!/usr/bin/gsdevkit/smalltalk_350
"
$GS_HOME/bin/stones implementation in GemStone Smalltalk
"
Class {
     #name : 'GsDevKit_StonesScript',
     #superclass : 'StashScript',
     #category : 'Stash-Scripts'
}

{ #category : 'script execution' }
GsDevKit_StonesScript >> scriptOptions [
	^ {
			#('help' $h #'none').
			#('all' $a #'none').
			#('running' $r #'none').
			#('installed' $i #'none').
	}
]

{ #category : 'script execution' }
GsDevKit_StonesScript >> executeScript [

	opts
		at: 'help'
    ifAbsent: [
			opts at: 'running' ifPresent: [:ignored | 
				^ Rowan gsDevKitTools stones runningStonesReportOn: GsFile stdout ].
			opts at: 'installed' ifPresent: [:ignored | 
				^  Rowan gsDevKitTools stones installedStonesReportOn: GsFile stdout ]. 
			Rowan gsDevKitTools stones installedStonesReportOn: GsFile stdout.
			Rowan gsDevKitTools stones runningStonesReportOn: GsFile stdout ]
    ifPresent: [ ^ self usage ]
]

{ #category : 'usage' }
GsDevKit_StonesScript >> usage [
	| dashes |
	dashes := '----------------------------------------------------
'.
  ^ dashes,
		(self manPageClass
          fromString:
'NAME
	stones - List information about the installed stones, running stones and running netldis.
SYNOPSIS
	stones.st [ -h | --help ]
	stones.st [ -a | --all ]
	stones.st [ -r | --running ]
	stones.st [ -i | --installed ]

DESCRIPTION

	List information about the installed stones, running stones and running netldis.

	-a | --all
		list running and installed stones [DEFAULT].

	-r | --running
		list running stones.

	-i | --installed
		list installed stones.

EXAMPLES
	stones.st --help
	stones.st -h

	stones.st --all
	stones.st --running
	stones.st --installed

	stones.st -a
	stones.st -r
	stones.st -i
') printString, dashes
]
