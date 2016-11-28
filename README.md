# mahogany
A jasmine-inspired testing framework for Delphi.  Allows you to use Delphi's anonymous procedures to structure your code similar to how you would structure javascript tests with jasmine.

## Features

* Use **Describe** to create a test suite
* Use **It** to specify specs
* Use **Expect** to specify an expectation
* Use **ExpectEqual** and **ExpectException** for special expectations
* Use **BeforeEach** and **AfterEach** for setup and teardown before and after tests in a suite
* Use **BeforeAll** and **AfterAll** for setup and teardown before and after all of the tests in a suite

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

outputs:

```
A suite
  contains a spec with an expectation
```
