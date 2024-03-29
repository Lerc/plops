program clock;

{$mode objfpc}{$H+}

uses
sysutils,BaseUnix,Math,DateUtils;

var
  CommandPipe : Text;

procedure initclock;
begin
  Writeln(CommandPipe,'create_window bob 10 100 200 200');
  Writeln(CommandPipe,'load_image clockface Clock.png');
  Writeln(CommandPipe,'set_image bob');
  Writeln(CommandPipe,'clear_color 0 255 0 0');
  Writeln(CommandPipe,'blend_image_onto_image clockface 1 0 0 200 200 0 0 200 200');
  Writeln(CommandPipe,'set_window bob');
  Writeln(CommandPipe,'set_shape');
  Writeln(CommandPipe,'set_has_alpha false');
end;

procedure update;
var
  A : single;
  t : tDateTime;
begin
  t := now;
  Writeln(CommandPipe,'set_image bob');
  Writeln(CommandPipe,'blend_image_onto_image clockface 1 0 0 200 200 0 0 200 200');
  Writeln(CommandPipe,'set_color 0 0 0 255 ');
  A := (HourOf(t) + MinuteOf(t)/60)   *Pi*2/12 +   -Pi/2;
  writeln(CommandPipe,'draw_line 100 100 ',round(100+cos(A)*50),' ',round(100+Sin(A)*50));
  A := MinuteOf(t)*Pi*2/60-Pi/2;
  writeln(CommandPipe,'draw_line 100 100 ',Round(100+cos(A)*80),' ',Round(100+Sin(A)*80));
  Writeln(CommandPipe,'set_color 255 0 0 255 ');
  A := SecondOf(t)*Pi*2/60-Pi/2;
  writeln(CommandPipe,'draw_line 100 100 ',Round(100+cos(A)*80),' ',Round(100+Sin(A)*80));
  Writeln(CommandPipe,'update');

  Flush(CommandPipe);
end;

{$IFDEF WINDOWS}{$R clock.rc}{$ENDIF}

begin
  //BaseDir:=ExtractFilePath(Paramstr(0));
//  writeln('opening pipe '+BaseDir+'/commands');
  Assign(CommandPipe,'commands');
  Rewrite(CommandPipe);

  initclock;

  while true do
  begin
     update;
     fpsleep(1);
  end;

end.

