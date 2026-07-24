"
Pins the C11 PGRCheck skeleton: canFix defaults false without the subclass writing it (P-CANFIX-DEFAULT), packages: stores the handed names for run to read, and the bare skeleton marks run/kind/fixCommandOn: as subclassResponsibility rather than silently answering.
"
Class {
	#name : 'PGRCheckSkeletonTest',
	#superclass : 'TestCase',
	#category : 'Phi-Guardrails-Tests-SDK',
	#package : 'Phi-Guardrails-Tests-SDK'
}

{ #category : 'tests' }
PGRCheckSkeletonTest >> testBareSkeletonMarksItsContract [
	| bare |
	bare := PGRCheck packages: #().
	self should: [ bare run ] raise: SubclassResponsibility.
	self should: [ bare kind ] raise: SubclassResponsibility.
	self should: [ bare fixCommandOn: #() ] raise: SubclassResponsibility
]

{ #category : 'tests' }
PGRCheckSkeletonTest >> testCanFixDefaultsFalse [
	self deny: (PGRMinimalCheckFixture packages: #()) canFix
]

{ #category : 'tests' }
PGRCheckSkeletonTest >> testPackagesConstructorStoresNames [
	| check |
	check := PGRMinimalCheckFixture packages: #('Pkg-A' 'Pkg-B').
	self assert: check packages equals: #('Pkg-A' 'Pkg-B').
	self assert: check run isGreen
]
