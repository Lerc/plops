program battery;

{$mode objfpc}{$H+}

uses
sysutils,BaseUnix,Math,DateUtils,Classes,process, plopscommands;

var
  CommandPipe : Text;


function RunProgram(cmdline : String) : String;
  var
     p : tProcess;
     output : tStringList;
  begin
     p := tProcess.Create(nil);
     Output := tStringlist.create;

     p.Commandline:=cmdline;
     p.Options := p.Options + [poWaitonExit,poUsePipes];
     p.Execute;
     Output.LoadFromStream(p.Output);
     Result := Output.text;
     output.free;
     P.Free;
end;

procedure initBattery;
begin
  Writeln(CommandPipe,'create_window battery 300 200 64 128');
  Writeln(CommandPipe,'load_image batt Battery.png');
  Writeln(CommandPipe,'set_image battery');
  Writeln(CommandPipe,'clear_color 0 255 0 0');
  Writeln(CommandPipe,'blend_image_onto_image batt 1 0 0 64 128 0 0 64 128');
  Writeln(CommandPipe,'set_window battery');
  Writeln(CommandPipe,'set_shape');
  Writeln(CommandPipe,'set_has_alpha false');
end;

Function GetChargePercentage : integer;
begin
  Result := StrToIntDef(trim(RunProgram('./readbattery')),0);
end;

procedure update;
var
  I : integer;
  ty : integer;
  charge : integer;
begin

  Charge := GetChargePercentage;
  Writeln(CommandPipe,'set_image battery');
  Writeln(CommandPipe,'blend_image_onto_image batt 1 0 0 200 200 0 0 200 200');
  Writeln(CommandPipe,'set_color 64 255 64 255 ');

  I := 0;
  ty := 102;
  while I <= Charge do
  begin
     writeln(CommandPipe,'draw_line 23 ',ty,' 39 ',ty);
     writeln(CommandPipe,'draw_line 23 ',ty-1,' 39 ',ty-1);
     writeln(CommandPipe,'draw_line 23 ',ty-2,' 39 ',ty-2);
     ty-=5;
     I := I + 10;

  end;
  Writeln(CommandPipe,'update');

  Flush(CommandPipe);
end;

{$IFDEF WINDOWS}{$R battery.rc}{$ENDIF}

begin
  //BaseDir:=ExtractFilePath(Paramstr(0));
//  writeln('opening pipe '+BaseDir+'/commands');
  Assign(CommandPipe,'commands');
  Rewrite(CommandPipe);




  initbattery;

  while true do
  begin
     update;
     fpsleep(30);
  end;

end.

