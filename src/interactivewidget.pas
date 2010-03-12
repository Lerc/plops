unit InteractiveWidget;

{$mode objfpc}{$H+}

interface

uses
   Classes, sysutils,BaseUnix,Math,DateUtils, WidgetButtons,Pipes;
  type

     { tInteractiveWidget }

     tInteractiveWidget = class
         public
               procedure CreateWindow(Name : String; X,Y,Width,height : integer);
               Procedure FreeWindow(Name : String);
               Procedure CreateImage(Name: String; Width,Height: integer);
               Procedure FreeImage(Name : string);
               Procedure CloneImage(Name : string);
               procedure LoadImage(Name : String; FileName : String);
               procedure FlipHorizontal;
               procedure FlipVertical;
               procedure FlipDiagonal;
               procedure Blur(Radius : integer);
               procedure Sharpen(Radius : integer);
               procedure SetClipRect(X,Y,Width,height : integer);
               Procedure DrawLine(X1,Y1,X2,Y2 : integer);
               Procedure DrawRectangle(Left,Top : integer; Width,height : integer);
               Procedure DrawEllipse(Left,Top : integer; Width,height : integer);
               Procedure FillRectangle(Left,Top : integer; Width,height : integer);
               Procedure FillEllipse(Left,Top : integer; Width,height : integer);
               procedure CopyAlphaToImage(Source : String; X,Y : integer);
               procedure CopyAlphaRectangleToImage(Source : String; src_x,src_y,Width,Height,dst_x,dst_y : integer);
               procedure ScrollRect(X,Y,Width,Height, DX,Dy : integer);
               procedure CopyRect(X,Y,Width,Height,NewX,NewY : integer);

               procedure SetImage(Name : String);
               procedure SetColor(Red,Green,Blue,Alpha : integer);
               procedure ClearColor(Red,Green,Blue,Alpha : integer);
               procedure BlendImageOntoImage(Source : String; MergeAlpha: Boolean;
                                        src_X,Src_Y,Src_W,Src_H : integer;
                                        dst_X,dst_Y,dst_W,dst_H : integer);
               procedure SetWindow(Name : String);
               procedure SetShape;
               procedure SetHasAlpha(NewValue : Boolean);
               procedure LoadFont(Name : String; Description:String);
               procedure SetFont(Name : String);
               procedure FreeFont(Name : String);
               Procedure TextDraw(X,Y : integer; S : String);

               procedure StartEvents;
               procedure SetEventMask;
               procedure Update;


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

procedure tInteractiveWidget.CreateWindow(Name: String; X, Y, Width,
  height: integer);
begin
  Writeln(CommandPipe,'create_window ' + Name +' '+intToStr(X)+' '+intToStr(Y)+' '+intToStr(Width)+' '+intToStr(Height));
end;

procedure tInteractiveWidget.FreeWindow(Name: String);
begin
  Writeln(CommandPipe,'free_window '+Name);
end;

procedure tInteractiveWidget.CreateImage(Name: String; Width, Height: integer);
begin
  Writeln(CommandPipe,'create_image ' + Name +' '+intToStr(Width)+' '+intToStr(Height));
end;

procedure tInteractiveWidget.FreeImage(Name: string);
begin
  Writeln(CommandPipe,'free_image '+Name);
end;

procedure tInteractiveWidget.CloneImage(Name: string);
begin
  Writeln(CommandPipe,'clone_image '+Name);
end;

procedure tInteractiveWidget.LoadImage(Name: String; FileName: String);
begin
  Writeln(CommandPipe,'load_image '+Name+' '+FileName);
end;

procedure tInteractiveWidget.FlipHorizontal;
begin
  Writeln(CommandPipe,'flip_horizontal');
end;

procedure tInteractiveWidget.FlipVertical;
begin
  Writeln(CommandPipe,'flip_verticall');
end;

procedure tInteractiveWidget.FlipDiagonal;
begin
  Writeln(CommandPipe,'flip_diagonal');
end;

procedure tInteractiveWidget.Blur(Radius: integer);
begin
  Writeln(CommandPipe,'blur '+intToStr(Radius));
end;

procedure tInteractiveWidget.Sharpen(Radius: integer);
begin
  Writeln(CommandPipe,'sharpen '+intToStr(Radius));
end;

procedure tInteractiveWidget.SetClipRect(X, Y, Width, height: integer);
begin
  Writeln(CommandPipe,'set_clip_rect ' +intToStr(X)+' '+intToStr(Y)+' '+intToStr(Width)+' '+intToStr(Height));
end;

procedure tInteractiveWidget.DrawLine(X1, Y1, X2, Y2: integer);
begin
  Writeln(CommandPipe,'draw_line ' +intToStr(X1)+' '+intToStr(Y1)+' '+intToStr(x2)+' '+intToStr(y2));
end;

procedure tInteractiveWidget.DrawRectangle(Left, Top: integer; Width,
  height: integer);
begin
  Writeln(CommandPipe,'draw_rectangle ' +intToStr(Left)+' '+intToStr(Top)+' '+intToStr(Width)+' '+intToStr(Height));
end;

procedure tInteractiveWidget.DrawEllipse(Left, Top: integer; Width,
  height: integer);
begin
  Writeln(CommandPipe,'draw_ellipse ' +intToStr(Left)+' '+intToStr(Top)+' '+intToStr(Width)+' '+intToStr(Height));
end;

procedure tInteractiveWidget.FillRectangle(Left, Top: integer; Width,
  height: integer);
begin
  Writeln(CommandPipe,'fill_rectangle ' +intToStr(Left)+' '+intToStr(Top)+' '+intToStr(Width)+' '+intToStr(Height));

end;

procedure tInteractiveWidget.FillEllipse(Left, Top: integer; Width,
  height: integer);
begin
  Writeln(CommandPipe,'fill_ellipse ' +intToStr(Left)+' '+intToStr(Top)+' '+intToStr(Width)+' '+intToStr(Height));
end;

procedure tInteractiveWidget.CopyAlphaToImage(Source: String; X, Y: integer);
begin
  Writeln(CommandPipe,'copy_alpha_to_image ' +intToStr(x)+' '+intToStr(y));

end;

procedure tInteractiveWidget.CopyAlphaRectangleToImage(Source: String; src_x,
  src_y, Width, Height, dst_x, dst_y: integer);
begin
  Writeln(CommandPipe,'copy_alpha_rectangle_to_image ' +intToStr(src_x)+' '+intToStr(src_y)+' '
                                                       +intToStr(width)+' '+intToStr(Height)+' '
                                                       +intToStr(dst_x)+' '+intToStr(dst_y) );

end;

procedure tInteractiveWidget.ScrollRect(X, Y, Width, Height, DX, Dy: integer);
begin
  Writeln(CommandPipe,'scroll_rect ' +intToStr(x)+' '+intToStr(y)+' '
                                     +intToStr(width)+' '+intToStr(Height)+' '
                                     +intToStr(dx)+' '+intToStr(dy) );

end;

procedure tInteractiveWidget.CopyRect(X, Y, Width, Height, NewX, NewY: integer
  );
begin
  Writeln(CommandPipe,'copy_rect ' +intToStr(x)+' '+intToStr(y)+' '
                                     +intToStr(width)+' '+intToStr(Height)+' '
                                     +intToStr(newX)+' '+intToStr(NewY) );

end;

procedure tInteractiveWidget.SetImage(Name: String);
begin
  Writeln(CommandPipe,'set_image ' +Name);
end;

procedure tInteractiveWidget.SetColor(Red, Green, Blue, Alpha: integer);
begin
  Writeln(CommandPipe,'set_color ' +intToStr(Red)+' '+intToStr(Green)+' '+intToStr(Blue)+' '+intToStr(Alpha));

end;

procedure tInteractiveWidget.ClearColor(Red, Green, Blue, Alpha: integer);
begin
  Writeln(CommandPipe,'clear_color ' +intToStr(Red)+' '+intToStr(Green)+' '+intToStr(Blue)+' '+intToStr(Alpha));
end;

procedure tInteractiveWidget.BlendImageOntoImage(Source: String;
  MergeAlpha: Boolean; src_X, Src_Y, Src_W, Src_H: integer; dst_X, dst_Y,
  dst_W, dst_H: integer);
var
  merge : String;
begin
  if MergeAlpha then Merge := ' 1 ' else Merge := ' 0 ';
  Writeln(CommandPipe,'blend_image_onto_image ' + Source+Merge+
  intToStr(src_x)+' '+intToStr(src_y)+' '+intToStr(Src_w)+' '+intToStr(src_h) +' ' +
  intToStr(dst_x)+' '+intToStr(dst_y)+' '+intToStr(dst_w)+' '+intToStr(dst_h));
end;

procedure tInteractiveWidget.SetWindow(Name: String);
begin
  Writeln(CommandPipe,'set_window ' + Name);
end;

procedure tInteractiveWidget.SetShape;
begin
  Writeln(CommandPipe,'set_shape');
end;

procedure tInteractiveWidget.SetHasAlpha(NewValue: Boolean);
var
  Value : String;
begin
  if NewValue then Value := 'true' else Value := 'false';
  Writeln(CommandPipe,'set_has_alpha '+value);
end;

procedure tInteractiveWidget.LoadFont(Name: String; Description: String);
begin
  Writeln(CommandPipe,'load_font '+name+' '+Description);
end;

procedure tInteractiveWidget.SetFont(Name: String);
begin
  Writeln(CommandPipe,'set_font '+Name);
end;

procedure tInteractiveWidget.FreeFont(Name: String);
begin
  Writeln(CommandPipe,'free_font '+Name);
end;

procedure tInteractiveWidget.TextDraw(X, Y: integer; S: String);
begin
  Writeln(CommandPipe,'text_draw '+  intToStr(x)+' '+intToStr(y)+' '+S);
end;

procedure tInteractiveWidget.StartEvents;
begin
  Writeln(CommandPipe,'start_events');
end;

procedure tInteractiveWidget.SetEventMask;
begin
  Writeln(CommandPipe,'set_event_mask');
end;

procedure tInteractiveWidget.Update;
begin
  Writeln(CommandPipe,'update');
end;

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

