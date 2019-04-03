#!/usr/bin/smalltalk
"
Example executable script
"
Class {
     #name : 'ExampleScript',
     #superclass : 'StashScript',
     #category : 'Examples'
}

{ #category : 'launching' }
ExampleScript class >> executeCommand: command [
     | opts args projectName |
     "for help: ./configSpec -h"
     command
          getOptsMixedLongShort: {
               #('help' $h #'none').
               #('install' nil #'none').
               }
          optionsAndArguments: [ :options :operands |
          opts := options.
          args := operands ].
     projectName := args at: 1.
     opts
          at: 'help'
          ifPresent: [ self usage ]
          ifAbsent: [
               opts at: 'install' ifPresent: [:installArg |
                    self doInstall: projectName ].
               "do things with projectName"]
]

{ #category : 'usage' }
ExampleScript class >> usage: launcher [
     self manPageClass
          viewManPage:
'NAME
     exampleScript - example
SYNOPSIS
     exampleScript [-h|--help] [--install] <project-name>
DESCRIPTION
EXAMPLES
     ./exampleScript --help
     ./exampleScript -h

     ./exampleScript --install

     ./exampleScript --install ExampleProject
'
          launcher: launcher
]
