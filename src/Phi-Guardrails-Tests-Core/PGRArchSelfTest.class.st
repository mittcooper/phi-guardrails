"
E09-C01: the reflective architecture walls, machine-enforced before the layer-map check
exists (roadmap E09). Six SUnit tests sweep the seven production packages (and, for the
kit-edge wall, every loaded Phi-Coding-Kit* package) for the ch. 9 properties in their
reflective form: P-CORE-NEUTRAL (no engine leakage into -SDK/-Core, no client reference
anywhere), P-SDK-EDGE (kit sees only the SDK boundary), P-FIX-GATE-WALL (the gate names no
kit class), P-NO-TRANSCRIPT (no Transcript binding or #Transcript symbol), and
P-DETERMINISTIC (no Zinc/Network/Zodiac reference and no FileReference/FileSystem/FileLocator
reference outside the three ruled artifact-read sites - D-53/D-55/D-45, the B-15
reconciliation pinned live). This class is a plain test: it registers nothing (glossary -
gate-runnable things are checks). Each sweep proves itself live: a nonzero scanned count and
a known-banned witness, so a wrong ban predicate reddens rather than passing vacuously.
"
Class {
	#name : 'PGRArchSelfTest',
	#superclass : 'TestCase',
	#category : 'Phi-Guardrails-Tests-Core',
	#package : 'Phi-Guardrails-Tests-Core'
}

{ #category : 'helpers' }
PGRArchSelfTest >> assertNoOffenders: aCollection label: aLabel [
	"Empty-or-fail, with the offenders (Class>>#selector -> referenced class) in the description."
	self
		assert: aCollection isEmpty
		description: aLabel, ' -- ', (' | ' join: aCollection)
]

{ #category : 'helpers' }
PGRArchSelfTest >> definingPackageNameOf: aClass [
	"A referenced class's own defining-package name."
	^ aClass package name
]

{ #category : 'helpers' }
PGRArchSelfTest >> kitPackageNames [
	"Every loaded package whose name begins 'Phi-Coding-Kit' - tests and fixtures included
	 (the E07-recorded reading of P-SDK-EDGE)."
	^ (PackageOrganizer default packages
		select: [ :each | each name beginsWith: 'Phi-Coding-Kit' ])
		collect: [ :each | each name ]
]

{ #category : 'helpers' }
PGRArchSelfTest >> methodReferencesTranscript: aMethod [
	"True when the method carries the Transcript global binding or the plain #Transcript
	 symbol among its literals - a literals scan catches both the binding (a variable
	 binding keyed #Transcript) and the named at:put: evasion (the bare symbol)."
	^ aMethod allLiterals anySatisfy: [ :literal |
		(literal isVariableBinding and: [ literal key = #Transcript ])
			or: [ literal == #Transcript ] ]
]

{ #category : 'helpers' }
PGRArchSelfTest >> methodsInPackageNamed: aName [
	"The package's defined classes, instance and class side. A classless package (e.g.
	 Phi-Coding-Kit-Architecture at M1) contributes zero methods, never an error. Extension
	 methods a package defines on classes elsewhere are outside the contract (B-05)."
	| package methods |
	methods := OrderedCollection new.
	package := PackageOrganizer default packageNamed: aName ifAbsent: [ ^ methods ].
	package definedClasses do: [ :cls |
		methods addAll: cls methods; addAll: cls class methods ].
	^ methods
]

{ #category : 'helpers' }
PGRArchSelfTest >> methodsInPackagesNamed: aCollectionOfNames [
	^ aCollectionOfNames
		inject: OrderedCollection new
		into: [ :acc :name | acc addAll: (self methodsInPackageNamed: name); yourself ]
]

{ #category : 'helpers' }
PGRArchSelfTest >> productionMethods [
	^ self methodsInPackagesNamed: self productionPackageNames
]

{ #category : 'helpers' }
PGRArchSelfTest >> productionPackageNames [
	"The seven production packages (baseline group 'production', frozen at E01)."
	^ #(
		'Phi-Guardrails-SDK'
		'Phi-Guardrails-Core'
		'Phi-Guardrails-Gate'
		'Phi-Coding-Kit'
		'Phi-Coding-Kit-Rules'
		'Phi-Coding-Kit-Architecture'
		'Phi-Coding-Kit-Behavioral' )
]

{ #category : 'helpers' }
PGRArchSelfTest >> referenceStringFor: aMethod [
	^ aMethod methodClass name, '>>#', aMethod selector
]

{ #category : 'helpers' }
PGRArchSelfTest >> referencedClassOffendersIn: aMethodCollection banned: aBanBlock allowing: allowedReferences [
	"The generic sweep: every (method, referenced class) pair whose referenced class the ban
	 block accepts and whose defining method is not allowlisted, rendered
	 'Class>>#selector -> ReferencedClass'."
	| offenders |
	offenders := OrderedCollection new.
	aMethodCollection do: [ :method | | reference |
		reference := self referenceStringFor: method.
		(allowedReferences includes: reference) ifFalse: [
			method referencedClasses do: [ :referenced |
				(aBanBlock value: referenced) ifTrue: [
					offenders add: reference, ' -> ', referenced name ] ] ] ].
	^ offenders
]

{ #category : 'helpers' }
PGRArchSelfTest >> ruledFileAccessSelectors [
	"The allowlist for the file-triad and Zinc/Network/Zodiac arms: exactly the three ch. 9
	 ruled artifact-read sites (D-53/D-55/D-45). PCKSrcInventoryCheck - section 7.6's second
	 ruled file access, the src walk - joined at M2 needing NO entry: its walk uses
	 String-extension sends only and compiles no file-triad class literal (D-82 doc pass).
	 A future implementation needing a triad literal is a stop-and-report, never a silent
	 entry here."
	^ #(
		'PGRConfiguration class>>#fromFile:'
		'PGRGate class>>#runHeadless:'
		'PGRGate class>>#runHeadless:on:' )
]

{ #category : 'helpers' }
PGRArchSelfTest >> transcriptLivenessPlant [
	"The deliberate Transcript witness for testNoProductionMethodReferencesTranscript: its body
	 references the Transcript global so the detector has a known-positive to prove itself
	 against. This is a tests-role method, which no lint registration sweeps (D-33), and the
	 production sweep never visits it - it lives outside the seven production packages."
	^ Transcript
]

{ #category : 'tests' }
PGRArchSelfTest >> testCoreReferencesNoEngineClass [
	"P-CORE-NEUTRAL (engine half): no method in -SDK or -Core references an SUnit, Renraku, or
	 RB class. Engine prefixes are the live defining packages of the ch. 9 witnesses
	 (TestCase -> SUnit-Core, ReAbstractRule -> Renraku, RBParser/RBParseTreeRewriter ->
	 AST-Core; 'Refactoring' retained for the wider RB family)."
	| methods engineBan |
	methods := self methodsInPackagesNamed: #( 'Phi-Guardrails-SDK' 'Phi-Guardrails-Core' ).
	self assert: methods size >= 40.
	engineBan := [ :cls | #( 'SUnit' 'Renraku' 'AST-Core' 'Refactoring' )
		anySatisfy: [ :prefix | (self definingPackageNameOf: cls) beginsWith: prefix ] ].
	self assert: (engineBan value: TestCase).
	self assert: (engineBan value: ReAbstractRule).
	self assertNoOffenders: (self referencedClassOffendersIn: methods banned: engineBan allowing: #())
		label: 'engine class referenced from -SDK/-Core'
]

{ #category : 'tests' }
PGRArchSelfTest >> testGateReferencesNoKitClass [
	"P-FIX-GATE-WALL (reflective form): no method in -Gate references a class defined in any
	 Phi-Coding-Kit* package (subsumes the PCKFixCommand clause). Witness: PCKFixCommand."
	| methods kitBan |
	methods := self methodsInPackageNamed: 'Phi-Guardrails-Gate'.
	self assert: methods size >= 10.
	kitBan := [ :cls | (self definingPackageNameOf: cls) beginsWith: 'Phi-Coding-Kit' ].
	self assert: (kitBan value: PCKFixCommand).
	self assertNoOffenders: (self referencedClassOffendersIn: methods banned: kitBan allowing: #())
		label: 'kit class referenced from -Gate'
]

{ #category : 'tests' }
PGRArchSelfTest >> testKitPackagesReferenceOnlySDK [
	"P-SDK-EDGE: no method in any Phi-Coding-Kit* package references a class defined in
	 -Core or -Gate. Witness: PGRRegistry (defined in -Core)."
	| methods coreOrGateBan |
	methods := self methodsInPackagesNamed: self kitPackageNames.
	self assert: methods size >= 60.
	coreOrGateBan := [ :cls |
		#( 'Phi-Guardrails-Core' 'Phi-Guardrails-Gate' ) includes: (self definingPackageNameOf: cls) ].
	self assert: (coreOrGateBan value: PGRRegistry).
	self assertNoOffenders: (self referencedClassOffendersIn: methods banned: coreOrGateBan allowing: #())
		label: '-Core/-Gate class referenced from a kit package'
]

{ #category : 'tests' }
PGRArchSelfTest >> testNoNetworkOrStrayFileReferences [
	"P-DETERMINISTIC: (arm 1) no method references a Zinc/Network/Zodiac class except from the
	 three ruled sites, and PGRConfiguration class>>#fromFile: does reference a Zinc class (the
	 B-15 pin - so a silent future removal of the encoding-error catch is visible); (arm 2) no
	 method references FileReference/FileSystem/FileLocator outside the same allowlist."
	| methods networkBan fileTriadBan |
	methods := self productionMethods.
	self assert: methods size >= 100.
	networkBan := [ :cls | #( 'Zinc' 'Network' 'Zodiac' )
		anySatisfy: [ :prefix | (self definingPackageNameOf: cls) beginsWith: prefix ] ].
	fileTriadBan := [ :cls | #( 'FileReference' 'FileSystem' 'FileLocator' ) includes: cls name asString ].
	self assert: (networkBan value: ZnCharacterEncodingError).
	self assert: (fileTriadBan value: FileReference).
	self assertNoOffenders:
		(self referencedClassOffendersIn: methods banned: networkBan allowing: self ruledFileAccessSelectors)
		label: 'Zinc/Network/Zodiac class referenced outside the ruled sites'.
	self assert: ((PGRConfiguration class >> #fromFile:) referencedClasses
		anySatisfy: [ :cls | networkBan value: cls ]).
	self assertNoOffenders:
		(self referencedClassOffendersIn: methods banned: fileTriadBan allowing: self ruledFileAccessSelectors)
		label: 'FileReference/FileSystem/FileLocator referenced outside the ruled sites'
]

{ #category : 'tests' }
PGRArchSelfTest >> testNoProductionMethodReferencesTranscript [
	"P-NO-TRANSCRIPT: no production method carries the Transcript global binding or the
	 #Transcript symbol among its literals. Witness: this class's transcriptLivenessPlant."
	| methods offenders |
	methods := self productionMethods.
	self assert: methods size >= 100.
	self assert: (self methodReferencesTranscript: self class >> #transcriptLivenessPlant).
	offenders := (methods select: [ :method | self methodReferencesTranscript: method ])
		collect: [ :method | self referenceStringFor: method ].
	self assertNoOffenders: offenders label: 'Transcript referenced from a production method'
]

{ #category : 'tests' }
PGRArchSelfTest >> testProductionReferencesNoClientClass [
	"P-CORE-NEUTRAL (client half): no method in the seven production packages references a
	 class defined in a Toy-* package. Witness at string level ('Toy-Core' begins 'Toy-') -
	 the toy packages are classless at M1, so no class witness exists."
	| methods clientBan |
	methods := self productionMethods.
	self assert: methods size >= 100.
	clientBan := [ :cls | (self definingPackageNameOf: cls) beginsWith: 'Toy-' ].
	self assert: ('Toy-Core' beginsWith: 'Toy-').
	self assertNoOffenders: (self referencedClassOffendersIn: methods banned: clientBan allowing: #())
		label: 'client (Toy-) class referenced from a production package'
]
