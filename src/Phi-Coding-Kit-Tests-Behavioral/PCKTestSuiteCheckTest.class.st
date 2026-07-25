"
Pins the behavioral suite check (spec ch. 5 par. 5.2): red with exact Class>>#selector findings over the planted red fixture package (passes, skips, and the expected failure produce none - the par. 5.3 precision split), green over the always-green Phi-Guardrails-Tests-SDK mirror package (the par. 5.5 pair's good half, R-37), and missing on a loaded package with zero test classes (R-24, D-21). A fourth method, testMissingOnEmptyTestsRole, is added by E07-C05 (kit-derivation ground). Swept, green-only.
"
Class {
	#name : 'PCKTestSuiteCheckTest',
	#superclass : 'TestCase',
	#category : 'Phi-Coding-Kit-Tests-Behavioral',
	#package : 'Phi-Coding-Kit-Tests-Behavioral'
}

{ #category : 'tests' }
PCKTestSuiteCheckTest >> testGreenOnPassingSuite [
	"The good half of the behavioral fixture pair (R-37): a real, always-green, no-skips mirror package - the nested 19-test re-run is bounded and stateless."
	| verdict |
	verdict := (PCKTestSuiteCheck
		package: 'Phi-Guardrails-Tests-SDK'
		cache: PCKSuiteRunCache new) run.
	self assert: verdict isGreen.
	self assertEmpty: verdict findings
]

{ #category : 'tests' }
PCKTestSuiteCheckTest >> testMissingOnPackageWithoutTestClasses [
	"R-24's zero-test-classes arm: a tests-role package with nothing to run is never silently green - the verdict is missing (D-21), its reason naming the package."
	| verdict |
	verdict := (PCKTestSuiteCheck
		package: 'Phi-Coding-Kit'
		cache: PCKSuiteRunCache new) run.
	self assert: verdict status equals: #missing.
	self assert: (verdict missingReason includesSubstring: 'Phi-Coding-Kit')
]

{ #category : 'tests' }
PCKTestSuiteCheckTest >> testRedOnFailingSuite [
	"Par. 5.2's red arm over the planted fixture package: exactly one finding per failure and per error, asserted as a set - the result's failures/errors collections guarantee no order. The passing and skipping classes produce no finding, and the expected failure is not a failure (D-15 trap pinned at the check level)."
	| check verdict pairs |
	check := PCKTestSuiteCheck
		package: 'Phi-Coding-Kit-Fixtures-Behavioral'
		cache: PCKSuiteRunCache new.
	verdict := check run.
	self assert: check kind equals: #behavioral.
	self assert: verdict status equals: #red.
	self deny: verdict isGreen.
	self assert: verdict findings size equals: 2.
	pairs := (verdict findings collect: [ :each | each target -> each message ]) asSet.
	self assert: pairs equals: {
		'PCKFailingFixtureTest>>#testAlwaysFails' -> 'failed'.
		'PCKFailingFixtureTest>>#testAlwaysErrors' -> 'errored' } asSet
]
