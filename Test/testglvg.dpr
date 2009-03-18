program Testglvg;

uses
  Forms,
  TestglvgForm in 'TestglvgForm.pas' {DGLForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TDGLForm, DGLForm);
  Application.Run;
end.
