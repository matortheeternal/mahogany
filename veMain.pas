unit veMain;

interface

uses
  SysUtils, Classes;

type
  TProc = reference to procedure;
  ITest = interface
    ['{C05D06D7-62D0-C7F0-D9B7-B86A41202749}']
    property context: ITest;
    property description: String;
    property passed: Boolean;
    procedure Execute;
  end;
  ISuite = interface(ITest)
    property children: TInterfaceList;
    property beforeEach: TProc;
    property afterEach: TProc;
    property beforeAll: TProc;
    property afterAll: TProc;
    constructor Create(description: String; callback: TProc);
    procedure Execute;
    procedure AddChild(child: ITest);
    destructor Destroy;
  end;
  ISpec = interface(ITest)
    property callback: TProc;
    constructor Create(description: String; callback: TProc);
    procedure Execute;
    procedure Fail(x: Exception); overload;
    procedure Fail(msg: String); overload;
  end;
  IFailure = interface
    property context: ISpec;
    property exception: Exception;
    constructor Create(context: ISpec; exception: Exception);
    procedure MarkContextFailed;
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
  procedure BuildFailedException(target, description: String; x: Exception);

var
  MainSuites: TInterfaceList;
  Failures: TList;
  ActiveSuite: ISuite;

implementation


{******************************************************************************}
{ Public API
  These functions provide the public API for Vermilion.
}
{******************************************************************************}

{ Suite Functions }
procedure Describe(description: String; callback: TProc);
begin
  try
    ISuite.Create(description, callback);
  except
    on x: Exception do
      BuildFailedException('test suite', description, x);
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
    CannotCallException('AfterAll', 'Describe');
  ActiveSuite.afterAll := callback;
end;

procedure BeforeEach(callback: TProc);
begin
  if (ActiveSuite = nil) then
    CannotCallException('BeforeEach', 'Describe');
  ActiveSuite.beforeEach := callback;
end;

procedure AfterEach(callback: TProc);
begin
  if (ActiveSuite = nil) then
    CannotCallException('AfterEach', 'Describe');
  ActiveSuite.afterEach := callback;
end;

{ Spec Functions }
procedure It(description: String; callback: TProc);
begin
  if (ActiveSuite = nil) then
    CannotCallException('It', 'Describe');
  try
    ISpec.Create(description, callback);
  except
    on x: Exception do
      BuildFailedException('spec', description, x);
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

procedure BuildFailedException(target, description: String; x: Exception);
const
  BuildFailedError = 'Failed to build %s "%s": %s';
begin
  x.Message := Format(BuildFailedError, [target, description, x.Message]);
  raise x;
end;

{ TSuite }
constructor ISuite.Create(description: String; callback: TProc);
begin
  // suites can be nested inside of each other
  context := nil;
  if Assigned(ActiveSuite) then begin
    context := ActiveSuite as ITest;
    ActiveSuite.AddChild(self as ITest);
  end; 
  
  // set input properties
  self.description := description;
  children := TInterfaceList.Create;
  // the suite passes if it has no specs
  passed := true;

  // build nested specs/suites
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

procedure ISuite.Execute;
var
  i: Integer;
  test: ITest;
begin
  // Setup before all tests if given
  if Assigned(BeforeAll) then BeforeAll;

  // execute each test in the suite
  for i := 0 to Pred(children.Count) do begin
    if Supports(children[i], ITest, test) then begin
      // Setup before each test if given
      if Assigned(BeforeEach) then BeforeEach;
      // execute the test
      test.Execute;
      // Tear down after each test if given
      if Assigned(AfterEach) then AfterEach;
    end;
  end;

  // Tear down after all tests if given
  if Assigned(AfterAll) then AfterAll;
end;

procedure ISuite.AddChild(child: ITest);
begin
  children.Add(child);
end;

destructor ISuite.Destroy;
begin
  children.Free;
  inherited;
end;

{ ISpec }
constructor ISpec.Create(description: String; callback: TProc);
begin                
  // enumerate the spec in the active suite's children
  context := ActiveSuite as ITest;  
  ActiveSuite.AddChild(self as ITest);
  // set input properties
  self.description := description;
  self.callback := callback;
  // the spec passes if it has no expectations
  passed := true;
end;

procedure ISpec.Execute;
begin
  try
    callback();
  except
    on x: Exception do
      fail(x);
  end;
end;

procedure ISpec.Fail(x: Exception); overload;
begin
  IFailure.Create(self, x);
end;

procedure ISpec.Fail(msg: String); overload;
begin
  IFailure.Create(self, Exception.Create(msg));
end;

{ IFailure }
constructor IFailure.Create(context: ISpec; exception: Exception);
begin
  self.context := context as ITest;
  self.exception := exception; 
  MarkContextFailed;
  Failures.Add(self);
end;

procedure IFailure.MarkContextFailed;
const
  // this saves us from an infinite loop if there is a recursive context
  maxTestDepth = 100;
  MaxTestDepthError = 'Max test depth of 100 reached, check for recursive contexts.';
var
  currentContext: ITest;
  i: Integer;
begin
  currentContext := self.context;
  i := 1;
  while Assigned(currentContext) do begin
    currentContext.passed := false;
    currentContext := currentContext.context;  
    if (i = maxTestDepth) then 
      raise Exception.Create(MaxTestDepthError);
    Inc(i);
  end;
end;

{ Initialization and Finalization }
initialization
begin
  ActiveSuite := nil;
  MainSuites := TInterfaceList.Create;
  Failures := TInterfaceList.Create;
end;

finalization
begin
  MainSuites.Free;
  Failures.Free;
end;

end.
