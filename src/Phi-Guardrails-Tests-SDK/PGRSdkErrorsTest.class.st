"
Pins the C07 SDK error-vocabulary contract: each of the four errors is signallable and catchable by its own class, carries the one-line reason in messageText, and the four stay mutually disjoint direct Error subclasses so catch-by-class never swallows a sibling. Real message wording is never asserted — it is not an API.
"
Class {
	#name : 'PGRSdkErrorsTest',
	#superclass : 'TestCase',
	#category : 'Phi-Guardrails-Tests-SDK',
	#package : 'Phi-Guardrails-Tests-SDK'
}

{ #category : 'accessing' }
PGRSdkErrorsTest >> errorClasses [
	^ { PGRConfigurationError. PGRNotAutofixable. PGRFixNotPreviewed. PGRFixStale }
]

{ #category : 'tests' }
PGRSdkErrorsTest >> testEachErrorClassIsSignallableAndCatchableByClass [
	self errorClasses do: [ :each | self should: [ each signal: 'boom' ] raise: each ]
]

{ #category : 'tests' }
PGRSdkErrorsTest >> testErrorClassesAreDisjoint [
	self errorClasses do: [ :each |
		self assert: (each inheritsFrom: Error).
		self errorClasses do: [ :other |
			each == other ifFalse: [ self deny: (each inheritsFrom: other) ] ] ]
]

{ #category : 'tests' }
PGRSdkErrorsTest >> testMessageTextCarriesTheReason [
	| caught |
	caught := nil.
	[ PGRConfigurationError signal: 'the reason' ]
		on: PGRConfigurationError
		do: [ :ex | caught := ex ].
	self assert: caught messageText equals: 'the reason'
]
