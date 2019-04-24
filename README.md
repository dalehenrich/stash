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
# Script execution environment
Stash scripts are executed in a GemStone session that is running against a 
particular GemStone Object Server or against a single user GemStone extent
file, using a topaz solo login.
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
There are a number of scripts in the `$ROWAN_PROJECTS_HOME/stash/scripts`
directory.
Each of the `.st` scripts has a `--help` option defined:
```bash
$ROWAN_PROJECTS_HOME/stash/scripts/snapshot.st --help -- -lq			# GEMSTONE
$ROWAN_PROJECTS_HOME/stash/scripts/snapshot.st --help -- <stone-name> -lq	# GsDevKit_home
```

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
