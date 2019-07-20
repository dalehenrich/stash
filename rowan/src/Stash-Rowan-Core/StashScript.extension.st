Extension { #name : 'StashScript' }

{ #category : '*stash-rowan-core' }
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

{ #category : '*stash-rowan-core' }
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

{ #category : '*stash-rowan-core' }
StashScript class >> saveScript [
	self writeToDirectory: scriptDir as: scriptName
]

{ #category : '*stash-rowan-core' }
StashScript class >> writeToDirectory: directoryPath as: filename [
	"Run script with --save option to invoke this method"
	| classDefinition |
	classDefinition := (Rowan image loadedClassNamed: self name) asDefinition.
	Rowan stashTools classTool 
		writeTonelClassDefinition: classDefinition 
		toDirectory: directoryPath
		as: filename.
]

{ #category : '*stash-rowan-core' }
StashScript >> deleteScriptProject [
	"should be used before doing a commit from within the script, to avoid persisting script project artifacts"

	Rowan image loadedProjectNamed: self projectName ifAbsent: [ ^ self ].
	Rowan projectTools delete deleteProjectNamed: self projectName.
]

{ #category : '*stash-rowan-core' }
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

{ #category : '*stash-rowan-core' }
StashScript >> globalNamed: aString [
	"return nil if no global found"

	^ Rowan globalNamed: aString
]
