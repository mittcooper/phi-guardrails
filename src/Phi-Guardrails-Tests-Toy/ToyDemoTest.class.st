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
