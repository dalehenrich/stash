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
			#('installed' $i #'optional').
			#('netldi' $n #'none').
	}
]

{ #category : 'script execution' }
GsDevKit_StonesScript >> executeScript [

	opts
		at: 'help'
    ifAbsent: [
			| running installed netldi installedSortKey |
			running := installed := netldi := opts isEmpty.
			installedSortKey := #name.
			opts at: 'running' ifPresent: [:ignored | running := true ].
			opts at: 'installed' ifPresent: [:argOrNil | 
				installed := true.
				argOrNil ifNotNil: [ installedSortKey := argOrNil asSymbol ] ]. 
			opts at: 'netldi' ifPresent: [:ignored | netldi := true ]. 
			installed
				ifTrue: [ Rowan stashTools stones installedStonesReportOn: GsFile stdout sortKey: installedSortKey ].
			running
				ifTrue: [ Rowan stashTools stones runningStonesReportOn: GsFile stdout ].
			netldi
				ifTrue: [ Rowan stashTools stones runningNetldiReportOn: GsFile stdout ] ] 
    ifPresent: [ ^ self usage ]
]

{ #category : 'usage' }
GsDevKit_StonesScript >> usage [
	| dashes |
	dashes := '----------------------------------------------------
'.
  GsFile stdout nextPutAll: dashes,
		(self manPageClass
          fromString:
'NAME
	stones - List information about the installed stones, running stones and running netldis.
SYNOPSIS
	stones.st [ -h | --help ]
	stones.st [ -a | --all ]
	stones.st [ -r | --running ]
	stones.st [ -i | --installed[=name|version] ]
	stones.st [ -i | --netldi ]

DESCRIPTION

	List information about the installed stones, running stones and running netldis.

	-a | --all
		list running and installed stones [DEFAULT].

	-r | --running
		list running stones.

	-i | --installed[=name|version]
		list installed stones. The stone list may be sorted by `name` or `version`.
		By default, the list is sorte by `version`.

EXAMPLES
	stones.st --help
	stones.st -h

	stones.st

	stones.st --all
	stones.st --running
	stones.st --installed=name
	stones.st --netldi

	stones.st --installed --netldi

	stones.st -a
	stones.st -r
	stones.st -i version
	stones.st -n

') printString, dashes
]
