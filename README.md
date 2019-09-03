# handle-exception
Middleware for handle exception in HORSE

Sample Horse Server
```delphi
uses
  Horse, Horse.HandleException;

var
  App: THorse;

begin
  App := THorse.Create(9000);

  App.Use(HandleException);

  App.Post('ping',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
        raise Exception.Create('My error!');
    end);

  App.Start;
end.
```
