#!/usr/bin/gsdevkit/smalltalk_350
"
Make a snapshot of the extent files for the current stone
"
Class {
     #name : 'GemStoneSnapshotScript',
     #superclass : 'StashScript',
     #category : 'Stash-Scripts'
}

{ #category : 'script execution' }
GemStoneSnapshotScript >> scriptOptions [
	^ {
			#('help' $h #'none').
			#('safely' $a #'none').
			#('commit' $r #'none').
			#('suspend' $i #'required').
			#('dir' $n #'required').
	}
]

{ #category : '' }
GemStoneSnapshotScript >> commit [

	self deleteScriptProject.
	super commit.
]

{ #category : 'script execution' }
GemStoneSnapshotScript >> executeScript [

	opts
		at: 'help'
    ifAbsent: [
			| snapshotExtension snapshotPath suspendInMinutes safely snapShots |
			args size < 1
				ifTrue: [ self error: 'Required argument <snapshot-extension> missing.' ].
			snapshotExtension := args at: 1.
			snapshotPath := '$GS_HOME/server/stones/' , self stoneName , '/snapshots'.
			suspendInMinutes := 15.
			safely := false.
			opts at: 'commit' ifPresent: [:ignored | self commit ].
			snapShots := Rowan stashTools gemstone
				snapshot: snapshotExtension 
				to: snapshotPath 
				suspendInMinutes: suspendInMinutes 
				safely: safely.
			snapShots do: [:snapShotFileRef |
				| resultString |
				resultString := GsHostProcess execute: '/bin/chmod -w ', snapShotFileRef pathString.
				GsFile stdout nextPutAll: resultString ] ] 
    ifPresent: [ ^ self usage ]
]

{ #category : 'usage' }
GemStoneSnapshotScript >> usage [
	| dashes |
	dashes := '----------------------------------------------------
'.
  GsFile stdout nextPutAll: dashes,
		(self manPageClass
          fromString:
'NAME
	snapshot - Make a snapshot of the extent files for the current stone.

SYNOPSIS
  snapshot [ --safely ] [ --suspend=<minutes> ] \
		[ --dir=<snapshot-directory> ] <snapshot-extension>

DESCRIPTION
  Make a snapshot copy of the extent files: 

    1. Suspend checkpoints. By default, checkpoints will be suspended for 15 
       minutes. If that may not be enough time, you can specify the number of 
       minutes to suspend the checkpoints with the --suspend option.
    2. Copy the extent files to the <snapshot-directory>. (replacing the `.dbf` 
       file extension with the given <snapshot-file-extension>). The default 
			 directory is the snapshot directory for the stone.
    3. Resume checkpoints. Since checkpoints are explicitly resumed after the
       copies have been made, it does not hurt to be generous with the 
       --suspend option.
  
  With the --safely option specified, the snapshot will (quietly) be skipped if
  the target snapshot already exists.

  With the --commit options specificied, a commit will be performed before the 
	checkpoints are enabled. A commit is needed to ensure that checkpoint processing
	is not delayed (I think).

EXAMPLES
	snapshot.st --help
	snapshot.st sample.dbf
	snapshot.st --commit sample.dbf
	snapshot.st --safely sample.dbf
	snapshot.st --dir=$GS_HOME/gemstone/snapshots sample.dbf

	snapshot.st solo.dbf

') printString, dashes
]
