"
E04-C01 scratch fixture - the full conforming check, deliberately a plain Object subclass: duck-typed conformance, not ancestry, is what registration requires (D-53). Always answers a green verdict over the packages handed at construction (D-60); kind is the non-catalog #scratch so registry tests witness that the engine reads only kinds and verdicts (R-42). Root of the scratch check family - the red/erroring/claims-fix variants subclass it.
"
Class {
	#name : 'PGRScratchGreenCheck',
	#superclass : 'Object',
	#instVars : [
		'packages'
	],
	#category : 'Phi-Guardrails-Tests-Core',
	#package : 'Phi-Guardrails-Tests-Core'
}

{ #category : 'instance creation' }
PGRScratchGreenCheck class >> packages: aCollectionOfPackageNames [
	^ self new
		setPackages: (Array withAll: aCollectionOfPackageNames);
		yourself
]

{ #category : 'testing' }
PGRScratchGreenCheck >> canFix [
	^ false
]

{ #category : 'accessing' }
PGRScratchGreenCheck >> kind [
	^ #scratch
]

{ #category : 'accessing' }
PGRScratchGreenCheck >> packages [
	^ packages
]

{ #category : 'running' }
PGRScratchGreenCheck >> run [
	^ PGRVerdict green
]

{ #category : 'private' }
PGRScratchGreenCheck >> setPackages: anArrayOfPackageNames [
	packages := anArrayOfPackageNames
]
