"
""Load a single tonel class file""
Rowan classTools stashClassLoadTool loadTonelClassFile: '$GS_HOME/shared/repos/stash/bin/sample.st'.

""Load several class directories from filetree repo in once load""
Rowan classTools stashClassLoadTool loadFiletreeClassDirectories:
	{
		'$GS_HOME/shared/repos/stash/tode/TDCommandGetOpts.class'.
		'$GS_HOME/shared/repos/stash/tode/TDCommandGetOptsTestCase.class'.
		'$GS_HOME/shared/repos/stash/tode/TDCommandLine.class'.
		'$GS_HOME/shared/repos/stash/tode/TDCommandLineTestCase.class'.
	}
"
Class {
	#name : 'StashClassTool',
	#superclass : 'StashAbstractTool',
	#category : 'Stash-Tools'
}

{ #category : 'stash script creation' }
StashClassTool >> _executeScriptSource [

	^ 'executeScript
	"Called to initiate execution of the script"
	^ opts
			at: ''help''
			ifAbsent: [ 
''PUT YOUR SCRIPT CODE HERE''
				 ]
			ifPresent: [ self usage ]'
]

{ #category : 'stash script creation' }
StashClassTool >> _scriptExtension [

	^ '.st'
]

{ #category : 'stash script creation' }
StashClassTool >> _scriptOptionsSource [

	^ 'scriptOptions
	"specify the command line options"
	^ {
			#(''help'' $h #none).
	}'
]

{ #category : 'writing' }
StashClassTool >> _shebang [

	^ '#!/usr/local/bin/smalltalk/gemstone/stash'
]

{ #category : 'stash script creation' }
StashClassTool >> _usageSource: scriptName [

	^ 'usage
	"Man page for script"
	| dashes |
	dashes := ''----------------------------------------------------
''.
	^ GsFile stdout nextPutAll: dashes,
		(self manPageClass
			fromString:
''NAME
	', scriptName, ' - example script, that can be used as a template to create your own script
SYNOPSIS
	', scriptName, ' [-h|--help] -- <topaz-arguments>

DESCRIPTION

	This ', scriptName, ' is set up with help (--help).

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
	', scriptName, ' --help -- MyStone -lq								# GsDevKit_home
	', scriptName, ' --help -- -lq									# GEMSTONE
	', scriptName, ' --help -- MyStone -lq -C "GEM_SOLO_EXTENT=$GEMSTONE/bin/extent0.solo.dbf" --solo	# SOLO
	', scriptName, ' -h -- -lq										# GEMSTONE


'') printString, dashes'
]

{ #category : 'stash script creation' }
StashClassTool >> createScriptNamed: scriptName classNamed: className inDirectory: directoryPath [

	| classDefinition scriptFileName |
	scriptFileName := scriptName , self _scriptExtension.
	classDefinition := (RwClassDefinition newForClassNamed: className super: 'StashScript' category: 'Stash-Scripts')
		comment: 'a Stash Script';
		addInstanceMethod: self _scriptOptionsSource protocol: 'script execution';
		addInstanceMethod: self _executeScriptSource protocol: 'script execution';
		addInstanceMethod: (self _usageSource: scriptFileName) protocol: 'usage';
		yourself.
	self writeTonelClassDefinition: classDefinition toDirectory: directoryPath as: scriptFileName.
	GsHostProcess execute: '/bin/chmod +x ', (directoryPath asFileReference / scriptFileName) pathString.
	^ classDefinition
]

{ #category : 'loading' }
StashClassTool >> loadFiletreeClassDirectories: directoryPathArray [

	| projectDefinition |
	projectDefinition := RwRepositoryComponentProjectFiletreeReaderVisitor readClassDirectories: directoryPathArray.
	Rowan projectTools load loadProjectDefinition: projectDefinition.
	^ projectDefinition
]

{ #category : 'loading' }
StashClassTool >> loadFiletreeClassDirectories: directoryPathArray projectName: projectName packageName: packageName [

	| projectDefinition |
	projectDefinition := RwRepositoryComponentProjectFiletreeReaderVisitor readClassDirectories: directoryPathArray projectName: projectName packageName: packageName.
	Rowan projectTools load loadProjectDefinition: projectDefinition.
	^ projectDefinition
]

{ #category : 'loading' }
StashClassTool >> loadFiletreeClassDirectory: directoryPath [

	| projectDefinition |
	projectDefinition := RwRepositoryComponentProjectFiletreeReaderVisitor readClassDirectory: directoryPath.
	Rowan projectTools load loadProjectDefinition: projectDefinition.
	^ projectDefinition
]

{ #category : 'loading' }
StashClassTool >> loadFiletreeClassDirectory: directoryPath projectName: projectName packageName: packageName [

	| projectDefinition |
	projectDefinition := RwRepositoryComponentProjectFiletreeReaderVisitor readClassDirectory: directoryPath projectName: projectName packageName: packageName.
	Rowan projectTools load loadProjectDefinition: projectDefinition.
	^ projectDefinition
]

{ #category : 'loading' }
StashClassTool >> loadTonelClassFile: filePath [

	| projectDefinition |
	projectDefinition := RwRepositoryComponentProjectTonelReaderVisitor readClassFile: filePath.
	Rowan projectTools load loadProjectDefinition: projectDefinition.
	^ projectDefinition
]

{ #category : 'loading' }
StashClassTool >> loadTonelClassFile: filePath projectName: projectName packageName: packageName [

	^ self loadTonelClassFile: filePath projectName: projectName packageName: packageName symDictName: 'UserGlobals'
]

{ #category : 'loading' }
StashClassTool >> loadTonelClassFile: filePath projectName: projectName packageName: packageName symDictName: symbolDictName [

	| projectDefinition |
	projectDefinition := RwRepositoryComponentProjectTonelReaderVisitor readClassFile: filePath projectName: projectName packageName: packageName.
	projectDefinition setSymbolDictName: symbolDictName forPackageNamed: packageName.
	Rowan projectTools load loadProjectDefinition: projectDefinition.
	^ projectDefinition
]

{ #category : 'loading' }
StashClassTool >> loadTonelClassFiles: filePathArray [

	| projectDefinition |
	projectDefinition := RwRepositoryComponentProjectTonelReaderVisitor readClassFiles: filePathArray.
	Rowan projectTools load loadProjectDefinition: projectDefinition.
	^ projectDefinition
]

{ #category : 'loading' }
StashClassTool >> loadTonelClassFiles: filePathArray projectName: projectName packageName: packageName [

	^self loadTonelClassFiles: filePathArray projectName: projectName packageName: packageName symDictName: 'UserGlobals'
]

{ #category : 'loading' }
StashClassTool >> loadTonelClassFiles: filePathArray projectName: projectName packageName: packageName symDictName: symbolDictName [

	| projectDefinition |
	projectDefinition := RwRepositoryComponentProjectTonelReaderVisitor readClassFiles: filePathArray projectName: projectName packageName: packageName.
	projectDefinition setSymbolDictName: symbolDictName forPackageNamed: packageName, '_1'.
	Rowan projectTools load loadProjectDefinition: projectDefinition.
	^ projectDefinition
]

{ #category : 'writing' }
StashClassTool >> writeTonelClassDefinition: classDefinition toDirectory: directoryPath as: fileName [

	| visitor fileRef |
	visitor := RwModificationTonelWriterVisitor new.
	fileRef := directoryPath asFileReference / fileName.
	fileRef deleteIfAbsent: [].
	fileRef
		writeStreamDo: [:fileStream |
			fileStream nextPutAll: self _shebang; lf.
			visitor 
				_writeClassDefinition: classDefinition on: fileStream;
				_writeClassSideMethodDefinitions: classDefinition on: fileStream;
				_writeInstanceSideMethodDefinitions: classDefinition on: fileStream ].
]
