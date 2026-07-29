"
The toy's own suite plants (R-44/R-37/D-26, sanctioned Toy-* exception): exactly two
methods - one plainly failing test and one skip: test - what a real adopter's first gate
run over its own suite red-flags. Committed-red is lawful here because Toy-Tests is
exempt-role in the framework's artifact and full-matches neither verify tests-family
pattern (D-57). The failing test's raw material feeds behavioral/Toy-Tests; the skip
feeds PCKNoSkippedTestsMetaRule. This suite is unswept by design; its plants are
witnessed live at check level by PGRToyPlantWitnessTest.
"
Class {
	#name : 'ToyOrderTest',
	#superclass : 'TestCase',
	#category : 'Toy-Tests',
	#package : 'Toy-Tests'
}

{ #category : 'tests' }
ToyOrderTest >> testSkippedOnPurpose [
	"PLANTED skip (R-44): the no-skips meta-rule's raw material - a committed skip: call
	sanctioned only in the exempt-role toy suite."
	self skip: 'planted skip'
]

{ #category : 'tests' }
ToyOrderTest >> testTotalIsFortyTwo [
	"PLANTED failing test (R-44): an empty order totals 0, never 42 - the suite check's
	raw material, a deliberate failure sanctioned only in the exempt-role toy suite."
	self assert: ToyOrder empty total equals: 42
]
