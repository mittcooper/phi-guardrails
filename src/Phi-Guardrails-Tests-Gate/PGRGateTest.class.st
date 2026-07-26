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
