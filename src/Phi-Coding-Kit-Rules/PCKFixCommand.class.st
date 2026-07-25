"
The coding kit's implementation of the SDK fix-invocation protocol (D-53: construct -> previewOn: -> apply -> changes), realized over methods and the refactoring engine - the only framework code path that mutates client source; the gate never invokes it (P-FIX-GATE-WALL). Preview is mandatory before apply (D-06): a never-previewed instance refuses apply with PGRFixNotPreviewed; previewOn: (E08-C03) runs the rule through the D-72 environment, lands the full diff on the handed stream, and marks the instance previewed. apply's staleness/execution body is E08-C04's.
"
Class {
	#name : 'PCKFixCommand',
	#superclass : 'Object',
	#instVars : [
		'rule',
		'packages',
		'pendingChanges',
		'previewed'
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
	preview, the collected change objects after one. A fresh Array each call: apply's
	blast radius (E08-C04) is exactly pendingChanges, which no caller may reshape
	from outside (the C02-review watch point)."
	^ Array withAll: pendingChanges
]

{ #category : 'initialization' }
PCKFixCommand >> initialize [
	super initialize.
	pendingChanges := Array new.
	previewed := false
]

{ #category : 'actions' }
PCKFixCommand >> previewOn: aWriteStream [
	"D-06's mandatory preview: run the rule exactly as the check does (ch. 2 par. 2.3
	steps 1-2 through the D-72 environment - one attribution story across check and
	fix), keep each change-providing critique's change object, and land every
	prospective diff - target, old source, new source - on the handed stream before
	anything can change. Answers the pending count; the handed stream is the only
	sink, and mutation stays apply's monopoly (E08-C04)."
	| ruleInstance checker critiques |
	ruleInstance := rule new.
	checker := ReSmalllintChecker new
		rule: { ruleInstance };
		environment: (PCKLintRuleCheck lintEnvironmentOver: packages);
		run;
		yourself.
	critiques := (checker criticsOf: ruleInstance) asArray
		select: [ :each | each providesChange ].
	pendingChanges := critiques collect: [ :each | each change ].
	critiques with: pendingChanges do: [ :critique :change |
		aWriteStream
			nextPutAll: critique entity printString; cr;
			nextPutAll: '--- old'; cr;
			nextPutAll: change oldVersionTextToDisplay; cr;
			nextPutAll: '+++ new'; cr;
			nextPutAll: change textToDisplay; cr ].
	previewed := true.
	^ pendingChanges size
]

{ #category : 'private' }
PCKFixCommand >> setPackages: anArrayOfPackageNames [
	packages := anArrayOfPackageNames
]

{ #category : 'private' }
PCKFixCommand >> setRule: aRuleClass [
	rule := aRuleClass
]
