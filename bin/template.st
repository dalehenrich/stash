#!/usr/bin/smalltalk
"
Example executable script
"
Class {
     #name : 'TEMPLATE',
     #superclass : 'StashScript',
     #category : 'Scripts'
}

{ #category : 'script execution' }
ExampleScript >> executeCommand: command [
	"Called to initiate execution of the script"
	| opts args |
	command
		getOptsMixedLongShort: {
			#('help' $h #'none').
			#('print' nil #'optional').
			}
		optionsAndArguments: [ :options :operands |
			opts := options.
      args := operands ].
		^ opts
			at: 'help'
				ifAbsent: [ 
'PUT YOUR SCRIPT CODE HERE'
				 ]
				ifPresent: [ self usage ] ]

{ #category : 'usage' }
ExampleScript >> usage [
	"Man page for script"
	| dashes |
	dashes := '----------------------------------------------------
'.
	^ dashes,
		(self manPageClass
			fromString:
'NAME
     TEMPLATE - example
SYNOPSIS
     TEMPLATE [-h|--help] [--print=arg]
DESCRIPTION
EXAMPLES
	TEMPLATE --help
	TEMPLATE -h

	TEMPLATE --print=\`hi there\`
') printString, dashes
]
