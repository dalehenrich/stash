#!/usr/local/bin/smalltalk/gemstone/stash
"
	Write `Hello World` to stdout and exit.
"
Class {
	#name : 'StashHelloWorldScript',
	#superclass : 'StashScript',
	#category : 'Stash-Scripts'
}

{ #category : 'script execution' }
StashHelloWorldScript >> executeScript [

	opts at: 'help' ifPresent: [ ^ self usage ].
	GsFile stdout nextPutAll: 'Hello World'; lf
]

{ #category : 'usage' }
StashHelloWorldScript >> usage [

	^ self usage: 'hello.st' description: 'Write `hello world` to stdout and exit.'
]
