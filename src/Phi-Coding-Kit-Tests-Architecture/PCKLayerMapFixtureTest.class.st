"
The self-test proving PCKLayerMapFixture is real and self-cleaning, so a green layer-map
check result over it later cannot be vacuous (R-37). Each test installs the scratch
mini-fixture, asserts, and tears it down from an ensure: block so cleanup runs even when an
assertion fails; the scratch classes are reached by symbol lookup since they exist only
between install and remove.
"
Class {
	#name : 'PCKLayerMapFixtureTest',
	#superclass : 'TestCase',
	#category : 'Phi-Coding-Kit-Tests-Architecture',
	#package : 'Phi-Coding-Kit-Tests-Architecture'
}

{ #category : 'tests' }
PCKLayerMapFixtureTest >> testEachPlantedClassReportsItsOwnPackage [
	"By-defining-package attribution is honest: each scratch class names its own package, so
	the walk's per-class layer lookup will be truthful."
	[
	PCKLayerMapFixture install.
	self
		assert: (Smalltalk globals at: #PCKScratchUiView) package name
		equals: PCKLayerMapFixture uiPackageName.
	self
		assert: (Smalltalk globals at: #PCKScratchDomainModel) package name
		equals: PCKLayerMapFixture domainPackageName.
	self
		assert: (Smalltalk globals at: #PCKScratchPersistenceStore) package name
		equals: PCKLayerMapFixture persistencePackageName ]
		ensure: [ PCKLayerMapFixture remove ]
]

{ #category : 'tests' }
PCKLayerMapFixtureTest >> testInstallCreatesThreeDistinctPackages [
	"install resolves each of the three package names to a distinct loaded package and puts the
	four scratch classes into the system."
	| packages |
	[
	PCKLayerMapFixture install.
	packages := PCKLayerMapFixture packageNames collect: [ :name |
		PackageOrganizer default packageNamed: name ifAbsent: [ nil ] ].
	self assert: (packages allSatisfy: [ :each | each notNil ]).
	self assert: packages asSet size equals: 3.
	PCKLayerMapFixture classNames do: [ :className |
		self assert: (Smalltalk globals includesKey: className) ] ]
		ensure: [ PCKLayerMapFixture remove ]
]

{ #category : 'tests' }
PCKLayerMapFixtureTest >> testPlantedForbiddenReferenceIsPresent [
	"The ui -> persistence plant the check must catch is genuinely in the fixture: the
	referenced classes of PCKScratchUiView>>#usesPersistence, normalized to instance side,
	include PCKScratchPersistenceStore."
	| referenced |
	[
	PCKLayerMapFixture install.
	referenced := ((Smalltalk globals at: #PCKScratchUiView) >> #usesPersistence)
		referencedClasses collect: [ :each | each instanceSide ].
	self assert: (referenced includes: (Smalltalk globals at: #PCKScratchPersistenceStore)) ]
		ensure: [ PCKLayerMapFixture remove ]
]

{ #category : 'tests' }
PCKLayerMapFixtureTest >> testRemoveLeavesNoResidue [
	"After install then remove, no scratch package resolves and no scratch class is in the
	globals - and a second remove raises nothing (guarded teardown)."
	[
	PCKLayerMapFixture install.
	PCKLayerMapFixture remove.
	PCKLayerMapFixture packageNames do: [ :name |
		self assert: (PackageOrganizer default packageNamed: name ifAbsent: [ nil ]) isNil ].
	PCKLayerMapFixture classNames do: [ :className |
		self deny: (Smalltalk globals includesKey: className) ].
	PCKLayerMapFixture remove ]
		ensure: [ PCKLayerMapFixture remove ]
]
