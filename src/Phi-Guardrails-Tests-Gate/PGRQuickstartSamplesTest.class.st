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

testAdoptAndRunSamples is the adopt-and-run leg (D-59, guide 1's M4 anchor): guide 1's four
samples execute verbatim through the C04 harness - sample 1's config drives the gate to the
four guide-named registrations green, the draft-prose claim parses back, the Metacello sample
compiles to the OCParser boundary and is pinned textually equal to the CI workflow it mirrors
(no in-image network load - the live load is E15-C01's hosted step, D-76/B-26), samples 3 and 4
run under a scratch path binding, and the two §5 first-run failures raise PGRConfigurationError
/ answer a missing verdict exactly as documented. A scratch Acme world (BaselineOfAcme + three
role packages) is built and removed in-test via the tracked harness.
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
PGRQuickstartSamplesTest >> acmeWorldSources [
	"The harness-install: source strings for the scratch Acme world guide 1's sample 1 targets:
	a BaselineOfAcme declaring three role packages via a <baseline>-pragma baseline: method (the
	P3-probed fluid shape), and one clean class per package - two production classes clean under
	both catalog lint rules and one passing TestCase clean under the no-skips meta-rule. Ordered
	baseline-first so the role packages exist by the time fromString: introspects the baseline."
	^ {
		'BaselineOf << #BaselineOfAcme package: ''BaselineOfAcme''
BaselineOfAcme >> baseline: spec
	<baseline>
	spec for: #common do: [ spec package: ''Acme-Core''; package: ''Acme-Server''; package: ''Acme-Tests'' ]'.
		'Object << #AcmeCore package: ''Acme-Core''
AcmeCore >> ping
	^ 42'.
		'Object << #AcmeServer package: ''Acme-Server''
AcmeServer >> start
	^ true'.
		'TestCase << #AcmeSmokeTest package: ''Acme-Tests''
AcmeSmokeTest >> testTruth
	self assert: 3 + 4 = 7' }
]

{ #category : 'fixtures' }
PGRQuickstartSamplesTest >> committedWorkflowText [
	"Read .github/workflows/ci.yml via the same three-stage locator chain the harness's own
	guideNamed: uses (the working-directory walk is not the CI path - B-26 - so all three stages
	are chained); a nil after all three is a loud error, never a skip."
	| harness parts found |
	harness := PGRQuickstartSampleHarness new.
	parts := { '.github'. 'workflows'. 'ci.yml' }.
	found := (harness locateUpwardFrom: FileSystem workingDirectory for: parts)
		ifNil: [ (harness smalltalkCILocateFor: parts)
			ifNil: [ harness locateUpwardFrom: FileLocator imageDirectory for: parts ] ].
	found ifNil: [ ^ self error: 'committed workflow not found: .github/workflows/ci.yml' ].
	^ found contents
]

{ #category : 'fixtures' }
PGRQuickstartSamplesTest >> installAcmeWorldOn: aHarness [
	"Install every acmeWorldSources string through aHarness (tracked for teardown by the caller)."
	self acmeWorldSources do: [ :source | aHarness install: source ]
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
PGRQuickstartSamplesTest >> testAdoptAndRunSamples [
	"Ch.-9-named, P-GUIDE-EXEC (adopt-and-run leg, D-59): guide 1's four samples execute verbatim
	through the C04 harness and each behaves as the guide states. One method, the D-59 shape; its
	arms fail individually with named assertions. The scratch Acme world is tracked (newHarness),
	so a mid-arm failure still tears it down; the Metacello sample is executed only to the
	OCParser boundary - its live load is E15-C01's hosted step - and this arm pins the guide's
	load coordinates textually equal to the CI workflow so the two cannot diverge."
	| harness acmeHarness samples s1 s2 s3 s4 gate report names scratchDir missingVerdict nonconformingConfig |
	harness := self newHarness.

	"1 - inventory pin: exactly four samples, in the config-then-three-smalltalk order."
	samples := harness samplesIn: (harness guideNamed: '01-adopt-and-run.md').
	self assert: samples size = 4 description: 'guide 1 must offer its four samples'.
	self assert: (samples collect: [ :each | each key ]) asArray = #(ston smalltalk smalltalk smalltalk)
		description: 'the samples are the config, the Metacello load, the in-image run, and the defective-config handler'.
	s1 := (samples at: 1) value.
	s2 := (samples at: 2) value.
	s3 := (samples at: 3) value.
	s4 := (samples at: 4) value.

	"2 - install the scratch Acme world sample 1 targets (tracked; tearDown removes all)."
	acmeHarness := self newHarness.
	self installAcmeWorldOn: acmeHarness.

	"3 - sample 1 runs the gate: the four guide-named registrations in order, all green, exit 0."
	gate := PGRGate forConfiguration: (PGRConfiguration fromString: s1).
	report := gate run.
	names := (report verdicts collect: [ :each | each registrationName ]) asArray.
	self assert: names = #('lint/PCKNoIsNilIfTrueRule' 'lint/ReCodeCruftLeftInMethodsRule' 'behavioral/Acme-Tests' 'behavioral/PCKNoSkippedTestsMetaRule')
		description: 'the gate answers exactly the guide-named registrations, in order'.
	self assert: report isClean description: 'the clean scratch world is green'.
	self assert: report exitCode = 0 description: 'a clean run exits 0'.

	"4 - the draft-prose claim: draftFor: the scratch baseline answers a draft fromString: accepts."
	self assert: (PGRConfiguration fromString: (PGRConfigurationDraft draftFor: 'BaselineOfAcme')) project = 'Acme'
		description: 'the draft the guide promises parses back into a usable configuration'.

	"5 - sample 2 compiles clean and cannot diverge from the workflow it mirrors."
	self deny: (OCParser parseExpression: s2) isFaulty
		description: 'the Metacello load sample is syntactically clean'.
	self assert: (s2 includesSubstring: 'baseline: ''PhiGuardrails''')
		description: 'the sample names the real baseline'.
	self assert: (s2 includesSubstring: 'repository: ''github://mittcooper/phi-guardrails:main/src''')
		description: 'the sample names the real repository coordinates'.
	self assert: (self committedWorkflowText includesSubstring: 'baseline: ''PhiGuardrails''')
		description: 'the CI workflow loads the same baseline - the guide cannot diverge'.
	self assert: (self committedWorkflowText includesSubstring: 'repository: ''github://mittcooper/phi-guardrails:main/src''')
		description: 'the CI workflow loads the same repository - the guide cannot diverge'.

	"6 + 7 - samples 3 and 4 execute verbatim under a scratch path binding."
	scratchDir := FileSystem workingDirectory / 'pgr-e15-scratch'.
	scratchDir ensureCreateDirectory.
	[ | goodPath badPath defectText result |
		goodPath := (scratchDir / 'acme.ston') fullName.
		(scratchDir / 'acme.ston') writeStreamDo: [ :stream | stream nextPutAll: s1 ].
		badPath := (scratchDir / 'bad.ston') fullName.
		(scratchDir / 'bad.ston') writeStreamDo: [ :stream | stream nextPutAll: '{ #schemaVersion : 2, #junk }' ].

		"6 - the in-image run answers empty blockingVerdicts on the clean world."
		self assert: ((OpalCompiler new evaluate: '[:path | ' , s3 , ' ]') value: goodPath) isEmpty
			description: 'the in-image run sample answers empty blockingVerdicts on the clean world'.

		"7 - the defective-config handler, both ways, plus the raw raise it wraps."
		defectText := (OpalCompiler new evaluate: '[:path | ' , s4 , ' ]') value: badPath.
		self assert: (defectText isString and: [ defectText notEmpty ])
			description: 'a bad path drives the handler to answer a non-empty error message text'.
		result := (OpalCompiler new evaluate: '[:path | ' , s4 , ' ]') value: goodPath.
		self assert: result project = 'Acme'
			description: 'a good path flows through the handler-wrapped sample to the parsed configuration'.
		self should: [ PGRConfiguration fromFile: badPath ] raise: PGRConfigurationError
			description: 'the malformed config file raises a configuration error before anything runs'
	] ensure: [ scratchDir ensureDeleteAll ].

	"8 - §5 failure 2: a check-name typo resolves to nothing (one missing verdict, exit 1); a
	name resolving to a loaded but non-conforming class is a configuration error at registry
	build (`PGRGate forConfiguration:`), not at `fromString:` (D-51)."
	gate := PGRGate forConfiguration: (PGRConfiguration fromString: (s1 copyReplaceAll: 'PCKNoIsNilIfTrueRule' with: 'PCKNoIsNilIfTrue')).
	report := gate run.
	missingVerdict := report verdicts detect: [ :each | each registrationName = 'lint/PCKNoIsNilIfTrue' ].
	self assert: missingVerdict status = #missing
		description: 'a check name resolving to no loaded class is a missing verdict'.
	self assert: report exitCode = 1 description: 'a missing verdict fails the gate, exit 1'.
	nonconformingConfig := PGRConfiguration fromString: (s1 copyReplaceAll: 'PCKNoIsNilIfTrueRule' with: 'OrderedCollection').
	self should: [ PGRGate forConfiguration: nonconformingConfig ]
		raise: PGRConfigurationError
		description: 'a name resolving to a loaded but non-conforming class is a configuration error (the guide §5 exit-2 case) - the parse above already succeeded (kit-block rule names are opaque to config parsing, D-51), so the error is raised only as the registry builds eagerly'.

	"9 - §5 failure 1 (last: it mutates the scratch baseline): a package the baseline declares but
	no role covers fails the scope law. Grow the baseline with an unmatched Acme-Benchmarks and
	recompile its baseline: method; no restoration - teardown removes the world, no arm follows."
	acmeHarness install: 'Object << #AcmeBenchmark package: ''Acme-Benchmarks'''.
	acmeHarness install: 'BaselineOfAcme >> baseline: spec
	<baseline>
	spec for: #common do: [ spec package: ''Acme-Core''; package: ''Acme-Server''; package: ''Acme-Tests''; package: ''Acme-Benchmarks'' ]'.
	self should: [ PGRConfiguration fromString: s1 ] raise: PGRConfigurationError
		description: 'a package the baseline declares but no role covers fails the scope law'
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
