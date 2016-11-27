unit veMain;

interface

uses
  SysUtils, Classes;

type
  TProc = reference to procedure;
  TSuite = class(TObject)
  public
    context: TSuite;
    description: String;
    passed: Boolean;
    children: TList;
    beforeEach: TProc;
    afterEach: TProc;
    beforeAll: TProc;
    afterAll: TProc;
    constructor Create(description: String; callback: TProc);
    destructor Destroy;
  end;
  TSpec = class(TObject)
  public
    context: TSuite;
    description: String;
    passed: Boolean;
    callback: TProc;
  end;
  TFailure = class(TObject)
  public
    context: TSpec;
    exception: Exception;
  end;

  // PUBLIC API
  procedure Describe(description: String; callback: TProc);
  procedure BeforeAll(callback: TProc);
  procedure AfterAll(callback: TProc);
  procedure BeforeEach(callback: TProc);
  procedure AfterEach(callback: TProc);
  procedure It(description: String; callback: TProc);

  // PRIVATE
  procedure CannotCallException(target, context: String);

var
  MainSuites: TList;
  Failures: TList;
  ActiveSuite: TSuite;

implementation


{******************************************************************************}
{ Public API
  These functions provide the public API for Vermilion.
}
{******************************************************************************}

{ Suite Functions }
procedure Describe(description: String; callback: TProc);
const
  BuildFailedError = 'Failed to build test suite "%s": %s';
begin
  try
    TSuite.Create(description, callback);
  except
    on x: Exception do begin
      x.Message := Format(BuildFailedError, [description, x.Message]);
      raise x;
    end;
  end;
end;

{ Setup Functions }
procedure BeforeAll(callback: TProc);
begin
  if (ActiveSuite = nil) then
    CannotCallException('BeforeAll', 'Describe');
  ActiveSuite.beforeAll := callback;
end;

procedure AfterAll(callback: TProc);
begin
  if (ActiveSuite = nil) then
    raise Exception.Create('You cannot call AfterAll outside of a "describe".');
  ActiveSuite.afterAll := callback;
end;

procedure BeforeEach(callback: TProc);
begin
  if (ActiveSuite = nil) then
    raise Exception.Create('You cannot call BeforeEach outside of a "describe".');
  ActiveSuite.beforeEach := callback;
end;

procedure AfterEach(callback: TProc);
begin
  if (ActiveSuite = nil) then
    raise Exception.Create('You cannot call AfterEach outside of a "describe".');
  ActiveSuite.afterEach := callback;
end;

{ Spec Functions }
procedure It(description: String; callback: TProc);
const
  BuildFailedError = 'Failed to build spec "%s": %s';
begin
  if (ActiveSuite = nil) then
    raise Exception.Create('You cannot use call It outside of a "describe".');
  try
    TSpec.Create(description, callback);
  except
    on x: Exception do begin
      x.Message := Format(BuildFailedError, [description, x.Message]);
      raise x;
    end;
  end;
end;


{******************************************************************************}
{ Private
  These functions are private to Vermilion.  You should not call them from
  your code.
}
{******************************************************************************}

{ Error Handling }
procedure CannotCallException(target, context: String);
const
  CannotCallError = 'You cannot call "%s" outside of a "%s".';
begin
  raise Exception.Create(Format(CannotCallError, [target, context]));
end;

{ TSuite }
constructor TSuite.Create(description: String; callback: TProc);
begin
  context := ActiveSuite;
  self.description := description;
  children := TList.Create;
  // the suite passes if it has no specs
  passed := true;
  try
    // the suite is active in the context of its callback
    ActiveSuite := self;
    callback();
    // the suite is a main suite if it doesn't have a parent context
    if (context = nil) then
      MainSuites.Add(self);
  finally
    // the suite should no longer be active once its callback completes
    ActiveSuite := context;
  end;
end;

destructor TSuite.Destroy;
begin
  children.Free;
  inherited;
end;

{ TSpec }
constructor TSpec.Create(description: String; callback: TProc);
begin
  context := ActiveSuite;
end;

{ TFailure }

{ Initialization and Finalization }
initialization
begin
  ActiveSuite := nil;
  MainSuites := TList.Create;
  Failures := TList.Create;
end;

finalization
begin
  MainSuites.Free;
  Failures.Free;
end;

end.
