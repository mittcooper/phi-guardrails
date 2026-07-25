"
Declared BAD cruft fixture (R-37/D-26 sanctioned exception to the halt/Transcript/flag ban): one method per send form the ch. 3 par. 3.2b catalog claims ReCodeCruftLeftInMethodsRule catches. Its methods are never executed - the halt never halts anything; they exist only to be read by the rule. Plain Object subclass in a tests-role package (D-25/D-33), invisible to production-role lint and inert to behavioral runs.
"
Class {
	#name : 'PCKCruftBadFixture',
	#superclass : 'Object',
	#category : 'Phi-Coding-Kit-Tests-Rules',
	#package : 'Phi-Coding-Kit-Tests-Rules'
}

{ #category : 'fixture' }
PCKCruftBadFixture >> withFlag [
	self flag: #cruft
]

{ #category : 'fixture' }
PCKCruftBadFixture >> withHalt [
	self halt
]

{ #category : 'fixture' }
PCKCruftBadFixture >> withHaltIf [
	self haltIf: false
]

{ #category : 'fixture' }
PCKCruftBadFixture >> withTranscriptShow [
	Transcript show: 'cruft'
]
