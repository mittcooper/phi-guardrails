"
The run-scoped suite result cache (spec ch. 5 par. 5.4): one instance per registry construction, closed over by that run's behavioral registrations and discarded with them, so every reader shares one package run (D-36) without any global state (R-35). The public protocol is the single message resultsForPackage: - the bulk reader was deliberately deleted (D-36) - and plain new is the whole construction: no setters exist for a named constructor to name. The test-class query is class-side so the suite check's zero-test-classes decision (C03) asks exactly the question this runner answers.
"
Class {
	#name : 'PCKSuiteRunCache',
	#superclass : 'Object',
	#instVars : [
		'results'
	],
	#category : 'Phi-Coding-Kit-Behavioral',
	#package : 'Phi-Coding-Kit-Behavioral'
}

{ #category : 'accessing' }
PCKSuiteRunCache class >> testClassesIn: aPackageName [
	"Par. 5.2 step 1's filter: classes defined in the package that inherit from TestCase and answer isAbstract false. Sorted by name - definedClasses order is not guaranteed, and P2 wants a deterministic answer."
	^ ((PackageOrganizer default packageNamed: aPackageName) definedClasses
		select: [ :each | (each inheritsFrom: TestCase) and: [ each isAbstract not ] ])
		sorted: [ :a :b | a name < b name ]
]

{ #category : 'initialization' }
PCKSuiteRunCache >> initialize [
	super initialize.
	results := Dictionary new
]

{ #category : 'accessing' }
PCKSuiteRunCache >> resultsForPackage: aPackageName [
	"Lazily runs par. 5.2 step 1 on the first pull per package and answers the identical cached TestResult thereafter (D-36's single-run guarantee)."
	^ results at: aPackageName ifAbsentPut: [ self runSuiteForPackage: aPackageName ]
]

{ #category : 'private' }
PCKSuiteRunCache >> runSuiteForPackage: aPackageName [
	"One aggregate suite filled from each class's buildSuite, run once - one TestResult per package. Private: the one-message law binds the public protocol."
	| suite |
	suite := TestSuite new.
	(self class testClassesIn: aPackageName) do: [ :each |
		suite addTests: each buildSuite tests ].
	^ suite run
]
