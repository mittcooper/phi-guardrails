"
Fixture-pair test for PCKNoIsNilIfTrueRule (R-37, P-CAT-FIXTURES): the rule fires on the named plant in PCKLintBadFixture and stays silent on PCKLintGoodFixture. Runs the D-15 headless checker recipe over this tests-role package; the critiqued method is reached as `critique entity` (C13 live probe).
"
Class {
	#name : 'PCKNoIsNilIfTrueRuleTest',
	#superclass : 'TestCase',
	#category : 'Phi-Coding-Kit-Tests-Rules',
	#package : 'Phi-Coding-Kit-Tests-Rules'
}

{ #category : 'running' }
PCKNoIsNilIfTrueRuleTest >> runRuleCritiques [
	"D-15 checker recipe scoped to this package; answers the rule's critiques."
	| rule checker |
	rule := PCKNoIsNilIfTrueRule new.
	checker := ReSmalllintChecker new
		rule: { rule };
		environment: (RBPackageEnvironment packageName: 'Phi-Coding-Kit-Tests-Rules');
		run;
		yourself.
	^ checker criticsOf: rule
]

{ #category : 'tests' }
PCKNoIsNilIfTrueRuleTest >> testFiresOnBadFixture [
	"Exactly one critique names the plant - filtered by critiqued method, because
	this package gains other classes in later chunks (P-CAT-FIXTURES)."
	| plantCritiques |
	plantCritiques := self runRuleCritiques select: [ :each |
		each entity == (PCKLintBadFixture >> #withIsNilIfTrue) ].
	self assert: plantCritiques size equals: 1
]

{ #category : 'tests' }
PCKNoIsNilIfTrueRuleTest >> testProvidesAutofix [
	"P-CAT-AUTOFIX (ch. 9): the check declares the fix capability and the plant's
	violation carries a previewable change - Renraku's isRewriteRule/providesChange,
	the engine spellings behind the SDK's neutral ones."
	| plantCritique check |
	plantCritique := self runRuleCritiques detect: [ :each |
		each entity == (PCKLintBadFixture >> #withIsNilIfTrue) ].
	check := PCKLintRuleCheck rule: PCKNoIsNilIfTrueRule packages: #('Phi-Coding-Kit-Tests-Rules').
	self assert: check canFix.
	self assert: plantCritique providesChange
]

{ #category : 'tests' }
PCKNoIsNilIfTrueRuleTest >> testSilentOnGoodFixture [
	"Zero critiques on the clean twin: the rule is precise, not trigger-happy."
	| goodCritiques |
	goodCritiques := self runRuleCritiques select: [ :each |
		each entity methodClass == PCKLintGoodFixture ].
	self assertEmpty: goodCritiques
]
