"
Pins the C09 PGRVerdict value contract: five constructors total over P6's four statuses, isGreen true only for #green, advisories never block, missing carries its reason, handed collections are copied at construction, and the three engine-stamping setters read back through the frozen readers (nil before stamping).
"
Class {
	#name : 'PGRVerdictTest',
	#superclass : 'TestCase',
	#category : 'Phi-Guardrails-Tests-SDK',
	#package : 'Phi-Guardrails-Tests-SDK'
}

{ #category : 'tests' }
PGRVerdictTest >> testEngineStampingReadBack [
	| verdict |
	verdict := PGRVerdict green.
	self assert: verdict registrationName isNil.
	self assert: verdict kind isNil.
	self assert: verdict durationMillis isNil.
	verdict
		registrationName: 'lint/X';
		kind: #lint;
		durationMillis: 12.
	self assert: verdict registrationName equals: 'lint/X'.
	self assert: verdict kind equals: #lint.
	self assert: verdict durationMillis equals: 12
]

{ #category : 'tests' }
PGRVerdictTest >> testGreenVerdict [
	| verdict |
	verdict := PGRVerdict green.
	self assert: verdict status equals: #green.
	self assert: verdict isGreen.
	self assert: verdict findings isEmpty.
	self assert: verdict advisories isEmpty
]

{ #category : 'tests' }
PGRVerdictTest >> testGreenWithAdvisoriesStaysGreen [
	| finding verdict |
	finding := PGRFinding target: 'Foo>>#bar' message: 'method is long'.
	verdict := PGRVerdict greenAdvisories: (OrderedCollection with: finding).
	self assert: verdict status equals: #green.
	self assert: verdict isGreen.
	self assert: verdict advisories equals: { finding }.
	self assert: verdict findings isEmpty
]

{ #category : 'tests' }
PGRVerdictTest >> testHandedCollectionsAreCopied [
	| findings verdict |
	findings := OrderedCollection with: (PGRFinding target: 'Foo>>#bar' message: 'first').
	verdict := PGRVerdict redFindings: findings.
	findings add: (PGRFinding target: 'Foo>>#baz' message: 'second').
	self assert: verdict findings size equals: 1.
	self assert: verdict findings first message equals: 'first'
]

{ #category : 'tests' }
PGRVerdictTest >> testMissingVerdictCarriesReason [
	| verdict |
	verdict := PGRVerdict missingReason: 'class not loaded'.
	self assert: verdict status equals: #missing.
	self deny: verdict isGreen.
	self assert: verdict missingReason equals: 'class not loaded'.
	self assert: verdict findings isEmpty.
	self assert: verdict advisories isEmpty
]

{ #category : 'tests' }
PGRVerdictTest >> testRedFindingsVerdict [
	| finding verdict |
	finding := PGRFinding target: 'Foo>>#bar' message: 'mutates a global'.
	verdict := PGRVerdict redFindings: (OrderedCollection with: finding).
	self assert: verdict status equals: #red.
	self deny: verdict isGreen.
	self assert: verdict findings equals: { finding }.
	self assert: verdict advisories isEmpty
]

{ #category : 'tests' }
PGRVerdictTest >> testSkippedVerdictIsNotGreen [
	| verdict |
	verdict := PGRVerdict skipped.
	self assert: verdict status equals: #skipped.
	self deny: verdict isGreen
]
