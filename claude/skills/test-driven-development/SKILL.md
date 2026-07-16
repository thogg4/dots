---
name: test-driven-development
description: The specify-encode-fulfill TDD loop (Canon TDD) for building application code — how to translate specifications into tests, work the red-green cycle, clean the kitchen before starting, and avoid speculative code. Invoke before writing application code in the Build step of the Development Workflow, or any time you're about to implement a behavior change with tests.
---

# Test-Driven Development

## The Specify-Encode-Fulfill Loop

I use something called "specify-encode-fulfill":

1. **Specify**: Come up with the specifications for what you want to build
2. **Encode**: Encode those specifications as automated tests (executable specifications)
3. **Fulfill**: Write the code to fulfill the specifications

At a finer grain:

1. Write a list of the specifications within scope of the current TDD session
2. Encode one item in the list as an automated test
3. Change the code *just barely enough* to *make the current test failure go away*. Avoid "speculative coding" - if we write more code than necessary to make the current test failure go away, we risk having code never exercised by any test
4. Optionally refactor, but not before committing the behavior change. Never mix behavior changes with refactoring
5. Until the list is empty, go back to #2

This follows Kent Beck's [Canon TDD](https://tidyfirst.substack.com/p/canon-tdd).

## Translating Specifications into Tests

Specifications should take the form: "under scenario A, X happens; under scenario B, Y happens".

Each scenario should map to an RSpec _example group_. If the specification is,
for example "when a test suite run's status is 'passed', its label says
'Passed'", then the test should look like this:

```ruby
describe "#label" do
  context "when status is 'passed'" do
    it "returns 'Passed'" do
      test_suite_run = TestSuiteRun.new(status: "passed")
      expect(test_suite_run.label).to eq("Passed")
    end
  end
end
```

Here's an example of a BAD way to write such a test:

```ruby
describe "#label" do
  it "returns the correct value" do
    test_suite_run = TestSuiteRun.new(status: "passed")
    expect(test_suite_run.label).to eq("Passed")
  end
end
```

Of course it returns the "correct" value. What else could we ever want from our
code? Never assert that a behavior "works correctly" or "works properly" or
"handles" certain scenario. What we want to specify in every scenario is _what
the correct behavior is_.

## Workflow

Once we've agreed on the specifications, work through them autonomously — no
need to pause for approval on each test or each change.

1. See if we need to "clean the kitchen before we make dinner". Refer to the
   "Cleaning the Kitchen" section below.
2. Write just one test (per Canon TDD).
3. Write only enough application code to make it pass. Refer to the
   "Fulfilling Test Specifications" section below.
4. Move to the next specification and repeat until the list is empty.

### Cleaning the Kitchen

Before you write a test, picture the test you're going to write and where
you're going to put it. Does the conceptual framework of this new behavior
we're about to add slot tidily into the conceptual framework of the area of the
code where we'll be adding it? If not, is there a reconceptualizing of the
current behavior that could be done in order to make the ending result more
conceptually elegant? If such a reconceptualizing is called for, abandon the
current change, get to a clean working state, and, on a new branch, perform the
refactoring. "Clean the kitchen before you make dinner." Then resume the TDD
cycle.

### Fulfilling Test Specifications

When writing the application code to fulfill a certain specification, write
only enough code to make the current test failure go away. Never use "defensive
coding". Defensive coding is almost always just speculative coding, which means
code that's added without justification or feedback. Once you've written the
test, invoke a separate subagent with the /test-design-review command to
scrutinize your test code.

### Don't Be Sloppy

This kind of thinking is bad:

> That failure is pre-existing (unrelated to our change — it's in send_results).
> Our 6 new + existing specs pass. Want me to commit and push?

We don't make dinner in a dirty kitchen. If we discover a pre-existing failure,
the right move is to pause, stash our changes, fix the pre-existing failure,
then resume.
