unit Horse.HandleException;

interface

uses
  Horse, System.SysUtils;

procedure HandleException(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

uses
  System.JSON;

procedure HandleException(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  LJSON: TJSONObject;
begin
  try
    Next();
  except
    on E: Exception do
    begin
      LJSON := TJSONObject.Create;
      LJSON.AddPair('error', E.ClassName);
      LJSON.AddPair('description', E.Message);
      Res
        .Send<TJSONObject>(LJSON)
        .Status(400);
    end;
  end;
end;

end.
