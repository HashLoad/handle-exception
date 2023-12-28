program samples;

{$APPTYPE CONSOLE}
{$R *.res}

uses Horse, Horse.Jhonson, Horse.HandleException, System.SysUtils, System.JSON;

begin
  {$region 'Example 01: Handle-exception is responsible for notifying the client (Default)'}
  THorse
    .Use(Jhonson)
    .Use(HandleException);
  {$endregion}

  {$region 'Example 02: Handle-exception is responsible for notifying the client using the TInterceptExceptionCallback Callback'}
//  THorse
//    .Use(Jhonson)
//    .Use(HandleException(
//      procedure(const E: Exception; const Req: THorseRequest; const Res: THorseResponse; var ASendException: Boolean)
//      var
//        LGUID: TGUID;
//        LMessage: string;
//      begin
//        CreateGUID(LGUID);
//        LMessage := Format('ID: %s - Message: %s', [GUIDToString(LGUID), E.Message]);
//        Writeln(LMessage);
//      end));
  {$endregion}

  {$region 'Example 03: Developer is responsible for notifying the client using the TInterceptExceptionCallback Callback'}
//  THorse
//    .Use(Jhonson)
//    .Use(HandleException(
//      procedure(const E: Exception; const Req: THorseRequest; const Res: THorseResponse; var ASendException: Boolean)
//      var
//        LGUID: TGUID;
//        LMessage: string;
//      begin
//        ASendException := False;
//        CreateGUID(LGUID);
//        LMessage := Format('ID: %s - Message: %s', [GUIDToString(LGUID), E.Message]);
//        Writeln(LMessage);
//        Res.Send<TJSONObject>(TJSONObject.Create.AddPair('myCustomError', E.Message)).Status(THTTPStatus.InternalServerError);
//      end));
  {$endregion}

  THorse.Get('/ping',
    procedure(Req: THorseRequest; Res: THorseResponse)
    begin
      raise EHorseException.New.Error('My Error!');
    end);

  THorse.Listen(9000,
    procedure
    begin
      Writeln('Server is running on port ' + THorse.Port.ToString);
    end);
end.
