program Vermilion;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  veMain in 'veMain.pas';

procedure BuildVermilionTests;
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

  Describe('You can evaluate expressions for expectations', procedure
    begin
      It('it can be a boolean value', procedure
        begin
          Expect(true, 'True passes');
          Expect(not false, 'Not false passes');
          Expect(true and not false, 'True and not false passes');
        end);

      It('it can be an integer comparison', procedure
        begin
          Expect(1 = 1, '1 equals 1');
          Expect(1 <> 2, '1 does not equal 2');
          Expect(3 > 2, '3 is greater than 2');
          Expect(3 < 4, '3 is less than 4');
          Expect(5 >= 5, '5 is greater than or equal to 5');
          Expect(6 <= 6, '6 is greater than or equal to 6');
        end);

      It('it can be a floating point comparison', procedure
        begin
          Expect(1.23 = 1.23, '1.23 equals 1.23');
          Expect(1.234 <> 1.23, '1.234 does not equal 1.23');
          Expect(1.4 > 1.23, '1.4 is greater than 1.23');
          Expect(0.5 < 0.506, '0.5 is less than 0.506');
          Expect(0.7809 >= 0.7809, '0.7809 is greater than or equal to 0.7809');
          Expect(9.61 <= 9.61, '9.61 is less than or equal to 9.61');
        end);

      It('it can be a string comparison', procedure
        begin
          Expect('Hello' = 'Hello', '''Hello'' equals ''Hello''');
          Expect('world' <> 'World', '''world'' is not equal to ''World''');
          Expect(SameText('abc', 'ABC'), '''abc'' is the same text as ''ABC''');
        end);

      It('it can be any other code that returns a boolean', procedure
        begin
          Expect(Pos('n', 'orange') > 0, 'orange has an n in it');
          Expect(36 / 10000 = 0, '36 divided by 10000 is 0');
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

      Describe('''ExpectException'' checks for an exception', procedure
        begin
          It('It can expect a specific exception', procedure
            begin
              ExpectException(procedure
                var
                  i: Extended;
                begin
                  i := 5 / 0;
                end, 'Division by zero');
            end);

          It('Or any exception', procedure
            begin
              ExpectException(procedure
                var
                  i: Integer;
                begin
                  i := 9999999999999;
                  i := i * i;
                end);
            end);
        end);
    end);
end;

procedure RunVermilionTests;
begin
  RunTests(procedure(msg: String)
    begin
      WriteLn(msg);
    end);
end;

begin
  try
    BuildVermilionTests;
    RunVermilionTests;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  ReadLn;
end.
