Class {
	#name : 'StashGemStoneTool',
	#superclass : 'StashGsDevKitTool',
	#category : 'Stash-Tools'
}

{ #category : 'snapshot' }
StashGemStoneTool class >> _checkpointsSuspended [
	^ System checkpointStatus at: 1
]

{ #category : 'snapshot' }
StashGemStoneTool class >> snapshot: snapshotExtension to: snapshotPath suspendInMinutes: suspendInMinutes safely: safely [
	| snapshots snapshotFileRef |
	snapshotFileRef := snapshotPath asFileReference.
	[ 
	System commitTransaction
		ifFalse: [ self error: 'Commit failed: snapshot not taken' ].
	self checkpointsSuspended
		ifTrue: [ self error: 'Checkpoints currently suspended. Please wait and try again.' ].
	System startCheckpointSync
		ifFalse: [ 
			self
				error:
					'Could not start a checkpoint, See comment in System class>>startCheckpointSync for possible reasons for failure.' ].
	(System suspendCheckpointsForMinutes: suspendInMinutes)
		ifFalse: [ 
			self
				error:
					'Could not suspend checkpoints, See comment in System class>>suspendCheckpointsForMinutes: for possible reasons for failure.' ].
	snapshots := {}.
	self snapshotExtentFilePaths
		do: [ :extentPath | 
			| extent extentName snapshotName snapshotFilePath performCopy |
			extent := extentPath asFileReference.
			snapshotName := extentName := extent basename.
			(extentName extension = '.dbf')
				ifTrue: [ 
					snapshotName := (extentName copyFrom: 1 to: extentName size - 3)
						, snapshotExtension ].
			snapshotFilePath := snapshotFileRef / snapshotName.
			performCopy := safely
				ifTrue: [ 
					"account for nil return value"
					snapshotFilePath exists ]
				ifFalse: [ true ].
			GsFile stdout lf.
			performCopy
				ifTrue: [ 
					GsFile stdout nextPutAll:
							'---Starting snapshot to ' , (extentPath , ' ' , snapshotFilePath) printString
								, '(' , DateAndTime now asString , ')'.
					extentPath copyto: snapshotFilePath.
					snapshots add: snapshotFilePath.
					GsFile stdout
						cr;
						tab;
						show:
								'---Finishing snapshot ' , DateAndTime now asString , ' -- ' , snapshotFilePath ]
				ifFalse: [ 
					GsFile stdout nextPutAll:
							'The snapshot file exists, --safely present, copy skipped for: '
								, snapshotFilePath printString ] ].
	self _checkpointsSuspended
		ifFalse: [ 
			snapshots do: [ :snapshotFilePath | snapshotFilePath delete ].
			self
				error:
					'Checkpoints were resumed before the extent copies were completed. Extent copies have been deleted.' ] ]
		ensure: [ System resumeCheckpoints ].
	^ snapshots
]

{ #category : 'snapshot' }
StashGemStoneTool class >> snapshotExtentFilePaths [
	^ SystemRepository fileNames
		collect: [ :each | 
			(each indexOf: $! startingAt: 1) = 0
				ifTrue: [ each ]
				ifFalse: [ 
					| idx |
					"in 2.4.x, the the NRS is tacked on the front of the filename"
					idx := each indexOf: $! startingAt: 2.
					each copyFrom: idx + 1 to: each size ] ]
]
