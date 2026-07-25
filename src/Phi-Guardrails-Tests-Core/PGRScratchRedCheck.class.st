"
E04-C01 scratch fixture - the conforming check that always fires: one planted finding naming itself. The registry tests' red witness.
"
Class {
	#name : 'PGRScratchRedCheck',
	#superclass : 'PGRScratchGreenCheck',
	#category : 'Phi-Guardrails-Tests-Core',
	#package : 'Phi-Guardrails-Tests-Core'
}

{ #category : 'running' }
PGRScratchRedCheck >> run [
	^ PGRVerdict redFindings: { PGRFinding target: 'PGRScratchRedCheck' message: 'planted scratch violation' }
]
