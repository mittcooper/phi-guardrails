"
The toy's persistence layer: an in-memory store of saved orders. Lives in the 'persistence' layer (Toy-Persistence) and references no sibling toy package - the layer map's leaf.
"
Class {
	#name : 'ToyOrderStore',
	#superclass : 'Object',
	#instVars : [
		'orders'
	],
	#category : 'Toy-Persistence',
	#package : 'Toy-Persistence'
}

{ #category : 'instance creation' }
ToyOrderStore class >> empty [
	^ self new
]

{ #category : 'accessing' }
ToyOrderStore >> count [
	^ orders size
]

{ #category : 'initialization' }
ToyOrderStore >> initialize [
	super initialize.
	orders := OrderedCollection new
]

{ #category : 'adding' }
ToyOrderStore >> save: anOrder [
	orders add: anOrder
]
