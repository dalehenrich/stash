#!/usr/bin/gemstone/smalltalk
"
	Write `hello world` to stdout and exit.
"
Class {
     #name : 'HelloWorldScript',
     #superclass : 'StashScript',
     #category : 'Stash-Scripts'
}

{ #category : 'script execution' }
 HelloWorldScript>> executeScript [

	opts
		at: 'help'
    ifAbsent: [
			GsFile stdout nextPutAll: 'Hello world'; lf  ] 
    ifPresent: [ ^ self usage ]
]

{ #category : 'usage' }
 HelloWorldScript>> usage [
	self usage: 'hello.st'
]
