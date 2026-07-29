"
Framework-side pins for the toy's own configuration artifact (spec ch. 1 par. 1.1, the normative example; ch. 8 par. 8.2, its in-repo embodiment as class-side STON on BaselineOfToy). Lives in the swept tests-role package so both facts are enforced by the verify command and the framework's own gate. testArtifactParsesAndValidates is the par. 1.1 pin: the artifact parses, validates, and - carrying no baseline group - lets the matchers assign the five packages to their roles whole (R-47). testArtifactYieldsTheSixRegistrationsInOrder is D-51's pin: the file is the complete statement of what runs - exactly six resolved registrations, in registry order. Construction only; no run is sent (that is E14's ground).
"
Class {
	#name : 'PGRToyArtifactTest',
	#superclass : 'TestCase',
	#category : 'Phi-Guardrails-Tests-Toy',
	#package : 'Phi-Guardrails-Tests-Toy'
}

{ #category : 'tests' }
PGRToyArtifactTest >> testArtifactParsesAndValidates [
	"Par. 1.1 normative-example pin: the committed toy artifact parses, validates, and assigns roles by matcher - the baseline declares no group, so the four production matchers and the tests matcher land the five Toy-* packages whole (R-47)."
	| configuration |
	configuration := PGRConfiguration fromString: BaselineOfToy guardrailsSTON.
	self assert: configuration project equals: 'Toy'.
	self assert: configuration baselineClass name equals: #BaselineOfToy.
	self
		assert: configuration productionPackageNames asSortedCollection asArray
		equals: #( 'Toy-Core' 'Toy-Persistence' 'Toy-Rules' 'Toy-UI' ).
	self assert: (configuration testsPackageNames includes: 'Toy-Tests').
	self assert: configuration testsPackageNames size equals: 1
]

{ #category : 'tests' }
PGRToyArtifactTest >> testArtifactYieldsTheSixRegistrationsInOrder [
	"D-51's pin: the file is the complete statement of what runs. The registry answers exactly six registrations, their names equal to the digest's list in registry order (lint -> architecture -> behavioral suites -> meta-rules), and every one resolved - the map covers, the rules resolve, the tests role is non-empty. No run is sent."
	| registry |
	registry := PGRRegistry fromConfiguration:
		(PGRConfiguration fromString: BaselineOfToy guardrailsSTON).
	self assert: registry size equals: 6.
	self
		assert: (registry registrations collect: [ :each | each name ])
		equals: #(
			'lint/PCKNoIsNilIfTrueRule'
			'lint/ReCodeCruftLeftInMethodsRule'
			'lint/ToyNoIsNilIfFalseRule'
			'architecture/PCKLayerMapCheck'
			'behavioral/Toy-Tests'
			'behavioral/PCKNoSkippedTestsMetaRule' ).
	registry registrations do: [ :each | self assert: each isResolved ]
]
