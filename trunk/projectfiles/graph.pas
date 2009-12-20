program graph;

{$mode objfpc}{$H+}

uses
sysutils,BaseUnix,Math,DateUtils;

var
  CommandPipe : Text;

procedure initdisplay;
begin
  Writeln(CommandPipe,'create_window win 550 650 289 162');
  Writeln(CommandPipe,'load_image display Screen_256x128.png');
  Writeln(CommandPipe,'set_image win');
  Writeln(CommandPipe,'clear_color 0 255 0 0');
  Writeln(CommandPipe,'blend_image_onto_image display 1 0 0 289 162 0 0 289 162');
  Writeln(CommandPipe,'set_window win');
  Writeln(CommandPipe,'set_shape');
  Writeln(CommandPipe,'set_has_alpha false');
 Writeln(CommandPipe,'update');

  Flush(CommandPipe);
end;



{$IFDEF WINDOWS}{$R clock.rc}{$ENDIF}

{$IFDEF WINDOWS}{$R graph.rc}{$ENDIF}

begin
  //BaseDir:=ExtractFilePath(Paramstr(0));
//  writeln('opening pipe '+BaseDir+'/commands');
  Assign(CommandPipe,'commands');
  Rewrite(CommandPipe);

  initdisplay;

  while true do
  begin

     fpsleep(1);
  end;

end.

