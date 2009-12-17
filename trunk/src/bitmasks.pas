unit Bitmasks;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils; 

type

    { tBitmask }

    tBitmask = class
    private
      function Getbits(x, y : integer): boolean;
      procedure Setbits(x, y : integer; const AValue: boolean);
      protected
       fWidth, fHeight : integer;
       Surface : Pointer;
      public
       constructor create(W : integer; H : integer);
       constructor CreateFromBytes(W , H : integer; Data:pByte;initialoffset : integer=0;byteskip : integer = 1);
       property Width : integer read fWidth;
       property Height : integer read fHeight;
       property bits[x,y : integer] : boolean read Getbits write Setbits; default;
    end;

implementation

{ tBitmask }

function tBitmask.Getbits(x, y : integer): boolean;
var
  Walk : pByte;
  offset : integer;
  bit : byte;
begin
  if (X<0) or (Y<0) or (Width<X) or (Height<Y) then
  begin
    Result := false;
    Exit;
  end;
  Walk := Surface;
  offset := Y*width+x;
  Walk+=offset div 8;
  bit := 1 shl (offset and 7);
  result := (Walk^ and bit) <> 0;
end;

procedure tBitmask.Setbits(x, y : integer; const AValue: boolean);
var
  Walk : pByte;
  offset : integer;
  bit : byte;
begin
  offset := Y*width+x;
  Walk+=offset div 8;
  bit := 1 shl (offset and 7);
  if avalue
     then Walk^:=walk^ or bit
     else Walk^:=walk^ and not bit;
end;

constructor tBitmask.create(W: integer; H: integer);
begin
 inherited Create;
 fWidth := w;
 fHeight := h;
 Surface := Allocmem((W*H) div 8 + 1);
end;

constructor tBitmask.CreateFromBytes(W, H: integer; Data: pByte;initialoffset : integer;
  byteskip: integer);
var
  SrcWalk,DestWalk : pByte;
  tx,ty : integer;
  hold : integer;
  count : integer;
begin
  Create(W,H);
  DestWalk := surface;
  SrcWalk := Data;
  SrcWalk+=initialOffset;
  count :=0;
  for ty := 0 to h-1 do
  begin
    for tx := 0 to w-1 do
    begin
       if srcWalk^ > 128 then Hold:=hold + $100;
       Hold := hold shr 1;
       Count+=1;
       if Count = 8 then
       begin
         Destwalk^ := Hold;
         Count :=0;
         DestWalk+=1;
       end;
       srcwalk+=byteskip;
    end;
  end;
end;

end.

