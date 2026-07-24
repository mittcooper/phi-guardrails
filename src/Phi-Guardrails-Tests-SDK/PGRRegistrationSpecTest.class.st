"
Pins the C10 PGRRegistrationSpec value contract: the two class-side constructors hand back exactly what the kit author put in - a resolved spec carries its check and a nil missingReason, a missing spec carries its reason, its explicit kind (D-60: no check exists to ask), and a nil check. The spec never inspects its check, so a plain scratch object stands in for one.
"
Class {
	#name : 'PGRRegistrationSpecTest',
	#superclass : 'TestCase',
	#category : 'Phi-Guardrails-Tests-SDK',
	#package : 'Phi-Guardrails-Tests-SDK'
}

{ #category : 'tests' }
PGRRegistrationSpecTest >> testMissingSpecCarriesReasonAndExplicitKind [
	| spec |
	spec := PGRRegistrationSpec
		missing: 'behavioral/tests-role'
		kind: #behavioral
		reason: 'tests role expanded to zero packages'.
	self assert: spec name equals: 'behavioral/tests-role'.
	self assert: spec kind equals: #behavioral.
	self assert: spec missingReason equals: 'tests role expanded to zero packages'.
	self assert: spec check isNil
]

{ #category : 'tests' }
PGRRegistrationSpecTest >> testResolvedSpecCarriesItsCheck [
	| scratch spec |
	scratch := Object new.
	spec := PGRRegistrationSpec name: 'lint/Scratch' kind: #lint check: scratch.
	self assert: spec name equals: 'lint/Scratch'.
	self assert: spec kind equals: #lint.
	self assert: spec check identicalTo: scratch.
	self assert: spec missingReason isNil
]
