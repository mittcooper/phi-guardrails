"
The gate-level demonstration the roadmap reserved for E14 (spec ch. 8 §8.3): a fresh,
in-image gate run over the TOY's own committed configuration artifact
(BaselineOfToy class>>guardrailsSTON), asserted to answer exactly the toy's six planted
red verdicts. Where PGRToyPlantWitnessTest witnesses each plant at check level, this class
witnesses them at gate level - one run of the whole instrument over a real adopter's
config. Lives in the swept Phi-Guardrails-Tests-Toy so the demo itself is enforced by the
verify command and the framework's own gate.

The setUp planted-state guard (D-43 item 2): before each test the toy is checked to be in
its expected planted (all-red) condition - each plant method's current sourceCode must
still contain its body-distinguishing marker. A leak from any source (a failed C02/C03
restoration, an interrupted run, a Playground session, a future test) then fails loudly at
its cause, naming the offending Class>>#selector, instead of surfacing as a confusing
failure elsewhere. The markers are body-distinguishing by construction (probed): each is
present in the committed plant body and absent from that method's own plant comment, so the
guard tracks the body on every mutation path (the fix command preserves comments). The
guard protects all three tests of this class, including the two E14-C02/C03 add.

Termination (D-46): the demo runs the gate on the TOY's config, whose tests role is only
Toy-Tests - so Phi-Guardrails-Tests-Toy (this package) can never enter that set. A
framework self-hosted run nests (outer gate -> behavioral check runs Tests-Toy -> this test
runs an inner gate on the toy config -> the inner behavioral check runs Toy-Tests, which
drives no gate -> terminates); it does not recurse.

The exact-count law (§8.3): the six-verdict count is asserted exactly, the one ruled
exception to floors-only. When the recommended block grows at M5 and the toy's artifact
composes the new entries in, this test breaks by design - a new shipped check must arrive
with a decision about how the toy demonstrates it, not slip in unnoticed behind a >=.
"
Class {
	#name : 'ToyDemoTest',
	#superclass : 'TestCase',
	#category : 'Phi-Guardrails-Tests-Toy',
	#package : 'Phi-Guardrails-Tests-Toy'
}

{ #category : 'fixtures' }
ToyDemoTest >> expectedRegistrationNames [
	"The toy's six resolved registrations, verbatim, in registry order (E12 digest): the
	names the demo asserts the gate answers - lint x3, architecture, then the two
	behavioral registrations."
	^ #(
		'lint/PCKNoIsNilIfTrueRule'
		'lint/ReCodeCruftLeftInMethodsRule'
		'lint/ToyNoIsNilIfFalseRule'
		'architecture/PCKLayerMapCheck'
		'behavioral/Toy-Tests'
		'behavioral/PCKNoSkippedTestsMetaRule' )
]

{ #category : 'fixtures' }
ToyDemoTest >> fixedPlantSources [
	"The six { class. selector. fixedSource } triples (spec 8.3, probed P5): each fixedSource
	is the full method source - selector line then tab-indented body - that turns its plant
	clean under every registered check. The four fix species: the isNil ifTrue:/ifFalse:
	rewrites, the Transcript cruft and the ui->persistence reference removed, the failing
	assertion corrected (an empty order totals 0), the skip replaced by a real assertion (an
	empty order's item count is 0). Compiled transiently by testAllFixedThenClean, then
	restored on the block's return - nothing committed changes (D-43/D-26)."
	^ {
		{ ToyOrder. #totalOrZero. 'totalOrZero
	items ifNil: [ ^ 0 ].
	^ self total' }.
		{ ToyOrder. #logTotal. 'logTotal
	^ self total' }.
		{ ToyOrder. #itemCountOrZero. 'itemCountOrZero
	^ items ifNil: [ 0 ] ifNotNil: [ items size ]' }.
		{ ToyOrderView. #storeSnapshot. 'storeSnapshot
	^ nil' }.
		{ ToyOrderTest. #testTotalIsFortyTwo. 'testTotalIsFortyTwo
	self assert: ToyOrder empty total equals: 0' }.
		{ ToyOrderTest. #testSkippedOnPurpose. 'testSkippedOnPurpose
	self assert: ToyOrder empty itemCount equals: 0' } }
]

{ #category : 'fixtures' }
ToyDemoTest >> plantedShapes [
	"The six { class. selector. marker } triples of the toy's plants, in registry order:
	row i pairs with registration i of expectedRegistrationNames. The marker is the
	body-distinguishing substring probed present in the committed plant body and absent
	from that method's own plant comment. Single source read by the setUp guard and by the
	demo's target assertions (and later chunks' snapshot lists)."
	^ {
		{ ToyOrder. #totalOrZero. 'items isNil ifTrue:' }.
		{ ToyOrder. #logTotal. 'Transcript show: self total' }.
		{ ToyOrder. #itemCountOrZero. 'items isNil ifFalse:' }.
		{ ToyOrderView. #storeSnapshot. 'ToyOrderStore empty' }.
		{ ToyOrderTest. #testTotalIsFortyTwo. 'equals: 42' }.
		{ ToyOrderTest. #testSkippedOnPurpose. 'self skip:' } }
]

{ #category : 'running' }
ToyDemoTest >> runToyGate [
	"One fresh gate run over the toy's own committed artifact: a fresh registry and a fresh
	behavioral suite-run cache per send (the E07 cache law - never reuse a gate across runs)."
	^ (PGRGate forConfiguration:
		(PGRConfiguration fromString: BaselineOfToy guardrailsSTON)) run
]

{ #category : 'running' }
ToyDemoTest >> setUp [
	"D-43 item 2: assert the toy is in its planted (all-red) condition before each test -
	each plant method's current sourceCode still contains its body-distinguishing marker -
	so any leak fails loudly here, naming the leaked Class>>#selector at its cause."
	super setUp.
	self plantedShapes do: [ :shape |
		| targetClass selector marker |
		targetClass := shape first.
		selector := shape second.
		marker := shape third.
		self
			assert: ((targetClass >> selector) sourceCode includesSubstring: marker)
			description: 'planted state leaked: ',
				targetClass name asString, '>>#', selector asString ]
]

{ #category : 'tests' }
ToyDemoTest >> testGateIsRedOnPlantedViolations [
	"Given the committed toy in its planted state (guaranteed by setUp) and its own frozen
	artifact, one fresh gate run answers exactly the six red verdicts, in registry order,
	every one red, each naming its planted target (§8.3)."
	| report |
	report := self runToyGate.
	self deny: report isClean.
	self assert: report exitCode equals: 1.
	self assert: report verdicts size equals: 6.
	self
		assert: (report verdicts collect: [ :verdict | verdict registrationName ]) asArray
		equals: self expectedRegistrationNames.
	self assert: report blockingVerdicts size equals: 6.
	report verdicts doWithIndex: [ :verdict :index |
		| shape expectedTarget |
		shape := self plantedShapes at: index.
		expectedTarget := shape first name asString, '>>#', shape second asString.
		self
			assert: (verdict findings anySatisfy: [ :finding | finding target = expectedTarget ])
			description: 'verdict ', index printString, ' (', verdict registrationName,
				') is missing planted target ', expectedTarget ]
]

{ #category : 'running' }
ToyDemoTest >> restoringSourcesOf: classSelectorPairs during: aBlock [
	"D-43 item 1: each source mutation snapshots its original method - source text and
	protocol - before the block runs, then recompiles every snapshot in an ensure: so
	restoration runs whether the block returned, failed, or errored, never left to
	tearDown alone. Probed (P3): sourceCode answers a ByteString, protocolName a
	ByteSymbol (protocolName, not protocol, which answers a Protocol object);
	compile:classified: recompiles preserving package (Toy-Core) and protocol, and the
	restored sourceCode is byte-identical."
	| snapshots |
	snapshots := classSelectorPairs collect: [ :pair |
		| method |
		method := pair first >> pair second.
		{ pair first. method sourceCode. method protocolName } ].
	^ aBlock ensure: [
		snapshots do: [ :snapshot |
			snapshot first compile: snapshot second classified: snapshot third ] ]
]

{ #category : 'tests' }
ToyDemoTest >> testLintAutofixThenGreen [
	"R-32 demonstration half / spec 8.3 test-2: E08's preview-first fix command (D-06)
	drives the one fixable plant, then a fresh gate run shows that registration alone
	turned green - five still blocking - and the source is restored byte-identically on
	the block's return (D-43 item 1). The plant comment (kept by the fix) still carries
	the naive 'isNil ifTrue:' string, so the post-fix assertion uses the
	body-distinguishing marker 'items isNil ifTrue:' (probed P8)."
	| before |
	before := (ToyOrder >> #totalOrZero) sourceCode.
	self restoringSourcesOf: { { ToyOrder. #totalOrZero } } during: [
		| command greenVerdict report |
		command := PCKFixCommand rule: PCKNoIsNilIfTrueRule packages: #('Toy-Core').
		self assert: (command previewOn: (WriteStream on: String new)) equals: 1.
		self assert: command apply size equals: 1.
		self deny: ((ToyOrder >> #totalOrZero) sourceCode includesSubstring: 'items isNil ifTrue:').
		report := self runToyGate.
		self assert: report verdicts size equals: 6.
		greenVerdict := report verdicts
			detect: [ :verdict | verdict registrationName = 'lint/PCKNoIsNilIfTrueRule' ].
		self assert: greenVerdict isGreen.
		self assert: report blockingVerdicts size equals: 5 ].
	self assert: (ToyOrder >> #totalOrZero) sourceCode equals: before
]

{ #category : 'tests' }
ToyDemoTest >> testAllFixedThenClean [
	"R-32/R-43/R-44 demonstration half, spec 8.3 test-3 (D-43/D-80): with every plant fixed
	in-image - the six probed fixed sources compiled over the plants (the widest mutation) -
	the same gate over the same artifact answers GREEN (isClean, exit code 0), carrying only
	the one #unlayered advisory (D-80, target 'architecture/PCKLayerMapCheck') that rides the
	clean report without blocking it. Then restoration returns the committed red state
	byte-identically - each method's sourceCode back to its pre-test snapshot - completing
	red -> fixed -> green inside one test class. No third gate run after restoration: the
	neighboring tests and every setUp guard pin post-restore red continuously (P5)."
	| pairs snapshots |
	pairs := self plantedShapes collect: [ :shape | { shape first. shape second } ].
	snapshots := pairs collect: [ :pair | (pair first >> pair last) sourceCode ].
	self restoringSourcesOf: pairs during: [
		| report advisory |
		self fixedPlantSources do: [ :triple |
			| targetClass selector |
			targetClass := triple first.
			selector := triple second.
			targetClass
				compile: triple third
				classified: (targetClass >> selector) protocolName ].
		report := self runToyGate.
		self assert: report isClean.
		self assert: report exitCode equals: 0.
		self assert: report advisories size equals: 1.
		advisory := report advisories first.
		self assert: advisory target equals: 'architecture/PCKLayerMapCheck' ].
	pairs with: snapshots do: [ :pair :snapshot |
		self assert: (pair first >> pair last) sourceCode equals: snapshot ]
]
