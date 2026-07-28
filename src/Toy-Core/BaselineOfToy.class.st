"
The toy adopter's own baseline (spec ch. 8 par. 8.2), defined inside Toy-Core so it needs no package of its own - it is introspected, never Metacello-loaded in v1 (the BaselineOfPCKFixture precedent). Under D-45 it declares no role groups: the toy's artifact assigns roles by matcher, which is how the toy demonstrates R-47 - adoption changed nothing in the adopted project's baseline.
"
Class {
	#name : 'BaselineOfToy',
	#superclass : 'BaselineOf',
	#category : 'Toy-Core',
	#package : 'Toy-Core'
}

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
