"
The no-skips meta-rule (spec ch. 5 par. 5.3; R-25), kind #behavioral: reads the same result objects the suite registrations use through the construction-handed PCKSuiteRunCache, pulled per package and never by run order (D-36) - the lazy cache runs any suite not yet run, so a meta-rule running first or alone cannot fail open, while in a full run every result is already cached and nothing runs twice. One finding per skipped test ('skipped') and per expected failure ('expected failure'), target Class>>#selector (C03's verified form), each carrying the class-side rationale; red iff any finding, else green. An empty handed list is green here - vacuity is covered one level up by the kit's behavioral/tests-role missing registration (par. 5.1). Failures and errors are the suite check's findings, never this rule's, and the suspicious-shapes sweep is a separate widened meta-rule at M5 - par. 5.3's zero-false-positive precision (D-08). Constructed via the kit-side packages:cache: (par. 5.4); the promised one-argument packages: stays inherited and untouched - a client class named in #metaRules takes that generic path and reaches no cache.
"
Class {
	#name : 'PCKNoSkippedTestsMetaRule',
	#superclass : 'PGRCheck',
	#instVars : [
		'cache'
	],
	#category : 'Phi-Coding-Kit-Behavioral',
	#package : 'Phi-Coding-Kit-Behavioral'
}

{ #category : 'instance creation' }
PCKNoSkippedTestsMetaRule class >> packages: testsPackageNames cache: aSuiteRunCache [
	"Kit-side constructor (par. 5.4): the kit constructs this, its own class, with the
	shared run cache (C05 special-cases it). Fills the inherited skeleton storage so
	the generic packages reader stays truthful."
	^ (self packages: testsPackageNames)
		setCache: aSuiteRunCache;
		yourself
]

{ #category : 'accessing' }
PCKNoSkippedTestsMetaRule class >> rationale [
	"The ruled wording (par. 5.3): doubles as agent guidance and is emitted with every finding."
	^ 'a skipped or expected-failure test is a disabled check — P6 makes disabling a build failure; re-enable the test or delete it via a reviewed diff.'
]

{ #category : 'accessing' }
PCKNoSkippedTestsMetaRule >> cache [
	"Internal reader: the kit's wiring test (C05) reads it."
	^ cache
]

{ #category : 'private' }
PCKNoSkippedTestsMetaRule >> findingOn: aTestCaseInstance message: aMessageString [
	"C03's verified Class>>#selector target form, reused - never re-derived."
	^ PGRFinding
		target: aTestCaseInstance class name , '>>#' , aTestCaseInstance selector
		message: aMessageString
		rationale: self class rationale
]

{ #category : 'accessing' }
PCKNoSkippedTestsMetaRule >> kind [
	^ #behavioral
]

{ #category : 'running' }
PCKNoSkippedTestsMetaRule >> run [
	"Par. 5.3's whole law: the same result objects the suite checks read, pulled per
	package from the handed cache, never by run order (D-36) - the lazy pull means
	running first or alone cannot fail open; no second run, no static heuristics
	(D-08). An empty handed list falls through green - vacuity is the kit's
	behavioral/tests-role missing registration (par. 5.1), one level up."
	| findings |
	findings := OrderedCollection new.
	self packages do: [ :packageName |
		| result |
		result := cache resultsForPackage: packageName.
		result skipped do: [ :each |
			findings add: (self findingOn: each message: 'skipped') ].
		result expectedDefects do: [ :each |
			findings add: (self findingOn: each message: 'expected failure') ] ].
	^ findings
		ifEmpty: [ PGRVerdict green ]
		ifNotEmpty: [ PGRVerdict redFindings: findings ]
]

{ #category : 'private' }
PCKNoSkippedTestsMetaRule >> setCache: aSuiteRunCache [
	cache := aSuiteRunCache
]
