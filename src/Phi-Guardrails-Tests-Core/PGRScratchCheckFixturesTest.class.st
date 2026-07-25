"
E04-C01 fixture-pinning suite: asserts the scratch check family and the data-driven PGRScratchSpecKit behave exactly as the E04 registry chunks (C02-C05) assume - green/red/erroring/nonconforming/claims-fix checks and the spec-answering kit, all duck-typed plain Object subclasses (D-53).
"
Class {
	#name : 'PGRScratchCheckFixturesTest',
	#superclass : 'TestCase',
	#category : 'Phi-Guardrails-Tests-Core',
	#package : 'Phi-Guardrails-Tests-Core'
}

{ #category : 'tests' }
PGRScratchCheckFixturesTest >> testClaimsFixCheckLacksFixCommand [
	| check |
	check := PGRScratchClaimsFixCheck packages: #( 'P1' ).
	self assert: check canFix.
	self deny: (check respondsTo: #fixCommandOn:)
]

{ #category : 'tests' }
PGRScratchCheckFixturesTest >> testErroringCheckRaises [
	self
		should: [ (PGRScratchErroringCheck packages: #( 'P1' )) run ]
		raise: Error
		withExceptionDo: [ :ex |
			self assert: (ex description includesSubstring: 'scratch check exploded') ]
]

{ #category : 'tests' }
PGRScratchCheckFixturesTest >> testGreenCheckRunsGreen [
	| check |
	check := PGRScratchGreenCheck packages: #( 'P1' ).
	self assert: check run isGreen.
	self assert: check kind equals: #scratch.
	self assert: check packages equals: #( 'P1' )
]

{ #category : 'tests' }
PGRScratchCheckFixturesTest >> testNonconformingCheckLacksRunOnly [
	| check |
	check := PGRScratchNonconformingCheck packages: #( 'P1' ).
	self deny: (check respondsTo: #run).
	self assert: (check respondsTo: #kind).
	self assert: (check respondsTo: #canFix)
]

{ #category : 'tests' }
PGRScratchCheckFixturesTest >> testRedCheckFiresNamingPlant [
	| verdict |
	verdict := (PGRScratchRedCheck packages: #( 'P1' )) run.
	self assert: verdict status equals: #red.
	self assert: verdict findings size equals: 1.
	self assert: verdict findings first target equals: 'PGRScratchRedCheck'.
	self assert: verdict findings first message equals: 'planted scratch violation'
]

{ #category : 'tests' }
PGRScratchCheckFixturesTest >> testSpecKitAnswersSpecsFromBlock [
	| block specs first second |
	block := Dictionary new.
	block
		at: #specs
		put: {
			(Dictionary new
				at: #name put: 'scratch/G1';
				at: #kind put: #scratch;
				at: #check put: 'PGRScratchGreenCheck';
				yourself).
			(Dictionary new
				at: #name put: 'scratch/M1';
				at: #kind put: #scratch;
				at: #missing put: 'engine absent';
				yourself) }.
	specs := PGRScratchSpecKit
		registrationsFrom: block
		productionPackages: #( 'PA' 'PB' )
		testsPackages: #( 'TA' ).
	self assert: specs size equals: 2.
	first := specs first.
	self assert: first name equals: 'scratch/G1'.
	self assert: first kind equals: #scratch.
	self assert: first check class equals: PGRScratchGreenCheck.
	self assert: first check packages equals: #( 'PA' 'PB' ).
	self assert: first missingReason isNil.
	second := specs second.
	self assert: second name equals: 'scratch/M1'.
	self assert: second kind equals: #scratch.
	self assert: second check isNil.
	self assert: second missingReason equals: 'engine absent'
]

{ #category : 'tests' }
PGRScratchCheckFixturesTest >> testSpecKitEchoesRoleLists [
	| block specs |
	block := Dictionary new.
	block
		at: #specs
		put: { (Dictionary new
			at: #name put: 'scratch/E1';
			at: #kind put: #scratch;
			at: #echoRoles put: true;
			yourself) }.
	specs := PGRScratchSpecKit
		registrationsFrom: block
		productionPackages: #( 'PA' 'PB' )
		testsPackages: #( 'TA' ).
	self assert: specs size equals: 1.
	self assert: specs first missingReason equals: 'production: PA, PB | tests: TA'
]
