Class {
	#name : 'StashManPage',
	#superclass : 'Object',
	#instVars : [
		'commandName',
		'summary',
		'synopsis',
		'description',
		'options',
		'examples',
		'commandPath',
		'sourceMethod',
		'subCommands',
		'seeAlso'
	],
	#category : 'Stash-CommandLine'
}

{ #category : 'instance creation' }
StashManPage class >> commandName: commandName commandPath: commandPath fromString: manPageString [
  "see http://pubs.opengroup.org/onlinepubs/009695399/basedefs/xbd_chap12.html for tips on documenting command syntax"

  ^ (self fromString: manPageString)
    commandName: commandName;
    commandPath: commandPath;
    yourself
]

{ #category : 'instance creation' }
StashManPage class >> commandName: commandName commandPath: commandPath sourceMethod: sourceMethod fromString: manPageString [
  "see http://pubs.opengroup.org/onlinepubs/009695399/basedefs/xbd_chap12.html for tips on documenting command syntax"

  ^ (self fromString: manPageString)
    commandPath: commandPath;
    sourceMethod: sourceMethod;
    commandName: commandName;
    yourself
]

{ #category : 'instance creation' }
StashManPage class >> commandName: commandName fromString: manPageString [
  "see http://pubs.opengroup.org/onlinepubs/009695399/basedefs/xbd_chap12.html for tips on documenting command syntax"

  ^ (self fromString: manPageString)
    commandName: commandName;
    yourself
]

{ #category : 'instance creation' }
StashManPage class >> commandName: commandName sourceMethod: sourceMethod fromString: manPageString [
  "see http://pubs.opengroup.org/onlinepubs/009695399/basedefs/xbd_chap12.html for tips on documenting command syntax"

  ^ (self fromString: manPageString)
    sourceMethod: sourceMethod;
    commandName: commandName;
    yourself
]

{ #category : 'instance creation' }
StashManPage class >> commandPath: commandPath fromString: manPageString [
  "see http://pubs.opengroup.org/onlinepubs/009695399/basedefs/xbd_chap12.html for tips on documenting command syntax"

  ^ (self fromString: manPageString)
    commandPath: commandPath;
    yourself
]

{ #category : 'instance creation' }
StashManPage class >> commandPath: commandPath sourceMethod: sourceMethod fromString: manPageString [
  "see http://pubs.opengroup.org/onlinepubs/009695399/basedefs/xbd_chap12.html for tips on documenting command syntax"

  ^ (self fromString: manPageString)
    commandPath: commandPath;
    sourceMethod: sourceMethod;
    yourself
]

{ #category : 'instance creation' }
StashManPage class >> fromString: manPageString [
  "see http://pubs.opengroup.org/onlinepubs/009695399/basedefs/xbd_chap12.html for tips on documenting command syntax"

  | summaryIndex synopsisIndex descriptIndex optionsIndex exampleIndex manPage seeAlsoIndex |
  summaryIndex := 'NAME' size.
  synopsisIndex := manPageString indexOfSubCollection: 'SYNOPSIS' startingAt: 1.
  descriptIndex := manPageString indexOfSubCollection: 'DESCRIPTION' startingAt: 1.
  optionsIndex := manPageString indexOfSubCollection: 'OPTIONS' startingAt: 1.
  exampleIndex := manPageString indexOfSubCollection: 'EXAMPLES' startingAt: 1.
  seeAlsoIndex := manPageString indexOfSubCollection: 'SEE ALSO' startingAt: 1.
  seeAlsoIndex == 0
    ifTrue: [ seeAlsoIndex := manPageString size ].
  exampleIndex == 0
    ifTrue: [ exampleIndex := seeAlsoIndex ].
  optionsIndex == 0
    ifTrue: [ optionsIndex := exampleIndex ].
  descriptIndex == 0
    ifTrue: [ descriptIndex := optionsIndex ].
  synopsisIndex == 0
    ifTrue: [ synopsisIndex := descriptIndex ].
  manPage := self new
    summary:
        (manPageString copyFrom: summaryIndex + 1 to: synopsisIndex - 1) trimBoth;
    synopsis:
        (manPageString copyFrom: synopsisIndex + 'SYNOPSIS' size to: descriptIndex - 1)
            trimBoth;
    description:
        (manPageString copyFrom: descriptIndex + 'DESCRIPTION' size to: optionsIndex - 1)
            trimBoth;
    options:
        (manPageString copyFrom: optionsIndex + 'OPTIONS' size to: exampleIndex - 1)
            trimBoth;
    examples:
        (manPageString copyFrom: exampleIndex + 'EXAMPLES' size to: seeAlsoIndex - 1)
            trimBoth;
    seeAlso:
        (manPageString copyFrom: seeAlsoIndex + 'SEE ALSO' size to: manPageString size)
            trimBoth;
    yourself.
  ^ manPage
]

{ #category : 'instance creation' }
StashManPage class >> sourceMethod: sourceMethod fromString: manPageString [
  "see http://pubs.opengroup.org/onlinepubs/009695399/basedefs/xbd_chap12.html for tips on documenting command syntax"

  ^ (self fromString: manPageString)
    sourceMethod: sourceMethod;
    yourself
]

{ #category : 'as yet unclassified' }
StashManPage >> = aManPage [
  (aManPage isKindOf: self class)
    ifFalse: [ ^ false ].
  ^ self asText asString = aManPage asText asString
]

{ #category : 'as yet unclassified' }
StashManPage >> commandName [
  commandName ifNil: [ commandName := '' ].
  ^ commandName
]

{ #category : 'as yet unclassified' }
StashManPage >> commandName: aString [
  commandName := aString
]

{ #category : 'as yet unclassified' }
StashManPage >> commandPath [
  commandPath ifNil: [ commandPath := '' ].
  ^ commandPath
]

{ #category : 'as yet unclassified' }
StashManPage >> commandPath: aString [
  aString
    ifNil: [ 
      commandPath := nil.
      ^ self ].
  commandPath := 'edit ' , aString
]

{ #category : 'as yet unclassified' }
StashManPage >> description [
  description ifNil: [ description := '' ].
  ^ description
]

{ #category : 'as yet unclassified' }
StashManPage >> description: anObject [
  description := anObject
]

{ #category : 'as yet unclassified' }
StashManPage >> exactSearch: searchString [
  ((self summary includesSubstring: searchString)
    or: [ self description includesSubstring: searchString ])
    ifTrue: [ ^ true ].
  self subCommands values
    do: [ :sub | 
      (sub exactSearch: searchString)
        ifTrue: [ ^ true ] ].
  ^ false
]

{ #category : 'as yet unclassified' }
StashManPage >> examples [
  examples ifNil: [ examples := '' ].
  ^ examples
]

{ #category : 'as yet unclassified' }
StashManPage >> examples: aString [
  examples := aString
]

{ #category : 'as yet unclassified' }
StashManPage >> hash [
  ^ self asText asString hash
]

{ #category : 'as yet unclassified' }
StashManPage >> manPages [
  ^ {self} , self subCommands values
]

{ #category : 'as yet unclassified' }
StashManPage >> options [
  options ifNil: [ options := '' ].
  ^ options
]

{ #category : 'as yet unclassified' }
StashManPage >> options: aString [
  options := aString
]

{ #category : 'as yet unclassified' }
StashManPage >> printOn: aStream [
	aStream
		nextPutAll: 'NAME';
		lf;
		tab;
		nextPutAll: self summary;
		lf;
		lf;
		nextPutAll: 'SYNOPSIS';
		lf;
		tab;
		nextPutAll: self synopsis;
		lf;
		lf;
		nextPutAll: 'DESCRIPTION';
		lf;
		tab;
		nextPutAll: self description;
		lf;
		lf;
		nextPutAll: 'EXAMPLES';
		lf;
		tab;
		nextPutAll: self examples;
		lf;
		lf;
		nextPutAll: 'SEE ALSO';
		lf;
		tab;
		nextPutAll: self commandPath;
		lf;
		tab;
		nextPutAll: self sourceMethod;
		lf
]

{ #category : 'as yet unclassified' }
StashManPage >> regexSearch: regex [
  ((regex search: self summary) or: [ regex search: self description ])
    ifTrue: [ ^ true ].
  self subCommands values
    do: [ :sub | 
      (sub regexSearch: regex)
        ifTrue: [ ^ true ] ].
  ^ false
]

{ #category : 'as yet unclassified' }
StashManPage >> seeAlso [
  | result |
  (seeAlso == nil or: [ seeAlso isEmpty ])
    ifTrue: [ seeAlso := '' ].
  result := seeAlso , String lf.
  commandPath ifNotNil: [ result := result , self commandPath , String lf ].
  sourceMethod
    ifNotNil: [ result := result , '  ' , self sourceMethod , String lf ].
  ^ result
]

{ #category : 'as yet unclassified' }
StashManPage >> seeAlso: aString [
  seeAlso := aString
]

{ #category : 'as yet unclassified' }
StashManPage >> sourceMethod [
  sourceMethod ifNil: [ sourceMethod := '' ].
  ^ sourceMethod
]

{ #category : 'as yet unclassified' }
StashManPage >> sourceMethod: aString [
  aString
    ifNil: [ 
      sourceMethod := nil.
      ^ self ].
  sourceMethod := 'browse method --spec `' , aString , '`'
]

{ #category : 'as yet unclassified' }
StashManPage >> subCommands [
  subCommands ifNil: [ subCommands := Dictionary new ].
  ^ subCommands
]

{ #category : 'as yet unclassified' }
StashManPage >> summary [
  summary ifNil: [ summary := '' ].
  ^ summary
]

{ #category : 'as yet unclassified' }
StashManPage >> summary: anObject [
  summary := anObject
]

{ #category : 'as yet unclassified' }
StashManPage >> synopsis [
  synopsis ifNil: [ synopsis := '' ].
  ^ synopsis
]

{ #category : 'as yet unclassified' }
StashManPage >> synopsis: anObject [
  synopsis := anObject
]

{ #category : 'as yet unclassified' }
StashManPage >> todeItNote: location [
  ^ '  NOTE - use the `tode it` menu item to run the ' , location
    , ' directly from this window.'
]

{ #category : 'as yet unclassified' }
StashManPage >> writeMdOn: aStream [
  | lf lflf |
  lf := String lf.
  lflf := lf , lf.
  aStream
    nextPutAll: '##NAME';
    lf;
    nextPutAll: '  ';
    nextPutAll: (self summary copyReplaceAll: String lf with: lflf);
    lf;
    lf;
    nextPutAll: '##SYNOPSIS';
    lf;
    nextPutAll: '  ';
    nextPutAll: (self synopsis copyReplaceAll: String lf with: lflf);
    lf;
    lf;
    nextPutAll: '##DESCRIPTION';
    lf;
    nextPutAll: '  ';
    nextPutAll: (self description copyReplaceAll: String lf with: lflf);
    lf;
    lf.
  self options isEmpty
    ifFalse: [ 
      aStream
        nextPutAll: '##OPTIONS';
        lf;
        nextPutAll: '  ';
        nextPutAll: (self options copyReplaceAll: String lf with: lflf);
        lf;
        lf ].
  self examples isEmpty
    ifFalse: [ 
      aStream
        nextPutAll: '##EXAMPLES';
        lf;
        nextPutAll: '  ';
        nextPutAll: (self examples copyReplaceAll: String lf with: lflf);
        lf;
        lf ].
  aStream
    nextPutAll: '##SEE ALSO';
    lf;
    nextPutAll: '  ';
    nextPutAll: self commandPath;
    lf;
    nextPutAll: '  ';
    nextPutAll: self sourceMethod;
    lf
]
