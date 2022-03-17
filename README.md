# handle-exception
<b>Handle-exception</b> is a official middleware for handling exceptions in APIs developed with the <a href="https://github.com/HashLoad/horse">Horse</a> framework.
<br>We created a channel on Telegram for questions and support:<br><br>
<a href="https://t.me/hashload">
  <img src="https://img.shields.io/badge/telegram-join%20channel-7289DA?style=flat-square">
</a>

## ⭕ Prerequisites
[**jhonson**](https://github.com/HashLoad/jhonson) - Jhonson is a official middleware for working with JSON in APIs developed with the Horse framework.

*Obs: If you use Boss (dependency manager for Delphi), the jhonson will be installed automatically when installing handle-exception.*

## ⚙️ Installation
Installation is done using the [`boss install`](https://github.com/HashLoad/boss) command:
``` sh
boss install handle-exception
```
If you choose to install manually, simply add the following folders to your project, in *Project > Options > Resource Compiler > Directories and Conditionals > Include file search path*
```
../handle-exception/src
```

## ✔️ Compatibility
This middleware is compatible with projects developed in:
- [X] Delphi
- [X] Lazarus

## ⚡️ Quickstart Delphi
```delphi
uses 
  Horse, 
  Horse.Jhonson, // It's necessary to use the unit
  Horse.HandleException, // It's necessary to use the unit
  System.JSON;

begin
  // It's necessary to add the middlewares in the Horse:
  THorse
    .Use(Jhonson) // It has to be before the exceptions middleware
    .Use(HandleException);

  THorse.Post('/ping',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      // Manage your exceptions:
      raise EHorseException.New.Error('My Error!');
    end);

  THorse.Listen(9000);
end;
```

## ⚡️ Quickstart Lazarus
```delphi
{$MODE DELPHI}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Horse,
  Horse.Jhonson, // It's necessary to use the unit
  Horse.HandleException, // It's necessary to use the unit
  SysUtils;

procedure GetPing(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
begin
  // Manage your exceptions:
  raise EHorseException.New.Error('My Error!');
end;

begin
  // It's necessary to add the middlewares in the Horse:
  THorse
    .Use(Jhonson) // It has to be before the exceptions middleware
    .Use(HandleException);

  THorse.Get('/ping', GetPing);

  THorse.Listen(9000);
end.
```

## ⚠️ License
`handle-exception` is free and open-source middleware licensed under the [MIT License](https://github.com/HashLoad/handle-exception/blob/master/LICENSE).
