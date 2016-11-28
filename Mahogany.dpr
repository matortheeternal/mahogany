program Mahogany;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  maMain in 'maMain.pas';

procedure BuildMahoganyTests;
var
  a: Boolean;
  obj: TObject;
begin
  Describe('A suite', procedure
    begin
      It('contains a spec with an expectation', procedure
        begin
          Expect(true, 'True passes');
        end);
    end);

  Describe('A suite is just a procedure', procedure
    begin
      It('and so is a spec', procedure
        begin
          a := true;
          Expect(a, 'A variable containing true passes');
        end);
    end);

  Describe('Expressions for expectations', procedure
    begin
      It('can be a boolean value', procedure
        begin
          Expect(true, 'True passes');
          Expect(not false, 'Not false passes');
          Expect(true and not false, 'True and not false passes');
        end);

      It('can be an integer comparison', procedure
        begin
          Expect(1 = 1, '1 equals 1');
          Expect(1 <> 2, '1 does not equal 2');
          Expect(3 > 2, '3 is greater than 2');
          Expect(3 < 4, '3 is less than 4');
          Expect(5 >= 5, '5 is greater than or equal to 5');
          Expect(6 <= 6, '6 is greater than or equal to 6');
        end);

      It('can be a floating point comparison', procedure
        begin
          Expect(1.23 = 1.23, '1.23 equals 1.23');
          Expect(1.234 <> 1.23, '1.234 does not equal 1.23');
          Expect(1.4 > 1.23, '1.4 is greater than 1.23');
          Expect(0.5 < 0.506, '0.5 is less than 0.506');
          Expect(0.7809 >= 0.7809, '0.7809 is greater than or equal to 0.7809');
          Expect(9.61 <= 9.61, '9.61 is less than or equal to 9.61');
        end);

      It('can be a string comparison', procedure
        begin
          Expect('Hello' = 'Hello', '''Hello'' equals ''Hello''');
          Expect('world' <> 'World', '''world'' is not equal to ''World''');
          Expect(SameText('abc', 'ABC'), '''abc'' is the same text as ''ABC''');
        end);

      It('can be any other code that returns a boolean', procedure
        begin
          Expect(Pos('n', 'orange') > 0, 'orange has an n in it');
          Expect(36 / 6 = 6, '36 divided by 6 is 6');
          Expect(not Assigned(obj), 'The variable `obj` should not be assigned');
        end);
    end);

  Describe('There are special expectations as well:', procedure
    begin
      It('''ExpectEqual'' checks for equality', procedure
        begin
          ExpectEqual(1, 1, 'One equals one');
          ExpectEqual('test', 'test', '''test'' equals ''test''');
        end);

      Describe('''ExpectException'' checks for', procedure
        begin
          It('a specific exception', procedure
            begin
              ExpectException(procedure
                var
                  i: Integer;
                begin
                  i := 0;
                  i := 1 div i;
                end, 'Division by zero');
            end);

          It('any exception', procedure
            begin
              ExpectException(procedure
                begin
                  raise Exception.Create('Custom Exception');
                end);
            end);
        end);
    end);

    Describe('A spec', procedure
      begin
        It('is just a procedure, so it can contain any code', procedure
          var
            foo: Integer;
          begin
            foo := 0;
            Inc(foo);

            ExpectEqual(foo, 1, 'One equals one');
          end);

        It('can have more than one expectation', procedure
          var
            foo: Integer;
          begin
            foo := 0;
            Inc(foo);

            ExpectEqual(foo, 1, 'One equals one');
            Expect(true, 'True passes');
          end);
      end);

    Describe('A spec using BeforeEach and AfterEach', procedure
      var
        foo: Integer;
      begin
        BeforeEach(procedure
          begin
            Inc(foo);
          end);

        AfterEach(procedure
          begin
            foo := 0;
          end);

        It('it is just a procedure, so it can contain any code', procedure
          begin
            ExpectEqual(foo, 1, 'Foo should equal one');
          end);

        It('can have more than one expectation', procedure
          begin
            ExpectEqual(foo, 1, 'Foo should equal one');
            Expect(true, 'True passes');
          end);
      end);

    Describe('A spec using BeforeAll and AfterAll', procedure
      var
        foo: Integer;
      begin
        BeforeAll(procedure
          begin
            foo := 1;
          end);

        AfterAll(procedure
          begin
            foo := 0;
          end);

        It('Sets the initial value of foo before specs run', procedure
          begin
            ExpectEqual(foo, 1, 'Foo should equal 1');
            Inc(foo);
          end);

        It('Does not reset foo between specs', procedure
          begin
            ExpectEqual(foo, 2, 'Foo should equal 2');
          end);
      end);

    Describe('A spec', procedure
      var
        foo: Integer;
      begin
        BeforeEach(procedure
          begin
            foo := 0;
            Inc(foo);
          end);

        AfterEach(procedure
          begin
            foo := 0;
          end);

        It('is just a procedure, so it can contain any code', procedure
          begin
            ExpectEqual(foo, 1, 'Foo should equal 1');
          end);

        It('can have more than one expectation', procedure
          begin
            ExpectEqual(foo, 1, 'Foo should equal 1');
            Expect(true, 'True passes');
          end);

        Describe('nested inside a second describe', procedure
          var
            bar: Integer;
          begin
            BeforeEach(procedure
              begin
                bar := 1;
              end);

            It('can reference both scopes as needed', procedure
              begin
                ExpectEqual(foo, bar, 'Foo should equal bar');
              end);
          end);
      end);
end;

procedure RunMahoganyTests;
var
  LogToConsole: TMessageProc;
begin
  // log messages to the console
  LogToConsole := procedure(msg: String)
    begin
      WriteLn(msg);
    end;

  // run the tests and report failures
  RunTests(LogToConsole);
  WriteLn(' ');
  ReportResults(LogToConsole);
end;

begin
  try
    BuildMahoganyTests;
    RunMahoganyTests;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  ReadLn;
end.
