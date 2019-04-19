#!/usr/bin/gsdevkit/smalltalk_350
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
				| scriptName scriptDir |
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
						inDirectory: directoryPath ]
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
	createTemplateScript.st [-h|--help]
	createTemplateScript.st [--dir=<directory-path>] --script=<script-name> --class=<class-name> \
		[ -- <startTopaz-specific-options> ]
DESCRIPTION

	This script creates a new stash script name <script-name>.st in the current
	directory. 

	The `--dir` option may be used to create a script in an alternate location.
	The `--dir` option may be an absolute path or a path relative to the 
	current directory.

	Use the env var GEMSTONE_SCRIPT_ARGS to define default <stone-name> and other
	topaz arguments (<startTopaz-specific-options>) to be used when running scripts.

	For complete details about <startTopaz-specific-options> see `startTopaz -h`. Typically,
	you will specify the name of the stone and along with the `-lq` flags.

EXAMPLES
	createTemplateScript.st --help
	createTemplateScript.st -h

	createTemplateScript.st -h -- myStone -lq

	createTemplateScript.st --script=myScript --class=MyScript
	createTemplateScript.st --script=myScript --class=MyScript --dir=/home/me/bin
') printString, dashes
]
