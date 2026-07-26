"
The in-image gate run (ch. 7 §7.2; R-30's in-image mode). forConfiguration: builds the
run's registry eagerly - so a kit-raised PGRConfigurationError surfaces before anything
runs - and captures the configuration's project string; the gate holds project, registry,
and sink (nil by default, D-55) and nothing else, never the configuration object itself
beyond construction (R-35). onVerdict: sets the sink; there is no default - given none,
verdicts merely accumulate into the report and nothing streams; framework production code
never references Transcript, not as default, not as fallback (D-55). run executes every
registration in registry order via PGRRegistration>>run, passes each verdict to the sink
as it completes when one is set - before run returns - and answers
PGRReport project:verdicts: over every verdict, in order. run adds no exception handling of
its own: per-registration errors are already red verdicts inside PGRRegistration>>run
(D-21), and the top-level handler belongs to runHeadless: alone (D-39, E05-C05) - an
in-image caller sees raw exceptions from anything outside a check's run.
"
Class {
	#name : 'PGRGate',
	#superclass : 'Object',
	#instVars : [
		'project',
		'registry',
		'sink'
	],
	#category : 'Phi-Guardrails-Gate',
	#package : 'Phi-Guardrails-Gate'
}

{ #category : 'instance creation' }
PGRGate class >> forConfiguration: aPGRConfiguration [
	"Build the registry eagerly, inside the constructor, so a kit-raised PGRConfigurationError surfaces before anything runs; capture the project string. The configuration object itself is never held beyond this send (R-35)."
	^ self new
		setProject: aPGRConfiguration project
			registry: (PGRRegistry fromConfiguration: aPGRConfiguration);
		yourself
]

{ #category : 'running' }
PGRGate class >> runHeadless: aPathString [
	"Delegate onto Stdio stdout - the only Stdio reference this chunk adds (§7.6's ruled file/stream access site)."
	^ self runHeadless: aPathString on: Stdio stdout
]

{ #category : 'running' }
PGRGate class >> runHeadless: aPathString on: aWriteStream [
	"Ch. 7 §7.3, the invocation contract: parse the configuration at the explicit path (no
	default, no working-directory fallback - D-45 rulings 1/4, no environment sniffing), then
	stream the report onto aWriteStream - header first, one verdict line as each registration
	completes, then the summary - flush before answering. Exit codes: 0 clean, 1 non-green, 2
	a configuration error or any exception escaping the run (D-39's law - the gate never ends
	without deciding a number). The whole run is one top-level handler: a PGRConfigurationError
	writes its messageText; anything else writes its class name and description - exactly one
	line either way, itself guarded (on: Error do:, swallowing) so a broken stream still yields
	the number. Halt is the verified non-Error catchable on this image (P5); a resumable
	Notification resumes with nil by default and so never escapes."
	| writeErrorLine |
	writeErrorLine := [ :text | [ aWriteStream nextPutAll: text; lf; flush ] on: Error do: [ :ignored | ] ].
	^ [ [
		| configuration registry report |
		configuration := PGRConfiguration fromFile: aPathString.
		registry := PGRRegistry fromConfiguration: configuration.
		PGRReport printHeaderProject: configuration project count: registry size on: aWriteStream.
		report := (self forConfiguration: configuration)
			onVerdict: [ :verdict | aWriteStream lf. PGRReport printVerdict: verdict on: aWriteStream ];
			run.
		aWriteStream lf.
		report printSummaryOn: aWriteStream.
		aWriteStream flush.
		report exitCode
	  ] on: PGRConfigurationError do: [ :error |
		writeErrorLine value: error messageText.
		2 ]
	  ] on: Error, Halt do: [ :error |
		writeErrorLine value: error class name , ': ' , error description.
		2 ]
]

{ #category : 'configuring' }
PGRGate >> onVerdict: aOneArgBlock [
	"Set the verdict sink. There is no default (D-55): given none, run merely accumulates verdicts into the report."
	sink := aOneArgBlock
]

{ #category : 'private' }
PGRGate >> setProject: aProjectString registry: aPGRRegistry [
	project := aProjectString.
	registry := aPGRRegistry
]

{ #category : 'running' }
PGRGate >> run [
	"Run every registration in registry order; stream each verdict to the sink as it completes, before this answers, when a sink is set (P-STREAM); answer the aggregate report. No exception handling here - per-registration errors already land as red verdicts (D-21); the top-level handler is runHeadless:'s alone (D-39)."
	| verdicts |
	verdicts := registry registrations collect: [ :registration |
		| verdict |
		verdict := registration run.
		sink ifNotNil: [ :aBlock | aBlock value: verdict ].
		verdict ].
	^ PGRReport project: project verdicts: verdicts
]
