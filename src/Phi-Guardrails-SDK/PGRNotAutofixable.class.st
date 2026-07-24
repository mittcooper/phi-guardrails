"
Fix invocation on a check that has no autofix. Not a configuration error: the artifact is not at fault when a caller hands the fix command a flag-only rule (ch. 3 par. 3.3). Signalled by the fix-invocation implementation; caught by the fix invoker, by class. Carries only the one-line reason handed to signal: — the wording is human-facing, not an API.
"
Class {
	#name : 'PGRNotAutofixable',
	#superclass : 'Error',
	#category : 'Phi-Guardrails-SDK',
	#package : 'Phi-Guardrails-SDK'
}
