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
	TEMPLATE - example script, than can be used as a template to create your own script
SYNOPSIS
	TEMPLATE.st [-h|--help] [ -- <startTopaz-specific-options> ]
DESCRIPTION

	This TEMPLATE is set up with help (--help).

	Use the env var GEMSTONE_SCRIPT_ARGS to define default <stone-name> and other
	topaz arguments (<startTopaz-specific-options>) to be used when running scripts.

EXAMPLES
	TEMPLATE.st --help
	TEMPLATE.st -h
') printString, dashes
]
