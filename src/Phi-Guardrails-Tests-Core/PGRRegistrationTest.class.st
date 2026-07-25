"
E04-C02: PGRRegistration wrapping and run semantics - resolved/missing wrapping, verdict stamping, red pass-through, the P-GATE-MISSING core-half machinery witness (a missing registration's run answers a missing verdict), and the ch.-9 P-ERR-IS-RED registration arm (an erroring check yields red; no exception escapes).
"
Class {
	#name : 'PGRRegistrationTest',
	#superclass : 'TestCase',
	#category : 'Phi-Guardrails-Tests-Core',
	#package : 'Phi-Guardrails-Tests-Core'
}

{ #category : 'tests' }
PGRRegistrationTest >> testErroringCheckYieldsRed [
	| verdict |
	verdict := (PGRRegistration fromSpec: (PGRRegistrationSpec
		name: 'scratch/E1'
		kind: #scratch
		check: (PGRScratchErroringCheck packages: #( 'P1' )))) run.
	self assert: verdict status equals: #red.
	self assert: verdict findings size equals: 1.
	self assert: (verdict findings first message includesSubstring: 'scratch check exploded').
	self assert: verdict registrationName equals: 'scratch/E1'.
	self assert: verdict kind equals: #scratch.
	self assert: verdict durationMillis isInteger.
	self assert: verdict durationMillis >= 0
]

{ #category : 'tests' }
PGRRegistrationTest >> testMissingRunAnswersMissingVerdict [
	| verdict |
	verdict := (PGRRegistration fromSpec: (PGRRegistrationSpec
		missing: 'scratch/M1'
		kind: #scratch
		reason: 'engine absent')) run.
	self assert: verdict status equals: #missing.
	self assert: verdict missingReason equals: 'engine absent'.
	self assert: verdict registrationName equals: 'scratch/M1'.
	self assert: verdict kind equals: #scratch.
	self assert: verdict durationMillis isInteger.
	self assert: verdict durationMillis >= 0
]

{ #category : 'tests' }
PGRRegistrationTest >> testMissingSpecWrapsUnresolved [
	| registration |
	registration := PGRRegistration fromSpec: (PGRRegistrationSpec
		missing: 'scratch/M1'
		kind: #scratch
		reason: 'engine absent').
	self deny: registration isResolved.
	self assert: registration name equals: 'scratch/M1'.
	self assert: registration kind equals: #scratch
]

{ #category : 'tests' }
PGRRegistrationTest >> testRedVerdictPassesThrough [
	| verdict |
	verdict := (PGRRegistration fromSpec: (PGRRegistrationSpec
		name: 'scratch/R1'
		kind: #scratch
		check: (PGRScratchRedCheck packages: #( 'P1' )))) run.
	self assert: verdict status equals: #red.
	self assert: verdict findings size equals: 1.
	self assert: verdict findings first message equals: 'planted scratch violation'.
	self assert: verdict registrationName equals: 'scratch/R1'.
	self assert: verdict kind equals: #scratch
]

{ #category : 'tests' }
PGRRegistrationTest >> testResolvedSpecWrapsResolved [
	| registration |
	registration := PGRRegistration fromSpec: (PGRRegistrationSpec
		name: 'scratch/G1'
		kind: #scratch
		check: (PGRScratchGreenCheck packages: #( 'P1' ))).
	self assert: registration name equals: 'scratch/G1'.
	self assert: registration kind equals: #scratch.
	self assert: registration isResolved
]

{ #category : 'tests' }
PGRRegistrationTest >> testRunStampsVerdict [
	| verdict |
	verdict := (PGRRegistration fromSpec: (PGRRegistrationSpec
		name: 'scratch/G1'
		kind: #scratch
		check: (PGRScratchGreenCheck packages: #( 'P1' )))) run.
	self assert: verdict isGreen.
	self assert: verdict registrationName equals: 'scratch/G1'.
	self assert: verdict kind equals: #scratch.
	self assert: verdict durationMillis isInteger.
	self assert: verdict durationMillis >= 0
]
