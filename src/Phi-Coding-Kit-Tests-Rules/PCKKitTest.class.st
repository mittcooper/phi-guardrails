"
Behavioral pin of the kit block envelope and dispatch: strict five-key validation (D-51 - blocks are opaque to the core, so only the kit can validate its own), the #lintRules pipeline arms (C16), the generic promised-constructor paths for #architectureChecks and #metaRules with role-by-block-key, missing specs for unresolved names, the neither-path configuration error, the carried-unread #layerMap parameter, the derived behavioral-suite registrations sharing one run-scoped cache per call with the behavioral/tests-role sentinel and the own-meta-rule special case (E07-C05; par. 5.1/5.4, D-36), and the completed four-stage lint -> architecture -> behavioral -> meta order law (C17, completed E07-C05). Error-message assertions name the offender, never exact wording (the text is human-facing, not an API). Lives here by the recorded chunks.md ruling: the frozen E01 tree has no root kit tests package; E07 extends this class in place.
"
Class {
	#name : 'PCKKitTest',
	#superclass : 'TestCase',
	#category : 'Phi-Coding-Kit-Tests-Rules',
	#package : 'Phi-Coding-Kit-Tests-Rules'
}

{ #category : 'tests' }
PCKKitTest >> testArchitectureCheckResolvedViaPackagesConstructor [
	"Ch. 1 par. 1.4, promised-constructor path: a named class the kit does not own is instantiated via packages: (D-60); role-by-block-key hands #architectureChecks the production list, not the tests list."
	| block specs spec |
	block := Dictionary new.
	block at: #architectureChecks put: #('PCKArchStubCheck').
	specs := PCKKit
		registrationsFrom: block
		productionPackages: #('P-One' 'P-Two')
		testsPackages: #().
	self assert: specs size equals: 2.
	spec := specs first.
	self assert: spec name equals: 'architecture/PCKArchStubCheck'.
	self assert: spec kind identicalTo: #architecture.
	self assert: spec check class equals: PCKArchStubCheck.
	self assert: spec check packages equals: #('P-One' 'P-Two').
	self assert: specs last name equals: 'behavioral/tests-role'.
	self assert: specs last kind identicalTo: #behavioral.
	self assert: specs last check isNil
]

{ #category : 'tests' }
PCKKitTest >> testClassAnsweringNeitherPathSignals [
	"Ch. 1 par. 1.4, neither-path arm: a resolved class whose class side answers no packages: constructor is a configuration error naming the class."
	| block |
	block := Dictionary new.
	block at: #architectureChecks put: #('PGRFinding').
	self
		should: [ PCKKit registrationsFrom: block productionPackages: #('P-One') testsPackages: #() ]
		raise: PGRConfigurationError
		withExceptionDo: [ :error |
			self assert: (error messageText includesSubstring: 'PGRFinding') ]
]

{ #category : 'tests' }
PCKKitTest >> testDerivesOneSuiteRegistrationPerTestsRolePackage [
	"Par. 5.1's whole derivation, ordered: one suite registration per tests-role package, no block key - unconditional, in handed order, each check a PCKTestSuiteCheck closed over its own package (D-25)."
	| specs |
	specs := PCKKit
		registrationsFrom: Dictionary new
		productionPackages: #('P-One')
		testsPackages: #('Phi-Coding-Kit-Fixtures-Behavioral' 'Phi-Guardrails-Tests-SDK').
	self assert: specs size equals: 2.
	self
		assert: (specs collect: [ :each | each name ]) asArray
		equals: #('behavioral/Phi-Coding-Kit-Fixtures-Behavioral' 'behavioral/Phi-Guardrails-Tests-SDK').
	specs do: [ :each |
		self assert: each kind identicalTo: #behavioral.
		self assert: each check class equals: PCKTestSuiteCheck.
		self assert: 'behavioral/' , each check package equals: each name ]
]

{ #category : 'tests' }
PCKKitTest >> testLayerMapKeyProducesNoRegistrationsAndNoError [
	"#layerMap is a parameter key, not a check list: a present map is carried, unread and unregistered until E10 gives it its consumer and its shape validation."
	| block specs |
	block := Dictionary new.
	block at: #lintRules put: #('PCKNoIsNilIfTrueRule').
	block at: #layerMap put: { #layers -> Dictionary new } asDictionary.
	specs := PCKKit
		registrationsFrom: block
		productionPackages: #('P-One')
		testsPackages: #().
	self assert: specs size equals: 2.
	self assert: specs first name equals: 'lint/PCKNoIsNilIfTrueRule'.
	self assert: specs last name equals: 'behavioral/tests-role'
]

{ #category : 'tests' }
PCKKitTest >> testLintRegistrationsFromBlock [
	"Ch. 2 par. 2.4: a shipped built-in registers exactly like a catalog rule - same block, same spec shape; lint targets the production role (D-25)."
	| block specs |
	block := Dictionary new.
	block at: #kit put: 'PCKKit'.
	block at: #lintRules put: #('PCKNoIsNilIfTrueRule' 'ReCodeCruftLeftInMethodsRule').
	specs := PCKKit
		registrationsFrom: block
		productionPackages: #('Phi-Guardrails-SDK')
		testsPackages: #().
	self assert: specs size equals: 3.
	self
		assert: (specs collect: [ :each | each name ]) asArray
		equals: #('lint/PCKNoIsNilIfTrueRule' 'lint/ReCodeCruftLeftInMethodsRule' 'behavioral/tests-role').
	(specs first: 2) do: [ :each |
		self assert: each kind identicalTo: #lint.
		self assert: each check class equals: PCKLintRuleCheck.
		self assert: each check packages equals: #('Phi-Guardrails-SDK') ].
	self assert: specs first check rule identicalTo: PCKNoIsNilIfTrueRule.
	self assert: (specs at: 2) check rule identicalTo: ReCodeCruftLeftInMethodsRule
]

{ #category : 'tests' }
PCKKitTest >> testMetaRuleResolvedWithTestsRole [
	"Role-by-block-key, tests arm: #metaRules hands the tests list, not the production list; the name takes the behavioral prefix (ch. 1 par. 1.3: behavioral/<Class>)."
	| block specs spec |
	block := Dictionary new.
	block at: #metaRules put: #('PCKMetaStubCheck').
	specs := PCKKit
		registrationsFrom: block
		productionPackages: #('P-One')
		testsPackages: #('T-One').
	self assert: specs size equals: 2.
	self assert: specs first name equals: 'behavioral/T-One'.
	self assert: specs first kind identicalTo: #behavioral.
	self assert: specs first check class equals: PCKTestSuiteCheck.
	spec := specs last.
	self assert: spec name equals: 'behavioral/PCKMetaStubCheck'.
	self assert: spec kind identicalTo: #behavioral.
	self assert: spec check class equals: PCKMetaStubCheck.
	self assert: spec check packages equals: #('T-One')
]

{ #category : 'tests' }
PCKKitTest >> testNonRuleClassSignals [
	"Ch. 1 par. 1.5, loaded-but-not-a-rule arm: a resolved class with no Renraku descent is a configuration error at construction, never a missing spec."
	| block |
	block := Dictionary new.
	block at: #lintRules put: #('PGRFinding').
	self
		should: [ PCKKit registrationsFrom: block productionPackages: #('Phi-Guardrails-SDK') testsPackages: #() ]
		raise: PGRConfigurationError
		withExceptionDo: [ :error |
			self assert: (error messageText includesSubstring: 'PGRFinding') ]
]

{ #category : 'tests' }
PCKKitTest >> testOwnMetaRuleRidesTheRunCache [
	"Par. 5.4's own-meta-rule special case + D-36's one-cache law: the kit's own class named in #metaRules is constructed over the run's one shared cache - identical to the suite check's - so it reads the very result objects the suite registrations produce; the sibling generic path is pinned by testMetaRuleResolvedWithTestsRole."
	| block specs metaSpec |
	block := Dictionary new.
	block at: #metaRules put: #('PCKNoSkippedTestsMetaRule').
	specs := PCKKit
		registrationsFrom: block
		productionPackages: #('P-One')
		testsPackages: #('Phi-Coding-Kit-Fixtures-Behavioral').
	self assert: specs size equals: 2.
	metaSpec := specs last.
	self assert: metaSpec name equals: 'behavioral/PCKNoSkippedTestsMetaRule'.
	self assert: metaSpec kind identicalTo: #behavioral.
	self assert: metaSpec check class equals: PCKNoSkippedTestsMetaRule.
	self assert: metaSpec check packages equals: #('Phi-Coding-Kit-Fixtures-Behavioral').
	self assert: metaSpec check cache identicalTo: specs first check cache
]

{ #category : 'tests' }
PCKKitTest >> testRecommendedBlockParsesAndConforms [
	"P-STANZA-VALID (ch. 9): the published stanza parses cleanly, every check it names resolves and registers through the kit's own dispatch, and each registered check conforms to the frozen check protocol - run, kind, canFix, packages - with the spec's kind equal to the check's own kind (D-60's agreement fact, asserted directly at the kit boundary): the stanza can never drift from the code it describes."
	| specs |
	specs := PCKKit
		registrationsFrom: (STON fromString: PCKKit recommendedBlock)
		productionPackages: #('Phi-Guardrails-SDK')
		testsPackages: #('Phi-Coding-Kit-Fixtures-Behavioral').
	self assert: specs size equals: 4.
	specs do: [ :each |
		self deny: each check isNil.
		#(run kind canFix packages) do: [ :selector |
			self assert: (each check respondsTo: selector) ].
		self assert: each kind identicalTo: each check kind ]
]

{ #category : 'tests' }
PCKKitTest >> testRecommendedBlockParsesAsKitBlock [
	"The published stanza (ch. 1 par. 1.3, D-54/D-60) parses as the kit block it documents: a Dictionary with Symbol keys whose #kit is this class, whose #lintRules is the ordered catalog pair (D-51, par. 3.2 then 3.2b), and whose #metaRules is the no-skips meta-rule (R-25) - the complete M1 recommended set, and nothing beyond those three keys."
	| block |
	block := STON fromString: PCKKit recommendedBlock.
	self assert: (block isKindOf: Dictionary).
	self assert: block size equals: 3.
	self assert: (block at: #kit) equals: 'PCKKit'.
	self
		assert: (block at: #lintRules) asArray
		equals: #('PCKNoIsNilIfTrueRule' 'ReCodeCruftLeftInMethodsRule').
	self
		assert: (block at: #metaRules) asArray
		equals: #('PCKNoSkippedTestsMetaRule')
]

{ #category : 'tests' }
PCKKitTest >> testRecommendedBlockRegistersCleanly [
	"The resolution arm of P-STANZA-VALID: the stanza can never name something that does not resolve - parsed and handed to the kit with a real tests role it yields the two catalog specs, the derived suite spec, and the own-meta-rule spec, in the frozen four-stage order, all resolved, none missing."
	| specs |
	specs := PCKKit
		registrationsFrom: (STON fromString: PCKKit recommendedBlock)
		productionPackages: #('Phi-Guardrails-SDK')
		testsPackages: #('Phi-Coding-Kit-Fixtures-Behavioral').
	self assert: specs size equals: 4.
	self
		assert: (specs collect: [ :each | each name ]) asArray
		equals: #('lint/PCKNoIsNilIfTrueRule' 'lint/ReCodeCruftLeftInMethodsRule' 'behavioral/Phi-Coding-Kit-Fixtures-Behavioral' 'behavioral/PCKNoSkippedTestsMetaRule').
	specs do: [ :each |
		self deny: each check isNil.
		self assert: each missingReason isNil ]
]

{ #category : 'tests' }
PCKKitTest >> testRegistrationOrderIsLintThenArchitectureThenMeta [
	"The four-stage order law, frozen at E06 acceptance and completed here (ch. 1 par. 1.4): all lint, then all architecture, then all derived behavioral suites, then all #metaRules specs - the dispatch order, whatever order the block was assembled in."
	| block specs |
	block := Dictionary new.
	block at: #metaRules put: #('PCKMetaStubCheck').
	block at: #architectureChecks put: #('PCKArchStubCheck').
	block at: #lintRules put: #('PCKNoIsNilIfTrueRule').
	specs := PCKKit
		registrationsFrom: block
		productionPackages: #('P-One')
		testsPackages: #('T-One').
	self
		assert: (specs collect: [ :each | each name ]) asArray
		equals: #('lint/PCKNoIsNilIfTrueRule' 'architecture/PCKArchStubCheck' 'behavioral/T-One' 'behavioral/PCKMetaStubCheck')
]

{ #category : 'tests' }
PCKKitTest >> testRuleWithoutOwnSeveritySignals [
	"P-SEVERITY-EXPLICIT (D-41): the inherited #warning is not a legal state for a registered rule; the kit raises when it opens its block, before any check runs."
	| block |
	block := Dictionary new.
	block at: #lintRules put: #('PCKInheritedSeverityStubRule').
	self
		should: [ PCKKit registrationsFrom: block productionPackages: #('Phi-Guardrails-SDK') testsPackages: #() ]
		raise: PGRConfigurationError
		withExceptionDo: [ :error |
			self assert: (error messageText includesSubstring: 'PCKInheritedSeverityStubRule') ]
]

{ #category : 'tests' }
PCKKitTest >> testSuiteRegistrationsPrecedeMetaRules [
	"P-SUITES-BEFORE-META (ch. 9): every derived suite spec's index in the answer is lower than every #metaRules spec's index - the suites a meta-rule reads over are registered before it."
	| block specs lastSuiteIndex firstMetaIndex |
	block := Dictionary new.
	block at: #metaRules put: #('PCKMetaStubCheck').
	specs := PCKKit
		registrationsFrom: block
		productionPackages: #('P-One')
		testsPackages: #('Phi-Coding-Kit-Fixtures-Behavioral' 'Phi-Guardrails-Tests-SDK').
	lastSuiteIndex := specs findLast: [ :each | each check class = PCKTestSuiteCheck ].
	firstMetaIndex := specs findFirst: [ :each | each name = 'behavioral/PCKMetaStubCheck' ].
	self assert: lastSuiteIndex > 0.
	self assert: firstMetaIndex > 0.
	self assert: lastSuiteIndex < firstMetaIndex
]

{ #category : 'tests' }
PCKKitTest >> testTwoRegistrationRoundsShareNoCache [
	"R-35: the cache is run-scoped - one per contract call, closed over by that call's behavioral checks and discarded with them; two calls never share one."
	| block firstCache secondCache |
	block := Dictionary new.
	firstCache := (PCKKit
		registrationsFrom: block
		productionPackages: #('P-One')
		testsPackages: #('Phi-Coding-Kit-Fixtures-Behavioral')) first check cache.
	secondCache := (PCKKit
		registrationsFrom: block
		productionPackages: #('P-One')
		testsPackages: #('Phi-Coding-Kit-Fixtures-Behavioral')) first check cache.
	self deny: firstCache identicalTo: secondCache
]

{ #category : 'tests' }
PCKKitTest >> testUnknownBlockKeySignals [
	"Strict envelope validation (D-51): any key outside the canonical five is a configuration error naming the key."
	| block |
	block := Dictionary new.
	block at: #lintRulez put: #('PCKNoIsNilIfTrueRule').
	self
		should: [ PCKKit registrationsFrom: block productionPackages: #() testsPackages: #() ]
		raise: PGRConfigurationError
		withExceptionDo: [ :error |
			self assert: (error messageText includesSubstring: 'lintRulez') ]
]

{ #category : 'tests' }
PCKKitTest >> testUnresolvedArchitectureAndMetaAnswerMissingSpecs [
	"Ch. 1 par. 1.5: an unresolved name in either list is a missing spec, never an exception; a missing spec keeps its explicit kind - no check exists to ask (D-60)."
	| block specs |
	block := Dictionary new.
	block at: #architectureChecks put: #('PCKNoSuchCheck').
	block at: #metaRules put: #('PCKNoSuchCheck').
	specs := PCKKit
		registrationsFrom: block
		productionPackages: #('P-One')
		testsPackages: #('T-One').
	self assert: specs size equals: 3.
	self assert: specs first name equals: 'architecture/PCKNoSuchCheck'.
	self assert: specs first kind identicalTo: #architecture.
	self assert: (specs at: 2) name equals: 'behavioral/T-One'.
	self deny: (specs at: 2) check isNil.
	self assert: specs last name equals: 'behavioral/PCKNoSuchCheck'.
	self assert: specs last kind identicalTo: #behavioral.
	{ specs first. specs last } do: [ :each |
		self assert: each check isNil.
		self assert: (each missingReason includesSubstring: 'PCKNoSuchCheck') ]
]

{ #category : 'tests' }
PCKKitTest >> testUnresolvedLintRuleAnswersMissingSpec [
	"Ch. 1 par. 1.5: an unresolved name is a verdict-level fact, not an exception - the run completes and the gate, not the kit, fails."
	| block specs spec |
	block := Dictionary new.
	block at: #lintRules put: #('PCKNoSuchRule').
	specs := PCKKit
		registrationsFrom: block
		productionPackages: #('Phi-Guardrails-SDK')
		testsPackages: #().
	self assert: specs size equals: 2.
	spec := specs first.
	self assert: spec name equals: 'lint/PCKNoSuchRule'.
	self assert: spec kind identicalTo: #lint.
	self assert: spec check isNil.
	self assert: (spec missingReason includesSubstring: 'PCKNoSuchRule').
	self assert: specs last name equals: 'behavioral/tests-role'.
	self assert: specs last kind identicalTo: #behavioral.
	self assert: specs last check isNil
]
