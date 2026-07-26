"
E05-C06 escape fixture (D-39 ruling 3): a duck-typed, stateless, class-side-only kit whose
registrationsFrom:productionPackages:testsPackages: raises a plain Error - never a
PGRConfigurationError - so PGRRegistry fromConfiguration:'s propagation is genuinely an
escape, not a handled configuration defect. Exists to be caught by runHeadless:on:'s
top-level handler (P-NEVER-UNDECIDED, kit arm); never registered anywhere but the artifacts
that name it (P-LOADING-INERT).
"
Class {
	#name : 'PGRScratchThrowingKit',
	#superclass : 'Object',
	#category : 'Phi-Guardrails-Tests-Gate',
	#package : 'Phi-Guardrails-Tests-Gate'
}

{ #category : 'accessing' }
PGRScratchThrowingKit class >> recommendedBlock [
	^ '{ #kit : ''PGRScratchThrowingKit'' }'
]

{ #category : 'registering' }
PGRScratchThrowingKit class >> registrationsFrom: aBlock productionPackages: productionNames testsPackages: testsNames [
	^ Error new signal: 'scratch kit exploded'
]
