"
The fixture family's baseline (spec ch. 5 par. 5.5; BaselineOf* prefix exception D-11 as amended): declares the mandatory production group empty (par. 1.1; declared, listed, expands to nothing - D-25.a addendum) and the fixtures package under tests. Later E07 chunks derive the scratch tests-role list from it by introspection - it is never Metacello-loaded.
"
Class {
	#name : 'BaselineOfPCKFixture',
	#superclass : 'BaselineOf',
	#category : 'Phi-Coding-Kit-Fixtures-Behavioral',
	#package : 'Phi-Coding-Kit-Fixtures-Behavioral'
}

{ #category : 'baselines' }
BaselineOfPCKFixture >> baseline: spec [
	<baseline>
	spec for: #common do: [
		spec package: 'Phi-Coding-Kit-Fixtures-Behavioral'.
		spec
			group: 'production' with: #(  );
			group: 'tests' with: #( 'Phi-Coding-Kit-Fixtures-Behavioral' ) ]
]
