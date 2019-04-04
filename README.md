# stash
smalltalk shell - new life for an old idea (http://seaside.gemtalksystems.com/ss/stash.html)

### Installation with GsDevKit_home
**stash** is dependent upon **Rowan** and currently **Rowan** runs on GemStone 3.2.15.
```
#	clone Rowan and stash
cd $GS_HOME/shared/repos/
git clone git@github.com:GemTalk/Rowan.git
git clone git@github.com:dalehenrich/stash.git

# create the stash stone ... scripts will be run in the context of this stone
createStone -g stash_3215 3.2.15

# link to script for building/rebuilding the stash stone
cd $GS_HOME/server/stones/stash_3215
ln -s $GS_HOME/shared/repos/stash/gemstone/gsdevkit/newBuild_SystemUser_stash .
./newBuild_SystemUser_stash

# create /usr/bin/smalltalk which is the gemstone shell interpretter for Smalltalk
cd /usr/bin
sudo ln -s $GS_HOME/shared/repos/stash/bin/stash_interpretter smalltalk
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
