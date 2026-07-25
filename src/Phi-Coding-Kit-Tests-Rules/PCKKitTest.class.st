"
Behavioral pin of the kit block envelope and lint dispatch (C16): strict five-key validation (D-51 - blocks are opaque to the core, so only the kit can validate its own), then the #lintRules pipeline arms - specs in block order (ch. 2 par. 2.4: a built-in registers exactly like a catalog rule), missing specs for unresolved names (ch. 1 par. 1.5), configuration errors for non-rule classes and D-41 severity omissions. Error-message assertions name the offender, never exact wording (the text is human-facing, not an API). Lives here by the recorded chunks.md ruling: the frozen E01 tree has no root kit tests package; E07 extends this class in place.
"
Class {
	#name : 'PCKKitTest',
	#superclass : 'TestCase',
	#category : 'Phi-Coding-Kit-Tests-Rules',
	#package : 'Phi-Coding-Kit-Tests-Rules'
}

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
		self assert: (each check isKindOf: PCKLintRuleCheck).
		self assert: each check packages equals: #('Phi-Guardrails-SDK') ].
	self assert: specs first check rule identicalTo: PCKNoIsNilIfTrueRule.
	self assert: specs last check rule identicalTo: ReCodeCruftLeftInMethodsRule
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
