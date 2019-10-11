Extension { #name : 'AbstractStashScript' }

{ #category : '*stash-gemstone-abstract' }
AbstractStashScript >> commit [
	"Commits are not allowed when running with a solo session, so skip the commit if running against a solo extent"

	self sessionIsSolo
		ifTrue: [^ true ].
	^ System commit
]

{ #category : '*stash-gemstone-abstract' }
AbstractStashScript >> sessionIsSolo [

	^(GsSession respondsTo: #isSolo)
		ifTrue: [ GsSession perform: #isSolo ]
		ifFalse: [ false ]
]

{ #category : '*stash-gemstone-abstract' }
AbstractStashScript >> stderr [

	^ GsFile stderr
]

{ #category : '*stash-gemstone-abstract' }
AbstractStashScript >> stdout [

	^ GsFile stdout
]
