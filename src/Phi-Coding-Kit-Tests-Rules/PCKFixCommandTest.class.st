"
Behavioral pin of PCKFixCommand's construction, error and preview paths (ch. 3 par. 3.3): the not-autofixable guard's two arms, the apply-before-preview error (E08-C02), and the D-06 mandatory preview - diff emitted, count answered, changes exposed, nothing mutated (E08-C03). Error classes are asserted by class, never by wording; preview assertions pin content substrings, never layout.
"
Class {
	#name : 'PCKFixCommandTest',
	#superclass : 'TestCase',
	#category : 'Phi-Coding-Kit-Tests-Rules',
	#package : 'Phi-Coding-Kit-Tests-Rules'
}

{ #category : 'tests' }
PCKFixCommandTest >> testApplyWithoutPreviewSignals [
	"P-FIX-PREVIEW leg 1 (ch. 9, D-06): apply with no prior previewOn: signals."
	| fix |
	fix := PCKFixCommand rule: PCKNoIsNilIfTrueRule packages: #('Phi-Coding-Kit-Tests-Rules').
	self should: [ fix apply ] raise: PGRFixNotPreviewed
]

{ #category : 'tests' }
PCKFixCommandTest >> testChangesEmptyBeforePreview [
	"Guard green arm: construction over a rewrite rule succeeds, and the pending
	change objects read as empty before any preview."
	| fix |
	fix := PCKFixCommand rule: PCKNoIsNilIfTrueRule packages: #('Phi-Coding-Kit-Tests-Rules').
	self assertEmpty: fix changes
]

{ #category : 'tests' }
PCKFixCommandTest >> testFlagOnlyRuleSignalsNotAutofixable [
	"Guard red arm (par. 3.3): a rule with no autofix must be refused at construction.
	The catalog's flag-only example ReCodeCruftLeftInMethodsRule answers isRewriteRule
	true in the live Pharo 13 image (it subclasses ReNodeRewriteRule - E08-C02 P5 probe),
	so the shipped ReEmptyExceptionHandlerRule, genuinely rewrite-less, carries this arm."
	self
		should: [ PCKFixCommand rule: ReEmptyExceptionHandlerRule packages: #('Phi-Coding-Kit-Tests-Rules') ]
		raise: PGRNotAutofixable
]

{ #category : 'tests' }
PCKFixCommandTest >> testPreviewAnswersCountAndExposesChanges [
	"Exactly one pending change: the count doubles as the blast-radius guard on
	apply (E08-C04 applies every pending change) - a second isNil ifTrue: plant in
	this package must redden this suite loudly, never be silently rewritten."
	| fix count change |
	fix := PCKFixCommand rule: PCKNoIsNilIfTrueRule packages: #('Phi-Coding-Kit-Tests-Rules').
	count := fix previewOn: (WriteStream on: String new).
	self assert: count equals: 1.
	self assert: fix changes size equals: 1.
	change := fix changes first.
	self assert: (change oldVersionTextToDisplay includesSubstring: 'isNil ifTrue:').
	self assert: (change textToDisplay includesSubstring: 'ifNil:')
]

{ #category : 'tests' }
PCKFixCommandTest >> testPreviewEmitsTargetAndBothSources [
	"D-06's mandatory preview: the emission carries the target and both sources -
	the invoker saw the diff before anything can change. Content substrings only;
	layout is implementer latitude, not API."
	| fix stream contents |
	fix := PCKFixCommand rule: PCKNoIsNilIfTrueRule packages: #('Phi-Coding-Kit-Tests-Rules').
	stream := WriteStream on: String new.
	fix previewOn: stream.
	contents := stream contents.
	self assert: (contents includesSubstring: 'PCKLintBadFixture').
	self assert: (contents includesSubstring: 'withIsNilIfTrue').
	self assert: (contents includesSubstring: 'isNil ifTrue:').
	self assert: (contents includesSubstring: 'ifNil:')
]

{ #category : 'tests' }
PCKFixCommandTest >> testPreviewMutatesNoSource [
	"Preview is pure - mutation is apply's monopoly (R-12's division of labor)."
	| fix before |
	before := (PCKLintBadFixture >> #withIsNilIfTrue) sourceCode.
	fix := PCKFixCommand rule: PCKNoIsNilIfTrueRule packages: #('Phi-Coding-Kit-Tests-Rules').
	fix previewOn: (WriteStream on: String new).
	self assert: (PCKLintBadFixture >> #withIsNilIfTrue) sourceCode equals: before
]
