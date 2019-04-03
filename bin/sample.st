#!/usr/bin/smalltalk
"
Example executable script
"
Class {
     #name : 'ExampleScript',
     #superclass : 'StashScript',
     #category : 'Examples'
}

{ #category : 'script execution' }
ExampleScript >> scriptOptions [
	^ {
			#('help' $h #'none').
			#('print' $p #'optional').
	}
]

{ #category : 'script execution' }
ExampleScript >> executeScript [
	opts
		at: 'help'
    ifAbsent: [
			opts at: 'print' 
				ifPresent: [:optionalArg |
					^ optionalArg asString ].
			^ 'noop' ]
    ifPresent: [ ^ self usage ]
]

{ #category : 'usage' }
ExampleScript >> usage [
	| dashes |
	dashes := '----------------------------------------------------
'.
  ^ dashes,
		(self manPageClass
          fromString:
'NAME
     exampleScript - example
SYNOPSIS
     exampleScript [-h|--help] [-p [<arg>] | --print[=<arg>]]
DESCRIPTION
EXAMPLES
     ./exampleScript --help
     ./exampleScript -h

     ./exampleScript --print=\`hi there\`
     ./exampleScript -p \`hi there\`

     ./exampleScript --print=hi
     ./exampleScript -p hi

     ./exampleScript --print
     ./exampleScript -p
') printString, dashes
]
