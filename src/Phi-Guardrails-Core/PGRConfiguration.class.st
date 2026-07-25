"
The parsed, validated configuration artifact - the one scope of a gate run (spec ch. 1 par. 1.2). Class-side fromString: is the public caller surface; instance readers are internal to the framework and carry no compatibility promise. Validation is strict: malformed or unknown input signals PGRConfigurationError, never a silent default (P-CFG-STRICT). The pipeline lands across C21-C27; stages so far: 1 strict STON parse, 2 envelope shape law, 3 schema-version law (parse set exactly {2}, D-45/D-51), 4 kit and baseline resolution (class-side conformance for kits, never ancestry, D-53; inheritsFrom: BaselineOf for the baseline, D-25.a). Kit blocks are opaque beyond #kit and handed on verbatim (D-51).
"
Class {
	#name : 'PGRConfiguration',
	#superclass : 'Object',
	#instVars : [
		'project',
		'kitBlocks',
		'kitClasses',
		'baselineClass'
	],
	#category : 'Phi-Guardrails-Core',
	#package : 'Phi-Guardrails-Core'
}

{ #category : 'private' }
PGRConfiguration class >> currentSchemaVersion [
	"The one statement of the gate's own schema version - it writes and reads exactly 2; every schema change bumps it (D-49). Internal."
	^ 2
]

{ #category : 'instance creation' }
PGRConfiguration class >> fromString: aString [
	"Answer the validated configuration parsed from aString, or signal PGRConfigurationError."
	| map |
	map := self parsedMapFrom: aString.
	self validateEnvelope: map.
	self validateSchemaVersion: map.
	^ self new
		setProject: (map at: #project)
		kitBlocks: (map at: #kits)
		kitClasses: (self resolveKitClasses: (map at: #kits))
		baselineClass: (self resolveBaselineClass: (map at: #baseline));
		yourself
]

{ #category : 'private' }
PGRConfiguration class >> parsedMapFrom: aString [
	"Stage 1, strict parse. STONReaderError never escapes: callers catch configuration defects by class (D-49)."
	^ [ STON fromString: aString ]
		on: STONReaderError
		do: [ :error | PGRConfigurationError new signal: 'Malformed STON: ' , error description ]
]

{ #category : 'private' }
PGRConfiguration class >> resolveBaselineClass: aName [
	"Stage 4, baseline arm: the name resolves to a loaded BaselineOf subclass - inheritsFrom: is the ruled contract check here (D-25.a)."
	| baselineClass |
	baselineClass := Smalltalk classNamed: aName.
	baselineClass ifNil: [ PGRConfigurationError new signal: 'Unknown baseline class: ' , aName ].
	(baselineClass inheritsFrom: BaselineOf) ifFalse: [
		PGRConfigurationError new signal: aName , ' is not a BaselineOf subclass' ].
	^ baselineClass
]

{ #category : 'private' }
PGRConfiguration class >> resolveKitClassNamed: aName [
	"Conformance, not ancestry (D-53): the class answers respondsTo: for both frozen class-side kit-protocol selectors - never inheritsFrom: PGRKit, so a duck-typed plain class resolves fine. Resolution stops here; sending the protocol is the registry's (E04)."
	| kitClass |
	kitClass := Smalltalk classNamed: aName.
	kitClass ifNil: [ PGRConfigurationError new signal: 'Unknown kit class: ' , aName ].
	#( registrationsFrom:productionPackages:testsPackages: recommendedBlock ) do: [ :selector |
		(kitClass respondsTo: selector) ifFalse: [
			PGRConfigurationError new signal: aName , ' does not answer the class-side kit-protocol selector ' , selector printString ] ].
	^ kitClass
]

{ #category : 'private' }
PGRConfiguration class >> resolveKitClasses: kitBlockArray [
	"Stage 4, kit arm (spec ch. 1 par. 1.4 step 1): every block's #kit resolves to a loaded, class-side-conforming kit class. Answers the classes ordered as the blocks, parallel to kitBlocks."
	^ kitBlockArray collect: [ :block | self resolveKitClassNamed: (block at: #kit) ]
]

{ #category : 'private' }
PGRConfiguration class >> shapeErrorFor: aKey expected: aDescription [
	PGRConfigurationError new signal: 'Top-level key ' , aKey , ' must be ' , aDescription
]

{ #category : 'private' }
PGRConfiguration class >> validateEnvelope: anObject [
	"Stage 2, the envelope shape law (spec ch. 1 par. 1.1): one map with Symbol keys, the five core keys present, no unknown top-level key, every core key well-shaped."
	self validateTopLevelMap: anObject.
	self validateKeySet: anObject.
	self validateShapes: anObject
]

{ #category : 'private' }
PGRConfiguration class >> validateKeySet: aMap [
	"The five core keys are required; #src and #exemptNamePatterns are the only optional keys; there are no other top-level keys (D-51)."
	#( schemaVersion project kits baseline roles ) do: [ :key |
		(aMap includesKey: key) ifFalse: [
			PGRConfigurationError new signal: 'Missing required top-level key: ' , key ] ].
	aMap keysDo: [ :key |
		(#( schemaVersion project kits baseline roles src exemptNamePatterns ) includes: key) ifFalse: [
			PGRConfigurationError new signal: 'Unknown top-level key: ' , key ] ]
]

{ #category : 'private' }
PGRConfiguration class >> validateKits: anObject [
	"A block is looked at only for #kit - everything else in it is kit-custom and opaque to the core (D-51)."
	(anObject isArray and: [ anObject isNotEmpty ]) ifFalse: [
		self shapeErrorFor: #kits expected: 'a non-empty list of kit blocks' ].
	anObject do: [ :block |
		(block isDictionary and: [ (block at: #kit ifAbsent: [ nil ]) isString ]) ifFalse: [
			PGRConfigurationError new signal: 'Every kit block must be a map carrying #kit as a String' ] ]
]

{ #category : 'private' }
PGRConfiguration class >> validateRoles: anObject [
	"Exactly a subset of #production/#tests/#exempt, with #production and #tests mandatory; String role keys compare equal to Symbols, so symbol-ness is checked explicitly."
	anObject isDictionary ifFalse: [ self shapeErrorFor: #roles expected: 'a map of role name to matcher list' ].
	#( production tests ) do: [ :role |
		(anObject includesKey: role) ifFalse: [
			PGRConfigurationError new signal: 'Missing mandatory role: ' , role ] ].
	anObject keysAndValuesDo: [ :role :matchers |
		(role isSymbol and: [ #( production tests exempt ) includes: role ]) ifFalse: [
			PGRConfigurationError new signal: 'Unknown role: ' , role printString ].
		self validateStringList: matchers for: role ]
]

{ #category : 'private' }
PGRConfiguration class >> validateSchemaVersion: aMap [
	"Stage 3, the schema-version law: the parse set is exactly {2}, not {1, 2} - the prior-shipped-versions set is empty at v1 because version 1 is the never-shipped pre-D-51 draft, refused as unknown like any other non-2 value (D-51 detail 4). The older-shipped arm of the D-49 policy activates only with the first post-2 bump. Every refusal names both versions, the artifact's and the gate's own (D-45 ruling 3)."
	| version |
	version := aMap at: #schemaVersion.
	version = self currentSchemaVersion ifFalse: [
		PGRConfigurationError new signal: 'artifact schema version ' , version printString , '; this gate reads version ' , self currentSchemaVersion printString ]
]

{ #category : 'private' }
PGRConfiguration class >> validateShapes: aMap [
	"Shape only: the schema-version value law is C22, resolution starts at C23, #src and #exemptNamePatterns semantics are C27 and C26."
	(aMap at: #schemaVersion) isInteger ifFalse: [ self shapeErrorFor: #schemaVersion expected: 'an Integer' ].
	(aMap at: #project) isString ifFalse: [ self shapeErrorFor: #project expected: 'a String' ].
	(aMap at: #baseline) isString ifFalse: [ self shapeErrorFor: #baseline expected: 'a String' ].
	self validateKits: (aMap at: #kits).
	self validateRoles: (aMap at: #roles).
	aMap at: #src ifPresent: [ :value | value isString ifFalse: [ self shapeErrorFor: #src expected: 'a String' ] ].
	aMap at: #exemptNamePatterns ifPresent: [ :value | self validateStringList: value for: #exemptNamePatterns ]
]

{ #category : 'private' }
PGRConfiguration class >> validateStringList: anObject for: aKey [
	(anObject isArray and: [ anObject allSatisfy: [ :each | each isString ] ]) ifFalse: [
		PGRConfigurationError new signal: aKey printString , ' must be a list of Strings' ]
]

{ #category : 'private' }
PGRConfiguration class >> validateTopLevelMap: anObject [
	"Pure-data STON is enforced here, not by the reader: a class-tagged top level is not a Dictionary and is refused."
	anObject isDictionary ifFalse: [
		PGRConfigurationError new signal: 'Configuration artifact top level must be a map, not ' , anObject class name ].
	anObject keysDo: [ :key |
		key isSymbol ifFalse: [
			PGRConfigurationError new signal: 'Top-level keys must be Symbols: ' , key printString ] ]
]

{ #category : 'accessing' }
PGRConfiguration >> baselineClass [
	"The resolved BaselineOf subclass. Specified but internal - E04 consumes it."
	^ baselineClass
]

{ #category : 'accessing' }
PGRConfiguration >> kitBlocks [
	"The kit blocks, ordered and verbatim - opaque maps whose only common field is #kit (D-51)."
	^ kitBlocks
]

{ #category : 'accessing' }
PGRConfiguration >> kitClasses [
	"The resolved kit classes, ordered as the #kits array and parallel to kitBlocks. Specified but internal - the registry (E04) consumes them."
	^ kitClasses
]

{ #category : 'accessing' }
PGRConfiguration >> project [
	"The project display name, verbatim from the artifact."
	^ project
]

{ #category : 'private' }
PGRConfiguration >> setProject: aString kitBlocks: blockArray kitClasses: classArray baselineClass: aClass [
	project := aString.
	kitBlocks := blockArray.
	kitClasses := classArray.
	baselineClass := aClass
]
