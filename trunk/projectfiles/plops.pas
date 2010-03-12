program plops;
{$mode objfpc}{$H+}
uses
  x, xlib, xshm, BaseUnix, unix, ipc,sysutils,sysconst, Classes, pipes, Imlib, WidgetWindows,
  Widgethandlers, eventloop, CommandOptions, Bitmasks, controlbar,
configuration;


procedure LaunchProcess(Const Path: AnsiString; Const ComLine: Array Of AnsiString);
var
  pid    : longint;
  e : EOSError;
Begin
  pid:=fpFork;
  if pid=0 then
   begin
     {The child does the actual exec, and then exits}
      fpexecl(Path,Comline);
     { If the execve fails, we return an exitvalue of 127, to let it be known}
     fpExit(127);
   end
  else
  begin
   if pid=-1 then         {Fork failed}
    begin
      e:=EOSError.CreateFmt(SExecuteProcessFailed,[Path,-1]);
      e.ErrorCode:=-1;
      raise e;
    end;

  { We're in the parent }
  end;
end;



procedure AddHandlers;
var
  Base : String;
  WidgetName :String;
  WidgetDir : String;
  I : integer;
  Attr : longint;
  Handler : tWidgetHandler;
begin
  Base := GetCurrentDir;
  //writeln('CurrentDir:',Base);
  for I := 1 to paramcount do
  begin
       WidgetName := paramstr(I);
       WidgetDir := BAse+'/'+WidgetName;
       WidgetName := ExtractFileName(WidgetName);
       Attr := FileGetAttr(WidgetDir);
       if (Attr > 0) and ((attr and faDirectory)<>0) then
       begin
          Handler :=tWidgetHandler.Create(WidgetDir,WidgetName);
          Handlers.add(Handler);
          SetCurrentDir(WidgetDir);
          Launchprocess(WidgetDir+'/'+WidgetName,['--launchedbyhandler']);
          SetCurrentDir(Base);
       end;
  end;
end;

begin
  loadconfig;
  WidgetWindows.init;
  AddHandlers;
  //writeln('starting event loop');
  eventLoop.Run;
	WidgetWindows.done;
end.
