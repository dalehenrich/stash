Class {
	#name : 'TDCommandLineTestCase',
	#superclass : 'TestCase',
	#category : 'Stash-CommandLine-Tests'
}

{ #category : 'as yet unclassified' }
TDCommandLineTestCase >> assert: commandLine parsesInto: expectedCommands [
  ^ self assert: commandLine shouldParse: true into: expectedCommands
]

{ #category : 'as yet unclassified' }
TDCommandLineTestCase >> assert: commandLine shouldParse: shouldParse into: expectedCommands [
  | parsed count |
  parsed := false.
  count := 1.
  TDCommandLine
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
TDCommandLineTestCase >> test01 [
  self assert: '' shouldParse: false into: #().
  self
    assert: 'cd'
    parsesInto:
      {(TDCommandLine new
        tokens: {'cd'};
        yourself)}.
  self
    assert: 'cd ..'
    parsesInto:
      {(TDCommandLine new
        tokens:
            {'cd'.
              '..'};
        yourself)}.
  self
    assert: 'cd /home/bin/xxx'
    parsesInto:
      {(TDCommandLine new
        tokens:
            {'cd'.
              '/home/bin/xxx'};
        yourself)}.
  self
    assert: 'cd /home/bin/xxx; ls'
    parsesInto:
      {(TDCommandLine new
        tokens:
            {'cd'.
              '/home/bin/xxx'};
        yourself).
      (TDCommandLine new
        tokens: {'ls'};
        yourself)}.
  self
    assert: 'mm copy Topez-Core filetree:///opt/git/tode/repository; edit'
    parsesInto:
      {(TDCommandLine new
        tokens:
            {'mm'.
              'copy'.
              'Topez-Core'.
              'filetree:///opt/git/tode/repository'};
        yourself).
      (TDCommandLine new
        tokens: {'edit'};
        yourself)}
]

{ #category : 'as yet unclassified' }
TDCommandLineTestCase >> test02 [
  self
    assert: 'c > xxx'
    parsesInto:
      {(TDCommandLine new
        tokens: #('c');
        redirectTarget: 'xxx';
        yourself)}
]

{ #category : 'as yet unclassified' }
TDCommandLineTestCase >> test03 [
  self
    assert: 'mm copy Topez-Core filetree:///opt/git/tode/repository; edit'
    parsesInto:
      {(TDCommandLine new
        tokens:
            {'mm'.
              'copy'.
              'Topez-Core'.
              'filetree:///opt/git/tode/repository'};
        yourself).
      (TDCommandLine new
        tokens: {'edit'};
        yourself)}
]

{ #category : 'as yet unclassified' }
TDCommandLineTestCase >> test04 [
  self
    assert: 'mm copy Topez-Core filetree:///opt/git/tode/repository > xxx'
    parsesInto:
      {(TDCommandLine new
        tokens:
            #('mm' 'copy' 'Topez-Core' 'filetree:///opt/git/tode/repository');
        redirectTarget: 'xxx';
        yourself)}
]

{ #category : 'as yet unclassified' }
TDCommandLineTestCase >> test05 [
  self
    assert: 'browse amethod Object>>at:put: > xxx'
    parsesInto:
      {(TDCommandLine new
        tokens: #('browse' 'amethod' 'Object>>at:put:');
        redirectTarget: 'xxx';
        yourself)}
]

{ #category : 'as yet unclassified' }
TDCommandLineTestCase >> test06 [
  self
    assert: 'browse amethod Object class>>new > xxx'
    parsesInto:
      {(TDCommandLine new
        tokens: #('browse' 'amethod' 'Object' 'class>>new');
        redirectTarget: 'xxx';
        yourself)}
]

{ #category : 'as yet unclassified' }
TDCommandLineTestCase >> test07 [
  self
    assert: 'browse amethod @1 > xxx'
    parsesInto:
      {(TDCommandLine new
        tokens: #('browse' 'amethod' '@1');
        redirectTarget: 'xxx';
        yourself)}
]

{ #category : 'as yet unclassified' }
TDCommandLineTestCase >> test08 [
  self
    assert: 'browse method #> > xxx'
    parsesInto: {(TDCommandLine new tokens: #('browse' 'method') yourself)}
]

{ #category : 'as yet unclassified' }
TDCommandLineTestCase >> test09 [
  self
    assert: 'query `this is a test'' " < ; # \ string\`'
    parsesInto:
      {(TDCommandLine new
        tokens: #('query' 'this is a test'' " < ; # \ string\');
        yourself)}
]

{ #category : 'as yet unclassified' }
TDCommandLineTestCase >> test10 [
  self
    assert: 'testopt -c foo arg1 > result'
    parsesInto:
      {(TDCommandLine new
        tokens: #('testopt' '-c' 'foo' 'arg1');
        redirectTarget: 'result';
        yourself)}
]

{ #category : 'as yet unclassified' }
TDCommandLineTestCase >> test11 [
  self
    assert: 'command subcommand -c foo arg1 > result'
    parsesInto:
      {(TDCommandLine new
        tokens: #('command' 'subcommand' '-c' 'foo' 'arg1');
        redirectTarget: 'result';
        yourself)}
]

{ #category : 'as yet unclassified' }
TDCommandLineTestCase >> test12 [
  | commandLine |
  commandLine := 'command -c foo arg1 > result'.
  TDCommandLine
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
TDCommandLineTestCase >> test13 [
  | commandLine |
  commandLine := 'command subcommand -c foo arg1 > result'.
  TDCommandLine
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
TDCommandLineTestCase >> test14 [
  | commandLine |
  commandLine := 'command  -c foo arg1 > result'.
  TDCommandLine
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
TDCommandLineTestCase >> test15 [
  | commandLine |
  commandLine := 'command subcommand -c foo arg1 > result'.
  TDCommandLine
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
TDCommandLineTestCase >> test16 [
  | commandLine |
  commandLine := 'command  -c foo arg1 > result'.
  TDCommandLine
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
TDCommandLineTestCase >> test17 [
  | commandLine |
  commandLine := 'command subcommand -c foo arg1 > result'.
  TDCommandLine
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
TDCommandLineTestCase >> test18 [
  | commandLine |
  commandLine := './command'.
  TDCommandLine
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
TDCommandLineTestCase >> test19 [
  | commandLine |
  commandLine := './command '.
  TDCommandLine
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
TDCommandLineTestCase >> test20 [
  | commandLine |
  commandLine := 'command --a subcommand --b=optionBArg arg1'.
  TDCommandLine
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
      TDCommandLine
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
TDCommandLineTestCase >> test21 [
	| commandLine sawCommands |
	commandLine := 'command -c foo arg1 > result
  skipMe subcommand -c foo arg1 > result
command subcommand -c foo arg1 > result'.
	sawCommands := false.
	TDCommandLine
		fromStream: commandLine readStream
		selectLine: [ :cmdLine | cmdLine beginsWith: 'command' ]
		forEachCommand: [ :command | 
			self assert: command command = 'command'.
			sawCommands := true ].
	self assert: sawCommands
]

{ #category : 'as yet unclassified' }
TDCommandLineTestCase >> testBackSlashNewLineEscape [
  self
    assert:
      'ls
cd \
   /home'
    parsesInto:
      {(TDCommandLine new
        tokens: #('ls');
        yourself).
      (TDCommandLine new
        tokens: #('cd' '/home');
        yourself)}.
  self
    assert:
      './gemServer \
--register=seaside --type=zinc \
--port=1750 --log=all \
              --logTo=transcript'
    parsesInto:
      {(TDCommandLine new
        tokens:
            #('./gemServer' '--register=seaside'  '--type=zinc'  '--port=1750' '--log=all'  '--logTo=transcript');
        yourself)}
]

{ #category : 'as yet unclassified' }
TDCommandLineTestCase >> testHashComment [
  self
    assert: 'cd /home/bin/xxx; ls'
    parsesInto:
      {(TDCommandLine new
        tokens:
            {'cd'.
              '/home/bin/xxx'};
        yourself).
      (TDCommandLine new
        tokens: {'ls'};
        yourself)}.
  self
    assert: 'cd /home/bin/xxx#; ls'
    parsesInto:
      {(TDCommandLine new
        tokens:
            {'cd'.
              '/home/bin/xxx'};
        yourself)}.
  self
    assert: 'c > xxx'
    parsesInto:
      {(TDCommandLine new
        tokens: #('c');
        redirectTarget: 'xxx';
        yourself)}.
  self
    assert: 'c #> xxx'
    parsesInto:
      {(TDCommandLine new
        tokens: #('c');
        yourself)}
]
