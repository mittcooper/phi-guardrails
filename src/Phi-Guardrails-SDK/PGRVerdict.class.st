"
One registration's outcome, total over P6's four states: status is one of #green / #red / #missing / #skipped, and everything non-green fails the gate. The check author constructs (green / greenAdvisories: / redFindings: / missingReason:); the caller only reads. Advisories are reported, never block: isGreen stays true. skipped is engine-only (D-21/D-32): check authors must never emit it; no v1 code path produces it in a completed run; it exists so the vocabulary stays total over P6's states - its only legitimate producer is report construction over a partially-run registry, which is why it is absent from the Check-author SDK and both spec diagrams. Handed collections are copied to Array at construction so a caller mutating its own collection afterwards cannot reach into the verdict. A dumb value: no validation - strictness is the engine's. The registration stamps registrationName/kind/durationMillis after run via the internal engine-stamping setters (internal, changeable without notice); the readers are frozen caller surface and answer nil unstamped. missingReason is an internal reader for report rendering (E05), not part of the freeze.
"
Class {
	#name : 'PGRVerdict',
	#superclass : 'Object',
	#instVars : [
		'status',
		'findings',
		'advisories',
		'missingReason',
		'registrationName',
		'kind',
		'durationMillis'
	],
	#category : 'Phi-Guardrails-SDK',
	#package : 'Phi-Guardrails-SDK'
}

{ #category : 'instance creation' }
PGRVerdict class >> green [
	^ self new
		setStatus: #green findings: #() advisories: #();
		yourself
]

{ #category : 'instance creation' }
PGRVerdict class >> greenAdvisories: aCollection [
	^ self new
		setStatus: #green findings: #() advisories: (Array withAll: aCollection);
		yourself
]

{ #category : 'instance creation' }
PGRVerdict class >> missingReason: aString [
	^ self new
		setStatus: #missing findings: #() advisories: #();
		setMissingReason: aString;
		yourself
]

{ #category : 'instance creation' }
PGRVerdict class >> redFindings: aCollection [
	^ self new
		setStatus: #red findings: (Array withAll: aCollection) advisories: #();
		yourself
]

{ #category : 'instance creation' }
PGRVerdict class >> skipped [
	"Engine-only (D-21/D-32): check authors must never emit this - see the class comment."
	^ self new
		setStatus: #skipped findings: #() advisories: #();
		yourself
]

{ #category : 'accessing' }
PGRVerdict >> advisories [
	^ advisories
]

{ #category : 'accessing' }
PGRVerdict >> durationMillis [
	^ durationMillis
]

{ #category : 'internal - engine stamping' }
PGRVerdict >> durationMillis: anInteger [
	durationMillis := anInteger
]

{ #category : 'accessing' }
PGRVerdict >> findings [
	^ findings
]

{ #category : 'testing' }
PGRVerdict >> isGreen [
	^ status == #green
]

{ #category : 'accessing' }
PGRVerdict >> kind [
	^ kind
]

{ #category : 'internal - engine stamping' }
PGRVerdict >> kind: aSymbol [
	kind := aSymbol
]

{ #category : 'internal - reading' }
PGRVerdict >> missingReason [
	^ missingReason
]

{ #category : 'accessing' }
PGRVerdict >> registrationName [
	^ registrationName
]

{ #category : 'internal - engine stamping' }
PGRVerdict >> registrationName: aString [
	registrationName := aString
]

{ #category : 'private' }
PGRVerdict >> setMissingReason: aString [
	missingReason := aString
]

{ #category : 'private' }
PGRVerdict >> setStatus: aSymbol findings: aFindingsArray advisories: anAdvisoriesArray [
	status := aSymbol.
	findings := aFindingsArray.
	advisories := anAdvisoriesArray
]

{ #category : 'accessing' }
PGRVerdict >> status [
	^ status
]
