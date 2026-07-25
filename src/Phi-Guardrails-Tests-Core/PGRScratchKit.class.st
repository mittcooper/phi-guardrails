"
C20 scratch client fixture — a duck-typed kit: deliberately a plain Object subclass, not a PGRKit subclass, witnessing that conformance, not ancestry, is what registration requires (D-53). Class-side only, stateless.
"
Class {
	#name : 'PGRScratchKit',
	#superclass : 'Object',
	#category : 'Phi-Guardrails-Tests-Core',
	#package : 'Phi-Guardrails-Tests-Core'
}

{ #category : 'accessing' }
PGRScratchKit class >> recommendedBlock [
	^ '{ #kit : ''PGRScratchKit'' }'
]

{ #category : 'registering' }
PGRScratchKit class >> registrationsFrom: aBlock productionPackages: productionNames testsPackages: testsNames [
	"The trivial conforming answer: no registrations, whatever the block says."
	^ OrderedCollection new
]
