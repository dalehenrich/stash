Class {
	#name : 'StashClassLoadTool',
	#superclass : 'RwClassTool',
	#category : 'Stash-Tools'
}

{ #category : 'loading' }
StashClassLoadTool >> loadTonelClassFile: filepath [

	| projectDefinition |
	projectDefinition := RwRepositoryComponentProjectTonelReaderVisitor readClassFile: filepath.
	Rowan projectTools load loadProjectDefinition: projectDefinition.
	^ projectDefinition
]
