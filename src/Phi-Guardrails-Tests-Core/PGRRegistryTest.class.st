"
E04-C03/C04: PGRRegistry construction, the verbatim handoff, and spec-level validation. C03 arm: specs wrapped into registrations in answer order, kit answers concatenated in #kits array order, the resolved role lists (and nothing else) crossing the kit boundary (testRoleListsHandedResolved is the D-53.5 handoff witness), an empty kit answer yielding an empty registry (D-51), and registrations answering a fresh defensive copy per send (R-35). C04 arm (P-CONFORMANCE, both ch.-9-named tests): protocol conformance naming class and missing selector (D-53), kind agreement naming registration, both kinds, and check class (D-60 G-6), the canFix-true-demands-fixCommandOn: clause (P-CANFIX-DEFAULT), duplicate names across kits as a configuration error never a dedupe (P-CFG-STRICT's duplicate-name arm), the duck-typed positive arm, and the missing-spec skip. Carries its own artifact helpers - the canonical scratch envelope with a splice point for the #kits array; nothing on PGRConfigurationTest is touched. C05 arm (both ch.-9-named property tests): P-LOADING-INERT - a transient PGRCheck subclass installed mid-test (ensure:-removed) enters no registry, the name list staying exactly the block's #specs names in order (R-41, D-51); P-REG-FRESH - two runs over two artifacts (grouped and plain baselines) share nothing, mutating the Array a configuration reader answers affects no run, rebuilding answers fresh uncached objects, and the reflective sweep finds no class-side state in -Core/-Gate, nonzero class count asserted for -Core; the gate/report clause is E05's (recorded split). plainBaselineArtifactString is the plain-baseline variant's helper.
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
PGRRegistryTest >> plainBaselineArtifactString [
	"The second, distinct artifact for P-REG-FRESH: E03's plain baseline - no groups, so roles are assigned by exact package-name matchers - and one spec, scratch/P1. The plain baseline declares no ghost package, so no exempt role is needed."
	^ '{
	#schemaVersion : 2,
	#project : ''ScratchPlain'',
	#baseline : ''BaselineOfPGRScratchPlain'',
	#roles : {
		#production : [ ''Phi-Guardrails-SDK'', ''Phi-Guardrails-Core'' ],
		#tests : [ ''Phi-Guardrails-Tests-SDK'' ] },
	#kits : [ { #kit : ''PGRScratchSpecKit'', #specs : [
		{ #name : ''scratch/P1'', #kind : ''scratch'', #missing : ''plain-baseline run'' } ] } ]
}'
]

{ #category : 'fixtures' }
PGRRegistryTest >> registryFromKitsFragment: aStonKitsArrayString [
	^ PGRRegistry fromConfiguration:
		(PGRConfiguration fromString: (self artifactWithKitsFragment: aStonKitsArrayString))
]

{ #category : 'tests' }
PGRRegistryTest >> testCanFixTrueWithoutFixCommandSignals [
	"P-CANFIX-DEFAULT's clause via the conformance machinery: canFix true demands fixCommandOn:."
	self
		should: [ self registryFromKitsFragment: '[ { #kit : ''PGRScratchSpecKit'', #specs : [
			{ #name : ''scratch/F1'', #kind : ''scratch'', #check : ''PGRScratchClaimsFixCheck'' } ] } ]' ]
		raise: PGRConfigurationError
		withExceptionDo: [ :error |
			self assert: (error messageText includesSubstring: 'PGRScratchClaimsFixCheck').
			self assert: (error messageText includesSubstring: 'fixCommandOn:') ]
]

{ #category : 'tests' }
PGRRegistryTest >> testDuckTypedConformingCheckRegisters [
	"P-CONFORMANCE's positive arm: a plain-Object-lineage duck type answering the whole engine-consumed protocol registers normally (D-53)."
	| registry registration |
	registry := self registryFromKitsFragment: '[ { #kit : ''PGRScratchSpecKit'', #specs : [
		{ #name : ''scratch/G1'', #kind : ''scratch'', #check : ''PGRScratchGreenCheck'' } ] } ]'.
	self assert: registry size equals: 1.
	registration := registry registrations first.
	self assert: registration isResolved.
	self assert: registration run isGreen
]

{ #category : 'tests' }
PGRRegistryTest >> testDuplicateRegistrationNameSignals [
	"P-CFG-STRICT's duplicate-name arm, the E03-recorded handoff: the same name across two kit blocks is a configuration error naming the duplicated name - never a silent dedupe (ch. 1 par. 1.3)."
	self
		should: [ self registryFromKitsFragment: '[
			{ #kit : ''PGRScratchSpecKit'', #specs : [
				{ #name : ''scratch/G1'', #kind : ''scratch'', #check : ''PGRScratchGreenCheck'' } ] },
			{ #kit : ''PGRScratchSpecKit'', #specs : [
				{ #name : ''scratch/G1'', #kind : ''scratch'', #check : ''PGRScratchGreenCheck'' } ] } ]' ]
		raise: PGRConfigurationError
		withExceptionDo: [ :error |
			self assert: (error messageText includesSubstring: 'scratch/G1') ]
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
PGRRegistryTest >> testInstalledCheckClassRegistersNothing [
	"Ch.-9-named, P-LOADING-INERT (R-41): loading is not activation. A fresh PGRCheck subclass named in no kit block is installed mid-test and the registry rebuilt from the same configuration - both name sequences equal exactly the block's #specs names, in order: nothing enters by presence, nothing by shipped default (D-51). Removal is ensure:-guarded; the pre-install guard covers a leftover from a crashed prior run."
	| configuration namesBefore namesAfter |
	configuration := PGRConfiguration fromString: (self artifactWithKitsFragment: '[ { #kit : ''PGRScratchSpecKit'', #specs : [
		{ #name : ''scratch/G1'', #kind : ''scratch'', #check : ''PGRScratchGreenCheck'' },
		{ #name : ''scratch/M1'', #kind : ''scratch'', #missing : ''engine absent'' } ] } ]').
	namesBefore := (PGRRegistry fromConfiguration: configuration) registrations collect: [ :each | each name ].
	(Smalltalk classNamed: 'PGRTransientLoadedCheck') ifNotNil: [ :leftover | leftover removeFromSystem ].
	[
	(PGRCheck << #PGRTransientLoadedCheck
		package: 'Phi-Guardrails-Tests-Core';
		install).
	namesAfter := (PGRRegistry fromConfiguration: configuration) registrations collect: [ :each | each name ] ]
		ensure: [ (Smalltalk classNamed: 'PGRTransientLoadedCheck') ifNotNil: [ :installed | installed removeFromSystem ] ].
	self assert: namesBefore equals: #( 'scratch/G1' 'scratch/M1' ).
	self assert: namesAfter equals: #( 'scratch/G1' 'scratch/M1' )
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
PGRRegistryTest >> testMissingSpecSkipsConformance [
	"A missing spec is skipped by both validation passes - no check exists to ask - and keeps its explicit kind (D-60)."
	| registry registration |
	registry := self registryFromKitsFragment: '[ { #kit : ''PGRScratchSpecKit'', #specs : [
		{ #name : ''scratch/M1'', #kind : ''scratch'', #missing : ''engine absent'' } ] } ]'.
	self assert: registry size equals: 1.
	registration := registry registrations first.
	self deny: registration isResolved.
	self assert: registration kind equals: #scratch
]

{ #category : 'tests' }
PGRRegistryTest >> testNonconformingCheckClassSignals [
	"Ch.-9-named, P-CONFORMANCE: a resolved spec whose check misses an engine-consumed selector is a configuration error naming the class and the missing selector (D-53)."
	self
		should: [ self registryFromKitsFragment: '[ { #kit : ''PGRScratchSpecKit'', #specs : [
			{ #name : ''scratch/N1'', #kind : ''scratch'', #check : ''PGRScratchNonconformingCheck'' } ] } ]' ]
		raise: PGRConfigurationError
		withExceptionDo: [ :error |
			self assert: (error messageText includesSubstring: 'PGRScratchNonconformingCheck').
			self assert: (error messageText includesSubstring: 'run') ]
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

{ #category : 'tests' }
PGRRegistryTest >> testSpecKindMismatchSignals [
	"Ch.-9-named, P-CONFORMANCE / D-60 G-6: a spec kind disagreeing with the check's own kind names the registration, both kinds, and the check class. The name kindclash/X1 keeps lowercase 'scratch' unique to the check's-own-kind clause."
	self
		should: [ self registryFromKitsFragment: '[ { #kit : ''PGRScratchSpecKit'', #specs : [
			{ #name : ''kindclash/X1'', #kind : ''architecture'', #check : ''PGRScratchGreenCheck'' } ] } ]' ]
		raise: PGRConfigurationError
		withExceptionDo: [ :error |
			self assert: (error messageText includesSubstring: 'kindclash/X1').
			self assert: (error messageText includesSubstring: 'architecture').
			self assert: (error messageText includesSubstring: 'scratch').
			self assert: (error messageText includesSubstring: 'PGRScratchGreenCheck') ]
]

{ #category : 'tests' }
PGRRegistryTest >> testTwoRunsShareNothing [
	"Ch.-9-named, P-REG-FRESH (R-35): runs share nothing. Two registries over two artifacts each carry exactly their own names; mutating the Array a configuration reader answers - the only reachable handle - affects no run, the reader's fresh-copy contract asserted directly against the expansion testRoleListsHandedResolved pins; rebuilding from the same configuration answers a fresh registry with fresh registration objects, nothing cached; and the reflective sweep finds no class variables and no class-side instance variables in -Core/-Gate (nonzero class count asserted for -Core; an unknown package name signals, never passes vacuously). The gate/report clause of ch. 9's phrasing lands with E05's gate tests (recorded split)."
	| groupedConfiguration plainConfiguration groupedRegistry plainRegistry rebuilt |
	groupedConfiguration := PGRConfiguration fromString: (self artifactWithKitsFragment: '[ { #kit : ''PGRScratchSpecKit'', #specs : [
		{ #name : ''scratch/G1'', #kind : ''scratch'', #check : ''PGRScratchGreenCheck'' },
		{ #name : ''scratch/M1'', #kind : ''scratch'', #missing : ''engine absent'' } ] } ]').
	plainConfiguration := PGRConfiguration fromString: self plainBaselineArtifactString.
	groupedRegistry := PGRRegistry fromConfiguration: groupedConfiguration.
	plainRegistry := PGRRegistry fromConfiguration: plainConfiguration.
	self assert: (groupedRegistry registrations collect: [ :each | each name ]) equals: #( 'scratch/G1' 'scratch/M1' ).
	self assert: (plainRegistry registrations collect: [ :each | each name ]) equals: #( 'scratch/P1' ).
	groupedConfiguration productionPackageNames at: 1 put: 'Mutated-Handle'.
	self assert: groupedConfiguration productionPackageNames equals: #( 'Phi-Guardrails-SDK' 'Phi-Guardrails-Core' ).
	rebuilt := PGRRegistry fromConfiguration: groupedConfiguration.
	self assert: (rebuilt registrations collect: [ :each | each name ]) equals: #( 'scratch/G1' 'scratch/M1' ).
	self assert: (plainRegistry registrations collect: [ :each | each name ]) equals: #( 'scratch/P1' ).
	self assert: rebuilt ~~ groupedRegistry.
	rebuilt registrations with: groupedRegistry registrations do: [ :one :other | self assert: one ~~ other ].
	#( 'Phi-Guardrails-Core' 'Phi-Guardrails-Gate' ) do: [ :packageName |
		| swept |
		swept := (PackageOrganizer default packageNamed: packageName) definedClasses.
		packageName = 'Phi-Guardrails-Core' ifTrue: [ self deny: swept isEmpty ].
		swept do: [ :each |
			self assertEmpty: each classVarNames.
			self assertEmpty: each class instVarNames ] ]
]
