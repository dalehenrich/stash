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
ExampleScript >> scriptOptions [
	"specify the command line options"
	^ {
			#('help' $h #'none').
			#('print' nil #'optional').
	}
]

{ #category : 'script execution' }
ExampleScript >> executeScript [
	"Called to initiate execution of the script"
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
     TEMPLATE [-h|--help] [--print=<arg>] [ -- <topaz-specific-options> ]
DESCRIPTION
EXAMPLES
	TEMPLATE --help
	TEMPLATE -h

	TEMPLATE --print=\`hi there\`
') printString, dashes
]
