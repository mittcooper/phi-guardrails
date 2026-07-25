"
v1 catalog lint rule (ch. 3 par. 3.2, D-04): AST rewrite rule replacing the banned nil re-test conditional with the single-send ifNil: idiom, severity #error (D-20). The pattern string in initialize is a literal, not an AST send, so the rule never critiques its own definition. Declaration only - applying the rewrite is the fix command's job (E08).
"
Class {
	#name : 'PCKNoIsNilIfTrueRule',
	#superclass : 'ReNodeRewriteRule',
	#category : 'Phi-Coding-Kit-Rules',
	#package : 'Phi-Coding-Kit-Rules'
}

{ #category : 'accessing' }
PCKNoIsNilIfTrueRule class >> rationale [
	^ 'x isNil ifTrue: [...] re-tests a nil you already have; ifNil: is one send and reads as intent. The rewrite is behavior-preserving — apply the autofix.'
]

{ #category : 'accessing' }
PCKNoIsNilIfTrueRule class >> ruleName [
	^ 'isNil ifTrue: should be ifNil:'
]

{ #category : 'accessing' }
PCKNoIsNilIfTrueRule class >> severity [
	^ #error "D-20"
]

{ #category : 'initialization' }
PCKNoIsNilIfTrueRule >> initialize [
	super initialize.
	self replace: '`@x isNil ifTrue: [`.@block]' with: '`@x ifNil: [`.@block]'
]
