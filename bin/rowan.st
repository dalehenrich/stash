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
				 ]
			ifPresent: [ self usage ]
]

{ #category : 'script implementation' }
rowan >> install: projectSpecUrl [
	| url errFilename spec specUrl specFile result |
	specUrl := projectSpecUrl.
	url := specUrl asRwUrl.
	url scheme = 'https'
		ifTrue: [
			| filename |
			filename :=  '/tmp/', self class name asString, '.ston'.
			errFilename := self downloadHttpsFile: specUrl to: filename username: nil pass: nil.
			specUrl := 'file:', filename.
			url := specUrl asRwUrl ].
	specFile := url pathString.
	[specFile  asFileReference readStreamDo: [:fStream | spec := STON fromString: fStream contents ] ]
		on: Error
		do: [:ex |
			self error: 'ERROR :: ', ex description, ' :: reading project spec from ', specUrl printString, ' ::error could have been cause by:: ', errFilename asFileReference contents ].
	Rowan projectTools clone
		cloneSpecUrl: specUrl
		gitRootPath: '$ROWAN_PROJECTS_HOME'
		useSsh: true.
	result := Rowan projectTools load loadProjectNamed: spec specName.
	self deleteScriptProject.
	System commit.
	^ result
]

{ #category : 'script implementation' }
rowan >> list [
]

{ #category : 'script implementation' }
rowan >> load: aProjectName [
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
	}
]

{ #category : 'script implementation' }
rowan >> unload: aProjecName [
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
	rowan.st ... [ -- <topaz-specific-options> ]
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
		load the script into the stone running the script, so that it can be written
		using Smalltalk development tools.

	<topaz-specific-options>
		Specify any topaz-specific options following a ` -- ` on the command line. 

		You can use tse the env var GEMSTONE_SCRIPT_ARGS to define default <stone-name>
		and other topaz arguments (<startTopaz-specific-options>) to be used when running 
		scripts.

EXAMPLES
	rowan.st --help
	rowan.st -h
	rowan.st -h -- myStone_350 -lq

	rowan.st --install=https://raw.githubusercontent.com/GsDevKit/GsDevKit_upgrade/master/rowan/specs/GsDevKit_upgrade.ston
	rowan.st --load=GsDevKit_upgrade
	rowan.st --unload=GsDevKit_upgrade
	rowan.st --list
	rowan.st --edit
') printString, dashes
]
