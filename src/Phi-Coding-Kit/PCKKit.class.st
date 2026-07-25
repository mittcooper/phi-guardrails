"
The coding kit (name ruled D-56), implementing the frozen PGRKit contract. Stateless - all class-side, no class-side variables. It validates its own block strictly against the canonical five-key schema (ch. 1 par. 1.4; D-51: blocks are opaque to the core, so only the kit can) and dispatches #lintRules into PCKLintRuleCheck registrations targeting the production role (D-25). #architectureChecks, #layerMap and #metaRules are recognized keys that produce no specs until C17; behavioral suites have no block key (E07 derives them from the tests role); recommendedBlock stays inherited until C18.
"
Class {
	#name : 'PCKKit',
	#superclass : 'PGRKit',
	#category : 'Phi-Coding-Kit',
	#package : 'Phi-Coding-Kit'
}

{ #category : 'private' }
PCKKit class >> blockKeys [
	"The canonical block schema, frozen at E06 acceptance (ch. 1 par. 1.4). #kit is
	tolerated verbatim: the engine resolved it to reach this class, so its value is
	not re-validated here."
	^ #(kit lintRules architectureChecks layerMap metaRules)
]

{ #category : 'private' }
PCKKit class >> lintSpecFor: aRuleName productionPackages: productionNames [
	"The #lintRules pipeline for one name (ch. 1 par. 1.5 + D-41): unresolved is a
	missing spec - a verdict-level fact, never an exception; a resolved non-rule, or
	a rule that does not itself implement class-side #severity (the inherited
	#warning is not a legal state for a registered rule), is a configuration error."
	| ruleClass |
	ruleClass := Smalltalk globals at: aRuleName asSymbol ifAbsent: [ nil ].
	ruleClass ifNil: [
		^ PGRRegistrationSpec
			missing: 'lint/' , aRuleName
			kind: #lint
			reason: aRuleName , ' does not resolve to a loaded class' ].
	(ruleClass isClass and: [ ruleClass inheritsFrom: ReAbstractRule ]) ifFalse: [
		PGRConfigurationError signal:
			aRuleName , ' is loaded but is not a Renraku rule class' ].
	(ruleClass class includesSelector: #severity) ifFalse: [
		PGRConfigurationError signal:
			aRuleName , ' does not itself implement class-side #severity (D-41)' ].
	^ PGRRegistrationSpec
		name: 'lint/' , aRuleName
		kind: #lint
		check: (PCKLintRuleCheck rule: ruleClass packages: productionNames)
]

{ #category : 'registering' }
PCKKit class >> registrationsFrom: aBlock productionPackages: productionNames testsPackages: testsNames [
	"The frozen contract (E02 digest). Specs come back in block order; testsNames is
	carried for the contract but unused until behavioral derivation (E07);
	#architectureChecks, #layerMap and #metaRules contribute no specs until C17."
	| specs |
	self validateBlock: aBlock.
	specs := OrderedCollection new.
	(aBlock at: #lintRules ifAbsent: [ #() ]) do: [ :each |
		specs add: (self lintSpecFor: each productionPackages: productionNames) ].
	^ specs
]

{ #category : 'private' }
PCKKit class >> validateBlock: aBlock [
	"Strict envelope validation (family 7): an unknown key or a malformed #lintRules
	value is a configuration error naming the key, never a silent default. printString
	on the key keeps the naming safe whatever object a malformed block carries."
	aBlock keysDo: [ :key |
		(self blockKeys includes: key) ifFalse: [
			PGRConfigurationError signal:
				'unknown key in the coding-kit block: ' , key printString ] ].
	aBlock at: #lintRules ifPresent: [ :value |
		(value isCollection and: [
			value isString not and: [
				value allSatisfy: [ :each | each isString ] ] ])
			ifFalse: [
				PGRConfigurationError signal:
					'#lintRules must be a collection of rule-class name Strings' ] ]
]
