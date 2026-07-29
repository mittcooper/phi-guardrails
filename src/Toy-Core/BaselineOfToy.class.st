"
The toy adopter's own baseline (spec ch. 8 par. 8.2), defined inside Toy-Core so it needs no package of its own - it is introspected, never Metacello-loaded in v1 (the BaselineOfPCKFixture precedent). Under D-45 it declares no role groups: the toy's artifact assigns roles by matcher, which is how the toy demonstrates R-47 - adoption changed nothing in the adopted project's baseline.
"
Class {
	#name : 'BaselineOfToy',
	#superclass : 'BaselineOf',
	#category : 'Toy-Core',
	#package : 'Toy-Core'
}

{ #category : 'artifact' }
BaselineOfToy class >> guardrailsSTON [
	"The toy adopter's own configuration artifact - spec ch. 1 par. 1.1's example verbatim, minus that rendering's reader-only annotation quotes (the committed toy artifact, D-45/D-51). Answered as class-side STON text (ch. 8 par. 8.2) because the repo root's guardrails.ston is the framework's own; the demo (E14) reads this with PGRConfiguration fromString:. A fromString: config has no directory, so the artifact declares no #src and registers no dead-src check (D-45). It carries no STON comments - STON's comment support is unverified and nothing may depend on it (P5)."
	^ '{
	#schemaVersion : 2,
	#project : ''Toy'',
	#baseline : ''BaselineOfToy'',
	#roles : {
		#production : [ ''Toy-(Core|UI|Persistence|Rules)'' ],
		#tests : [ ''Toy-Tests'' ] },
	#kits : [ {
		#kit : ''PCKKit'',
		#lintRules : [ ''PCKNoIsNilIfTrueRule'',
			''ReCodeCruftLeftInMethodsRule'',
			''ToyNoIsNilIfFalseRule'' ],
		#architectureChecks : [ ''PCKLayerMapCheck'' ],
		#layerMap : {
			#layers : {
				''ui'' : [ ''Toy-UI'' ],
				''domain'' : [ ''Toy-Core'' ],
				''persistence'' : [ ''Toy-Persistence'' ] },
			#allowed : [ [ ''ui'', ''domain'' ], [ ''domain'', ''persistence'' ] ],
			#unlayered : [ ''Toy-Rules'' ] },
		#metaRules : [ ''PCKNoSkippedTestsMetaRule'' ] } ]
}'
]

{ #category : 'baselines' }
BaselineOfToy >> baseline: spec [
	<baseline>
	spec for: #common do: [
		spec
			package: 'Toy-Core';
			package: 'Toy-UI';
			package: 'Toy-Persistence';
			package: 'Toy-Rules';
			package: 'Toy-Tests' ]
]
