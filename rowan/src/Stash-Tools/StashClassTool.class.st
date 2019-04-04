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
StashClassTool >> createScriptClassNamed: scriptName inDirectory: directoryPath [

	| classDefinition |
	classDefinition := (RwClassDefinition newForClassNamed: scriptName super: 'StashScript' category: 'Stash-Scripts')
		comment: 'a Stash Script';
		addInstanceMethod:self _scriptOptionsSource protocol: 'script execution';
		addInstanceMethod:self _executeScriptSource protocol: 'script execution';
		addInstanceMethod:self _usageSource protocol: 'usage';
		yourself.
	self writeTonelClassDefinition: classDefinition toDirectory: directoryPath as: scriptName, '.st'.
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
StashClassTool >> loadFiletreeClassDirectory: directoryPath [

	| projectDefinition |
	projectDefinition := RwRepositoryComponentProjectFiletreeReaderVisitor readClassDirectory: directoryPath.
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
StashClassTool >> loadTonelClassFiles: filePathArray [

	| projectDefinition |
	projectDefinition := RwRepositoryComponentProjectTonelReaderVisitor readClassFiles: filePathArray.
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
