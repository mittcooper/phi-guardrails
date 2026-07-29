"
Check-level witnesses that all six of the toy's planted violations (E12-C03, spec ch. 8
§8.2) are live, committed red - so committed-red is a machine fact, not prose (R-37/P1).
Lives in the swept Phi-Guardrails-Tests-Toy and asserts at check/checker level only,
never by running a gate over the toy's configuration (gate-level red->fixed->green is
E14's ToyDemoTest; not pre-built here, D-43/§8.3). The witnesses themselves are plain,
all-green tests: the plants are the toy's, not this suite's.

Three lint plants are witnessed by constructing the frozen kit check directly over the
production-role Toy-Core (§2.3, D-33); the architecture plant through the frozen kit
contract (PCKKit registrationsFrom:productionPackages:testsPackages:), filtering to the
'architecture/PCKLayerMapCheck' spec and running its check; the two behavioral plants by
running ToyOrderTest's suite and reading the probed result counts (probes.md P3). The
nested toy suite run terminates - nothing in Toy-Tests drives a gate (E07 precedent).
"
Class {
	#name : 'PGRToyPlantWitnessTest',
	#superclass : 'TestCase',
	#category : 'Phi-Guardrails-Tests-Toy',
	#package : 'Phi-Guardrails-Tests-Toy'
}

{ #category : 'fixtures' }
PGRToyPlantWitnessTest >> toyKitBlock [
	"The toy's coding-kit block (digest item 2, frozen E10 config-author surface): the
	PCKLayerMapCheck architecture registration plus the toy's layer map (ui/domain/
	persistence over the toy packages, ui->domain and domain->persistence allowed,
	Toy-Rules unlayered). Built as STON parses it - Symbol block keys, Dictionary maps."
	| layers layerMap |
	layers := Dictionary new
		at: 'ui' put: #( 'Toy-UI' );
		at: 'domain' put: #( 'Toy-Core' );
		at: 'persistence' put: #( 'Toy-Persistence' );
		yourself.
	layerMap := Dictionary new
		at: #layers put: layers;
		at: #allowed put: { { 'ui'. 'domain' }. { 'domain'. 'persistence' } };
		at: #unlayered put: #( 'Toy-Rules' );
		yourself.
	^ Dictionary new
		at: #kit put: 'PCKKit';
		at: #architectureChecks put: #( 'PCKLayerMapCheck' );
		at: #layerMap put: layerMap;
		yourself
]

{ #category : 'tests' }
PGRToyPlantWitnessTest >> testCodeCruftPlantIsCaught [
	"The Toy-Core `Transcript show:` plant fires the built-in cruft rule (§8.2 row 2)."
	| verdict |
	verdict := (PCKLintRuleCheck rule: ReCodeCruftLeftInMethodsRule packages: #( 'Toy-Core' )) run.
	self deny: verdict isGreen.
	self assert: (verdict findings anySatisfy: [ :each |
		each target = 'ToyOrder>>#logTotal' ])
]

{ #category : 'tests' }
PGRToyPlantWitnessTest >> testFailingAndSkipPlantsAreLive [
	"The two Toy-Tests behavioral plants are live and are exactly the declared two: one
	failure, one skip, no error (probes.md P3 result protocol; §8.2 rows 5-6)."
	| result |
	result := ToyOrderTest suite run.
	self assert: result failureCount equals: 1.
	self assert: result skippedCount equals: 1.
	self assert: result errorCount equals: 0
]

{ #category : 'tests' }
PGRToyPlantWitnessTest >> testForbiddenUiReferenceIsCaught [
	"The Toy-UI -> Toy-Persistence plant fires PCKLayerMapCheck, reached through the frozen
	kit contract (never the internal layerMap: constructor); the finding names the method
	and the referenced persistence class (§8.2 row 4, E10 finding shape)."
	| specs spec verdict |
	specs := PCKKit
		registrationsFrom: self toyKitBlock
		productionPackages: #( 'Toy-Core' 'Toy-Persistence' 'Toy-Rules' 'Toy-UI' )
		testsPackages: #( 'Toy-Tests' ).
	spec := specs detect: [ :each | each name = 'architecture/PCKLayerMapCheck' ].
	verdict := spec check run.
	self deny: verdict isGreen.
	self assert: (verdict findings anySatisfy: [ :each |
		each target = 'ToyOrderView>>#storeSnapshot'
			and: [ each message includesSubstring: 'ToyOrderStore' ] ])
]

{ #category : 'tests' }
PGRToyPlantWitnessTest >> testIsNilIfTruePlantIsCaught [
	"The Toy-Core `isNil ifTrue:` plant fires the catalog rule, exactly once (§8.2 row 1)."
	| verdict matching |
	verdict := (PCKLintRuleCheck rule: PCKNoIsNilIfTrueRule packages: #( 'Toy-Core' )) run.
	self deny: verdict isGreen.
	matching := verdict findings select: [ :each | each target = 'ToyOrder>>#totalOrZero' ].
	self assert: matching size equals: 1
]

{ #category : 'tests' }
PGRToyPlantWitnessTest >> testToyRulePlantIsCaught [
	"The Toy-Core `isNil ifFalse:` plant fires the toy's own extension rule, exactly once;
	the production-scoped run never reaches C02's bad fixture in Toy-Tests (§8.2 row 3)."
	| verdict matching |
	verdict := (PCKLintRuleCheck rule: ToyNoIsNilIfFalseRule packages: #( 'Toy-Core' )) run.
	self deny: verdict isGreen.
	matching := verdict findings select: [ :each | each target = 'ToyOrder>>#itemCountOrZero' ].
	self assert: matching size equals: 1.
	"The run is production-scoped: it must NOT reach C02's bad fixture in Toy-Tests -
	so the whole verdict is exactly that one finding, not merely one that matches."
	self assert: verdict findings size equals: 1
]
