Extension { #name : 'StashScript' }

{ #category : '*stash-rowan-core' }
StashScript class >> saveScript [
	self writeToDirectory: scriptDir as: scriptName
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
