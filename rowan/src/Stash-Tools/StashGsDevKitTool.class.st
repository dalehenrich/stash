Class {
	#name : 'StashGsDevKitTool',
	#superclass : 'StashAbstractTool',
	#category : 'Stash-Tools'
}

{ #category : 'accessing' }
StashGsDevKitTool >> gs_stonesHome [

	^ (System gemEnvironmentVariable: 'GS_SERVER_STONES') asFileReference
]

{ #category : 'accessing' }
StashGsDevKitTool >> stoneInfoFilename [
	^  'info.ston'
]

{ #category : 'accessing' }
StashGsDevKitTool >> stoneName [
]
