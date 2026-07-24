"
apply was invoked before previewOn: ran on the same fix-command instance — the machine-checkable meaning of D-06's mandatory preview. Signalled by the fix-invocation implementation; caught by the fix invoker, by class. Carries only the one-line reason handed to signal: — the wording is human-facing, not an API.
"
Class {
	#name : 'PGRFixNotPreviewed',
	#superclass : 'Error',
	#category : 'Phi-Guardrails-SDK',
	#package : 'Phi-Guardrails-SDK'
}
