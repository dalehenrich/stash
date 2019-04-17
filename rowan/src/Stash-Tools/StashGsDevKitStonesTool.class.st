Class {
	#name : 'StashGsDevKitStonesTool',
	#superclass : 'StashGsDevKitTool',
	#instVars : [
		'installedStones'
	],
	#category : 'Stash-Tools'
}

{ #category : 'accessing' }
StashGsDevKitStonesTool >> installedStones [
	installedStones
		ifNil: [ 
			| stonesHome dirs |
			installedStones := Dictionary new.
			stonesHome := self gs_stonesHome.
			dirs := stonesHome directories.
			dirs
				do: [ :stoneDir | 
					(stoneDir filesMatching: self stoneInfoFilename)
						do: [ :infoFile | 
							| info |
							info := GsDevKitStoneInfo importFrom: infoFile.
							stoneDir isSymlink
								ifTrue: [ info isAttached: true ].
							installedStones at: info stoneName put: info ] ] ].
	^ installedStones
]

{ #category : 'reports' }
StashGsDevKitStonesTool >> installedStonesReportOn: stream [
	^ self installedStonesReportOn: stream  sortKey: #name
]

{ #category : 'reports' }
StashGsDevKitStonesTool >> installedStonesReportOn: stream  sortKey: installedSortKey [
	| sortedStoneInfo |
	stream
		nextPutAll: 'Installed Stones:';
		cr.
	sortedStoneInfo := installedSortKey == #name
		ifTrue: [ self installedStones values sorted: [ :a :b | a stoneName < b stoneName ] ]
		ifFalse: [ 
			self installedStones values sorted: [ :a :b |  | avn bvn |
				avn := a  versionNumber.
				bvn := b versionNumber .
				avn = bvn
					ifTrue:  [ a stoneName < b stoneName ]
					ifFalse: [ avn < bvn ] ] ].
	sortedStoneInfo
		do: [ :info | 
			stream
				tab;
				nextPutAll: info gsVers;
				tab;
				nextPutAll: info stoneName.
			info isForeignStone
				ifTrue: [ 
					stream
						tab;
						nextPutAll: '(foreign)' ].
			info isAttached
				ifTrue: [ 
					stream
						tab;
						nextPutAll: '(attached)' ].
			stream cr ]
]

{ #category : 'reports' }
StashGsDevKitStonesTool >> runningNetldiReportOn: aStream [
]

{ #category : 'reports' }
StashGsDevKitStonesTool >> runningStonesReportOn: aStream [
]
