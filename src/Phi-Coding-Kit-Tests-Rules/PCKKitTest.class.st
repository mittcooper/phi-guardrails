"
Behavioral pin of the kit block envelope and dispatch: strict five-key validation (D-51 - blocks are opaque to the core, so only the kit can validate its own), the #lintRules pipeline arms (C16), and the generic promised-constructor paths for #architectureChecks and #metaRules with role-by-block-key, missing specs for unresolved names, the neither-path configuration error, the carried-unread #layerMap parameter, and the frozen lint -> architecture -> meta order law (C17). Error-message assertions name the offender, never exact wording (the text is human-facing, not an API). Lives here by the recorded chunks.md ruling: the frozen E01 tree has no root kit tests package; E07 extends this class in place.
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
	self assert: specs size equals: 1.
	spec := specs first.
	self assert: spec name equals: 'architecture/PCKArchStubCheck'.
	self assert: spec kind identicalTo: #architecture.
	self assert: spec check class equals: PCKArchStubCheck.
	self assert: spec check packages equals: #('P-One' 'P-Two')
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
	self assert: specs size equals: 1.
	self assert: specs first name equals: 'lint/PCKNoIsNilIfTrueRule'
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
	self assert: specs size equals: 2.
	self
		assert: (specs collect: [ :each | each name ]) asArray
		equals: #('lint/PCKNoIsNilIfTrueRule' 'lint/ReCodeCruftLeftInMethodsRule').
	specs do: [ :each |
		self assert: each kind identicalTo: #lint.
		self assert: each check class equals: PCKLintRuleCheck.
		self assert: each check packages equals: #('Phi-Guardrails-SDK') ].
	self assert: specs first check rule identicalTo: PCKNoIsNilIfTrueRule.
	self assert: specs last check rule identicalTo: ReCodeCruftLeftInMethodsRule
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
	self assert: specs size equals: 1.
	spec := specs first.
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
PCKKitTest >> testRecommendedBlockParsesAsKitBlock [
	"The published stanza (ch. 1 par. 1.3, D-54/D-60) parses as the kit block it documents: a Dictionary with Symbol keys whose #kit is this class and whose #lintRules is the ordered catalog pair (D-51, par. 3.2 then 3.2b) - and nothing beyond those two keys (the M1-partial form; E07 appends #metaRules)."
	| block |
	block := STON fromString: PCKKit recommendedBlock.
	self assert: (block isKindOf: Dictionary).
	self assert: block size equals: 2.
	self assert: (block at: #kit) equals: 'PCKKit'.
	self
		assert: (block at: #lintRules) asArray
		equals: #('PCKNoIsNilIfTrueRule' 'ReCodeCruftLeftInMethodsRule')
]

{ #category : 'tests' }
PCKKitTest >> testRecommendedBlockRegistersCleanly [
	"The E06 arm of P-STANZA-VALID (E07 adds the registry-construction arm): the stanza can never name something that does not resolve - parsed and handed to the kit it yields exactly the two catalog specs, both resolved, none missing."
	| specs |
	specs := PCKKit
		registrationsFrom: (STON fromString: PCKKit recommendedBlock)
		productionPackages: #('Phi-Guardrails-SDK')
		testsPackages: #().
	self assert: specs size equals: 2.
	self
		assert: (specs collect: [ :each | each name ]) asArray
		equals: #('lint/PCKNoIsNilIfTrueRule' 'lint/ReCodeCruftLeftInMethodsRule').
	specs do: [ :each |
		self deny: each check isNil.
		self assert: each missingReason isNil ]
]

{ #category : 'tests' }
PCKKitTest >> testRegistrationOrderIsLintThenArchitectureThenMeta [
	"The order law, frozen at E06 acceptance (ch. 1 par. 1.4): all lint, then all architecture, then all meta specs - the dispatch order, whatever order the block was assembled in."
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
		equals: #('lint/PCKNoIsNilIfTrueRule' 'architecture/PCKArchStubCheck' 'behavioral/PCKMetaStubCheck')
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
	self assert: specs size equals: 2.
	self assert: specs first name equals: 'architecture/PCKNoSuchCheck'.
	self assert: specs first kind identicalTo: #architecture.
	self assert: specs last name equals: 'behavioral/PCKNoSuchCheck'.
	self assert: specs last kind identicalTo: #behavioral.
	specs do: [ :each |
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
	self assert: specs size equals: 1.
	spec := specs first.
	self assert: spec name equals: 'lint/PCKNoSuchRule'.
	self assert: spec kind identicalTo: #lint.
	self assert: spec check isNil.
	self assert: (spec missingReason includesSubstring: 'PCKNoSuchRule')
]
