"
Behavioral pin of PCKFixCommand's construction, error, preview and apply paths (ch. 3 par. 3.3): the not-autofixable guard's two arms, the apply-before-preview error (E08-C02), the D-06 mandatory preview - diff emitted, count answered, changes exposed, nothing mutated (E08-C03) - and the apply legs (E08-C04): rewrite-and-answer, the D-34.2 stale guard, and the consumed-preview second apply. Error classes are asserted by class, never by wording; preview assertions pin content substrings, never layout. Every test that can mutate the plant restores it via the saved-source discipline in setUp/tearDown (ch. 9 P-FIX-PREVIEW).
"
Class {
	#name : 'PCKFixCommandTest',
	#superclass : 'TestCase',
	#instVars : [
		'savedSource'
	],
	#category : 'Phi-Coding-Kit-Tests-Rules',
	#package : 'Phi-Coding-Kit-Tests-Rules'
}

{ #category : 'running' }
PCKFixCommandTest >> setUp [
	"Saved-source discipline (ch. 9 P-FIX-PREVIEW): snapshot the plant's source so
	tearDown can put the bad code back - the fixture must be bad again for whatever
	test runs next (idempotence)."
	super setUp.
	savedSource := (PCKLintBadFixture >> #withIsNilIfTrue) sourceCode
]

{ #category : 'running' }
PCKFixCommandTest >> tearDown [
	"Recompile the snapshot back when the current source differs (P5-confirmed
	spelling: compile:classified: preserves the method's protocol, here 'fixture')."
	savedSource ifNotNil: [
		(PCKLintBadFixture >> #withIsNilIfTrue) sourceCode = savedSource
			ifFalse: [ PCKLintBadFixture compile: savedSource classified: 'fixture' ] ].
	super tearDown
]

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

{ #category : 'tests' }
PCKFixCommandTest >> testPreviewThenApplyRewrites [
	"P-FIX-PREVIEW leg 2 (ch. 9, D-06/R-15): the confirmed diff is the applied diff -
	after apply the plant carries the D-04 rewrite, and apply answered the one change."
	| fix applied current |
	fix := PCKFixCommand rule: PCKNoIsNilIfTrueRule packages: #('Phi-Coding-Kit-Tests-Rules').
	fix previewOn: (WriteStream on: String new).
	applied := fix apply.
	current := (PCKLintBadFixture >> #withIsNilIfTrue) sourceCode.
	self assert: (current includesSubstring: 'ifNil:').
	self deny: (current includesSubstring: 'isNil ifTrue:').
	self assert: applied size equals: 1
]

{ #category : 'tests' }
PCKFixCommandTest >> testSecondApplySignals [
	"One preview authorizes one apply (D-06, chunks.md ruling): the second apply finds
	its preview consumed - PGRFixNotPreviewed, and nothing applies twice."
	| fix afterFirst |
	fix := PCKFixCommand rule: PCKNoIsNilIfTrueRule packages: #('Phi-Coding-Kit-Tests-Rules').
	fix previewOn: (WriteStream on: String new).
	fix apply.
	afterFirst := (PCKLintBadFixture >> #withIsNilIfTrue) sourceCode.
	self should: [ fix apply ] raise: PGRFixNotPreviewed.
	self assert: (PCKLintBadFixture >> #withIsNilIfTrue) sourceCode equals: afterFirst
]

{ #category : 'tests' }
PCKFixCommandTest >> testStaleApplySignals [
	"P-FIX-PREVIEW leg 3 (D-34.2): drift between preview and apply signals PGRFixStale
	and applies nothing - the mutated form survives verbatim, all-or-nothing."
	| fix staleSource |
	fix := PCKFixCommand rule: PCKNoIsNilIfTrueRule packages: #('Phi-Coding-Kit-Tests-Rules').
	fix previewOn: (WriteStream on: String new).
	staleSource := savedSource copyReplaceAll: '#bad' with: '#stale'.
	PCKLintBadFixture compile: staleSource classified: 'fixture'.
	self should: [ fix apply ] raise: PGRFixStale.
	self assert: (PCKLintBadFixture >> #withIsNilIfTrue) sourceCode equals: staleSource
]
