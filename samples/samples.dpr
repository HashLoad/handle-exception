program samples;

{$APPTYPE CONSOLE}

uses
  Horse,
  Horse.Jhonson,
  Horse.HandleException,
  System.SysUtils;

{$R *.res}

var
  App: THorse;

begin
  App := THorse.Create(9000);

  App.Use(Jhonson);
  App.Use(HandleException);

  App.Get('ping',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      raise Exception.Create('Meu erro personalizado!');
    end);

  App.Start;
end.
