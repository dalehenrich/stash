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
StashScript >> executeScript [
]

{ #category : 'accessing' }
StashScript >> stashArgs [

	^ stashArgs
]

{ #category : 'accessing' }
StashScript >> stashArgString: aString [

	stashArgs := aString
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
