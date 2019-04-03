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
	#category : 'Stash-Core'
}

{ #category : 'initialization' }
StashScript class >> initialize [

	Globals addAssociation: (UserGlobals associationAt: self theNonMetaClass name asSymbol)
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

{ #category : 'script utilities' }
StashScript >> args [

	^args
]

{ #category : 'script utilities' }
StashScript >> basename [

	^ self scriptFile basename
]

{ #category : 'script utilities' }
StashScript >> command [

	^ command
]

{ #category : 'script utilities' }
StashScript >> dirname [

	^ self scriptFile parent
]

{ #category : 'script execution' }
StashScript >> executeScript [

	self subclassResponsibility: #executeScript
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
		commandLine: self class name asString, self stashArgs 
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
	index := aString indexOfSubCollection:  '--' startingAt: 1.
	stashArgs := index = 0
		ifTrue: [ '' ]
		ifFalse: [ aString copyFrom: index + 2 to: aString size ]
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

{ #category : 'accessing' }
StashScript >> workingDirectory [

	^ workingDirectory
]

{ #category : 'accessing' }
StashScript >> workingDirectoryPath: aString [

	workingDirectory := aString asFileReference
]
