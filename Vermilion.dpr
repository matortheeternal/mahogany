program Vermilion;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  veMain in 'veMain.pas';

begin
  try
    { TODO -oUser -cConsole Main : Insert code here }
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
