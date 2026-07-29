"
Client-convention fixture-pair test for ToyNoIsNilIfFalseRule (R-37, spec §8.1 step 3): the rule fires on the named plant in ToyRuleBadFixture and stays silent on ToyRuleGoodFixture. Runs the D-15 headless checker recipe over this tests-role package; the critiqued method is reached as `critique entity` (C13 live probe). Filtered by entity — the package gains more classes in C03. This suite is unswept by design (Toy-Tests full-matches neither verify pattern, D-57), so it is verified by an explicit eval arm, not the sweep.
"
Class {
	#name : 'ToyNoIsNilIfFalseRuleTest',
	#superclass : 'TestCase',
	#category : 'Toy-Tests',
	#package : 'Toy-Tests'
}

{ #category : 'running' }
ToyNoIsNilIfFalseRuleTest >> runRuleCritiques [
	"D-15 checker recipe scoped to this package; answers the rule's critiques."
	| rule checker |
	rule := ToyNoIsNilIfFalseRule new.
	checker := ReSmalllintChecker new
		rule: { rule };
		environment: (RBPackageEnvironment packageName: 'Toy-Tests');
		run;
		yourself.
	^ checker criticsOf: rule
]

{ #category : 'tests' }
ToyNoIsNilIfFalseRuleTest >> testFiresOnBadFixture [
	"Exactly one critique names the plant - filtered by critiqued method, because
	this package gains other classes in C03 (R-37 fires half)."
	| plantCritiques |
	plantCritiques := self runRuleCritiques select: [ :each |
		each entity == (ToyRuleBadFixture >> #withIsNilIfFalse) ].
	self assert: plantCritiques size equals: 1
]

{ #category : 'tests' }
ToyNoIsNilIfFalseRuleTest >> testSilentOnGoodFixture [
	"Zero critiques on the clean twin: the rule is precise, not trigger-happy (R-37 silent half)."
	| goodCritiques |
	goodCritiques := self runRuleCritiques select: [ :each |
		each entity methodClass == ToyRuleGoodFixture ].
	self assertEmpty: goodCritiques
]
