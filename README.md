# mahogany
A Jasmine-inspired testing framework for Delphi.  Allows you to use Delphi's anonymous procedures to structure your tests similar to how you would structure them with [Jasmine](https://jasmine.github.io/).

## Features

* Use **Describe** to create a test suite
* Use **It** to specify specs
* Use **Expect** to specify an expectation
* Use **ExpectEqual** and **ExpectException** for special expectations
* Use **BeforeEach** and **AfterEach** for setup and teardown before and after each test in a suite
* Use **BeforeAll** and **AfterAll** for setup and teardown before and after a suite's tests

## Differences from Jasmine

* The matchers aren't quite as rich.  I may expand them in the future.
* No built-in spies yet.  (I don't see them as being particularly relevant for Delphi code, tbh)
* No built-in asynchronous testing yet.
* No built-in timing testing yet.

## Example code

```delphi
Describe('A suite', procedure
  begin
    It('contains a spec with an expectation', procedure
      begin
        Expect(true, 'True passes');
      end);
  end);
```

When run outputs:

```
A suite
  contains a spec with an expectation
```

## Design

Testing is broken into two major stages with Mahogany: building the tests and running them.  

- `Describe` and `It` build a nested structure of test suites and expectations.
- `RunTests` iterates through all top-level test suites and executes them.
- `ReportResults` provides an overview of how many specs were run and how many failed.

How test results are reported is up to the calling code.  You can use Mahogany's built-in reporting functionality to get a report of the suites and specs as they run by providing an anonymous procedure as a callback for log messages.  This can be used to log messages to the console, to a file, or however else meets your requirements.
