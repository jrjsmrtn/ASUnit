(*
ASUnit tests

copyright: (c) 2006 Nir Soffer <nirs@freeshell.org>
license: GNU GPL, see COPYING for details
*)

on _setpath()
	if current application's name is "AppleScript Editor" then
		(folder of file (document 1's path as POSIX file) of application "Finder") as text
	else if current application's name is in {"osacompile", "osascript"} then
		((POSIX file (do shell script "pwd")) as text) & ":"
	else
		error "This file can be compiled/run only with AppleScript Editor, osacompile or osascript"
	end if
end _setpath

-- Required ASUnit header
-- Load  ASUnit from current folder using text format during development
property ASUnitPath : _setpath() & "ASUnit.applescript" -- set at compile time
property parent : run script file ASUnitPath
property name : "Unit tests for ASUnit"
property ASUnit : my parent -- Needed to refer to ASUnit in some tests
property TestASUnit : me -- Needed to refer to top level entities from some tests
property suite : makeTestSuite("ASUnit Tests")

script |ASUnit name and bundle id|
	property parent : TestSet(me)
	property ThisTestSet : me
	
	script |This test script's name|
		property parent : UnitTest(me)
		assertEqual("Unit tests for ASUnit", TestASUnit's name)
	end script
	
	script |A unit test's name is accessible|
		property parent : UnitTest(me)
		assertEqual("A unit test's name is accessible", my name)
	end script
	
	script |The parent of a unit test is the wrapping test set|
		property parent : UnitTest(me)
		assertEqual("ASUnit name and bundle id", my parent's name)
	end script
	
	script |A test set descends from TestCase|
		property parent : UnitTest(me)
		assertEqual("TestCase", ThisTestSet's parent's parent's name)
		assertInheritsFrom(ASUnit's TestCase, ThisTestSet)
	end script
	
	script |Bundle id|
		property parent : UnitTest(me)
		assertEqual("com.lifepillar.ASUnit", ASUnit's id)
	end script
	
end script

script |test failIf|
	property parent : TestSet(me)
	
	script |nested failIf|
		property parent : UnitTest(me)
		on willFail(dummy)
			failIf(my ok, {true}, "")
		end willFail
		failIf(willFail, {0}, "Nested failIf() should not fail.")
	end script
	
end script

script |should and shouldnt|
	property parent : TestSet(me)
	
	script |should succeed with true|
		property parent : UnitTest(me)
		should(true, name)
	end script
	
	script |shouldnt succeed with false|
		property parent : UnitTest(me)
		shouldnt(false, name)
	end script
	
	script |should fail with false|
		property parent : UnitTest(me)
		
		script |unregistered failure|
			property parent : makeTestCase()
			should(false, name)
		end script
		set aResult to |unregistered failure|'s test()
		should(aResult's hasPassed() is false, "should passed with false?!")
	end script
	
	script |shouldnt fail with true|
		property parent : UnitTest(me)
		
		script |unregistered failure|
			property parent : makeTestCase()
			shouldnt(true, name)
		end script
		set aResult to |unregistered failure|'s test()
		shouldnt(aResult's hasPassed(), "shouldnt passed with true?!")
	end script
	
end script

script |ok, notOk, assert and refute|
	property parent : TestSet(me)
	
	script |ok succeeds with true|
		property parent : UnitTest(me)
		ok(true)
	end script
	
	script |notOk succeeds with false|
		property parent : UnitTest(me)
		notOk(false)
	end script
	
	script |assert succeeds with true|
		property parent : UnitTest(me)
		assert(true, "true should be true.")
	end script
	
	script |refute succeeds with false|
		property parent : UnitTest(me)
		refute(false, "false should be false.")
	end script
	
end script -- ok, notOk, assert and refute

script |assert equal (exact and approximate)|
	property parent : TestSet(me)
	
	script |compare equal values|
		property parent : UnitTest(me)
		assertEqual(2, 1 + 1)
		assertEqual("ab", "a" & "b")
		shouldEqual({} as text, "")
		shouldEqual(|compare equal values|, |compare equal values|)
		assertEqual(current application, current application)
	end script
	
	script |compare different values|
		property parent : UnitTest(me)
		failIf(my assertEqual, {1, "a"}, "1 should be different from a.")
		failIf(my assertEqual, {script, "a"}, "script should be different from a.")
		failIf(my assertEqual, {AppleScript, current application}, "script should be different from a.")
	end script
	
	script |equal within absolute error|
		property parent : UnitTest(me)
		assertEqualAbsError(1, 1 + 1.0E-5, 1.0E-4)
	end script
	
	script |equal within relative error|
		property parent : UnitTest(me)
		assertEqualRelError(100, 104, 0.05) -- Equal within 5% tolerance
	end script
	
end script -- assert equal

script |assert not equal|
	property parent : TestSet(me)
	
	script |compare different values|
		property parent : UnitTest(me)
		script EmptyScript
		end script
		assertNotEqual(1, "a")
		assertNotEqual(|compare different values|, EmptyScript)
		assertNotEqual(|compare different values|, {})
		shouldNotEqual({1}, {2})
		shouldNotEqual(1 + 1, 3)
		assertNotEqual(AppleScript, current application)
	end script
	
end script -- assert not equal

script |assert instance of|
	property parent : TestSet(me)
	
	script |test classes of expressions|
		property parent : UnitTest(me)
		assertInstanceOf(integer, 1)
		assertInstanceOf(real, 2.7)
		failIf(my assertInstanceOf, {number, 1}, "1 should be an instance of integer.")
		failIf(my assertInstanceOf, {number, 2.7}, "2.7 should be an instance of real.")
		assertInstanceOf(text, "abc")
		assertInstanceOf(list, {})
		assertInstanceOf(record, {a:1})
		assertInstanceOf(date, current date)
		assertInstanceOf(boolean, 1 = 1)
		assertInstanceOf(class, class of class of 1)
		assertInstanceOf(real, pi)
		assertInstanceOf(script, me)
		-- "class of current application" collapses to "class"
		refuteInstanceOf(application, current application) -- AS bug?
		-- should be 'application' according to The AppleScript Language Guide
		assertInstanceOf(null, application "Finder") -- AS bug?
		set f to POSIX file "/Users/myUser/Feb_Meeting_Notes.rtf"
		assertInstanceOf(«class furl», f) -- shouldn't be 'file'?
		assertInstanceOf(grams, 1 as grams)
		refuteInstanceOf(number, 1)
		refuteInstanceOf(real, 1)
		refuteInstanceOf(RGB color, {1, 2, 70000})
		refuteInstanceOf(RGB color, {65535, 65535, 65535})
		refuteInstanceOf(kilograms, 1 as grams)
		refuteInstanceOf(list, {a:1})
		refuteInstanceOf(file, f)
		refuteInstanceOf(POSIX file, f)
		refuteInstanceOf(alias, f)
	end script
	
end script

script |Kind of|
	property parent : TestSet(me)
	property x : missing value
	
	on setUp()
		set x to missing value
	end setUp
	
	script |kind of user-defined class|
		property parent : UnitTest(me)
		
		script Father
			property class : "Father"
		end script
		
		script Child
			property parent : Father
			property class : "Child"
		end script
		
		assertInstanceOf("Child", Child)
		assertInstanceOf("Father", Father)
		refuteInstanceOf("Child", Father)
		refuteInstanceOf("Father", Child)
		refuteInstanceOf(script, Child)
		refuteInstanceOf(script, Father)
		assertInheritsFrom(Father, Child)
		assertInheritsFrom(AppleScript, Child)
		assertInheritsFrom(current application, Child)
		refuteInheritsFrom(Child, Father)
		assertKindOf("Father", Child)
		refuteKindOf("Child", Father)
		assertKindOf(script, Child)
	end script
	
	script |Child of integer in kind of number|
		property parent : UnitTest(me)
		script x
			property parent : 1
		end script
		assertInstanceOf(script, x)
		refuteInstanceOf(number, x)
		refuteInstanceOf(integer, x)
		assertKindOf(integer, x)
		assertKindOf(number, x)
	end script
	
end script

script Inheritance
	property parent : TestSet(me)
	
	on scriptWithParent(theParent)
		script
			property parent : theParent
			property class : theParent's class -- Avoids infinite loop when accessing script's class
		end script
	end scriptWithParent
	
	script |inherits from AppleScript|
		property parent : UnitTest(me)
		assertInheritsFrom(AppleScript, me)
		failIf(my refuteInheritsFrom, {AppleScript, me}, "")
	end script
	
	script |inherits from top level|
		property parent : UnitTest(me)
		script x
		end script
		assertInheritsFrom(TestASUnit, x)
		refuteInheritsFrom(x, x)
	end script
	
	script |inherits from list|
		property parent : UnitTest(me)
		set x to scriptWithParent({})
		assertInheritsFrom({}, x)
		refuteInheritsFrom({1}, x)
		failIf(my refuteInheritsFrom, {{}, x}, "")
	end script
	
	script |test current application|
		property parent : UnitTest(me)
		
		set x to current application -- does not have a parent
		refuteInheritsFrom(x, x)
		failIf(my assertInheritsFrom, {x, x}, "")
	end script
	
	script |self-inheritance|
		property parent : UnitTest(me)
		script Loop
			property parent : me
		end script
		set x to scriptWithParent(Loop)
		assertInheritsFrom(Loop, Loop)
		failIf(my refuteInheritsFrom, {Loop, Loop}, "")
		assertInheritsFrom(Loop, x)
		assertNotEqual(x, Loop) -- "x's class" hangs if x's class is not explicitly defined (AS 2.3, OS X 10.9)
		assertNotEqual(Loop's parent, x)
		refuteInheritsFrom(x, Loop)
	end script
	
end script

script |assert (not) reference|
	property parent : TestSet(me)
	
	script |test Finder reference|
		property parent : UnitTest(me)
		assertReference(path to me)
		tell application "Finder" to set x to folder of file (path to me)
		assertReference(x)
	end script
	
	script |test 'a reference to' operator|
		property parent : UnitTest(me)
		property x : 3
		set y to a reference to x
		assertReference(y)
	end script
	
	script |test assertNotReference|
		property parent : UnitTest(me)
		property x : 1
		assertNotReference(x)
		assertNotReference({})
		set y to a reference to x
		assertNotReference(contents of y)
	end script
	
end script -- assert (not) reference


script |skipping test helper|
	-- I'm a helper fixture for the skip tests..
	property parent : TestSet(me)
	
	script test
		property parent : makeTestCase()
		skip("I feel skippy")
		should(true, name)
	end script
end script


script |skipping setup helper|
	-- I'm a helper fixture for the skip tests..
	property parent : TestSet(me)
	
	on setUp()
		skip("I feel skippy")
	end setUp
	
	script test
		property parent : makeTestCase()
		should(true, name)
	end script
end script


script skipping
	property parent : TestSet(me)
	
	script |skipping test|
		property parent : UnitTest(me)
		set aResult to |skipping test helper|'s test's test()
		should(aResult's hasPassed(), "test failed")
		should(aResult's skipCount() = 1, "skipCount ≠ 1")
	end script
	
	script |skipping setup|
		property parent : UnitTest(me)
		set aResult to |skipping setup helper|'s test's test()
		should(aResult's hasPassed(), "test failed")
		should(aResult's skipCount() = 1, "skipCount ≠ 1")
	end script
	
end script


script |errors setUp helper|
	-- I'm a helper for tearDown tests
	property parent : TestSet(me)
	
	on setUp()
		error "setUp raised an error"
	end setUp
	
	script test
		property parent : makeTestCase()
		should(true, name)
	end script
	
end script


script |errors test case helper|
	-- I'm a helper for tearDown tests
	property parent : TestSet(me)
	
	script test
		property parent : makeTestCase()
		error "I feel nasty"
	end script
	
end script


script |errors tearDown helper|
	-- I'm a helper for tearDown tests
	property parent : TestSet(me)
	
	on tearDown()
		error "tearDown raised an error"
	end tearDown
	
	script test
		property parent : makeTestCase()
		should(true, name)
	end script
	
end script


script errors
	property parent : TestSet(me)
	
	script |error in setup|
		property parent : UnitTest(me)
		set aResult to |errors setUp helper|'s test's test()
		shouldnt(aResult's hasPassed(), "error in setup ignored")
		should(aResult's errorCount() = 1, "errorCount ≠ 1")
	end script
	
	script |error in test case|
		property parent : UnitTest(me)
		set aResult to |errors test case helper|'s test's test()
		shouldnt(aResult's hasPassed(), "error in test case ignored")
		should(aResult's errorCount() = 1, "errorCount ≠ 1")
	end script
	
	script |error in tearDown|
		property parent : UnitTest(me)
		set aResult to |errors tearDown helper|'s test's test()
		shouldnt(aResult's hasPassed(), "error in tearDown ignored")
		should(aResult's errorCount() = 1, "errorCount ≠ 1")
	end script
	
end script


script setUp
	property parent : TestSet(me)
	property setUpDidRun : false
	
	on setUp()
		set setUpDidRun to true
	end setUp
	
	script |setup run before test|
		property parent : UnitTest(me)
		should(setUpDidRun, "setup did not run before the test")
	end script
	
end script


script |tearDown helper|
	-- I'm a helper to tearDown tests
	property parent : TestSet(me)
	property tearDownDidRun : missing value
	
	on setUp()
		set tearDownDidRun to false
	end setUp
	
	on tearDown()
		set tearDownDidRun to true
	end tearDown
	
	script |failing test|
		property parent : makeTestCase()
		should(false, name)
	end script
	
	script |erroring test|
		property parent : makeTestCase()
		error "I feel nasty"
		should(true, name)
	end script
	
	script |skipping test|
		property parent : makeTestCase()
		skip("I feel skippy")
		should(true, name)
	end script
	
end script


script |skip in setUp helper|
	-- I'm a helper to tearDown tests
	property parent : TestSet(me)
	property tearDownDidRun : missing value
	
	on setUp()
		set tearDownDidRun to false
		skip("I feel skippy")
	end setUp
	
	on tearDown()
		set tearDownDidRun to true
	end tearDown
	
	script test
		property parent : makeTestCase()
		should(true, name)
	end script
	
end script


script |error in setUp helper|
	-- I'm a helper for tearDown tests
	property parent : TestSet(me)
	property tearDownDidRun : missing value
	
	on setUp()
		set tearDownDidRun to false
		error "I feel nasty"
	end setUp
	
	on tearDown()
		set tearDownDidRun to true
	end tearDown
	
	script test
		property parent : makeTestCase()
		should(true, name)
	end script
	
end script


script |tearDown|
	property parent : TestSet(me)
	
	script |run after failed test|
		property parent : UnitTest(me)
		set aResult to (|tearDown helper|'s |failing test|'s test())
		if aResult's hasPassed() then error "failing test did not fail, can't test tearDown"
		should(|tearDown helper|'s tearDownDidRun, name)
	end script
	
	script |run after error in test|
		property parent : UnitTest(me)
		set aResult to (|tearDown helper|'s |erroring test|'s test())
		if aResult's hasPassed() then error "erroring test did not error, can't test tearDown"
		should(|tearDown helper|'s tearDownDidRun, name)
	end script
	
	script |run after skipping test|
		property parent : UnitTest(me)
		set aResult to (|tearDown helper|'s |skipping test|'s test())
		if aResult's skipCount() ≠ 1 then error "skipping test did not skip, can't test tearDown"
		should(|tearDown helper|'s tearDownDidRun, name)
	end script
	
	script |run after skip in setup|
		property parent : UnitTest(me)
		set aResult to (|skip in setUp helper|'s test's test())
		if aResult's skipCount() ≠ 1 then error "there was no skip, can't test tearDown"
		should(|skip in setUp helper|'s tearDownDidRun, name)
	end script
	
	script |run after error in setup|
		property parent : UnitTest(me)
		set aResult to (|error in setUp helper|'s test's test())
		if aResult's hasPassed() then error "there was no error, can't test tearDown"
		should(|error in setUp helper|'s tearDownDidRun, name)
	end script
	
end script


script |invalid test case|
	property parent : TestSet(me)
	
	script |unregistered test without run handler|
		property parent : makeTestCase()
	end script
	
	script |no run handler|
		property parent : UnitTest(me)
		set aResult to |unregistered test without run handler|'s test()
		shouldnt(aResult's hasPassed(), "test passed with an error?!")
	end script
	
end script


script |analyze helper|
	-- I'm a helper fixture. All my tests are NOT registered in this suite
	property parent : TestSet(me)
	
	script success
		property parent : makeTestCase()
		should(true, name)
	end script
	
	script skip
		property parent : makeTestCase()
		skip("I feel skippy")
	end script
	
	script failure
		property parent : makeTestCase()
		should(false, name)
	end script
	
	script |error|
		property parent : makeTestCase()
		error "I feel nasty"
	end script
	
end script


script |analyze results|
	-- Test hasPassed() and count() methods
	property parent : TestSet(me)
	
	script |check counts|
		property parent : UnitTest(me)
		set aSuite to TestASUnit's makeTestSuite(name)
		aSuite's add(|analyze helper|'s success)
		aSuite's add(|analyze helper|'s success)
		aSuite's add(|analyze helper|'s skip)
		aSuite's add(|analyze helper|'s |error|)
		aSuite's add(|analyze helper|'s failure)
		set aResult to aSuite's test()
		should(aResult's runCount() = 5, "runCount ≠ 5")
		should(aResult's passCount() = 2, "passCount ≠ 2")
		should(aResult's skipCount() = 1, "skipCount ≠ 1")
		should(aResult's failureCount() = 1, "failureCount ≠ 1")
		should(aResult's errorCount() = 1, "errorCount ≠ 1")
	end script
	
	script |suite with success should pass|
		property parent : UnitTest(me)
		set aSuite to TestASUnit's makeTestSuite(name)
		aSuite's add(|analyze helper|'s success)
		aSuite's add(|analyze helper|'s success)
		set aResult to aSuite's test()
		should(aResult's hasPassed(), "test failed without defects?!")
	end script
	
	script |suite with skips should pass|
		property parent : UnitTest(me)
		set aSuite to TestASUnit's makeTestSuite(name)
		aSuite's add(|analyze helper|'s success)
		aSuite's add(|analyze helper|'s skip)
		aSuite's add(|analyze helper|'s skip)
		set aResult to aSuite's test()
		should(aResult's hasPassed(), "test failed without defects?!")
	end script
	
	script |suite with a failure should fail|
		property parent : UnitTest(me)
		set aSuite to TestASUnit's makeTestSuite(name)
		aSuite's add(|analyze helper|'s success)
		aSuite's add(|analyze helper|'s skip)
		aSuite's add(|analyze helper|'s failure)
		set aResult to aSuite's test()
		shouldnt(aResult's hasPassed(), "test passed with defects?!")
	end script
	
	script |suite with an error should fail|
		property parent : UnitTest(me)
		set aSuite to TestASUnit's makeTestSuite(name)
		aSuite's add(|analyze helper|'s success)
		aSuite's add(|analyze helper|'s skip)
		aSuite's add(|analyze helper|'s |error|)
		set aResult to aSuite's test()
		shouldnt(aResult's hasPassed(), "test passed with defects?!")
	end script
	
end script


property properyOfMainScript : true

script scriptInMainScript
	return true
end script


script |access main script context|
	-- Test that test case can access some of main script context
	property parent : TestSet(me)
	
	script |properties|
		property parent : UnitTest(me)
		try
			should(properyOfMainScript, name)
		on error msg number errorNumber
			fail(msg & "(" & errorNumber & ")")
		end try
	end script
	
	script |scripts|
		property parent : UnitTest(me)
		try
			should(run scriptInMainScript, name)
		on error msg number errorNumber
			fail(msg & "(" & errorNumber & ")")
		end try
	end script
	
end script


script |shouldRaise|
	(* To check for errors, the tested code should be closed inside a script object run 
	handler, and the script object should be sent to shouldRaise. *)
	property parent : TestSet(me)
	
	-- blocks
	
	script |no error|
		set foo to "this can't fail"
	end script
	
	script |raise 500|
		error number 500
	end script
	
	script |raise 501|
		error number 501
	end script
	
	-- helper unregistered tests, to be run by the real tests
	
	script |shouldRaise fail with unexpected error|
		property parent : makeTestCase()
		shouldRaise(500, |raise 501|, name)
	end script
	
	script |shouldRaise fail with no error|
		property parent : makeTestCase()
		shouldRaise(500, |no error|, name)
	end script
	
	script |shouldntRaise fail|
		property parent : makeTestCase()
		shouldntRaise(500, |raise 500|, name)
	end script
	
	-- tests
	
	script |should raise with expected error|
		property parent : UnitTest(me)
		shouldRaise(500, |raise 500|, name)
	end script
	
	script |shouldnt raise with no error|
		property parent : UnitTest(me)
		shouldntRaise(500, |no error|, name)
	end script
	
	script |shouldnt raise with another error|
		property parent : UnitTest(me)
		shouldntRaise(500, |raise 501|, name)
	end script
	
	script |should raise with unexpected error|
		property parent : UnitTest(me)
		set aResult to |shouldRaise fail with unexpected error|'s test()
		shouldnt(aResult's hasPassed(), name)
	end script
	
	script |should raise with no error|
		property parent : UnitTest(me)
		set aResult to |shouldRaise fail with no error|'s test()
		shouldnt(aResult's hasPassed(), name)
	end script
	
	script |shouldnt raise with an error|
		property parent : UnitTest(me)
		set aResult to |shouldntRaise fail|'s test()
		shouldnt(aResult's hasPassed(), name)
	end script
	
	script |shouldRaise can catch more than one exception|
		property parent : UnitTest(me)
		script Raiser
			error number 9876
		end script
		
		shouldRaise({1, 2, 3, 1000, 9876, 10000}, Raiser, ¬
			"The script should have raised exception 9876.")
		shouldRaise({}, Raiser, ¬
			"The script should have raised exception 9876")
		shouldntRaise({1, 2, 3, 1000, 10000}, Raiser, ¬
			"The script has raised a forbidden exception.")
	end script
	
	script |shouldntRaise can catch more than one exception|
		property parent : UnitTest(me)
		script Quiet
			-- Must not be empty, because it will inherit the run handler
			-- which will cause a stack overflow
			-- (see http://macscripter.net/viewtopic.php?pid=170090)
			on run
			end run
		end script
		shouldntRaise({1, 2, 9876}, Quiet, "Should not have raised any exception.")
		shouldntRaise({}, Quiet, "Should not have raised any exception.")
	end script
	
end script


script |test case creation|
	-- Note: don't rename me or my tests will break!
	property parent : TestSet(me)
	
	-- helpers
	
	script |makeTestCase helper|
		property parent : makeTestCase()
		should(true, name)
	end script
	
	-- tests
	
	script |registerTestCase make test case inherit from current fixture|
		property parent : UnitTest(me)
		should(parent is |test case creation|, "test registration failed")
	end script
	
	script |makeTestCase make test case inherit from current fixture|
		property parent : UnitTest(me)
		should(|makeTestCase helper|'s parent is |test case creation|, "wrong parent")
	end script
	
	(* TODO: how to test that registerTestCase add a test to the suite and makeTestCase 
	does not? *)
	
end script


script |fixture parent|
	(* A base class for fixture. May be used to share helper handles between different 
	fixtures. Each concrete fixture should register itself with registerFixtureWithParent(me, aParent) *)
	property parent : makeFixture()
	
	on sharedHandler()
		return true
	end sharedHandler
end script

script |concrete fixture|
	property parent : registerFixtureOfKind(me, |fixture parent|)
	
	script |inheriting from user defined fixture|
		property parent : UnitTest(me)
		should(sharedHandler(), "why?!")
	end script
	
end script

script |pretty print|
	property parent : TestSet(me)
	
	script |pp alias|
		property parent : UnitTest(me)
		assertEqual((path to me) as text, pp(path to me))
	end script
	
	script |pp application|
		property parent : UnitTest(me)
		assertEqual("«application Finder»", pp(application "Finder"))
	end script
	
	script |pp AppleScript|
		property parent : UnitTest(me)
		assertEqual("AppleScript", pp(AppleScript))
	end script
	
	script |pp boolean|
		property parent : UnitTest(me)
		assertEqual("true", pp(true))
		assertEqual("false", pp(false))
		assertEqual("true", pp(1 = 1))
		assertEqual("false", pp(1 = 2))
	end script
	
	script |pp class|
		property parent : UnitTest(me)
		assertEqual("integer", pp(class of 1))
		assertEqual("class", pp(class of class of 1))
	end script
	
	script |pp constant|
		property parent : UnitTest(me)
		set x to missing value
		assertEqual("missing value", pp(missing value))
		assertEqual("missing value", pp(x))
		assertEqual("hyphens", pp(hyphens))
		assertEqual(pi as text, pp(pi))
		assertEqual(linefeed, pp(linefeed))
		assertEqual(quote, pp(quote))
	end script
	
	script |pp date|
		property parent : UnitTest(me)
		set d to current date
		set day of d to 19
		set month of d to 12
		set year of d to 2014
		set time of d to 2700
		assertEqual(d as text, pp(d))
	end script
	
	script |pp list|
		property parent : UnitTest(me)
		assertEqual("{}", pp({}))
		assertEqual("{1, " & (3.4 as text) & ", abc}", pp({1, 3.4, "abc"}))
		assertEqual("{1, {2, {3, 4}}, 5}", pp({1, {2, {3, 4}}, 5}))
		assertEqual("{«script pp list», «record {1, {«application Finder», {1, 2}}, x}», true}", ¬
			pp({me, {a:1, b:{application "Finder", {1, 2}}, c:"x"}, true}))
	end script
	
	script |pp number|
		property parent : UnitTest(me)
		assertEqual("42", pp(42))
		assertEqual(2.71828 as text, pp(2.71828))
	end script
	
	script |pp POSIX file|
		property parent : UnitTest(me)
		set f to POSIX file "/Users/myUser/Feb_Meeting_Notes.rtf"
		assertEqual(f as text, pp(f))
	end script
	
	script |pp record|
		property parent : UnitTest(me)
		assertEqual("«record {1, 2, 3}»", pp({a:1, b:2, c:3}))
	end script
	
	script |pp script|
		property parent : UnitTest(me)
		assertEqual("«script pp script»", pp(me))
	end script
	
	script |pp text|
		property parent : UnitTest(me)
		assertEqual("àèìòùąčęėįšųūžñ©", pp("àèìòùąčęėįšųūžñ©"))
	end script
	
	script |pp unit types|
		property parent : UnitTest(me)
		assertEqual("10 centimeters", pp(10 as centimeters))
		assertEqual("11 feet", pp(11 as feet))
		assertEqual("12 inches", pp(12 as inches))
		assertEqual("13 kilometers", pp(13 as kilometers))
		assertEqual("14 meters", pp(14 as meters))
		assertEqual("15 miles", pp(15 as miles))
		assertEqual("16 yards", pp(16 as yards))
		assertEqual("17 square feet", pp(17 as square feet))
		assertEqual("18 square kilometers", pp(18 as square kilometers))
		assertEqual("19 square meters", pp(19 as square meters))
		assertEqual("20 square miles", pp(20 as square miles))
		assertEqual("21 square yards", pp(21 as square yards))
		assertEqual("22 cubic centimeters", pp(22 as cubic centimeters))
		assertEqual("23 cubic feet", pp(23 as cubic feet))
		assertEqual("24 cubic inches", pp(24 as cubic inches))
		assertEqual("25 cubic meters", pp(25 as cubic meters))
		assertEqual("26 cubic yards", pp(26 as cubic yards))
		assertEqual("27 gallons", pp(27 as gallons))
		assertEqual("28 liters", pp(28 as liters))
		assertEqual("29 quarts", pp(29 as quarts))
		assertEqual("30 grams", pp(30 as grams))
		assertEqual("31 kilograms", pp(31 as kilograms))
		assertEqual("32 ounces", pp(32 as ounces))
		assertEqual("33 pounds", pp(33 as pounds))
		assertEqual("34 degrees Celsius", pp(34 as degrees Celsius))
		assertEqual("35 degrees Fahrenheit", pp(35 as degrees Fahrenheit))
		assertEqual("36 degrees Kelvin", pp(36 as degrees Kelvin))
	end script
end script -- pretty print

log "ASUnit v" & my parent's version
tell AppleScriptEditorLogger -- Customize colors
	set its defaultColor to {256 * 30, 256 * 20, 256 * 10} -- RGB(30,20,10)
	set its successColor to {256 * 1, 256 * 102, 256 * 146} -- RGB(1,102,146)
	set its defectColor to {256 * 255, 256 * 108, 256 * 96} -- RGB(255,108,96)
end tell

--set suite's loggers to {AppleScriptEditorLogger, ConsoleLogger}
autorun(suite)