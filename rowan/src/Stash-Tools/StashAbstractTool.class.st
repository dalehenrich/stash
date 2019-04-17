Class {
	#name : 'StashAbstractTool',
	#superclass : 'RwAbstractTool',
	#category : 'Stash-Tools'
}

{ #category : 'commands' }
StashAbstractTool class >> classTool [

	^ StashClassTool new
]

{ #category : 'commands' }
StashAbstractTool class >> gemstone [

	^ StashGemStoneTool new
]

{ #category : 'commands' }
StashAbstractTool class >> stones [

	^ StashGsDevKitStonesTool new
]
