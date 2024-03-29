unit WidgetWindows;
{$mode objfpc}{$h+}
interface
uses
  x, xlib,xatom,xshm, BaseUnix, unix,ipc, Classes,pipes,Imlib,FGL,CommandOptions,Bitmasks;
type

  { tWidgetWindow }

  tWidgetwindow = class
  private
    FEventMask: tBitmask;
    procedure SetEventMask(const AValue: tBitmask);
  private
    FHeight: integer;
    fscale: single;
    FWidth: integer;
    DesiredX : integer;
    DesiredY : integer;
    getscale: single;

    WindowState : array of tAtom;
    MovePending : Boolean;
    function getScaledHeight: integer;
    function getScaledWidth: integer;
    function getWorkspace: integer;
    procedure SetHeight(const AValue: integer);
    procedure Setscale(const AValue: single);
    procedure SetWidth(const AValue: integer);
    procedure SetWorkspace(const AValue: integer);
  public

  Window : twindow;
  Image : pImage;
  Name: string;
  procedure AdaptToSize;

	constructor Create(x,y,nwidth,nheight : integer);
	destructor destroy; override;
  procedure SetShape(Mask : tPixmap);
  procedure MoveTo(X,Y : integer);
  procedure ProcessPendingTasks;
  function GetPosition :tRect;
  property Width : integer read FWidth write SetWidth;
  property Height : integer read FHeight write SetHeight;
  property EventMask : tBitmask read FEventMask write SetEventMask;
  property Scale: single read fscale write Setscale;
  property ScaledWidth : integer read getScaledWidth;
  property ScaledHeight : integer read getScaledHeight;
  property Workspace : integer read getWorkspace write SetWorkspace;
  end;
  


procedure init;
procedure done; 

var
  Display: PDisplay;
  Screen: Longint;
  BlackColor: longint;
  WhiteColor: longint;
  WindowState_atom : tAtom;
  WindowType_atom : tAtom;
  WindowType_Dock_atom : tAtom;
  WindowType_Notification_atom : tAtom;
  WindowType_Utility_atom : tAtom;
  //WindowState_FullScreen_atom : tAtom;
  WindowState_Below_atom : tAtom;
  WindowState_Above_atom : tAtom;
  WindowState_Skip_Pager_atom : tAtom;
  WindowState_Skip_Taskbar_atom : tAtom;
  WindowState_Sticky_atom : tAtom;
  WindowState_OpenBox_Undecorated_atom : tAtom;
  Motif_Hints_atom : tAtom;
  Desktop_atom : tAtom;

  ChosenWindowType_atom : tAtom;
implementation

type
  tMWMHints = record
    flags : DWORD;
    functions : DWORD;
    decorations : DWORD;
    inputMode : integer;
    status : DWORD;
  end;
const
  MWM_HINTS_FUNCTIONS = 1 shl 0;
  MWM_HINTS_DECORATIONS = 1 shl 1;
  MWM_HINTS_INPUT_MODE = 1 shl 2;
  MWM_HINTS_STATUS = 1 shl 3;

  MWM_FUNC_ALL = 1 shl 0;
  MWM_FUNC_RESIZE = 1 shl 1;
  MWM_FUNC_MOVE = 1 shl 2;
  MWM_FUNC_MAXIMIZE = 1 shl 3;
  MWM_FUNC_MINIMIZE = 1 shl 4;
  MWM_FUNC_CLOSE = 1 shl 5;

  MWM_DECOR_ALL = 1 shl 0;
  MWM_DECOR_BORDER = 1 shl 1;
  MWM_DECOR_RESHIZEH = 1 shl 2;
  MWM_DECOR_TITLE = 1 shl 3;
  MWM_DECOR_MENU = 1 shl 4;
  MWM_DECOR_MINIMIZE = 1 shl 5;
  MWM_DECOR_MAXIMIZE = 1 shl 6;

  MWM_INPUT_MODELESS = 0;
  MWM_INPUT_PRIMARY_APPLICATION_MODAL = 1;
  MWM_INPUT_SYSTEM_MODAL = 2;
  MWM_INPUT_FULL_APPLICATION_MODAL = 3;

  PROP_MWM_HINTS_ELEMENTS = 5;
  PROP_MWM_HINTS_ELEMENTS_MIN = 4;

procedure XShapeCombineMask(Display: PDisplay; W: twindow; DestKind : integer; xoffset:integer; yOffset : integer; mask : tPixmap; op : integer); cdecl;
                     external 'Xext' name 'XShapeCombineMask';

procedure init;
var
    WindowType : String;
begin
  Display := XOpenDisplay(nil);

  if Display = nil then
  Begin
    Halt;
  End;
//	initxrender(TheDisplay);

  Screen := XDefaultScreen(Display);
  BlackColor := XBlackPixel(Display,Screen);
  WhiteColor := XWhitePixel(Display,Screen);
  WindowState_atom := XInternAtom(Display,'_NET_WM_STATE',True);
  WindowType_atom := XInternAtom(Display,'_NET_WM_WINDOW_TYPE',True);
  WindowType_Dock_atom := XInternAtom(Display,'_NET_WM_WINDOW_TYPE_DOCK',True);
  WindowType_Utility_atom := XInternAtom(Display,'_NET_WM_WINDOW_TYPE_UTILITY',True);
  WindowType_Notification_atom := XInternAtom(Display,'_NET_WM_WINDOW_TYPE_NOTIFICATION',True);
  //WindowState_FullScreen_atom := XInternAtom(Display,'_NET_WM_STATE_FULLSCREEN',True);
  WindowState_Below_atom := XInternAtom(Display,'_NET_WM_STATE_BELOW',True);
  WindowState_OpenBox_Undecorated_atom := XInternAtom(Display,'_OB_WM_STATE_UNDECORATED',True);
  WindowState_Sticky_atom := XInternAtom(Display,'_NET_WM_STATE_STICKY',True);
  WindowState_Skip_Taskbar_atom := XInternAtom(Display,'_NET_WM_STATE_SKIP_TASKBAR',True);
  WindowState_Skip_Pager_atom := XInternAtom(Display,'_NET_WM_STATE_SKIP_PAGER',True);
  WindowState_Above_atom := XInternAtom(Display,'_NET_WM_STATE_ABOVE',True);
  WindowState_Below_atom := XInternAtom(Display,'_NET_WM_STATE_BELOW',True);

  WindowType:=OptionValue('WindowType','_NET_WM_WINDOW_TYPE_NOTIFICATION');
  ChosenWindowType_atom := XInternAtom(Display,pchar(WindowType),True);
  Motif_Hints_atom :=XInternAtom(Display,'_MOTIF_WM_HINTS',False);

  Desktop_atom :=XInternAtom(Display,'_NET_WM_DESKTOP',False);

end;

procedure done; 
begin
  XcloseDisplay(Display);
end;
{ tWidgetWindow }

procedure tWidgetwindow.SetEventMask(const AValue: tBitmask);
begin
  if FEventMask=AValue then exit;
  if FEventMask <> nil then fEventMask.Free;
  FEventMask:=AValue;
end;

procedure tWidgetWindow.SetHeight(const AValue: integer);
begin
  if FHeight=AValue then exit;
  FHeight:=AValue;
end;

procedure tWidgetwindow.Setscale(const AValue: single);
begin
  fScale:=aValue;
  MovePending :=True;
end;

function tWidgetwindow.getScaledHeight: integer;
begin
  result := round(fHeight*fScale);
end;

function tWidgetwindow.getScaledWidth: integer;
begin
  result := round(fWidth*fScale);
end;

function tWidgetwindow.getWorkspace: integer;
var
  Type_return: tAtom;
  Format_Return : integer;
  nItems_Return : dword;
  bytes_after_Return :dword;
  Value : pInteger;
  xresult : integer;
begin
  value := nil;
  xresult:=XGetWindowProperty(Display,Window,Desktop_Atom,0,1,false,XA_CARDINAL,
            addr(Type_Return),
            addr(Format_return),
            addr(nItems_return),
            addr(Bytes_after_return),
            Addr(value));
  if xresult <> Success then
  begin
    result := -1;
  end
  else
  begin
    Result := Value^;
  end;
  if (Value <> nil) then XFree(Value);
end;

procedure tWidgetWindow.SetWidth(const AValue: integer);
begin
  if FWidth=AValue then exit;
  FWidth:=AValue;
end;

procedure tWidgetwindow.SetWorkspace(const AValue: integer);
var
    Event : tXEvent;
begin
    fillchar(Event,Sizeof(Event),0);
    Event._type:=ClientMessage;
    Event.xclient.window:=window;
    Event.xclient.display:=display;
    Event.xclient.message_type:=Desktop_atom;
    Event.xclient.format:=32;
    Event.xclient.data.l[0]:=AValue;

    XSendEvent(display,XDefaultRootWindow(display),false,SubstructureNotifyMask or SubstructureRedirectMask,Addr(Event));

//   XChangeProperty(display,window,Desktop_atom,XA_CARDINAL,32,PropModeReplace,addr(Avalue),1);
end;

procedure tWidgetWindow.AdaptToSize;
begin
  if image <> nil then
  begin
    imlib.context_set_Image(Image);
    imlib.free_Image;
    image := nil;
  end;
  image := imlib.create_image(Width,Height);
  imlib.context_set_Image(Image);
  image_set_has_alpha(1);
end;


constructor tWidgetWindow.Create(x, y, nwidth, nheight: integer);
var
  AttributeMask : longint;
  Attributes : TXSetWindowAttributes;
  mwmHints : tMWMHints;
begin
  fWidth:= nWidth;
  fHeight:=nHeight;
  scale:=0.5;
{	Window :=XCreateSimpleWindow(Display,
	XDefaultRootWindow(Display),
	    x, y, nwidth,nheight, 0, BlackColor, BlackColor);
	 XSelectInput(Display, Window, StructureNotifyMask + KeyPressMask +
	KeyReleaseMask+ExposureMask);
}
setLength(WindowState,4);
WindowState[0] :=WindowState_Below_atom;
WindowState[1] :=WindowState_Skip_Pager_atom;
WindowState[2] :=WindowState_Skip_TaskBar_atom;
WindowState[3] :=WindowState_OpenBox_UnDecorated_atom;

fillchar(Attributes,Sizeof(attributes),0);
Attributes.override_redirect:=1;
AttributeMask := 0;//CWOverrideRedirect;
Window :=XCreateWindow(Display,
XDefaultRootWindow(Display),
    x, y, nwidth,nheight,0, 0,0,nil, AttributeMask, addr(Attributes));


 XSelectInput(Display, Window, StructureNotifyMask + KeyPressMask +
KeyReleaseMask+ExposureMask+ButtonPressMask+ButtonReleaseMask+ButtonMotionMask);

 XChangeProperty(Display,Window,WindowType_atom,XA_ATOM,32,PropModeReplace,addr(ChosenWindowType_atom),1);
 XChangeProperty(Display,Window,WindowState_atom,XA_ATOM,32,PropModeReplace,addr(WindowState[0]),length(WindowState));

 fillchar(mwmhints,Sizeof(mwmHints),0);
 mwmHints.flags := MWM_HINTS_DECORATIONS;
 mwmHints.decorations :=0;
 XChangeProperty(Display,Window,Motif_Hints_Atom,Motif_Hints_ATOM,32,PropModeReplace,addr(mwmHints),PROP_MWM_HINTS_ELEMENTS);
  xMapwindow(Display,window);
  AdaptToSize;
  eventMask := tBitMask.create(0,0);
end;

destructor tWidgetWindow.destroy;
begin
  EventMask :=nil;
  XDestroyWindow(Display,window);
  if image <> nil then
  begin
    imlib.context_set_Image(Image);
    imlib.free_Image;
    image := nil;
  end;
	inherited;
end;

procedure tWidgetwindow.SetShape(Mask: tPixmap);
begin
  XshapeCombineMask(Display,window,0,0,0,mask,0);
end;

procedure tWidgetwindow.MoveTo(X, Y: integer);
begin
  DesiredX := X;
  DesiredY := Y;
  MovePending :=True;
end;

procedure tWidgetwindow.ProcessPendingTasks;
begin
  if MovePending then
  begin
    XMoveResizeWindow(Display,Window,DesiredX,DesiredY,round(fWidth*fScale),round(fHeight*Scale));
    MovePending := False;
  end;
end;

function tWidgetwindow.GetPosition: tRect;
var
  Attributes : tXWindowAttributes;
  X,Y,W,H,BW,D : integer;
  C: tWindow;
  Root : tWindow;
begin
  XGetWindowAttributes(Display,Window,@attributes);

  XGetGeometry(Display,Window,@Root,@X,@Y,@W,@H,@BW,@D);
  XTranslateCoordinates(Display,Window,Root,X,Y,@Result.Left,@Result.Top,@C);
  result.Right :=Result.Left+W;
  result.Bottom :=Result.Top+H;
end;

end.
