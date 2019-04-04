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
			| stream |
			stream := WriteStreamPortable on: String new.
			args size > 0
				ifTrue: [
					stream nextPutAll: '|args| '.
					args do: [:arg | stream nextPutAll: arg; space ] ]
				ifFalse: [ stream nextPutAll: 'no args ' ].
			opts at: 'print' 
				ifPresent: [:optionalArg |
					stream nextPutAll: ' |print| ', optionalArg asString ]
				ifAbsent: [ stream nextPutAll: ' || no --print ' ].
			^ stream contents ]
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
	sample - example script
SYNOPSIS
	sample [-h|--help] [-p [<arg>] | --print[=<arg>]] [ <positional-args> ]\
		[ -- <topaz-specific-options> ]
DESCRIPTION

	This example script shows how to define command options and positional arguments.

	Use the env var GEMSTONE_SCRIPT_ARGS to define default <stone-name> and other
	topaz arguments (<startTopaz-specific-options>) to be used when running scripts.

EXAMPLES
	sample.st --help
	sample.st -h

	sample.st --print=\`hi there\`
	sample.st -p \`hi there\` arg1

	sample.st --print=hi arg1 arg2
	sample.st -p hi

	sample.st --print
	sample.st -p

	sample.st arg1 arg2 arg3
') printString, dashes
]
