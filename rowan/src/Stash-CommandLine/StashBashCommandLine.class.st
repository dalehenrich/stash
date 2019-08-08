"
Command line parser to be used to parse command lines that may be used in a bash script. Specifically, use $"" as the argument delimiter instead of $`.
"
Class {
	#name : 'StashBashCommandLine',
	#superclass : 'StashCommandLine',
	#category : 'Stash-CommandLine'
}

{ #category : 'accessing' }
StashBashCommandLine >> getOptsParserClass [

	^ StashBashCommandGetOpts
]
