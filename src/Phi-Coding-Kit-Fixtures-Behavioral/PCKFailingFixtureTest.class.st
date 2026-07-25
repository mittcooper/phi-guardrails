"
Planted behavioral fixture (R-37/D-26): its red state is deliberate - one failure and one error, the suite check's bad-fixture raw material (spec par. 5.2's two finding messages). Committed-red code is sanctioned only in this unswept -Fixtures- package (D-22).
"
Class {
	#name : 'PCKFailingFixtureTest',
	#superclass : 'TestCase',
	#category : 'Phi-Coding-Kit-Fixtures-Behavioral',
	#package : 'Phi-Coding-Kit-Fixtures-Behavioral'
}

{ #category : 'tests' }
PCKFailingFixtureTest >> testAlwaysErrors [
	self error: 'planted error'
]

{ #category : 'tests' }
PCKFailingFixtureTest >> testAlwaysFails [
	self assert: false
]
