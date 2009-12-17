unit InteractiveWidget;

{$mode objfpc}{$H+}

interface

uses
   Classes, sysutils,BaseUnix,Math,DateUtils, WidgetButtons,Pipes;
  type

     { tInteractiveWidget }

     tInteractiveWidget = class
         public
         ButtonUnderMouseDown : tWidgetButton;
         CommandPipe : Text;
         EventPipe : tHandle;
         BaseDir : String;
         EventStream : tInputPipeStream;
         ButtonSet : tWidgetButtonSet;

         Constructor Create;
         Destructor Destroy; override;
         procedure init; virtual abstract;
         procedure EventLoop; virtual;
         procedure NoEvents; virtual;
         procedure DrawButton(b:tWidgetButton);
         procedure DrawAllButtons;
         procedure HandleEvent(Event : string); virtual;
         procedure InitWidgetIO;
         procedure CloseWidgetIO;
         procedure MouseDown(button,X,Y : integer); virtual;
         procedure MouseUp(button,X,Y : integer); virtual;
         procedure KeyPress(Code : integer;State :integer;keysym : integer; keyascii : integer); virtual;
         procedure KeyRelease(Code : integer;State :integer;keysym : integer); virtual;
     end;

var
  UpdateRequested : boolean;

implementation

{ tInteractiveWidget }

constructor tInteractiveWidget.Create;
begin
   ButtonSet := tWidgetButtonSet.Create('Base','Down');
   InitWidgetIO;
end;

destructor tInteractiveWidget.Destroy;
begin
  CloseWidgetIO;
  ButtonSet.Free;
  inherited Destroy;
end;

procedure tInteractiveWidget.EventLoop;
var
  C : integer;
  Line : String;
  Done : boolean;
  FDSet : tFDSet;
begin
  Writeln ('Calculator event loop');
  fpFD_ZERO(FDSET);
  fpFD_SET(EventStream.Handle,FDSET);

  Done := false;
  Line := '';
  while not done do
  begin
    fpselect(EventStream.Handle+1,@FDSET,nil,nil,16);
    while EventStream.NumBytesAvailable > 0 do
    begin
      c := EventStream.ReadByte();
      if c= 10 then
      begin
        HandleEvent(Line);
  	    //writeln( 'Event:' +Line);
  		  Line := '';
      end else
      begin
        Line+=chr(c);
      end;
    end;
    NoEvents;
  end;
end;

procedure tInteractiveWidget.NoEvents;
begin

end;



procedure tInteractiveWidget.DrawButton(b: tWidgetButton);
var
  Bounds : string;
  Image : String;
begin
  Bounds := intToStr(b.Left)+' '+intToStr(b.Top)+' '+intToStr(B.Width)+' '+intToStr(b.Height);
  if b.Down then Image := ButtonSet.DownImage else Image := ButtonSet.BaseImage;
  Writeln(CommandPipe,'blend_image_onto_image '+Image+' 1 '+bounds+' '+bounds);
  if B.hilighted then
  begin
    Writeln(CommandPipe,'set_color 255 255 255 64');
    Writeln(CommandPipe,'fill_rectangle '+bounds);
  end;
  UpdateRequested:=true;

end;

procedure tInteractiveWidget.DrawAllButtons;
var
  I : integer;
  b : tWidgetButton;
begin
  for I := 0 to ButtonSet.Buttons.count-1 do
  begin
    DrawButton(ButtonSet.Buttons[I]);
  end;
end;

procedure tInteractiveWidget.HandleEvent(Event: string);
var
  parameters : tStringlist;
  EventName :string;
  buttonNumber : integer;
  X,Y : integer;

begin
  Parameters := tStringlist.create;
  Parameters.Delimiter:=' ';
  Parameters.DelimitedText:=Event;


  EventName := Parameters[0];

  if EventName = 'buttonpress' then
  begin
    ButtonNumber := strtoInt(Parameters[1]);
    X:= strtoInt(Parameters[2]);
    Y:= strtoInt(Parameters[3]);
    MouseDown(ButtonNumber,X,Y);
  end;
  if EventName = 'buttonrelease' then
  begin
    ButtonNumber := strtoInt(Parameters[1]);
    X:= strtoInt(Parameters[2]);
    Y:= strtoInt(Parameters[3]);
    MouseUp(ButtonNumber,X,Y);
  end;
  if EventName = 'keypress' then
  begin
    //writeln('event:',event);
    KeyPress(StrToInt(Parameters[1]),StrToInt(Parameters[2]),StrToInt(Parameters[3]),StrToInt(Parameters[4]));
  end;
  if EventName = 'keyRelease' then
  begin
    KeyRelease(StrToInt(Parameters[1]),StrToInt(Parameters[2]),StrToInt(Parameters[3]));
  end;
end;

procedure tInteractiveWidget.InitWidgetIO;
begin
  Assign(CommandPipe,'commands');
  Rewrite(CommandPipe);
  EventPipe:=fpOpen ('events',o_NonBlock,O_RdOnly);
  EventStream := tInputPipeStream.Create(EventPipe);
end;

procedure tInteractiveWidget.CloseWidgetIO;
begin
  Close(CommandPipe);
  EventStream.free;
end;

procedure tInteractiveWidget.MouseDown(button, X, Y: integer);
var
  ButtonUnderMouse : tWidgetButton;
  I  : integer;
  B : tWidgetButton;
  WasUp : boolean;
begin
  ButtonUnderMouse := ButtonSet.FindButton(X,Y);
  if assigned(ButtonUnderMouse) then
  begin
    ButtonUnderMouse.DoMouseDown(button,x,y);
  end;
  if button = 1 then
  begin
    if ButtonUnderMouse<>ButtonUnderMouseDown then
    begin
      if assigned(ButtonUnderMouseDown) then
      begin
        ButtonUnderMouseDown.Down:=False;
        DrawButton(ButtonUnderMouseDown);
      end;
      ButtonUnderMouseDown := ButtonUnderMouse;
      if assigned(ButtonUnderMouseDown) then
      begin
        If ButtonUnderMouseDown.canToggle then
        begin
          ButtonUnderMouseDown.Down:=not ButtonUnderMouseDown.Down;
          DrawButton(ButtonUnderMouseDown);
          ButtonUnderMouseDown := nil;
        end
        else
        begin
          Wasup :=not ButtonUnderMouseDown.Down;
          ButtonUnderMouseDown.Down:=true;
          DrawButton(ButtonUnderMouseDown);
          if ButtonUnderMouseDown.group <> 0 then
          begin
               for I := 0 to ButtonSet.Buttons.count-1 do
               begin
                  b := ButtonSet.Buttons[I];
                  if (b.group = ButtonUnderMouseDown.group) and (b <> ButtonUnderMouseDown) and b.Down then
                  begin
                    b.Down := false;
                    DrawButton(B);
                  end;
               end;
            if WasUp then ButtonUnderMouseDown.DoClick;
            ButtonUnderMouseDown:=nil;
          end;
        //ButtonUnderMouseDown.Hilighted:=true;
        end;
      end;
    end;
  end;
end;

procedure tInteractiveWidget.MouseUp(button, X, Y: integer);
var
  ButtonUnderMouse : tWidgetButton;
begin
  ButtonUnderMouse := ButtonSet.FindButton(X,Y);
  if assigned(ButtonUnderMouse) then
  begin
    ButtonUnderMouse.DoMouseUp(button,x,y);
  end;
  if button = 1 then
  begin
    if assigned(ButtonUnderMouseDown) then
    begin
      if ButtonUnderMouse = ButtonUnderMouseDown then ButtonUnderMouseDown.DoClick;
      if assigned(ButtonUnderMouseDown) then
      begin
        ButtonUnderMouseDown.Down:=False;
        DrawButton(ButtonUnderMouseDown);
        ButtonUnderMouseDown:=nil;
      end;
    end;
  end;
end;

procedure tInteractiveWidget.KeyPress(Code: integer; State: integer;
  keysym: integer;keyascii : integer);
begin
 // writeln ('KeyPress:',keysym);

end;

procedure tInteractiveWidget.KeyRelease(Code: integer; State: integer;
  keysym: integer);
begin
 // writeln ('KeyRelease:',keysym);
end;


end.

