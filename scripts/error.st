#!/usr/bin/gsdevkit/smalltalk_350
"
	Bring up topaz debugger when a script error is encountered
"
Class {
     #name : 'ErrorExampleScript',
     #superclass : 'StashScript',
     #category : 'Stash-Scripts'
}

{ #category : 'script execution' }
 ErrorExampleScript>> scriptOptions [
	^ {
			#('help' $h #'none').
			#('boom' nil #'none').
	}
]

{ #category : 'script execution' }
 ErrorExampleScript>> executeScript [

	opts
		at: 'help'
    ifAbsent: [
			opts at: 'boom' ifPresent: [ self halt ].
			GsFile stdout nextPutAll: 'No error today'; lf  ] 
    ifPresent: [ ^ self usage ]
]

{ #category : 'usage' }
 ErrorExampleScript>> usage [
	| dashes |
	dashes := '----------------------------------------------------
'.
  GsFile stdout nextPutAll: dashes,
		(self manPageClass
          fromString:
'NAME
	error.st - bring up topaz debugger on error

SYNOPSIS
  error.st [ --boom ] 

DESCRIPTION
  --boom
		signal error and bring up topaz debugger.

	With no options, the script exits somewhat quietly.

EXAMPLES
	error.st --help

	error.st
 	error.st --boom

') printString, dashes
]
