#!/usr/bin/gemstone/smalltalk
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
	stones.st [ -h | --help ] -- <topaz-arguments>
	stones.st [ -a | --all ] -- <topaz-arguments>
	stones.st [ -r | --running ] -- <topaz-arguments>
	stones.st [ -i | --installed[=name|version] ] -- <topaz-arguments>
	stones.st [ -i | --netldi ] -- <topaz-arguments>

DESCRIPTION

	List information about the installed stones, running stones and running netldis.

	-a | --all
		list running and installed stones [DEFAULT].

	-r | --running
		list running stones.

	-i | --installed[=name|version]
		list installed stones. The stone list may be sorted by `name` or `version`.
		By default, the list is sorte by `version`.

	`-- <topaz-arguments>`
		The command line arguments following the `--` will be passed to the topaz 
		exectuable that runs the script. Typically you will use the `-lq` options to
		run scripts.

		If you want to use a solo session then you need to define the 
		`GEM_SOLO_EXTENT` configuration paramter in your gem.conf file or on the 
		command line using the `-C` option. The `--solo` option will then initiate a
		topaz solo login for the session: 
	
		-lq -C "GEM_SOLO_EXTENT=$GEMSTONE/bin/extent0.dbf" --solo

		GsDevKit_home
		-------------
		In the GsDevKit_home environment, the env var `$GS_HOME` must be dfined and
		the name of the stone must be supplied on the command line as the first 
		argument after the `--`.

		GEMSTONE
		--------
		If you are not using GsDevKit_home, then the env var `$GEMSTONE` must be
		defined, `$GEMSTONE/bin/topaz` must be in your `$PATH` env variable.

EXAMPLES
	error.st --help -- MyStone -lq							# GsDevKit_home
	error.st --help -- MyStone -lq -C "GEM_SOLO_EXTENT=$GEMSTONE/bin/extent0.solo.dbf" \
				--solo							# SOLO
	error.st -h -- MyStone -lq							# GsDevKit_home

	stones.st -- MyStone -lq							# GsDevKit_home

	stones.st --all -- MyStone -lq							# GsDevKit_home
	stones.st --running -- MyStone -lq						# GsDevKit_home
	stones.st --installed=name -- MyStone -lq					# GsDevKit_home
	stones.st --netldi -- MyStone -lq						# GsDevKit_home

	stones.st --installed --netldi -- MyStone -lq					# GsDevKit_home

	stones.st -a -- MyStone -lq							# GsDevKit_home
	stones.st -r -- MyStone -lq							# GsDevKit_home
	stones.st -i version -- MyStone -lq						# GsDevKit_home
	stones.st -n -- MyStone -lq							# GsDevKit_home

') printString, dashes
]
