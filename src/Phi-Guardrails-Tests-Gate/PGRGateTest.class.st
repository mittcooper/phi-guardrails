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
