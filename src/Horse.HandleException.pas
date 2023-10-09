unit Horse.HandleException;

{$IF DEFINED(FPC)}
{$MODE DELPHI}{$H+}
{$ENDIF}

interface

uses
  {$IF DEFINED(FPC)}
  SysUtils, fpjson,
  {$ELSE}
  System.SysUtils, System.JSON,
  {$ENDIF}
  Horse, Horse.Commons;

type
{$IF DEFINED(FPC)}
  TInterceptExceptionCallback = {$IF DEFINED(HORSE_FPC_FUNCTIONREFERENCES)}reference to {$ENDIF}procedure(AException: Exception; AResponse: THorseResponse; var ASendException: Boolean);
{$ELSE}
  TInterceptExceptionCallback = reference to procedure(AException: Exception; AResponse: THorseResponse; var ASendException: Boolean);
{$ENDIF}

function HandleException: THorseCallback; overload;
function HandleException(const ACallback: TInterceptExceptionCallback): THorseCallback; overload;
procedure Middleware(Req: THorseRequest; Res: THorseResponse; Next: {$IF DEFINED(FPC)}TNextProc{$ELSE}TProc{$ENDIF});

function FormatExceptionJSON(AException: Exception): TJSONObject;

implementation

uses
  {$IF DEFINED(FPC)}
  TypInfo;
  {$ELSE}
  System.TypInfo;
  {$ENDIF}

var
  InterceptExceptionCallback: TInterceptExceptionCallback = nil;

procedure SendException(ARes: THorseResponse; AJson: TJSONObject; const AStatus: Integer);
begin
  ARes.Send<TJSONObject>(AJson).Status(AStatus);
end;

function FormatExceptionJSON(AException: Exception): TJSONObject;
var
  LEHorseException: EHorseException;
begin
  if (AException is EHorseException) then
  begin
    LEHorseException := (AException as EHorseException);
    Result := {$IF DEFINED(FPC)}GetJSON(LEHorseException.ToJSON) as TJSONObject{$ELSE}TJSONObject.ParseJSONValue(LEHorseException.ToJSON) as TJSONObject{$ENDIF};
  end
  else
  begin
    Result := TJSONObject.Create;
    Result.{$IF DEFINED(FPC)}Add{$ELSE}AddPair{$ENDIF}('error', AException.Message);
  end;
end;

procedure Middleware(Req: THorseRequest; Res: THorseResponse; Next: {$IF DEFINED(FPC)}TNextProc{$ELSE}TProc{$ENDIF});
var
  LJSON: TJSONObject;
  LStatus: Integer;
  lSendException: Boolean;
begin
  try
    Next();
  except
    on E: Exception do
    begin
      if (E is EHorseCallbackInterrupted) then
        raise;

      lSendException := True;
      if Assigned(InterceptExceptionCallback) then
        InterceptExceptionCallback(E, Res, lSendException);

      if not lSendException then
        Exit;

      if (E is EHorseException) then
      begin
        LJSON := FormatExceptionJSON(E);
        SendException(Res, LJSON, Integer(EHorseException(E).Status));
      end
      else
      begin
        LStatus := Res.Status;
        if (LStatus < Integer(THTTPStatus.BadRequest)) then
          LStatus := Integer(THTTPStatus.InternalServerError);
        LJSON := FormatExceptionJSON(E);
        SendException(Res, LJSON, LStatus);
      end;
    end;
  end;
end;

function HandleException: THorseCallback; overload;
begin
  Result := Middleware;
end;

function HandleException(const ACallback: TInterceptExceptionCallback): THorseCallback; overload;
begin
  InterceptExceptionCallback := ACallback;
  Result := Middleware;
end;

end.
