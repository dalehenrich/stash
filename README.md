# Stash
Shell interpreters for [GemStone/S 64 smalltalk][1] and [topaz][2].

Stash makes it possible to directly execute standalone topaz and smalltalk scripts.

Note that **GemStone/S 64 3.5.0** or later is required.
### topaz script
Here is a [`hello world` topaz script][3]:
```smalltalk
#!/usr/bin/gemstone/topaz
#
#	Write `hello world` to stdout and exit.
#
login
run
	GsFile stdout nextPutAll: 'hello world'
%
exit
```
### smalltalk script
Here is a [`hello world` smalltalk script][4]:
```smalltalk
#!/usr/bin/gemstone/smalltalk
"
	Write `Hello World` to stdout and exit.
"
Class {
     #name : 'HelloWorldScript',
     #superclass : 'StashScript',
     #category : 'Stash-Scripts'
}

{ #category : 'script execution' }
 HelloWorldScript>> executeScript [

	opts at: 'help' ifPresent: [ ^ self usage ].
	GsFile stdout nextPutAll: 'Hello World'; lf
]

{ #category : 'usage' }
 HelloWorldScript>> usage [

	self usage: 'hello.st' description: 'Write `hello world` to stdout and exit.'
]
```
### Table of Contents
1. [Script execution environment](#script-execution-environment)
2. [Installation](#installation)
3. [Examples](#examples)
4. [Creating your own scripts](#creating-your-own-scripts)
5. [Debugging scripts](#debugging-scripts)
6. [Topaz Solo script support](#topaz-solo-script-support)
# Script execution environment
Stash scripts are executed in a GemStone session that is running against a 
particular GemStone Object Server or against a single user GemStone extent
file, using a topaz solo login (see 
[Topaz Solo script support](#topaz-solo-script-support) for more info).
A combination of environmentvariables and command line arguments are used to
select the desired execution environment.
There are two execution environments that are currently supported:
1. [Classic GemStone](#classic-gemstone-environment)
2. [GsDevKit_home](#gsdevkit_home-environment)

## Classic GemStone environment
The **Classic GemStone** environment expects:
1. The **GEMSTONE** environmnent variable to refence the GemStone/S 64 product
tree to be used.
2. The **PATH** environment variable to reference `$GEMSTONE/bin`, where the `topaz` executable is located.
3. and a [`.topazini` file][5] to specify the name of the GemStone Object Server to be used, 
as well as the the userId, and password to be used to create GemStone session to execute the script.
### topaz script invocation
A command line invocation of the `hello.tpz` script using the 
[classic GemStone environment](#classic-gemstone-environment) would look like the following:
```bash
bash> hello.tpz -lq -I ./.topazini
hello world
```
### smalltalk script invocation
A command line invocation of the `hello.st` script using the 
[Classic GemStone environment](#classic-gemstone-environment) would look like the following:
```bash
bash> hello.st -- -lq  -I ./.topazini
Hello World
```
## GsDevKit_home environment
The **GsDevKit_home** environment expects:
1. The **GS_HOME** environmnet variable to reference the root directory of the 
[GsDdevKit_home][6] installation.
2. The name of the stone is enough to identify where the GemStone/S 64 product
tree is located as well as where the default [`.topazini` file][5] is located.
### topaz script invocation
A command line invocation of the `hello.tpz` script using the 
[GsDevKit_home environment](#gsdevkit_home-environment) would look like the following:
```bash
bash> hello.tpz <stone-name> -lq
hello world
```
### smalltalk script invocation
A command line invocation of the `hello.st` script using the 
[GsDevKit_home environment](#gsdevkit_home-environment) would look like the following:
```bash
bash> hello.st -- <stone-name> -lq
Hello World
```
# Installation 
To install Stash, you need to have `sudo` privileges, as the shell interpreters
([smalltalk_350_interpreter][7] and [topaz_350_interpreter][8]) need to be
installed in `/usr/bin/gemstone`.

Stash will install [Rowan][10] into your stone as it is required.
The Rowan environment needs to have the **ROWAN_PROJECTS_HOME** environment 
variable defined. 
**ROWAN_PROJECTS_HOME** defines the directory where the git clones for stash
and Rowan will be located.

## Classic GemStone install
For a [Classic GemStone installation](#classic-gemstone-install), you need to have the
environment variables set up and create a stone that will be used to provide
the the scripting environment. You will supply the name of the stone on the 
[`install.sh`][9] command line:
```bash
export ROWAN_PROJECTS_HOME=<git-clone-directory>
cd $ROWAN_PROJECTS_HOME
git clone https://github.com/dalehenrich/stash.git
$ROWAN_PROJECTS_HOME/stash/bin/install.sh <stone-name>
```

## GsDevKit_home install
For a [GsDevKit_home installation](#gsdevkit_home-install), you need to have `$GS_HOME`
defined. You do not need to have a stone created before running the 
[`install.sh`][9] script.
If you provide the GemStone/S 65 version number on the command line, the script
will create the stone for you:
```bash
export ROWAN_PROJECTS_HOME=$GS_HOME/shared/repos
cd $ROWAN_PROJECTS_HOME
git clone https://github.com/dalehenrich/stash.git
$ROWAN_PROJECTS_HOME/stash/bin/install.sh <stone-name> 3.5.0
```
# Examples
There are a number of scripts in the [`$ROWAN_PROJECTS_HOME/stash/scripts`
directory][13].
Each of the `.st` scripts has a `--help` option defined:
```bash
$ROWAN_PROJECTS_HOME/stash/scripts/snapshot.st --help -- -lq			# GEMSTONE

$ROWAN_PROJECTS_HOME/stash/scripts/snapshot.st --help -- <stone-name> -lq	# GsDevKit_home
```
# Creating your own scripts
### topaz script creation
If you want to create a new topaz script, simply copy the `template.tpz` 
example script and then edit it as needed:
```bash
cp $ROWAN_PROJECTS_HOME/stash/scripts/template.tpz myscript.tpz
```
### smalltalk script creation
To create a new smalltalk script, use the `createTemplateScript.st` script
```bash
$ROWAN_PROJECTS_HOME/stash/scripts/createTemplateScript.st \
	--script=myScript --class=MyScript --dir=/home/me/bin -- MyStone -lq	
```
If take a close look at a smalltalk script, you will notice that this is simply
a Tonel class file and that the class is a subclass of StashScript:
```smalltalk
#!/usr/bin/gemstone/smalltalk
"
	Write `Hello World` to stdout and exit.
"
Class {
     #name : 'HelloWorldScript',
     #superclass : 'StashScript',
     #category : 'Stash-Scripts'
}

{ #category : 'script execution' }
 HelloWorldScript>> executeScript [

	opts at: 'help' ifPresent: [ ^ self usage ].
	GsFile stdout nextPutAll: 'Hello World'; lf
]

{ #category : 'usage' }
 HelloWorldScript>> usage [

	self usage: 'hello.st' description: 'Write `hello world` to stdout and exit.'
]
```
The implication here is that this is not just a chunk of workspace code, but a
real live class to which you can add methods and instance variables, etc. 

It is also worth taking a close look at the 
`$ROWAN_PROJECTS_HOME/stash/scripts/rowan.st` script. Specifically, the
`#scriptOptions` and `#executeScript` methods are interesting.
The `#scriptOptions` method is interesting because you can
see an example where a range of command line options, some with 
arguments and some without are declared:
```smalltalk
{ #category : 'script execution' }
rowan >> scriptOptions [
	"specify the command line options"
	^ {
			#('help' $h #none).
			#('install' nil #required).
			#('load' nil #required).
			#('unload' nil #required).
			#('list' nil #none).
			#('write' nil #required).
			#('commit' nil #required).
			#('edit' nil #none).
	}
]
```
The `#executeScript` method because you can see how the various command line 
options are handeled and dispatched:
```smalltalk
{ #category : 'script execution' }
rowan >> executeScript [
	"Called to initiate execution of the script"
	^ opts
			at: 'help'
			ifAbsent: [ 
				opts at: 'edit' ifPresent: [:arg | self edit ].
				opts at: 'install' ifPresent: [:arg | self install: arg ].
				opts at: 'load' ifPresent: [:arg | self load: arg ].
				opts at: 'unload' ifPresent: [:arg | self unload: arg ].
				opts at: 'write' ifPresent: [:arg | self write: arg ].
				opts at: 'commit' ifPresent: [:arg | self commit: arg message: (args at: 1) ].
				opts at: 'list' ifPresent: [:arg | self list ].
				^ true ]
			ifPresent: [ self usage ]
]
``` 
# Debugging scripts
By default if an error occurs during script exection (topaz or smalltalk 
script), script execution halts, the error stack is printed and you are 
left at a topaz command prompt.
### Debugging error
```bash
bash> error.st --boom -- -lq
ERROR 2010 , a MessageNotUnderstood occurred (error 2010), a StashScript class does not understand  #'ansiRedOn:during:' (MessageNotUnderstood)
topaz > exec iferr 1 : stk 
==> 1 MessageNotUnderstood >> defaultAction         @3 line 3
2 MessageNotUnderstood (AbstractException) >> _signalWith: @6 line 25
3 MessageNotUnderstood (AbstractException) >> signal @2 line 47
4 StashScript class (Object) >> doesNotUnderstand: @10 line 10
5 StashScript class (Object) >> _doesNotUnderstand:args:envId:reason: @8 line 14
6 [] in Executed Code                           @10 line 16
7 StashCommandError (AbstractException) >> _executeHandler: @8 line 11
8 StashCommandError (AbstractException) >> _signalWith: @1 line 1
9 StashCommandError (AbstractException) >> signal: @3 line 7
10 StashCommandError class (AbstractException class) >> signal: @3 line 4
11 ErrorExampleScript (StashScript) >> error:    @2 line 3
12 [] in ErrorExampleScript >> executeScript     @14 line 6
13 ExecBlock0 (ExecBlock) >> cull:               @5 line 7
14 Dictionary (AbstractDictionary) >> at:ifPresent: @5 line 7
15 [] in ErrorExampleScript >> executeScript     @7 line 6
16 Dictionary (AbstractDictionary) >> at:ifAbsent:ifPresent: @4 line 6
17 ErrorExampleScript >> executeScript           @3 line 4
18 ErrorExampleScript (StashScript) >> setupAndExecuteScript @13 line 11
19 StashScript class >> loadAndExecuteScriptClassFile:stashArgs:topazArgs:workingDir:projectName:packageName:symDictName: @24 line 19
20 [] in Executed Code                           @5 line 3
21 ExecBlock0 (ExecBlock) >> on:do:              @3 line 44
22 Executed Code                                 @2 line 10
23 GsNMethod class >> _gsReturnToC               @1 line 1
Stopping at line 25 of /tmp/tmp.lzu8EwafAw
topaz 1> 
```
From this point you can use the [topaz debugger][11] or you can quit execution.
### Debugging command line errors
If you hit a command line error (i.e., unknown option, etc.), the error message
is displayed in red and the topaz process exits:
![](docs/error.png?raw=true)
If you use the stash interpreter option `--debugCommandError`, then topaz will be left open and ready to debug instead of exiting: 
```bash
bash> error.st --b -- -lq --debugCommandError
ERROR 2710 , a StashCommandError occurred (error 2710), , Unknown option: b (StashCommandError)
topaz > exec iferr 1 : stk 
==> 1 StashCommandError (AbstractException) >> _signalWith: @6 line 25
2 StashCommandError (AbstractException) >> signal: @3 line 7
3 StashCommandError class (AbstractException class) >> signal: @3 line 4
4 StashCommandGetOpts >> error:                 @2 line 3
5 [] in StashCommandGetOpts >> parseLongOptions:shortOptions:do:nonOptionsDo: @114 line 83
6 Dictionary >> at:ifAbsent:                    @8 line 10
7 StashCommandGetOpts >> parseLongOptions:shortOptions:do:nonOptionsDo: @64 line 82
8 StashCommandGetOpts >> getOptsLong:short:do:nonOptionsDo: @2 line 7
9 StashCommandGetOpts class >> getOptsLongFor:longOptionSpec:shortOptionAliases:do:nonOptionsDo: @4 line 4
10 StashCommandLine >> getCommandLongOpts:short:do:argsDo: @9 line 6
11 StashCommandLine >> getOptsLong:short:optionsAndArguments: @10 line 14
12 StashCommandLine >> getOptsMixedLongShort:optionsAndArguments: @8 line 26
13 ErrorExampleScript (StashScript) >> setupAndExecuteScript @12 line 7
14 StashScript class >> loadAndExecuteScriptClassFile:stashArgs:topazArgs:workingDir:projectName:packageName:symDictName: @24 line 19
15 [] in Executed Code                           @5 line 3
16 ExecBlock0 (ExecBlock) >> on:do:              @3 line 44
17 Executed Code                                 @2 line 10
18 GsNMethod class >> _gsReturnToC               @1 line 1
Stopping at line 25 of /tmp/tmp.kEjxfwNJ52
topaz 1>
```
# Topaz Solo script support
Starting with GemStone/S 64 3.5.0, a topaz executable can be used to execute
smalltalk code without running a stone.
A topaz *solo* session uses an extent file and creates a gem session that can
perform most code execution execution, although no persistent objects in the 
extents can be modified.

In order to initiate a topaz *solo* session
1. you need to specify the location
of the extent by using the configuration parameter **GEM_SOLO_EXTENT**. The
configuration parameter can be specified on a script command line using the 
`-C` topaz option or specified in a `gem.conf` file.
2. you need to include a `set solologin on` topz command in your topaz script.
### solo topaz script
For a topaz script, you need to explicitly include the `set solologin on` in 
your topaz script (see [solo.tpz][14]:
```
#!/usr/bin/gemstone/topaz
##
# just for solo tests
#

set solologin on
login

run
	GsFile stdout nextPutAll: 'I am being run from a topaz solo session'
%
exit
```
Here's an example script invocation of `solo.tpz` where the **GEM_SOLO_EXTENT**
is specified on the command line:
```bash
solo.tpz -lq -C "GEM_SOLO_EXTENT=$GEMSTONE/bin/extent0.dbf"
```
If the **GEM_SOLO_EXTENT** is specified in a `gem.conf` file, then all that is
needed is the `set solologin on` command in your topaz script:
```bash
solo.tpz -lq
```
### solo smalltalk script
For a smalltalk script, you don't have direct control over the topaz script, so
your need to use the `--solo` stash interpreter option which will cause 
`solologin' to be set `on`.
As with the [solo topaz script](#solo-topaz-script), the **GEM_SOLO_EXTENT**
must be set on the command line:
```bash
hello.st -- -lq -C "GEM_SOLO_EXTENT=$GEMSTONE/bin/extent0.dbf" --solo
```
Or in a `gem.conf` file:
```bash
error.st --boom -- MyStone -lq --solo
```
In a topaz session you may use the `status` command to determine whether or not
the session has had `set solologin on` performed:
```
topaz 1> status

Current settings are:
 display level: 0
 byte limit: 0 lev1bytes: 100
 omit bytes
 include deprecated methods in lists of methods
 display instance variable names
 omit oops   omit classoops   omit stacktemps 
 oop limit: 0
 omit automatic result checks
 omit interactive pause on errors
 omit interactive pause on warnings
 listwindow: 20
 stackpad: 45
 tab (ctl-H) equals 8 spaces when listing method source
 transactionmode  autoBegin
 using line editor
   line editor history: 100
   topaz input is from a tty on stdin
EditorName________ 
CompilationEnv____ 0
SourceStringClass    String
fileformat           8bit (tty stdin is utf8)
SessionInit          On
EnableRemoveAll      On
CacheName__________ 'Topaz'

Connection Information:
UserName___________ 'SystemUser'
Password __________ (set)
GemNetId___________ 'gcilnkobj'
SoloLogin       On                                        \<=======================

Browsing Information:
Class_____________ 
Category__________ (as yet unclassified)
```

---------------------------------------------------------------------------------------------------------

[1]: https://downloads.gemtalksystems.com/docs/GemStone64/3.4.x/GS64-ProgGuide-3.4/GS64-ProgGuide-3.4.htm
[2]: https://downloads.gemtalksystems.com/docs/GemStone64/3.4.x/GS64-Topaz-3.4/GS64-Topaz-3.4.htm
[3]: scripts/hello.tpz
[4]: scripts/hello.st
[5]: https://downloads.gemtalksystems.com/docs/GemStone64/3.4.x/GS64-Topaz-3.4/1-Tutorial.htm#pgfId-923343
[6]: https://github.com/GsDevKit/GsDevKit_home
[7]: bin/smalltalk_350_interpreter
[8]: bin/topaz_350_interpreter
[9]: bin/install.sh
[10]: https://github.com/GemTalk/Rowan
[11]: https://downloads.gemtalksystems.com/docs/GemStone64/3.4.x/GS64-Topaz-3.4/2-Debug.htm
[12]: docs/error.png
[13]: scripts/
[14]: scripts/solo.tpz#L6
