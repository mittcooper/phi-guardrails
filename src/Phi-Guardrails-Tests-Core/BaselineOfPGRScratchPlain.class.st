"
C20 scratch client fixture — the same three real packages as BaselineOfPGRScratchGrouped but no groups at all: role groups in a client's baseline are optional, never required (P-ROLES-FROM-CONFIG). Introspection data, never Metacello-loaded.
"
Class {
	#name : 'BaselineOfPGRScratchPlain',
	#superclass : 'BaselineOf',
	#category : 'Phi-Guardrails-Tests-Core',
	#package : 'Phi-Guardrails-Tests-Core'
}

{ #category : 'baselines' }
BaselineOfPGRScratchPlain >> baseline: spec [
	<baseline>
	spec for: #common do: [
		spec
			package: 'Phi-Guardrails-SDK';
			package: 'Phi-Guardrails-Core';
			package: 'Phi-Guardrails-Tests-SDK' ]
]
