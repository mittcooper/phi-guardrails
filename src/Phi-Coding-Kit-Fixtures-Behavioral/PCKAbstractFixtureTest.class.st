"
Planted behavioral fixture (R-37/D-26): abstract on purpose, carrying a test that would fail if run - proves the par. 5.2 test-class filter excludes abstract classes. If a later chunk's filter breaks, this red test pollutes the package counts and the pin tests go red.
"
Class {
	#name : 'PCKAbstractFixtureTest',
	#superclass : 'TestCase',
	#category : 'Phi-Coding-Kit-Fixtures-Behavioral',
	#package : 'Phi-Coding-Kit-Fixtures-Behavioral'
}

{ #category : 'testing' }
PCKAbstractFixtureTest class >> isAbstract [
	"Planted: the par. 5.2 filter must leave this class out of every suite."
	^ true
]

{ #category : 'tests' }
PCKAbstractFixtureTest >> testWouldFailIfRun [
	self assert: false
]
