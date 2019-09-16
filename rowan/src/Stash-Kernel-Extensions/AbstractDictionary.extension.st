Extension { #name : 'AbstractDictionary' }

{ #category : '*stash-kernel-extensions' }
AbstractDictionary >> at: key ifAbsent: absentBlock ifPresent: oneOrZeroArgBlock [ 
	"Lookup the given key in the receiver. If it is present, answer the value of evaluating the oneOrZeroArgBlock
		with the value associated with the key, otherwise answer the value of absentBlock."

	self at: key ifPresent: [ :v | ^ oneOrZeroArgBlock cull: v ].
	^ absentBlock value
]

{ #category : '*stash-kernel-extensions' }
AbstractDictionary >> at: key ifPresent: oneOrZeroArgBlock ifAbsent: absentBlock [
	"Lookup the given key in the receiver. If it is present, answer the value of evaluating the oneOrZeroArgBlock
		with the value associated with the key, otherwise answer the value of absentBlock."

	self at: key ifPresent: [ :v | ^ oneOrZeroArgBlock cull: v ].
	^ absentBlock value
]
