program samples;

{$APPTYPE CONSOLE}
{$R *.res}

uses Horse, Horse.Jhonson, Horse.HandleException, System.SysUtils;

begin
  THorse
    .Use(Jhonson)
    .Use(HandleException);

  THorse.Get('/ping',
    procedure(Req: THorseRequest; Res: THorseResponse)
    begin
      raise EHorseException.New.Error('My Error!');
    end);

  THorse.Listen(9000);
end.
