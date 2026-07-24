"
One entry of a kit's answer to registrationsFrom:productionPackages:testsPackages: - a registration name (<kind>/<discriminator>, e.g. 'lint/PCKNoIsNilIfTrueRule'), a kind Symbol, and either a live check instance bound to its targets or a missing-reason string; never both. A dumb value: no validation - conformance, kind agreement, and duplicate names are the engine's concern (E04), which wraps every resolved spec into its internal PGRRegistration; kits never see that class. A missing spec keeps its explicit kind: no check exists to ask (D-60). The boundary carries information; the engine owns mechanism (D-54).
"
Class {
	#name : 'PGRRegistrationSpec',
	#superclass : 'Object',
	#instVars : [
		'name',
		'kind',
		'check',
		'missingReason'
	],
	#category : 'Phi-Guardrails-SDK',
	#package : 'Phi-Guardrails-SDK'
}

{ #category : 'instance creation' }
PGRRegistrationSpec class >> missing: aNameString kind: aKindSymbol reason: aReasonString [
	^ self new
		setName: aNameString kind: aKindSymbol check: nil missingReason: aReasonString;
		yourself
]

{ #category : 'instance creation' }
PGRRegistrationSpec class >> name: aNameString kind: aKindSymbol check: aCheck [
	^ self new
		setName: aNameString kind: aKindSymbol check: aCheck missingReason: nil;
		yourself
]

{ #category : 'accessing' }
PGRRegistrationSpec >> check [
	^ check
]

{ #category : 'accessing' }
PGRRegistrationSpec >> kind [
	^ kind
]

{ #category : 'accessing' }
PGRRegistrationSpec >> missingReason [
	^ missingReason
]

{ #category : 'accessing' }
PGRRegistrationSpec >> name [
	^ name
]

{ #category : 'private' }
PGRRegistrationSpec >> setName: aNameString kind: aKindSymbol check: aCheckOrNil missingReason: aReasonStringOrNil [
	name := aNameString.
	kind := aKindSymbol.
	check := aCheckOrNil.
	missingReason := aReasonStringOrNil
]
