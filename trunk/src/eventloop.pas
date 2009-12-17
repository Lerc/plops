unit eventloop;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
  x, xlib,xshm, BaseUnix, unix,ipc, Classes,pipes,Imlib,fgl,WidgetWindows,Widgethandlers;
  

procedure Run;

var Handlers : tWidgetHandlerList;

implementation

procedure Run;
var
  event : tXevent;
  done : boolean;
  WidgetWindow : tWidgetWindow;
  Handler : tWidgetHandler;
  I : integer;
  X11 : tHandle;
  FDSet : tFDSet;

begin
  Done := false;
  X11 := ConnectionNumber(Display);
  fpFD_ZERO(FDSET);
  fpFD_SET(X11,FDSET);

  while not done do
  begin
    fpselect(X11+1,@FDSET,nil,nil,16);
    while xpending(Display) > 0 do
    begin
      xnextevent(Display, @event);
      try
        if HandlersByxHandle.Find(event.xany.window,I) then
        begin
          Handler := HandlersByXHandle.Data[I];
          WidgetWindow :=WidgetWindowsByXHandle[event.xany.window];
          Handler.HandleXEvent(event,WidgetWindow);
        end;
      except
           on ElistError  do writeln('event not handled');
      end;
    end;
    for I := 0 to Handlers.Count - 1 do
    begin
      Handlers[i].CheckPipes;
      Handlers[i].ProcessPendingTasks;
    end;

  end;
end;


initialization
  Handlers := tWidgetHandlerList.Create;
finalization;
  Handlers.Free;

end.
