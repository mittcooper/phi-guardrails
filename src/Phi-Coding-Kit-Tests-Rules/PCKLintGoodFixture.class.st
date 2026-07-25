"
Declared GOOD lint fixture (R-37): the near-miss clean twin of PCKLintBadFixture, written with the idiom the rule's rationale prescribes; PCKNoIsNilIfTrueRule must stay silent here. Never executed - it exists only to be read by the rule.
"
Class {
	#name : 'PCKLintGoodFixture',
	#superclass : 'Object',
	#category : 'Phi-Coding-Kit-Tests-Rules',
	#package : 'Phi-Coding-Kit-Tests-Rules'
}

{ #category : 'fixture' }
PCKLintGoodFixture >> withIfNil [
	| x |
	x := nil.
	x ifNil: [ ^ #good ].
	^ #also
]
