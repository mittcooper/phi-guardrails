"
The parsed, validated configuration artifact - the one scope of a gate run (spec ch. 1 par. 1.2). Class-side fromString: and fromFile: are the public caller surface; instance readers are internal to the framework and carry no compatibility promise. Validation is strict: malformed or unknown input signals PGRConfigurationError, never a silent default (P-CFG-STRICT). The pipeline lands across C21-C27; stages so far: 1 strict STON parse, 2 envelope shape law, 3 schema-version law (parse set exactly {2}, D-45/D-51), 4 kit and baseline resolution (class-side conformance for kits, never ancestry, D-53; inheritsFrom: BaselineOf for the baseline, D-25.a), 5 role-matcher expansion over the resolved baseline (group name first - membership pre-checked - else exact package name, else full-match pattern, D-47/D-15; zero-match legal; the group-vs-package ambiguity is unconstructible, D-70), 6 the scope law plus loadedness - every package the baseline declares in exactly one role, pairwise disjoint and jointly total (D-25 as amended by D-45), production- and tests-role packages loaded in the image, an absent exempt package legal (D-25.a), 7 exempt-name patterns when #exemptNamePatterns is present - every exempt-role package full-matches some pattern and no production- or tests-role package full-matches any (D-15 full-match; D-25 residual 1: misfiling is loud), an absent key meaning no check at all, 8 the #src anchor - absent legal, absolute recorded verbatim, relative resolved against the config file's own directory via fromFile: and refused naming the fix via fromString: (D-45 rulings 1-2, D-47 flag 2). Kit blocks are opaque beyond #kit and handed on verbatim (D-51).
"
Class {
	#name : 'PGRConfiguration',
	#superclass : 'Object',
	#instVars : [
		'project',
		'kitBlocks',
		'kitClasses',
		'baselineClass',
		'productionPackageNames',
		'testsPackageNames',
		'exemptPackageNames',
		'srcPath'
	],
	#category : 'Phi-Guardrails-Core',
	#package : 'Phi-Guardrails-Core'
}

{ #category : 'private' }
PGRConfiguration class >> currentSchemaVersion [
	"The one statement of the gate's own schema version - it writes and reads exactly 2; every schema change bumps it (D-49). Internal."
	^ 2
]

{ #category : 'private' }
PGRConfiguration class >> expand: aMatcher over: aVersion [
	"Resolution order as ratified (D-47): group name first, else exact package name, else full-match pattern. The group arm pre-checks membership because packagesForSpecNamed: silently answers empty for an unknown name (the D-25.a trap); a group-vs-package name collision is unconstructible - Metacello itself refuses declaring it (D-70). Group members are answered in baseline declaration order."
	| declaredNames groupMemberNames |
	declaredNames := aVersion packages collect: [ :each | each name ].
	(aVersion groups anySatisfy: [ :each | each name = aMatcher ]) ifTrue: [
		groupMemberNames := ((aVersion packagesForSpecNamed: aMatcher) collect: [ :each | each name ]) asSet.
		^ declaredNames select: [ :name | groupMemberNames includes: name ] ].
	(declaredNames includes: aMatcher) ifTrue: [ ^ Array with: aMatcher ].
	^ self select: declaredNames fullMatching: aMatcher
]

{ #category : 'private' }
PGRConfiguration class >> expandMatchers: matcherArray over: aVersion [
	"One role: matcher order first, baseline declaration order within one matcher, dedup within the role. A matcher expanding to zero packages is legal (D-47) - its consequences are the scope law's business (C25), not this stage's."
	| names |
	names := OrderedCollection new.
	matcherArray do: [ :matcher |
		(self expand: matcher over: aVersion) do: [ :name |
			(names includes: name) ifFalse: [ names add: name ] ] ].
	^ names asArray
]

{ #category : 'private' }
PGRConfiguration class >> expandRoles: rolesMap over: aBaselineClass [
	"Stage 5, role-matcher expansion over the resolved baseline (spec ch. 1 par. 1.1): assignment from the configuration, inventory from the baseline (D-45). Answers the three expanded package-name Arrays ordered production, tests, exempt; an absent #exempt is an empty role."
	| version |
	version := aBaselineClass project version.
	^ #( production tests exempt ) collect: [ :role |
		self expandMatchers: (rolesMap at: role ifAbsent: [ #(  ) ]) over: version ]
]

{ #category : 'instance creation' }
PGRConfiguration class >> fromFile: aPathString [
	"Answer the validated configuration parsed from the file at aPathString, or signal PGRConfigurationError. The explicit path is all there is - no default location, no working-directory fallback (D-45 ruling 1); a missing or unreadable file is a configuration error naming the path, never a raw file exception - callers catch configuration defects by class (D-49)."
	| file contents |
	file := aPathString asFileReference.
	contents := [ file contents ]
		on: FileException
		do: [ :error | PGRConfigurationError new signal: 'Cannot read configuration file: ' , aPathString ].
	^ self fromString: contents anchor: file parent
]

{ #category : 'instance creation' }
PGRConfiguration class >> fromString: aString [
	"Answer the validated configuration parsed from aString, or signal PGRConfigurationError."
	^ self fromString: aString anchor: nil
]

{ #category : 'private' }
PGRConfiguration class >> fromString: aString anchor: aDirectoryOrNil [
	"The one validation pipeline behind both frozen entries, stages 1-8 (one validation path, two entries); the anchor is the config file's own directory via fromFile:, nil via fromString:."
	| map baselineClass expandedRoles |
	map := self parsedMapFrom: aString.
	self validateEnvelope: map.
	self validateSchemaVersion: map.
	baselineClass := self resolveBaselineClass: (map at: #baseline).
	expandedRoles := self expandRoles: (map at: #roles) over: baselineClass.
	self validateScopeLaw: expandedRoles over: baselineClass.
	self validateExemptNamePatterns: map roles: expandedRoles.
	^ self new
		setProject: (map at: #project)
			kitBlocks: (map at: #kits)
			kitClasses: (self resolveKitClasses: (map at: #kits))
			baselineClass: baselineClass;
		setProductionPackageNames: (expandedRoles at: 1)
			testsPackageNames: (expandedRoles at: 2)
			exemptPackageNames: (expandedRoles at: 3);
		setSrcPath: (self resolveSrc: map anchor: aDirectoryOrNil);
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
PGRConfiguration class >> resolveSrc: aMap anchor: aDirectoryOrNil [
	"Stage 8, the #src anchor rules (spec ch. 1 par. 1.1): absent is nothing to do - a consuming check goes missing at run time, the par. 1.5 pattern (E11); absolute is recorded as-is; relative resolves against the config file's own directory (D-45 ruling 2), and with no directory to anchor to the error names the fix (D-47 flag 2). Whether the directory exists is not checked - the walk that consumes it judges that at run time."
	| src |
	src := aMap at: #src ifAbsent: [ ^ nil ].
	src asFileReference isAbsolute ifTrue: [ ^ src ].
	aDirectoryOrNil ifNil: [
		PGRConfigurationError new signal: 'Relative #src ' , src printString , ' cannot be anchored via fromString: - use an absolute path, or load the file via fromFile:' ].
	^ (aDirectoryOrNil / src) fullName
]

{ #category : 'private' }
PGRConfiguration class >> select: nameCollection fullMatching: aMatcher [
	"Full-match regex semantics (D-15: 'XSUnit-Tests' matchesRegex: 'SUnit-.*' is false). A matcher the regex engine rejects is a loud configuration error naming it - no engine exception escapes fromString: (family 7)."
	^ [ nameCollection select: [ :name | name matchesRegex: aMatcher ] ]
		on: RegexError
		do: [ :error | PGRConfigurationError new signal: 'Invalid role matcher regex: ' , aMatcher ]
]

{ #category : 'private' }
PGRConfiguration class >> selectNames: nameCollection fullMatchingExemptNamePattern: aPattern [
	"Same regex-wrap rule as the stage-5 matchers (family 7): an exempt-name pattern the engine rejects is a loud configuration error naming it - no engine exception escapes fromString:. Full-match semantics (D-15)."
	^ [ nameCollection select: [ :name | name matchesRegex: aPattern ] ]
		on: RegexError
		do: [ :error | PGRConfigurationError new signal: 'Invalid exempt-name pattern regex: ' , aPattern ]
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
PGRConfiguration class >> validateExemptNamePatterns: aMap roles: expandedRoles [
	"Stage 7, #exemptNamePatterns in both directions (spec ch. 1 par. 1.1; R-24 validation half): absent means no check at all; present, every exempt-role package full-matches at least one exempt-name pattern (direction 1) and no production- or tests-role package full-matches any (direction 2 - a misfiled package is loud, D-25 residual 1). Arm order direction 1 then direction 2 is fixed so the error messages stay deterministic; every offender is named (family 7)."
	aMap at: #exemptNamePatterns ifPresent: [ :patternArray |
		| matchedExempt misfiled |
		matchedExempt := Set new.
		misfiled := OrderedCollection new.
		patternArray do: [ :aPattern |
			matchedExempt addAll: (self selectNames: (expandedRoles at: 3) fullMatchingExemptNamePattern: aPattern).
			(self selectNames: (expandedRoles at: 1) , (expandedRoles at: 2) fullMatchingExemptNamePattern: aPattern)
				do: [ :name | (misfiled includes: name) ifFalse: [ misfiled add: name ] ] ].
		((expandedRoles at: 3) reject: [ :name | matchedExempt includes: name ]) ifNotEmpty: [ :unmatched |
			PGRConfigurationError new signal: 'Exempt packages full-matching no exempt-name pattern: ' , (', ' join: unmatched) ].
		misfiled ifNotEmpty: [
			PGRConfigurationError new signal: 'Production or tests packages full-matching an exempt-name pattern: ' , (', ' join: misfiled) ] ]
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
PGRConfiguration class >> validateRoleCoverage: expandedRoles over: declaredNames [
	"Coverage arm: every package the baseline itself declares sits in some role - with disjointness, in exactly one: the scope law (D-25 as amended by D-45). An unassigned new package is a loud failure here, never unguarded code; dependency-project packages are out of scope (spec ch. 1 par. 1.1)."
	| assigned uncovered |
	assigned := Set new.
	expandedRoles do: [ :roleNames | assigned addAll: roleNames ].
	uncovered := declaredNames reject: [ :name | assigned includes: name ].
	uncovered ifNotEmpty: [
		PGRConfigurationError new signal: 'Packages assigned to no role: ' , (', ' join: uncovered) ]
]

{ #category : 'private' }
PGRConfiguration class >> validateRoleDisjointness: expandedRoles [
	"Disjointness arm: no package name in more than one expanded role; every offender is named (family 7). Within-role duplicates cannot reach here - stage 5 dedups per role."
	| seen duplicated |
	seen := Set new.
	duplicated := OrderedCollection new.
	expandedRoles do: [ :roleNames |
		roleNames do: [ :name |
			(seen includes: name)
				ifTrue: [ (duplicated includes: name) ifFalse: [ duplicated add: name ] ]
				ifFalse: [ seen add: name ] ] ].
	duplicated ifNotEmpty: [
		PGRConfigurationError new signal: 'Packages assigned to more than one role: ' , (', ' join: duplicated) ]
]

{ #category : 'private' }
PGRConfiguration class >> validateRoleLoadedness: expandedRoles [
	"Loadedness arm: every production- and tests-role package is loaded in the image (D-15 spelling). The exempt role is skipped by construction - no check ever targets an exempt package, so baseline introspection alone suffices for it (D-25.a)."
	| missing |
	missing := ((expandedRoles at: 1) , (expandedRoles at: 2)) select: [ :name |
		(PackageOrganizer default packageNamed: name ifAbsent: [ nil ]) isNil ].
	missing ifNotEmpty: [
		PGRConfigurationError new signal: 'Role packages not loaded in the image: ' , (', ' join: missing) ]
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
PGRConfiguration class >> validateScopeLaw: expandedRoles over: aBaselineClass [
	"Stage 6, the scope law plus loadedness (spec ch. 1 par. 1.1). Arm order disjointness - coverage - loadedness is fixed so the error messages stay deterministic."
	self validateRoleDisjointness: expandedRoles.
	self validateRoleCoverage: expandedRoles
		over: (aBaselineClass project version packages collect: [ :each | each name ]).
	self validateRoleLoadedness: expandedRoles
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
PGRConfiguration >> exemptPackageNames [
	"The #exempt role expanded to package names - derived from the baseline at validation time (spec ch. 1 par. 1.3); empty when the artifact carries no #exempt. Specified but internal; answers a fresh copy (R-35)."
	^ exemptPackageNames copy
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
PGRConfiguration >> productionPackageNames [
	"The #production role expanded to package names - derived from the baseline at validation time (spec ch. 1 par. 1.3). Specified but internal; answers a fresh copy (R-35)."
	^ productionPackageNames copy
]

{ #category : 'accessing' }
PGRConfiguration >> project [
	"The project display name, verbatim from the artifact."
	^ project
]

{ #category : 'private' }
PGRConfiguration >> setProductionPackageNames: productionArray testsPackageNames: testsArray exemptPackageNames: exemptArray [
	productionPackageNames := productionArray.
	testsPackageNames := testsArray.
	exemptPackageNames := exemptArray
]

{ #category : 'private' }
PGRConfiguration >> setProject: aString kitBlocks: blockArray kitClasses: classArray baselineClass: aClass [
	project := aString.
	kitBlocks := blockArray.
	kitClasses := classArray.
	baselineClass := aClass
]

{ #category : 'private' }
PGRConfiguration >> setSrcPath: aStringOrNil [
	srcPath := aStringOrNil
]

{ #category : 'accessing' }
PGRConfiguration >> srcPath [
	"The #src source root as an absolute path String, nil when the artifact carries no #src. Specified but internal - E11's src-inventory wiring consumes it; whether it exists is judged by the walk at run time (R-47)."
	^ srcPath
]

{ #category : 'accessing' }
PGRConfiguration >> testsPackageNames [
	"The #tests role expanded to package names - derived from the baseline at validation time (spec ch. 1 par. 1.3). Specified but internal; answers a fresh copy (R-35)."
	^ testsPackageNames copy
]
