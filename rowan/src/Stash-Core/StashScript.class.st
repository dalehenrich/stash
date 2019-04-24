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
		'command',
		'projectName',
		'packageName'
	],
	#classInstVars : [
		'scriptDir',
		'scriptName'
	],
	#category : 'Stash-Core'
}

{ #category : 'private' }
StashScript class >> _createScriptExecutionSymbolDictionaryNamed: dictName [

	"create and add a symbol dictionary to the current sessions transient symbol list
		throw and error if there is already a symbol dictionary of the same name in
		the symbol list. "

	| symbolName session transientSymbolList symbolDict |
	symbolName := dictName asSymbol.
	session := GsCurrentSession currentSession.
	transientSymbolList := session symbolList.
	symbolDict := transientSymbolList
		detect: [ :each | (each at: symbolName ifAbsent: [ nil ]) == each ]
		ifNone: [ 
			| newDict|
			newDict := SymbolDictionary new
				name: symbolName;
				objectSecurityPolicy: transientSymbolList objectSecurityPolicy;
				yourself.
			transientSymbolList insertObject: newDict at: 1.
			^ newDict ].
	self error: 'a symbol dictionary named ', dictName printString, ' is already present in the transient symbol list'
]

{ #category : 'script launching' }
StashScript class >> loadAndExecuteScriptClassFile: script_file stashArgs: stash_args topazArgs: topaz_args workingDir: working_dir projectName: projectName packageName: packageName symDictName: symbolDictName [

	| projectDefinition scriptClassDefinition stash |
	self _createScriptExecutionSymbolDictionaryNamed: symbolDictName.
	projectDefinition := Rowan stashTools classTool 
		loadTonelClassFile: script_file
		projectName: projectName
		packageName: packageName
		symDictName: symbolDictName.
	scriptClassDefinition := (projectDefinition packages values any) classDefinitions values any.
	stash := ((GsCurrentSession currentSession symbolList objectNamed: scriptClassDefinition name) 
		stashFilePath: script_file 
		topazArgs: topaz_args 
		stashArgs: stash_args
		workingDir: working_dir)
			projectName: projectName;
			packageName: packageName;
			yourself.
	^ stash setupAndExecuteScript
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
	Rowan stashTools classTool 
		writeTonelClassDefinition: classDefinition 
		toDirectory: directoryPath
		as: filename.
]

{ #category : 'script utilities' }
StashScript >> _downloadErrorFileNameFor: outputFileName [
	| pid |
	pid := (System gemVersionReport at: 'processId') printString.
	^ '/tmp/curl-' , pid , '-' , (outputFileName select: [ :c | c isAlphaNumeric ])
		, '.err'
]

{ #category : 'script utilities' }
StashScript >> args [

	^args
]

{ #category : 'formatting' }
StashScript >> asciiTabulate: columnWidth titleRow: titleRow bodyRows: bodyRows do: rowBlock [

	"
		Each row of the table (titleRow plus bodyRows) is expected to be an array with at least columnWidth slots.
		The columnWidth slots are expected to Strings. Any slots beyond the columnWidth are assumed to be user
		data.

		rowBlock is a 2 arg block: arg1 is a formatted string for the row and arg2 is the row array.
	"

	|  rows colMax title space separator rowPrintBlock dashCount rowStream |

	colMax := Array new: columnWidth withAll: 0.

	title := Array new: titleRow size.
	titleRow isEmpty
		ifFalse: [ 
		1 to: columnWidth do: [:column | | entry |
			entry := titleRow at: column.
			colMax at: column put: entry size.
			title at: column put: { entry . entry size . 0 }	"string, string size, padding" ] ].

	rows := Array new.
	bodyRows do: [:theRow | | row |
		row := Array new: theRow size. 
		1 to: columnWidth do: [:column | | entry |
			entry := theRow at: column.
			colMax at: column put: (entry size  max: (colMax at: column)).
			row at: column put: { entry . entry size . 0 }.	"string, string size, padding"
			(column = columnWidth and: [ theRow size > columnWidth ])
				ifTrue: [
					"additional column data is user specific, so preserve it"
					columnWidth + 1 to: theRow size do: [:index |
						row at: index put: (theRow at: index) ] ] ].
		rows add: row ].

	{title}, rows do: [:theRow |
		theRow isEmpty
			ifFalse: [ 
				1 to: columnWidth do: [:column | | entryArray |
					entryArray := theRow at: column.	"string, string size, padding"
					entryArray at: 3 put: ((colMax at: column) - (entryArray at: 2)) ] ] ].

	rowPrintBlock := [:row |
			rowStream := WriteStream on: String new.
			rowStream nextPutAll: '| '.
			1 to: columnWidth do: [:column | | entry |
				entry := row at: column.
				rowStream nextPutAll: (entry at: 1).
				(entry at: 3) timesRepeat: [rowStream nextPut: space].
				rowStream nextPutAll: separator ].
			rowBlock cull: rowStream contents cull: row ].

	space := Character space.
	separator := ' | '.
	rowStream := WriteStream on: String new.
	dashCount := 2  + (columnWidth * separator size) - 1.
	1 to: columnWidth do: [:column | dashCount := dashCount + (colMax at: column) ].
	dashCount timesRepeat: [ rowStream nextPut: $- ].
	rowBlock cull: rowStream contents cull: nil.

	title isEmpty
		ifFalse: [ rowPrintBlock value: title ].

	rows isEmpty
		ifFalse: [ 
			title isEmpty
				ifFalse: [ 
					rowStream := WriteStream on: String new.
					rowStream nextPutAll: '| '.
					1 to: columnWidth do: [:column |
						(colMax at: column) timesRepeat: [ rowStream nextPut: $- ].
						rowStream nextPutAll: separator ]. 
					rowBlock cull: rowStream contents cull: nil ].

			rows do: rowPrintBlock.

			rowStream := WriteStream on: String new.
			dashCount timesRepeat: [ rowStream nextPut: $- ].
			rowBlock cull: rowStream contents cull: nil ]
]

{ #category : 'script utilities' }
StashScript >> basename [

	^ self stashFile basename
]

{ #category : 'script utilities' }
StashScript >> command [

	^ command
]

{ #category : 'solo support' }
StashScript >> commit [
	"Commits are not allowed when running with a solo session, so skip the commit if running against a solo extent"

	self sessionIsSolo
		ifTrue: [^ true ].
	^ System commit
]

{ #category : 'script utilities' }
StashScript >> deleteScriptProject [
	"should be used before doing a commit from within the script, to avoid persisting script project artifacts"

	Rowan image loadedProjectNamed: self projectName ifAbsent: [ ^ self ].
	Rowan projectTools delete deleteProjectNamed: self projectName.
]

{ #category : 'script utilities' }
StashScript >> dirname [

	^ self stashFile parent
]

{ #category : 'script utilities' }
StashScript >> downloadHttpsFile: httpsUrl to: outputFileName username: username pass: pass [
	"download from <httpsUrl> into <outputFileName>"

	| errorFileName theArgs |
	"Make a unique name for the error log and ensure that we can write the files"
	errorFileName := self _downloadErrorFileNameFor: outputFileName.
	outputFileName asFileReference ensureCreateFile.
	errorFileName asFileReference ensureCreateFile.
	theArgs := username ifNotNil: [ ' -u ' , username , ':' , pass ] ifNil: [ '' ].
	System
		performOnServer:
			'/usr/bin/curl' , theArgs , ' -L ' , httpsUrl , ' > ' , outputFileName , ' 2> '
				, errorFileName.
	^ errorFileName
]

{ #category : 'script implementation' }
StashScript >> edit [
	"add to script if you want to be able to edit your script using smalltalk tools"

	"use `<script-class> saveScript` in image to save any script changes you have made"

	| projName |
	projName := 'EDIT-', self class name asString.
	Rowan stashTools classTool 
		loadTonelClassFile: self stashFile 
			projectName: projName
			packageName: 'EDIT-', self class name asString, '-PKG'.
	self class
		scriptDir: self dirname;
		scriptName: self basename.
	self deleteScriptProject.
	System commit.
	^ 'script can be found in the project ', projName printString
]

{ #category : 'error handling' }
StashScript >> error: aString [

	^ StashCommandError signal: aString
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

{ #category : 'accessing' }
StashScript >> packageName [

	^ packageName
]

{ #category : 'accessing' }
StashScript >> packageName: aString [

	packageName := aString
]

{ #category : 'accessing' }
StashScript >> projectName [

	^ projectName
]

{ #category : 'accessing' }
StashScript >> projectName: aString [

	projectName := aString
]

{ #category : 'script execution' }
StashScript >> scriptOptions [

	self subclassResponsibility: #scriptOptions
]

{ #category : 'testing' }
StashScript >> sessionIsSolo [

	^(GsSession respondsTo: #isSolo)
		ifTrue: [ GsSession perform: #isSolo ]
		ifFalse: [ false ]
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

{ #category : 'error handling' }
StashScript >> stError: aString [

	^ Error signal: aString
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
