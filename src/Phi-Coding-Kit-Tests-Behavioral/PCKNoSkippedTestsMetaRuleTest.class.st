"
Pins the no-skips meta-rule (spec ch. 5 par. 5.3): red with exactly the two planted findings over the par. 5.5 scratch shape - the tests-role list derived from BaselineOfPCKFixture by introspection (D-25.a) - whether the cache was warmed the full-run way (par. 1.4 suites-then-meta) or never touched at all (D-36: the lazy pull means running first or alone cannot fail open); green over the always-green Phi-Guardrails-Tests-SDK mirror package (R-37's good half). Constitution par. 3 self-note: this chunk is the machine form of the repo's own no-skips law - once registered (E09, guardrails.ston) the meta-rule sweeps every framework tests-role package, including the class that tests it. Swept, green-only.
"
Class {
	#name : 'PCKNoSkippedTestsMetaRuleTest',
	#superclass : 'TestCase',
	#category : 'Phi-Coding-Kit-Tests-Behavioral',
	#package : 'Phi-Coding-Kit-Tests-Behavioral'
}

{ #category : 'asserting' }
PCKNoSkippedTestsMetaRuleTest >> assertPlantedFindingsOn: aVerdict [
	"Exactly the two planted findings, asserted as a set - the failing class contributes none (failures are the suite check's business, D-08 precision) - and every finding carries the ruled rationale."
	| pairs |
	self assert: aVerdict status equals: #red.
	self deny: aVerdict isGreen.
	self assert: aVerdict findings size equals: 2.
	pairs := (aVerdict findings collect: [ :each | each target -> each message ]) asSet.
	self assert: pairs equals: {
		'PCKSkippingFixtureTest>>#testSkippedOnPurpose' -> 'skipped'.
		'PCKSkippingFixtureTest>>#testExpectedlyFailing' -> 'expected failure' } asSet.
	aVerdict findings do: [ :each |
		self assert: each rationale equals: PCKNoSkippedTestsMetaRule rationale ]
]

{ #category : 'accessing' }
PCKNoSkippedTestsMetaRuleTest >> scratchPackages [
	"The par. 5.5 scratch shape: the tests-role list derived from BaselineOfPCKFixture by introspection (D-25.a spellings, pinned by C01) - the baseline is never Metacello-loaded."
	^ (BaselineOfPCKFixture project version packagesForSpecNamed: 'tests')
		collect: [ :spec | spec name ]
]

{ #category : 'tests' }
PCKNoSkippedTestsMetaRuleTest >> testFiresInIsolationWithoutPriorSuiteRuns [
	"D-36's named regression: a fresh cache and no suite check run at all - the lazy pull runs the suites itself, so a narrowed run cannot fail open."
	| rule |
	rule := PCKNoSkippedTestsMetaRule
		packages: self scratchPackages
		cache: PCKSuiteRunCache new.
	self assertPlantedFindingsOn: rule run
]

{ #category : 'tests' }
PCKNoSkippedTestsMetaRuleTest >> testFiresOnSkipAndExpectedFailure [
	"The full-run shape (par. 1.4 suites-then-meta): a suite check warms the shared cache first; the meta-rule then reads the same result objects - nothing runs twice (D-36)."
	| cache rule |
	cache := PCKSuiteRunCache new.
	(PCKTestSuiteCheck package: 'Phi-Coding-Kit-Fixtures-Behavioral' cache: cache) run.
	rule := PCKNoSkippedTestsMetaRule packages: self scratchPackages cache: cache.
	self assert: rule kind equals: #behavioral.
	self assertPlantedFindingsOn: rule run
]

{ #category : 'tests' }
PCKNoSkippedTestsMetaRuleTest >> testSilentOnCleanSuite [
	"The good half of the meta-rule's fixture pair (R-37): the always-green, no-skips mirror package - C03's recorded green subject; the nested re-run is bounded and stateless."
	| verdict |
	verdict := (PCKNoSkippedTestsMetaRule
		packages: #( 'Phi-Guardrails-Tests-SDK' )
		cache: PCKSuiteRunCache new) run.
	self assert: verdict isGreen.
	self assertEmpty: verdict findings
]
