#!/usr/bin/gsdevkit/smalltalk_350
"
a command line interface to Rowan. See `rowan.st -h` for more information.
"
Class {
	#name : 'rowan',
	#superclass : 'StashScript',
	#category : 'Stash-Scripts'
}

{ #category : 'script implementation' }
rowan >> commit: aProjectName message: commitMessage [
	"commit the project to a git repository"

	commitMessage ifNil: [ self error: 'missing required option: --messge' ].
	Rowan projectTools write writeProjectNamed: aProjectName.
	Rowan projectTools commit
		commitProjectNamed: aProjectName
		message: commitMessage.
	self deleteScriptProject.
	self commit.
]

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
				opts at: 'write' ifPresent: [:arg | self write: arg ].
				opts at: 'commit' ifPresent: [:arg | self commit: arg message: (args at: 1) ].
				opts at: 'list' ifPresent: [:arg | self list ].
				^ true ]
			ifPresent: [ self usage ]
]

{ #category : 'script implementation' }
rowan >> install: projectSpecUrl [
	| url errFilename spec specUrl specFile |
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
	[specFile  asFileReference readStreamDo: [:fStream | 
		"verify that the .ston file exists and can be read..."
		spec := STON fromString: fStream contents ] ]
		on: Error
		do: [:ex |
			self error: 'ERROR :: ', ex description, ' :: reading project spec from ', specUrl printString, ' ::error could have been cause by:: ', errFilename asFileReference contents ].
	"clone the project to disk"
	Rowan projectTools clone
		cloneSpecUrl: specUrl
		gitRootPath: '$ROWAN_PROJECTS_HOME'
		useSsh: true.
	"load the project"
	^ self load: spec specName
]

{ #category : 'script implementation' }
rowan >> list [

	| stream fields col1Max col2Max col3Max col4Max space separator titleFields titleField1 
		titleField2 titleField3 titleField4 fieldPrintBlock |
	stream := GsFile stdin.
	fields := (((Rowan projectNames 
		select: [:aProjectName | aProjectName ~= '__EXECUTE_STASH_SCRIPT_PROJECT__']) 
			collect: [:aProjectName | RwProject newNamed: aProjectName ]) 
				sort: [:a :b | a name <= b name])
					collect: [:project |
						| field branch path |
						[ branch :=  project currentBranchName ] on: Error do: [:ex | branch :=  'ERROR getting repository branch' ].
						path := (project repositoryRootPath ifNil: ['no repositoryRootPath']).
						field := Array new: 4.
						field
							at: 1 put: { project name . project name size . 0 };
							at: 2 put: { project loadedCommitId . project loadedCommitId size . 0};
							at: 3 put: { branch . branch size . 0};
							at: 4 put: { path . path size . 0};
							yourself ].
	titleField1 := 'Project'.
	titleField2 := 'Commit'.
	titleField3 := 'Branch'.
	titleField4 := 'Repository'.
	col1Max := titleField1 size.
	col2Max := titleField2 size.
	col3Max := titleField3 size.
	col4Max := titleField4 size.
	fields do: [:field |
		col1Max := ((field at: 1) at: 2) max: col1Max.
		col2Max := ((field at: 2) at: 2) max: col2Max.
		col3Max := ((field at: 3) at: 2) max: col3Max.
		col4Max := ((field at: 4) at: 2) max: col4Max ].
	fields do: [:field |
		(field at: 1) at: 3 put: (col1Max - ((field at: 1) at: 2)).
		(field at: 2) at: 3 put: (col2Max - ((field at: 2) at: 2)).
		(field at: 3) at: 3 put: (col3Max - ((field at: 3) at: 2)).
		(field at: 4) at: 3 put: (col4Max - ((field at: 4) at: 2)) ].
	titleFields := { 
		{titleField1 . nil. col1Max - titleField1 size }.
		{titleField2 . nil. col2Max - titleField2 size }.
		{titleField3 . nil. col3Max - titleField3 size }.
		{titleField4 . nil. col4Max - titleField4 size }.
	}.

	fieldPrintBlock := [:field |
			stream nextPutAll: '| '.
			stream nextPutAll: ((field at: 1) at: 1).
			(((field at: 1) at: 3) + 1) timesRepeat: [stream nextPut: space].
			stream nextPutAll: separator, ((field at: 2) at: 1).
			(((field at: 2) at: 3) + 1) timesRepeat: [stream nextPut: space].
			stream nextPutAll: separator, ((field at: 3) at: 1).
			(((field at: 3) at: 3) + 1) timesRepeat: [stream nextPut: space].
			stream nextPutAll: separator, ((field at: 4) at: 1).
			(((field at: 4) at: 3) + 1) timesRepeat: [stream nextPut: space].
			stream nextPutAll: separator.
			stream lf ].

	space := Character space.
	separator := ' | '.
	2 + col1Max + col2Max + col3Max + col4Max + 3 + (4 * separator size) timesRepeat: [ stream nextPut: $- ].
	stream lf.

	fieldPrintBlock value: titleFields.

	stream nextPutAll: '| '.
	col1Max + 1 timesRepeat: [ stream nextPut: $- ].
	stream nextPutAll: separator. 
	col2Max + 1 timesRepeat: [ stream nextPut: $- ].
	stream nextPutAll: separator. 
	col3Max + 1 timesRepeat: [ stream nextPut: $- ].
	stream nextPutAll: separator. 
	col4Max + 1 timesRepeat: [ stream nextPut: $- ].
	stream nextPutAll: separator.
	stream lf.

	fields do: fieldPrintBlock.

	2 + col1Max + col2Max + col3Max + col4Max + 3 + (4 * separator size) timesRepeat: [ stream nextPut: $- ].
	stream lf.
]

{ #category : 'script implementation' }
rowan >> load: aProjectName [
	"load the project"

	| result |
	result := Rowan projectTools load loadProjectNamed: aProjectName.
	self deleteScriptProject.
	self commit.
	^ result
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
			#('write' nil #required).
			#('commit' nil #required).
			#('edit' nil #none).
	}
]

{ #category : 'script implementation' }
rowan >> unload: aProjectName [
	"unload the project"

	| result |
	result := Rowan projectTools delete deleteProjectNamed: aProjectName.
	self deleteScriptProject.
	self commit.
	^ result
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
	rowan.st [--write=<project-name>] 
	rowan.st [--commit=<project-name> <commit-message> ] 
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

{ #category : 'script implementation' }
rowan >> write: aProjectName [
	"write the project to disk"

	Rowan projectTools write writeProjectNamed: aProjectName.
	self deleteScriptProject.
	self commit.
]
