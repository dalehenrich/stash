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
ExampleScript >> executeCommand: command [
     | opts args |
     command
          getOptsMixedLongShort: {
               #('help' $h #'none').
               #('print' $p #'optional').
               }
          optionsAndArguments: [ :options :operands |
          opts := options.
          args := operands ].
     opts
          at: 'help'
          ifPresent: [ self usage ]
          ifAbsent: [
               opts at: 'print' ifPresent: [:optionalArg |
                    GsFile gciLogServer: optionalArg printString ].
          ].
			^ '--example script executed--'
]

{ #category : 'usage' }
ExampleScript >> usage: script [
     self manPageClass
          viewManPage:
'NAME
     exampleScript - example
SYNOPSIS
     exampleScript [-h|--help] [-p string |--print=<string]
DESCRIPTION
EXAMPLES
     ./exampleScript --help
     ./exampleScript -h

     ./exampleScript --print="hi there"
     ./exampleScript -p "hi there"

     ./exampleScript --print
     ./exampleScript -p
'
          script: script
]
