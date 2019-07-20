Extension { #name : 'StashScript' }

{ #category : '*stash-gemstone-core' }
StashScript >> _downloadErrorFileNameFor: outputFileName [
	| pid |
	pid := (System gemVersionReport at: 'processId') printString.
	^ '/tmp/curl-' , pid , '-' , (outputFileName select: [ :c | c isAlphaNumeric ])
		, '.err'
]

{ #category : '*stash-gemstone-core' }
StashScript >> commit [
	"Commits are not allowed when running with a solo session, so skip the commit if running against a solo extent"

	self sessionIsSolo
		ifTrue: [^ true ].
	^ System commit
]

{ #category : '*stash-gemstone-core' }
StashScript >> downloadHttpsFile: httpsUrl to: outputFileName username: username pass: pass [
	"download from <httpsUrl> into <outputFileName>"

	| errorFileName theArgs |
	"Make a unique name for the error log and ensure that we can write the files"
	errorFileName := self _downloadErrorFileNameFor: outputFileName.
	outputFileName asFileReference ensureCreateFile.
	errorFileName asFileReference ensureCreateFile.
	theArgs := username ifNotNil: [ ' -u ' , username , ':' , pass ] ifNil: [ '' ].
	System
		performOnServer:
			'/usr/bin/curl' , theArgs , ' -L ' , httpsUrl , ' > ' , outputFileName , ' 2> '
				, errorFileName.
	^ errorFileName
]

{ #category : '*stash-gemstone-core' }
StashScript >> sessionIsSolo [

	^(GsSession respondsTo: #isSolo)
		ifTrue: [ GsSession perform: #isSolo ]
		ifFalse: [ false ]
]

{ #category : '*stash-gemstone-core' }
StashScript >> stderr [

	^ GsFile stderr
]

{ #category : '*stash-gemstone-core' }
StashScript >> stdout [

	^ GsFile stdout
]
