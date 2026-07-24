"
The optional check skeleton. The check protocol is exactly that - a protocol: the message set below plus its behavioral expectations. Conformance, not ancestry, is what registration requires (D-53): a duck-typed plain class implementing packages:, run, kind, canFix (and fixCommandOn: when canFix is true) registers fine. Subclassing here is a convenience - documentation, subclassResponsibility markers, and the implemented defaults (packages:/packages storage, canFix false). An abstract class, not a trait (trait attribution is backlog B-03). The kit that names a check instantiates it via packages:, handing its target package names at construction; a check never pulls context from anywhere - everything it knows, it was given (D-60).
"
Class {
	#name : 'PGRCheck',
	#superclass : 'Object',
	#instVars : [
		'packages'
	],
	#category : 'Phi-Guardrails-SDK',
	#package : 'Phi-Guardrails-SDK'
}

{ #category : 'instance creation' }
PGRCheck class >> packages: aCollectionOfPackageNames [
	"The role the handed names carry is the one the kit's block key implies
	(#architectureChecks -> production-role, #metaRules -> tests-role)."
	^ self new
		setPackages: (Array withAll: aCollectionOfPackageNames);
		yourself
]

{ #category : 'testing' }
PGRCheck >> canFix [
	"Fixing is opt-in: a conforming check answers false unless it overrides this."
	^ false
]

{ #category : 'fixing' }
PGRCheck >> fixCommandOn: aCollectionOfPackageNames [
	"Required only when canFix is overridden true; answers an object conforming to
	the fix-invocation protocol (construct -> previewOn: -> apply -> changes).
	A canFix-false check is never sent this - the marker documents, it never obliges."
	^ self subclassResponsibility
]

{ #category : 'accessing' }
PGRCheck >> kind [
	"Answer a Symbol; must equal the kind the registration's block key implies -
	kind agreement (D-60) is validated by the engine, not here."
	^ self subclassResponsibility
]

{ #category : 'accessing' }
PGRCheck >> packages [
	"A check's run reads its targets here; run stays argument-less (D-60)."
	^ packages
]

{ #category : 'running' }
PGRCheck >> run [
	"Answer a PGRVerdict over the packages handed at construction."
	^ self subclassResponsibility
]

{ #category : 'private' }
PGRCheck >> setPackages: anArrayOfPackageNames [
	packages := anArrayOfPackageNames
]
