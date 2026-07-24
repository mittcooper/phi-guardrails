"
The optional kit skeleton. The kit contract is exactly two class-side messages - registrationsFrom:productionPackages:testsPackages: and recommendedBlock (D-54 as amended by D-60; the class name is the kit's identity). Conformance, not ancestry, is what registration requires (D-53): a duck-typed plain class implementing the pair registers fine; subclassing here is documentation plus subclassResponsibility markers. Kits are stateless - all class-side, no class-side variables. An abstract class, not a trait (backlog B-03).
"
Class {
	#name : 'PGRKit',
	#superclass : 'Object',
	#category : 'Phi-Guardrails-SDK',
	#package : 'Phi-Guardrails-SDK'
}

{ #category : 'accessing' }
PGRKit class >> recommendedBlock [
	"The published stanza, single-sourced on the kit class, answered as STON text
	(a String, D-60); the init tool composes it into drafts and docs quote it."
	^ self subclassResponsibility
]

{ #category : 'registering' }
PGRKit class >> registrationsFrom: aBlock productionPackages: productionNames testsPackages: testsNames [
	"aBlock is the kit's verbatim block - a Dictionary from the artifact's #kits
	array; productionNames/testsNames are the resolved role package-name lists,
	never the configuration object (D-53: over-reach is impossible, not caught).
	Answers an ordered collection of PGRRegistrationSpec values, never fewer than
	the block names. The kit validates its own block strictly: an unknown key
	inside it raises PGRConfigurationError, raised by the kit."
	^ self subclassResponsibility
]
