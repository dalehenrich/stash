# Stash
Shell interpreters for [GemStone/S 64 smalltalk][1] and [topaz][2].

Stash makes it possible to directly execute standalone topaz and smalltalk scripts.
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
1. [classic GemStone](#classic-gemstone)
2. [GsDevKit_home](#gsdevkit_home)

## Classic GemStone
The **Classic GemStone** environment expects:
1. The **GEMSTONE** environmnent variable to refence the GemStone/S 64 product
tree to be used.
2. The **PATH** environment variable to reference `$GEMSTONE/bin`, where the `topaz` executable is located.
3. and a [`.topazini` file][5] to specify the name of the GemStone Object Server to be used, 
as well as the the userId, and password to be used to create GemStone session to execute the script.
### topaz script invocation
A command line invocation of the `hello.tpz` script using the 
[classic GemStone](#classic-gemstone) environment would look like the following:
```bash
bash> hello.tpz -lq -I ./.topazini
hello world
```
### smalltalk script invocation
A command line invocation of the `hello.st` script using the 
[classic GemStone](#classic-gemstone) environment would look like the following:
```bash
bash> hello.st -- -lq  -I ./.topazini
Hello World
```
## GsDevKit_home
The **GsDevKit_home** environment expects:
1. The **GS_HOME** environmnet variable to reference the root directory of the 
[GsDdevKit_home][6] installation.
2. The name of the stone is enough to identify where the GemStone/S 64 product
tree is located as well as where the default [`.topazini` file][5] is located.
### topaz script invocation
A command line invocation of the `hello.tpz` script using the 
[GsDevKit_home](#gsdevkit_home) environment would look like the following:
```bash
bash> hello.tpz MyStone -lq
hello world
```
### smalltalk script invocation
A command line invocation of the `hello.st` script using the 
[classic GemStone](#classic-gemstone) environment would look like the following:
```bash
bash> hello.st -- MyStone -lq
Hello World
```
# Installation 




--------------------------------------------------------------------------
--------------------------------------------------------------------------

with GsDevKit_home
**stash** is dependent upon **Rowan** and currently **Rowan** runs on GemStone 3.2.15 and soon to be released GemStone 3.5.0.
```
#	clone Rowan and stash
cd $GS_HOME/shared/repos/
git clone git@github.com:GemTalk/Rowan.git
git clone git@github.com:dalehenrich/stash.git

#	create the stash stone ... scripts will be run in the context of this stone
createStone -g stash_3215 3.2.15

#	link to script for building/rebuilding the stash stone
cd $GS_HOME/server/stones/stash_3215
ln -s $GS_HOME/shared/repos/stash/gemstone/gsdevkit/newBuild_SystemUser_stash .
./newBuild_SystemUser_stash

#	create /usr/bin/gsdevkit and link in the smalltalk and two topaz shell interpretters
cd /usr/bin
sudo mkdir gsdevkit
cd gsdevkit
sudo ln -s $GS_HOME/shared/repos/stash/bin/gsdevkit_smalltalk_interpretter smalltalk
sudo ln -s $GS_HOME/shared/repos/stash/bin/gsdevkit_smalltalk_350_interpretter smalltalk_350
sudo ln -s $GS_HOME/shared/repos/stash/bin/gsdevkit_topaz_interpretter topaz
sudo ln -s $GS_HOME/shared/repos/stash/bin/gsdevkit_topaz_350_interpretter topaz_350
```
### Installation into an existing Rowan stone
```
| url |
url := 'file:$ROWAN_PROJECTS_HOME/stash/rowan/specs/stash.ston'.
Rowan projectTools clone
	cloneSpecUrl: url
	gitRootPath: '$ROWAN_PROJECTS_HOME'
	useSsh: true.
Rowan projectTools load loadProjectNamed: 'stash'.
```
### Creating a GemStone Smalltalk script
The following shell script creates a template script file:
```
$GS_HOME/server/stones/stash_3215/bin/CreateNewStashScript.st --help

$GS_HOME/server/stones/stash_3215/bin/CreateNewStashScript.st --name=MyScript
```
It is worth noting that *CreateNewStashScript.st* itself is a smalltalk shell script:
```smalltalk
#!/usr/bin/smalltalk
"
a Stash Script
"
Class {
	#name : 'CreateNewStashScript',
	#superclass : 'StashScript',
	#category : 'Stash-Scripts'
}

{ #category : 'script execution' }
CreateNewStashScript >> executeScript [
	"Called to initiate execution of the script"
	^ opts
			at: 'help'
			ifAbsent: [ 
				| scriptName scriptDir |
				scriptDir := self workingDirectory asFileReference.
				opts at: 'dir'
					ifPresent: [:dirPath | scriptDir := dirPath asFileReference ].
				scriptDir isAbsolute
					ifFalse: [ scriptDir := self workingDirectory asFileReference / scriptDir ].
				scriptName := opts at: 'name' ifAbsent: [ self error: 'reguired argument `--name` not present' ].
				Rowan classTools stashClassTool
					createScriptClassNamed: scriptName 
					inDirectory: scriptDir fullName ]
			ifPresent: [ self usage ]
]

{ #category : 'script execution' }
CreateNewStashScript >> scriptOptions [
	"specify the command line options"
	^ {
			#('help' $h #none).
			#('name' nil #required).
			#('dir' nil #required).
	}
]

{ #category : 'usage' }
CreateNewStashScript >> usage [
	"Man page for script"
	| dashes |
	dashes := '----------------------------------------------------
'.
	^ dashes,
		(self manPageClass
			fromString:
'NAME
	CreateNewStashScript.st - create a new script template
SYNOPSIS
	CreateNewStashScript.st [-h|--help] [--dir=<directory-path>]--name=<script-name> \
		[ -- <startTopaz-specific-options> ]
DESCRIPTION

	This script creates a new stash script name <script-name>.st in the current
	directory. 

	The `--dir` option may be used to create a script in an alternate location.
	The `--dir` option may be an absolute path or a path relative to the 
	current directory.

	Use the env var GEMSTONE_SCRIPT_ARGS to define default <stone-name> and other
	topaz arguments (<startTopaz-specific-options>) to be used when running scripts.

	For complete details about <startTopaz-specific-options> see `startTopaz -h`. Typically,
	you will specify the name of the stone and along with the `-lq` flags.

EXAMPLES
	CreateNewStashScript.st --help
	CreateNewStashScript.st -h

	CreateNewStashScript.st -h -- myStone -lq

	CreateNewStashScript.st --name=MyScript
	CreateNewStashScript.st --name=MyScript --dir=/home/me/bin
') printString, dashes
]
```
### Rowan project creation script
```smalltalk
"Create GsDevKit_upgrade project"

	| projectUrl projectName configurationNames groupNames comment projectHome
		cpd packageName |

	projectName := 'stash'.
	configurationNames := #( 'Main' ).
	groupNames := #( 'core' ).
	projectUrl := 'https://github.com/dalehenrich/', projectName.
	comment := 'command line scripting support'.

	projectHome := '$ROWAN_PROJECTS_HOME'.

"create project definition"
	cpd := RwComponentProjectDefinition
		projectName: projectName 
			configurationNames: configurationNames 
			groupNames: groupNames 
			useGit: true 
			projectUrl: projectUrl 
			comment: comment.

"create package definitions"
	cpd
		addPackageNamed: projectName, '-Core' 
			toComponentNamed: 'Main' 
			withConditions: #( 'common' ) 
			andGroup: 'core';
		yourself.

"create class and method definitions"
	packageName := projectName, '-Core'.

"prepare to export component project definition"
	cpd projectHome: projectHome.
	cpd repositoryRoot ensureDeleteAll.

"create component project on disk"
	cpd create.
```

[1]: https://downloads.gemtalksystems.com/docs/GemStone64/3.4.x/GS64-ProgGuide-3.4/GS64-ProgGuide-3.4.htm
[2]: https://downloads.gemtalksystems.com/docs/GemStone64/3.4.x/GS64-Topaz-3.4/GS64-Topaz-3.4.htm
[3]: scripts/hello.tpz
[4]: scripts/hello.st
[5]: https://downloads.gemtalksystems.com/docs/GemStone64/3.4.x/GS64-Topaz-3.4/1-Tutorial.htm#pgfId-923343
[6]: https://github.com/GsDevKit/GsDevKit_home
