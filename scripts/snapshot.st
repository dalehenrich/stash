#!/usr/bin/gsdevkit/smalltalk_350
"
Make a snapshot of the extent files for the current stone
"
Class {
     #name : 'GemStone_Snapshot',
     #superclass : 'StashScript',
     #category : 'Stash-Scripts'
}

{ #category : 'script execution' }
GemStone_Snapshot >> scriptOptions [
	^ {
			#('help' $h #'none').
			#('safely' $a #'none').
			#('commit' $r #'none').
			#('suspend' $i #'required').
			#('dir' $n #'required').
	}
]

{ #category : 'script execution' }
GemStone_Snapshot >> executeScript [

	opts
		at: 'help'
    ifAbsent: [
			| snapshotExtension snapshotPath suspendInMinutes safely |
			(snapshotExtension := args atOrNil: 1)
				ifNil: [ self error: 'Required argument <snapshot-extension> missing.' ].
			snapshotPath := '$GS_HOME/server/stones/' , self stoneName , '/snapshots'.
			suspendInMinutes := 15.
			safely := false.
			Rowan stashTools gemstone
				snapshot: snapshotExtension 
				to: snapshotPath 
				suspendInMinutes: suspendInMinutes 
				safely: safely
				] 
    ifPresent: [ ^ self usage ]
]

{ #category : 'usage' }
GemStone_Snapshot >> usage [
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

  A commit is always performed immediately before the checkpoints are enabled.

EXAMPLES
	snapshot.st --help
	snapshot.st sample.dbf
	snapshot.st --safely sample.dbf
	snapshot.st --dir=$GS_HOME/gemstone/snapshots sample.dbf

') printString, dashes
]
