unit Horse.HandleException;

interface

uses Horse, Horse.Commons, System.SysUtils;

procedure HandleException(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

uses System.JSON;

procedure HandleException(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  LJSON: TJSONObject;
begin
  try
    Next();
  except
    on E: EHorseCallbackInterrupted do
      raise;

    on E: EHorseException do
    begin
      LJSON := TJSONObject.Create;
      LJSON.AddPair('error', E.Error);
      Res.Send<TJSONObject>(LJSON).Status(E.Status);
    end;

    on E: Exception do
    begin
      LJSON := TJSONObject.Create;
      LJSON.AddPair('error', E.ClassName);
      LJSON.AddPair('description', E.Message);
      Res.Send<TJSONObject>(LJSON).Status(THTTPStatus.BadRequest);
    end;
  end;
end;

end.
