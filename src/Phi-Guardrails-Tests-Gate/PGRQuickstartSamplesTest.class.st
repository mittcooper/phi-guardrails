"
E09-C05 · P-GUIDE-EXEC (ch. 9 §9.2), the write-a-check leg (D-59: one test method per
guide). testWriteACheckSamples executes every sample of the committed
docs/quickstarts/02-write-a-check.md verbatim through the accepted C04 harness and asserts
each behaves as the guide states - superclass, kind/run/canFix/fixCommandOn:, the fixture
pair running green, and the registration appearing in the gate report. A sample the surface
no longer satisfies would be a P-GUIDE-EXEC finding to report, never a guide the test patches
(the guides are producer-owned). testBuildAKitSamples is C06's scheduled addition to this
file. Every scratch Acme class/package is created and removed in-test (ensure: + tearDown, the
E08-C04 discipline); the harnesses are tracked so a mid-arm failure still tears everything
down. Verified spellings (in-image, this chunk): a fresh class's `comment` is an empty
ByteString (not nil), so `comment isNil or: [ comment isEmpty ]` flags it; `cls name` answers
a Symbol yet `aSymbol = 'aString'` is true here, so sample 3's `f target = '...'` holds.
"
Class {
	#name : 'PGRQuickstartSamplesTest',
	#superclass : 'TestCase',
	#instVars : [
		'harnesses'
	],
	#category : 'Phi-Guardrails-Tests-Gate',
	#package : 'Phi-Guardrails-Tests-Gate'
}

{ #category : 'fixtures' }
PGRQuickstartSamplesTest >> envelopeWithFragment: aKitBlockFragment [
	"The canonical scratch envelope (the accepted E05-C03 PGRGateTest shape, duplicated
	locally - deliberate self-containment) with the given text spliced into the coding-kit
	block. BaselineOfPGRScratchGrouped is the accepted E03 fixture, named inside the artifact
	string; its roles expand to scratch-prod = SDK + Core, scratch-tst = Phi-Guardrails-Tests-SDK,
	scratch-ghost exempt."
	^ '{
	#schemaVersion : 2,
	#project : ''Scratch'',
	#baseline : ''BaselineOfPGRScratchGrouped'',
	#roles : {
		#production : [ ''scratch-prod'' ],
		#tests : [ ''scratch-tst'' ],
		#exempt : [ ''scratch-ghost'' ] },
	#kits : [ { #kit : ''PCKKit'', ' , aKitBlockFragment , ' } ]
}'
]

{ #category : 'fixtures' }
PGRQuickstartSamplesTest >> envelopeWithKits: aKitsKeyValue [
	"The same canonical scratch envelope as envelopeWithFragment: (the accepted E05-C03
	PGRGateTest shape), but with the whole #kits key-value spliced in verbatim: guide 3 sample 2
	is the entire two-block #kits array (a PCKKit block and a DKKit block), not a single
	coding-kit fragment. BaselineOfPGRScratchGrouped's roles expand to scratch-prod = SDK + Core,
	scratch-tst = Phi-Guardrails-Tests-SDK, scratch-ghost exempt."
	^ '{
	#schemaVersion : 2,
	#project : ''Scratch'',
	#baseline : ''BaselineOfPGRScratchGrouped'',
	#roles : {
		#production : [ ''scratch-prod'' ],
		#tests : [ ''scratch-tst'' ],
		#exempt : [ ''scratch-ghost'' ] },
	' , aKitsKeyValue , '
}'
]

{ #category : 'fixtures' }
PGRQuickstartSamplesTest >> newHarness [
	"A fresh harness, tracked for teardown so tearDown removes everything it installed even if
	an arm fails mid-test."
	| harness |
	harness := PGRQuickstartSampleHarness new.
	harnesses add: harness.
	^ harness
]

{ #category : 'fixtures' }
PGRQuickstartSamplesTest >> plainClassStorageMethods [
	"The author's own storage plumbing sample 2 (§2) deliberately elides (D-60: illustrative,
	the author's own class): the setter answers self by default, which the sample's own
	`^ self new setPackages: names` relies on, and the reader its `run` reads. Compiled as
	harness-supplied input onto the installed plain class, under the sample's own methods."
	^ 'AcmeClassCommentCheck >> setPackages: aCollection
	packages := aCollection
AcmeClassCommentCheck >> packages
	^ packages'
]

{ #category : 'running' }
PGRQuickstartSamplesTest >> setUp [
	super setUp.
	harnesses := OrderedCollection new
]

{ #category : 'running' }
PGRQuickstartSamplesTest >> tearDown [
	harnesses do: [ :each | each removeInstalled ].
	super tearDown
]

{ #category : 'tests' }
PGRQuickstartSamplesTest >> testBuildAKitSamples [
	"Ch.-9-named, P-GUIDE-EXEC (build-a-kit leg): guide 3's two samples execute verbatim through
	the C04 harness and each behaves as the guide states - the two class-side contract messages,
	the stanza parsing as a kit block, strict validation raising PGRConfigurationError, the
	missing/resolved spec pair, and the composed adopter artifact yielding both kits' registrations
	in block order. One method, the D-59 shape; its arms fail individually with named assertions.
	DKKit and DKClassCommentCheck are scratch, built here and removed by tearDown (the harness is
	tracked in newHarness, so a mid-arm failure still tears everything down)."
	| harness samples s1 s2 kitClass parsed specs spec checkSource gate report names pckNames pckMax dkMin |
	harness := self newHarness.
	samples := harness samplesIn: (harness guideNamed: '03-build-a-kit.md').
	self assert: samples size = 2 description: 'guide 3 must offer its two samples'.
	s1 := (samples at: 1) value.
	s2 := (samples at: 2) value.

	"1 - install sample 1, the working kit: superclass PGRKit and both contract messages class-side."
	harness install: s1.
	kitClass := Smalltalk classNamed: 'DKKit'.
	self assert: kitClass notNil description: 'the DKKit class installs'.
	self assert: kitClass superclass == PGRKit description: 'DKKit subclasses the skeleton PGRKit'.
	self assert: (kitClass class includesSelector: #recommendedBlock) description: 'recommendedBlock is class-side'.
	self assert: (kitClass class includesSelector: #registrationsFrom:productionPackages:testsPackages:) description: 'the working message is class-side - two messages, both class-side'.

	"2 - stanza arm: recommendedBlock parses cleanly as a kit block."
	parsed := STON fromString: kitClass recommendedBlock.
	self assert: (parsed at: #kit) = 'DKKit' description: 'the stanza names the kit DKKit'.
	self assert: (parsed at: #docChecks) = #('DKClassCommentCheck') description: 'the stanza lists its doc check'.

	"3 - strict-validation arm: an unknown key inside the block is a PGRConfigurationError the kit raises."
	self
		should: [ kitClass
			registrationsFrom: (Dictionary new at: #kit put: 'DKKit'; at: #zzz put: #(); yourself)
			productionPackages: #()
			testsPackages: #() ]
		raise: PGRConfigurationError.

	"4 - missing arm: an unresolved name answers a doc/-named #doc missing spec - silence is not an option."
	specs := kitClass registrationsFrom: parsed productionPackages: #('P-One') testsPackages: #().
	self assert: specs size = 1 description: 'one spec per named check, never fewer than the block names'.
	spec := specs first.
	self assert: spec name = 'doc/DKClassCommentCheck' description: 'the missing spec is named doc/DKClassCommentCheck'.
	self assert: spec kind = #doc description: 'the missing spec keeps the kit-given #doc kind'.
	self assert: spec check isNil description: 'the missing spec carries no check'.

	"5 - resolved arm: install a conforming DKClassCommentCheck; the name is instantiated via its
	promised packages: constructor with the handed production list."
	checkSource := 'PGRCheck << #DKClassCommentCheck package: ''Demo-Kit-Checks''
DKClassCommentCheck >> kind
	^ #doc
DKClassCommentCheck >> run
	^ PGRVerdict green'.
	harness install: checkSource.
	specs := kitClass registrationsFrom: parsed productionPackages: #('P-One') testsPackages: #().
	spec := specs first.
	self assert: spec name = 'doc/DKClassCommentCheck' description: 'the resolved spec keeps the doc/ name'.
	self assert: spec check notNil description: 'the resolved name answers a live check'.
	self assert: spec check class name = 'DKClassCommentCheck' description: 'the check is a DKClassCommentCheck instance, built via its own constructor'.
	self assert: spec check packages = #('P-One') description: 'the check was built via packages: with the handed production list'.

	"6 - sample 2, the adopter file: both blocks register, every PCK verdict before every DK verdict."
	gate := PGRGate forConfiguration: (PGRConfiguration fromString: (self envelopeWithKits: s2)).
	report := gate run.
	names := report verdicts collect: [ :each | each registrationName ].
	self assert: (names includes: 'lint/PCKNoIsNilIfTrueRule') description: 'the PCK block registers its lint rule'.
	self assert: (names includes: 'doc/DKClassCommentCheck') description: 'the DK block registers its doc check'.
	self assert: (names includes: 'behavioral/Phi-Guardrails-Tests-SDK') description: 'the PCK block derives its behavioral suite from the scratch tests role'.
	pckNames := #('lint/PCKNoIsNilIfTrueRule' 'behavioral/Phi-Guardrails-Tests-SDK').
	pckMax := (pckNames collect: [ :n | names indexOf: n ]) max.
	dkMin := names indexOf: 'doc/DKClassCommentCheck'.
	self assert: pckMax < dkMin description: 'every PCK-block verdict precedes every DK-block verdict - blocks are ordered (D-51)'
]

{ #category : 'tests' }
PGRQuickstartSamplesTest >> testWriteACheckSamples [
	"Ch.-9-named, P-GUIDE-EXEC (write-a-check leg): the five samples of the committed guide 2
	execute verbatim through the C04 harness and each behaves as the guide states. One method,
	the D-59 shape; its arms fail individually with named assertions."
	| harness samples s1 s2 s3 s4 s5 plainHarness cls inst registry registration skeleton
	  uncommented commented testClass result gate report names |
	harness := self newHarness.
	samples := harness samplesIn: (harness guideNamed: '02-write-a-check.md').
	self assert: samples size = 5 description: 'guide 2 must offer its five samples'.
	s1 := (samples at: 1) value.
	s2 := (samples at: 2) value.
	s3 := (samples at: 3) value.
	s4 := (samples at: 4) value.
	s5 := (samples at: 5) value.

	"§2 - the plain class, in an isolated pass (it redefines sample 1's class name). Play the
	author's hand: install with the elided slot, supply the elided storage, then the sample's
	own constructor/kind/canFix stand on top; the same check with no framework superclass
	conforms and registers resolved - conformance, not ancestry, at the engine."
	plainHarness := self newHarness.
	[
		plainHarness install: s2 slots: #(packages).
		plainHarness install: self plainClassStorageMethods.
		cls := Smalltalk classNamed: 'AcmeClassCommentCheck'.
		self assert: cls notNil description: 'the plain class installs'.
		self assert: cls superclass == Object description: 'the plain class has no framework superclass'.
		inst := cls packages: #('P-One').
		self assert: inst kind = #architecture description: 'the plain check answers its own kind'.
		self deny: inst canFix description: 'the plain check declares canFix false'.
		self assert: inst packages = #('P-One') description: 'the plain constructor stores the handed packages'.
		registry := PGRRegistry fromConfiguration: (PGRConfiguration fromString: (self envelopeWithFragment: s4)).
		registration := registry registrations detect: [ :each | each name = 'architecture/AcmeClassCommentCheck' ].
		self assert: registration isResolved description: 'the plain class registers resolved - conformance, not ancestry'
	] ensure: [ plainHarness removeInstalled ].

	"§1 + §5 - the skeleton path and the fix capability on the same class."
	harness install: s1.
	harness install: s5.
	skeleton := Smalltalk classNamed: 'AcmeClassCommentCheck'.
	self assert: skeleton superclass == PGRCheck description: 'the skeleton check subclasses PGRCheck'.
	self assert: (skeleton includesSelector: #kind) description: 'the skeleton carries kind'.
	self assert: (skeleton includesSelector: #run) description: 'the skeleton carries the real run'.
	self assert: (skeleton includesSelector: #canFix) description: 'sample 5 declares canFix'.
	self assert: (skeleton includesSelector: #fixCommandOn:) description: 'sample 5 wires fixCommandOn:'.
	self assert: (skeleton respondsTo: #packages:) description: 'packages: is answered'.
	self deny: (skeleton class includesSelector: #packages:) description: 'packages: is inherited from the skeleton, not written'.
	self assert: (skeleton packages: #('scratch-prod')) canFix description: 'the skeleton instance declares canFix true'.

	"§3 fixture inputs (harness-supplied - the samples reference these but do not define them):
	a bad fixture the check must flag and a good one it must ignore."
	harness install: 'Object << #AcmeUncommentedFixture package: ''Acme-Guardrails-Fixtures'''.
	harness install: 'Object << #AcmeCommentedFixture package: ''Acme-Guardrails-GoodFixtures'''.
	uncommented := Smalltalk classNamed: 'AcmeUncommentedFixture'.
	commented := Smalltalk classNamed: 'AcmeCommentedFixture'.
	commented comment: 'A fixture that carries an intention comment.'.
	self assert: uncommented comment isEmpty description: 'the bad fixture carries no comment'.
	self deny: commented comment isEmpty description: 'the good fixture carries a comment'.

	"§3 - the sample's own fixture-pair tests run 2/2 green against the sample check."
	harness install: 'TestCase << #AcmeClassCommentCheckTest package: ''Acme-Guardrails-Tests'''.
	harness install: s3.
	testClass := Smalltalk classNamed: 'AcmeClassCommentCheckTest'.
	result := testClass suite run.
	self assert: result runCount = 2 description: 'both sample-3 tests run'.
	self assert: result passedCount = 2 description: 'bad-fixture-fires and good-fixture-silent both pass'.
	self assert: result failureCount = 0 description: 'no sample-3 failure'.
	self assert: result errorCount = 0 description: 'no sample-3 error'.

	"§4 - the registration line: the gate report names the registration."
	gate := PGRGate forConfiguration: (PGRConfiguration fromString: (self envelopeWithFragment: s4)).
	report := gate run.
	names := report verdicts collect: [ :each | each registrationName ].
	self assert: (names includes: 'architecture/AcmeClassCommentCheck')
		description: 'the registration appears in every report as architecture/AcmeClassCommentCheck'
]
