program Lig4;

uses
  FMX.Forms,
  Main in 'Main.pas' {FMain};

{$R *.res}

var
  _Main: TFMain;

begin
  ReportMemoryLeaksOnShutdown := true;
  Application.Initialize;
  Application.CreateForm(TFMain, _Main);
  Application.Run;

end.
