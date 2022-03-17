program Console;

{$MODE DELPHI}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Horse,
  Horse.Jhonson,
  Horse.HandleException,
  SysUtils;

procedure GetPing(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
begin
  raise EHorseException.New.Error('My Error!');
end;

begin
  THorse
    .Use(Jhonson)
    .Use(HandleException);

  THorse.Get('/ping', GetPing);

  THorse.Listen(9000);
end.
