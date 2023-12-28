unit Horse.HandleException;

{$IF DEFINED(FPC)}
  {$MODE DELPHI}{$H+}
{$ENDIF}

interface

uses
  {$IF DEFINED(FPC)}
  SysUtils,
  fpjson,
  TypInfo,
  {$ELSE}
  System.SysUtils,
  System.JSON,
  System.TypInfo,
  {$ENDIF}
  Horse,
  Horse.Commons;

type
{$IF DEFINED(FPC)}
  TInterceptExceptionCallback = procedure(const E: Exception; const Req: THorseRequest; const Res: THorseResponse; var ASendException: Boolean);
{$ELSE}
  TInterceptExceptionCallback = reference to procedure(const E: Exception; const Req: THorseRequest; const Res: THorseResponse; var ASendException: Boolean);
{$ENDIF}

function HandleException: THorseCallback; overload;
function HandleException(const ACallback: TInterceptExceptionCallback): THorseCallback; overload;

implementation

var
  InterceptExceptionCallback: TInterceptExceptionCallback = nil;

procedure SendException(ARes: THorseResponse; AJson: TJSONObject; const AStatus: Integer);
begin
  ARes.Send<TJSONObject>(AJson).Status(AStatus);
end;

function FormatExceptionJSON(const E: Exception): TJSONObject;
var
  LEHorseException: EHorseException;
begin
  if (E is EHorseException) then
  begin
    LEHorseException := (E as EHorseException);
    Result := {$IF DEFINED(FPC)}GetJSON(LEHorseException.ToJSON) as TJSONObject{$ELSE}TJSONObject.ParseJSONValue(LEHorseException.ToJSON) as TJSONObject{$ENDIF};
  end
  else
  begin
    Result := TJSONObject.Create;
    Result.{$IF DEFINED(FPC)}Add{$ELSE}AddPair{$ENDIF}('error', E.Message);
  end;
end;

procedure Middleware(Req: THorseRequest; Res: THorseResponse; Next: {$IF DEFINED(FPC)}TNextProc{$ELSE}TProc{$ENDIF});
var
  LJSON: TJSONObject;
  LStatus: Integer;
  LSendException: Boolean;
begin
  try
    Next();
  except
    on E: Exception do
    begin
      if (E is EHorseCallbackInterrupted) then
        raise;

      LSendException := True;
      if Assigned(InterceptExceptionCallback) then
        InterceptExceptionCallback(E, Req, Res, LSendException);

      if not LSendException then
        Exit;

      LJSON := FormatExceptionJSON(E);
      if (E is EHorseException) then
        SendException(Res, LJSON, Integer(EHorseException(E).Status))
      else
      begin
        LStatus := Res.Status;
        if (LStatus < Integer(THTTPStatus.BadRequest)) then
          LStatus := Integer(THTTPStatus.InternalServerError);
        SendException(Res, LJSON, LStatus);
      end;
    end;
  end;
end;

function HandleException: THorseCallback; overload;
begin
  Result := HandleException(nil);
end;

function HandleException(const ACallback: TInterceptExceptionCallback): THorseCallback; overload;
begin
  InterceptExceptionCallback := ACallback;
  Result := Middleware;
end;

end.
