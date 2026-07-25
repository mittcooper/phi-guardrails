"
E04-C03: PGRRegistry construction and the verbatim handoff - specs wrapped into registrations in answer order, kit answers concatenated in #kits array order, the resolved role lists (and nothing else) crossing the kit boundary (testRoleListsHandedResolved is the D-53.5 handoff witness), an empty kit answer yielding an empty registry (what runs is exactly what the file names, D-51), and registrations answering a fresh defensive copy per send (R-35). Carries its own artifact helpers - the canonical scratch envelope with a splice point for the #kits array; nothing on PGRConfigurationTest is touched.
"
Class {
	#name : 'PGRRegistryTest',
	#superclass : 'TestCase',
	#category : 'Phi-Guardrails-Tests-Core',
	#package : 'Phi-Guardrails-Tests-Core'
}

{ #category : 'fixtures' }
PGRRegistryTest >> artifactWithKitsFragment: aStonKitsArrayString [
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
PGRRegistryTest >> registryFromKitsFragment: aStonKitsArrayString [
	^ PGRRegistry fromConfiguration:
		(PGRConfiguration fromString: (self artifactWithKitsFragment: aStonKitsArrayString))
]

{ #category : 'tests' }
PGRRegistryTest >> testEmptyKitAnswerYieldsEmptyRegistry [
	"E03's canonical envelope verbatim: its only kit, PGRScratchKit, answers no registrations - lawful, and what runs is exactly what the file names (D-51)."
	| registry |
	registry := self registryFromKitsFragment: '[ { #kit : ''PGRScratchKit'' } ]'.
	self assert: registry size equals: 0.
	self assertEmpty: registry registrations
]

{ #category : 'tests' }
PGRRegistryTest >> testKitsConcatenateInArrayOrder [
	"Array order across kits, answer order within one (spec ch. 1 par. 1.4 step 3) - the empty-answering PGRScratchKit sits between the two spec-kit blocks and contributes nothing."
	| registry |
	registry := self registryFromKitsFragment: '[
		{ #kit : ''PGRScratchSpecKit'', #specs : [
			{ #name : ''scratch/A1'', #kind : ''scratch'', #missing : ''first block'' },
			{ #name : ''scratch/A2'', #kind : ''scratch'', #missing : ''first block'' } ] },
		{ #kit : ''PGRScratchKit'' },
		{ #kit : ''PGRScratchSpecKit'', #specs : [
			{ #name : ''scratch/B1'', #kind : ''scratch'', #missing : ''third block'' } ] } ]'.
	self assert: (registry registrations collect: [ :each | each name ])
		equals: #( 'scratch/A1' 'scratch/A2' 'scratch/B1' )
]

{ #category : 'tests' }
PGRRegistryTest >> testRegistrationsAnswersFreshCopy [
	"R-35: the collection is defensive, the members are the run's."
	| registry first second |
	registry := self registryFromKitsFragment: '[ { #kit : ''PGRScratchSpecKit'', #specs : [
		{ #name : ''scratch/G1'', #kind : ''scratch'', #check : ''PGRScratchGreenCheck'' },
		{ #name : ''scratch/M1'', #kind : ''scratch'', #missing : ''engine absent'' } ] } ]'.
	first := registry registrations.
	second := registry registrations.
	self assert: (first collect: [ :each | each name ]) equals: (second collect: [ :each | each name ]).
	self assert: first ~~ second.
	first with: second do: [ :one :other | self assert: one identicalTo: other ]
]

{ #category : 'tests' }
PGRRegistryTest >> testRegistrationsWrapSpecsInOrder [
	"Specs wrap into registrations in the kit's answer order (spec ch. 1 par. 1.4 step 2); resolvedness and the run stamp survive the wrap."
	| registry registrations verdict |
	registry := self registryFromKitsFragment: '[ { #kit : ''PGRScratchSpecKit'', #specs : [
		{ #name : ''scratch/G1'', #kind : ''scratch'', #check : ''PGRScratchGreenCheck'' },
		{ #name : ''scratch/M1'', #kind : ''scratch'', #missing : ''engine absent'' } ] } ]'.
	self assert: registry size equals: 2.
	registrations := registry registrations.
	self assert: (registrations collect: [ :each | each name ]) equals: #( 'scratch/G1' 'scratch/M1' ).
	self assert: registrations first isResolved.
	verdict := registrations first run.
	self assert: verdict isGreen.
	self assert: verdict registrationName equals: 'scratch/G1'.
	self deny: (registrations at: 2) isResolved
]

{ #category : 'tests' }
PGRRegistryTest >> testRoleListsHandedResolved [
	"The D-53.5 handoff witness: the resolved role lists crossed the kit boundary, and nothing else did. The expansions are the ones PGRScratchFixturesTest pins for this image."
	| verdict |
	verdict := (self registryFromKitsFragment: '[ { #kit : ''PGRScratchSpecKit'', #specs : [
		{ #name : ''scratch/R1'', #kind : ''scratch'', #echoRoles : true } ] } ]')
		registrations first run.
	self assert: verdict status equals: #missing.
	self assert: verdict missingReason
		equals: 'production: Phi-Guardrails-SDK, Phi-Guardrails-Core | tests: Phi-Guardrails-Tests-SDK'
]
