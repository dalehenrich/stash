#!/usr/bin/smalltalk
"
a Stash Script
"
Class {
	#name : 'CreateNewStashScript',
	#superclass : 'StashScript',
	#category : 'Stash-Scripts'
}

{ #category : 'script execution' }
CreateNewStashScript >> executeScript [
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
				scriptName := opts at: 'name' ifAbsent: [ self error: 'reguired argument `--name` not present' ].
				Rowan classTools stashClassTool
					createScriptClassNamed: scriptName 
					inDirectory: scriptDir fullName ]
			ifPresent: [ self usage ]
]

{ #category : 'script execution' }
CreateNewStashScript >> scriptOptions [
	"specify the command line options"
	^ {
			#('help' $h #none).
			#('name' nil #required).
			#('dir' nil #required).
	}
]

{ #category : 'usage' }
CreateNewStashScript >> usage [
	"Man page for script"
	| dashes |
	dashes := '----------------------------------------------------
'.
	^ dashes,
		(self manPageClass
			fromString:
'NAME
	CreateNewStashScript.st - create a new script template
SYNOPSIS
	CreateNewStashScript.st [-h|--help] [--dir=<directory-path>]--name=<script-name> \
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
	CreateNewStashScript.st --help
	CreateNewStashScript.st -h

	CreateNewStashScript.st -h -- myStone -lq

	CreateNewStashScript.st --name=MyScript
	CreateNewStashScript.st --name=MyScript --dir=/home/me/bin
') printString, dashes
]
