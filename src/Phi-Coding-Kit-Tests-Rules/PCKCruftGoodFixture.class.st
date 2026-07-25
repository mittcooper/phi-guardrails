"
Declared GOOD cruft fixture (R-37): the clean twin of PCKCruftBadFixture; ReCodeCruftLeftInMethodsRule must stay silent here. Never executed - it exists only to be read by the rule.
"
Class {
	#name : 'PCKCruftGoodFixture',
	#superclass : 'Object',
	#category : 'Phi-Coding-Kit-Tests-Rules',
	#package : 'Phi-Coding-Kit-Tests-Rules'
}

{ #category : 'fixture' }
PCKCruftGoodFixture >> cleanMethod [
	^ 42
]
