unit controlbar;

{$mode objfpc}

interface

uses
  Classes, SysUtils, WidgetWindows;

type

  { tControlBar }

  tControlBar = class(tWidgetWindow)
    Controllfor : tWidgetWindow;

    Constructor Create(over : tWidgetWindow);
  end;

implementation
{incData tools.png ToolBarPNG}
{incData ontop.png OntopPNG}

{ tControlBar }

constructor tControlBar.Create(over: tWidgetWindow);
const
  BarWidth = 142;
var
   overbounds : tRect;
   CenterX : integer;
begin
  OverBounds := Over.GetPosition;
   CenterX := (OverBounds.Right-OverBounds.Left) div 2 + OverBounds.Left;

  inherited Create(CenterX-BarWidth div 2, OverBounds.Top - 45,BarWidth,41);
end;

end.

