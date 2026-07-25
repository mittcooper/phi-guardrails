"
C20 scratch client fixture (R-05: the scratch client, never a real one) — introspection data for E03's configuration tests, never Metacello-loaded. Three real loaded packages plus the ghost 'PGR-Scratch-Ghost' (declaration is inventory, not loadedness); role-shaped, overlap, empty (D-25.a addendum) and composite groups. Later chunks cite this tree verbatim — it is part of the fixture contract.
"
Class {
	#name : 'BaselineOfPGRScratchGrouped',
	#superclass : 'BaselineOf',
	#category : 'Phi-Guardrails-Tests-Core',
	#package : 'Phi-Guardrails-Tests-Core'
}

{ #category : 'baselines' }
BaselineOfPGRScratchGrouped >> baseline: spec [
	<baseline>
	spec for: #common do: [
		spec
			package: 'Phi-Guardrails-SDK';
			package: 'Phi-Guardrails-Core';
			package: 'Phi-Guardrails-Tests-SDK';
			package: 'PGR-Scratch-Ghost'.
		spec
			group: 'scratch-prod' with: #( 'Phi-Guardrails-SDK' 'Phi-Guardrails-Core' );
			group: 'scratch-tst' with: #( 'Phi-Guardrails-Tests-SDK' );
			group: 'scratch-ghost' with: #( 'PGR-Scratch-Ghost' );
			group: 'scratch-overlap' with: #( 'Phi-Guardrails-SDK' );
			group: 'scratch-empty' with: #(  );
			group: 'scratch-both' with: #( 'scratch-prod' 'scratch-ghost' ) ]
]
