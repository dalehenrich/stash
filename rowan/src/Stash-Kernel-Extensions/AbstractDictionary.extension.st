Extension { #name : 'AbstractDictionary' }

{ #category : '*stash-kernel-extensions' }
AbstractDictionary >> at: key ifPresent: aBlock [
  "Lookup the given key in the receiver. If it is present, answer the value of evaluating the given block with the value associated with the key. Otherwise, answer nil."

  | v |
  v := self at: key ifAbsent: [ ^ nil ].
  ^ aBlock value: v

]

{ #category : '*stash-kernel-extensions' }
AbstractDictionary >> at: key ifPresent: oneArgBlock ifAbsent: absentBlock [
  "Lookup the given key in the receiver. If it is present, answer the value of evaluating the oneArgBlock with the value associated with the key, otherwise answer the value of absentBlock."

  self at: key ifPresent: [ :v | ^ oneArgBlock value: v ].
  ^ absentBlock value

]
