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
	#superclass : 'RwClassTool',
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

	^ '#!/usr/bin/smalltalk'
]

{ #category : 'stash script creation' }
StashClassTool >> _usageSource [

	^ 'usage
	"Man page for script"
	| dashes |
	dashes := ''----------------------------------------------------
''.
	^ dashes,
		(self manPageClass
			fromString:
''NAME
	TEMPLATE - example script, that can be used as a template to create your own script
SYNOPSIS
	TEMPLATE.st [-h|--help] [ -- <startTopaz-specific-options> ]
DESCRIPTION

	This TEMPLATE is set up with help (--help).

	Use the env var GEMSTONE_SCRIPT_ARGS to define default <stone-name> and other
	topaz arguments (<startTopaz-specific-options>) to be used when running scripts.

	For complete details about <startTopaz-specific-options> see `startTopaz -h`. Typically,
	you will specify the name of the stone and along with the `-lq` flags.

EXAMPLES
	TEMPLATE.st --help
	TEMPLATE.st -h

	TEMPLATE.st -h -- myStone -lq
'') printString, dashes'
]

{ #category : 'stash script creation' }
StashClassTool >> _usageSource: scriptName [

	^ 'usage
	"Man page for script"
	| dashes |
	dashes := ''----------------------------------------------------
''.
	^ dashes,
		(self manPageClass
			fromString:
''NAME
	', scriptName, ' - example script, that can be used as a template to create your own script
SYNOPSIS
	', scriptName, ' [-h|--help] [ -- <startTopaz-specific-options> ]
DESCRIPTION

	This ', scriptName, ' is set up with help (--help).

	Use the env var GEMSTONE_SCRIPT_ARGS to define default <stone-name> and other
	topaz arguments (<startTopaz-specific-options>) to be used when running scripts.

	For complete details about <startTopaz-specific-options> see `startTopaz -h`. Typically,
	you will specify the name of the stone and along with the `-lq` flags.

EXAMPLES
	', scriptName, ' --help
	', scriptName, ' -h

	', scriptName, ' -h -- myStone -lq
'') printString, dashes'
]

{ #category : 'stash script creation' }
StashClassTool >> createScriptClassNamed: scriptName inDirectory: directoryPath [

	| classDefinition scriptFileName |
	scriptFileName := scriptName , self _scriptExtension.
	classDefinition := (RwClassDefinition newForClassNamed: scriptName super: 'StashScript' category: 'Stash-Scripts')
		comment: 'a Stash Script';
		addInstanceMethod: self _scriptOptionsSource protocol: 'script execution';
		addInstanceMethod: self _executeScriptSource protocol: 'script execution';
		addInstanceMethod: (self _usageSource: scriptFileName) protocol: 'usage';
		yourself.
	self writeTonelClassDefinition: classDefinition toDirectory: directoryPath as: scriptFileName.
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

	| projectDefinition |
	projectDefinition := RwRepositoryComponentProjectTonelReaderVisitor readClassFile: filePath projectName: projectName packageName: packageName.
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

	| projectDefinition |
	projectDefinition := RwRepositoryComponentProjectTonelReaderVisitor readClassFiles: filePathArray projectName: projectName packageName: packageName.
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
