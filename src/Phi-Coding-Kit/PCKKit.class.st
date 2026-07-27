"
The coding kit (name ruled D-56), implementing the frozen PGRKit contract. Stateless - all class-side, no class-side variables. It validates its own block strictly against the canonical five-key schema (ch. 1 par. 1.4; D-51: blocks are opaque to the core, so only the kit can) and answers its specs in the canonical four-stage order (frozen at E06 acceptance, completed E07): all lint, then all architecture, then all derived behavioral suites, then all meta, in-key block order preserved. #lintRules becomes PCKLintRuleCheck registrations targeting the production role (D-25); #architectureChecks and #metaRules resolve via the promised packages: constructor (D-60), role-by-block-key (production and tests respectively). #layerMap is a parameter key (E10): when present it is parsed and validated against the production role at block-open (§4.1) and, when #architectureChecks names the kit's own PCKLayerMapCheck, handed to it via layerMap: (§4.3, richer than packages:); absent map or an unloaded layer package makes that one registration missing (§1.5), while every other architecture check keeps the generic packages: path. Behavioral suites have no block key (D-25): one derived registration per tests-role package - or the behavioral/tests-role missing sentinel on an empty expansion (R-24) - and every behavioral check of a call closes over that call's one PCKSuiteRunCache (par. 5.4, D-36), the kit's own PCKNoSkippedTestsMetaRule named in #metaRules riding the same cache. recommendedBlock answers the published stanza (C18; E07-C06 appends its #metaRules line).
"
Class {
	#name : 'PCKKit',
	#superclass : 'PGRKit',
	#category : 'Phi-Coding-Kit',
	#package : 'Phi-Coding-Kit'
}

{ #category : 'private' }
PCKKit class >> architectureSpecFor: aName layerMap: aLayerMapOrNil packages: productionNames [
	"The #architectureChecks dispatch for one name (§4.3). The kit owns PCKLayerMapCheck,
	so - by class identity, not kinship (== PCKLayerMapCheck, the accepted own-meta-rule
	pattern) - it is constructed richer than the generic packages: path: over the parsed
	#layerMap handed at block-open. #layerMap is this check's required parameter key (§1.5):
	absent (aLayerMapOrNil nil) it is a missing spec; a declared layer package not loaded
	is a missing spec naming it (loaded-ness is the kit's gate, never the check's walk);
	else the resolved check over the map. Every other arch name - a check the kit does not
	own - keeps the generic promised packages: path (R-21) untouched."
	(Smalltalk globals at: aName asSymbol ifAbsent: [ nil ]) == PCKLayerMapCheck ifFalse: [
		^ self
			promisedSpecFor: aName
			prefix: 'architecture/'
			kind: #architecture
			packages: productionNames ].
	aLayerMapOrNil ifNil: [
		^ PGRRegistrationSpec
			missing: 'architecture/PCKLayerMapCheck'
			kind: #architecture
			reason: 'PCKLayerMapCheck requires the #layerMap parameter key, which is absent' ].
	aLayerMapOrNil layers valuesDo: [ :packageNames |
		packageNames do: [ :packageName |
			(PackageOrganizer default packageNamed: packageName ifAbsent: [ nil ]) ifNil: [
				^ PGRRegistrationSpec
					missing: 'architecture/PCKLayerMapCheck'
					kind: #architecture
					reason: 'layer-map package ' , packageName , ' is not loaded' ] ] ].
	^ PGRRegistrationSpec
		name: 'architecture/PCKLayerMapCheck'
		kind: #architecture
		check: (PCKLayerMapCheck layerMap: aLayerMapOrNil)
]

{ #category : 'private' }
PCKKit class >> behavioralSpecsFor: testsNames cache: aSuiteRunCache [
	"Par. 5.1's whole derivation law: behavioral suites have no block key - one
	registration per tests-role package, unconditional and in handed order, each
	check closed over the run's one cache (D-36). An empty expansion is instead the
	one behavioral/tests-role missing registration (ch. 1 par. 1.5): the stock
	runner exits 0 on nothing-to-run, and silence is never a pass (R-24)."
	testsNames ifEmpty: [
		^ { PGRRegistrationSpec
			missing: 'behavioral/tests-role'
			kind: #behavioral
			reason: 'the tests-role expansion is empty - no packages to derive suite registrations from' } ].
	^ testsNames collect: [ :each |
		PGRRegistrationSpec
			name: 'behavioral/' , each
			kind: #behavioral
			check: (PCKTestSuiteCheck package: each cache: aSuiteRunCache) ]
]

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
PCKKit class >> metaRuleSpecFor: aCheckName packages: testsNames cache: aSuiteRunCache [
	"Par. 5.4's own-meta-rule special case: only when the name resolves to the kit's
	own PCKNoSkippedTestsMetaRule - identity, not kinship - is the check constructed
	over the run's shared cache, so it reads the very result objects the suite
	checks read (D-36). Every other resolved class keeps the generic promised
	packages: path and reaches no cache; unresolved names still answer missing
	specs there. Spec name and kind are the same either way."
	(Smalltalk globals at: aCheckName asSymbol ifAbsent: [ nil ])
		== PCKNoSkippedTestsMetaRule ifTrue: [
			^ PGRRegistrationSpec
				name: 'behavioral/' , aCheckName
				kind: #behavioral
				check: (PCKNoSkippedTestsMetaRule packages: testsNames cache: aSuiteRunCache) ].
	^ self
		promisedSpecFor: aCheckName
		prefix: 'behavioral/'
		kind: #behavioral
		packages: testsNames
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

{ #category : 'accessing' }
PCKKit class >> recommendedBlock [
	"The published stanza (ch. 1 par. 1.3, D-54/D-60): pure-data STON text (D-16),
	single-sourced here - a documented template the init tool composes into drafts
	and docs quote, never run-time machinery. No STON comments: their support is
	unverified and nothing may depend on it (P5). This is the complete M1
	recommended set (R-25/D-51): the two catalog lint rules plus the no-skips
	meta-rule. Behavioral suites need no stanza line - they derive from the
	adopter's tests role (par. 5.1); later milestones' checks join by their own
	scheduled edits. An adopter keeps the meta-rule by keeping the line -
	composition over defaults (D-51)."
	^ '{
	#kit : ''PCKKit'',
	#lintRules : [ ''PCKNoIsNilIfTrueRule'', ''ReCodeCruftLeftInMethodsRule'' ],
	#metaRules : [ ''PCKNoSkippedTestsMetaRule'' ]
}'
]

{ #category : 'registering' }
PCKKit class >> registrationsFrom: aBlock productionPackages: productionNames testsPackages: testsNames [
	"The frozen contract (E02 digest). The answered order is the canonical four-stage
	one, completed here (ch. 1 par. 1.4): all lint, then all architecture, then all
	derived behavioral suites (par. 5.1 - no block key), then all #metaRules specs,
	in-key block order preserved. One PCKSuiteRunCache per call closes every
	behavioral check of the call over one shared suite run (par. 5.4, D-36) -
	run-scoped, discarded with its checks, never global (R-35). Role-by-block-key:
	#architectureChecks hands the production list, #metaRules the tests list.
	#layerMap is E10's consumed parameter (§4.1): present, it is parsed and validated
	against the production role at block-open - a malformed or non-covering map raises
	here, whether or not PCKLayerMapCheck is registered - then routed, run-scoped and
	discarded with the specs, to the kit's own PCKLayerMapCheck in the architecture pass
	(§4.3); every other arch name keeps the generic packages: path (R-21)."
	| specs cache layerMap |
	self validateBlock: aBlock.
	specs := OrderedCollection new.
	cache := PCKSuiteRunCache new.
	layerMap := aBlock
		at: #layerMap
		ifPresent: [ :sub | PCKLayerMap fromLayerMap: sub productionPackages: productionNames ]
		ifAbsent: [ nil ].
	(aBlock at: #lintRules ifAbsent: [ #() ]) do: [ :each |
		specs add: (self lintSpecFor: each productionPackages: productionNames) ].
	(aBlock at: #architectureChecks ifAbsent: [ #() ]) do: [ :each |
		specs add: (self architectureSpecFor: each layerMap: layerMap packages: productionNames) ].
	specs addAll: (self behavioralSpecsFor: testsNames cache: cache).
	(aBlock at: #metaRules ifAbsent: [ #() ]) do: [ :each |
		specs add: (self metaRuleSpecFor: each packages: testsNames cache: cache) ].
	^ specs
]

{ #category : 'private' }
PCKKit class >> validateBlock: aBlock [
	"Strict envelope validation (family 7): an unknown key or a malformed list value
	is a configuration error naming the key, never a silent default. printString on
	the unknown key keeps the naming safe whatever object a malformed block carries.
	The isString exclusion bites because a String is itself a collection of
	Characters. #layerMap's envelope shape is checked here - a present value must be a
	map; its deep structure and completeness are PCKLayerMap's (E10-C01/C02), not
	duplicated here."
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
						'#' , listKey , ' must be a collection of check-class name Strings' ] ] ].
	aBlock at: #layerMap ifPresent: [ :value |
		value isDictionary ifFalse: [
			PGRConfigurationError signal:
				'#layerMap must be a map of layer-map keys to their values' ] ]
]
