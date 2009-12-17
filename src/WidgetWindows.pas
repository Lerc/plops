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
    FWidth: integer;
    DesiredX : integer;
    DesiredY : integer;

    WindowState : array of tAtom;
    MovePending : Boolean;
    procedure SetHeight(const AValue: integer);
    procedure SetWidth(const AValue: integer);
  public

  Window : twindow;
  Image : pImage;

  procedure AdaptToSize;

	constructor Create(x,y,nwidth,nheight : integer);
	destructor destroy; override;
  procedure SetShape(Mask : tPixmap);
  procedure MoveTo(X,Y : integer);
  procedure ProcessPendingTasks;
  property Width : integer read FWidth write SetWidth;
  property Height : integer read FHeight write SetHeight;
  property EventMask : tBitmask read FEventMask write SetEventMask;
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

  ChosenWindowType_atom : tAtom;
implementation


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

procedure tWidgetWindow.SetWidth(const AValue: integer);
begin
  if FWidth=AValue then exit;
  FWidth:=AValue;
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
begin
  fWidth:= nWidth;
  fHeight:=nHeight;
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
    XMoveWindow(Display,Window,DesiredX,DesiredY);
    MovePending := False;
  end;
end;

end.
