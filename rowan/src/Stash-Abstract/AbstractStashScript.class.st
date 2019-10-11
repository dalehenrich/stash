Class {
	#name : 'AbstractStashScript',
	#superclass : 'Object',
	#instVars : [
		'workingDirectory',
		'opts',
		'args',
		'command',
		'stashFile',
		'projectName',
		'packageName'
	],
	#category : 'Stash-Abstract'
}

{ #category : 'script utilities' }
AbstractStashScript >> args [

	^ args ifNil: [ args := {} ]
]

{ #category : 'script utilities' }
AbstractStashScript >> basename [

	^ self stashFile basename
]

{ #category : 'script utilities' }
AbstractStashScript >> dirname [

	^ self stashFile parent
]

{ #category : 'error handling' }
AbstractStashScript >> error: aString [

	^ StashCommandError signal: aString
]

{ #category : 'script utilities' }
AbstractStashScript >> command [

	^ command
]

{ #category : 'script execution' }
AbstractStashScript >> executeScript [

	self subclassResponsibility: #executeScript
]

{ #category : 'script utilities' }
AbstractStashScript >> manPageClass [

	^ StashManPage
]

{ #category : 'script utilities' }
AbstractStashScript >> opts [

	^opts
]

{ #category : 'accessing' }
AbstractStashScript >> packageName [

	^ packageName
]

{ #category : 'accessing' }
AbstractStashScript >> packageName: aString [

	packageName := aString
]

{ #category : 'accessing' }
AbstractStashScript >> projectName [

	^ projectName
]

{ #category : 'accessing' }
AbstractStashScript >> projectName: aString [

	projectName := aString
]

{ #category : 'script execution' }
AbstractStashScript >> scriptOptions [

	"help should always be available"

	^ {
			#('help' $h #'none').
	}
]

{ #category : 'script execution' }
AbstractStashScript >> setupAndExecuteScript [

	command := StashBashCommandLine 
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
AbstractStashScript >> stashFile [

	^stashFile
]

{ #category : 'accessing' }
AbstractStashScript >> stashFilePath: aString [

	stashFile := aString asFileReference
]

{ #category : 'error handling' }
AbstractStashScript >> stError: aString [

	^ Error signal: aString
]

{ #category : 'script utilities' }
AbstractStashScript >> workingDirectory [

	^ workingDirectory
]

{ #category : 'accessing' }
AbstractStashScript >> workingDirectoryPath: aString [

	workingDirectory := aString asFileReference
]
