program graph;

{$mode objfpc}{$H+}

uses
sysutils,BaseUnix,Math,DateUtils,Pipes,TermIO;

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


type
  tDataItem = Integer;
  pDataItem = ^tDataItem;
var
  DataScope :  integer = 1024;
  DataItemCount : integer = 1;
  RecordedData : pInteger = nil;
  DataItemHead : integer = 0;
procedure InitDataBuffer;
begin
  RecordedData := reAllocMem(RecordedData,DataItemCount*DataScope*sizeof(tDataItem));
end;

function DataPosition(I : integer) : pDataItem;
begin
  Result := RecordedData + (DataItemCount * I);
end;

procedure redraw;
var
  tx : integer;
  ty : integer;
  SamplePoint : Integer;
  A,B : integer;
begin
  Writeln(CommandPipe,'set_image win');
  Writeln(CommandPipe,'blend_image_onto_image display 1 0 0 289 162 0 0 289 162');
  Writeln(CommandPipe,'set_color 128 255 0 255 ');

  SamplePoint := DataItemHead;
  B:=0;
  for  tx := 0 to 255 do
  begin
     A:=DataPosition(SamplePoint)^ div 2;
     //writeln('draw_line '+inttostr(271-tx+1)+' '+intToStr(145-B)+' ' +inttostr(271-tx)+' '+intToStr(145-A));
     Writeln(CommandPipe,'draw_line '+inttostr(271-tx+1)+' '+intToStr(145-B)+' ' +inttostr(271-tx)+' '+intToStr(145-A));
     SamplePoint-=1;
     if SamplePoint < 0 then SamplePoint := DataScope-1;
     B:=A;
  end;
  Writeln(CommandPipe,'update');
  Flush(CommandPipe);
end;

function BytesAvailable(Handle : tHandle) : integer;
begin
  if fpioctl(Handle, FIONREAD, @Result)<0 then
    Result := 0;
end;

procedure HandleInput(S : String);
var
  Walk : pDataItem;
  Neg : integer;
  A : integer;
  C : Integer;
  SWalk : pChar;
  digits : integer;
begin

  Inc(DataItemHead);
  if DataItemHead >= DataScope then DataItemHead := 0;

  Walk := DataPosition(DataItemHead);
  Swalk := pChar(s);
  A := 0;
  C := 0;
  neg := 1;
  Digits :=0;
  while (C < DataItemCount) do
  begin
     case Swalk^ of
       '-': neg :=-1;
       '0'..'9': begin
                 A:=A*10 + ord(Swalk^)-ord('0');
                 digits +=1;
                 end;
      else
        begin

          Walk^ := A * Neg;
          //writeln('input interpreted as :'+intToStr(Walk^));
          if Digits >0 then
          begin
            inc(Walk);
            C+=1;
            Digits:=0;
          end;
          Neg:=1;
          A:=0;
          if Swalk^=#0 then exit;
        end;
     end;
     inc(Swalk);
  end;
end;

procedure HandleCommand(S : string);
begin

end;

procedure HandleInputPipe;
var
  Buffer : array [0..255] of byte;
  Walk : pByte;
  C : byte;
  Line : String;
  Done : boolean;
  FDSet : tFDSet;
  InputPipe : tHandle;
  BytesInBuffer : integer;
begin
  InitDataBuffer;
  redraw;



  Done := false;
  Line := '';
  while not done do
  begin
     InputPipe:=fpOpen ('data',O_RdOnly);
{    fpFD_ZERO(FDSET);
    fpFD_SET(Inputpipe,FDSET);
    writeln('preselect');
    fpselect(InputPipe+1,@FDSET,nil,nil,10000);
    writeln('postselect');}
    BytesInBuffer := fpread(InputPipe,Buffer,1);
    Walk := addr(buffer);
    While BytesInBuffer > 0 do
    begin
       c:=Walk^;
       walk+=1;
      //writeln ('C = '+intToStr(Ord(C)));
      if c= 10 then
      begin
        //writeln('line :' +line);
        if line[1] = '!' then HandleCommand(Line) else HandleInput(Line);
  		  Line := '';
      end else
      begin
        Line+=chr(c);
      end;
      BytesInBuffer-=1;
      if BytesInBuffer = 0 then
      begin
        if BytesAvailable(InputPipe) = 0 then
        begin
          redraw;
        end
        else
        begin
          BytesInBuffer := fpread(InputPipe,Buffer,Min(256,BytesAvailable(InputPipe)));
          Walk:=addr(Buffer);
        end;
      end;
    end;
    //redraw;
    fpClose (InputPipe);
    writeln('Input handled');
   // NoEvents;
  end;
end;

{$IFDEF WINDOWS}{$R clock.rc}{$ENDIF}

{$IFDEF WINDOWS}{$R graph.rc}{$ENDIF}

begin
  //BaseDir:=ExtractFilePath(Paramstr(0));
//  writeln('opening pipe '+BaseDir+'/commands');
  Assign(CommandPipe,'commands');
  Rewrite(CommandPipe);

  initdisplay;

  HandleInputPipe;
end.

