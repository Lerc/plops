unit WidgetButtons;

{$mode objfpc}{$H+}

interface

uses
  Types,Classes, SysUtils, fgl;

type

     tButtonState = (bsDown,bsHilighted,bsInactive,bsSelected);
     tButtonStateSet = set of tButtonState;

     { tWidgetButton }

     tWidgetButton = Class
     public
        procedure DoClick; virtual;
        procedure DoMouseDown(button,X,Y : integer); virtual;
        procedure DoMouseUp(button,X,Y : integer); virtual;
     private
       function getHeight: integer;
       function getState: tButtonStateSet;
       function getWidth: integer;
       procedure SetState(const AValue: tButtonStateSet);
     public
        Bounds : tRect;
        onClick : tNotifyEvent;
        Down: Boolean;
        Hilighted : boolean;
        Inactive : boolean;
        Selected : boolean;
        group : integer;
        cantoggle : boolean;
        Constructor Create(X,Y,Width,height : integer; clickEvent : tnotifyevent = nil);
        function ContainsPoint(p : tPoint) : boolean;
        property Left : integer read bounds.left;
        property Top : integer read bounds.Top;
        property Right : integer read bounds.Right;
        property Bottom : integer read bounds.Bottom;
        property Width : integer read getWidth;
        property Height : integer read getHeight;
        property State : tButtonStateSet read getState write SetState;
     end;

     tWidgetButtonList = specialize tFPGObjectList <tWidgetButton>;

     { tWidgetButtonSet }

     tWidgetButtonSet = class
        Buttons : tWidgetButtonList;
        BaseImage : String;
        DownImage : String;
        OverImage : String;
        SelectedImage :String;
        constructor Create(Base :String;  Down:string; Over:string=''; Selected:String='');
        Destructor destroy; override;
        function GenerateMaskSequence : string;
        function FindButton(X,Y : integer) : tWidgetButton;
     end;

implementation

{ tWidgetButtonSet }

constructor tWidgetButtonSet.Create(Base: String; Down: string; Over: string;
  Selected: String);
begin
  BaseImage := Base;
  DownImage := Down;
  OverImage := Over;
  SelectedImage :=Selected;

  if OverImage = '' then OverImage := BaseImage;
  If SelectedImage = '' then SelectedImage := DownImage;
  Buttons := tWidgetbuttonList.Create;
end;

destructor tWidgetButtonSet.destroy;
begin
  buttons.free;
  inherited destroy;
end;

function tWidgetButtonSet.GenerateMaskSequence: string;
var
   I : integer;
   current : tWidgetButton;
   Lines : tStringlist;
   w,h : integer;
begin
   Lines := tStringList.Create;

   lines.add('create_image eventmask 256 360');
   lines.add('set_image eventmask');
   lines.add('clear_color 0 0 0 0');
   lines.add('set_color 255 255 255 255');

   for I := 0 to buttons.count-1 do
   begin
     Current := buttons[I];
     w := current.Bounds.Right-current.Bounds.Left;
     h := current.Bounds.Bottom-current.Bounds.Top;
     lines.add('fill_rectangle '+inttoStr(current.Bounds.Left)+' '+inttoStr(current.bounds.Top)+' '+inttoStr(w)+' '+inttoStr(h));
   end;
   lines.add('set_event_mask');
   lines.add('free_image eventmask');


   Result := lines.text;
   Lines.Free;
end;

function tWidgetButtonSet.FindButton(X, Y: integer): tWidgetButton;
  var
  I : integer;
  B : tWidgetButton;
  p : tPoint;
begin
  p:=Point(X,Y);
  for I := 0 to Buttons.Count-1 do
  begin
    b:=Buttons[i];
    if b.ContainsPoint(p) then
    begin
       Result := b;
       exit;
    end;
  end;
  result := nil;
end;


{ tWidgetButton }

procedure tWidgetButton.DoClick;
begin
  if assigned(onClick) then onClick(self);
end;

procedure tWidgetButton.DoMouseDown(button, X, Y: integer);
begin

end;

procedure tWidgetButton.DoMouseUp(button, X, Y: integer);
begin

end;

function tWidgetButton.getHeight: integer;
begin
  result:=Bottom-Top;
end;

function tWidgetButton.getState: tButtonStateSet;
begin
  result := [];
  if Down then result+=[bsDown];
  if Selected then result+=[bsSelected];
  if Hilighted then result+=[bsHilighted];
  if Inactive then result+=[bsInactive];

end;

function tWidgetButton.getWidth: integer;
begin
  Result := Right-Left;
end;

procedure tWidgetButton.SetState(const AValue: tButtonStateSet);
begin
  Down := bsDown in AValue;
  Selected := bsSelected in Avalue;
  Hilighted := bsHilighted in Avalue;
  Inactive := bsInactive in Avalue;
end;

constructor tWidgetButton.Create(X, Y, Width, height: integer; clickEvent : tnotifyevent = nil);
begin
  Bounds.TopLeft:=Point(X,Y);
  Bounds.Bottom:=Bounds.Top+Height;
  Bounds.Right:=Bounds.Left+Width;
  OnClick := ClickEvent;
end;

function tWidgetButton.ContainsPoint(p : tPoint): boolean;
begin
  result := PtinRect(Bounds,P);
end;

end.

