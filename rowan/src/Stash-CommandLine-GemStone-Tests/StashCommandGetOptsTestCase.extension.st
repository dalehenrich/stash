Extension { #name : 'StashCommandGetOptsTestCase' }

{ #category : '*stash-commandline-gemstone-tests' }
StashCommandGetOptsTestCase >> assert: aString includesSubstring: subString [

	self assert: (aString _findString: aString startingAt: 1 ignoreCase: false) ~~ 0
]

