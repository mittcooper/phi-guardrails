"
E05-C06 escape fixture (D-39 ruling 3): a write-stream stand-in whose every write raises a
plain Error, proving runHeadless:on:'s guarded error-line write (P-NEVER-UNDECIDED, stream
arm) survives even a sink that cannot be written to at all. A subclass of Object, not of
WriteStream or Stream: the enumerated sends the C02 rendering and the C05 handler actually
make on a stream - nextPutAll:, lf, flush (record-in-report duty; verify-in-image confirmed
these three are the only ones sent by PGRGate class>>runHeadless:on: and
PGRReport class>>printHeaderProject:count:on: on the escape paths this chunk exercises) -
each raise explicitly here; nextPut: and << are implemented too, on the same rationale, for
any caller that reaches them. Any other write this stand-in has not implemented instead
raises doesNotUnderstand: - itself an Error the handler must survive - so either way the
run's exit code still gets decided, which is the point.
"
Class {
	#name : 'PGRScratchThrowingWriteStream',
	#superclass : 'Object',
	#category : 'Phi-Guardrails-Tests-Gate',
	#package : 'Phi-Guardrails-Tests-Gate'
}

{ #category : 'writing' }
PGRScratchThrowingWriteStream >> nextPutAll: aCollection [
	^ Error new signal: 'scratch stream exploded'
]

{ #category : 'writing' }
PGRScratchThrowingWriteStream >> nextPut: anObject [
	^ Error new signal: 'scratch stream exploded'
]

{ #category : 'writing' }
PGRScratchThrowingWriteStream >> lf [
	^ Error new signal: 'scratch stream exploded'
]

{ #category : 'writing' }
PGRScratchThrowingWriteStream >> flush [
	^ Error new signal: 'scratch stream exploded'
]

{ #category : 'writing' }
PGRScratchThrowingWriteStream >> << anObject [
	^ Error new signal: 'scratch stream exploded'
]
