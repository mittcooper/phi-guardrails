"
The init tool: authoring-time only, never run-time machinery (D-49). draftFor: inspects a
loaded baseline and composes the discovered kits' published stanzas into a proposed
guardrails.ston text for a human to review, edit, and save - it answers text and writes no
file. It is homed in Phi-Guardrails-Core (D-53.6) and lives on the config-author surface;
PGRConfiguration is the run-time counterpart and this class never wires into it (D-45 ruling
4: generation may guess, the run-time gate may never infer). Compose fresh per call - no
class-side state (R-35).

Two boundaries are guesses, stated here as the constraints the code cannot show:

- Kit discovery: the composition population is PGRKit allSubclasses whose class side itself
  implements #recommendedBlock (the per-class includesSelector: probe, D-82 - never true for a
  subclass that merely inherits the skeleton's subclassResponsibility hook), sorted by class
  name for determinism. Anchoring on the SDK skeleton is deliberate: an image-wide
  protocol-conformance scan is polluted by duck-typed scratch kits (probes.md P4). A duck-typed
  kit - conformance, not ancestry, is what registration needs (D-53) - is simply not
  discovered; its author composes its stanza by hand (ordinary authoring).

- Role assignment: introspect the loaded baseline's declared packages; a package whose name
  full-matches '.*-Tests(-.*)?' is a tests-role package, every other a production-role package.
  Each role lists its package names explicitly (a guess should be literally reviewable) - no
  group names, no patterns, so the drafted file works for a baseline with no groups at all.

The envelope keys are the frozen version-2 schema (#schemaVersion #project #baseline #roles
#kits); #src, #exempt/#exemptNamePatterns, #layerMap and #architectureChecks are the human's
ground, deliberately absent (the tool cannot know them). #project is the baseline name minus a
leading 'BaselineOf' (a guess). A name that does not resolve to a loaded BaselineOf subclass
raises PGRConfigurationError naming it - a loud failure over a silent default (constitution,
family 7).
"
Class {
	#name : 'PGRConfigurationDraft',
	#superclass : 'Object',
	#category : 'Phi-Guardrails-Core',
	#package : 'Phi-Guardrails-Core'
}

{ #category : 'private' }
PGRConfigurationDraft class >> discoveredKitsIn: aBaselineClass [
	"The composition population (a guess, D-45 ruling 4): PGRKit subclasses whose class side
	itself implements #recommendedBlock - the per-class includesSelector: probe (D-82), which
	never answers true for a subclass merely inheriting the skeleton's hook. Sorted by class
	name for determinism. The baseline argument is unused today - a wider, baseline-scoped
	discovery is a decision-sheet entry, not a silent widening (probes.md P4)."

	^ (PGRKit allSubclasses
		select: [ :each | each class includesSelector: #recommendedBlock ])
		asSortedCollection: [ :a :b | a name <= b name ]
]

{ #category : 'generating' }
PGRConfigurationDraft class >> draftFor: aBaselineName [
	"Answer draft guardrails.ston text (a String) for the loaded baseline named aBaselineName,
	for human review - draft-only, writes no file (D-49). Signals PGRConfigurationError naming
	the baseline when the name does not resolve to a loaded BaselineOf subclass."

	| baselineClass packageNames productionNames testsNames |
	baselineClass := self resolveBaselineNamed: aBaselineName.
	packageNames := baselineClass project version packages
		collect: [ :each | each name ].
	testsNames := (packageNames select: [ :name | name matchesRegex: '.*-Tests(-.*)?' ])
		asSortedCollection asArray.
	productionNames := (packageNames reject: [ :name | name matchesRegex: '.*-Tests(-.*)?' ])
		asSortedCollection asArray.
	^ self
		textForProject: (self projectNameFrom: aBaselineName)
		baseline: aBaselineName
		production: productionNames
		tests: testsNames
		kits: (self discoveredKitsIn: baselineClass)
]

{ #category : 'private' }
PGRConfigurationDraft class >> projectNameFrom: aBaselineName [
	"The #project guess (D-45 ruling 4): the baseline name minus a leading 'BaselineOf'
	prefix ('BaselineOfToy' -> 'Toy'); a name without the prefix is taken verbatim."

	^ (aBaselineName beginsWith: 'BaselineOf')
		ifTrue: [ aBaselineName allButFirst: 'BaselineOf' size ]
		ifFalse: [ aBaselineName ]
]

{ #category : 'private' }
PGRConfigurationDraft class >> quotedListOf: nameCollection [
	"A STON string-literal list of the names, in the handed order."

	^ String streamContents: [ :s |
		s << '[ '.
		nameCollection doWithIndex: [ :name :i |
			i > 1 ifTrue: [ s << ', ' ].
			s << '''' << name << '''' ].
		s << ' ]' ]
]

{ #category : 'private' }
PGRConfigurationDraft class >> resolveBaselineNamed: aName [
	"The strict-input arm: aName must resolve to a loaded BaselineOf subclass - inheritsFrom:
	BaselineOf is the ruled subclass probe (D-25.a). An unknown name, or a resolved
	non-BaselineOf class, raises PGRConfigurationError naming aName (family 7: loud, never a
	silent default)."

	| baselineClass |
	baselineClass := Smalltalk classNamed: aName.
	(baselineClass notNil and: [ baselineClass inheritsFrom: BaselineOf ]) ifFalse: [
		PGRConfigurationError new signal: 'Unknown baseline class: ' , aName ].
	^ baselineClass
]

{ #category : 'private' }
PGRConfigurationDraft class >> textForProject: projectName baseline: baselineName production: productionNames tests: testsNames kits: kitClasses [
	"Assemble the version-2 draft text: the five envelope keys, each role listing its package
	names explicitly, and each discovered kit's recommendedBlock text spliced verbatim into
	#kits (D-54.3: single-sourced on the kit class). STON is whitespace-insensitive; the
	layout is for the human reader."

	^ String streamContents: [ :s |
		s << '{'; cr.
		s << '	#schemaVersion : 2,'; cr.
		s << '	#project : ''' << projectName << ''','; cr.
		s << '	#baseline : ''' << baselineName << ''','; cr.
		s << '	#roles : {'; cr.
		s << '		#production : ' << (self quotedListOf: productionNames) << ','; cr.
		s << '		#tests : ' << (self quotedListOf: testsNames) << ' },'; cr.
		s << '	#kits : ['.
		kitClasses doWithIndex: [ :kitClass :i |
			i > 1 ifTrue: [ s << ',' ].
			s << String cr << kitClass recommendedBlock ].
		s << ' ]'; cr.
		s << '}' ]
]
