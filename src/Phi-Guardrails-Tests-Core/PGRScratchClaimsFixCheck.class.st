"
E04-C01 scratch fixture - the C04 defect witness: claims canFix true while implementing no fixCommandOn:. The gap between claim and implementation is the fixture's whole point - do not add fixCommandOn:.
"
Class {
	#name : 'PGRScratchClaimsFixCheck',
	#superclass : 'PGRScratchGreenCheck',
	#category : 'Phi-Guardrails-Tests-Core',
	#package : 'Phi-Guardrails-Tests-Core'
}

{ #category : 'testing' }
PGRScratchClaimsFixCheck >> canFix [
	^ true
]
