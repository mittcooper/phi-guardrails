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
PCKLintRuleCheckTest >> testCanFixFalseForRecipelessRule [
	"The C02-recorded non-rewrite built-in: no recipe exists to offer, so the capability
	is per-rule fact, never a blanket true."
	self deny: (PCKLintRuleCheck rule: ReEmptyExceptionHandlerRule packages: #('Phi-Guardrails-SDK')) canFix
]

{ #category : 'tests' }
PCKLintRuleCheckTest >> testCanFixTrueForRewriteRule [
	"P1: fixes, not flags - the catalog rule's check advertises its autofix. D-74 makes
	the capability the mechanical fact with no policy overlay: ReCodeCruftLeftInMethodsRule
	carries a deletion recipe (E08-C02 P5 probe), so its check answers true too."
	self assert: (PCKLintRuleCheck rule: PCKNoIsNilIfTrueRule packages: #('Phi-Guardrails-SDK')) canFix.
	self assert: (PCKLintRuleCheck rule: ReCodeCruftLeftInMethodsRule packages: #('Phi-Guardrails-SDK')) canFix
]

{ #category : 'tests' }
PCKLintRuleCheckTest >> testFixCommandOnAnswersWorkingCommand [
	"Protocol conformance behaviorally (responds-to plus an actual preview, never class
	identity), and the command is bound, not merely shaped: previewing finds exactly the
	plant in the handed target - the invoker's packages, not the check's own (par. 1.3).
	No apply is sent: this test mutates nothing."
	| check command stream |
	check := PCKLintRuleCheck rule: PCKNoIsNilIfTrueRule packages: #('Phi-Guardrails-SDK').
	command := check fixCommandOn: #('Phi-Coding-Kit-Tests-Rules').
	self assert: (command respondsTo: #previewOn:).
	self assert: (command respondsTo: #apply).
	self assert: (command respondsTo: #changes).
	stream := WriteStream on: String new.
	self assert: (command previewOn: stream) equals: 1.
	self assert: (stream contents includesSubstring: 'withIsNilIfTrue')
]

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
	| check |
	check := PCKLintRuleCheck rule: PCKNoIsNilIfTrueRule packages: #('Phi-Guardrails-SDK').
	self assert: check kind identicalTo: #lint
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

{ #category : 'tests' }
PCKLintRuleCheckTest >> testTraitProvidedMethodLintedAtUsingClassPackage [
	"D-72 regression (the D-71 escape): a trait-provided method must be linted at the
	using class's package. The scratch trait/class pair exists only inside this test;
	ensure: removes it even when an assertion fails. The planted flag: send is a string
	compiled at runtime into the scratch trait, never a committed send (R-37/D-26)."
	| verdict |
	[
	(Trait << #PCKScratchCruftTrait
		package: 'PCKScratchB03-Traits';
		install) compile: 'probeCruft self flag: #probe'.
	Object << #PCKScratchCruftUser
		traits: { (Smalltalk globals at: #PCKScratchCruftTrait) };
		package: 'PCKScratchB03-User';
		install.
	verdict := (PCKLintRuleCheck
		rule: ReCodeCruftLeftInMethodsRule
		packages: #('PCKScratchB03-User')) run.
	self deny: verdict isGreen.
	self assert: (verdict findings anySatisfy: [ :each |
		each target includesSubstring: 'probeCruft' ]) ]
		ensure: [
			(Smalltalk globals at: #PCKScratchCruftUser ifAbsent: [ nil ])
				ifNotNil: [ :user | user removeFromSystem ].
			(Smalltalk globals at: #PCKScratchCruftTrait ifAbsent: [ nil ])
				ifNotNil: [ :trait | trait removeFromSystem ].
			(PackageOrganizer default packageNamed: 'PCKScratchB03-User' ifAbsent: [ nil ])
				ifNotNil: [ :package | package removeFromSystem ].
			(PackageOrganizer default packageNamed: 'PCKScratchB03-Traits' ifAbsent: [ nil ])
				ifNotNil: [ :package | package removeFromSystem ] ]
]
