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
begin
  try
    Next();
  except
    on E: EHorseCallbackInterrupted do
      raise;

    on E: EHorseException do
    begin
      LJSON := TJSONObject.Create;
      LJSON.{$IF DEFINED(FPC)}Add{$ELSE}AddPair{$ENDIF}('error', E.Error);

      if not E.Title.Trim.IsEmpty then
      begin
        LJSON.{$IF DEFINED(FPC)}Add{$ELSE}AddPair{$ENDIF}('title', E.Title);
      end;

      if not E.&Unit.Trim.IsEmpty then
      begin
        LJSON.{$IF DEFINED(FPC)}Add{$ELSE}AddPair{$ENDIF}('unit', E.&Unit);
      end;

      if E.Code <> 0 then
      begin
        LJSON.{$IF DEFINED(FPC)}Add{$ELSE}AddPair{$ENDIF}('code', {$IF DEFINED(FPC)}TJSONIntegerNumber{$ELSE}TJSONNumber{$ENDIF}.Create(E.Code));
      end;

      if E.&Type <> TMessageType.Error then
      begin
        LJSON.{$IF DEFINED(FPC)}Add{$ELSE}AddPair{$ENDIF}('type', GetEnumName(TypeInfo(TMessageType), Integer(E.&Type)));
      end;

      SendError(Res, LJSON, E.Code);
    end;

    on E: Exception do
    begin
      LJSON := TJSONObject.Create;
      LJSON.{$IF DEFINED(FPC)}Add{$ELSE}AddPair{$ENDIF}('error', E.ClassName);
      LJSON.{$IF DEFINED(FPC)}Add{$ELSE}AddPair{$ENDIF}('description', E.Message);
      SendError(Res, LJSON, Integer(THTTPStatus.BadRequest));
    end;
  end;
end;

end.
