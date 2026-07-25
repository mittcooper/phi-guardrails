"
Planted behavioral fixture (R-37/D-26): deliberately skipped and expectedly failing - exactly one skip: call and one expectedFailures entry, the no-skips meta-rule's bad fixture (spec par. 5.5). Committed skip/expectedFailures are sanctioned only in this unswept -Fixtures- package (D-22).
"
Class {
	#name : 'PCKSkippingFixtureTest',
	#superclass : 'TestCase',
	#category : 'Phi-Coding-Kit-Fixtures-Behavioral',
	#package : 'Phi-Coding-Kit-Fixtures-Behavioral'
}

{ #category : 'accessing' }
PCKSkippingFixtureTest >> expectedFailures [
	^ #( testExpectedlyFailing )
]

{ #category : 'tests' }
PCKSkippingFixtureTest >> testExpectedlyFailing [
	self assert: false
]

{ #category : 'tests' }
PCKSkippingFixtureTest >> testSkippedOnPurpose [
	self skip: 'planted skip'
]
