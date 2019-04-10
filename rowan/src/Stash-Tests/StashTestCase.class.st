Class {
	#name : 'StashTestCase',
	#superclass : 'RwAbstractTest',
	#category : 'Stash-Tests'
}

{ #category : 'tests' }
StashTestCase >> testScriptLoad [

	| projectName rowanSpec repoRoot packageName audit className meth stashPackageName |
	projectName := 'TestScriptLoad'.
	packageName := 'TestScriptLoad-Script'.
	stashPackageName := packageName, '_1'.
	className:= 'Sample'.

	(Rowan image loadedProjectNamed: projectName ifAbsent: [  ])
		ifNotNil: [ :prj | Rowan image _removeLoadedProject: prj ].

	rowanSpec := (Rowan image _projectForNonTestProject: 'stash') specification.

	repoRoot := rowanSpec repositoryRootPath asFileReference.

	Rowan classTools stashClassTool 
		loadTonelClassFiles: {repoRoot / 'bin' / 'sample.st' } 
			projectName: projectName 
			packageName: packageName
			symDictName: self _symbolDictionaryName1.

	self assert: (Rowan globalNamed: 'Sample') notNil.

	audit := Rowan projectTools audit auditForProjectNamed: projectName.
	self assert: audit isEmpty.

	meth := (Rowan globalNamed: className)
		compiledMethodAt: #usage.
	self assert: meth rowanProjectName = projectName.
	self assert: meth rowanPackageName = stashPackageName.

	Rowan projectTools browser 
		addOrUpdateMethod: 'foo ^1' 
		inProtocol: 'test' 
		forClassNamed: className 
		isMeta: false 
		inPackageNamed: stashPackageName.

	audit := Rowan projectTools audit auditForProjectNamed: projectName.
	self assert: audit isEmpty.
]
