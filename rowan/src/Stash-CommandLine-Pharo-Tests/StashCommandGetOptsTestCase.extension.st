Extension { #name : 'StashCommandGetOptsTestCase' }

{ #category : '*stash-commandline-pharo-tests' }
StashCommandGetOptsTestCase >> assert: aString includesSubstring: subString [

	self assert: (aString includesSubstring: aString)
]

