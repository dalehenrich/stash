Class {
	#name : 'StashClassLoadTool',
	#superclass : 'RwClassTool',
	#category : 'Stash-Tools'
}

{ #category : 'loading' }
StashClassLoadTool >> loadTonelClassFile: filepath [

	| projectDefinition |
	projectDefinition := RwRepositoryComponentProjectTonelReaderVisitor readClassFile: filepath.
self halt.
]

{ #category : 'loading' }
StashClassLoadTool >> loadTonelClassFileXX: filepath [

	| reader fileName definitions snapshot cypressLoader patch |
	reader := TonelCypressReader new.
	fileName := '/home/dhenrich/rogue/_homes/rogue/_home/server/stones/gs_350_g/sample.st'.
	definitions := (reader fileUtils
		readStreamFor: fileName
	  do: [ :s | 
			s nextLine. "skip the first line with #!"
			TonelParser parseStream: s forReader: reader ]) flattened.
	snapshot := CypressSnapshot definitions: definitions.

	cypressLoader := CypressLoader new.
	patch := snapshot patchRelativeToBase: CypressSnapshot empty.
	patch := CypressSnapshot empty patchRelativeToBase: snapshot.
	patch applyTo: cypressLoader.
	snapshot definitions do: [:ea | cypressLoader provisions addAll: ea provisions].
	cypressLoader load.
]
