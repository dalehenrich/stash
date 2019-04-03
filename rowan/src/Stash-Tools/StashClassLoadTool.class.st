"
""Load a single tonel class file""
Rowan classTools stashClassLoadTool loadTonelClassFile: '$GS_HOME/shared/repos/stash/bin/sample.st'.

""Load several class directories from filetree repo in once load""
Rowan classTools stashClassLoadTool loadFiletreeClassDirectories:
	{
		'$GS_HOME/shared/repos/stash/tode/TDCommandGetOpts.class'.
		'$GS_HOME/shared/repos/stash/tode/TDCommandGetOptsTestCase.class'.
		'$GS_HOME/shared/repos/stash/tode/TDCommandLine.class'.
		'$GS_HOME/shared/repos/stash/tode/TDCommandLineTestCase.class'.
	}
"
Class {
	#name : 'StashClassLoadTool',
	#superclass : 'RwClassTool',
	#category : 'Stash-Tools'
}

{ #category : 'loading' }
StashClassLoadTool >> loadFiletreeClassDirectories: directoryPathArray [

	| projectDefinition |
	projectDefinition := RwRepositoryComponentProjectFiletreeReaderVisitor readClassDirectories: directoryPathArray.
	Rowan projectTools load loadProjectDefinition: projectDefinition.
	^ projectDefinition
]

{ #category : 'loading' }
StashClassLoadTool >> loadFiletreeClassDirectory: directoryPath [

	| projectDefinition |
	projectDefinition := RwRepositoryComponentProjectFiletreeReaderVisitor readClassDirectory: directoryPath.
	Rowan projectTools load loadProjectDefinition: projectDefinition.
	^ projectDefinition
]

{ #category : 'loading' }
StashClassLoadTool >> loadTonelClassFile: filePath [

	| projectDefinition |
	projectDefinition := RwRepositoryComponentProjectTonelReaderVisitor readClassFile: filePath.
	Rowan projectTools load loadProjectDefinition: projectDefinition.
	^ projectDefinition
]

{ #category : 'loading' }
StashClassLoadTool >> loadTonelClassFiles: filePathArray [

	| projectDefinition |
	projectDefinition := RwRepositoryComponentProjectTonelReaderVisitor readClassFiles: filePathArray.
	Rowan projectTools load loadProjectDefinition: projectDefinition.
	^ projectDefinition
]
