"
The registry of one gate run - the run's registrations, nothing else (glossary). Built per run by fromConfiguration:, spec ch. 1 par. 1.4 steps 1-3: each kit class receives its block verbatim plus the resolved configuration facts - never the configuration object (D-53.5): the core builds one PGRKitEnvironment view per construction and probes each kit once (respondsTo:), handing the view to a kit answering registrationsFrom:environment: and falling back to the frozen three-argument form (resolved production and tests lists) otherwise (D-81 additive; zero accepted consumers change) - and its answered specs are wrapped via PGRRegistration fromSpec: in answer order (the kit's order is normative; the engine never reorders), concatenated across kits in #kits array order. Construction validates every spec before wrapping (C04), on the specs kits answer, never on block contents (ch. 0 par. 0.4, D-60 G-7): protocol conformance by respondsTo: (run, kind, canFix; fixCommandOn: when canFix is true - D-53, P-CANFIX-DEFAULT), kind agreement (D-60 G-6), and duplicate registration names on add (ch. 1 par. 1.3) - all before any check runs; a missing spec skips conformance and kind agreement, no check exists to ask. Holds only what construction gave it (R-35); a PGRConfigurationError raised by a kit inside registrationsFrom:... propagates untouched - the kit's stated duty (D-60), mapped to exit 2 by E05. Internal: no frozen caller surface.
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
	"Spec ch. 1 par. 1.4 steps 1-3: for each (kitClass, block) pair in #kits array order - kitClasses is parallel to kitBlocks - hand the kit its block verbatim (opaque, D-51) and the resolved configuration facts, never the configuration object (over-reach is impossible, not caught, D-53.5). The core builds one PGRKitEnvironment view per construction (R-35 per-run local, never cached) and probes each kit once (respondsTo:, the D-53/D-60 reflective-conformance family): a kit answering registrationsFrom:environment: receives the view; every other kit takes the frozen three-argument form with the resolved role lists (D-81 additive - zero accepted consumers change). One shared view is correct: each collection reader answers a fresh copy per send, so no kit can reach another's through it. Every answered spec is validated as it is processed - protocol conformance then kind agreement (C04) - and the first name seen a second time signals on add (duplicate is a configuration error, never a silent dedupe, ch. 1 par. 1.3); all of it completes before any check runs (ch. 0 par. 0.4). A PGRConfigurationError a kit raises propagates untouched (D-60)."
	| wrapped seenNames environment |
	wrapped := OrderedCollection new.
	seenNames := Set new.
	environment := PGRKitEnvironment
		productionPackages: aPGRConfiguration productionPackageNames
		testsPackages: aPGRConfiguration testsPackageNames
		exemptPackages: aPGRConfiguration exemptPackageNames
		srcPath: aPGRConfiguration srcPath.
	aPGRConfiguration kitClasses with: aPGRConfiguration kitBlocks do: [ :kitClass :block |
		| specs |
		specs := (kitClass respondsTo: #registrationsFrom:environment:)
			ifTrue: [ kitClass registrationsFrom: block environment: environment ]
			ifFalse: [ kitClass
				registrationsFrom: block
				productionPackages: aPGRConfiguration productionPackageNames
				testsPackages: aPGRConfiguration testsPackageNames ].
		specs do: [ :spec |
			self validateSpec: spec.
			(seenNames includes: spec name) ifTrue: [
				PGRConfigurationError new signal: 'Duplicate registration name: ' , spec name ].
			seenNames add: spec name.
			wrapped add: (PGRRegistration fromSpec: spec) ] ].
	^ self new
		setRegistrations: wrapped asArray;
		yourself
]

{ #category : 'private' }
PGRRegistry class >> validateConformanceOf: aCheck [
	"The engine-consumed instance protocol, held by respondsTo: - the specified contract check, never ancestry (D-53): run, kind, canFix always, and fixCommandOn: when canFix answers true (P-CANFIX-DEFAULT). Each failure names the class and the missing selector (D-53)."
	#( run kind canFix ) do: [ :selector |
		(aCheck respondsTo: selector) ifFalse: [
			PGRConfigurationError new signal:
				aCheck class name asString , ' does not answer the check-protocol selector ' , selector printString ] ].
	(aCheck canFix and: [ (aCheck respondsTo: #fixCommandOn:) not ]) ifTrue: [
		PGRConfigurationError new signal:
			aCheck class name asString , ' answers canFix true but does not answer ' , #fixCommandOn: printString ]
]

{ #category : 'private' }
PGRRegistry class >> validateKindAgreementOf: aRegistrationSpec [
	"D-60 G-6: the spec's kind must equal the check's own kind; the error names the registration, both kinds, and the check class. Conformance ran first, so the check answers kind."
	| check |
	check := aRegistrationSpec check.
	aRegistrationSpec kind = check kind ifTrue: [ ^ self ].
	PGRConfigurationError new signal:
		'Registration ' , aRegistrationSpec name , ' declares kind ' , aRegistrationSpec kind asString
			, ' but its check ' , check class name asString , ' answers kind ' , check kind asString
]

{ #category : 'private' }
PGRRegistry class >> validateSpec: aRegistrationSpec [
	"Spec-level validation (ch. 1 par. 1.4 step 2), on the specs kits answer - never on block contents (D-60 G-7): protocol conformance, then kind agreement. A missing spec is skipped by both passes - no check exists to ask, its explicit kind stands (D-60). The class-side packages: constructor is not re-checked: by the time a spec exists the check is constructed."
	aRegistrationSpec check ifNil: [ ^ self ].
	self validateConformanceOf: aRegistrationSpec check.
	self validateKindAgreementOf: aRegistrationSpec
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
