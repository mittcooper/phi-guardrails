"
A defect in the configuration artifact or its use: unknown key, malformed block, duplicate registration name, undeclared kit class, nonconforming check — the gate run fails before producing a report. Signalled by core validation, by a kit that cannot resolve or validate its own block, and by a check whose construction-time parameters are invalid (D-60); catchable by any caller, by class. Carries only the one-line reason handed to signal: — the wording is human-facing, not an API.
"
Class {
	#name : 'PGRConfigurationError',
	#superclass : 'Error',
	#category : 'Phi-Guardrails-SDK',
	#package : 'Phi-Guardrails-SDK'
}
