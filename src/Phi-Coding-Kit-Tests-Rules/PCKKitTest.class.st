"
Behavioral pin of the kit block envelope and dispatch: strict five-key validation (D-51 - blocks are opaque to the core, so only the kit can validate its own), the #lintRules pipeline arms (C16), the generic promised-constructor paths for #architectureChecks and #metaRules with role-by-block-key, missing specs for unresolved names, the neither-path configuration error, the carried-unread #layerMap parameter, the derived behavioral-suite registrations sharing one run-scoped cache per call with the behavioral/tests-role sentinel and the own-meta-rule special case (E07-C05; par. 5.1/5.4, D-36), and the completed four-stage lint -> architecture -> behavioral -> meta order law (C17, completed E07-C05). Error-message assertions name the offender, never exact wording (the text is human-facing, not an API). Lives here by the recorded chunks.md ruling: the frozen E01 tree has no root kit tests package; E07 extends this class in place.
"
Class {
	#name : 'PCKKitTest',
	#superclass : 'TestCase',
	#category : 'Phi-Coding-Kit-Tests-Rules',
	#package : 'Phi-Coding-Kit-Tests-Rules'
}

{ #category : 'tests' }
PCKKitTest >> testArchitectureCheckResolvedViaPackagesConstructor [
	"Ch. 1 par. 1.4, promised-constructor path: a named class the kit does not own is instantiated via packages: (D-60); role-by-block-key hands #architectureChecks the production list, not the tests list."
	| block specs spec |
	block := Dictionary new.
	block at: #architectureChecks put: #('PCKArchStubCheck').
	specs := PCKKit
		registrationsFrom: block
		productionPackages: #('P-One' 'P-Two')
		testsPackages: #().
	self assert: specs size equals: 2.
	spec := specs first.
	self assert: spec name equals: 'architecture/PCKArchStubCheck'.
	self assert: spec kind identicalTo: #architecture.
	self assert: spec check class equals: PCKArchStubCheck.
	self assert: spec check packages equals: #('P-One' 'P-Two').
	self assert: specs last name equals: 'behavioral/tests-role'.
	self assert: specs last kind identicalTo: #behavioral.
	self assert: specs last check isNil
]

{ #category : 'tests' }
PCKKitTest >> testClassAnsweringNeitherPathSignals [
	"Ch. 1 par. 1.4, neither-path arm: a resolved class whose class side answers no packages: constructor is a configuration error naming the class."
	| block |
	block := Dictionary new.
	block at: #architectureChecks put: #('PGRFinding').
	self
		should: [ PCKKit registrationsFrom: block productionPackages: #('P-One') testsPackages: #() ]
		raise: PGRConfigurationError
		withExceptionDo: [ :error |
			self assert: (error messageText includesSubstring: 'PGRFinding') ]
]

{ #category : 'tests' }
PCKKitTest >> testDerivesOneSuiteRegistrationPerTestsRolePackage [
	"Par. 5.1's whole derivation, ordered: one suite registration per tests-role package, no block key - unconditional, in handed order, each check a PCKTestSuiteCheck closed over its own package (D-25)."
	| specs |
	specs := PCKKit
		registrationsFrom: Dictionary new
		productionPackages: #('P-One')
		testsPackages: #('Phi-Coding-Kit-Fixtures-Behavioral' 'Phi-Guardrails-Tests-SDK').
	self assert: specs size equals: 2.
	self
		assert: (specs collect: [ :each | each name ]) asArray
		equals: #('behavioral/Phi-Coding-Kit-Fixtures-Behavioral' 'behavioral/Phi-Guardrails-Tests-SDK').
	specs do: [ :each |
		self assert: each kind identicalTo: #behavioral.
		self assert: each check class equals: PCKTestSuiteCheck.
		self assert: 'behavioral/' , each check package equals: each name ]
]

{ #category : 'tests' }
PCKKitTest >> testEnvironmentFormMatchesThreeArgumentForm [
	"D-81 delegation witness: one pipeline, two doors. The three-argument form and the environment form over a degenerate view (same roles, exempt #(), srcPath nil) answer the same spec list pairwise - equal names, kinds, and missing-nesses - for a block that consumes no envelope fact."
	| block threeArg envForm view |
	block := Dictionary new.
	block at: #lintRules put: #('PCKNoIsNilIfTrueRule' 'ReCodeCruftLeftInMethodsRule').
	block at: #metaRules put: #('PCKNoSkippedTestsMetaRule').
	threeArg := PCKKit
		registrationsFrom: block
		productionPackages: #('Phi-Guardrails-SDK')
		testsPackages: #('Phi-Coding-Kit-Fixtures-Behavioral').
	view := PGRKitEnvironment
		productionPackages: #('Phi-Guardrails-SDK')
		testsPackages: #('Phi-Coding-Kit-Fixtures-Behavioral')
		exemptPackages: #()
		srcPath: nil.
	envForm := PCKKit registrationsFrom: block environment: view.
	self assert: threeArg size equals: envForm size.
	threeArg with: envForm do: [ :a :b |
		self assert: a name equals: b name.
		self assert: a kind equals: b kind.
		self assert: a check isNil equals: b check isNil ]
]

{ #category : 'tests' }
PCKKitTest >> testGenericArchitectureCheckStillUsesPackagesConstructor [
	"R-21 / §4.3 regression: a non-owned arch check keeps the generic promised packages: path untouched by the PCKLayerMapCheck special case - resolved into an architecture spec whose check carries the handed production role."
	| block specs spec |
	block := Dictionary new.
	block at: #architectureChecks put: #('PCKArchStubCheck').
	specs := PCKKit
		registrationsFrom: block
		productionPackages: #('P-One' 'P-Two')
		testsPackages: #().
	self assert: specs size equals: 2.
	spec := specs first.
	self assert: spec name equals: 'architecture/PCKArchStubCheck'.
	self assert: spec kind identicalTo: #architecture.
	self assert: spec check class equals: PCKArchStubCheck.
	self assert: spec check packages equals: #('P-One' 'P-Two')
]

{ #category : 'tests' }
PCKKitTest >> testLayerMapCheckConstructedWithMapWhenRegistered [
	"§4.3: the kit owns PCKLayerMapCheck and, when #architectureChecks names it with a present covering #layerMap over loaded packages, constructs it via layerMap: (richer than the generic packages:) into a resolved architecture spec whose check is a PCKLayerMapCheck of kind #architecture."
	| block specs spec |
	block := Dictionary new.
	block at: #architectureChecks put: #('PCKLayerMapCheck').
	block at: #layerMap put: { #layers -> ({ 'p' -> #('Phi-Coding-Kit-Architecture') } asDictionary). #allowed -> #() } asDictionary.
	specs := PCKKit
		registrationsFrom: block
		productionPackages: #('Phi-Coding-Kit-Architecture')
		testsPackages: #().
	self assert: specs size equals: 2.
	spec := specs first.
	self assert: spec name equals: 'architecture/PCKLayerMapCheck'.
	self assert: spec kind identicalTo: #architecture.
	self assert: spec check class equals: PCKLayerMapCheck.
	self assert: spec check kind identicalTo: #architecture.
	"Discriminates the layerMap: construction from the inherited generic packages: path:
	built via layerMap:, the inherited packages ivar is never set, so it is nil."
	self assert: spec check packages isNil
]

{ #category : 'tests' }
PCKKitTest >> testLayerMapCheckMissingWhenLayerPackageUnloaded [
	"§1.5 unloaded arm: a declared layer package present in the handed production role (so the completeness law passes on names) but not loaded in the image yields the missing architecture spec, its reason naming the unloaded package - loaded-ness is the kit's gate, never the check's walk."
	| block specs spec |
	block := Dictionary new.
	block at: #architectureChecks put: #('PCKLayerMapCheck').
	block at: #layerMap put: { #layers -> ({ 'p' -> #('PCK-No-Such-Package') } asDictionary). #allowed -> #() } asDictionary.
	specs := PCKKit
		registrationsFrom: block
		productionPackages: #('PCK-No-Such-Package')
		testsPackages: #().
	self assert: specs size equals: 2.
	spec := specs first.
	self assert: spec name equals: 'architecture/PCKLayerMapCheck'.
	self assert: spec kind identicalTo: #architecture.
	self assert: spec check isNil.
	self assert: (spec missingReason includesSubstring: 'PCK-No-Such-Package')
]

{ #category : 'tests' }
PCKKitTest >> testLayerMapCheckMissingWhenNoMap [
	"§1.5: #layerMap is PCKLayerMapCheck's required parameter key; naming the check in #architectureChecks with no #layerMap yields the missing architecture spec (no check), its reason naming the absent key."
	| block specs spec |
	block := Dictionary new.
	block at: #architectureChecks put: #('PCKLayerMapCheck').
	specs := PCKKit
		registrationsFrom: block
		productionPackages: #('P-One')
		testsPackages: #().
	self assert: specs size equals: 2.
	spec := specs first.
	self assert: spec name equals: 'architecture/PCKLayerMapCheck'.
	self assert: spec kind identicalTo: #architecture.
	self assert: spec check isNil.
	self assert: (spec missingReason includesSubstring: 'layerMap')
]

{ #category : 'tests' }
PCKKitTest >> testLayerMapKeyProducesNoRegistrationsAndNoError [
	"#layerMap is a parameter key, not a check list: a present, valid, covering map is validated (E10-C06) but - absent a PCKLayerMapCheck entry in #architectureChecks - contributes no registration of its own; the specs are exactly the lint and behavioral-sentinel pair, no error."
	| block specs |
	block := Dictionary new.
	block at: #lintRules put: #('PCKNoIsNilIfTrueRule').
	block at: #layerMap put: { #layers -> ({ 'p' -> #('P-One') } asDictionary). #allowed -> #() } asDictionary.
	specs := PCKKit
		registrationsFrom: block
		productionPackages: #('P-One')
		testsPackages: #().
	self assert: specs size equals: 2.
	self assert: specs first name equals: 'lint/PCKNoIsNilIfTrueRule'.
	self assert: specs last name equals: 'behavioral/tests-role'
]

{ #category : 'tests' }
PCKKitTest >> testLayerMapPathIntactUnderEnvironmentForm [
	"D-81: the E10 layer-map arm rides the view's production list unchanged. A view (srcPath nil) whose production is #('P-One') and a block whose #layerMap covers that role at block-open but whose layer package is unloaded in the verify image answers the missing sentinel naming 'P-One' - byte-equivalent to testLayerMapCheckMissingWhenLayerPackageUnloaded, reproduced through the environment door."
	| block view specs spec |
	block := Dictionary new.
	block at: #architectureChecks put: #('PCKLayerMapCheck').
	block at: #layerMap put: { #layers -> ({ 'p' -> #('P-One') } asDictionary). #allowed -> #() } asDictionary.
	view := PGRKitEnvironment
		productionPackages: #('P-One')
		testsPackages: #()
		exemptPackages: #()
		srcPath: nil.
	specs := PCKKit registrationsFrom: block environment: view.
	spec := specs detect: [ :each | each name = 'architecture/PCKLayerMapCheck' ].
	self assert: spec kind identicalTo: #architecture.
	self assert: spec check isNil.
	self assert: (spec missingReason includesSubstring: 'P-One')
]

{ #category : 'tests' }
PCKKitTest >> testLintRegistrationsFromBlock [
	"Ch. 2 par. 2.4: a shipped built-in registers exactly like a catalog rule - same block, same spec shape; lint targets the production role (D-25)."
	| block specs |
	block := Dictionary new.
	block at: #kit put: 'PCKKit'.
	block at: #lintRules put: #('PCKNoIsNilIfTrueRule' 'ReCodeCruftLeftInMethodsRule').
	specs := PCKKit
		registrationsFrom: block
		productionPackages: #('Phi-Guardrails-SDK')
		testsPackages: #().
	self assert: specs size equals: 3.
	self
		assert: (specs collect: [ :each | each name ]) asArray
		equals: #('lint/PCKNoIsNilIfTrueRule' 'lint/ReCodeCruftLeftInMethodsRule' 'behavioral/tests-role').
	(specs first: 2) do: [ :each |
		self assert: each kind identicalTo: #lint.
		self assert: each check class equals: PCKLintRuleCheck.
		self assert: each check packages equals: #('Phi-Guardrails-SDK') ].
	self assert: specs first check rule identicalTo: PCKNoIsNilIfTrueRule.
	self assert: (specs at: 2) check rule identicalTo: ReCodeCruftLeftInMethodsRule
]

{ #category : 'tests' }
PCKKitTest >> testMetaRuleResolvedWithTestsRole [
	"Role-by-block-key, tests arm: #metaRules hands the tests list, not the production list; the name takes the behavioral prefix (ch. 1 par. 1.3: behavioral/<Class>)."
	| block specs spec |
	block := Dictionary new.
	block at: #metaRules put: #('PCKMetaStubCheck').
	specs := PCKKit
		registrationsFrom: block
		productionPackages: #('P-One')
		testsPackages: #('T-One').
	self assert: specs size equals: 2.
	self assert: specs first name equals: 'behavioral/T-One'.
	self assert: specs first kind identicalTo: #behavioral.
	self assert: specs first check class equals: PCKTestSuiteCheck.
	spec := specs last.
	self assert: spec name equals: 'behavioral/PCKMetaStubCheck'.
	self assert: spec kind identicalTo: #behavioral.
	self assert: spec check class equals: PCKMetaStubCheck.
	self assert: spec check packages equals: #('T-One')
]

{ #category : 'tests' }
PCKKitTest >> testNonRuleClassSignals [
	"Ch. 1 par. 1.5, loaded-but-not-a-rule arm: a resolved class with no Renraku descent is a configuration error at construction, never a missing spec."
	| block |
	block := Dictionary new.
	block at: #lintRules put: #('PGRFinding').
	self
		should: [ PCKKit registrationsFrom: block productionPackages: #('Phi-Guardrails-SDK') testsPackages: #() ]
		raise: PGRConfigurationError
		withExceptionDo: [ :error |
			self assert: (error messageText includesSubstring: 'PGRFinding') ]
]

{ #category : 'tests' }
PCKKitTest >> testOwnMetaRuleRidesTheRunCache [
	"Par. 5.4's own-meta-rule special case + D-36's one-cache law: the kit's own class named in #metaRules is constructed over the run's one shared cache - identical to the suite check's - so it reads the very result objects the suite registrations produce; the sibling generic path is pinned by testMetaRuleResolvedWithTestsRole."
	| block specs metaSpec |
	block := Dictionary new.
	block at: #metaRules put: #('PCKNoSkippedTestsMetaRule').
	specs := PCKKit
		registrationsFrom: block
		productionPackages: #('P-One')
		testsPackages: #('Phi-Coding-Kit-Fixtures-Behavioral').
	self assert: specs size equals: 2.
	metaSpec := specs last.
	self assert: metaSpec name equals: 'behavioral/PCKNoSkippedTestsMetaRule'.
	self assert: metaSpec kind identicalTo: #behavioral.
	self assert: metaSpec check class equals: PCKNoSkippedTestsMetaRule.
	self assert: metaSpec check packages equals: #('Phi-Coding-Kit-Fixtures-Behavioral').
	self assert: metaSpec check cache identicalTo: specs first check cache
]

{ #category : 'tests' }
PCKKitTest >> testPresentButUncoveringLayerMapSignals [
	"§4.1: a present #layerMap is validated at block-open - its layers and #unlayered must jointly cover the production role - regardless of whether PCKLayerMapCheck is registered. A map that leaves a production package covered nowhere raises a configuration error naming that uncovered package (here 'P-Two', the accepted C02 completeness law naming the offending production-role package)."
	| block |
	block := Dictionary new.
	block at: #layerMap put: { #layers -> ({ 'p' -> #('P-One') } asDictionary). #allowed -> #() } asDictionary.
	self
		should: [ PCKKit registrationsFrom: block productionPackages: #('P-One' 'P-Two') testsPackages: #() ]
		raise: PGRConfigurationError
		withExceptionDo: [ :error |
			self assert: (error messageText includesSubstring: 'P-Two') ]
]

{ #category : 'tests' }
PCKKitTest >> testRecommendedBlockParsesAndConforms [
	"P-STANZA-VALID (ch. 9): the published stanza parses cleanly, every check it names resolves and registers through the kit's own dispatch, and each registered check conforms to the frozen check protocol - run, kind, canFix, packages - with the spec's kind equal to the check's own kind (D-60's agreement fact, asserted directly at the kit boundary): the stanza can never drift from the code it describes."
	| specs |
	specs := PCKKit
		registrationsFrom: (STON fromString: PCKKit recommendedBlock)
		productionPackages: #('Phi-Guardrails-SDK')
		testsPackages: #('Phi-Coding-Kit-Fixtures-Behavioral').
	self assert: specs size equals: 4.
	specs do: [ :each |
		self deny: each check isNil.
		#(run kind canFix packages) do: [ :selector |
			self assert: (each check respondsTo: selector) ].
		self assert: each kind identicalTo: each check kind ]
]

{ #category : 'tests' }
PCKKitTest >> testRecommendedBlockParsesAsKitBlock [
	"The published stanza (ch. 1 par. 1.3, D-54/D-60) parses as the kit block it documents: a Dictionary with Symbol keys whose #kit is this class, whose #lintRules is the ordered catalog pair (D-51, par. 3.2 then 3.2b), and whose #metaRules is the no-skips meta-rule (R-25) - the complete M1 recommended set, and nothing beyond those three keys."
	| block |
	block := STON fromString: PCKKit recommendedBlock.
	self assert: (block isKindOf: Dictionary).
	self assert: block size equals: 3.
	self assert: (block at: #kit) equals: 'PCKKit'.
	self
		assert: (block at: #lintRules) asArray
		equals: #('PCKNoIsNilIfTrueRule' 'ReCodeCruftLeftInMethodsRule').
	self
		assert: (block at: #metaRules) asArray
		equals: #('PCKNoSkippedTestsMetaRule')
]

{ #category : 'tests' }
PCKKitTest >> testRecommendedBlockRegistersCleanly [
	"The resolution arm of P-STANZA-VALID: the stanza can never name something that does not resolve - parsed and handed to the kit with a real tests role it yields the two catalog specs, the derived suite spec, and the own-meta-rule spec, in the frozen four-stage order, all resolved, none missing."
	| specs |
	specs := PCKKit
		registrationsFrom: (STON fromString: PCKKit recommendedBlock)
		productionPackages: #('Phi-Guardrails-SDK')
		testsPackages: #('Phi-Coding-Kit-Fixtures-Behavioral').
	self assert: specs size equals: 4.
	self
		assert: (specs collect: [ :each | each name ]) asArray
		equals: #('lint/PCKNoIsNilIfTrueRule' 'lint/ReCodeCruftLeftInMethodsRule' 'behavioral/Phi-Coding-Kit-Fixtures-Behavioral' 'behavioral/PCKNoSkippedTestsMetaRule').
	specs do: [ :each |
		self deny: each check isNil.
		self assert: each missingReason isNil ]
]

{ #category : 'tests' }
PCKKitTest >> testRegistrationOrderIsLintThenArchitectureThenMeta [
	"The four-stage order law, frozen at E06 acceptance and completed here (ch. 1 par. 1.4): all lint, then all architecture, then all derived behavioral suites, then all #metaRules specs - the dispatch order, whatever order the block was assembled in."
	| block specs |
	block := Dictionary new.
	block at: #metaRules put: #('PCKMetaStubCheck').
	block at: #architectureChecks put: #('PCKArchStubCheck').
	block at: #lintRules put: #('PCKNoIsNilIfTrueRule').
	specs := PCKKit
		registrationsFrom: block
		productionPackages: #('P-One')
		testsPackages: #('T-One').
	self
		assert: (specs collect: [ :each | each name ]) asArray
		equals: #('lint/PCKNoIsNilIfTrueRule' 'architecture/PCKArchStubCheck' 'behavioral/T-One' 'behavioral/PCKMetaStubCheck')
]

{ #category : 'tests' }
PCKKitTest >> testRuleWithoutOwnSeveritySignals [
	"P-SEVERITY-EXPLICIT (D-41): the inherited #warning is not a legal state for a registered rule; the kit raises when it opens its block, before any check runs."
	| block |
	block := Dictionary new.
	block at: #lintRules put: #('PCKInheritedSeverityStubRule').
	self
		should: [ PCKKit registrationsFrom: block productionPackages: #('Phi-Guardrails-SDK') testsPackages: #() ]
		raise: PGRConfigurationError
		withExceptionDo: [ :error |
			self assert: (error messageText includesSubstring: 'PCKInheritedSeverityStubRule') ]
]

{ #category : 'tests' }
PCKKitTest >> testSrcInventoryCheckConstructedFromView [
	"§7.5 / D-81: named in #architectureChecks with a view declaring #src, PCKSrcInventoryCheck is constructed over the view's srcPath into a resolved architecture spec whose check is a PCKSrcInventoryCheck of kind #architecture."
	| block view specs spec |
	block := Dictionary new.
	block at: #architectureChecks put: #('PCKSrcInventoryCheck').
	view := PGRKitEnvironment
		productionPackages: #('P-One')
		testsPackages: #('T-One')
		exemptPackages: #('X-One')
		srcPath: (FileSystem workingDirectory / 'pck-e11-c04-scratch') fullName.
	specs := PCKKit registrationsFrom: block environment: view.
	spec := specs detect: [ :each | each name = 'architecture/PCKSrcInventoryCheck' ].
	self assert: spec kind identicalTo: #architecture.
	self deny: spec check isNil.
	self assert: spec check class equals: PCKSrcInventoryCheck.
	self assert: spec check kind identicalTo: #architecture
]

{ #category : 'tests' }
PCKKitTest >> testSrcInventoryCheckMissingWithoutSrc [
	"§1.5: PCKSrcInventoryCheck's #src is an envelope key; naming the check with a view whose srcPath is nil yields the missing architecture spec (no check), its reason naming the absent #src key."
	| block view specs spec |
	block := Dictionary new.
	block at: #architectureChecks put: #('PCKSrcInventoryCheck').
	view := PGRKitEnvironment
		productionPackages: #('P-One')
		testsPackages: #('T-One')
		exemptPackages: #('X-One')
		srcPath: nil.
	specs := PCKKit registrationsFrom: block environment: view.
	spec := specs detect: [ :each | each name = 'architecture/PCKSrcInventoryCheck' ].
	self assert: spec kind identicalTo: #architecture.
	self assert: spec check isNil.
	self assert: (spec missingReason includesSubstring: '#src')
]

{ #category : 'tests' }
PCKKitTest >> testSuiteRegistrationsPrecedeMetaRules [
	"P-SUITES-BEFORE-META (ch. 9): every derived suite spec's index in the answer is lower than every #metaRules spec's index - the suites a meta-rule reads over are registered before it."
	| block specs lastSuiteIndex firstMetaIndex |
	block := Dictionary new.
	block at: #metaRules put: #('PCKMetaStubCheck').
	specs := PCKKit
		registrationsFrom: block
		productionPackages: #('P-One')
		testsPackages: #('Phi-Coding-Kit-Fixtures-Behavioral' 'Phi-Guardrails-Tests-SDK').
	lastSuiteIndex := specs findLast: [ :each | each check class = PCKTestSuiteCheck ].
	firstMetaIndex := specs findFirst: [ :each | each name = 'behavioral/PCKMetaStubCheck' ].
	self assert: lastSuiteIndex > 0.
	self assert: firstMetaIndex > 0.
	self assert: lastSuiteIndex < firstMetaIndex
]

{ #category : 'tests' }
PCKKitTest >> testThreeArgumentFormAnswersSrcInventoryMissing [
	"D-81: the frozen three-argument form stays complete and honest. Its degenerate delegation view carries no #src fact, so a block naming PCKSrcInventoryCheck answers the §1.5 missing spec, its reason naming #src."
	| block specs spec |
	block := Dictionary new.
	block at: #architectureChecks put: #('PCKSrcInventoryCheck').
	specs := PCKKit
		registrationsFrom: block
		productionPackages: #('P-One')
		testsPackages: #('T-One').
	spec := specs detect: [ :each | each name = 'architecture/PCKSrcInventoryCheck' ].
	self assert: spec check isNil.
	self assert: (spec missingReason includesSubstring: '#src')
]

{ #category : 'tests' }
PCKKitTest >> testTwoRegistrationRoundsShareNoCache [
	"R-35: the cache is run-scoped - one per contract call, closed over by that call's behavioral checks and discarded with them; two calls never share one."
	| block firstCache secondCache |
	block := Dictionary new.
	firstCache := (PCKKit
		registrationsFrom: block
		productionPackages: #('P-One')
		testsPackages: #('Phi-Coding-Kit-Fixtures-Behavioral')) first check cache.
	secondCache := (PCKKit
		registrationsFrom: block
		productionPackages: #('P-One')
		testsPackages: #('Phi-Coding-Kit-Fixtures-Behavioral')) first check cache.
	self deny: firstCache identicalTo: secondCache
]

{ #category : 'tests' }
PCKKitTest >> testUnknownBlockKeySignals [
	"Strict envelope validation (D-51): any key outside the canonical five is a configuration error naming the key."
	| block |
	block := Dictionary new.
	block at: #lintRulez put: #('PCKNoIsNilIfTrueRule').
	self
		should: [ PCKKit registrationsFrom: block productionPackages: #() testsPackages: #() ]
		raise: PGRConfigurationError
		withExceptionDo: [ :error |
			self assert: (error messageText includesSubstring: 'lintRulez') ]
]

{ #category : 'tests' }
PCKKitTest >> testUnresolvedArchitectureAndMetaAnswerMissingSpecs [
	"Ch. 1 par. 1.5: an unresolved name in either list is a missing spec, never an exception; a missing spec keeps its explicit kind - no check exists to ask (D-60)."
	| block specs |
	block := Dictionary new.
	block at: #architectureChecks put: #('PCKNoSuchCheck').
	block at: #metaRules put: #('PCKNoSuchCheck').
	specs := PCKKit
		registrationsFrom: block
		productionPackages: #('P-One')
		testsPackages: #('T-One').
	self assert: specs size equals: 3.
	self assert: specs first name equals: 'architecture/PCKNoSuchCheck'.
	self assert: specs first kind identicalTo: #architecture.
	self assert: (specs at: 2) name equals: 'behavioral/T-One'.
	self deny: (specs at: 2) check isNil.
	self assert: specs last name equals: 'behavioral/PCKNoSuchCheck'.
	self assert: specs last kind identicalTo: #behavioral.
	{ specs first. specs last } do: [ :each |
		self assert: each check isNil.
		self assert: (each missingReason includesSubstring: 'PCKNoSuchCheck') ]
]

{ #category : 'tests' }
PCKKitTest >> testUnresolvedLintRuleAnswersMissingSpec [
	"Ch. 1 par. 1.5: an unresolved name is a verdict-level fact, not an exception - the run completes and the gate, not the kit, fails."
	| block specs spec |
	block := Dictionary new.
	block at: #lintRules put: #('PCKNoSuchRule').
	specs := PCKKit
		registrationsFrom: block
		productionPackages: #('Phi-Guardrails-SDK')
		testsPackages: #().
	self assert: specs size equals: 2.
	spec := specs first.
	self assert: spec name equals: 'lint/PCKNoSuchRule'.
	self assert: spec kind identicalTo: #lint.
	self assert: spec check isNil.
	self assert: (spec missingReason includesSubstring: 'PCKNoSuchRule').
	self assert: specs last name equals: 'behavioral/tests-role'.
	self assert: specs last kind identicalTo: #behavioral.
	self assert: specs last check isNil
]
