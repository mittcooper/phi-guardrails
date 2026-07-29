"
Declared BAD lint fixture (R-37/D-26 sanctioned exception to the idiom ban): carries the exact plant ToyNoIsNilIfFalseRule must fire on. Its method is never executed - it exists only to be read by the rule. Plain Object subclass in the toy's tests-role package, which production-role lint never sweeps (D-33), so it adds no critique to any gate run.
"
Class {
	#name : 'ToyRuleBadFixture',
	#superclass : 'Object',
	#category : 'Toy-Tests',
	#package : 'Toy-Tests'
}

{ #category : 'fixture' }
ToyRuleBadFixture >> withIsNilIfFalse [
	| x |
	x := nil.
	x isNil ifFalse: [ ^ #reached ].
	^ #clean
]
