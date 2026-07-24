"
The one load root (P3: the file is the complete statement of what runs). Group tree is normative spec ch. 8 par. 8.1, frozen at E01: role groups partition the 20 packages (each package in exactly one role); composites are unions of groups only. No #requires: edges between stubs — membership, not load order, is what E01 freezes. The tests role spans both families (D-57); fixtures and toy are the sweep-exempt roles (D-22/D-46).
"
Class {
	#name : 'BaselineOfPhiGuardrails',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfPhiGuardrails',
	#package : 'BaselineOfPhiGuardrails'
}

{ #category : 'baselines' }
BaselineOfPhiGuardrails >> baseline: spec [
	<baseline>
	spec for: #common do: [
		spec
			package: 'Phi-Guardrails-SDK';
			package: 'Phi-Guardrails-Core';
			package: 'Phi-Guardrails-Gate';
			package: 'Phi-Coding-Kit';
			package: 'Phi-Coding-Kit-Rules';
			package: 'Phi-Coding-Kit-Architecture';
			package: 'Phi-Coding-Kit-Behavioral';
			package: 'Phi-Guardrails-Tests-SDK';
			package: 'Phi-Guardrails-Tests-Core';
			package: 'Phi-Guardrails-Tests-Gate';
			package: 'Phi-Guardrails-Tests-Toy';
			package: 'Phi-Coding-Kit-Tests-Rules';
			package: 'Phi-Coding-Kit-Tests-Architecture';
			package: 'Phi-Coding-Kit-Tests-Behavioral';
			package: 'Phi-Coding-Kit-Fixtures-Behavioral';
			package: 'Toy-Core';
			package: 'Toy-UI';
			package: 'Toy-Persistence';
			package: 'Toy-Rules';
			package: 'Toy-Tests'.
		spec
			group: 'production' with: #( 'Phi-Guardrails-SDK' 'Phi-Guardrails-Core' 'Phi-Guardrails-Gate' 'Phi-Coding-Kit' 'Phi-Coding-Kit-Rules' 'Phi-Coding-Kit-Architecture' 'Phi-Coding-Kit-Behavioral' );
			group: 'tests' with: #( 'Phi-Guardrails-Tests-SDK' 'Phi-Guardrails-Tests-Core' 'Phi-Guardrails-Tests-Gate' 'Phi-Guardrails-Tests-Toy' 'Phi-Coding-Kit-Tests-Rules' 'Phi-Coding-Kit-Tests-Architecture' 'Phi-Coding-Kit-Tests-Behavioral' );
			group: 'fixtures' with: #( 'Phi-Coding-Kit-Fixtures-Behavioral' );
			group: 'toy' with: #( 'Toy-Core' 'Toy-UI' 'Toy-Persistence' 'Toy-Rules' 'Toy-Tests' );
			group: 'Core' with: #( 'Phi-Guardrails-Core' 'Phi-Guardrails-Gate' );
			group: 'Coding' with: #( 'production' );
			group: 'Tests' with: #( 'production' 'tests' 'fixtures' 'toy' );
			group: 'Toy' with: #( 'production' 'toy' );
			group: 'CI' with: #( 'Tests' );
			group: 'default' with: #( 'production' ) ]
]
