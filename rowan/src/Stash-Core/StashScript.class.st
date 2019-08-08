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
StashScript class >> _ansiRed [
	^ (Character esc) asString, '[91;1m'
]

{ #category : 'private' }
StashScript class >> _ansiReset [
	^ (Character esc) asString, '[0m'
]

{ #category : 'script utilities' }
StashScript class >> ansiRedOn: stream during: aBlock [

	stream nextPutAll: self _ansiRed.
	aBlock ensure: [ stream nextPutAll: self _ansiReset ].
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

{ #category : 'script utilities' }
StashScript >> ansiRedOn: stream during: aBlock [

	self class ansiRedOn: stream during: aBlock
]

{ #category : 'script utilities' }
StashScript >> args [

	^ args ifNil: [ args := {} ]
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

{ #category : 'script utilities' }
StashScript >> dirname [

	^ self stashFile parent
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

	"help should always be available"

	^ {
			#('help' $h #'none').
	}
]

{ #category : 'script execution' }
StashScript >> setupAndExecuteScript [

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

{ #category : 'usage' }
StashScript >> usage: scriptName description: description [
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
	', description, '

	`-- <topaz-arguments>`
		The command line arguments following the `--` will be passed to the topaz 
		shell interpreter that runs the script. Typically you will use the `-lq` 
		or `MyStone -lq` options to run scripts.

		If you want to use a solo session then you need to define the 
		`GEM_SOLO_EXTENT` configuration parameter in your gem.conf file or on the 
		command line using the `-C` option. The `--solo` option will then initiate a
		topaz solo login for the session: 
	
		-lq -C "GEM_SOLO_EXTENT=$GEMSTONE/bin/extent0.dbf" --solo

		GsDevKit_home
		-------------
		In the GsDevKit_home environment, the env var `$GS_HOME` must be dfined and
		the name of the stone must be supplied on the command line as the first 
		argument after the `--`.

		GEMSTONE
		--------
		If you are not using GsDevKit_home, then the env var `$GEMSTONE` must be
		defined, `$GEMSTONE/bin/topaz` must be in your `$PATH` env variable.

EXAMPLES
	', scriptName, ' --help -- MyStone -lq									# GsDevKit_home
	', scriptName, ' --help -- -lq										# GEMSTONE
	', scriptName, ' --help -- MyStone -lq -C "GEM_SOLO_EXTENT=$GS_HOME/server/snapshots/extent0.solo.dbf" \
			--solo										# SOLO
	', scriptName, ' -- -lq											# GEMSTONE

	', scriptName, ' 	-- MyStone -lq									# GsDevKit_home
') printString, dashes
]

{ #category : 'script utilities' }
StashScript >> workingDirectory [

	^ workingDirectory
]

{ #category : 'accessing' }
StashScript >> workingDirectoryPath: aString [

	workingDirectory := aString asFileReference
]
