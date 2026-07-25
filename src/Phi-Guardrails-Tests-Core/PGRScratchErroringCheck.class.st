"
E04-C01 scratch fixture - the check that explodes mid-run: run signals an Error and never answers a verdict. Converting that into an outcome is the registration's duty (C02), never the check's.
"
Class {
	#name : 'PGRScratchErroringCheck',
	#superclass : 'PGRScratchGreenCheck',
	#category : 'Phi-Guardrails-Tests-Core',
	#package : 'Phi-Guardrails-Tests-Core'
}

{ #category : 'running' }
PGRScratchErroringCheck >> run [
	"Never answers - the raised Error is the fixture's whole behavior."
	Error new signal: 'scratch check exploded'
]
