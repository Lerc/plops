unit CommandOptions;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils; 

function OptionValue(Name:string; Default:String) : String;
function OptionExists(Name:string) : Boolean;

implementation
uses strutils;

var
  OptionList : tStringList;

  function OptionExists(Name:string) : Boolean;
  begin
    result := OptionList.IndexOfName(Name) >= 0;
  end;

  function OptionValue(Name:string; Default:String) : String;
  var
     I : integer;
  begin
    I := OptionList.IndexOfName(Name);
    if I < 0 then Result := Default else Result := OptionList.ValueFromIndex[I];
  end;


procedure LoadParameters;
var
  I : integer;
  Parameter : String;
begin
  For I := 1 to paramcount do
  begin
     Parameter:=ParamStr(I);
     if AnsiStartsStr('--',Parameter) then
     begin
       OptionList.Add(TrimLeftSet(Parameter,['-']));
     end;
  end;

end;

initialization
  OptionList := tStringList.Create;
  LoadParameters;

finalization
  OptionList.Free;
end.

