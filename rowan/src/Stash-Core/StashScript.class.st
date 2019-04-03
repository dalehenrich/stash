Class {
	#name : 'StashScript',
	#superclass : 'Object',
	#instVars : [
		'stashFile',
		'topazArgs',
		'stashArgs',
		'workingDirectory'
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
StashScript >> basename [

	^ self scriptFile basename
]

{ #category : 'script utilities' }
StashScript >> dirname [

	^ self scriptFile parent
]

{ #category : 'script execution' }
StashScript >> executeCommand: command [

	self subclassResponsibility: #executeCommand:
]

{ #category : 'script execution' }
StashScript >> executeScript [

	| command |
	command := StashCommandLine 
		commandLine: self class name asString, self stashArgs 
		redirectTarget: nil.
	^ self executeCommand: command
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
