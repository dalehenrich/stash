#!/usr/bin/gemstone/smalltalk
"
a Stash Script
"
Class {
	#name : 'CreateTemplateScript',
	#superclass : 'StashScript',
	#category : 'Stash-Scripts'
}

{ #category : 'script execution' }
 CreateTemplateScript>> executeScript [
	"Called to initiate execution of the script"
	^ opts
			at: 'help'
			ifAbsent: [ 
				| scriptName scriptDir className |
				scriptDir := self workingDirectory asFileReference.
				opts at: 'dir'
					ifPresent: [:dirPath | scriptDir := dirPath asFileReference ].
				scriptDir isAbsolute
					ifFalse: [ scriptDir := self workingDirectory asFileReference / scriptDir ].
				scriptName := opts at: 'script' ifAbsent: [ self error: 'reguired argument `--script` not present' ].
				className := opts at: 'class' ifAbsent: [ self error: 'reguired argument `--class` not present' ].
				Rowan stashTools classTool
					createScriptNamed: scriptName 
						classNamed: className 
						inDirectory: scriptDir ]
			ifPresent: [ self usage ]
]

{ #category : 'script execution' }
 CreateTemplateScript>> scriptOptions [
	"specify the command line options"
	^ {
			#('help' $h #none).
			#('script' nil #required).
			#('class' nil #required).
			#('dir' nil #required).
	}
]

{ #category : 'usage' }
 CreateTemplateScript>> usage [
	"Man page for script"
	| dashes |
	dashes := '----------------------------------------------------
'.
	^ GsFile stdout nextPutAll: dashes,
		(self manPageClass
			fromString:
'NAME
	createTemplateScript.st - create a new script template
SYNOPSIS
	createTemplateScript.st [-h|--help] -- <topaz-arguments>
	createTemplateScript.st [--dir=<directory-path>] --script=<script-name> --class=<class-name> \
		-- <topaz-arguments>
DESCRIPTION

	This script creates a new stash script name <script-name>.st in the current
	directory. 

	The `--dir` option may be used to create a script in an alternate location.
	The `--dir` option may be an absolute path or a path relative to the 
	current directory.

	The `--script` option defines the name of the script file (a `.st` extension
	will be added the name.

	The `--class` option defines the name of the class that will be used for the
	script.

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
	createTemplateScript.st --help -- MyStone -lq									# GsDevKit_home
	createTemplateScript.st --help -- -lq										# GEMSTONE
	createTemplateScript.st --help -- MyStone -lq -C "GEM_SOLO_EXTENT=$GS_HOME/server/snapshots/extent_solo.dbf" \
				--solo											# SOLO
	createTemplateScript.st -h -- -lq										# GEMSTONE

	createTemplateScript.st --script=myScript --class=MyScript -- -lq						# GEMSTONE
	createTemplateScript.st --script=myScript --class=MyScript --dir=/home/me/bin -- MyStone -lq			# GsDevKit_home
') printString, dashes
]
