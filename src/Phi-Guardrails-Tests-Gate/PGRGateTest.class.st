"
E05-C03: PGRGate construction, run, and streaming. P-GATE-COMPLETE
(testOneVerdictPerRegistration): one verdict per registration, in registry order, over a
green/red/missing three-spec artifact. P-STREAM, sink arm (testVerdictsStreamInOrder):
onVerdict: collects every verdict in registry order, each member identical (==) to the
report's own, all delivered before run returns. P-STREAM, no-sink arm
(testNoSinkMeansNoStreaming): with no sink set, run still answers normally and the report
still carries every verdict - nothing needs a sink, and no default exists to receive one
(D-55). P-JUDGE-CONVICTS (testDeliberatelyRedRegistrationIsReported, D-40): a deliberately
red registration leaves the report unclean, named in blockingVerdicts, exitCode 1. Carries
its own scratch-envelope helpers (the E04 PGRRegistryTest precedent; helper duplication
across test classes is deliberate self-containment).
"
Class {
	#name : 'PGRGateTest',
	#superclass : 'TestCase',
	#instVars : [
		'scratchDirectory'
	],
	#category : 'Phi-Guardrails-Tests-Gate',
	#package : 'Phi-Guardrails-Tests-Gate'
}

{ #category : 'fixtures' }
PGRGateTest >> artifactWithKitsFragment: aStonKitsArrayString [
	"The canonical scratch envelope - E03's validArtifactString shape against the C20 scratch fixtures - with the given #kits array text spliced in."
	^ '{
	#schemaVersion : 2,
	#project : ''Scratch'',
	#baseline : ''BaselineOfPGRScratchGrouped'',
	#roles : {
		#production : [ ''scratch-prod'' ],
		#tests : [ ''scratch-tst'' ],
		#exempt : [ ''scratch-ghost'' ] },
	#kits : ' , aStonKitsArrayString , '
}'
]

{ #category : 'fixtures' }
PGRGateTest >> gateFromKitsFragment: aStonKitsArrayString [
	^ PGRGate forConfiguration:
		(PGRConfiguration fromString: (self artifactWithKitsFragment: aStonKitsArrayString))
]

{ #category : 'fixtures' }
PGRGateTest >> threeSpecKitsFragment [
	"Green scratch/G1, red scratch/R1, missing scratch/M1 - registry order fixed by answer order."
	^ '[ { #kit : ''PGRScratchSpecKit'', #specs : [
		{ #name : ''scratch/G1'', #kind : ''scratch'', #check : ''PGRScratchGreenCheck'' },
		{ #name : ''scratch/R1'', #kind : ''scratch'', #check : ''PGRScratchRedCheck'' },
		{ #name : ''scratch/M1'', #kind : ''scratch'', #missing : ''engine absent'' } ] } ]'
]

{ #category : 'tests' }
PGRGateTest >> testOneVerdictPerRegistration [
	"Ch.-9-named, P-GATE-COMPLETE: report verdict names equal exactly the registry's registration names, in order."
	| report |
	report := (self gateFromKitsFragment: self threeSpecKitsFragment) run.
	self assert: (report verdicts collect: [ :v | v registrationName ])
		equals: #( 'scratch/G1' 'scratch/R1' 'scratch/M1' )
]

{ #category : 'tests' }
PGRGateTest >> testVerdictsStreamInOrder [
	"Ch.-9-named, P-STREAM (sink arm): the sink collects one verdict per registration, in registry order, each identical (==) to the report's own - every one delivered before run returned."
	| gate streamed report |
	streamed := OrderedCollection new.
	gate := self gateFromKitsFragment: self threeSpecKitsFragment.
	gate onVerdict: [ :verdict | streamed add: verdict ].
	report := gate run.
	self assert: streamed size equals: 3.
	streamed with: report verdicts do: [ :one :other | self assert: one == other ]
]

{ #category : 'tests' }
PGRGateTest >> testNoSinkMeansNoStreaming [
	"Ch.-9-named, P-STREAM (no-sink arm): with no sink set, run answers normally and the report still carries every verdict - no default sink exists to receive one (D-55)."
	| report |
	report := (self gateFromKitsFragment: self threeSpecKitsFragment) run.
	self assert: report verdicts size equals: 3
]

{ #category : 'fixtures' }
PGRGateTest >> plainBaselineArtifactString [
	"The E04-C05 plain-baseline shape: no groups, one green scratch/P1 spec - this arm wants a runnable second gate."
	^ '{
	#schemaVersion : 2,
	#project : ''ScratchPlain'',
	#baseline : ''BaselineOfPGRScratchPlain'',
	#roles : {
		#production : [ ''Phi-Guardrails-SDK'', ''Phi-Guardrails-Core'' ],
		#tests : [ ''Phi-Guardrails-Tests-SDK'' ] },
	#kits : [ { #kit : ''PGRScratchSpecKit'', #specs : [
		{ #name : ''scratch/P1'', #kind : ''scratch'', #check : ''PGRScratchGreenCheck'' } ] } ]
}'
]

{ #category : 'tests' }
PGRGateTest >> testRunContinuesAfterErroringCheck [
	"Ch.-9-named, P-ERR-IS-RED (gate arm, completing the property): with the throwing check placed mid-registry, the erroring registration yields #red with the error text as its finding message, the run continues, and every later registration still produced a verdict; the report exits 1."
	| report middle last |
	report := (self gateFromKitsFragment: '[ { #kit : ''PGRScratchSpecKit'', #specs : [
		{ #name : ''scratch/G1'', #kind : ''scratch'', #check : ''PGRScratchGreenCheck'' },
		{ #name : ''scratch/E1'', #kind : ''scratch'', #check : ''PGRScratchErroringCheck'' },
		{ #name : ''scratch/G2'', #kind : ''scratch'', #check : ''PGRScratchGreenCheck'' } ] } ]') run.
	self assert: report verdicts size equals: 3.
	middle := report verdicts at: 2.
	self assert: middle registrationName equals: 'scratch/E1'.
	self assert: middle status equals: #red.
	self assert: middle findings size equals: 1.
	self assert: (middle findings first message includesSubstring: 'scratch check exploded').
	last := report verdicts at: 3.
	self assert: last registrationName equals: 'scratch/G2'.
	self assert: last isGreen.
	self assert: report exitCode equals: 1
]

{ #category : 'tests' }
PGRGateTest >> testMissingRegistrationFailsGate [
	"Ch.-9-named, P-GATE-MISSING (gate half): a missing registration's verdict has status #missing, isClean is false, exitCode = 1."
	| report missing |
	report := (self gateFromKitsFragment: '[ { #kit : ''PGRScratchSpecKit'', #specs : [
		{ #name : ''scratch/G1'', #kind : ''scratch'', #check : ''PGRScratchGreenCheck'' },
		{ #name : ''scratch/M1'', #kind : ''scratch'', #missing : ''engine absent'' } ] } ]') run.
	missing := report verdicts at: 2.
	self assert: missing registrationName equals: 'scratch/M1'.
	self assert: missing status equals: #missing.
	self deny: report isClean.
	self assert: report exitCode equals: 1
]

{ #category : 'tests' }
PGRGateTest >> testRunMutatesNoSource [
	"Ch.-9-named, P-GATE-PURE (R-12): snapshot sourceCode of every method of the scratch check classes the run touches, keyed by selector, per class; run a gate over a red configuration; every snapshotted source is identical afterwards - the gate only reports. Both-sides dictionary equality (not a live-side lookup loop) so a run that deletes a method - or every method - cannot pass silently: Dictionary >> = compares size and content together."
	| greenBefore redBefore |
	greenBefore := Dictionary new.
	PGRScratchGreenCheck methods do: [ :m | greenBefore at: m selector put: m sourceCode ].
	redBefore := Dictionary new.
	PGRScratchRedCheck methods do: [ :m | redBefore at: m selector put: m sourceCode ].
	(self gateFromKitsFragment: '[ { #kit : ''PGRScratchSpecKit'', #specs : [
		{ #name : ''scratch/G1'', #kind : ''scratch'', #check : ''PGRScratchGreenCheck'' },
		{ #name : ''scratch/R1'', #kind : ''scratch'', #check : ''PGRScratchRedCheck'' } ] } ]') run.
	self assert: (PGRScratchGreenCheck methods inject: Dictionary new into: [ :d :m | d at: m selector put: m sourceCode; yourself ])
		equals: greenBefore.
	self assert: (PGRScratchRedCheck methods inject: Dictionary new into: [ :d :m | d at: m selector put: m sourceCode; yourself ])
		equals: redBefore
]

{ #category : 'tests' }
PGRGateTest >> testTwoGatesProduceIndependentReports [
	"P-REG-FRESH gate clause (the E04-recorded split, completed): two gates over the grouped and plain artifacts answer reports that share nothing - independent verdict names, no shared verdict identity, and a fresh re-run of one leaves the other's already-answered report unchanged."
	| groupedFragment groupedGate plainGate groupedReport plainReport plainNamesBefore |
	groupedFragment := '[ { #kit : ''PGRScratchSpecKit'', #specs : [
		{ #name : ''scratch/G1'', #kind : ''scratch'', #check : ''PGRScratchGreenCheck'' },
		{ #name : ''scratch/M1'', #kind : ''scratch'', #missing : ''engine absent'' } ] } ]'.
	groupedGate := self gateFromKitsFragment: groupedFragment.
	plainGate := PGRGate forConfiguration: (PGRConfiguration fromString: self plainBaselineArtifactString).
	groupedReport := groupedGate run.
	plainReport := plainGate run.
	self assert: (groupedReport verdicts collect: [ :v | v registrationName ]) equals: #( 'scratch/G1' 'scratch/M1' ).
	self assert: (plainReport verdicts collect: [ :v | v registrationName ]) equals: #( 'scratch/P1' ).
	groupedReport verdicts do: [ :gv | plainReport verdicts do: [ :pv | self deny: gv == pv ] ].
	plainNamesBefore := plainReport verdicts collect: [ :v | v registrationName ].
	(self gateFromKitsFragment: groupedFragment) run.
	self assert: (plainReport verdicts collect: [ :v | v registrationName ]) equals: plainNamesBefore
]

{ #category : 'tests' }
PGRGateTest >> testDeliberatelyRedRegistrationIsReported [
	"Ch.-9-named, P-JUDGE-CONVICTS (D-40): a deliberately red registration leaves the report unclean, named in blockingVerdicts, exitCode 1."
	| report |
	report := (self gateFromKitsFragment: '[ { #kit : ''PGRScratchSpecKit'', #specs : [
		{ #name : ''scratch/R1'', #kind : ''scratch'', #check : ''PGRScratchRedCheck'' } ] } ]') run.
	self deny: report isClean.
	self assert: (report blockingVerdicts collect: [ :v | v registrationName ]) equals: #( 'scratch/R1' ).
	self assert: report exitCode equals: 1
]

{ #category : 'fixtures' }
PGRGateTest >> scratchFileNamed: aFileName contents: aString [
	"Write aString verbatim to scratchDirectory / aFileName; answer the full path - the
	accepted PGRConfigurationTest scratch-file shape (writeStreamDo: + nextPutAll:)."
	| path |
	path := scratchDirectory / aFileName.
	path writeStreamDo: [ :stream | stream nextPutAll: aString ].
	^ path fullName
]

{ #category : 'fixtures' }
PGRGateTest >> scratchArtifactFileFor: aStonKitsArrayString named: aFileName [
	"The canonical scratch envelope (artifactWithKitsFragment:, E05-C03's helper on this
	class) with the given #kits fragment, written to scratchDirectory / aFileName; answer
	the full path."
	^ self scratchFileNamed: aFileName contents: (self artifactWithKitsFragment: aStonKitsArrayString)
]

{ #category : 'running' }
PGRGateTest >> setUp [
	super setUp.
	scratchDirectory := FileSystem workingDirectory / 'pgr-e05-scratch'.
	scratchDirectory ensureCreateDirectory
]

{ #category : 'running' }
PGRGateTest >> tearDown [
	scratchDirectory ensureDeleteAll.
	super tearDown
]

{ #category : 'tests' }
PGRGateTest >> testRunHeadlessAnswersExitCode [
	"Ch.-9-named, P-GATE-HEADLESS: a clean artifact file at an explicit scratch path answers
	0; a red one answers 1; both streams carry the header line and the final GATE: summary
	line by return - the full report reached the stream before the exit code was answered
	(the §7.3 flush requirement, machine-stated)."
	| cleanPath redPath cleanStream redStream |
	cleanPath := self scratchArtifactFileFor: '[ { #kit : ''PGRScratchSpecKit'', #specs : [
		{ #name : ''scratch/G1'', #kind : ''scratch'', #check : ''PGRScratchGreenCheck'' } ] } ]' named: 'clean.ston'.
	redPath := self scratchArtifactFileFor: '[ { #kit : ''PGRScratchSpecKit'', #specs : [
		{ #name : ''scratch/R1'', #kind : ''scratch'', #check : ''PGRScratchRedCheck'' } ] } ]' named: 'red.ston'.
	cleanStream := WriteStream on: String new.
	redStream := WriteStream on: String new.
	self assert: (PGRGate runHeadless: cleanPath on: cleanStream) equals: 0.
	self assert: (PGRGate runHeadless: redPath on: redStream) equals: 1.
	self assert: (cleanStream contents includesSubstring: 'PGR gate · Scratch').
	self assert: (cleanStream contents includesSubstring: 'GATE: GREEN').
	self assert: (redStream contents includesSubstring: 'PGR gate · Scratch').
	self assert: (redStream contents includesSubstring: 'GATE: RED')
]

{ #category : 'tests' }
PGRGateTest >> testConfigurationErrorExitsTwo [
	"Ch.-9-named, P-EXIT-CODES: a malformed artifact file is caught by the top-level handler
	- answers 2, does not raise, and writes exactly one line (one lf) naming the defect (its
	PGRConfigurationError messageText substring)."
	| path stream code |
	path := self scratchFileNamed: 'malformed.ston' contents: 'not ston {'.
	stream := WriteStream on: String new.
	code := PGRGate runHeadless: path on: stream.
	self assert: code equals: 2.
	self assert: (stream contents occurrencesOf: Character lf) equals: 1.
	self assert: (stream contents includesSubstring: 'Malformed STON')
]

{ #category : 'tests' }
PGRGateTest >> testNoDefaultPathIsConsulted [
	"Ch.-9-named, P-NO-DEFAULT-PATH: a valid guardrails.ston present in the process working
	directory (the decoy discipline - created only if absent, deleted only if this test
	created it) is never consulted; an explicit path to a different, red artifact answers
	that artifact's verdict (1); an explicit path to a nonexistent file answers 2 with one
	error line - no fallback."
	| decoyPath decoyCreated redPath redStream missingStream |
	decoyPath := FileSystem workingDirectory / 'guardrails.ston'.
	decoyCreated := false.
	decoyPath exists ifFalse: [
		decoyPath writeStreamDo: [ :stream | stream nextPutAll: (self artifactWithKitsFragment: '[ { #kit : ''PGRScratchSpecKit'', #specs : [
			{ #name : ''scratch/D1'', #kind : ''scratch'', #check : ''PGRScratchGreenCheck'' } ] } ]') ].
		decoyCreated := true ].
	[
		redPath := self scratchArtifactFileFor: '[ { #kit : ''PGRScratchSpecKit'', #specs : [
			{ #name : ''scratch/R1'', #kind : ''scratch'', #check : ''PGRScratchRedCheck'' } ] } ]' named: 'no-default.ston'.
		redStream := WriteStream on: String new.
		self assert: (PGRGate runHeadless: redPath on: redStream) equals: 1.
		missingStream := WriteStream on: String new.
		self assert: (PGRGate runHeadless: (scratchDirectory / 'absent.ston') fullName on: missingStream) equals: 2.
		self assert: (missingStream contents occurrencesOf: Character lf) equals: 1
	] ensure: [ decoyCreated ifTrue: [ decoyPath ensureDelete ] ]
]

{ #category : 'tests' }
PGRGateTest >> testHeadlessAndInImageAgree [
	"Ch.-9-named, P-SAME-VERDICT: the same artifact text, both written to a scratch file and
	held as a string, answers the same exit code through runHeadless:on: and through the
	in-image forConfiguration:/run/exitCode path - one engine, two modes - for both a clean
	(0) and a red (1) artifact."
	| cleanText redText cleanPath redPath cleanStream redStream cleanInImage redInImage |
	cleanText := self artifactWithKitsFragment: '[ { #kit : ''PGRScratchSpecKit'', #specs : [
		{ #name : ''scratch/G1'', #kind : ''scratch'', #check : ''PGRScratchGreenCheck'' } ] } ]'.
	redText := self artifactWithKitsFragment: '[ { #kit : ''PGRScratchSpecKit'', #specs : [
		{ #name : ''scratch/R1'', #kind : ''scratch'', #check : ''PGRScratchRedCheck'' } ] } ]'.
	cleanPath := self scratchFileNamed: 'agree-clean.ston' contents: cleanText.
	redPath := self scratchFileNamed: 'agree-red.ston' contents: redText.
	cleanStream := WriteStream on: String new.
	redStream := WriteStream on: String new.
	cleanInImage := (PGRGate forConfiguration: (PGRConfiguration fromString: cleanText)) run exitCode.
	redInImage := (PGRGate forConfiguration: (PGRConfiguration fromString: redText)) run exitCode.
	self assert: (PGRGate runHeadless: cleanPath on: cleanStream) equals: cleanInImage.
	self assert: (PGRGate runHeadless: redPath on: redStream) equals: redInImage.
	self assert: cleanInImage equals: 0.
	self assert: redInImage equals: 1
]

{ #category : 'tests' }
PGRGateTest >> testEscapedExceptionExitsTwo [
	"Ch.-9-named, P-NEVER-UNDECIDED (kit arm, D-39.2): a kit whose registrationsFrom:...
	raises a plain Error while the registry is under construction escapes to
	runHeadless:on:'s top-level Error, Halt handler - answers 2, does not raise, and the
	stream holds exactly one line naming the exception, including the kit's own message."
	| path stream code |
	path := self scratchArtifactFileFor: '[ { #kit : ''PGRScratchThrowingKit'' } ]'
		named: 'throwing-kit.ston'.
	stream := WriteStream on: String new.
	code := PGRGate runHeadless: path on: stream.
	self assert: code equals: 2.
	self assert: (stream contents occurrencesOf: Character lf) equals: 1.
	self assert: (stream contents includesSubstring: 'scratch kit exploded')
]

{ #category : 'tests' }
PGRGateTest >> testThrowingStreamStillAnswersTwo [
	"Ch.-9-named, P-NEVER-UNDECIDED (stream arm - ch. 9's 'and, separately, a sink that
	throws'): a clean artifact run onto a stream whose every write raises still answers 2
	and does not raise - even the error line's own write failure is swallowed by
	runHeadless:on:'s guard; deciding the number wins over reporting it."
	| path code |
	path := self scratchArtifactFileFor: '[ { #kit : ''PGRScratchSpecKit'', #specs : [
		{ #name : ''scratch/G1'', #kind : ''scratch'', #check : ''PGRScratchGreenCheck'' } ] } ]'
		named: 'clean-for-throwing-stream.ston'.
	code := PGRGate runHeadless: path on: PGRScratchThrowingWriteStream new.
	self assert: code equals: 2
]

{ #category : 'tests' }
PGRGateTest >> testKitRaisedConfigurationErrorExitsTwo [
	"Ch.-9-named, the E04 ADVISORY headless arm: a kit whose registrationsFrom:... raises
	PGRConfigurationError while the registry is under construction is caught by
	runHeadless:on:'s PGRConfigurationError arm - answers 2, wrote exactly one line
	carrying the kit's own messageText - before any check runs."
	| path stream code |
	path := self scratchArtifactFileFor: '[ { #kit : ''PGRScratchConfigErrorKit'' } ]'
		named: 'config-error-kit.ston'.
	stream := WriteStream on: String new.
	code := PGRGate runHeadless: path on: stream.
	self assert: code equals: 2.
	self assert: (stream contents occurrencesOf: Character lf) equals: 1.
	self assert: (stream contents includesSubstring: 'scratch kit block defect')
]

{ #category : 'tests' }
PGRGateTest >> testKitConfigurationErrorPropagatesFromConstruction [
	"Ch.-9-named, the E04 ADVISORY direct arm: the same defective kit, driven through
	PGRGate forConfiguration: with no handler present, raises PGRConfigurationError
	carrying the kit's own message - the frozen E04 claim ('propagates out of
	fromConfiguration: unhandled') witnessed through the gate's eager registry build."
	| text |
	text := self artifactWithKitsFragment: '[ { #kit : ''PGRScratchConfigErrorKit'' } ]'.
	self
		should: [ PGRGate forConfiguration: (PGRConfiguration fromString: text) ]
		raise: PGRConfigurationError
		withExceptionDo: [ :error | self assert: (error messageText includesSubstring: 'scratch kit block defect') ]
]
