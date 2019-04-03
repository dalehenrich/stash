Class {
	#name : 'StashCommandLineTestCase',
	#superclass : 'TestCase',
	#category : 'Stash-CommandLine-Tests'
}

{ #category : 'as yet unclassified' }
StashCommandLineTestCase >> assert: commandLine parsesInto: expectedCommands [
  ^ self assert: commandLine shouldParse: true into: expectedCommands
]

{ #category : 'as yet unclassified' }
StashCommandLineTestCase >> assert: commandLine shouldParse: shouldParse into: expectedCommands [
  | parsed count |
  parsed := false.
  count := 1.
  StashCommandLine
    fromStream: commandLine readStream
    forEachCommand: [ :command | 
      | tokens expectedTokens expectedCommand |
      parsed := true.
      tokens := command tokens.
      expectedCommand := expectedCommands at: count.
      count := count + 1.
      expectedTokens := expectedCommand tokens.
      self assert: tokens size = expectedTokens size.
      1 to: tokens size do: [ :index | self assert: (tokens at: index) = (expectedTokens at: index) ].
      self assert: command redirectTarget = expectedCommand redirectTarget ].
  self assert: expectedCommands size = (count - 1).
  self assert: parsed == shouldParse
]

{ #category : 'as yet unclassified' }
StashCommandLineTestCase >> test01 [
  self assert: '' shouldParse: false into: #().
  self
    assert: 'cd'
    parsesInto:
      {(StashCommandLine new
        tokens: {'cd'};
        yourself)}.
  self
    assert: 'cd ..'
    parsesInto:
      {(StashCommandLine new
        tokens:
            {'cd'.
              '..'};
        yourself)}.
  self
    assert: 'cd /home/bin/xxx'
    parsesInto:
      {(StashCommandLine new
        tokens:
            {'cd'.
              '/home/bin/xxx'};
        yourself)}.
  self
    assert: 'cd /home/bin/xxx; ls'
    parsesInto:
      {(StashCommandLine new
        tokens:
            {'cd'.
              '/home/bin/xxx'};
        yourself).
      (StashCommandLine new
        tokens: {'ls'};
        yourself)}.
  self
    assert: 'mm copy Topez-Core filetree:///opt/git/tode/repository; edit'
    parsesInto:
      {(StashCommandLine new
        tokens:
            {'mm'.
              'copy'.
              'Topez-Core'.
              'filetree:///opt/git/tode/repository'};
        yourself).
      (StashCommandLine new
        tokens: {'edit'};
        yourself)}
]

{ #category : 'as yet unclassified' }
StashCommandLineTestCase >> test02 [
  self
    assert: 'c > xxx'
    parsesInto:
      {(StashCommandLine new
        tokens: #('c');
        redirectTarget: 'xxx';
        yourself)}
]

{ #category : 'as yet unclassified' }
StashCommandLineTestCase >> test03 [
  self
    assert: 'mm copy Topez-Core filetree:///opt/git/tode/repository; edit'
    parsesInto:
      {(StashCommandLine new
        tokens:
            {'mm'.
              'copy'.
              'Topez-Core'.
              'filetree:///opt/git/tode/repository'};
        yourself).
      (StashCommandLine new
        tokens: {'edit'};
        yourself)}
]

{ #category : 'as yet unclassified' }
StashCommandLineTestCase >> test04 [
  self
    assert: 'mm copy Topez-Core filetree:///opt/git/tode/repository > xxx'
    parsesInto:
      {(StashCommandLine new
        tokens:
            #('mm' 'copy' 'Topez-Core' 'filetree:///opt/git/tode/repository');
        redirectTarget: 'xxx';
        yourself)}
]

{ #category : 'as yet unclassified' }
StashCommandLineTestCase >> test05 [
  self
    assert: 'browse amethod Object>>at:put: > xxx'
    parsesInto:
      {(StashCommandLine new
        tokens: #('browse' 'amethod' 'Object>>at:put:');
        redirectTarget: 'xxx';
        yourself)}
]

{ #category : 'as yet unclassified' }
StashCommandLineTestCase >> test06 [
  self
    assert: 'browse amethod Object class>>new > xxx'
    parsesInto:
      {(StashCommandLine new
        tokens: #('browse' 'amethod' 'Object' 'class>>new');
        redirectTarget: 'xxx';
        yourself)}
]

{ #category : 'as yet unclassified' }
StashCommandLineTestCase >> test07 [
  self
    assert: 'browse amethod @1 > xxx'
    parsesInto:
      {(StashCommandLine new
        tokens: #('browse' 'amethod' '@1');
        redirectTarget: 'xxx';
        yourself)}
]

{ #category : 'as yet unclassified' }
StashCommandLineTestCase >> test08 [
  self
    assert: 'browse method #> > xxx'
    parsesInto: {(StashCommandLine new tokens: #('browse' 'method') yourself)}
]

{ #category : 'as yet unclassified' }
StashCommandLineTestCase >> test09 [
  self
    assert: 'query `this is a test'' " < ; # \ string\`'
    parsesInto:
      {(StashCommandLine new
        tokens: #('query' 'this is a test'' " < ; # \ string\');
        yourself)}
]

{ #category : 'as yet unclassified' }
StashCommandLineTestCase >> test10 [
  self
    assert: 'testopt -c foo arg1 > result'
    parsesInto:
      {(StashCommandLine new
        tokens: #('testopt' '-c' 'foo' 'arg1');
        redirectTarget: 'result';
        yourself)}
]

{ #category : 'as yet unclassified' }
StashCommandLineTestCase >> test11 [
  self
    assert: 'command subcommand -c foo arg1 > result'
    parsesInto:
      {(StashCommandLine new
        tokens: #('command' 'subcommand' '-c' 'foo' 'arg1');
        redirectTarget: 'result';
        yourself)}
]

{ #category : 'as yet unclassified' }
StashCommandLineTestCase >> test12 [
  | commandLine |
  commandLine := 'command -c foo arg1 > result'.
  StashCommandLine
    line: commandLine
    forEachCommand: [ :command | 
      | options args |
      self assert: command command = 'command'.
      options := Dictionary new.
      args := OrderedCollection new.
      command
        getCommandOpts: 'abc:'
        do: [ :option :optionArg | options at: option asString put: optionArg ]
        argsDo: [ :arg | args add: arg ].
      self assert: options keys size = 1.
      self assert: (options at: 'c') = 'foo'.
      self assert: args size = 1.
      self assert: (args at: 1) = 'arg1' ]
]

{ #category : 'as yet unclassified' }
StashCommandLineTestCase >> test13 [
  | commandLine |
  commandLine := 'command subcommand -c foo arg1 > result'.
  StashCommandLine
    line: commandLine
    forEachCommand: [ :command | 
      | options args |
      self assert: command command = 'command'.
      self assert: command subCommand = 'subcommand'.
      self assert: command redirectTarget = 'result'.
      options := Dictionary new.
      args := OrderedCollection new.
      command
        getSubCommandOpts: 'abc:'
        do: [ :option :optionArg | options at: option asString put: optionArg ]
        argsDo: [ :arg | args add: arg ].
      self assert: options keys size = 1.
      self assert: (options at: 'c') = 'foo'.
      self assert: args size = 1.
      self assert: (args at: 1) = 'arg1' ]
]

{ #category : 'as yet unclassified' }
StashCommandLineTestCase >> test14 [
  | commandLine |
  commandLine := 'command  -c foo arg1 > result'.
  StashCommandLine
    line: commandLine
    forEachCommand: [ :command | 
      | options args |
      self assert: command command = 'command'.
      self assert: command redirectTarget = 'result'.
      command
        getCommandOpts: 'abc:'
        optionsAndArguments: [ :optionDictionary :arguments | 
          options := optionDictionary.
          args := arguments ].
      self assert: options keys size = 1.
      self assert: (options at: 'c') = 'foo'.
      self assert: args size = 1.
      self assert: (args at: 1) = 'arg1' ]
]

{ #category : 'as yet unclassified' }
StashCommandLineTestCase >> test15 [
  | commandLine |
  commandLine := 'command subcommand -c foo arg1 > result'.
  StashCommandLine
    line: commandLine
    forEachCommand: [ :command | 
      | options args |
      self assert: command command = 'command'.
      self assert: command subCommand = 'subcommand'.
      self assert: command redirectTarget = 'result'.
      command
        getSubCommandOpts: 'abc:'
        optionsAndArguments: [ :optionDictionary :arguments | 
          options := optionDictionary.
          args := arguments ].
      self assert: options keys size = 1.
      self assert: (options at: 'c') = 'foo'.
      self assert: args size = 1.
      self assert: (args at: 1) = 'arg1' ]
]

{ #category : 'as yet unclassified' }
StashCommandLineTestCase >> test16 [
  | commandLine |
  commandLine := 'command  -c foo arg1 > result'.
  StashCommandLine
    line: commandLine
    forEachCommand: [ :command | 
      | options args |
      self assert: command command = 'command'.
      self assert: command redirectTarget = 'result'.
      command
        getOpts: 'abc:'
        optionsAndArguments: [ :optionDictionary :arguments | 
          options := optionDictionary.
          args := arguments ].
      self assert: options keys size = 1.
      self assert: (options at: 'c') = 'foo'.
      self assert: args size = 1.
      self assert: (args at: 1) = 'arg1' ]
]

{ #category : 'as yet unclassified' }
StashCommandLineTestCase >> test17 [
  | commandLine |
  commandLine := 'command subcommand -c foo arg1 > result'.
  StashCommandLine
    line: commandLine
    forEachCommand: [ :command | 
      | options args |
      self assert: command command = 'command'.
      self assert: command subCommand = 'subcommand'.
      self assert: command redirectTarget = 'result'.
      command
        hasSubCommand: true;
        getOpts: 'abc:'
          optionsAndArguments: [ :optionDictionary :arguments | 
              options := optionDictionary.
              args := arguments ].
      self assert: options keys size = 1.
      self assert: (options at: 'c') = 'foo'.
      self assert: args size = 1.
      self assert: (args at: 1) = 'arg1' ]
]

{ #category : 'as yet unclassified' }
StashCommandLineTestCase >> test18 [
  | commandLine |
  commandLine := './command'.
  StashCommandLine
    line: commandLine
    forEachCommand: [ :command | 
      | opts args |
      command
        getOptsMixedLongShort:
          {#('help' $h #'none').
          #('optional' $o #'optional').
          #('required' $r #'required')}
        optionsAndArguments: [ :options :operands | 
          opts := options.
          args := operands ].
      self assert: opts isEmpty.
      self assert: args isEmpty ]
]

{ #category : 'as yet unclassified' }
StashCommandLineTestCase >> test19 [
  | commandLine |
  commandLine := './command '.
  StashCommandLine
    line: commandLine
    forEachCommand: [ :command | 
      | opts args |
      command
        getOptsMixedLongShort:
          {#('help' $h #'none').
          #('optional' $o #'optional').
          #('required' $r #'required')}
        optionsAndArguments: [ :options :operands | 
          opts := options.
          args := operands ].
      self assert: opts isEmpty.
      self assert: args isEmpty ]
]

{ #category : 'as yet unclassified' }
StashCommandLineTestCase >> test20 [
  | commandLine |
  commandLine := 'command --a subcommand --b=optionBArg arg1'.
  StashCommandLine
    line: commandLine
    forEachCommand: [ :command | 
      | options args subCommandLine subCommandArgPtrIndex |
      self assert: command command = 'command'.
      command
        getOptsMixedLongShort: {#('a' nil #'none')}
        optionsAndArguments: [ :optionDictionary :arguments | 
          options := optionDictionary.
          args := arguments ].
      self assert: options keys size = 1.
      self assert: (options at: 'a') == nil.
      self assert: args size = 3.
      subCommandArgPtrIndex := command rawTokens size - args size.
      subCommandLine := command commandLine
        copyFrom: (command argPtrs at: subCommandArgPtrIndex)
        to: command commandLine size.
      StashCommandLine
        line: subCommandLine
        forEachCommand: [ :subCommand | 
          | subOptions subArgs |
          self assert: subCommand command = 'subcommand'.
          subCommand
            getOptsMixedLongShort: {#('b' nil #'required')}
            optionsAndArguments: [ :optionDictionary :arguments | 
              subOptions := optionDictionary.
              subArgs := arguments ].
          self assert: options keys size = 1.
          self assert: (subOptions at: 'b') = 'optionBArg'.
          self assert: subArgs size = 1.
          self assert: (subArgs at: 1) = 'arg1' ] ]
]

{ #category : 'as yet unclassified' }
StashCommandLineTestCase >> test21 [
	| commandLine sawCommands |
	commandLine := 'command -c foo arg1 > result
  skipMe subcommand -c foo arg1 > result
command subcommand -c foo arg1 > result'.
	sawCommands := false.
	StashCommandLine
		fromStream: commandLine readStream
		selectLine: [ :cmdLine | cmdLine beginsWith: 'command' ]
		forEachCommand: [ :command | 
			self assert: command command = 'command'.
			sawCommands := true ].
	self assert: sawCommands
]

{ #category : 'as yet unclassified' }
StashCommandLineTestCase >> testBackSlashNewLineEscape [
  self
    assert:
      'ls
cd \
   /home'
    parsesInto:
      {(StashCommandLine new
        tokens: #('ls');
        yourself).
      (StashCommandLine new
        tokens: #('cd' '/home');
        yourself)}.
  self
    assert:
      './gemServer \
--register=seaside --type=zinc \
--port=1750 --log=all \
              --logTo=transcript'
    parsesInto:
      {(StashCommandLine new
        tokens:
            #('./gemServer' '--register=seaside'  '--type=zinc'  '--port=1750' '--log=all'  '--logTo=transcript');
        yourself)}
]

{ #category : 'as yet unclassified' }
StashCommandLineTestCase >> testHashComment [
  self
    assert: 'cd /home/bin/xxx; ls'
    parsesInto:
      {(StashCommandLine new
        tokens:
            {'cd'.
              '/home/bin/xxx'};
        yourself).
      (StashCommandLine new
        tokens: {'ls'};
        yourself)}.
  self
    assert: 'cd /home/bin/xxx#; ls'
    parsesInto:
      {(StashCommandLine new
        tokens:
            {'cd'.
              '/home/bin/xxx'};
        yourself)}.
  self
    assert: 'c > xxx'
    parsesInto:
      {(StashCommandLine new
        tokens: #('c');
        redirectTarget: 'xxx';
        yourself)}.
  self
    assert: 'c #> xxx'
    parsesInto:
      {(StashCommandLine new
        tokens: #('c');
        yourself)}
]
