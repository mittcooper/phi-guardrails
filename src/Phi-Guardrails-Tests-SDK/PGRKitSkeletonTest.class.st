"
Pins the C11 two-message kit contract (D-54/D-60) by set equality over PGRKit class selectors: a third class-side message drifting in fails as an extra element; a contract message vanishing locally fails as a missing one. A contract change must come through a ruling, never drift.
"
Class {
	#name : 'PGRKitSkeletonTest',
	#superclass : 'TestCase',
	#category : 'Phi-Guardrails-Tests-SDK',
	#package : 'Phi-Guardrails-Tests-SDK'
}

{ #category : 'tests' }
PGRKitSkeletonTest >> testKitContractIsTwoClassSideMessages [
	self
		assert: PGRKit class selectors asSet
		equals: #(#registrationsFrom:productionPackages:testsPackages: #recommendedBlock) asSet.
	self
		should: [ PGRKit registrationsFrom: Dictionary new productionPackages: #() testsPackages: #() ]
		raise: SubclassResponsibility.
	self should: [ PGRKit recommendedBlock ] raise: SubclassResponsibility
]
