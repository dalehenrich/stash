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
		'packageName',
		'topazArgs',
		'stashArgs'
	],
	#category : 'Stash-Abstract'
}

{ #category : 'private' }
AbstractStashScript class >> _ansiRed [
	^ (Character esc) asString, '[91;1m'
]

{ #category : 'private' }
AbstractStashScript class >> _ansiReset [
	^ (Character esc) asString, '[0m'
]

{ #category : 'script utilities' }
AbstractStashScript class >> ansiRedOn: stream during: aBlock [

	stream nextPutAll: self _ansiRed.
	aBlock ensure: [ stream nextPutAll: self _ansiReset ].
]

{ #category : 'instance creation' }
AbstractStashScript class >> stashFilePath: stashFilePath topazArgs: topazArgs stashArgs: stashArgs workingDir: workingDir [

	^ self new
		stashFilePath: stashFilePath;
		topazArgString: topazArgs; 
		stashArgString: stashArgs; 
		workingDirectoryPath: workingDir;
		yourself
]

{ #category : 'script utilities' }
AbstractStashScript >> ansiRedOn: stream during: aBlock [

	self class ansiRedOn: stream during: aBlock
]

{ #category : 'script utilities' }
AbstractStashScript >> args [

	^ args ifNil: [ args := {} ]
]

{ #category : 'script utilities' }
AbstractStashScript >> basename [

	^ self stashFile basename
]

{ #category : 'script utilities' }
AbstractStashScript >> command [

	^ command
]

{ #category : 'script utilities' }
AbstractStashScript >> dirname [

	^ self stashFile parent
]

{ #category : 'error handling' }
AbstractStashScript >> error: aString [

	^ StashCommandError signal: aString
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
AbstractStashScript >> stashArgs [

	^ stashArgs ifNil: [ '' ]
]

{ #category : 'accessing' }
AbstractStashScript >> stashArgString: aString [

	| index |
	index := aString indexOfSubCollection:  ' -- ' startingAt: 1.
	stashArgs := index = 0
		ifTrue: [ aString]
		ifFalse: [ aString copyFrom: 1 to: index - 1 ]
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

{ #category : 'accessing' }
AbstractStashScript >> topazArgs [

	^topazArgs
]

{ #category : 'accessing' }
AbstractStashScript >> topazArgString: aString [

	topazArgs := aString
]

{ #category : 'script utilities' }
AbstractStashScript >> workingDirectory [

	^ workingDirectory
]

{ #category : 'accessing' }
AbstractStashScript >> workingDirectoryPath: aString [

	workingDirectory := aString asFileReference
]

{ #category : 'usage' }
AbstractStashScript >> usage: scriptName description: description [
	| dashes |
	dashes := '----------------------------------------------------
'.
  self stdout nextPutAll: dashes,
		(self manPageClass
          fromString:
'NAME
	', scriptName, ' - ', description, '.

SYNOPSIS
  ', scriptName, ' [ -h | --help ] -- <topaz-arguments>

DESCRIPTION
	
EXAMPLES
	', scriptName, ' --help	', scriptName, '

	', scriptName, '
') printString, dashes
]
