Class {
	#name : 'GsDevKitStoneInfo',
	#superclass : 'Object',
	#instVars : [
		'stoneName',
		'gsVers',
		'username',
		'isAttached'
	],
	#category : 'Stash-Tools'
}

{ #category : 'instance creation' }
GsDevKitStoneInfo class >> importFrom: aFileReference [
	aFileReference readStreamDo: [ :fileStream | ^ STON fromString: fileStream contents ]
]

{ #category : 'ston' }
GsDevKitStoneInfo >> excludedInstVarNames [
	^ #(#isAttached)
]

{ #category : 'ston' }
GsDevKitStoneInfo >> exportTo: aFileReference [
	aFileReference writeStreamDo: [ :stream | STON put: self onStreamPretty: stream ]
]

{ #category : 'accessing' }
GsDevKitStoneInfo >> gsVers [
	^ gsVers
]

{ #category : 'accessing' }
GsDevKitStoneInfo >> gsVers: anObject [
	gsVers := anObject
]

{ #category : 'accessing' }
GsDevKitStoneInfo >> isAttached [
	isAttached ifNil: [ isAttached := false ].
	^ isAttached
]

{ #category : 'accessing' }
GsDevKitStoneInfo >> isAttached: anObject [
	isAttached := anObject
]

{ #category : 'testing' }
GsDevKitStoneInfo >> isForeignStone [

	^false
]

{ #category : 'accessing' }
GsDevKitStoneInfo >> netLDI [
	^ self stoneName , '_ldi'
]

{ #category : 'printing' }
GsDevKitStoneInfo >> printOn: aStream [
	aStream nextPutAll: 'Stone ', self stoneName printString, ' version ', self gsVers printString
]

{ #category : 'accessing' }
GsDevKitStoneInfo >> stoneName [
	^ stoneName
]

{ #category : 'accessing' }
GsDevKitStoneInfo >> stoneName: anObject [
	stoneName := anObject
]

{ #category : 'ston' }
GsDevKitStoneInfo >> stonInstVarNames [
  | oc |
  oc := self class allInstVarNames asOrderedCollection.
  oc removeAll: self excludedInstVarNames.
  ^ oc
]

{ #category : 'ston' }
GsDevKitStoneInfo >> stonOn: stonWriter [
  stonWriter
    writeObject: self
    streamMap: [ :dictionary | 
      self stonInstVarNames
        do: [ :each | dictionary at: each asSymbol put: (self instVarNamed: each) ] ]
]

{ #category : 'ston' }
GsDevKitStoneInfo >> stonProcessSubObjects: block [
  "#stonInstVarNames are the only instance variables that need to be processed..."

  self stonInstVarNames
    do: [ :ivName | self instVarNamed: ivName put: (block value: (self instVarNamed: ivName)) ]
]

{ #category : 'accessing' }
GsDevKitStoneInfo >> username [
	username ifNil: [ username := System gemEnvironmentVariable: 'USER' ].
	^ username
]

{ #category : 'accessing' }
GsDevKitStoneInfo >> username: anObject [
	username := anObject
]

{ #category : 'accessing' }
GsDevKitStoneInfo >> versionNumber [
	^ RwGemStoneVersionNumber fromString: self gsVers
]
