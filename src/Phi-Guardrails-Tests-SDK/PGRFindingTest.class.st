"
Pins the C08 PGRFinding value contract: the two class-side constructors hand every reading caller back exactly what the check author put in, the two-part constructor leaves rationale nil, and printString names the target, message, and rationale for human eyes. No exact print format is asserted - rendering is not an API (D-48).
"
Class {
	#name : 'PGRFindingTest',
	#superclass : 'TestCase',
	#category : 'Phi-Guardrails-Tests-SDK',
	#package : 'Phi-Guardrails-Tests-SDK'
}

{ #category : 'tests' }
PGRFindingTest >> testPrintStringNamesTargetAndMessage [
	| printed |
	printed := (PGRFinding
		target: 'Foo>>#bar'
		message: 'does the wrong thing'
		rationale: 'methods must do the right thing') printString.
	self assert: (printed includesSubstring: 'Foo>>#bar').
	self assert: (printed includesSubstring: 'does the wrong thing').
	self assert: (printed includesSubstring: 'methods must do the right thing')
]

{ #category : 'tests' }
PGRFindingTest >> testTargetMessageConstructor [
	| finding |
	finding := PGRFinding target: 'Foo>>#bar' message: 'does the wrong thing'.
	self assert: finding target equals: 'Foo>>#bar'.
	self assert: finding message equals: 'does the wrong thing'.
	self assert: finding rationale isNil
]

{ #category : 'tests' }
PGRFindingTest >> testTargetMessageRationaleConstructor [
	| finding |
	finding := PGRFinding
		target: 'Foo>>#bar'
		message: 'does the wrong thing'
		rationale: 'methods must do the right thing'.
	self assert: finding target equals: 'Foo>>#bar'.
	self assert: finding message equals: 'does the wrong thing'.
	self assert: finding rationale equals: 'methods must do the right thing'
]
