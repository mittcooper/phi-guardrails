"
Toy client's own extension lint rule (spec ch. 8 §8.2, §8.1 step 3): a flag-only structural rule matching `@x isNil ifFalse: [`.@block] at severity #error. Flag-only means a ReNodeMatchRule (ch. 2 §2.2) — no autofix ships; the rewrite is done by hand. History note: the toy's extension rule was re-pointed from Transcript show: to this pattern when the D-28 built-in took that ground. The pattern string in initialize is a literal, not an AST send, so the rule never critiques its own definition. Models the extension package a real adopter contributes (R-31/R-32); subclasses a Renraku base, not PGRCheck — a client rule needs nothing from Phi-Guardrails-SDK.
"
Class {
	#name : 'ToyNoIsNilIfFalseRule',
	#superclass : 'ReNodeMatchRule',
	#category : 'Toy-Rules',
	#package : 'Toy-Rules'
}

{ #category : 'accessing' }
ToyNoIsNilIfFalseRule class >> rationale [
	^ 're-testing a nil you already have reads backwards; ifNotNil: is one send and reads as intent. No autofix ships — rewrite by hand.'
]

{ #category : 'accessing' }
ToyNoIsNilIfFalseRule class >> ruleName [
	^ 'isNil ifFalse: should be ifNotNil:'
]

{ #category : 'accessing' }
ToyNoIsNilIfFalseRule class >> severity [
	^ #error "spec §8.2; D-41 — own class-side severity, or a registered rule is a configuration error"
]

{ #category : 'initialization' }
ToyNoIsNilIfFalseRule >> initialize [
	super initialize.
	self matches: '`@x isNil ifFalse: [`.@block]'
]
