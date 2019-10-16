# handle-exception
Middleware for handle exception in HORSE

Sample Horse Server
```delphi
uses Horse, Horse.Jhonson, Horse.HandleException, System.SysUtils;

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
```
