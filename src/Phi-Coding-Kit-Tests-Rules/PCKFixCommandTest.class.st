"
Behavioral pin of PCKFixCommand's construction and error paths (ch. 3 par. 3.3, E08-C02): the not-autofixable guard's two arms and the apply-before-preview error - P-FIX-PREVIEW leg 1 (D-06). Error classes are asserted by class, never by wording.
"
Class {
	#name : 'PCKFixCommandTest',
	#superclass : 'TestCase',
	#category : 'Phi-Coding-Kit-Tests-Rules',
	#package : 'Phi-Coding-Kit-Tests-Rules'
}

{ #category : 'tests' }
PCKFixCommandTest >> testApplyWithoutPreviewSignals [
	"P-FIX-PREVIEW leg 1 (ch. 9, D-06): apply with no prior previewOn: signals."
	| fix |
	fix := PCKFixCommand rule: PCKNoIsNilIfTrueRule packages: #('Phi-Coding-Kit-Tests-Rules').
	self should: [ fix apply ] raise: PGRFixNotPreviewed
]

{ #category : 'tests' }
PCKFixCommandTest >> testChangesEmptyBeforePreview [
	"Guard green arm: construction over a rewrite rule succeeds, and the pending
	change objects read as empty before any preview."
	| fix |
	fix := PCKFixCommand rule: PCKNoIsNilIfTrueRule packages: #('Phi-Coding-Kit-Tests-Rules').
	self assertEmpty: fix changes
]

{ #category : 'tests' }
PCKFixCommandTest >> testFlagOnlyRuleSignalsNotAutofixable [
	"Guard red arm (par. 3.3): a rule with no autofix must be refused at construction.
	The catalog's flag-only example ReCodeCruftLeftInMethodsRule answers isRewriteRule
	true in the live Pharo 13 image (it subclasses ReNodeRewriteRule - E08-C02 P5 probe),
	so the shipped ReEmptyExceptionHandlerRule, genuinely rewrite-less, carries this arm."
	self
		should: [ PCKFixCommand rule: ReEmptyExceptionHandlerRule packages: #('Phi-Coding-Kit-Tests-Rules') ]
		raise: PGRNotAutofixable
]
