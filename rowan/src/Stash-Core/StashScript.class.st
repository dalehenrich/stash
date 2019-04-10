"
To debug a script in the image.

1. Load the script class into your image... use the path to your script file:
	[Rowan classTools stashClassTool loadTonelClassFile: '/home/dhenrich/rogue/_homes/rogue/_home/server/stones/stash_3215/git/stash/bin/template.st'] 
		on: Error do: [:ex | self halt]

2. Then exicute the following to duplicate the code that is run to execute your script ... use the correct class and path:
	| stash |
	stash := (System myUserProfile symbolList objectNamed: 'TEMPLATE') 
		stashFilePath: '/home/dhenrich/rogue/_homes/rogue/_home/server/stones/stash_3215/git/stash/bin/TEMPLATE.st' 
		topazArgs: 'stash_3215 -lq' 
		stashArgs: '--help' 
		workingDir: '/home/dhenrich/rogue/_homes/rogue/_home/server/stones/stash_3215/git/stash'.
	stash setupAndExecuteScript
"
Class {
	#name : 'StashScript',
	#superclass : 'Object',
	#instVars : [
		'stashFile',
		'topazArgs',
		'stashArgs',
		'workingDirectory',
		'opts',
		'args',
		'command'
	],
	#classInstVars : [
		'scriptDir',
		'scriptName'
	],
	#category : 'Stash-Core'
}

{ #category : 'initialization' }
StashScript class >> initialize [

	Globals addAssociation: (UserGlobals associationAt: self theNonMetaClass name asSymbol)
]

{ #category : 'script implementation' }
StashScript class >> saveScript [
	self writeToDirectory: scriptDir as: scriptName
]

{ #category : 'accessing' }
StashScript class >> scriptDir: aStringOrFileReference [

	scriptDir := aStringOrFileReference
]

{ #category : 'accessing' }
StashScript class >> scriptName: aStringOrFileReference [

	scriptName := aStringOrFileReference
]

{ #category : 'instance creation' }
StashScript class >> stashFilePath: stashFilePath topazArgs: topazArgs stashArgs: stashArgs workingDir: workingDir [

	^ self new
		stashFilePath: stashFilePath;
		topazArgString: topazArgs; 
		stashArgString: stashArgs; 
		workingDirectoryPath: workingDir;
		yourself
]

{ #category : 'script implementation' }
StashScript class >> writeToDirectory: directoryPath as: filename [
	"Run script with --save option to invoke this method"
	| classDefinition |
	classDefinition := (Rowan image loadedClassNamed: self name) asDefinition.
	Rowan classTools stashClassTool
		writeTonelClassDefinition: classDefinition 
		toDirectory: directoryPath
		as: filename.
]

{ #category : 'script utilities' }
StashScript >> args [

	^args
]

{ #category : 'script utilities' }
StashScript >> basename [

	^ self stashFile basename
]

{ #category : 'script utilities' }
StashScript >> command [

	^ command
]

{ #category : 'script utilities' }
StashScript >> dirname [

	^ self stashFile parent
]

{ #category : 'script implementation' }
StashScript >> edit [
	"add to script if you want to be able to edit your script using smalltalk tools"

	"use `<script-class> saveScript` in image to save any script changes you have made"

	Rowan classTools stashClassTool 
		loadTonelClassFile: self stashFile 
			projectName: 'EDIT-', self class name asString
			packageName: 'EDIT-', self class name asString, '-PKG'.
	self class
		scriptDir: self dirname;
		scriptName: self basename.
	System commit
]

{ #category : 'script execution' }
StashScript >> executeScript [

	self subclassResponsibility: #executeScript
]

{ #category : 'script utilities' }
StashScript >> globalNamed: aString [
	"return nil if no global found"

	^ Rowan globalNamed: aString
]

{ #category : 'script utilities' }
StashScript >> manPageClass [

	^ StashManPage
]

{ #category : 'script utilities' }
StashScript >> opts [

	^opts
]

{ #category : 'script execution' }
StashScript >> scriptOptions [

	self subclassResponsibility: #scriptOptions
]

{ #category : 'script execution' }
StashScript >> setupAndExecuteScript [

	command := StashCommandLine 
		commandLine: self class name asString, ' ', self stashArgs 
		redirectTarget: nil.
     command
		getOptsMixedLongShort: self scriptOptions
		optionsAndArguments: [ :options :operands |
			opts := options.
			args := operands ].
	^ self executeScript
]

{ #category : 'accessing' }
StashScript >> stashArgs [

	^ stashArgs ifNil: [ '' ]
]

{ #category : 'accessing' }
StashScript >> stashArgString: aString [

	| index |
	index := aString indexOfSubCollection:  ' -- ' startingAt: 1.
	stashArgs := index = 0
		ifTrue: [ aString]
		ifFalse: [ aString copyFrom: 1 to: index - 1 ]
]

{ #category : 'accessing' }
StashScript >> stashFile [

	^stashFile
]

{ #category : 'accessing' }
StashScript >> stashFilePath: aString [

	stashFile := aString asFileReference
]

{ #category : 'accessing' }
StashScript >> topazArgs [

	^topazArgs
]

{ #category : 'accessing' }
StashScript >> topazArgString: aString [

	topazArgs := aString
]

{ #category : 'script utilities' }
StashScript >> workingDirectory [

	^ workingDirectory
]

{ #category : 'accessing' }
StashScript >> workingDirectoryPath: aString [

	workingDirectory := aString asFileReference
]
