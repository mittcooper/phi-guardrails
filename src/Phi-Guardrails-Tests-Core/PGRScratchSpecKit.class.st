"
E04-C01 scratch fixture - the data-driven obedient kit every E04 registry test drives: a duck-typed plain Object subclass (D-53), class-side only and stateless, answering one PGRRegistrationSpec per entry of the block's #specs list, in entry order (D-54). Entry arms: #check names a class to instantiate via packages: with the production names (D-60); #missing answers a missing spec with the entry's reason; #echoRoles answers a missing spec whose reason is the received role lists verbatim - the C03 handoff witness, echoing instead of capturing state. Deliberately no block validation: strictness inside blocks is kit-side ground (E06/E07), and block opacity to the core is what the registry tests witness (D-51). Entries outside the three arms are undefined - the fixture models obedience, not strictness.
"
Class {
	#name : 'PGRScratchSpecKit',
	#superclass : 'Object',
	#category : 'Phi-Guardrails-Tests-Core',
	#package : 'Phi-Guardrails-Tests-Core'
}

{ #category : 'accessing' }
PGRScratchSpecKit class >> recommendedBlock [
	^ '{ #kit : ''PGRScratchSpecKit'' }'
]

{ #category : 'registering' }
PGRScratchSpecKit class >> registrationsFrom: aBlock productionPackages: productionNames testsPackages: testsNames [
	^ (aBlock at: #specs ifAbsent: [ #(  ) ])
		collect: [ :entry | self specFor: entry productionPackages: productionNames testsPackages: testsNames ]
		as: OrderedCollection
]

{ #category : 'private' }
PGRScratchSpecKit class >> specFor: entry productionPackages: productionNames testsPackages: testsNames [
	(entry includesKey: #check) ifTrue: [
		^ PGRRegistrationSpec
			name: (entry at: #name)
			kind: (entry at: #kind) asSymbol
			check: ((Smalltalk classNamed: (entry at: #check)) packages: productionNames) ].
	(entry includesKey: #missing) ifTrue: [
		^ PGRRegistrationSpec
			missing: (entry at: #name)
			kind: (entry at: #kind) asSymbol
			reason: (entry at: #missing) ].
	(entry includesKey: #echoRoles) ifTrue: [
		^ PGRRegistrationSpec
			missing: (entry at: #name)
			kind: (entry at: #kind) asSymbol
			reason: 'production: ' , (', ' join: productionNames) , ' | tests: ' , (', ' join: testsNames) ].
	^ nil
]
