"
Declared GOOD lint fixture (R-37): the near-miss clean twin of ToyRuleBadFixture, written with the ifNotNil: idiom the rule's rationale prescribes; ToyNoIsNilIfFalseRule must stay silent here. Never executed - it exists only to be read by the rule.
"
Class {
	#name : 'ToyRuleGoodFixture',
	#superclass : 'Object',
	#category : 'Toy-Tests',
	#package : 'Toy-Tests'
}

{ #category : 'fixture' }
ToyRuleGoodFixture >> withIfNotNil [
	| x |
	x := nil.
	x ifNotNil: [ :v | ^ #reached ].
	^ #clean
]
