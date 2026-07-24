"
A fix target changed between preview and apply; nothing was applied — the diff the invoker confirmed is the diff that applies. Signalled by the fix-invocation implementation; caught by the fix invoker, by class. Carries only the one-line reason handed to signal: — the wording is human-facing, not an API.
"
Class {
	#name : 'PGRFixStale',
	#superclass : 'Error',
	#category : 'Phi-Guardrails-SDK',
	#package : 'Phi-Guardrails-SDK'
}
