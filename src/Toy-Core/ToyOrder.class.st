"
The toy's domain object: an order accumulating item prices. Lives in the 'domain' layer (Toy-Core) and references no sibling toy package. Real, tiny, executable - the honest fixture behind R-32.
"
Class {
	#name : 'ToyOrder',
	#superclass : 'Object',
	#instVars : [
		'items'
	],
	#category : 'Toy-Core',
	#package : 'Toy-Core'
}

{ #category : 'instance creation' }
ToyOrder class >> empty [
	^ self new
]

{ #category : 'adding' }
ToyOrder >> addItemPriced: aNumber [
	items add: aNumber
]

{ #category : 'initialization' }
ToyOrder >> initialize [
	super initialize.
	items := OrderedCollection new
]

{ #category : 'accessing' }
ToyOrder >> itemCount [
	^ items size
]

{ #category : 'accessing' }
ToyOrder >> total [
	"Sum of the item prices; 0 for an empty order."
	^ items inject: 0 into: [ :sum :each | sum + each ]
]
