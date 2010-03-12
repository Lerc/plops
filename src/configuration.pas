unit Configuration;

{$mode objfpc}

interface

uses
  Classes, SysUtils,inifiles;

var
    ConfigFile : tMemIniFile;
    procedure LoadConfig;
    procedure SaveConfig;

implementation

procedure LoadConfig;
begin
   ConfigFile := tMemIniFile.Create('plops.config');
end;

procedure SaveConfig;
begin
  ConfigFile.UpdateFile;
end;

end.

