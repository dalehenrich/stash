Class {
	#name : 'StashCommandGetOptsTestCase',
	#superclass : 'TestCase',
	#category : 'Stash-CommandLine-Tests'
}

{ #category : 'tests' }
StashCommandGetOptsTestCase >> longOptionSpec [
  ^ Dictionary new
    at: 'argA' put: #'none';
    at: 'argB' put: #'none';
    at: 'argC' put: #'required';
    yourself
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> shortOptionAliases [
  ^ Dictionary new
    at: $a put: 'argA';
    at: $b put: 'argB';
    at: $c put: 'argC';
    yourself
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> test01 [
  | parser |
  parser := StashCommandGetOpts parseCommand: (ReadStream on: 'testopt').
  self assert: parser command = 'testopt'.
  parser
    getOpts: 'abc:'
    do: [ :opt :optArg | self assert: false ]
    nonOptionsDo: [ :nonOption | self assert: false ]
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> test02 [
  | parser options processedOption |
  options := Dictionary new
    add: $a -> nil;
    add: $b -> nil;
    yourself.
  parser := StashCommandGetOpts parseCommand: (ReadStream on: 'testopt -a -b').
  self assert: parser command = 'testopt'.
  processedOption := false.
  parser
    getOpts: 'abc:'
    do: [ :opt :optArg | 
      processedOption := true.
      self assert: (options at: opt) = optArg ]
    nonOptionsDo: [ :nonOption | self assert: false ].
  self assert: processedOption
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> test03 [
  | parser options processedOption |
  options := Dictionary new
    add: $a -> nil;
    add: $b -> nil;
    yourself.
  parser := StashCommandGetOpts parseCommand: (ReadStream on: 'testopt -ab').
  self assert: parser command = 'testopt'.
  processedOption := false.
  parser
    getOpts: 'abc:'
    do: [ :opt :optArg | 
      processedOption := true.
      self assert: (options at: opt) = optArg ]
    nonOptionsDo: [ :nonOption | self assert: false ].
  self assert: processedOption
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> test04 [
  | parser options processedOption |
  options := Dictionary new
    add: $a -> nil;
    add: $b -> nil;
    yourself.
  parser := StashCommandGetOpts parseCommand: (ReadStream on: 'testopt -ba').
  self assert: parser command = 'testopt'.
  processedOption := false.
  parser
    getOpts: 'abc:'
    do: [ :opt :optArg | 
      processedOption := true.
      self assert: (options at: opt) = optArg ]
    nonOptionsDo: [ :nonOption | self assert: false ].
  self assert: processedOption
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> test05 [
  | parser options processedOption |
  options := Dictionary new
    add: $c -> 'foo';
    yourself.
  parser := StashCommandGetOpts parseCommand: (ReadStream on: 'testopt -c foo').
  self assert: parser command = 'testopt'.
  processedOption := false.
  parser
    getOpts: 'abc:'
    do: [ :opt :optArg | 
      processedOption := true.
      self assert: (options at: opt) = optArg ]
    nonOptionsDo: [ :nonOption | self assert: false ].
  self assert: processedOption
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> test06 [
  | parser options processedOption |
  options := Dictionary new
    add: $c -> 'foo';
    yourself.
  parser := StashCommandGetOpts parseCommand: (ReadStream on: 'testopt -cfoo').
  self assert: parser command = 'testopt'.
  processedOption := false.
  parser
    getOpts: 'abc:'
    do: [ :opt :optArg | 
      processedOption := true.
      self assert: (options at: opt) = optArg ]
    nonOptionsDo: [ :nonOption | self assert: false ].
  self assert: processedOption
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> test07 [
  | parser processedNonOption |
  parser := StashCommandGetOpts parseCommand: (ReadStream on: 'testopt arg1').
  self assert: parser command = 'testopt'.
  processedNonOption := false.
  parser
    getOpts: 'abc:'
    do: [ :opt :optArg | self assert: false ]
    nonOptionsDo: [ :nonOption | 
      processedNonOption := true.
      self assert: nonOption = 'arg1' ].
  self assert: processedNonOption
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> test08 [
  | parser options processedOption processNonOption |
  options := Dictionary new
    add: $a -> nil;
    yourself.
  parser := StashCommandGetOpts parseCommand: (ReadStream on: 'testopt -a arg1').
  self assert: parser command = 'testopt'.
  processNonOption := processedOption := false.
  parser
    getOpts: 'abc:'
    do: [ :opt :optArg | 
      processedOption := true.
      self assert: (options at: opt) = optArg ]
    nonOptionsDo: [ :nonOption | 
      processNonOption := true.
      self assert: nonOption = 'arg1' ].
  self assert: processedOption.
  self assert: processNonOption
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> test09 [
  | parser options processedOption processNonOption |
  options := Dictionary new
    add: $c -> 'foo';
    yourself.
  parser := StashCommandGetOpts
    parseCommand: (ReadStream on: 'testopt -c foo arg1').
  self assert: parser command = 'testopt'.
  processNonOption := processedOption := false.
  parser
    getOpts: 'abc:'
    do: [ :opt :optArg | 
      processedOption := true.
      self assert: (options at: opt) = optArg ]
    nonOptionsDo: [ :nonOption | 
      processNonOption := true.
      self assert: nonOption = 'arg1' ].
  self assert: processedOption.
  self assert: processNonOption
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> test10 [
  | parser options processedOption processNonOption |
  options := Dictionary new
    add: $a -> nil;
    yourself.
  parser := StashCommandGetOpts parseCommand: (ReadStream on: 'testopt -a -- -b').
  self assert: parser command = 'testopt'.
  processNonOption := processedOption := false.
  parser
    getOpts: 'abc:'
    do: [ :opt :optArg | 
      processedOption := true.
      self assert: (options at: opt) = optArg ]
    nonOptionsDo: [ :nonOption | 
      processNonOption := true.
      self assert: nonOption = '-b' ].
  self assert: processedOption.
  self assert: processNonOption
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> test11 [
  | parser options processedOption processNonOption |
  options := Dictionary new
    add: $a -> nil;
    yourself.
  parser := StashCommandGetOpts parseCommand: (ReadStream on: 'testopt -a -').
  self assert: parser command = 'testopt'.
  processNonOption := processedOption := false.
  parser
    getOpts: 'abc:'
    do: [ :opt :optArg | 
      processedOption := true.
      self assert: (options at: opt) = optArg ]
    nonOptionsDo: [ :nonOption | 
      processNonOption := true.
      self assert: nonOption = '-' ].
  self assert: processedOption.
  self assert: processNonOption
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> test15 [
  | parser options processedOption processNonOption |
  options := Dictionary new
    add: $c -> 'foo -d xxx';
    yourself.
  parser := StashCommandGetOpts
    parseCommand:
      (ReadStream on: 'testopt -c `foo -d xxx` arg1 `arg2 and -e friends`').
  self assert: parser command = 'testopt'.
  processNonOption := processedOption := false.
  parser
    getOpts: 'abc:'
    do: [ :opt :optArg | 
      processedOption := true.
      self assert: (options at: opt) = optArg ]
    nonOptionsDo: [ :nonOption | 
      processNonOption := true.
      self
        assert: (nonOption = 'arg1' or: [ nonOption = 'arg2 and -e friends' ]) ].
  self assert: processedOption.
  self assert: processNonOption
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> testLong01 [
  | parser |
  parser := StashCommandGetOpts parseCommand: (ReadStream on: 'testopt').
  self assert: parser command = 'testopt'.
  parser
    getOptsLong: self longOptionSpec
    do: [ :opt :optArg | self assert: false ]
    nonOptionsDo: [ :nonOption | self assert: false ]
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> testLong02 [
  | parser options processedOption |
  options := Dictionary new
    add: 'argA' -> nil;
    add: 'argB' -> nil;
    yourself.
  parser := StashCommandGetOpts
    parseCommand: (ReadStream on: 'testopt --argA --argB').
  self assert: parser command = 'testopt'.
  processedOption := false.
  parser
    getOptsLong: self longOptionSpec
    do: [ :opt :optArg | 
      processedOption := true.
      self assert: (options at: opt) = optArg ]
    nonOptionsDo: [ :nonOption | self assert: false ].
  self assert: processedOption
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> testLong05 [
  | parser options processedOption |
  options := Dictionary new
    add: 'argC' -> 'foo';
    yourself.
  parser := StashCommandGetOpts parseCommand: (ReadStream on: 'testopt --argC=foo').
  self assert: parser command = 'testopt'.
  processedOption := false.
  parser
    getOptsLong: self longOptionSpec
    do: [ :opt :optArg | 
      processedOption := true.
      self assert: (options at: opt) = optArg ]
    nonOptionsDo: [ :nonOption | self assert: false ].
  self assert: processedOption
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> testLong07 [
  | parser processedNonOption |
  parser := StashCommandGetOpts parseCommand: (ReadStream on: 'testopt arg1').
  self assert: parser command = 'testopt'.
  processedNonOption := false.
  parser
    getOptsLong: self longOptionSpec
    do: [ :opt :optArg | self assert: false ]
    nonOptionsDo: [ :nonOption | 
      processedNonOption := true.
      self assert: nonOption = 'arg1' ].
  self assert: processedNonOption
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> testLong08 [
  | parser options processedOption processNonOption |
  options := Dictionary new
    add: 'argA' -> nil;
    yourself.
  parser := StashCommandGetOpts
    parseCommand: (ReadStream on: 'testopt --argA arg1').
  self assert: parser command = 'testopt'.
  processNonOption := processedOption := false.
  parser
    getOptsLong: self longOptionSpec
    do: [ :opt :optArg | 
      processedOption := true.
      self assert: (options at: opt) = optArg ]
    nonOptionsDo: [ :nonOption | 
      processNonOption := true.
      self assert: nonOption = 'arg1' ].
  self assert: processedOption.
  self assert: processNonOption
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> testLong09 [
  | parser options processedOption processNonOption |
  options := Dictionary new
    add: 'argC' -> 'foo';
    yourself.
  parser := StashCommandGetOpts
    parseCommand: (ReadStream on: 'testopt --argC=foo arg1').
  self assert: parser command = 'testopt'.
  processNonOption := processedOption := false.
  parser
    getOptsLong: self longOptionSpec
    do: [ :opt :optArg | 
      processedOption := true.
      self assert: (options at: opt) = optArg ]
    nonOptionsDo: [ :nonOption | 
      processNonOption := true.
      self assert: nonOption = 'arg1' ].
  self assert: processedOption.
  self assert: processNonOption
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> testLong10 [
  | parser options processedOption processNonOption |
  options := Dictionary new
    add: 'argA' -> nil;
    yourself.
  parser := StashCommandGetOpts
    parseCommand: (ReadStream on: 'testopt --argA -- --argB').
  self assert: parser command = 'testopt'.
  processNonOption := processedOption := false.
  parser
    getOptsLong: self longOptionSpec
    do: [ :opt :optArg | 
      processedOption := true.
      self assert: (options at: opt) = optArg ]
    nonOptionsDo: [ :nonOption | 
      processNonOption := true.
      self assert: nonOption = '--argB' ].
  self assert: processedOption.
  self assert: processNonOption
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> testLong11 [
  | parser options processedOption processNonOption |
  options := Dictionary new
    add: 'argA' -> nil;
    yourself.
  parser := StashCommandGetOpts parseCommand: (ReadStream on: 'testopt --argA -').
  self assert: parser command = 'testopt'.
  processNonOption := processedOption := false.
  parser
    getOptsLong: self longOptionSpec
    do: [ :opt :optArg | 
      processedOption := true.
      self assert: (options at: opt) = optArg ]
    nonOptionsDo: [ :nonOption | 
      processNonOption := true.
      self assert: nonOption = '-' ].
  self assert: processedOption.
  self assert: processNonOption
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> testLong14 [
  | parser options processedOption processNonOption |
  options := Dictionary new
    add: 'argC' -> 'foo';
    yourself.
  parser := StashCommandGetOpts
    parseCommand: (ReadStream on: 'testopt --argC=foo arg1 arg2').
  self assert: parser command = 'testopt'.
  processNonOption := processedOption := false.
  parser
    getOptsLong: self longOptionSpec
    do: [ :opt :optArg | 
      processedOption := true.
      self assert: (options at: opt) = optArg ]
    nonOptionsDo: [ :nonOption | 
      processNonOption := true.
      self assert: (nonOption = 'arg1' or: [ nonOption = 'arg2' ]) ].
  self assert: processedOption.
  self assert: processNonOption
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> testLong15 [
  | parser options processedOption processNonOption |
  options := Dictionary new
    add: 'argC' -> 'foo -d xxx';
    yourself.
  parser := StashCommandGetOpts
    parseCommand:
      (ReadStream on: 'testopt --argC=`foo -d xxx` arg1 `arg2 and -e friends`').
  self assert: parser command = 'testopt'.
  processNonOption := processedOption := false.
  parser
    getOptsLong: self longOptionSpec
    do: [ :opt :optArg | 
      processedOption := true.
      self assert: (options at: opt) = optArg ]
    nonOptionsDo: [ :nonOption | 
      processNonOption := true.
      self
        assert: (nonOption = 'arg1' or: [ nonOption = 'arg2 and -e friends' ]) ].
  self assert: processedOption.
  self assert: processNonOption
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> testLong21 [
  | parser options processedOption processNonOption parsedOptions optionsSpec |
  options := Dictionary new
    add: 'directory' -> '/tmp/fileout';
    add: 'category' -> nil;
    yourself.
  parser := StashCommandGetOpts
    parseCommand:
      (ReadStream
        on:
          'fileout --directory=/tmp/fileout --category Index-Tests indexTests.gs').
  self assert: parser command = 'fileout'.
  processNonOption := processedOption := false.
  parsedOptions := Dictionary new.
  optionsSpec := Dictionary new
    at: 'directory' put: #'required';
    at: 'class' put: #'none';
    at: 'package' put: #'none';
    at: 'category' put: #'none';
    yourself.
  parser
    getOptsLong: optionsSpec
    do: [ :opt :optArg | 
      processedOption := true.
      parsedOptions at: opt put: optArg ]
    nonOptionsDo: [ :nonOption | 
      processNonOption := true.
      nonOption = 'Index-Tests' or: [ nonOption = 'indexTests.gs' ] ].
  options
    keysAndValuesDo: [ :key :value | self assert: (parsedOptions at: key) = (options at: key) ].
  self assert: processedOption.
  self assert: processNonOption
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> testMixed02 [
  | parser options processedOption |
  options := Dictionary new
    add: 'argA' -> nil;
    add: 'argB' -> nil;
    yourself.
  parser := StashCommandGetOpts parseCommand: (ReadStream on: 'testopt --argA -b').
  self assert: parser command = 'testopt'.
  processedOption := false.
  parser
    getOptsLong: self longOptionSpec
    short: self shortOptionAliases
    do: [ :opt :optArg | 
      processedOption := true.
      self assert: (options at: opt) = optArg ]
    nonOptionsDo: [ :nonOption | self assert: false ].
  self assert: processedOption
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> testMixed12 [
  | parser options processedOption processNonOption |
  options := Dictionary new
    add: 'argA' -> nil;
    add: 'argB' -> nil;
    add: 'argC' -> 'foo';
    yourself.
  parser := StashCommandGetOpts
    parseCommand: (ReadStream on: 'testopt --argA -b -c foo arg1').
  self assert: parser command = 'testopt'.
  processNonOption := processedOption := false.
  parser
    getOptsLong: self longOptionSpec
    short: self shortOptionAliases
    do: [ :opt :optArg | 
      processedOption := true.
      self assert: (options at: opt) = optArg ]
    nonOptionsDo: [ :nonOption | 
      processNonOption := true.
      self assert: nonOption = 'arg1' ].
  self assert: processedOption.
  self assert: processNonOption
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> testMixed13 [
  | parser options processedOption processNonOption |
  options := Dictionary new
    add: 'argA' -> nil;
    add: 'argB' -> nil;
    add: 'argC' -> 'foo';
    yourself.
  parser := StashCommandGetOpts
    parseCommand: (ReadStream on: 'testopt -a --argB --argC=foo arg1').
  self assert: parser command = 'testopt'.
  processNonOption := processedOption := false.
  parser
    getOptsLong: self longOptionSpec
    short: self shortOptionAliases
    do: [ :opt :optArg | 
      processedOption := true.
      self assert: (options at: opt) = optArg ]
    nonOptionsDo: [ :nonOption | 
      processNonOption := true.
      self assert: nonOption = 'arg1' ].
  self assert: processedOption.
  self assert: processNonOption
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> testMixed14 [
  | parser options processedOption processNonOption |
  options := Dictionary new
    add: 'argA' -> nil;
    add: 'argB' -> nil;
    add: 'argC' -> 'foo';
    yourself.
  parser := StashCommandGetOpts
    parseCommand: (ReadStream on: 'testopt -a --argB --argC=foo arg1 arg2').
  self assert: parser command = 'testopt'.
  processNonOption := processedOption := false.
  parser
    getOptsLong: self longOptionSpec
    short: self shortOptionAliases
    do: [ :opt :optArg | 
      processedOption := true.
      self assert: (options at: opt) = optArg ]
    nonOptionsDo: [ :nonOption | 
      processNonOption := true.
      nonOption = 'arg1' or: [ nonOption = 'arg2' ] ].
  self assert: processedOption.
  self assert: processNonOption
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> testMixed15 [
  | parser options processedOption processNonOption |
  options := Dictionary new
    add: 'argA' -> nil;
    add: 'argB' -> nil;
    add: 'argC' -> 'foo -d xxx';
    yourself.
  parser := StashCommandGetOpts
    parseCommand:
      (ReadStream
        on: 'testopt -a --argB --argC=`foo -d xxx` arg1 `arg2 and -e friends`').
  self assert: parser command = 'testopt'.
  processNonOption := processedOption := false.
  parser
    getOptsLong: self longOptionSpec
    short: self shortOptionAliases
    do: [ :opt :optArg | 
      processedOption := true.
      self assert: (options at: opt) = optArg ]
    nonOptionsDo: [ :nonOption | 
      processNonOption := true.
      nonOption = 'arg1' or: [ nonOption = 'arg2 and -e friends' ] ].
  self assert: processedOption.
  self assert: processNonOption
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> testMixed16 [
  | parser options processedOption processNonOption |
  options := Dictionary new
    add: 'argA' -> nil;
    add: 'argB' -> nil;
    add: 'argC' -> 'foo -d xxx';
    yourself.
  parser := StashCommandGetOpts
    parseCommand:
      (ReadStream on: 'testopt -a --argB -c `foo -d xxx` arg1 `arg2 and -e friends`').
  self assert: parser command = 'testopt'.
  processNonOption := processedOption := false.
  parser
    getOptsLong: self longOptionSpec
    short: self shortOptionAliases
    do: [ :opt :optArg | 
      processedOption := true.
      self assert: (options at: opt) = optArg ]
    nonOptionsDo: [ :nonOption | 
      processNonOption := true.
      nonOption = 'arg1' or: [ nonOption = 'arg2 and -e friends' ] ].
  self assert: processedOption.
  self assert: processNonOption
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> testMixed17 [
  | parser options processedOption processNonOption |
  options := Dictionary new
    add: 'argA' -> nil;
    add: 'argB' -> nil;
    add: 'argC' -> 'foo -d xxx';
    yourself.
  parser := StashCommandGetOpts
    parseCommand:
      (ReadStream on: 'testopt -a --argB -c`foo -d xxx` arg1 `arg2 and -e friends`').
  self assert: parser command = 'testopt'.
  processNonOption := processedOption := false.
  parser
    getOptsLong: self longOptionSpec
    short: self shortOptionAliases
    do: [ :opt :optArg | 
      processedOption := true.
      self assert: (options at: opt) = optArg ]
    nonOptionsDo: [ :nonOption | 
      processNonOption := true.
      nonOption = 'arg1' or: [ nonOption = 'arg2 and -e friends' ] ].
  self assert: processedOption.
  self assert: processNonOption
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> testMixed18 [
  | parser errorSignalled exception |
  parser := StashCommandGetOpts
    parseCommand:
      (ReadStream on: 'fileout -d/tmp/fileout --category Index-Tests indexTests.gs').
  errorSignalled := false.
  [ 
  parser
    getOptsMixedLongShort:
      {#('directory' $d #'required').
      #('class' nil #'none').
      #('package' nil #'none').
      #('category' nil #'required')}
    do: [ :opt :optArg |  ]
    nonOptionsDo: [ :nonOption |  ] ]
    on: Error
    do: [ :ex | 
      exception := ex.
      errorSignalled := true ].
  self assert: errorSignalled.
  self
    assert: exception description
    includesSubstring: 'Missing required argument for option: category'
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> testMixed19 [
  | parser errorSignalled exception |
  parser := StashCommandGetOpts
    parseCommand:
      (ReadStream
        on:
          'fileout --directory=/tmp/fileout --category Index-Tests indexTests.gs').
  errorSignalled := false.
  [ 
  parser
    getOptsMixedLongShort:
      {#('directory' $d #'required').
      #('class' nil #'none').
      #('package' nil #'none').
      #('category' nil #'required')}
    do: [ :opt :optArg |  ]
    nonOptionsDo: [ :nonOption |  ] ]
    on: Error
    do: [ :ex | 
      exception := ex.
      errorSignalled := true ].
  self assert: errorSignalled.
  self
    assert: exception description
    includesSubstring: 'Missing required argument for option: category'
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> testMixed20 [
  | parser options processedOption processNonOption parsedOptions |
  options := Dictionary new
    add: 'directory' -> '/tmp/fileout';
    add: 'category' -> nil;
    yourself.
  parser := StashCommandGetOpts
    parseCommand:
      (ReadStream
        on:
          'fileout --category --directory=/tmp/fileout  Index-Tests indexTests.gs').
  self assert: parser command = 'fileout'.
  processNonOption := processedOption := false.
  parsedOptions := Dictionary new.
  parser
    getOptsMixedLongShort:
      {#('directory' $d #'required').
      #('class' nil #'none').
      #('package' nil #'none').
      #('category' nil #'none')}
    do: [ :opt :optArg | 
      processedOption := true.
      parsedOptions at: opt put: optArg ]
    nonOptionsDo: [ :nonOption | 
      processNonOption := true.
      nonOption = 'Index-Tests' or: [ nonOption = 'indexTests.gs' ] ].
  options
    keysAndValuesDo: [ :key :value | self assert: (parsedOptions at: key) = (options at: key) ].
  self assert: processedOption.
  self assert: processNonOption
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> testMixed21 [
  | parser options processedOption processNonOption parsedOptions |
  options := Dictionary new
    add: 'directory' -> '/tmp/fileout';
    add: 'category' -> nil;
    yourself.
  parser := StashCommandGetOpts
    parseCommand:
      (ReadStream
        on:
          'fileout --directory=/tmp/fileout --category Index-Tests indexTests.gs').
  self assert: parser command = 'fileout'.
  processNonOption := processedOption := false.
  parsedOptions := Dictionary new.
  parser
    getOptsMixedLongShort:
      {#('directory' $d #'required').
      #('class' nil #'none').
      #('package' nil #'none').
      #('category' nil #'none')}
    do: [ :opt :optArg | 
      processedOption := true.
      parsedOptions at: opt put: optArg ]
    nonOptionsDo: [ :nonOption | 
      processNonOption := true.
      nonOption = 'Index-Tests' or: [ nonOption = 'indexTests.gs' ] ].
  options
    keysAndValuesDo: [ :key :value | self assert: (parsedOptions at: key) = (options at: key) ].
  self assert: processedOption.
  self assert: processNonOption
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> testMixed22 [
  | parser options processedOption processNonOption parsedOptions |
  options := Dictionary new
    add: 'directory' -> '/tmp/fileout';
    add: 'category' -> nil;
    yourself.
  parser := StashCommandGetOpts
    parseCommand:
      (ReadStream on: 'fileout -d/tmp/fileout --category Index-Tests indexTests.gs').
  self assert: parser command = 'fileout'.
  processNonOption := processedOption := false.
  parsedOptions := Dictionary new.
  parser
    getOptsMixedLongShort:
      {#('directory' $d #'required').
      #('class' nil #'none').
      #('package' nil #'none').
      #('category' nil #'none')}
    do: [ :opt :optArg | 
      processedOption := true.
      parsedOptions at: opt put: optArg ]
    nonOptionsDo: [ :nonOption | 
      processNonOption := true.
      nonOption = 'Index-Tests' or: [ nonOption = 'indexTests.gs' ] ].
  options
    keysAndValuesDo: [ :key :value | self assert: (parsedOptions at: key) = (options at: key) ].
  self assert: processedOption.
  self assert: processNonOption
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> testMixed23 [
  | parser errorSignalled exception |
  parser := StashCommandGetOpts
    parseCommand:
      (ReadStream
        on:
          'fileout --category --directory=/tmp/fileout  Index-Tests indexTests.gs').
  errorSignalled := false.
  [ 
  parser
    getOptsMixedLongShort:
      {#('directory' $d #'required').
      #('class' nil #'none').
      #('package' nil #'none').
      #('category' nil #'required')}
    do: [ :opt :optArg |  ]
    nonOptionsDo: [ :nonOption |  ] ]
    on: Error
    do: [ :ex | 
      exception := ex.
      errorSignalled := true ].
  self assert: errorSignalled.
  self
    assert: exception description
    includesSubstring: 'Missing required argument for option: category'
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> testMixed24 [
  | parser options processedOption processNonOption parsedOptions |
  options := Dictionary new
    add: 'directory' -> '/tmp/fileout';
    add: 'class' -> nil;
    add: 'package' -> nil;
    yourself.
  parser := StashCommandGetOpts
    parseCommand:
      (ReadStream on: 'fileout -d/tmp/fileout -cp Index-Tests indexTests.gs').
  self assert: parser command = 'fileout'.
  processNonOption := processedOption := false.
  parsedOptions := Dictionary new.
  parser
    getOptsMixedLongShort:
      {#('directory' $d #'required').
      #('class' $c #'none').
      #('package' $p #'none').
      #('category' nil #'none')}
    do: [ :opt :optArg | 
      processedOption := true.
      parsedOptions at: opt put: optArg ]
    nonOptionsDo: [ :nonOption | 
      processNonOption := true.
      nonOption = 'Index-Tests' or: [ nonOption = 'indexTests.gs' ] ].
  options
    keysAndValuesDo: [ :key :value | self assert: (parsedOptions at: key) = (options at: key) ].
  self assert: processedOption.
  self assert: processNonOption
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> testMixed25 [
  | parser options processedOption processNonOption parsedOptions |
  options := Dictionary new
    add: 'directory' -> '/tmp/fileout';
    add: 'class' -> nil;
    add: 'package' -> nil;
    yourself.
  parser := StashCommandGetOpts
    parseCommand:
      (ReadStream
        on: 'fileout -d/tmp/fileout --class --package Index-Tests indexTests.gs').
  self assert: parser command = 'fileout'.
  processNonOption := processedOption := false.
  parsedOptions := Dictionary new.
  parser
    getOptsMixedLongShort:
      {#('directory' $d #'required').
      #('class' $c #'none').
      #('package' $p #'none').
      #('category' nil #'none')}
    do: [ :opt :optArg | 
      processedOption := true.
      parsedOptions at: opt put: optArg ]
    nonOptionsDo: [ :nonOption | 
      processNonOption := true.
      nonOption = 'Index-Tests' or: [ nonOption = 'indexTests.gs' ] ].
  options
    keysAndValuesDo: [ :key :value | self assert: (parsedOptions at: key) = (options at: key) ].
  self assert: processedOption.
  self assert: processNonOption
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> testMixedQuotedArg01 [
  | parser options processedOption |
  options := Dictionary new
    add: 'argA' -> nil;
    add: 'argB' -> nil;
    yourself.
  parser := StashBashCommandGetOpts parseCommand: (ReadStream on: 'testopt `(self at: 1) - 1` ').
  self assert: parser command = 'testopt'.
  processedOption := false.
  parser
    getOptsLong: self longOptionSpec
    short: self shortOptionAliases
    do: [ :opt :optArg | 
      self assert: false ]
    nonOptionsDo: [ :nonOption | processedOption := true ].
  self assert: processedOption
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> testMixedQuotedBashArg01 [
  | parser options processedOption |
  options := Dictionary new
    add: 'argA' -> nil;
    add: 'argB' -> nil;
    yourself.
  parser := StashBashCommandGetOpts parseCommand: (ReadStream on: 'testopt "(self at: 1) - 1" ').
  self assert: parser command = 'testopt'.
  processedOption := false.
  parser
    getOptsLong: self longOptionSpec
    short: self shortOptionAliases
    do: [ :opt :optArg | 
      self assert: false ]
    nonOptionsDo: [ :nonOption | processedOption := true ].
  self assert: processedOption
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> testMixedSingleDashArg01 [
  | parser options processedOption |
  options := Dictionary new
    add: 'argA' -> nil;
    add: 'argB' -> nil;
    yourself.
  parser := StashBashCommandGetOpts parseCommand: (ReadStream on: 'testopt -').
  self assert: parser command = 'testopt'.
  processedOption := false.
  parser
    getOptsLong: self longOptionSpec
    short: self shortOptionAliases
    do: [ :opt :optArg | 
      self assert: false ]
    nonOptionsDo: [ :nonOption | processedOption := true ].
  self assert: processedOption
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> testMixedSingleDashArg02 [
  | parser options processedOption |
  options := Dictionary new
    add: 'argA' -> nil;
    add: 'argB' -> nil;
    yourself.
  parser := StashBashCommandGetOpts parseCommand: (ReadStream on: 'testopt - ').
  self assert: parser command = 'testopt'.
  processedOption := false.
  parser
    getOptsLong: self longOptionSpec
    short: self shortOptionAliases
    do: [ :opt :optArg | 
      self assert: false ]
    nonOptionsDo: [ :nonOption | processedOption := true ].
  self assert: processedOption
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> testMixedSingleDashQuotedBashArg01 [
  | parser options optionCount processedOption |
  options := Dictionary new
    add: 'argA' -> nil;
    add: 'argB' -> nil;
    yourself.
  parser := StashBashCommandGetOpts
    parseCommand: (ReadStream on: 'testopt --argA - --argB "(self at: 1) - 1" ').
  self assert: parser command = 'testopt'.
  processedOption := false.
  optionCount := 0.
  parser
    getOptsLong: self longOptionSpec
    short: self shortOptionAliases
    do: [ :opt :optArg | 
      optionCount := optionCount + 1.
      self assert: (options at: opt) = optArg ]
    nonOptionsDo: [ :nonOption | processedOption := true ].
  self assert: processedOption.
  self assert: optionCount = 2.
]

{ #category : 'tests' }
StashCommandGetOptsTestCase >> testMixedSingleDashQuotedBashArg02 [
  | parser options processedOption |
  options := Dictionary new
    add: 'argA' -> nil;
    add: 'argB' -> nil;
    yourself.
  parser := StashBashCommandGetOpts parseCommand: (ReadStream on: 'testopt "(self at: 1) - 1" - ').
  self assert: parser command = 'testopt'.
  processedOption := false.
  parser
    getOptsLong: self longOptionSpec
    short: self shortOptionAliases
    do: [ :opt :optArg | 
      self assert: false ]
    nonOptionsDo: [ :nonOption | processedOption := true ].
  self assert: processedOption
]
