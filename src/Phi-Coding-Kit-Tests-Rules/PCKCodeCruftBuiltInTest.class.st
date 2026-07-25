"
Pins the registered built-in ReCodeCruftLeftInMethodsRule (ch. 3 par. 3.2b): the bad fixture carries each send form the catalog claims it catches, one asserted critique per form (D-55.4); the good fixture stays silent (R-37); and the shipped class-side severity is pinned to #error (P-BUILTIN-PINNED, D-34.1) so a Pharo upgrade demoting the rule reddens a test instead of silently unblocking the gate. Runs the D-15 headless checker recipe over this tests-role package; the critiqued method is reached as `critique entity` (confirmed live, C13/C14).
"
Class {
	#name : 'PCKCodeCruftBuiltInTest',
	#superclass : 'TestCase',
	#category : 'Phi-Coding-Kit-Tests-Rules',
	#package : 'Phi-Coding-Kit-Tests-Rules'
}

{ #category : 'running' }
PCKCodeCruftBuiltInTest >> assertCritiques: critiques cover: aSelector [
	"One named assertion per claimed send form (D-55.4 match-set pin): at least one
	critique targets the bad-fixture method - filtered per method, because this
	package holds other fixture classes (P-CAT-FIXTURES)."
	self
		assert: (critiques anySatisfy: [ :each |
			each entity == (PCKCruftBadFixture >> aSelector) ])
		description: 'no critique targets PCKCruftBadFixture>>#' , aSelector
]

{ #category : 'running' }
PCKCodeCruftBuiltInTest >> runRuleCritiques [
	"D-15 checker recipe scoped to this package; answers the built-in rule's critiques."
	| rule checker |
	rule := ReCodeCruftLeftInMethodsRule new.
	checker := ReSmalllintChecker new
		rule: { rule };
		environment: (RBPackageEnvironment packageName: 'Phi-Coding-Kit-Tests-Rules');
		run;
		yourself.
	^ checker criticsOf: rule
]

{ #category : 'tests' }
PCKCodeCruftBuiltInTest >> testFiresOnBadFixture [
	"The match-set pin: a claimed form silently un-matched by a future Pharo is a red test."
	| critiques |
	critiques := self runRuleCritiques.
	self assertCritiques: critiques cover: #withHalt.
	self assertCritiques: critiques cover: #withHaltIf.
	self assertCritiques: critiques cover: #withTranscriptShow.
	self assertCritiques: critiques cover: #withFlag
]

{ #category : 'tests' }
PCKCodeCruftBuiltInTest >> testSeverityStillBlocks [
	"P-BUILTIN-PINNED (D-34.1): #error is what makes the built-in block (D-03 tiering);
	an image demoting it must redden here, never silently stop the gate blocking."
	self assert: ReCodeCruftLeftInMethodsRule severity identicalTo: #error
]

{ #category : 'tests' }
PCKCodeCruftBuiltInTest >> testSilentOnGoodFixture [
	"R-37 silence arm: zero critiques whose critiqued method belongs to the clean twin."
	| goodCritiques |
	goodCritiques := self runRuleCritiques select: [ :each |
		each entity methodClass == PCKCruftGoodFixture ].
	self assertEmpty: goodCritiques
]
