"
Planted behavioral fixture (R-37): the clean class inside the red fixtures package - later chunks assert its passes produce no findings (precision). Green on purpose; everything else here is red on purpose.
"
Class {
	#name : 'PCKPassingFixtureTest',
	#superclass : 'TestCase',
	#category : 'Phi-Coding-Kit-Fixtures-Behavioral',
	#package : 'Phi-Coding-Kit-Fixtures-Behavioral'
}

{ #category : 'tests' }
PCKPassingFixtureTest >> testAlwaysPasses [
	self assert: true
]
