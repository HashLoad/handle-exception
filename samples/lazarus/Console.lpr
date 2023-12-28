program Console;

{$MODE DELPHI}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  fpjson,
  Horse,
  Horse.Jhonson,
  Horse.HandleException,
  SysUtils;

procedure GetPing(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
begin
  raise EHorseException.New.Error('My Error!');
end;

//procedure Example02(const E: Exception; const Req: THorseRequest; const Res: THorseResponse; var ASendException: Boolean);
//var
//  LGUID: TGUID;
//  LMessage: string;
//begin
//  CreateGUID(LGUID);
//  LMessage := Format('ID: %s - Message: %s', [GUIDToString(LGUID), E.Message]);
//  Writeln(LMessage);
//end;

//procedure Example03(const E: Exception; const Req: THorseRequest; const Res: THorseResponse; var ASendException: Boolean);
//var
//  LGUID: TGUID;
//  LMessage: string;
//  LJSON: TJSONObject;
//begin
//  ASendException := False;
//  CreateGUID(LGUID);
//  LMessage := Format('ID: %s - Message: %s', [GUIDToString(LGUID), E.Message]);
//  Writeln(LMessage);
//  LJSON := TJSONObject.Create;
//  LJSON.Add('myCustomError', E.Message);
//  Res.Send<TJSONObject>(LJSON).Status(THTTPStatus.InternalServerError);
//end;

begin
  {$region 'Example 01: Handle-exception is responsible for notifying the client (Default)'}
  THorse
    .Use(Jhonson)
    .Use(HandleException);
  {$endregion}

  {$region 'Example 02: Handle-exception is responsible for notifying the client using the TInterceptExceptionCallback Callback'}
  //THorse
  //  .Use(Jhonson)
  //  .Use(HandleException(Example02));
  {$endregion}

  {$region 'Example 03: Developer is responsible for notifying the client using the TInterceptExceptionCallback Callback'}
  //THorse
  //  .Use(Jhonson)
  //  .Use(HandleException(Example03));
  {$endregion}

  THorse.Get('/ping', GetPing);

  THorse.Listen(9000);
end.
