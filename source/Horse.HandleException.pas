unit Horse.HandleException;

{$IF DEFINED(FPC)}
{$MODE DELPHI}{$H+}
{$ENDIF}

interface

uses
  {$IF DEFINED(FPC)}
  SysUtils,
  {$ELSE}
  System.SysUtils,
  {$ENDIF}
  Horse, Horse.Commons;

procedure HandleException(Req: THorseRequest; Res: THorseResponse; Next: {$IF DEFINED(FPC)}TNextProc{$ELSE}TProc{$ENDIF});

implementation

uses
  {$IF DEFINED(FPC)}
  fpjson, TypInfo;
  {$ELSE}
  System.JSON, System.TypInfo;
  {$ENDIF}

procedure SendError(ARes:THorseResponse; AJson: TJSONObject; AStatus: Integer);
begin
  ARes.Send<TJSONObject>(AJson).Status(AStatus);
end;

procedure HandleException(Req: THorseRequest; Res: THorseResponse; Next: {$IF DEFINED(FPC)}TNextProc{$ELSE}TProc{$ENDIF});
var
  LJSON: TJSONObject;
  LStatus: Integer;
begin
  try
    Next();
  except
    on E: EHorseCallbackInterrupted do
      raise;
    on E: EHorseException do
    begin
      LJSON := {$IF DEFINED(FPC)}GetJSON(E.ToJSON) as TJSONObject{$ELSE}TJSONObject.ParseJSONValue(E.ToJSON) as TJSONObject{$ENDIF};
      SendError(Res, LJSON, Integer(E.Status));
    end;
    on E: Exception do
    begin
      LStatus := Res.Status;
      if (LStatus < Integer(THTTPStatus.BadRequest)) then
        LStatus := Integer(THTTPStatus.InternalServerError);
      LJSON := TJSONObject.Create;
      LJSON.{$IF DEFINED(FPC)}Add{$ELSE}AddPair{$ENDIF}('error', E.Message);
      SendError(Res, LJSON, LStatus);
    end;
  end;
end;

end.
