"
E04-C01 scratch fixture - the C04 conformance-error witness: instantiable via packages: and answering kind, canFix, and packages, but missing exactly one protocol selector, #run. Deliberately its own plain Object subclass (not a PGRScratchGreenCheck) so nothing inherited can mask the gap - do not add run.
"
Class {
	#name : 'PGRScratchNonconformingCheck',
	#superclass : 'Object',
	#instVars : [
		'packages'
	],
	#category : 'Phi-Guardrails-Tests-Core',
	#package : 'Phi-Guardrails-Tests-Core'
}

{ #category : 'instance creation' }
PGRScratchNonconformingCheck class >> packages: aCollectionOfPackageNames [
	^ self new
		setPackages: (Array withAll: aCollectionOfPackageNames);
		yourself
]

{ #category : 'testing' }
PGRScratchNonconformingCheck >> canFix [
	^ false
]

{ #category : 'accessing' }
PGRScratchNonconformingCheck >> kind [
	^ #scratch
]

{ #category : 'accessing' }
PGRScratchNonconformingCheck >> packages [
	^ packages
]

{ #category : 'private' }
PGRScratchNonconformingCheck >> setPackages: anArrayOfPackageNames [
	packages := anArrayOfPackageNames
]
