"
The coding kit's implementation of the SDK fix-invocation protocol (D-53: construct -> previewOn: -> apply -> changes), realized over methods and the refactoring engine - the only framework code path that mutates client source; the gate never invokes it (P-FIX-GATE-WALL). Preview is mandatory before apply (D-06): a never-previewed instance refuses apply with PGRFixNotPreviewed; previewOn: (E08-C03) runs the rule through the D-72 environment, lands the full diff on the handed stream, and marks the instance previewed. apply (E08-C04) re-reads every pending change's target and signals PGRFixStale on any drift from the source the preview showed, applying nothing (D-34.2 all-or-nothing); otherwise it executes each change - an ordinary recompile, Epicea-recorded and listed in RBRefactoryChangeManager's undo history, with no code here managing either - and answers the applied change objects. One instance, one invocation: a successful apply consumes its preview, so a second apply refuses with PGRFixNotPreviewed; a stale command is discarded - a new fix run is a new instance with a new preview.
"
Class {
	#name : 'PCKFixCommand',
	#superclass : 'Object',
	#instVars : [
		'rule',
		'packages',
		'pendingChanges',
		'previewedSources',
		'previewed',
		'applied'
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
	"D-06's second half: the diff the invoker confirmed is the diff that applies.
	Guard: no preview on this instance, or a preview already consumed by a prior
	apply, refuses with PGRFixNotPreviewed (one preview authorizes one apply).
	Staleness (D-34.2): every pending change's target is re-read and compared to
	the source the preview snapshotted; any drift signals PGRFixStale and applies
	nothing - all-or-nothing. The re-read must not use oldVersionTextToDisplay,
	which re-renders from the live method and so never drifts (P5 probe, E08-C04);
	an untouched target's current sourceCode is textually identical to the
	snapshot, so plain string inequality is drift."
	| stale |
	(previewed and: [ applied not ])
		ifFalse: [ ^ PGRFixNotPreviewed signal: 'one preview authorizes one apply' ].
	stale := false.
	pendingChanges with: previewedSources do: [ :change :source |
		(change changeClass >> change selector) sourceCode = source
			ifFalse: [ stale := true ] ].
	stale ifTrue: [ ^ PGRFixStale signal: 'target source changed since the preview' ].
	pendingChanges do: [ :change | change execute ].
	applied := true.
	^ self changes
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
	previewedSources := Array new.
	previewed := false.
	applied := false
]

{ #category : 'actions' }
PCKFixCommand >> previewOn: aWriteStream [
	"D-06's mandatory preview: run the rule exactly as the check does (ch. 2 par. 2.3
	steps 1-2 through the D-72 environment - one attribution story across check and
	fix), keep each change-providing critique's change object, and land every
	prospective diff - target, old source, new source - on the handed stream before
	anything can change. The old sources are snapshotted here because
	oldVersionTextToDisplay re-reads the live method on every call (P5 probe,
	E08-C04) - apply's staleness guard compares against this moment. Answers the
	pending count; the handed stream is the only sink, and mutation stays apply's
	monopoly (E08-C04)."
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
	previewedSources := pendingChanges collect: [ :change | change oldVersionTextToDisplay ].
	critiques with: previewedSources do: [ :critique :source |
		aWriteStream
			nextPutAll: critique entity printString; cr;
			nextPutAll: '--- old'; cr;
			nextPutAll: source; cr;
			nextPutAll: '+++ new'; cr;
			nextPutAll: critique change textToDisplay; cr ].
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
