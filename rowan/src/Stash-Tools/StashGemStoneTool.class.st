Class {
	#name : 'StashGemStoneTool',
	#superclass : 'StashGsDevKitTool',
	#category : 'Stash-Tools'
}

{ #category : 'snapshot' }
StashGemStoneTool >> checkpointsSuspended [
	^ System checkpointStatus at: 1
]

{ #category : 'snapshot' }
StashGemStoneTool >> snapshot: snapshotExtension to: snapshotDirPath suspendInMinutes: suspendInMinutes safely: safely [
	"a commit should be performed before calling this method, to make sure that the snapshot contains any changed state 
		in the current session that you want preserved"

	| snapshots snapshotDirRef |
	snapshotDirRef := snapshotDirPath asFileReference.
	[ 
	self checkpointsSuspended
		ifTrue: [ self error: 'Checkpoints currently suspended. Please wait and try again. Use `System resumeCheckpoints` to resume checkpoints.' ].
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
			| extent extentName snapshotName snapshotFile performCopy |
			extent := extentPath asFileReference.
			snapshotName := extentName := extent basename.
			(extentName asFileReference extension = 'dbf')
				ifTrue: [ 
					snapshotName := (extentName copyFrom: 1 to: extentName size - 3)
						, snapshotExtension ].
			snapshotFile:= snapshotDirRef / snapshotName.
			performCopy := safely
				ifTrue: [ 
					"account for nil return value"
					snapshotFile exists ]
				ifFalse: [ true ].
			GsFile stdout lf.
			performCopy
				ifTrue: [ 
					GsFile stdout nextPutAll:
							'---Starting snapshot to ' , (extentPath , ' ' , snapshotFile pathString) printString
								, '(' , DateAndTime now asString , ')';
						lf.
					extent copyTo: snapshotFile.
					snapshots add: snapshotFile.
					GsFile stdout
						nextPutAll:
								'---Finishing snapshot ' , DateAndTime now asString , ' -- ' , snapshotFile pathString;
						lf]
				ifFalse: [ 
					GsFile stdout nextPutAll:
							'The snapshot file exists, --safely present, copy skipped for: '
								, snapshotFile printString;
						lf ] ].
	self checkpointsSuspended
		ifFalse: [ 
			snapshots do: [ :snapshotFile| snapshotFile delete ].
			self
				error:
					'Checkpoints were resumed before the extent copies were completed. Extent copies have been deleted.' ] ]
		ensure: [ System resumeCheckpoints ].
	^ snapshots
]

{ #category : 'snapshot' }
StashGemStoneTool >> snapshotExtentFilePaths [
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
