Class {
	#name : 'StashAbstractTool',
	#superclass : 'RwAbstractTool',
	#category : 'Stash-Rowan-Abstract-Tools'
}

{ #category : 'commands' }
StashAbstractTool class >> classTool [

	^ StashClassTool new
]

{ #category : 'error handling' }
StashAbstractTool >> error: aString [

	^ StashCommandError signal: aString
]
