Class {
	#name : 'StashCommandGetOpts',
	#superclass : 'Object',
	#instVars : [
		'stream',
		'command',
		'options',
		'arguments'
	],
	#category : 'Stash-CommandLine'
}

{ #category : 'parsing' }
StashCommandGetOpts class >> getOptsFor: aStream spec: optionSpec do: optionBlock nonOptionsDo: nonOptionBlock [
  ^ self new
    stream: aStream;
    getOpts: optionSpec do: optionBlock nonOptionsDo: nonOptionBlock
]

{ #category : 'parsing' }
StashCommandGetOpts class >> getOptsLongFor: aStream longOptionSpec: longOptionSpec shortOptionAliases: shortOptionAliases do: optionBlock nonOptionsDo: nonOptionBlock [
  ^ self new
    stream: aStream;
    getOptsLong: longOptionSpec
      short: shortOptionAliases
      do: optionBlock
      nonOptionsDo: nonOptionBlock
]

{ #category : 'parsing' }
StashCommandGetOpts class >> parseCommand: aStream [
  ^ self new
    parseCommand: aStream;
    yourself
]

{ #category : 'private' }
StashCommandGetOpts >> _argQuoteCharacters [

	^ #( $` )
]

{ #category : 'accessing' }
StashCommandGetOpts >> command [
  ^ command
]

{ #category : 'error handling' }
StashCommandGetOpts >> error: aString [

	^ StashCommandError signal: aString
]

{ #category : 'parsing' }
StashCommandGetOpts >> getOpts: optionSpec do: optionBlock nonOptionsDo: nonOptionBlock [
  | optionSpecs |
  optionSpecs := self parseOptionSpec: optionSpec.
  self skipWhiteSpace.
  self
    parseOptions: optionSpecs
    expectDash: true
    do: optionBlock
    nonOptionsDo: nonOptionBlock.
  self parseNonOptionArgs: nonOptionBlock
]

{ #category : 'parsing' }
StashCommandGetOpts >> getOptsLong: optionSpecs do: optionBlock nonOptionsDo: nonOptionBlock [
  "optionSpecs is expected to be a dictionary whose keys are the option names and whose values are: #none, #required, or #optional; to indicate whether or not option arguments are expected"

  self
    getOptsLong: optionSpecs
    short: ''
    do: optionBlock
    nonOptionsDo: nonOptionBlock
]

{ #category : 'parsing' }
StashCommandGetOpts >> getOptsLong: optionSpecs short: shortOptionAliases do: optionBlock nonOptionsDo: nonOptionBlock [
  "optionSpecs is expected to be a dictionary whose keys are the option names and whose values are: #none, #required, or #optional; to indicate whether or not option arguments are expected"

  "shortOptionAliases is expected to be a dictionary whose keys are option characters and whose values are option names (i.e., keys into the optionSpecs dicationary)"

  self
    parseLongOptions: optionSpecs
    shortOptions: shortOptionAliases
    do: optionBlock
    nonOptionsDo: nonOptionBlock.
  self parseNonOptionArgs: nonOptionBlock
]

{ #category : 'parsing' }
StashCommandGetOpts >> getOptsMixedLongShort: mixedOptionSpecs do: optionBlock nonOptionsDo: nonOptionBlock [
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
  self
    getOptsLong: longOptionsSpec
    short: shortOptionAliases
    do: optionBlock
    nonOptionsDo: nonOptionBlock
]

{ #category : 'private' }
StashCommandGetOpts >> parseArgToken: tokenBlock [
  | peek tokenStream escaped atEndBlock |
  tokenStream := WriteStream on: String new.
  atEndBlock := [ 
  stream atEnd
    ifTrue: [ 
      tokenBlock value: tokenStream contents.
      ^ self ] ].
  self skipWhiteSpace.
  atEndBlock value.
  peek := stream peek.
  escaped := self _argQuoteCharacters includes: peek .
  escaped
    ifTrue: [ 
      stream next.
      atEndBlock value.
      peek := stream peek ].
  [ escaped or: [ peek isSeparator not ] ]
    whileTrue: [ 
      tokenStream nextPut: peek.
      stream next.
      atEndBlock value.
      peek := stream peek.
     (self _argQuoteCharacters includes: peek)
        ifTrue: [ 
          escaped := escaped not.
          stream next.
          atEndBlock value.
          peek := stream peek ] ].
  tokenBlock value: tokenStream contents
]

{ #category : 'private' }
StashCommandGetOpts >> parseCommand [
  | char cmdStream |
  stream atEnd
    ifTrue: [ ^ '' ].
  char := stream next.
  char isLetter
    ifFalse: [ ^ '' ].
  cmdStream := WriteStream on: String new.
  cmdStream nextPut: char.
  [ true ]
    whileTrue: [ 
      stream atEnd
        ifTrue: [ ^ cmdStream contents ].
      char := stream next.
      char isAlphaNumeric
        ifFalse: [ ^ cmdStream contents ].
      cmdStream nextPut: char ]
]

{ #category : 'parsing' }
StashCommandGetOpts >> parseCommand: aStream [
  stream := aStream.
  command := self parseCommand
]

{ #category : 'private' }
StashCommandGetOpts >> parseLongOptionArg: required for: opt [
  | emptyTokenBlock peek |
  emptyTokenBlock := [ 
  required
    ifTrue: [ self error: 'Missing required argument for option: ' , opt asString ]
    ifFalse: [ nil ] ].
  stream atEnd
    ifTrue: [ ^ emptyTokenBlock value ].
  peek := stream peek.
  peek == $=
    ifFalse: [ ^ emptyTokenBlock value ].
  stream next.
  stream atEnd
    ifTrue: [ ^ emptyTokenBlock value ].
  peek := stream peek.
  self
    parseArgToken: [ :token | 
      token isEmpty
        ifTrue: [ ^ emptyTokenBlock value ].
      ^ token ]
]

{ #category : 'private' }
StashCommandGetOpts >> parseLongOptionName [
  | peek endBlock optionNameStream |
  optionNameStream := WriteStream on: String new.
  endBlock := [ optionNameStream contents ].
  stream atEnd
    ifTrue: [ ^ endBlock value ].
  peek := stream peek.
  [ peek isSeparator or: [ peek == $= ] ]
    whileFalse: [ 
      stream next.
      optionNameStream nextPut: peek.
      stream atEnd
        ifTrue: [ ^ endBlock value ].
      peek := stream peek ].
  ^ endBlock value
]

{ #category : 'private' }
StashCommandGetOpts >> parseLongOptions: optionSpecs shortOptions: shortOptionAliases do: optionBlock nonOptionsDo: nonOptionBlock [
  | peek opt spec |
  self skipWhiteSpace.
  peek := stream peek.
  peek == $-
    ifFalse: [ 
      "no options"
      ^ self ].
  stream next.
  stream atEnd
    ifTrue: [ 
      nonOptionBlock cull: peek asString.
      ^ self ].
  peek := stream peek.
  peek == $-
    ifFalse: [ 
      | alias |
      "no second dash ... old-style option or???"
      shortOptionAliases isEmpty
        ifTrue: [ self error: 'Unexpected short option: ' , peek asString ].
      opt := stream next.
      self
        resolveAliasFor: opt
        optionSpecs: optionSpecs
        shortOptions: shortOptionAliases
        do: [ :aliasString :specSymbol | 
          alias := aliasString.
          spec := specSymbol ].
      spec == #'none'
        ifTrue: [ 
          optionBlock value: alias value: nil.
          stream atEnd
            ifTrue: [ ^ self ].
          peek := stream peek.
          [ peek isSeparator ]
            whileFalse: [ 
              stream next.
              self
                resolveAliasFor: peek
                optionSpecs: optionSpecs
                shortOptions: shortOptionAliases
                do: [ :aliasString :specSymbol | 
                  alias := aliasString.
                  spec := specSymbol.
                  spec == #'required'
                    ifTrue: [ self error: 'missing required option value: ' , alias asString ].
                  optionBlock value: alias value: nil.
                  stream atEnd
                    ifTrue: [ ^ self ].
                  peek := stream peek ] ].
          self skipWhiteSpace.
          ^ self
            parseLongOptions: optionSpecs
            shortOptions: shortOptionAliases
            do: optionBlock
            nonOptionsDo: nonOptionBlock ]
        ifFalse: [ 
          | optArg |
          optArg := self parseOptionArg: spec == #'required' for: opt.
          optionBlock value: alias value: optArg.
          stream atEnd
            ifTrue: [ ^ self ].
          ^ self
            parseLongOptions: optionSpecs
            shortOptions: shortOptionAliases
            do: optionBlock
            nonOptionsDo: nonOptionBlock ] ].
  stream next.
  stream atEnd
    ifTrue: [ 
      "hit naked, terminal -- done with options"
      ^ self ].
  peek := stream peek.
  peek isSeparator
    ifTrue: [ 
      "hit naked -- done with options"
      stream next.
      self skipWhiteSpace.
      ^ self ].
  opt := self parseLongOptionName.
  spec := optionSpecs
    at: opt
    ifAbsent: [ ^ self error: 'Unknown option: ' , opt asString ].
  spec == #'none'
    ifTrue: [ 
      optionBlock value: opt value: nil.
      stream atEnd
        ifTrue: [ ^ self ].
      peek := stream peek.
      peek isSeparator
        ifFalse: [ self error: 'Unexpected character' ].
      self skipWhiteSpace.
      ^ self
        parseLongOptions: optionSpecs
        shortOptions: shortOptionAliases
        do: optionBlock
        nonOptionsDo: nonOptionBlock ]
    ifFalse: [ 
      | optArg |
      optArg := self parseLongOptionArg: spec == #'required' for: opt.
      optionBlock value: opt value: optArg.
      stream atEnd
        ifTrue: [ ^ self ].
      ^ self
        parseLongOptions: optionSpecs
        shortOptions: shortOptionAliases
        do: optionBlock
        nonOptionsDo: nonOptionBlock ]
]

{ #category : 'private' }
StashCommandGetOpts >> parseNonOptionArgs: nonOptionArgsBlock [
  [ stream atEnd ]
    whileFalse: [ 
      self
        parseArgToken: [ :token | 
          token isEmpty
            ifFalse: [ nonOptionArgsBlock cull: token ] ] ]
]

{ #category : 'private' }
StashCommandGetOpts >> parseOptionArg: required for: opt [
  | emptyTokenBlock peek |
  emptyTokenBlock := [ 
  required
    ifTrue: [ self error: 'Missing required argument for option: ' , opt asString ]
    ifFalse: [ nil ] ].
  stream atEnd
    ifTrue: [ ^ emptyTokenBlock value ].
  peek := stream peek.
  peek isSeparator
    ifTrue: [ 
      self skipWhiteSpace.
      stream atEnd
        ifTrue: [ ^ emptyTokenBlock value ].
      peek := stream peek ]
    ifFalse: [ 
      required
        ifFalse: [ ^ nil ] ].
  peek == $-
    ifTrue: [ ^ emptyTokenBlock value ].
  self
    parseArgToken: [ :token | 
      token isEmpty
        ifTrue: [ ^ emptyTokenBlock value ].
      ^ token ]
]

{ #category : 'private' }
StashCommandGetOpts >> parseOptions: optionSpecs expectDash: expectDash do: optionBlock nonOptionsDo: nonOptionBlock [
  | peek opt spec |
  expectDash
    ifTrue: [ 
      peek := stream peek.
      peek == $-
        ifFalse: [ 
          "no options"
          ^ self ].
      stream next.
      stream atEnd
        ifTrue: [ 
          nonOptionBlock value: peek asString.
          ^ self ].
      opt := stream peek.
      opt == $-
        ifTrue: [ 
          "hit --"
          stream next.
          self skipWhiteSpace.
          ^ self ].
      stream next ]
    ifFalse: [ 
      opt := stream peek.
      opt == $-
        ifTrue: [ 
          stream next.
          stream peek == $-
            ifTrue: [ 
              stream next.
              ^ self ].
          self error: 'Unexpected --' ].
      stream next ].
  spec := optionSpecs
    at: opt
    ifAbsent: [ ^ self error: 'Unknown option: ' , opt asString ].
  spec == #'none'
    ifTrue: [ 
      | expectDashNow |
      optionBlock value: opt value: nil.
      stream atEnd
        ifTrue: [ ^ self ].
      expectDashNow := stream peek isSeparator.
      self skipWhiteSpace.
      self
        parseOptions: optionSpecs
        expectDash: expectDashNow
        do: optionBlock
        nonOptionsDo: nonOptionBlock ]
    ifFalse: [ 
      | optArg |
      optArg := self parseOptionArg: spec == #'required' for: opt.
      optionBlock value: opt value: optArg.
      stream atEnd
        ifTrue: [ ^ self ].
      self
        parseOptions: optionSpecs
        expectDash: stream peek isSeparator
        do: optionBlock
        nonOptionsDo: nonOptionBlock ]
]

{ #category : 'private' }
StashCommandGetOpts >> parseOptionSpec: optionSpec [
	"The optionSpec argument is a string that specifies the option characters that are valid for this program. An option character in this string can be followed by a colon (:) to indicate that it takes a required argument. If an option character is followed by two colons (::), its argument is optional; this is a GNU extension."

  | optionSpecs optStream |
  optionSpecs := Dictionary new.
  optStream := ReadStream on: optionSpec.
  [ optStream atEnd ]
    whileFalse: [ 
      | opt arg peek |
      opt := optStream next.
      peek := optStream peek.
      arg := #'none'.
      peek == $:
        ifTrue: [ 
          arg := #'required'.
          optStream next.
          optStream atEnd
            ifFalse: [ 
              peek := optStream peek.
              peek == $:
                ifTrue: [ 
                  arg := #'optional'.
                  optStream next ] ] ].
      optionSpecs at: opt put: arg ].
  ^ optionSpecs
]

{ #category : 'private' }
StashCommandGetOpts >> resolveAliasFor: optionCharacter optionSpecs: optionSpecs shortOptions: shortOptionAliases do: aBlock [
  | alias spec |
  alias := shortOptionAliases
    at: optionCharacter
    ifAbsent: [ ^ self error: 'Unknown option: ' , optionCharacter asString ].
  spec := optionSpecs
    at: alias
    ifAbsent: [ ^ self error: 'Unknown option: ' , alias ].
  aBlock value: alias value: spec
]

{ #category : 'private' }
StashCommandGetOpts >> skipWhiteSpace [
  | peekChar |
  stream atEnd
    ifTrue: [ ^ self ].
  peekChar := stream peek.
  [ peekChar isSeparator ]
    whileTrue: [ 
      stream next.
      stream atEnd
        ifTrue: [ ^ self ].
      peekChar := stream peek ].
  ^ self
]

{ #category : 'private' }
StashCommandGetOpts >> stream: aStream [
  stream := aStream
]
