"
The toy's UI layer: renders one order as a line of text. Lives in the 'ui' layer (Toy-UI) and references ToyOrder (domain) only - the single allowed ui -> domain edge of the toy's layer map.
"
Class {
	#name : 'ToyOrderView',
	#superclass : 'Object',
	#instVars : [
		'order'
	],
	#category : 'Toy-UI',
	#package : 'Toy-UI'
}

{ #category : 'instance creation' }
ToyOrderView class >> on: aToyOrder [
	^ self new
		setOrder: aToyOrder;
		yourself
]

{ #category : 'rendering' }
ToyOrderView >> render [
	"A one-line summary naming the item count and total."
	^ 'Order: ' , order itemCount printString , ' items, total ' , order total printString
]

{ #category : 'initialization' }
ToyOrderView >> setOrder: aToyOrder [
	order := aToyOrder
]
