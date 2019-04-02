#!/home/dhenrich/rogue/_homes/rogue/_home/shared/repos/stash/bin/stash_interpretter
"
Example executable script
"
Class {
     #name : 'ExampleScript',
     #superclass : 'Script',
     #category : 'Examples'
}

{ #category : 'installing' }
ExampleScript class >> doInstall: projectName [

     "do what it takes to install the named project"
]

{ #category : 'launching' }
ExampleScript class >> launch: launcher command: command [
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
          ifPresent: [ self usage: launcher ]
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
