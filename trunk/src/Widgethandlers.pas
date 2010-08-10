unit Widgethandlers;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses 
	x, xlib, BaseUnix, unix, Classes,pipes,Imlib,WidgetWindows,fgl,sysutils;

type
	
	tWindowMap = specialize tFPGMap <string, tWidgetWindow>;
	tWindowList = specialize tFPGObjectList <tWidgetWindow>;


  tCommand = (
  cmd_createWindow,       cmd_freeWindow,           cmd_SetWindow,
  cmd_CreateImage,        cmd_freeImage,            cmd_LoadImage,
  cmd_CloneImage,         cmd_CreateCroppedImage,   cmd_CreateCroppedScaledImage,
  cmd_FlipHorizontal,     cmd_FlipVertical,         cmd_FlipDiagonal,
  cmd_Orientate,          cmd_Clear,                cmd_ClearColor,
  cmd_SetColor,           cmd_Blur,                 cmd_Sharpen,
  cmd_BlendImageOntoImage,cmd_setClipRect,          cmd_setImage,
  cmd_DrawLine,           cmd_DrawRectangle,        cmd_FillRectangle,
  cmd_DrawEllipse,        cmd_FillEllipse,          cmd_SetHasAlpha,
  cmd_CopyAlphaToImage,   cmd_CopyAlphaRectangleToImage,       cmd_ScrollRect,
  cmd_CopyRect, cmd_Update, cmd_SetShape, cmd_setEventMask, cmd_startEvents,
  cmd_freeFont,           cmd_LoadFont,  cmd_setFont, cmd_TextDraw);


  tCommandsByName = specialize tfpgMap <String, tcommand>;
  tImagesByName = specialize tfpgMap <String, Imlib.tImage>;
  tFontsByName = specialize tfpgMap <String, Imlib.tImage>;
var
  CommandsByName : tCommandsByName;

type
{ tWidgetHandler }

tWidgetHandler = class

protected
    CommandBuffer : string;

    Dragging : boolean;
    DragWindow : tWidgetWindow;
    ButtonWindowX : integer;
    ButtonWindowY : integer;
    ButtonRootX : integer;
    ButtonRootY : integer;
    Connected : boolean;
    buttonshadow : array [0..15] of boolean;
    LastCommand : String;
    LastCommandCode : tCommand;
    procedure OpenPipes;
    procedure ClosePipes;

public
	  Commands : tInputPipeStream;
	  Results : tOutputPipeStream;
	  Events : Text;
    EventsOn : boolean;
    procedure SetCurrentWindow (Name : String);
    procedure MakeEventMask;
    Procedure StartEvents;
    procedure SendEvent(S : String);
public

	  Windows : tWindowMap;
    ImlibContext : tContext;
    Images : tImagesByName;
    Fonts : tImagesByName;

    BaseDirectory : String;
    WidgetName : String;
    CurrentWindow_Name : string;
    CurrentWindow : tWidgetWindow;

    procedure UpdateWindow(W : tWidgetWindow);
    procedure RecallWindow(W : tWidgetWindow);
    procedure StoreWindow(W : tWidgetWindow);

		procedure AddWindow(Name : String; X,Y,W,H : integer);
		procedure RemoveWindow(Name : String);

    procedure AddImage(name : String;  Image : tImage);
    Procedure FreeImage(Name : String);

    procedure AddFont(name : String;  Font : tFont);
    Procedure FreeFont(Name : String);

		constructor Create(nBaseDirectory: String; nname : String);
		destructor Destroy; override;

		procedure HandleXEvent(var event : tXevent; EventWindow : tWidgetWindow);
		procedure CheckPipes;
		procedure DoCommand (Parameters : tStringlist);
    Procedure ProcessPendingTasks;
	end;


tXwindowToHandlerMap = specialize tFPGMap <tWindow, tWidgetHandler>;
tXwindowToWidgetWindowMap = specialize tFPGMap <tWindow, tWidgetWindow>;
tWidgetHandlerList = specialize tFPGObjectList <tWidgetHandler>;

var
	HandlersByXHandle : tXwindowToHandlerMap;
  WidgetWindowsByXHandle : tXwindowToWidgetWindowMap;
implementation
uses termio,Bitmasks,configuration;
{ tWidgetHandler }

procedure tWidgetHandler.AddWindow(Name: String; X, Y, W, H: integer);
var  NewWindow : tWidgetWindow;
begin
	NewWindow := tWidgetWindow.create(X,Y,W,H);
	Windows.add(Name,NewWindow);

  HandlersByXHandle.add(NewWindow.window,self);
  WidgetWindowsByXHandle.add(NewWindow.Window,NewWindow);
  Images.Add(name,NewWindow.Image);
  CurrentWindow:=NewWindow;
  CurrentWindow.Name:=Name;
  CurrentWindow_name := Name;
  RecallWindow(NewWindow);
end;

procedure tWidgetHandler.RemoveWindow(Name: String);
var
  oldWindow : tWidgetWindow;
begin
  //writeln('Freeing window named '+Name);
  oldWindow := Windows[Name];
  //writeln('which exists');

  if CurrentWindow = OldWindow then
  begin
    CurrentWindow := nil;
    CurrentWindow_name :='';
  end;

  HandlersByXHandle.remove(oldWindow.window);
  WidgetWindowsByXHandle.remove(oldWindow.window);
  Images.Remove(Name);
	Windows.remove(Name);
	oldWindow.Free;

end;

procedure tWidgetHandler.AddImage(name: String; Image: tImage);
var
   I : integer;
begin
  I:=Images.indexof(Name);
  if I >=0 then
  begin
    if Windows.Indexof(Name) >= 0 then
    begin
      writeln ('tried to override window image '+Name);
      imlib.context_set_image(Image);
      imlib.free_image;
      exit;
    end;
    FreeImage(name)
  end;

  Images.Add(name,Image);
end;

procedure tWidgetHandler.FreeImage(Name: String);
var
  Image : tImage;
begin
  Image := Images[Name];
  Images.Remove(Name);
  imlib.context_set_image(Image);
  imlib.free_image;
end;

procedure tWidgetHandler.AddFont(name: String; Font:tFont);
var
   I : integer;
begin
  I:=Fonts.indexof(Name);
  if I >=0 then
  begin
    FreeFont(name)
  end;
  Fonts.Add(name,Font);
end;

procedure tWidgetHandler.FreeFont(Name: String);
var
  Font : tFont;
begin
  Font := Fonts[Name];
  Fonts.Remove(Name);
  imlib.context_set_font(Font);
  imlib.free_font;
end;

constructor tWidgetHandler.Create(nBaseDirectory: String; nName:String);
begin
   Inherited create;
   imlibcontext := imlib.context_new;

   imlib.Context_push(imlibContext);

   context_set_display(Display);
   context_set_Visual(DefaultVisual(Display,Screen));
   imlib.Context_pop;

   Windows := tWindowMap.Create;
   Images := tImagesByName.Create;
   Fonts := tFontsByName.Create;
   BaseDirectory := nBaseDirectory;
   WidgetName := nName;

   OpenPipes;

end;

destructor tWidgetHandler.Destroy;
begin
   closepipes;
   While (Windows.count > 0) do RemoveWindow(Windows.keys[0]);
   imlib.context_free(imlibcontext);
   Images.Free;
   Fonts.Free;
  Windows.Free;
end;

procedure tWidgetHandler.ClosePipes;
begin
     Commands.free;
     Results.free;
end;

procedure tWidgetHandler.SetCurrentWindow(Name: String);
begin
  CurrentWindow_name := Name;
  CurrentWindow := Windows[Name];
  imlib.context_set_drawable(CurrentWindow.Window);
end;

procedure tWidgetHandler.MakeEventMask;
var
   Surface : PDword;
   image : tImage;
   workImage : tImage;
   W,H : integer;
begin
   image := imlib.context_get_image;
   workimage := clone_image;
   imlib.context_set_image(workimage);
   H := Image_get_Height;
   W := Image_get_Width;

   Surface := imlib.image_get_data_for_reading_only;
   //writeln('making mask for image ',W,',',H);
   CurrentWindow.EventMask := tBitmask.CreateFromBytes(W,H,pByte(Surface),0,4);
   imlib.free_image;
   imlib.context_set_image(image);
end;

procedure tWidgetHandler.StartEvents;
begin
   //writeln('start_events called');
  //if Events > 0 then exit;
  assign(Events,BaseDirectory+'/events');
  rewrite(events);
  EventsOn := true;
end;

procedure tWidgetHandler.SendEvent(S: String);
begin
  if not EventsOn then exit;
   writeln(Events,s);
   Flush(Events);
end;

procedure tWidgetHandler.UpdateWindow(W: tWidgetWindow);
begin
  imlib.Context_push(imlibContext);
  try
     imlib.context_set_drawable(W.Window);
     imlib.context_set_image(W.Image);
     imlib.Render_image_on_Drawable_at_size(0,0,W.ScaledWidth,W.ScaledHeight);
  finally
    imlib.Context_pop;
  end;
end;

procedure tWidgetHandler.RecallWindow(W: tWidgetWindow);
var
  Frame : tRect;
  X,Y : integer;
begin
  Frame := W.GetPosition;
  X := ConfigFile.ReadInteger(WidgetName,W.Name+'_X',Frame.Left);
  Y := ConfigFile.ReadInteger(WidgetName,W.Name+'_Y',Frame.Top);
  W.Scale := ConfigFile.ReadFloat(WidgetName,W.Name+'_Scale',W.Scale);
  W.Workspace := ConfigFile.ReadInteger(WidgetName,W.Name+'_Workspace',0);
  W.MoveTo(X,Y);
end;

procedure tWidgetHandler.StoreWindow(W: tWidgetWindow);
var
  Frame : tRect;
begin
  Frame := W.GetPosition;
  ConfigFIle.WriteInteger(WidgetName,W.Name+'_X',Frame.Left);
  ConfigFIle.WriteInteger(WidgetName,W.Name+'_Y',Frame.Top);
  ConfigFIle.WriteFloat(WidgetName,W.Name+'_Scale',W.Scale);
  ConfigFIle.WriteInteger(WidgetName,W.Name+'_Workspace',W.Workspace);
  ConfigFile.UpdateFile;
end;

function KeyToAscii(KeyCode,state,Keysym:integer) : integer;
//this isn't really the right way to do this.
// it ignores keyboard mappings

var
   shift : boolean;
   capslock : boolean;
   caps : boolean;
begin
   result := -1;
   capslock := (state and 2) <> 0;
   shift := ((state and 1) <> 0) ;
   caps := shift xor capslock;
   case keysym of
        65438: result :=ord('0');
        65436: result :=ord('1');
        65433: result :=ord('2');
        65435: result :=ord('3');
        65430: result :=ord('4');
        65437: result :=ord('5');
        65432: result :=ord('6');
        65429: result :=ord('7');
        65431: result :=ord('8');
        65434: result :=ord('9');
        65455: result :=ord('/');
        65450: result :=ord('*');
        65453: result :=ord('-');
        65451: result :=ord('+');
        65439: result :=ord('.');
        97..122:
        begin
          result := keysym;
          if caps then result-=32;
        end;
        32..96:
        begin
          result := keysym;
          if shift then
          case keysym of
          39: result :=ord('"');
          44: result :=ord('<');
          45: result :=ord('_');
          46: result :=ord('>');
          47: result :=ord('?');

            48: result :=ord(')');
            49: result :=ord('!');
            50: result :=ord('@');
            51: result :=ord('#');
            52: result :=ord('$');
            53: result :=ord('%');
            54: result :=ord('^');
            55: result :=ord('&');
            56: result :=ord('*');
            57: result :=ord('(');
            59: result :=ord(':');
            61: result :=ord('+');
            91: result :=ord('{');
            92: result :=ord('|');
            93: result :=ord('}');
            96: result :=ord('~');

          end;
        end;
   end;
end;

procedure tWidgetHandler.HandleXEvent(var event: tXevent; EventWindow : tWidgetWindow);
var
   keySym : tKeySym;
   keyascii : integer;
   mouseX : integer;
   mouseY : integer;
begin
//     writeln('event type:',event._type);
   case event._type of
     keypress: begin

       keySym := XLookupKeySym(addr(event.xkey),0);
       KeyAscii := KeyToAscii(event.xkey.keycode,event.xkey.state,keySym);
       SendEvent('keypress '+intToStr(event.xkey.keycode)+' '+intToStr(event.xkey.state) +' '+intToStr(keysym) +' '+intToStr(keyascii));
     end;
     keyrelease: begin
       keySym := XLookupKeySym(addr(event.xkey),0);
       SendEvent('keyrelease '+intToStr(event.xkey.keycode)+' '+intToStr(event.xkey.state) +' '+intToStr(keysym));
     end;
     buttonpress: begin
       if event.xbutton.button=2 then begin
         //xunmapwindow(display,EventWindow.window);
          Eventwindow.Workspace:=(Eventwindow.Workspace + 1) and 3;
         //xmapwindow(display,EventWindow.window);

       end;
       MouseX := round(event.xbutton.x/EventWindow.scale);
       MouseY := round(event.xbutton.Y/EventWindow.scale);
       if EventWindow.EventMask[MouseX,MouseY] then
       begin
         //Writeln('Event Zone hit');
         SendEvent('buttonpress '+intToStr(event.xbutton.button)+' '+intToStr(MouseX)+' '+intToStr(MouseY));
         ButtonShadow[event.xbutton.button] := true;
       end
       else if event.xbutton.button = 1 then
       begin
         ButtonWindowX := event.xbutton.x;
         ButtonWindowY := event.xbutton.y;
         ButtonRootX := event.xbutton.X_Root;
         ButtonRootY := event.xbutton.Y_Root;
         DragWindow := EventWindow;
         Dragging := true;
       end;
     end;
     buttonrelease: begin
       MouseX := round(event.xbutton.x/EventWindow.scale);
       MouseY := round(event.xbutton.Y/EventWindow.scale);
       if EventWindow.EventMask[MouseX,MouseY] or (ButtonShadow[event.xbutton.button])then
       begin
         //Writeln('Event Zone hit');
         SendEvent('buttonrelease '+intToStr(event.xbutton.button)+' '+intToStr(MouseX)+' '+intToStr(MouseY));
         ButtonShadow[event.xbutton.button]:=false;
       end
       else if event.xbutton.button = 1 then
       begin
         if Dragging then
         begin
           StoreWindow(DragWindow);
         end;
         Dragging := False;
       end;
     end;
     motionNotify: begin
       if Dragging then
       begin
         //writeln('drag');
           DragWindow.MoveTo(event.xmotion.X_root-ButtonWindowX,event.xmotion.Y_root-ButtonWindowY);
       end;
     end;
     expose: begin
       if event.xexpose.count = 0 then
       begin
         UpdateWindow(EventWindow);
       end;
     end;
   end;
end;

procedure tWidgetHandler.CheckPipes;
var
  Parameters : tStringList;
  Buffer : array [0..1024] of byte;
  C: integer;
  Walk : pByte;
  BytesInBuffer : integer;
begin
  while Commands.numbytesAvailable > 0 do
  begin
    Connected := true;
    //C:= fileread(Commands.Handle,dummy,0);
    BytesInBuffer:=Commands.Read(Buffer,SizeOf(Buffer));
    Walk := Addr(Buffer[0]);

    while BytesInBuffer > 0 do
    begin
      C:=Walk^;
      Walk+=1;
      BytesInBuffer-=1;

      if c =10 then
      begin
        Parameters := tStringlist.create;
        Parameters.Delimiter:=' ';
        Parameters.DelimitedText:=CommandBuffer;

        DoCommand(Parameters);
        parameters.free;
        CommandBuffer := '';
      end else CommandBuffer += chr(c);
    end;
  end;
end;

procedure tWidgetHandler.OpenPipes;
var
  Handle : tHandle;
begin
  Handle := fpopen(BaseDirectory+'/commands',o_NonBlock,o_rdonly);
  Commands:=tInputPipeStream.create(Handle);


  //Handle := fpopen(BaseDirectory+'/results',o_NonBlock,o_wronly);
  //Results:=tOutputPipeStream.create(Handle);

  //flush any old data out
  while Commands.numbytesAvailable > 0 do Commands.readbyte;
end;

procedure tWidgetHandler.DoCommand(Parameters: tStringList);
var
  CommandCode : tCommand;
  p : tStringList;
  i : integer;
  imagepixmap : tPixmap;
  mask : tPixmap;
  Image : tImage;
  Font : tFont;
  Filename : String;
  line : String;
  command : String;
begin
  //writeln(Parameters.text);
  Command := parameters[0];
  if command = LastCommand then
  begin
    CommandCode := LastCommandCode;
  end
  else
  begin
    I := CommandsByName.IndexOf(Command);
    if I < 0 then
    begin
      writeln('Unknown Command:"'+Command+'"');
      exit;
    end;
    CommandCode := CommandsByName.Data[I];
    LastCommandCode := CommandCode;
    LastCommand:=Command;
  end;
  P := Parameters;  //simply for brevity;

  imlib.Context_push(imlibContext);
  try
     case CommandCode of
       cmd_createWindow :  AddWindow(P[1],StrToInt(P[2]),StrToInt(P[3]),StrToInt(P[4]),StrToInt(P[5]));
       cmd_freeWindow : RemoveWindow(currentwindow_name);
       cmd_SetWindow : SetCurrentWindow(P[1]);
       cmd_CreateImage :
           begin
               image:=imlib.create_image(StrToInt(P[2]),StrToInt(P[3]));
               AddImage(p[1], Image);
               imlib.context_set_Image(Image);
               image_set_has_alpha(1);
           end;
       cmd_setImage: imlib.context_set_image(Images[p[1]]);
       cmd_freeImage : FreeImage(p[1]);
       cmd_LoadImage :
           begin
               Filename :=  BaseDirectory+'/'+p[2];
               Image := imlib.load_image(pchar(FileName));
               if Image = nil then writeln ('Failed to load image ',filename);
              AddImage(p[1], Image);
           end;
       cmd_setFont:
       begin
              imlib.context_set_font(Fonts[p[1]]);
       end;
       cmd_freeFont : FreeFont(p[1]);
       cmd_LoadFont :
           begin
               Filename :=  BaseDirectory+'/'+p[2];
               Font := imlib.load_Font(pchar(FileName));
               if Font = nil then writeln ('Failed to load Font ',filename);
              AddFont(p[1], Font);
           end;

       cmd_CloneImage : AddImage(p[1], imlib.clone_image);
       cmd_SetHasAlpha : imlib.image_set_has_alpha(ord(lowercase(P[1])='true'));
       cmd_CreateCroppedImage : AddImage(p[1], imlib.create_cropped_image(StrToInt(P[2]),StrToInt(P[3]),StrToInt(P[4]),StrToInt(P[5])));
       cmd_CreateCroppedScaledImage : AddImage(p[1], imlib.create_cropped_Scaled_image(StrToInt(P[2]),StrToInt(P[3]),StrToInt(P[4]),StrToInt(P[5]),StrToInt(P[6]),StrToInt(P[7])));
       cmd_FlipHorizontal: imlib.image_flip_horizontal;
       cmd_FlipVertical: imlib.image_flip_Vertical;
       cmd_FlipDiagonal: imlib.image_flip_Diagonal;
       cmd_Orientate: imlib.image_Orientate(StrToInt(P[1]));
       cmd_Clear: imlib.image_clear;
       cmd_ClearColor: imlib.image_clear_color(StrToInt(P[1]),StrToInt(P[2]),StrToInt(P[3]),StrToInt(P[4]));
       cmd_Blur: imlib.image_Blur(StrToInt(P[1]));
       cmd_Sharpen: imlib.image_Sharpen(StrToInt(P[1]));
       cmd_BlendImageOntoImage: imlib.blend_image_onto_image(
                                Images[p[1]], StrToInt(p[2]),   //src name,   mergeAlpha
                                StrToInt(p[3]),StrToInt(p[4]),  //src x,y
                                StrToInt(p[5]),StrToInt(p[6]),  //src width,height
                                StrToInt(p[7]),StrToInt(p[8]),  //dest x,y
                                StrToInt(p[9]),StrToInt(p[10]));  //dest width,height
       cmd_setClipRect: imlib.context_set_cliprect(StrToInt(P[1]),StrToInt(P[2]),StrToInt(P[3]),StrToInt(P[4]));
       cmd_SetColor: imlib.context_set_color(StrToInt(P[1]),StrToInt(P[2]),StrToInt(P[3]),StrToInt(P[4]));
       cmd_DrawLine: imlib.image_draw_line(StrToInt(P[1]),StrToInt(P[2]),StrToInt(P[3]),StrToInt(P[4]),0);
       cmd_DrawRectangle: imlib.image_draw_rectangle(StrToInt(P[1]),StrToInt(P[2]),StrToInt(P[3]),StrToInt(P[4]));
       cmd_FillRectangle: imlib.image_fill_rectangle(StrToInt(P[1]),StrToInt(P[2]),StrToInt(P[3]),StrToInt(P[4]));
       cmd_DrawEllipse: imlib.image_draw_ellipse(StrToInt(P[1]),StrToInt(P[2]),StrToInt(P[3]),StrToInt(P[4]));
       cmd_FillEllipse: imlib.image_fill_ellipse(StrToInt(P[1]),StrToInt(P[2]),StrToInt(P[3]),StrToInt(P[4]));
       cmd_CopyAlphaToImage: imlib.image_copy_alpha_to_image(Images[P[1]],StrToInt(P[2]),StrToInt(P[3]));
       cmd_CopyAlphaRectangleToImage: imlib.image_copy_alpha_rectangle_to_image(Images[p[1]],StrToInt(P[2]),StrToInt(P[3]),StrToInt(P[4]),StrToInt(P[5]),StrToInt(P[6]),StrToInt(P[7]));
       cmd_ScrollRect: imlib.image_scroll_rect(StrToInt(P[1]),StrToInt(P[2]),StrToInt(P[3]),StrToInt(P[4]),StrToInt(P[5]),StrToInt(P[6]));
       cmd_CopyRect: imlib.image_scroll_rect(StrToInt(P[1]),StrToInt(P[2]),StrToInt(P[3]),StrToInt(P[4]),StrToInt(P[5]),StrToInt(P[6]));
       cmd_Update: UpdateWindow(CurrentWindow);
       cmd_SetEventMask: MakeEventMask;
       cmd_StartEvents: StartEvents;
       cmd_setShape:
                    begin
                      Render_pixmaps_for_whole_image_at_size(addr(ImagePixmap),addr(Mask),CurrentWindow.scaledWidth,CurrentWindow.ScaledHeight);
                      CurrentWindow.SetShape(Mask);
                      imlib.free_pixmap_and_mask(ImagePixmap);
                    end;
       cmd_TextDraw:
       begin
         line := '';
         for I := 3 to P.count-1 do
         begin
           Line+=P[I]+' ';  //note lines end in a space to allow italics to fit in the box
         end;
         text_draw(StrToInt(P[1]),StrToInt(P[2]),pchar(Line));

       end;
     end;
  finally
    imlib.Context_pop;
  end;

end;

procedure tWidgetHandler.ProcessPendingTasks;
var
I : integer;
begin
  for I := 0 to Windows.Count - 1 do
  begin
    Windows.Data[I].ProcessPendingTasks;
  end;

end;

procedure SetCommandNames;
begin
   CommandsByName.add('create_window',cmd_CreateWindow);
   CommandsByName.add('free_window',cmd_FreeWindow);
   CommandsByName.add('set_window',cmd_setWindow);
   CommandsByName.add('create_image',cmd_CreateImage);
   CommandsByName.add('free_image',cmd_FreeImage);
   CommandsByName.add('load_image',cmd_LoadImage);
   CommandsByName.add('clone_image',cmd_CloneImage);
   CommandsByName.add('create_cropped_image',cmd_CreateCroppedImage);
   CommandsByName.add('create_cropped_scaled_image',cmd_CreateCroppedScaledImage);
   CommandsByName.add('flip_horizontal',cmd_FlipHorizontal);
   CommandsByName.add('flip_vertical',cmd_FlipVertical);
   CommandsByName.add('flip_diagonal',cmd_FlipDiagonal);
   CommandsByName.add('orientate',cmd_Orientate);
   CommandsByName.add('clear',cmd_Clear);
   CommandsByName.add('clear_color',cmd_ClearColor);
   CommandsByName.add('blur',cmd_Blur);
   CommandsByName.add('sharpen',cmd_Sharpen);
   CommandsByName.add('blend_image_onto_image',cmd_BlendImageOntoImage);
   CommandsByName.add('set_clip_rect',cmd_setClipRect);
   CommandsByName.add('set_image',cmd_setImage);
   CommandsByName.add('set_color',cmd_SetColor);
   CommandsByName.add('draw_line',cmd_DrawLine);
   CommandsByName.add('draw_rectangle',cmd_DrawRectangle);
   CommandsByName.add('fill_rectangle',cmd_FillRectangle);
   CommandsByName.add('draw_ellipse',cmd_DrawEllipse);
   CommandsByName.add('fill_ellipse',cmd_FillEllipse);
   CommandsByName.add('copy_alpha_to_image',cmd_CopyAlphaToImage);
   CommandsByName.add('copy_alpha_rectangle_to_image',cmd_CopyAlphaRectangleToImage);
   CommandsByName.add('scroll_rect',cmd_ScrollRect);
   CommandsByName.add('copy_rect',cmd_CopyRect);
   CommandsByName.add('update',cmd_Update);
   CommandsByName.add('set_shape',cmd_SetShape);
   CommandsByName.add('set_has_alpha',cmd_SetHasAlpha);
   CommandsByName.add('set_event_mask',cmd_setEventMask);
   CommandsByName.add('start_events',cmd_StartEvents);
   CommandsByName.add('set_font',cmd_SetFont);
   CommandsByName.add('load_font',cmd_LoadFont);
   CommandsByName.add('free_font',cmd_FreeFont);
   CommandsByName.add('text_draw',cmd_TextDraw);
end;

initialization
	HandlersByXHandle := tXwindowToHandlerMap.create;
  WidgetWindowsbyXHandle := tXwindowToWidgetWindowMap.create;
  CommandsByName := tCommandsByName.create;
  SetCommandNames;
finalization;
  WidgetWindowsbyXhandle.free;
	HandlersByXHandle.free;
  CommandsByName.free;

end.
