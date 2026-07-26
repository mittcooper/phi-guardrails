"
The gate run's aggregate (ch. 7 §7.1-§7.2): the run's verdicts, in run order, plus the
§7.2 rendering the headless entry streams from. isClean is true iff every verdict isGreen;
exitCode is 0 iff clean, else 1 (code 2 belongs to runHeadless:'s configuration-error path,
never this object's). blockingVerdicts is every non-green verdict - #red, #missing, #skipped
alike, since silence never passes the gate (P6); advisories is the concatenation of every
verdict's own advisories, reported but never blocking (D-03). Handed collections are copied
to Array at construction, and every collection reader answers a fresh Array copy per send
(R-35): the caller can hold onto neither this object's storage nor its own. The gate
constructs (project:verdicts:); nobody else does. Rendering (printOn: and its class-side
helpers) is human-facing and explicitly not an API (§7.2) - the format may change without
notice; it is split into printHeaderProject:count:on:, printVerdict:on:, and instance
printSummaryOn: so E05-C05's streaming entry can reuse the same lines incrementally, one
owner for the format.
"
Class {
	#name : 'PGRReport',
	#superclass : 'Object',
	#instVars : [
		'project',
		'verdicts'
	],
	#category : 'Phi-Guardrails-Gate',
	#package : 'Phi-Guardrails-Gate'
}

{ #category : 'instance creation' }
PGRReport class >> project: aProjectString verdicts: aVerdictArray [
	^ self new
		setProject: aProjectString verdicts: (Array withAll: aVerdictArray);
		yourself
]

{ #category : 'printing' }
PGRReport class >> printHeaderProject: aProjectString count: anInteger on: aStream [
	aStream
		nextPutAll: 'PGR gate · ';
		nextPutAll: aProjectString;
		nextPutAll: ' · ';
		print: anInteger;
		nextPutAll: ' registrations'
]

{ #category : 'printing' }
PGRReport class >> printVerdict: aPGRVerdict on: aStream [
	| tag |
	tag := aPGRVerdict status == #green ifTrue: [ '[ GREEN ]' ] ifFalse: [
		aPGRVerdict status == #red ifTrue: [ '[ RED   ]' ] ifFalse: [
			aPGRVerdict status == #missing ifTrue: [ '[MISSING]' ] ifFalse: [ '[SKIPPED]' ] ] ].
	aStream nextPutAll: tag; nextPutAll: ' '; nextPutAll: aPGRVerdict registrationName.
	(aPGRVerdict status == #green or: [ aPGRVerdict status == #red ])
		ifTrue: [
			aPGRVerdict durationMillis ifNotNil: [ :ms |
				aStream nextPutAll: ' ('; print: ms; nextPutAll: 'ms)' ] ].
	aPGRVerdict missingReason ifNotNil: [ :reason |
		aStream nextPutAll: ' — '; nextPutAll: reason ].
	(aPGRVerdict findings, aPGRVerdict advisories) do: [ :finding |
		aStream lf; nextPutAll: '          '; nextPutAll: finding target; nextPutAll: ' '; nextPutAll: finding message.
		finding rationale ifNotNil: [ :text |
			aStream lf; nextPutAll: '          rationale: '; nextPutAll: text ] ]
]

{ #category : 'accessing' }
PGRReport >> advisories [
	"The concatenation of every verdict's own advisories, in verdict order; a fresh Array
	copy per send (R-35) - advisories are reported, never block (D-03)."
	| result |
	result := OrderedCollection new.
	verdicts do: [ :v | result addAll: v advisories ].
	^ result asArray
]

{ #category : 'accessing' }
PGRReport >> blockingVerdicts [
	"Every non-green verdict, in verdict order; a fresh Array copy per send. All non-green
	statuses block - #red, #missing, #skipped alike - since silence never passes (P6)."
	^ (verdicts reject: [ :v | v isGreen ]) asArray
]

{ #category : 'testing' }
PGRReport >> isClean [
	^ verdicts allSatisfy: [ :v | v isGreen ]
]

{ #category : 'accessing' }
PGRReport >> exitCode [
	^ self isClean ifTrue: [ 0 ] ifFalse: [ 1 ]
]

{ #category : 'printing' }
PGRReport >> printOn: aStream [
	self class printHeaderProject: project count: verdicts size on: aStream.
	verdicts do: [ :v | aStream lf. self class printVerdict: v on: aStream ].
	aStream lf.
	self printSummaryOn: aStream
]

{ #category : 'printing' }
PGRReport >> printSummaryOn: aStream [
	aStream
		nextPutAll: 'GATE: ';
		nextPutAll: (self isClean ifTrue: [ 'GREEN' ] ifFalse: [ 'RED' ]);
		nextPutAll: ' — ';
		print: self blockingVerdicts size;
		nextPutAll: ' blocking of ';
		print: verdicts size;
		nextPutAll: ' · exit ';
		print: self exitCode
]

{ #category : 'private' }
PGRReport >> setProject: aProjectString verdicts: aVerdictArray [
	project := aProjectString.
	verdicts := aVerdictArray
]

{ #category : 'accessing' }
PGRReport >> verdicts [
	"The run's verdicts, ordered; a fresh Array copy per send - the collection is
	defensive, the members are the run's own (R-35)."
	^ verdicts copy
]
