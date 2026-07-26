"
E05-C06 escape fixture (the E04 ADVISORY, exercised disobediently): a duck-typed, stateless,
class-side-only kit whose registrationsFrom:productionPackages:testsPackages: raises
PGRConfigurationError - the kit-author grant (D-60) used to signal a block defect. Witnesses
the frozen E04 claim that a kit-raised PGRConfigurationError propagates out of
PGRRegistry fromConfiguration: unhandled, both directly and mapped to exit 2 by
runHeadless:on:. Never registered anywhere but the artifacts that name it (P-LOADING-INERT).
"
Class {
	#name : 'PGRScratchConfigErrorKit',
	#superclass : 'Object',
	#category : 'Phi-Guardrails-Tests-Gate',
	#package : 'Phi-Guardrails-Tests-Gate'
}

{ #category : 'accessing' }
PGRScratchConfigErrorKit class >> recommendedBlock [
	^ '{ #kit : ''PGRScratchConfigErrorKit'' }'
]

{ #category : 'registering' }
PGRScratchConfigErrorKit class >> registrationsFrom: aBlock productionPackages: productionNames testsPackages: testsNames [
	^ PGRConfigurationError new signal: 'scratch kit block defect'
]
