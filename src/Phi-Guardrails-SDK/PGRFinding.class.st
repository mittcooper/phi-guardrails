"
One blocking violation or one non-blocking advisory inside a verdict. Which of the two it is belongs to the verdict that carries it (findings vs advisories), never to this object. The check author constructs; the caller only reads. target is the precisely printed offender (e.g. 'Class>>#selector' - that precision is the producing check's duty, not validated here); message says what is wrong; rationale is the rule's rationale where one exists, nil when constructed via target:message:. A dumb value: no validation - strictness is the engine's concern, never the vocabulary's. printOn: renders for human eyes and is explicitly not an API (D-48).
"
Class {
	#name : 'PGRFinding',
	#superclass : 'Object',
	#instVars : [
		'target',
		'message',
		'rationale'
	],
	#category : 'Phi-Guardrails-SDK',
	#package : 'Phi-Guardrails-SDK'
}

{ #category : 'instance creation' }
PGRFinding class >> target: aTargetString message: aMessageString [
	^ self target: aTargetString message: aMessageString rationale: nil
]

{ #category : 'instance creation' }
PGRFinding class >> target: aTargetString message: aMessageString rationale: aRationaleStringOrNil [
	^ self new
		setTarget: aTargetString message: aMessageString rationale: aRationaleStringOrNil;
		yourself
]

{ #category : 'accessing' }
PGRFinding >> message [
	^ message
]

{ #category : 'printing' }
PGRFinding >> printOn: aStream [
	super printOn: aStream.
	aStream nextPutAll: ' ('; nextPutAll: target; nextPutAll: ': '; nextPutAll: message.
	rationale ifNotNil: [ aStream nextPutAll: ' -- '; nextPutAll: rationale ].
	aStream nextPut: $)
]

{ #category : 'accessing' }
PGRFinding >> rationale [
	^ rationale
]

{ #category : 'private' }
PGRFinding >> setTarget: aTargetString message: aMessageString rationale: aRationaleStringOrNil [
	target := aTargetString.
	message := aMessageString.
	rationale := aRationaleStringOrNil
]

{ #category : 'accessing' }
PGRFinding >> target [
	^ target
]
