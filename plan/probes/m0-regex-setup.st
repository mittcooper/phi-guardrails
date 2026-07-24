"M0 regex probe setup (D-57) — run by tools/probe-m0.sh against a scratch COPY of
 the stock image, never the base toolchain image. Creates one trivial passing test
 per probe package (fluid form per D-15.b precedent, compile: on install's result;
 each statement self-contained — no compile-time reference to a just-created class),
 then saves the image and quits. The harness then runs the verify command's exact
 regex against the saved image; expected: exit 0, exactly 2 tests run, XPhi excluded.
 Spellings as executed are recorded in decision-log D-63."
(TestCase << #ProbeAlphaTest
    package: 'Phi-Guardrails-Tests-ProbeAlpha';
    install) compile: 'testTruth self assert: 3 + 4 equals: 7'.
(TestCase << #ProbeBetaTest
    package: 'Phi-Coding-Kit-Tests-ProbeBeta';
    install) compile: 'testTruth self assert: 3 + 4 equals: 7'.
(TestCase << #ProbeGammaTest
    package: 'XPhi-Guardrails-Tests-Gamma';
    install) compile: 'testTruth self assert: 3 + 4 equals: 7'.
Smalltalk snapshot: true andQuit: true
