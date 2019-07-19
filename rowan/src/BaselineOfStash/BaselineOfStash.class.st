Class {
	#name : #BaselineOfStash,
	#superclass : #BaselineOf,
	#category : #BaselineOfStash
}

{ #category : #baselines }
BaselineOfStash >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ 
			spec
				package: #'Stash-Core';
				package: #'Stash-CommandLine' with: [ spec requires: #('Stash-Core') ];
				package: #'Stash-CommandLine-Tests' with: [ spec requires: #('Stash-Core') ];
				yourself ].

]

{ #category : #accessing }
BaselineOfStash >> projectClass [
    ^ MetacelloMCBaselineProject
]
