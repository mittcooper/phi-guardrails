"
Pinning suite for the behavioral fixtures family (spec ch. 5 par. 5.5): pins BaselineOfPCKFixture's declared shape (empty mandatory production group, tests group = the fixtures package; D-25.a), the D-57 sweep exemption of Phi-Coding-Kit-Fixtures-Behavioral (D-22 pinned by machine), and the planted fixture classes' exact shapes (R-37). Runs no fixture suite - running is C02's ground. Swept, green-only.
"
Class {
	#name : 'PCKBehavioralFixturesTest',
	#superclass : 'TestCase',
	#category : 'Phi-Coding-Kit-Tests-Behavioral',
	#package : 'Phi-Coding-Kit-Tests-Behavioral'
}

{ #category : 'accessing' }
PCKBehavioralFixturesTest >> fixturePackage [
	^ PackageOrganizer default packageNamed: 'Phi-Coding-Kit-Fixtures-Behavioral'
]

{ #category : 'accessing' }
PCKBehavioralFixturesTest >> fixtureVersion [
	"Baseline introspection needs no load (D-25.a)."
	^ BaselineOfPCKFixture project version
]

{ #category : 'accessing' }
PCKBehavioralFixturesTest >> packageNamesFor: aGroupName [
	"D-25.a trap: an unknown group name answers empty, no error - callers assert exact sets."
	^ ((self fixtureVersion packagesForSpecNamed: aGroupName) collect: [ :each | each name ]) asSortedCollection asArray
]

{ #category : 'accessing' }
PCKBehavioralFixturesTest >> plantedTestSelectorsOf: aClass [
	"Locally defined test selectors, sorted - the shapes par. 5.5's finding assertions will name."
	^ (aClass selectors select: [ :each | each beginsWith: 'test' ]) sorted asArray
]

{ #category : 'tests' }
PCKBehavioralFixturesTest >> testAbstractAndNonTestResidentsAreExcludable [
	"The two residents the par. 5.2 filter (C02) must exclude, declared so."
	| defined |
	defined := self fixturePackage definedClasses.
	self assert: (defined includes: PCKAbstractFixtureTest).
	self assert: PCKAbstractFixtureTest isAbstract.
	self assert: (defined includes: BaselineOfPCKFixture).
	self deny: (BaselineOfPCKFixture inheritsFrom: TestCase)
]

{ #category : 'tests' }
PCKBehavioralFixturesTest >> testBaselineDeclaresEmptyProductionGroup [
	"Par. 1.1 makes #production mandatory; an empty group is declared, listed, and expands to nothing (D-25.a addendum)."
	self assert: ((self fixtureVersion groups collect: [ :each | each name ]) includes: 'production').
	self assertEmpty: (self fixtureVersion packagesForSpecNamed: 'production')
]

{ #category : 'tests' }
PCKBehavioralFixturesTest >> testFixturesPackageIsUnswept [
	"D-22 pinned by machine, not by prose: the committed-red package never full-matches the D-57 sweep regex (matchesRegex: is full-match, D-15)."
	self deny: ('Phi-Coding-Kit-Fixtures-Behavioral' matchesRegex: '(Phi-Guardrails|Phi-Coding-Kit)-Tests-.*')
]

{ #category : 'tests' }
PCKBehavioralFixturesTest >> testPlantedFixtureShapesAreExact [
	| defined |
	defined := self fixturePackage definedClasses.
	{ PCKFailingFixtureTest. PCKSkippingFixtureTest } do: [ :each |
		self assert: (each inheritsFrom: TestCase).
		self assert: (defined includes: each) ].
	self assert: (self plantedTestSelectorsOf: PCKFailingFixtureTest) equals: #( testAlwaysErrors testAlwaysFails ).
	self assert: (self plantedTestSelectorsOf: PCKSkippingFixtureTest) equals: #( testExpectedlyFailing testSkippedOnPurpose ).
	self assert: PCKSkippingFixtureTest new expectedFailures equals: #( testExpectedlyFailing )
]

{ #category : 'tests' }
PCKBehavioralFixturesTest >> testTestsGroupExpandsToTheFixturePackage [
	"The scratch tests-role list every later E07 chunk derives by introspection."
	self assert: (self packageNamesFor: 'tests') equals: #( 'Phi-Coding-Kit-Fixtures-Behavioral' )
]
