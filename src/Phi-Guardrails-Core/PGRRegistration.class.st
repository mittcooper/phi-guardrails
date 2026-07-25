"
The engine's fully internal wrapper around one PGRRegistrationSpec (D-54): check authors never see this class, and none of it is frozen surface. The spec is boundary information; this class is run mechanism. run always answers a stamped PGRVerdict - never an exception escape, never nil: delegated to the check when resolved, converted to red when the check's run signals an unhandled Error (D-21: ""engine crashed"" blocks exactly like ""check failed""), missing when unresolved (missing is a verdict, not an exception - spec 1.5). Every answered verdict is stamped with registrationName, kind, and elapsed durationMillis. A registration trusts the spec it is handed: conformance, kind agreement, and duplicate validation happen before wrapping (C04). Per-run, constructed by the registry each fromConfiguration: - nothing cached.
"
Class {
	#name : 'PGRRegistration',
	#superclass : 'Object',
	#instVars : [
		'name',
		'kind',
		'check',
		'missingReason'
	],
	#category : 'Phi-Guardrails-Core',
	#package : 'Phi-Guardrails-Core'
}

{ #category : 'instance creation' }
PGRRegistration class >> fromSpec: aRegistrationSpec [
	"Copy the boundary information out of the spec: the spec stays a dumb value, the engine owns mechanism (D-54)."
	^ self new
		setName: aRegistrationSpec name
		kind: aRegistrationSpec kind
		check: aRegistrationSpec check
		missingReason: aRegistrationSpec missingReason;
		yourself
]

{ #category : 'testing' }
PGRRegistration >> isResolved [
	"Resolvedness is check nil-ness (a missing spec carries no check), never a type test."
	^ check notNil
]

{ #category : 'accessing' }
PGRRegistration >> kind [
	^ kind
]

{ #category : 'accessing' }
PGRRegistration >> name [
	^ name
]

{ #category : 'running' }
PGRRegistration >> run [
	"Answer a stamped verdict, always - the stamps land on the missing arm too, and 0 elapsed ms is legitimate there."
	| verdict millis |
	millis := Time millisecondsToRun: [ verdict := self runToVerdict ].
	verdict
		registrationName: name;
		kind: kind;
		durationMillis: millis.
	^ verdict
]

{ #category : 'private' }
PGRRegistration >> runToVerdict [
	"Missing is a verdict, not an exception (spec 1.5); an unhandled check Error converts to one red finding naming the check class (D-21)."
	check ifNil: [ ^ PGRVerdict missingReason: missingReason ].
	^ [ check run ]
		on: Error
		do: [ :err |
			PGRVerdict redFindings:
				{ PGRFinding target: check class name asString message: err description } ]
]

{ #category : 'private' }
PGRRegistration >> setName: aNameString kind: aKindSymbol check: aCheckOrNil missingReason: aReasonStringOrNil [
	name := aNameString.
	kind := aKindSymbol.
	check := aCheckOrNil.
	missingReason := aReasonStringOrNil
]
