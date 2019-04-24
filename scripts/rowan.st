#!/usr/bin/gemstone/smalltalk
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
		titleField2 titleField3 titleField4 fieldPrintBlock userIdHeader stoneHeader |
	stream := GsFile stdin.
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
							at: 1 put: { project name . project name size . 0 };
							at: 2 put: { loadedCommitId . loadedCommitId size . 0};
							at: 3 put: { branch . branch size . 0};
							at: 4 put: { path . path size . 0};
							at: 5 put: isSkew;
							yourself ].
	stoneHeader := (self sessionIsSolo
		ifTrue: [ '| Stone: (solo session)' ]
		ifFalse: [ '| Stone: ', (System stoneName subStrings: $!) last ]) .
	userIdHeader := '| User:  ', System myUserProfile userId.
	((userIdHeader size max: stoneHeader size) + 2) timesRepeat: [ stream nextPut: $- ].
	stream 
		lf;
		nextPutAll: stoneHeader.
	userIdHeader size >= stoneHeader size
		ifTrue: [ (userIdHeader size - stoneHeader size + 1) timesRepeat: [ stream nextPut: Character space ] ]
		ifFalse: [ stream nextPut: Character space ].
	stream 
		nextPut: $|;
		lf;
		nextPutAll: userIdHeader.
	userIdHeader size >= stoneHeader size
		ifTrue: [ stream nextPut: Character space ]
		ifFalse: [ (stoneHeader size - userIdHeader size + 1) timesRepeat: [ stream nextPut: Character space ] ].
	stream
		nextPut: $|;
		lf.
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
			| line isSkew |
			line := stream.
			isSkew := false.
			field size = 5
				ifTrue: [ 
					isSkew := field at: 5.
					line := isSkew
						ifTrue: [ WriteStream on: String new ]
						ifFalse: [ stream ] ].
			line nextPutAll: '| '.
			line nextPutAll: ((field at: 1) at: 1).
			(((field at: 1) at: 3) + 1) timesRepeat: [line nextPut: space].
			line nextPutAll: separator, ((field at: 2) at: 1).
			(((field at: 2) at: 3) + 1) timesRepeat: [line nextPut: space].
			line nextPutAll: separator, ((field at: 3) at: 1).
			(((field at: 3) at: 3) + 1) timesRepeat: [line nextPut: space].
			line nextPutAll: separator, ((field at: 4) at: 1).
			(((field at: 4) at: 3) + 1) timesRepeat: [line nextPut: space].
			line nextPutAll: separator.
			isSkew ifTrue: [ self ansiRedOn: stream during: [ stream nextPutAll: line contents ] ].
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
