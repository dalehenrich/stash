#!/usr/bin/smalltalk
"
a command line interface to Rowan. See `rowan.st -h` for more information.
"
Class {
	#name : 'rowan',
	#superclass : 'StashScript',
	#category : 'Stash-Scripts'
}

{ #category : 'script execution' }
rowan >> executeScript [
	"Called to initiate execution of the script"
	^ opts
			at: 'help'
			ifAbsent: [ 
				opts at: 'edit' ifPresent: [:arg | self edit ].
				opts at: 'install' ifPresent: [:arg | self install: arg ].
				opts at: 'load' ifPresent: [:arg | self load: arg ].
				opts at: 'unload' ifPresent: [:arg | self unload: arg ].
				opts at: 'list' ifPresent: [:arg | self list ].
				opts at: 'save' ifPresent: [:arg | self save ].
				 ]
			ifPresent: [ self usage ]
]

{ #category : 'script execution' }
rowan >> scriptOptions [
	"specify the command line options"
	^ {
			#('help' $h #none).
			#('install' nil #required).
			#('load' nil #required).
			#('unload' nil #required).
			#('list' nil #none).
			#('edit' nil #none).
			#('save' nil #none).
	}
]

{ #category : 'script implementation' }
rowan >> edit [
	| classDef |
	classDef := Rowan classTools stashClassTool 
		loadTonelClassFile: self stashFile projectName: 'EDIT' packageName: 'EDIT-PKG'.
	System commit.
	(self globalNamed: classDef name) class
		scriptDir: self dirname;
		scriptName: self scriptFile
	System commit
]

{ #category : 'script implementation' }
rowan class >> writeToDirectory[
	self writeToDirectory: scriptDir as: scriptName
]

{ #category : 'script implementation' }
rowan class >> writeToDirectory: directoryPath as: filename [
	"Run script with --save option to invoke this method"
	| classDefinition |
	classDefinition := (Rowan image loadedClassNamed: self name) asDefinition.
	Rowan classTools stashClassTool
		writeTonelClassDefinition: classDefinition 
		toDirectory: directoryPath
		as: filename.
]

{ #category : 'script implementation' }
rowan >> save [
	self class  writeToDirectory: self dirname as: self basename
]

{ #category : 'script implementation' }
rowan >> install: projectSpecUrl [
	| url |
	url := projectSpecUrl asRwUrl.
	url scheme = 'https'
		ifTrue: [].
]

{ #category : 'script implementation' }
rowan >> load: projectName [
]

{ #category : 'script implementation' }
rowan >> unload: projecName [
]
{ #category : 'script implementation' }
rowan >> list [
]

{ #category : 'usage' }
rowan >> usage [
	"Man page for script"
	| dashes |
	dashes := '----------------------------------------------------
'.
	^ dashes,
		(self manPageClass
			fromString:
'NAME
	rowan.st - manage Rowan projects
SYNOPSIS
	rowan.st [-h | --help] 
	rowan.st [--install=<spec-url>] 
	rowan.st [--load=<project-name>] 
	rowan.st [--unload=<project-name>] 
	rowan.st [--list] 
	rowan.st [--edit] 
		 
DESCRIPTION

	--install=<spec-url>
		Download and install the project as specified in the given <spec-url>.

	--load=<project-name>
		load the given <project-name>.

	--unload=<project-name>
		unload the given <project-name>.

  --list
		list the projects that are loaded in the current image.

	--edit
		load the script into the stone running the script, so that it can be eveloped
		using Smalltalk development tools.

	Use the env var GEMSTONE_SCRIPT_ARGS to define default <stone-name> and other
	topaz arguments (<startTopaz-specific-options>) to be used when running scripts.

EXAMPLES
	rowan.st --help
	rowan.st -h
	rowan.st -h -- myStone -lq

	rowan.st --install=https://github.com/GsDevKit/GsDevKit_upgrade/blob/master/rowan/specs/GsDevKit_upgrade.ston
	rowan.st --load=GsDevKit_upgrade
	rowan.st --unload=GsDevKit_upgrade
	rowan.st --list
	rowan.st --edit
') printString, dashes
]
