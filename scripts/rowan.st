#!/usr/bin/gemstone/smalltalk
"
a command line interface to Rowan. See `rowan.st -h` for more information.
"
Class {
	#name : 'rowan',
	#superclass : 'StashScript',
	#category : 'Stash-Scripts'
}

{ #category : 'private' }
rowan >> _ansiRed [
	^ (Character esc) asString, '[91;1m'
]

{ #category : 'private' }
rowan >> _ansiReset [
	^ (Character esc) asString, '[0m'
]

{ #category : 'utility' }
rowan >> ansiRedOn: stream during: aBlock [

	stream nextPutAll: self _ansiRed.
	aBlock ensure: [ stream nextPutAll: self _ansiReset ].
]

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

	| stream fields userIdHeader stoneHeader |
	stream := GsFile stdin.

	stoneHeader := (self sessionIsSolo
		ifTrue: [ 'Stone: (solo session)' ]
		ifFalse: [ 'Stone: ', (System stoneName subStrings: $!) last ]) .
	userIdHeader := 'User:  ', System myUserProfile userId.

	fields := (((Rowan projectNames 
		select: [:aProjectName | aProjectName ~= '__EXECUTE_STASH_SCRIPT_PROJECT__']) 
			collect: [:aProjectName | Rowan projectNamed: aProjectName ]) 
				sort: [:a :b | a name <= b name])
					collect: [:project |
						| field branch path isSkew loadedCommitId repositoryCommitId |
						loadedCommitId := project loadedCommitId.
						repositoryCommitId := project repositoryCommitId.
						isSkew := loadedCommitId ~= repositoryCommitId.
						isSkew ifTrue: [ loadedCommitId := loadedCommitId, ' -> ', repositoryCommitId ].
						[ branch :=  project currentBranchName ] on: Error do: [:ex | branch :=  'ERROR getting repository branch' ].
						path := (project repositoryRootPath ifNil: ['no repositoryRootPath']).
						field := Array new: 5.
						field
							at: 1 put: project name;
							at: 2 put: loadedCommitId;
							at: 3 put: branch;
							at: 4 put: path;
							at: 5 put: isSkew;
							yourself ].

	self 
		asciiTabulate: 1 
		titleRow: #()
		bodyRows: { { stoneHeader } . { userIdHeader } }
		do: [:rowString :rowArray | stream nextPutAll: rowString; lf ].

	self 
		asciiTabulate: 4 
		titleRow: { 'Project'. 'Commit'. 'Branch'. 'Repository' }
		bodyRows: fields
		do: [:rowString :rowArray | 
			((rowArray size = 5) and: [ rowArray at: 5 ])
				ifTrue: [ 
					self ansiRedOn: stream during: [ stream nextPutAll: rowString ] ]
				ifFalse: [ stream nextPutAll: rowString ].
			stream lf ].
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
	^ GsFile stdout nextPutAll: dashes,
		(self manPageClass
			fromString:
'NAME
	rowan.st - manage Rowan projects
SYNOPSIS
	rowan.st [-h | --help] 					-- MyStone -lq	# GsDevKit_home
	rowan.st [--install=<spec-url>] 			-- -lq		# GEMSTONE
	rowan.st [--load=<project-name>] 			-- MyStone -lq	# GsDevKit_home
	rowan.st [--unload=<project-name>] 			-- -lq		# GEMSTONE 
	rowan.st [--write=<project-name>] 			-- MyStone -lq	# GsDevKit_home 
	rowan.st [--commit=<project-name> <commit-message> ]	-- -lq		# GEMSTONE 
	rowan.st [--list] 					-- MyStone -lq	# GsDevKit_home
	rowan.st [--edit] 					-- -lq		# GEMSTONE

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
	rowan.st --help				-- MyStone -lq							# GsDevKit_home
	rowan.st -h				-- -lq -C "GEM_SOLO_EXTENT=$GEMSTONE/bin/extent0.solo.dbf" --solo \
														# SOLO
	rowan.st -h 				-- MyStone -lq							# GsDevKit_home

	rowan.st --install=https://raw.githubusercontent.com/GsDevKit/GsDevKit_upgrade/master/rowan/specs/GsDevKit_upgrade.ston \
						-- -lq								# GEMSTONE

	rowan.st --load=GsDevKit_upgrade 	-- MyStone -lq							# GsDevKit_home
	rowan.st --unload=GsDevKit_upgrade	-- -lq								# GEMSTONE
	rowan.st --list 			-- MyStone -lq							# GsDevKit_home
	rowan.st --edit				-- -lq								# GEMSTONE
') printString, dashes
]

{ #category : 'script implementation' }
rowan >> write: aProjectName [
	"write the project to disk"

	Rowan projectTools write writeProjectNamed: aProjectName.
	self deleteScriptProject.
	self commit.
]
