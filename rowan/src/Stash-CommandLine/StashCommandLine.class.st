Class {
	#name : 'StashCommandLine',
	#superclass : 'Object',
	#instVars : [
		'commandLine',
		'redirectTarget',
		'tokens',
		'argPtrs',
		'hasSubCommand'
	],
	#category : 'Stash-CommandLine'
}

{ #category : 'instance creation' }
StashCommandLine class >> commandLine: commandLine redirectTarget: redirectTarget [
  ^ self new
    commandLine: commandLine;
    redirectTarget: redirectTarget;
    yourself
]

{ #category : 'parsing' }
StashCommandLine class >> fromStream: aStream forEachCommand: aBlock [
  "multi-line input"

  self fromStream: aStream selectLine: [:cmdLine | true] forEachCommand: aBlock
]

{ #category : 'parsing' }
StashCommandLine class >> fromStream: aStream selectLine: selectLineBlock forEachCommand: aBlock [
  "multi-line input"

  | cmdLines line escaped lastLine |
  cmdLines := OrderedCollection new.
  escaped := false.
  lastLine := ''.
  [ aStream atEnd ]
    whileFalse: [ 
      line := aStream nextLine.
      (line isNil or: [ line isEmpty ])
        ifFalse: [ 
          (line isEmpty not and: [ line last == $\ ])
            ifTrue: [ 
              escaped := true.
              lastLine := lastLine , (line copyFrom: 1 to: line size - 1) ]
            ifFalse: [ 
              escaped
                ifTrue: [ 
                  cmdLines add: lastLine , line.
                  escaped := false ]
                ifFalse: [ cmdLines add: line ] ] ] ].
  escaped
    ifTrue: [ cmdLines add: lastLine ].
  cmdLines
    do: [ :cmdLine | 
      (selectLineBlock value: cmdLine)
        ifTrue: [ self line: cmdLine forEachCommand: aBlock ] ]
]

{ #category : 'private' }
StashCommandLine class >> isolate: aString [
  | isolated command final escaped skipComment |
  isolated := OrderedCollection new.
  command := WriteStream on: String new.
  skipComment := escaped := false.
  aString
    do: [ :char | 
      skipComment
        ifFalse: [ 
          escaped
            ifTrue: [ 
              command nextPut: char.
              char = $`
                ifTrue: [ escaped := false ] ]
            ifFalse: [ 
              char == $;
                ifTrue: [ 
                  isolated add: command contents.
                  command := WriteStream on: String new ]
                ifFalse: [ 
                  char == $#
                    ifTrue: [ skipComment := true ]
                    ifFalse: [ command nextPut: char ] ].
              char = $`
                ifTrue: [ escaped := true ] ] ] ].
  final := command contents.
  final isEmpty
    ifFalse: [ isolated add: final ].
  ^ isolated
]

{ #category : 'parsing' }
StashCommandLine class >> line: cmdLineString forEachCommand: aBlock [
  "single command line"

  (self isolate: cmdLineString)
    do: [ :isolated | 
      | redirected commandLine redirectTarget command |
      redirected := self scan: isolated delim: $>.
      commandLine := redirected at: 1.
      redirectTarget := redirected size > 1
        ifTrue: [ (redirected at: 2) trimBoth ].
      command := self commandLine: commandLine redirectTarget: redirectTarget.
      aBlock value: command ]
]

{ #category : 'private' }
StashCommandLine class >> scan: aString delim: delim [
  | scanned command stream final escaped |
  scanned := OrderedCollection new.
  command := WriteStream on: String new.
  stream := ReadStream on: aString.
  escaped := false.
  [ stream atEnd ]
    whileFalse: [ 
      | char |
      char := stream next.
      escaped
        ifTrue: [ 
          char = $`
            ifTrue: [ escaped := false ].
          command nextPut: char ]
        ifFalse: [ 
          char == Character space
            ifTrue: [ 
              stream peek == delim
                ifTrue: [ 
                  scanned add: command contents.
                  command := WriteStream on: String new.
                  stream next.
                  command nextPut: stream next ]
                ifFalse: [ command nextPut: char ] ]
            ifFalse: [ 
              char = $`
                ifTrue: [ escaped := true ].
              command nextPut: char ] ] ].
  final := command contents.
  final isEmpty
    ifFalse: [ scanned add: final ].
  ^ scanned
]

{ #category : 'private' }
StashCommandLine >> argPtrs [
  self tokens.	"ensure argPtrs defined"
  ^ argPtrs
]

{ #category : 'accessing' }
StashCommandLine >> command [
  ^ self rawTokens at: 1
]

{ #category : 'private' }
StashCommandLine >> commandArgPtr [
  ^ self argPtrs at: 1
]

{ #category : 'accessing' }
StashCommandLine >> commandLine [
  ^ commandLine
]

{ #category : 'private' }
StashCommandLine >> commandLine: aString [
  commandLine := aString trimBoth
]

{ #category : 'error handling' }
StashCommandLine >> error: aString [

	^ StashCommandError signal: aString
]

{ #category : 'private' }
StashCommandLine >> getCommandLongOpts: optionSpec short: shortOptionAliases do: optionBlock argsDo: argBlock [
  | optionStream optionString |
  optionString := commandLine copyFrom: self commandArgPtr to: commandLine size.
  optionStream := ReadStream on: optionString.
  StashCommandGetOpts
    getOptsLongFor: optionStream
    longOptionSpec: optionSpec
    shortOptionAliases: shortOptionAliases
    do: optionBlock
    nonOptionsDo: argBlock
]

{ #category : 'private' }
StashCommandLine >> getCommandOpts: optionSpec do: optionBlock argsDo: argBlock [
  | optionStream optionString |
  optionString := commandLine copyFrom: self commandArgPtr to: commandLine size.
  optionStream := ReadStream on: optionString.
  StashCommandGetOpts
    getOptsFor: optionStream
    spec: optionSpec
    do: optionBlock
    nonOptionsDo: argBlock
]

{ #category : 'private' }
StashCommandLine >> getCommandOpts: optionSpec optionsAndArguments: optsAndArgsBlock [
  | options args |
  options := Dictionary new.
  args := OrderedCollection new.
  self
    getCommandOpts: optionSpec
    do: [ :option :optionArg | options at: option asString put: optionArg ]
    argsDo: [ :arg | args add: arg ].
  optsAndArgsBlock value: options value: args
]

{ #category : 'parsing' }
StashCommandLine >> getOpts: optionSpec optionsAndArguments: optsAndArgsBlock [
  | options args |
  options := Dictionary new.
  args := OrderedCollection new.
  self hasSubCommand
    ifTrue: [ 
      self
        getSubCommandOpts: optionSpec
        do: [ :option :optionArg | options at: option asString put: optionArg ]
        argsDo: [ :arg | args add: arg ] ]
    ifFalse: [ 
      self
        getCommandOpts: optionSpec
        do: [ :option :optionArg | options at: option asString put: optionArg ]
        argsDo: [ :arg | args add: arg ] ].
  ^ optsAndArgsBlock value: options value: args
]

{ #category : 'parsing' }
StashCommandLine >> getOpts: optionSpecs subOpts: subOptionSpecs optionsAndArguments: optsAndArgsBlock [
  | options arguments subCommandArgPtrIndex subCommandLine subCommand subOptions subArguments |
  self
    getOptsMixedLongShort: optionSpecs
    optionsAndArguments: [ :optionDictionary :argsIn | 
      options := optionDictionary.
      arguments := argsIn ].
  subCommandArgPtrIndex := self rawTokens size - arguments size.
  subCommandLine := self commandLine
    copyFrom: (self argPtrs at: subCommandArgPtrIndex)
    to: self commandLine size.
  self class
    line: subCommandLine
    forEachCommand: [ :aCommand | 
      subCommand := aCommand.
      subCommand
        getOptsMixedLongShort: subOptionSpecs
        optionsAndArguments: [ :optionDictionary :argsIn | 
          subOptions := optionDictionary.
          subArguments := argsIn ] ].
  ^ optsAndArgsBlock
    value: options
    value: arguments
    value: subCommand command
    value: subOptions
    value: subArguments
]

{ #category : 'parsing' }
StashCommandLine >> getOptsLong: longOptionSpec optionsAndArguments: optsAndArgsBlock [
  ^ self
    getOptsLong: longOptionSpec
    short: Dictionary new
    optionsAndArguments: optsAndArgsBlock
]

{ #category : 'parsing' }
StashCommandLine >> getOptsLong: longOptionSpec short: shortOptionAliases optionsAndArguments: optsAndArgsBlock [
  | options args |
  options := Dictionary new.
  args := OrderedCollection new.
  self hasSubCommand
    ifTrue: [ 
      self
        getSubCommandLongOpts: longOptionSpec
        short: shortOptionAliases
        do: [ :option :optionArg | options at: option asString put: optionArg ]
        argsDo: [ :arg | args add: arg ] ]
    ifFalse: [ 
      self
        getCommandLongOpts: longOptionSpec
        short: shortOptionAliases
        do: [ :option :optionArg | options at: option asString put: optionArg ]
        argsDo: [ :arg | args add: arg ] ].
  ^ optsAndArgsBlock value: options value: args
]

{ #category : 'parsing' }
StashCommandLine >> getOptsMixedLongShort: mixedOptionSpecs optionsAndArguments: optsAndArgsBlock [
  "mixedOptionSpecs is an array of option specs, for example:

    {#('directory' $d #'required').
      #('class' nil #'none').
      #('package' nil #'none').
      #('category' nil #'required')}

   each subarray consists of the long-option-name, short-option-character, 
     [required|none|optional]
"

  | longOptionsSpec shortOptionAliases |
  longOptionsSpec := Dictionary new.
  shortOptionAliases := Dictionary new.
  mixedOptionSpecs
    do: [ :spec | 
      | optionName shortOptionCharacter optionValueSpec |
      optionName := spec at: 1.
      shortOptionCharacter := spec at: 2.
      optionValueSpec := spec at: 3.
      longOptionsSpec at: optionName put: optionValueSpec.
      shortOptionCharacter
        ifNotNil: [ shortOptionAliases at: shortOptionCharacter put: optionName ] ].
  ^ self
    getOptsLong: longOptionsSpec
    short: shortOptionAliases
    optionsAndArguments: optsAndArgsBlock
]

{ #category : 'obsolete' }
StashCommandLine >> getSubCommandLongOpts: optionSpec short: shortOptionAliases do: optionBlock argsDo: argBlock [
  | optionStream optionString |
  optionString := commandLine
    copyFrom: self subCommandArgPtr
    to: commandLine size.
  optionStream := ReadStream on: optionString.
  StashCommandGetOpts
    getOptsLongFor: optionStream
    longOptionSpec: optionSpec
    shortOptionAliases: shortOptionAliases
    do: optionBlock
    nonOptionsDo: argBlock
]

{ #category : 'obsolete' }
StashCommandLine >> getSubCommandOpts: optionSpec do: optionBlock argsDo: argBlock [
  | optionStream optionString |
  optionString := commandLine
    copyFrom: self subCommandArgPtr
    to: commandLine size.
  optionStream := ReadStream on: optionString.
  StashCommandGetOpts
    getOptsFor: optionStream
    spec: optionSpec
    do: optionBlock
    nonOptionsDo: argBlock
]

{ #category : 'obsolete' }
StashCommandLine >> getSubCommandOpts: optionSpec optionsAndArguments: optsAndArgsBlock [
  | options args |
  options := Dictionary new.
  args := OrderedCollection new.
  self
    getSubCommandOpts: optionSpec
    do: [ :option :optionArg | options at: option asString put: optionArg ]
    argsDo: [ :arg | args add: arg ].
  optsAndArgsBlock value: options value: args
]

{ #category : 'obsolete' }
StashCommandLine >> hasSubCommand [
  hasSubCommand ifNil: [ hasSubCommand := false ].
  ^ hasSubCommand
]

{ #category : 'obsolete' }
StashCommandLine >> hasSubCommand: aBool [
  hasSubCommand := aBool
]

{ #category : 'private' }
StashCommandLine >> parseMixedLongShortOpts: mixedOptionSpecs [
  "mixedOptionSpecs is an array of option specs, for example:

    {#('directory' $d #'required').
      #('class' nil #'none').
      #('package' nil #'none').
      #('category' nil #'required')}

   each subarray consists of the long-option-name, short-option-character, 
     [required|none|optional]
"

  | longOptionsSpec shortOptionAliases |
  longOptionsSpec := Dictionary new.
  shortOptionAliases := Dictionary new.
  mixedOptionSpecs
    do: [ :spec | 
      | optionName shortOptionCharacter optionValueSpec |
      optionName := spec at: 1.
      shortOptionCharacter := spec at: 2.
      optionValueSpec := spec at: 3.
      longOptionsSpec at: optionName put: optionValueSpec.
      shortOptionCharacter
        ifNotNil: [ shortOptionAliases at: shortOptionCharacter put: optionName ] ].
  ^ {longOptionsSpec.
  shortOptionAliases}
]

{ #category : 'printing' }
StashCommandLine >> printOn: aStream [
	aStream nextPutAll: self class name asString , '(' , self commandLine printString , ')'
]

{ #category : 'private' }
StashCommandLine >> rawTokens [
  tokens ifNil: [ tokens := self tokenize: self commandLine ].
  ^ tokens
]

{ #category : 'accessing' }
StashCommandLine >> redirectTarget [
  ^ redirectTarget
]

{ #category : 'private' }
StashCommandLine >> redirectTarget: aString [
  redirectTarget := aString
]

{ #category : 'accessing' }
StashCommandLine >> subCommand [
  self rawTokens size < 2
    ifTrue: [ self error: 'expected a subcommand' ].
  ^ self rawTokens at: 2
]

{ #category : 'obsolete' }
StashCommandLine >> subCommandArgPtr [
  ^ self argPtrs at: 2
]

{ #category : 'private' }
StashCommandLine >> tokenize: aString [
  | list token final escaped delimited stream count |
  list := OrderedCollection new.
  argPtrs := OrderedCollection new.
  token := WriteStream on: String new.
  escaped := false.
  delimited := false.
  stream := ReadStream on: aString.
  count := 0.
  [ stream atEnd ]
    whileFalse: [ 
      | char |
      char := stream next.
      count := count + 1.
      escaped
        ifTrue: [ 
          char = $`
            ifTrue: [ escaped := false ]
            ifFalse: [ token nextPut: char ] ]
        ifFalse: [ 
          char == Character space
            ifTrue: [ 
              delimited
                ifFalse: [ 
                  list add: token contents.
                  argPtrs add: count.
                  token := WriteStream on: String new ].
              delimited := true ]
            ifFalse: [ 
              delimited := false.
              char = $`
                ifTrue: [ escaped := true ]
                ifFalse: [ token nextPut: char ] ] ] ].
  final := token contents.
  final isEmpty
    ifFalse: [ 
      list add: final.
      argPtrs add: count + 1 ].
  ^ list
]

{ #category : 'parsing' }
StashCommandLine >> tokens [
  ^ self hasSubCommand
    ifTrue: [ 
      self rawTokens.
      tokens copyFrom: 2 to: tokens size ]
    ifFalse: [ self rawTokens ]
]

{ #category : 'private' }
StashCommandLine >> tokens: aCollection [
  tokens := aCollection
]
