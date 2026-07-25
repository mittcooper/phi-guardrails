"
Declared BAD lint fixture (R-37/D-26 sanctioned exception to the idiom ban): carries the exact plant PCKNoIsNilIfTrueRule must fire on. Its methods are never executed - they exist only to be read by the rule. Plain Object subclass in a tests-role package, invisible to production-role lint and inert to a behavioral run (D-25, ch. 9 par. 9.3).
"
Class {
	#name : 'PCKLintBadFixture',
	#superclass : 'Object',
	#category : 'Phi-Coding-Kit-Tests-Rules',
	#package : 'Phi-Coding-Kit-Tests-Rules'
}

{ #category : 'fixture' }
PCKLintBadFixture >> withIsNilIfTrue [
	| x |
	x := nil.
	x isNil ifTrue: [ ^ #bad ].
	^ #good
]
