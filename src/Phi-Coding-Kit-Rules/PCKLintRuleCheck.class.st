"
The lint kind's check (ch. 2 par. 2.3): wraps one Renraku rule class plus its target package names and answers the D-03 verdict - #error-severity critiques become red findings, sub-#error critiques become advisories on a green verdict, no critiques means green. One rule = one registration = one verdict. The gate reads critiques only, never applies a rule's rewrite (R-12); the fix capability pair stays inherited-false until E08. Constructed via the kit-side rule:packages: - richer than the promised packages: because the kit owns this class. E08 amendment through the decision-sheet path (D-72): run scopes the checker with the class-side lintEnvironmentOver: composition, so a trait-provided method is linted at each using class's package.
"
Class {
	#name : 'PCKLintRuleCheck',
	#superclass : 'PGRCheck',
	#instVars : [
		'rule'
	],
	#category : 'Phi-Coding-Kit-Rules',
	#package : 'Phi-Coding-Kit-Rules'
}

{ #category : 'environment' }
PCKLintRuleCheck class >> lintEnvironmentOver: aCollectionOfPackageNames [
	"The D-72 environment law, single-sourced: trait-provided methods are linted at
	each using class's package - a class environment over the target packages' defined
	classes (both sides) sees each class's own methods, flattened trait methods
	included, where the package environment attributed them only to the trait's
	defining package (D-71). The fix command (E08-C03) runs the rule through this
	same composition."
	| classes |
	classes := OrderedCollection new.
	aCollectionOfPackageNames do: [ :packageName |
		(PackageOrganizer default packageNamed: packageName) definedClasses
			do: [ :each | classes add: each; add: each classSide ] ].
	^ RBClassEnvironment classes: classes
]

{ #category : 'instance creation' }
PCKLintRuleCheck class >> rule: aRuleClass packages: aCollectionOfPackageNames [
	"Kit-side constructor (ch. 2 par. 2.3): the promised packages: constructor is for
	classes the kit does not own; this class carries its rule class too."
	^ (self packages: aCollectionOfPackageNames)
		setRule: aRuleClass;
		yourself
]

{ #category : 'accessing' }
PCKLintRuleCheck >> kind [
	^ #lint
]

{ #category : 'accessing' }
PCKLintRuleCheck >> rule [
	"Internal reader: the registration block (C16) and the fix command (E08) read the
	wrapped rule class here."
	^ rule
]

{ #category : 'running' }
PCKLintRuleCheck >> run [
	"The D-15 headless checker recipe over the packages handed at construction, then
	the D-03 two-tier mapping on the rule's class-side severity. Each finding's target
	is the critiqued method printed precisely (Class>>#selector, confirmed live), and
	the rule's rationale travels with every finding (R-13). criticsOf: answers a Set;
	asArray makes it sequenceable for the verdict constructors' Array withAll: copy."
	| ruleInstance checker critiques mapped |
	ruleInstance := rule new.
	checker := ReSmalllintChecker new
		rule: { ruleInstance };
		environment: (self class lintEnvironmentOver: self packages);
		run;
		yourself.
	critiques := checker criticsOf: ruleInstance.
	critiques ifEmpty: [ ^ PGRVerdict green ].
	mapped := critiques asArray collect: [ :each |
		PGRFinding
			target: each entity printString
			message: rule ruleName
			rationale: rule rationale ].
	^ rule severity == #error
		ifTrue: [ PGRVerdict redFindings: mapped ]
		ifFalse: [ PGRVerdict greenAdvisories: mapped ]
]

{ #category : 'private' }
PCKLintRuleCheck >> setRule: aRuleClass [
	rule := aRuleClass
]
