"
The behavioral suite check (spec ch. 5 par. 5.2): one tests-role package name, kind #behavioral. Zero concrete test classes in the package makes the verdict missing (R-24, D-21 - silence is never a pass; no cache pull happens in that arm); otherwise the construction-handed PCKSuiteRunCache is pulled - this check never runs suites itself and never builds a cache (D-60: everything it knows, it was given) - and each failure/error in the TestResult becomes one Class>>#selector finding ('failed' / 'errored'; no rationale - par. 5.2 gives these findings none). Passed, skipped, and expected-failure tests produce no findings here - skips are the meta-rule's subject (par. 5.3's precision split). Red iff any finding, else green. Constructed via the kit-side package:cache: (par. 5.4's kit-custom wiring); it fills the skeleton's packages storage so the generic reader stays truthful.
"
Class {
	#name : 'PCKTestSuiteCheck',
	#superclass : 'PGRCheck',
	#instVars : [
		'package',
		'cache'
	],
	#category : 'Phi-Coding-Kit-Behavioral',
	#package : 'Phi-Coding-Kit-Behavioral'
}

{ #category : 'instance creation' }
PCKTestSuiteCheck class >> package: aPackageName cache: aSuiteRunCache [
	"Kit-side constructor (par. 5.4): the kit constructs its own behavioral checks
	directly. Also fills the inherited skeleton storage so the generic packages
	reader stays truthful for any protocol-level reader."
	^ (self packages: { aPackageName })
		setPackage: aPackageName cache: aSuiteRunCache;
		yourself
]

{ #category : 'accessing' }
PCKTestSuiteCheck >> cache [
	"Internal reader: the kit's wiring test (C05) reads it."
	^ cache
]

{ #category : 'accessing' }
PCKTestSuiteCheck >> kind [
	^ #behavioral
]

{ #category : 'accessing' }
PCKTestSuiteCheck >> package [
	"Internal reader: the kit's wiring test (C05) reads it."
	^ package
]

{ #category : 'running' }
PCKTestSuiteCheck >> run [
	"Par. 5.2's whole law. The zero-test-classes question is asked of the shared
	C02 query, never re-derived; that arm pulls no cache."
	| result findings |
	(PCKSuiteRunCache testClassesIn: package)
		ifEmpty: [ ^ PGRVerdict missingReason:
				package , ' is registered as a tests-role package but contains no tests' ].
	result := cache resultsForPackage: package.
	findings := OrderedCollection new.
	result failures do: [ :each |
		findings add: (PGRFinding target: (self targetFor: each) message: 'failed') ].
	result errors do: [ :each |
		findings add: (PGRFinding target: (self targetFor: each) message: 'errored') ].
	^ findings
		ifEmpty: [ PGRVerdict green ]
		ifNotEmpty: [ PGRVerdict redFindings: findings ]
]

{ #category : 'private' }
PCKTestSuiteCheck >> setPackage: aPackageName cache: aSuiteRunCache [
	package := aPackageName.
	cache := aSuiteRunCache
]

{ #category : 'private' }
PCKTestSuiteCheck >> targetFor: aTestCaseInstance [
	"The fixed target form: class name, >>#, selector (spelling verified live)."
	^ aTestCaseInstance class name , '>>#' , aTestCaseInstance selector
]
