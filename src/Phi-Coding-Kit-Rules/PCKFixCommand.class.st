"
The coding kit's implementation of the SDK fix-invocation protocol (D-53: construct -> previewOn: -> apply -> changes), realized over methods and the refactoring engine - the only framework code path that mutates client source; the gate never invokes it (P-FIX-GATE-WALL). Preview is mandatory before apply (D-06): a never-previewed instance refuses apply with PGRFixNotPreviewed. This chunk (E08-C02) lands construction and the error paths; previewOn: is E08-C03's, apply's staleness/execution body E08-C04's.
"
Class {
	#name : 'PCKFixCommand',
	#superclass : 'Object',
	#instVars : [
		'rule',
		'packages',
		'pendingChanges'
	],
	#category : 'Phi-Coding-Kit-Rules',
	#package : 'Phi-Coding-Kit-Rules'
}

{ #category : 'instance creation' }
PCKFixCommand class >> rule: aRuleClass packages: aCollectionOfPackageNames [
	"Named constructor (ch. 3 par. 3.3): only a rule carrying a safe rewrite may drive
	the fix command; a flag-only rule is refused at construction - not a configuration
	error, the artifact is not at fault. isRewriteRule is instance-side in Pharo 13
	(ReAbstractRule false / ReNodeRewriteRule true; no class-side form - P5 probe,
	E08-C02), hence the probe instance. The handed names are copied to a fresh Array
	(the E02 no-shared-mutable-state precedent)."
	aRuleClass new isRewriteRule
		ifFalse: [ PGRNotAutofixable signal: 'check has no autofix' ].
	^ self new
		setRule: aRuleClass;
		setPackages: (Array withAll: aCollectionOfPackageNames);
		yourself
]

{ #category : 'actions' }
PCKFixCommand >> apply [
	"E08-C02 slice: with previewOn: not yet landed (E08-C03) every instance is
	pre-preview, so this is exactly the guard - D-06's mandatory preview made
	machine-checkable. The previewed-state test and the staleness/execution body
	arrive with E08-C03/C04."
	^ PGRFixNotPreviewed signal: 'previewOn: is the mandatory first step'
]

{ #category : 'accessing' }
PCKFixCommand >> changes [
	"The pending/applied change objects, inspectable (par. 3.3) - empty before any
	preview; E08-C03 fills it at preview time."
	^ pendingChanges
]

{ #category : 'initialization' }
PCKFixCommand >> initialize [
	super initialize.
	pendingChanges := Array new
]

{ #category : 'private' }
PCKFixCommand >> setPackages: anArrayOfPackageNames [
	packages := anArrayOfPackageNames
]

{ #category : 'private' }
PCKFixCommand >> setRule: aRuleClass [
	rule := aRuleClass
]
