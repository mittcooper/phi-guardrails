"
Machine-witnesses the published-surface freeze (R-04 machine half; ch. 0 §0.3; ch. 9 §9.1 P-SURFACE-CONFORMS). The class-side manifest mirrors ch. 0 §0.3's audience surfaces as (class · #class|#instance · selector) triples, grouped by audience; the tests assert every promised member resolves against the loaded image on its stated side, so a renamed or dropped member is a red test, not a client surprise. Arity note: a selector's arity is intrinsic to its spelling, so asserting successful implements-or-inherits lookup of the exact selector IS the arity assertion (class side via `cls class canUnderstand:`, instance side via `cls canUnderstand:` — both fold in inheritance; subclassResponsibility bodies count as implemented). Existence/side/arity only — behaviour is other suites' subject. The manifest is a class-side method answering fresh data (no class-side variable, R-35); it grows like the configuration artifact (constitution §3): the config-author audience has no code member at M1 (PGRConfigurationDraft is E12), and PGRVerdict class>>skipped is deliberately off every surface (D-21/D-32).
"
Class {
	#name : 'PGRSurfaceConformanceTest',
	#superclass : 'TestCase',
	#category : 'Phi-Guardrails-Tests-SDK',
	#package : 'Phi-Guardrails-Tests-SDK'
}

{ #category : 'manifest' }
PGRSurfaceConformanceTest class >> checkAuthorSurface [
	"The check-author SDK: the skeleton the author subclasses, plus the verdict and finding constructors it emits."

	^ {
		{ 'PGRCheck'. #class. #packages: }.
		{ 'PGRCheck'. #instance. #run }.
		{ 'PGRCheck'. #instance. #kind }.
		{ 'PGRCheck'. #instance. #canFix }.
		{ 'PGRCheck'. #instance. #fixCommandOn: }.
		{ 'PGRVerdict'. #class. #green }.
		{ 'PGRVerdict'. #class. #greenAdvisories: }.
		{ 'PGRVerdict'. #class. #redFindings: }.
		{ 'PGRVerdict'. #class. #missingReason: }.
		{ 'PGRFinding'. #class. #target:message: }.
		{ 'PGRFinding'. #class. #target:message:rationale: } }
]

{ #category : 'manifest' }
PGRSurfaceConformanceTest class >> errorClassNames [
	"The catchable-by-class error vocabulary (D-49); each inherits from Error."

	^ #( 'PGRConfigurationError' 'PGRNotAutofixable' 'PGRFixNotPreviewed' 'PGRFixStale' )
]

{ #category : 'manifest' }
PGRSurfaceConformanceTest class >> fixInvokerSurface [
	"The fix-invoker SDK: preview-first mutation through the coding kit's fix command."

	^ {
		{ 'PCKFixCommand'. #class. #rule:packages: }.
		{ 'PCKFixCommand'. #instance. #previewOn: }.
		{ 'PCKFixCommand'. #instance. #apply }.
		{ 'PCKFixCommand'. #instance. #changes } }
]

{ #category : 'manifest' }
PGRSurfaceConformanceTest class >> gateCallerSurface [
	"The gate-caller SDK: run the gate over a configuration and read its read-only report."

	^ {
		{ 'PGRGate'. #class. #runHeadless: }.
		{ 'PGRGate'. #class. #runHeadless:on: }.
		{ 'PGRGate'. #class. #forConfiguration: }.
		{ 'PGRGate'. #instance. #run }.
		{ 'PGRGate'. #instance. #onVerdict: }.
		{ 'PGRConfiguration'. #class. #fromFile: }.
		{ 'PGRConfiguration'. #class. #fromString: }.
		{ 'PGRReport'. #instance. #verdicts }.
		{ 'PGRReport'. #instance. #isClean }.
		{ 'PGRReport'. #instance. #exitCode }.
		{ 'PGRReport'. #instance. #blockingVerdicts }.
		{ 'PGRReport'. #instance. #advisories }.
		{ 'PGRVerdict'. #instance. #status }.
		{ 'PGRVerdict'. #instance. #isGreen }.
		{ 'PGRVerdict'. #instance. #registrationName }.
		{ 'PGRVerdict'. #instance. #kind }.
		{ 'PGRVerdict'. #instance. #durationMillis }.
		{ 'PGRVerdict'. #instance. #findings }.
		{ 'PGRVerdict'. #instance. #advisories }.
		{ 'PGRFinding'. #instance. #target }.
		{ 'PGRFinding'. #instance. #message }.
		{ 'PGRFinding'. #instance. #rationale } }
]

{ #category : 'manifest' }
PGRSurfaceConformanceTest class >> kitAuthorSurface [
	"The kit-author SDK, beyond the check-author rows: build a kit's registrations and its recommended block."

	^ {
		{ 'PGRKit'. #class. #registrationsFrom:productionPackages:testsPackages: }.
		{ 'PGRKit'. #class. #recommendedBlock }.
		{ 'PGRRegistrationSpec'. #class. #name:kind:check: }.
		{ 'PGRRegistrationSpec'. #class. #missing:kind:reason: } }
]

{ #category : 'manifest' }
PGRSurfaceConformanceTest class >> manifest [
	"The four M1 code audiences, keyed by audience name, each mapping to its surface triples. Ordered associations so callers can read keys and values; answered fresh (no class-side state)."

	^ {
		'gate-caller' -> self gateCallerSurface.
		'check-author' -> self checkAuthorSurface.
		'kit-author' -> self kitAuthorSurface.
		'fix-invoker' -> self fixInvokerSurface }
]

{ #category : 'accessing' }
PGRSurfaceConformanceTest >> allTriples [
	"Every surface triple across the four audiences, flattened."

	^ self class manifest
		inject: OrderedCollection new
		into: [ :acc :audience | acc addAll: audience value; yourself ]
]

{ #category : 'accessing' }
PGRSurfaceConformanceTest >> resolves: aTriple [
	"Answer whether the triple's class exists and implements-or-inherits its selector on its stated side."

	| className side selector |
	className := aTriple first.
	side := aTriple second.
	selector := aTriple third.
	^ (Smalltalk globals at: className asSymbol ifAbsent: [ nil ])
		ifNil: [ false ]
		ifNotNil: [ :cls |
			side = #class
				ifTrue: [ cls class canUnderstand: selector ]
				ifFalse: [ cls canUnderstand: selector ] ]
]

{ #category : 'tests' }
PGRSurfaceConformanceTest >> testErrorSurfaceClassesAreCatchableByClass [
	"D-49: each error-vocabulary class resolves and inherits from Error, so callers may catch by class."

	self class errorClassNames do: [ :name |
		(Smalltalk globals at: name asSymbol ifAbsent: [ nil ])
			ifNil: [ self assert: false description: name , ' — error class absent' ]
			ifNotNil: [ :cls |
				self
					assert: (cls inheritsFrom: Error)
					description: name , ' does not inherit from Error' ] ]
]

{ #category : 'tests' }
PGRSurfaceConformanceTest >> testEverySurfaceSelectorExistsWithRightArity [
	"ch. 9 §9.1: every manifest triple resolves against the loaded image on its stated side, every failing row named in the description; and the sweep visited >= 40 triples (nonzero-scan guard — the M1 roster is 41)."

	| triples failures |
	triples := self allTriples.
	self
		assert: triples size >= 40
		description: 'nonzero-scan guard: only ' , triples size printString , ' triples swept'.
	failures := triples reject: [ :each | self resolves: each ].
	self
		assert: failures isEmpty
		description: 'unresolved surface rows: '
			, (failures
				inject: ''
				into: [ :acc :t |
					acc , String cr , t first , ' · ' , t second asString , ' · ' , t third asString ])
]

{ #category : 'tests' }
PGRSurfaceConformanceTest >> testManifestSpansTheFourCodeSurfacesAtM1 [
	"The M1-form pin: exactly the four code audiences present and each non-empty, and no config-author code member yet (E12's draftFor: cut amends this by schedule)."

	| audiences |
	audiences := self class manifest collect: [ :each | each key ].
	self
		assert: audiences asSet
		equals: (Set withAll: #( 'gate-caller' 'check-author' 'kit-author' 'fix-invoker' )).
	self class manifest do: [ :each | self deny: each value isEmpty ].
	self deny: (audiences includes: 'config-author')
]
