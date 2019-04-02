Class {
	#name : 'StashScript',
	#superclass : 'Object',
	#instVars : [
		'stashFile',
		'topazArgString',
		'stashArgString',
		'workingDirectoryPath'
	],
	#category : 'Stash-Core'
}

{ #category : 'instance creation' }
StashScript class >> stashFile: stashFile topazArgs: topazArgs stashArgs: stashArgs workingDir: workingDir [

	^ self new
		stashFile: stashFile;
		topazArgString: topazArgs; 
		stashArgString: stashArgs; 
		workingDirectoryPath: workingDir;
		yourself
]

{ #category : 'script execution' }
StashScript >> executeScript [
]

{ #category : 'accessing' }
StashScript >> stashArgString [

	^ stashArgString
]

{ #category : 'accessing' }
StashScript >> stashArgString: aString [

	stashArgString := aString
]

{ #category : 'accessing' }
StashScript >> stashFile [

	^stashFile
]

{ #category : 'accessing' }
StashScript >> stashFile: aString [

	stashFile := aString
]

{ #category : 'accessing' }
StashScript >> topazArgString [

	^topazArgString
]

{ #category : 'accessing' }
StashScript >> topazArgString: aString [

	topazArgString := aString
]

{ #category : 'accessing' }
StashScript >> workingDirectoryPath [

	^ workingDirectoryPath
]

{ #category : 'accessing' }
StashScript >> workingDirectoryPath: aString [

	workingDirectoryPath := aString
]
