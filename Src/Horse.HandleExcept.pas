unit Horse.HandleExcept;

interface

uses
  Horse, System.SysUtils;

procedure HandleExcept(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

uses
  System.JSON;

procedure HandleExcept(Req: THorseRequest; Res: THorseResponse; Next: TProc);
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
