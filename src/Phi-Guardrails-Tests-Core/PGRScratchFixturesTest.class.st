"
Sanity suite for the C20 scratch client fixtures: pins the D-25.a declaration/expansion behavior of the two scratch baselines on this repo's own image, and witnesses the D-53 duck-typed kit (conformance, not ancestry).
"
Class {
	#name : 'PGRScratchFixturesTest',
	#superclass : 'TestCase',
	#category : 'Phi-Guardrails-Tests-Core',
	#package : 'Phi-Guardrails-Tests-Core'
}

{ #category : 'accessing' }
PGRScratchFixturesTest >> groupedVersion [
	^ BaselineOfPGRScratchGrouped project version
]

{ #category : 'accessing' }
PGRScratchFixturesTest >> packageNamesFor: aGroupName [
	"D-25.a trap: an unknown group name answers empty, no error — callers assert exact sets."
	^ ((self groupedVersion packagesForSpecNamed: aGroupName) collect: [ :each | each name ]) asSortedCollection asArray
]

{ #category : 'tests' }
PGRScratchFixturesTest >> testCompositeGroupExpandsTransitively [
	self
		assert: (self packageNamesFor: 'scratch-both')
		equals: #( 'Phi-Guardrails-SDK' 'Phi-Guardrails-Core' 'PGR-Scratch-Ghost' ) sorted
]

{ #category : 'tests' }
PGRScratchFixturesTest >> testEmptyGroupExpandsEmpty [
	"D-25.a addendum, pinned on this image: a declared-empty group expands to nothing."
	self assertEmpty: (self groupedVersion packagesForSpecNamed: 'scratch-empty')
]

{ #category : 'tests' }
PGRScratchFixturesTest >> testGhostPackageDeclaredButUnloaded [
	"Declaration is inventory, not loadedness (spec ch. 1 par. 1.1)."
	self assert: ((self groupedVersion packages collect: [ :each | each name ]) includes: 'PGR-Scratch-Ghost').
	self assert: (PackageOrganizer default packageNamed: 'PGR-Scratch-Ghost' ifAbsent: [ nil ]) isNil
]

{ #category : 'tests' }
PGRScratchFixturesTest >> testGroupExpansionMatchesDeclaration [
	self
		assert: (self packageNamesFor: 'scratch-prod')
		equals: #( 'Phi-Guardrails-SDK' 'Phi-Guardrails-Core' ) sorted
]

{ #category : 'tests' }
PGRScratchFixturesTest >> testGroupedBaselineDeclaresItsTree [
	| version |
	version := self groupedVersion.
	self
		assert: (version packages collect: [ :each | each name ]) asSet
		equals: #( 'Phi-Guardrails-SDK' 'Phi-Guardrails-Core' 'Phi-Guardrails-Tests-SDK' 'PGR-Scratch-Ghost' ) asSet.
	self
		assert: (version groups collect: [ :each | each name ]) asSet
		equals: #( 'scratch-prod' 'scratch-tst' 'scratch-ghost' 'scratch-overlap' 'scratch-empty' 'scratch-both' ) asSet
]

{ #category : 'tests' }
PGRScratchFixturesTest >> testPlainBaselineHasNoGroups [
	"P-ROLES-FROM-CONFIG's subject: role groups in a client's baseline are optional, never required."
	| version |
	version := BaselineOfPGRScratchPlain project version.
	self assertEmpty: version groups.
	self
		assert: (version packages collect: [ :each | each name ]) asSet
		equals: #( 'Phi-Guardrails-SDK' 'Phi-Guardrails-Core' 'Phi-Guardrails-Tests-SDK' ) asSet
]

{ #category : 'tests' }
PGRScratchFixturesTest >> testScratchKitConformsClassSide [
	"Conformance, not ancestry (D-53): the kit fixture answers the pair without inheriting PGRKit."
	self assert: (PGRScratchKit respondsTo: #recommendedBlock).
	self assert: (PGRScratchKit respondsTo: #registrationsFrom:productionPackages:testsPackages:).
	self assertEmpty: (PGRScratchKit registrationsFrom: Dictionary new productionPackages: #(  ) testsPackages: #(  )).
	self assert: PGRScratchKit recommendedBlock isString.
	self deny: (PGRScratchKit inheritsFrom: PGRKit)
]
