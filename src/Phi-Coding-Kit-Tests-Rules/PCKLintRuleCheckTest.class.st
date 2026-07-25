"
Behavioral pin of the lint kind's check (D-03 two-tier severity as behavior): red arm over the bad-fixture package, green arm over the frozen clean -SDK package, advisory arm via the warning-severity stub fixture. Assertions filter by target so sibling fixtures gaining critiques never break them (P-CAT-FIXTURES).
"
Class {
	#name : 'PCKLintRuleCheckTest',
	#superclass : 'TestCase',
	#category : 'Phi-Coding-Kit-Tests-Rules',
	#package : 'Phi-Coding-Kit-Tests-Rules'
}

{ #category : 'tests' }
PCKLintRuleCheckTest >> testGreenOnCleanPackage [
	"The frozen -SDK package is clean under the catalog rule (the constitution's own ifNil: mandate)."
	| verdict |
	verdict := (PCKLintRuleCheck rule: PCKNoIsNilIfTrueRule packages: #('Phi-Guardrails-SDK')) run.
	self assert: verdict isGreen.
	self assertEmpty: verdict findings.
	self assertEmpty: verdict advisories
]

{ #category : 'tests' }
PCKLintRuleCheckTest >> testKindIsLint [
	"canFix stays the inherited false: the fix capability is E08's, not this chunk's."
	| check |
	check := PCKLintRuleCheck rule: PCKNoIsNilIfTrueRule packages: #('Phi-Guardrails-SDK').
	self assert: check kind identicalTo: #lint.
	self deny: check canFix
]

{ #category : 'tests' }
PCKLintRuleCheckTest >> testRedOnBadFixturePackage [
	"R-13 end-to-end: the plant's finding carries the rule's name and rationale."
	| verdict plant |
	verdict := (PCKLintRuleCheck rule: PCKNoIsNilIfTrueRule packages: #('Phi-Coding-Kit-Tests-Rules')) run.
	self deny: verdict isGreen.
	self denyEmpty: verdict findings.
	plant := verdict findings detect: [ :each |
		(each target includesSubstring: 'PCKLintBadFixture') and: [
			each target includesSubstring: 'withIsNilIfTrue' ] ].
	self assert: plant message equals: PCKNoIsNilIfTrueRule ruleName.
	self assert: plant rationale equals: PCKNoIsNilIfTrueRule rationale
]

{ #category : 'tests' }
PCKLintRuleCheckTest >> testSubErrorSeverityYieldsAdvisories [
	"D-03: below #error the same critique arrives as an advisory on a green verdict."
	| verdict |
	verdict := (PCKLintRuleCheck rule: PCKWarningSeverityStubRule packages: #('Phi-Coding-Kit-Tests-Rules')) run.
	self assert: verdict isGreen.
	self denyEmpty: verdict advisories.
	self assertEmpty: verdict findings
]
