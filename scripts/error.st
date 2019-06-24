#!/usr/local/bin/smalltalk/gemstone/stash
"
	Bring up topaz debugger when a script error is encountered
"
Class {
     #name : 'ErrorExampleScript',
     #superclass : 'StashScript',
     #category : 'Stash-Scripts'
}

{ #category : 'script execution' }
 ErrorExampleScript>> scriptOptions [
	^ {
			#('help' $h #'none').
			#('bang' nil #'none').
			#('boom' nil #'none').
	}
]

{ #category : 'script execution' }
 ErrorExampleScript>> executeScript [

	opts
		at: 'help'
    ifAbsent: [
			opts at: 'boom' ifPresent: [ self error: 'BOOM' ].
			opts at: 'bang' ifPresent: [ self stError: 'BANG' ].
			GsFile stdout nextPutAll: 'No error today'; lf  ] 
    ifPresent: [ ^ self usage ]
]

{ #category : 'usage' }
 ErrorExampleScript>> usage [
	| dashes |
	dashes := '----------------------------------------------------
'.
  GsFile stdout nextPutAll: dashes,
		(self manPageClass
          fromString:
'NAME
	error.st - bring up topaz debugger on error

SYNOPSIS
  error.st [ -h | --help ] [ --boom ] [ --bang ] -- <topaz-arguments>

DESCRIPTION
  --boom
		signal a StashCommandError display `red` error message and exit topaz.

  --bang
		signal an error, stop execution, print stack and ready to debug.

	With no `--boom` or --`bang` option, the script exits somewhat quietly.

	`-- <topaz-arguments>`
		The command line arguments following the `--` will be passed to the topaz 
		shell interpreter that runs the script. Typically you will use the `-lq` 
		or `MyStone -lq` options to run scripts.

		If you want to use a solo session then you need to define the 
		`GEM_SOLO_EXTENT` configuration parameter in your gem.conf file or on the 
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
	error.st --help -- MyStone -lq									# GsDevKit_home
	error.st --help -- -lq										# GEMSTONE
	error.st --help -- MyStone -lq -C "GEM_SOLO_EXTENT=$GS_HOME/server/snapshots/extent0.solo.dbf" \
			--solo										# SOLO
	error.st -h -- -lq										# GEMSTONE

	error.st 	-- MyStone -lq									# GsDevKit_home
 	error.st --bang	-- MyStone -lq									# GsDevKit_home
 	error.st --boom	-- MyStone -lq									# GsDevKit_home
 	error.st --boom	-- MyStone -lq --debugCommandError						# GsDevKit_home

') printString, dashes
]
