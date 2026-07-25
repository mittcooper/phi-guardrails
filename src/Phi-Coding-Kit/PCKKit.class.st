"
The coding kit (name ruled D-56), implementing the frozen PGRKit contract. Stateless - all class-side, no class-side variables. It validates its own block strictly against the canonical five-key schema (ch. 1 par. 1.4; D-51: blocks are opaque to the core, so only the kit can) and answers its specs in the canonical order frozen at E06 acceptance: all lint, then all architecture, then all meta, in-key block order preserved. #lintRules becomes PCKLintRuleCheck registrations targeting the production role (D-25); #architectureChecks and #metaRules resolve via the promised packages: constructor (D-60), role-by-block-key (production and tests respectively). #layerMap is a parameter key: a present map is carried, unread, until E10 gives it its consumer. Behavioral suites have no block key (E07 derives them from the tests role); recommendedBlock stays inherited until C18.
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

{ #category : 'private' }
PCKKit class >> promisedSpecFor: aCheckName prefix: aPrefixString kind: aKindSymbol packages: roleNames [
	"The generic path for check classes the kit does not own (ch. 1 par. 1.4):
	unresolved is a missing spec - a verdict-level fact, never an exception (ch. 1
	par. 1.5, kind kept explicit: no check exists to ask); resolved and answering
	the promised constructor packages: (D-60) is instantiated with the handed role
	list; a class answering neither path is a configuration error naming it. The
	respondsTo: probe asks the metaclass, inherited implementations included -
	inheriting from PGRCheck is the normal case. This reflective conformance probe
	on a configuration-named class is the same validation family the engine uses
	(D-53/D-60), not the banned type-predicate dispatch on domain objects."
	| cls |
	cls := Smalltalk globals at: aCheckName asSymbol ifAbsent: [ nil ].
	cls ifNil: [
		^ PGRRegistrationSpec
			missing: aPrefixString , aCheckName
			kind: aKindSymbol
			reason: aCheckName , ' does not resolve to a loaded class' ].
	(cls respondsTo: #packages:) ifFalse: [
		PGRConfigurationError signal:
			aCheckName , ' is loaded but its class side answers no packages: constructor' ].
	^ PGRRegistrationSpec
		name: aPrefixString , aCheckName
		kind: aKindSymbol
		check: (cls packages: roleNames)
]

{ #category : 'registering' }
PCKKit class >> registrationsFrom: aBlock productionPackages: productionNames testsPackages: testsNames [
	"The frozen contract (E02 digest). The answered order is the canonical one (ch. 1
	par. 1.4): all lint, then all architecture, then all meta specs, in-key block
	order preserved - E07 inserts derived behavioral-suite registrations between
	architecture and meta. Role-by-block-key: #architectureChecks hands the
	production list, #metaRules the tests list. #layerMap contributes no specs:
	a parameter, not a check list - carried, unread, until E10."
	| specs |
	self validateBlock: aBlock.
	specs := OrderedCollection new.
	(aBlock at: #lintRules ifAbsent: [ #() ]) do: [ :each |
		specs add: (self lintSpecFor: each productionPackages: productionNames) ].
	(aBlock at: #architectureChecks ifAbsent: [ #() ]) do: [ :each |
		specs add: (self
			promisedSpecFor: each
			prefix: 'architecture/'
			kind: #architecture
			packages: productionNames) ].
	(aBlock at: #metaRules ifAbsent: [ #() ]) do: [ :each |
		specs add: (self
			promisedSpecFor: each
			prefix: 'behavioral/'
			kind: #behavioral
			packages: testsNames) ].
	^ specs
]

{ #category : 'private' }
PCKKit class >> validateBlock: aBlock [
	"Strict envelope validation (family 7): an unknown key or a malformed list value
	is a configuration error naming the key, never a silent default. printString on
	the unknown key keeps the naming safe whatever object a malformed block carries.
	The isString exclusion bites because a String is itself a collection of
	Characters. #layerMap is only recognized here - its shape is E10's to validate."
	aBlock keysDo: [ :key |
		(self blockKeys includes: key) ifFalse: [
			PGRConfigurationError signal:
				'unknown key in the coding-kit block: ' , key printString ] ].
	#(lintRules architectureChecks metaRules) do: [ :listKey |
		aBlock at: listKey ifPresent: [ :value |
			(value isCollection and: [
				value isString not and: [
					value allSatisfy: [ :each | each isString ] ] ])
				ifFalse: [
					PGRConfigurationError signal:
						'#' , listKey , ' must be a collection of check-class name Strings' ] ] ]
]
