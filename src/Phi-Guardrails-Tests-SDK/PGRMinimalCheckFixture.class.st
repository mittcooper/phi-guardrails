"
The minimal conforming check P-CANFIX-DEFAULT speaks of: overrides only kind and run - deliberately not canFix. A fixture, not a TestCase; sits beside its tests per ch. 9 par. 9.3.
"
Class {
	#name : 'PGRMinimalCheckFixture',
	#superclass : 'PGRCheck',
	#category : 'Phi-Guardrails-Tests-SDK',
	#package : 'Phi-Guardrails-Tests-SDK'
}

{ #category : 'accessing' }
PGRMinimalCheckFixture >> kind [
	^ #lint
]

{ #category : 'running' }
PGRMinimalCheckFixture >> run [
	^ PGRVerdict green
]
