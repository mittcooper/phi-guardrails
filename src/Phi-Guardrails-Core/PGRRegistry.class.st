"
The registry of one gate run - the run's registrations, nothing else (glossary). Built per run by fromConfiguration:, spec ch. 1 par. 1.4 steps 1-3: each kit class receives its block verbatim plus the resolved production and tests package-name lists - never the configuration object (D-53.5) - and its answered specs are wrapped via PGRRegistration fromSpec: in answer order (the kit's order is normative; the engine never reorders), concatenated across kits in #kits array order. Holds only what construction gave it (R-35); a PGRConfigurationError raised by a kit inside registrationsFrom:... propagates untouched - the kit's stated duty (D-60), mapped to exit 2 by E05. Spec-level validation (conformance, kind agreement, duplicate names) happens before wrapping (C04) - this class trusts the specs it is handed. Internal: no frozen caller surface.
"
Class {
	#name : 'PGRRegistry',
	#superclass : 'Object',
	#instVars : [
		'registrations'
	],
	#category : 'Phi-Guardrails-Core',
	#package : 'Phi-Guardrails-Core'
}

{ #category : 'instance creation' }
PGRRegistry class >> fromConfiguration: aPGRConfiguration [
	"Spec ch. 1 par. 1.4 steps 1-3: for each (kitClass, block) pair in #kits array order - kitClasses is parallel to kitBlocks - hand the kit its block verbatim (opaque, D-51) and the resolved role lists, never the configuration object (over-reach is impossible, not caught, D-53.5); each role reader answers a fresh copy per send, so no kit can reach another's. Answered specs wrap in answer order; a PGRConfigurationError a kit raises propagates untouched (D-60)."
	| wrapped |
	wrapped := OrderedCollection new.
	aPGRConfiguration kitClasses with: aPGRConfiguration kitBlocks do: [ :kitClass :block |
		(kitClass
			registrationsFrom: block
			productionPackages: aPGRConfiguration productionPackageNames
			testsPackages: aPGRConfiguration testsPackageNames)
			do: [ :spec | wrapped add: (PGRRegistration fromSpec: spec) ] ].
	^ self new
		setRegistrations: wrapped asArray;
		yourself
]

{ #category : 'accessing' }
PGRRegistry >> registrations [
	"The run's registrations, ordered; a fresh Array copy per send - the collection is defensive, the members are the run's own (R-35)."
	^ registrations copy
]

{ #category : 'private' }
PGRRegistry >> setRegistrations: anArray [
	registrations := anArray
]

{ #category : 'accessing' }
PGRRegistry >> size [
	^ registrations size
]
