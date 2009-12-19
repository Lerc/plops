program calc;

{$mode objfpc}{$H+}

uses
sysutils,BaseUnix,Math,DateUtils, WidgetButtons, InteractiveWidget,Classes,process;

const
  ScreenWidth = 15;
type

    { tFunctionButton }

    tFunctionButton = class(tWidgetButton)
       functionname : string;
       Constructor Create(X,Y,nWidth,nheight : integer; clickEvent : tnotifyevent = nil;f : string='');
    end;

    { tCharacterButton }

    tCharacterButton = class(tWidgetButton)
       character : string;
       Constructor Create(X,Y,nWidth,nheight : integer; clickEvent : tnotifyevent = nil;C : string=' ');
    end;

    { tCalculatorScreen }

    tCalculatorScreen = class(tWidgetButton)
    public
       procedure DoMouseDown(button,X,Y : integer); Override;
       procedure DoMouseUp(button,X,Y : integer); Override;
    private
      FCursorPosition: integer;
      FText: string;
      procedure SetCursorPosition(const AValue: integer);
      procedure SetText(const AValue: string);

    public
       BaseCode : string;
       VisibleText : String;
       ShowCursor : boolean;
       ScreenStart : Integer;
       UpdateNeeded : Boolean;
       procedure Clear;
       function Draw : String;
       procedure Insert(S:String);
       Procedure Wrap(pre,post : String);
       Procedure Delete;
       Procedure Backspace;
       procedure Evaluate;
       property CursorPosition : integer read FCursorPosition write SetCursorPosition;
       property Text : string read FText write SetText;

    end;

    { tCalculator }

    tCalculator = class(tInteractiveWidget)
    private
      FHistoryPosition: integer;
      procedure SetHistoryPosition(AValue: integer);
    public
       InvertButton : tWidgetButton;
       Base2Button : tWidgetButton;
       Base8Button : tWidgetButton;
       Base10Button : tWidgetButton;
       Base16Button : tWidgetButton;
       OneOverXButton : tWidgetButton;
       SizeButton : tWidgetButton;
       Screen : tCalculatorScreen;
       Number1Button : tCharacterButton;
       Number2Button : tCharacterButton;
       Number3Button : tCharacterButton;
       Number4Button : tCharacterButton;
       Number5Button : tCharacterButton;
       Number6Button : tCharacterButton;
       Number7Button : tCharacterButton;
       Number8Button : tCharacterButton;
       Number9Button : tCharacterButton;
       Number0Button : tCharacterButton;
       PointButton : tCharacterButton;
       PiButton : tCharacterButton;
       MultiplyButton : tCharacterButton;
       DivideButton : tCharacterButton;
       PlusButton : tCharacterButton;
       MinusButton : tCharacterButton;
       OneOverButton : tFunctionButton;
       SqrtButton : tFunctionButton;
       LogButton : tFunctionButton;
       SinButton : tFunctionButton;
       CosButton : tFunctionButton;
       TanButton : tFunctionButton;
       PowerButton : tCharacterButton;
       OpenBracketButton : tCharacterButton;
       CloseBracketButton : tCharacterButton;
       StoreButton : tWidgetButton;
       RecallButton : tWidgetButton;
       ModButton : tCharacterButton;
       EqualsButton : tWidgetButton;


       ClearButton : tWidgetButton;
       AllClearButton : tWidgetButton;
       History : tStringList;
       constructor create;
       procedure Evaluate;
       procedure CharacterButtonClicked(Sender : tObject);
       procedure ClearButtonClicked(Sender : tObject);
       procedure AllClearButtonClicked(Sender : tObject);
       procedure FunctionButtonClicked(Sender : tObject);
       procedure StoreButtonClicked(Sender : tObject);
       procedure RecallButtonClicked(Sender : tObject);
       procedure EqualsButtonClicked(Sender : tObject);

       procedure Base2ButtonClicked(Sender : tObject);
       procedure Base8ButtonClicked(Sender : tObject);
       procedure Base10ButtonClicked(Sender : tObject);
       procedure Base16ButtonClicked(Sender : tObject);

       Procedure init; override;
       procedure NoEvents; override;
       procedure KeyPress(Code : integer;State :integer;keysym : integer; keyascii:integer); override;
       property HistoryPosition : integer read FHistoryPosition write SetHistoryPosition;

    end;

function RunProgram(cmdline : String) : String;
var
   p : tProcess;
   output : tStringList;
begin
   p := tProcess.Create(nil);
   Output := tStringlist.create;

   p.Commandline:=cmdline;
   p.Options := p.Options + [poWaitonExit,poUsePipes];
   p.Execute;
   Output.LoadFromStream(p.Output);
   Result := Output.text;
   output.free;
   P.Free;
end;

{ tFunctionButton }

constructor tFunctionButton.Create(X, Y, nWidth, nheight: integer;
  clickEvent: tnotifyevent; f: string);
begin
  inherited create(X,Y,nWidth,nHeight,ClickEvent);
  functionname := f;
end;

{ tCalculatorScreen }

procedure tCalculatorScreen.DoMouseDown(button, X, Y: integer);
begin
  inherited DoMouseDown(button, X, Y);
  updateNeeded := true;
  CursorPosition := ScreenStart+((x-20) div 14);
end;

procedure tCalculatorScreen.DoMouseUp(button, X, Y: integer);
begin
  inherited DoMouseUp(button, X, Y);
  updateNeeded := true;
end;

procedure tCalculatorScreen.SetCursorPosition(const AValue: integer);
begin
  if FCursorPosition=AValue then exit;
  FCursorPosition:=AValue;
  UpdateNeeded := true;
  if CursorPosition <0 then CursorPosition := 0;
  if CursorPosition > length(text) then CursorPosition := Length(Text);
  if CursorPosition < screenstart then ScreenStart := cursorPosition;
  if ScreenStart+ScreenWidth < CursorPosition then ScreenStart := CursorPosition-ScreenWidth;
end;


procedure tCalculatorScreen.SetText(const AValue: string);
begin
  if FText=AValue then exit;
  FText:=AValue;
  updateNeeded :=true;
end;

procedure tCalculatorScreen.Clear;
begin
  Text := '';
  CursorPosition:=0;
end;

function tCalculatorScreen.Draw: String;
var
   CursorX : integer;
begin
  result :='set_color 0 64 0 255'+#10;
  result+= 'set_font screentext'+#10;
  VisibleText := Copy(text,Screenstart+1,ScreenWidth);
    if text = '' then
    begin
      Result+='text_draw 23 46 0'+#10;
    end
    else
    begin
      Result+='text_draw 23 46 '+VisibleText+#10;
    end;
    if ShowCursor and (text<>'') then
    begin
      Result+='set_color 0 0 0 128'+#10;
      CursorX := (CursorPosition-ScreenStart)*14+24;
      Result+='fill_rectangle '+intToStr(CursorX)+' 44 3 24'+#10;
    end;
end;

procedure tCalculatorScreen.Insert(S: String);
var
   NewText : String;
begin
   NewText := Text;
   system.insert(S,NewText,CursorPosition+1);
   Text:=NewText;
   CursorPosition:=CursorPosition+length(S);;
end;

procedure tCalculatorScreen.Wrap(pre, post: String);
begin
   Text := pre+text+Post;
   CursorPosition:=length(text);
end;

procedure tCalculatorScreen.Delete;
var
   NewText : String;
begin
  NewText := Text;
  system.Delete(NewText,CursorPosition+1,1);
  Text:=NewText;
end;

procedure tCalculatorScreen.Backspace;
var
   NewText : String;
begin
  NewText := Text;
  system.Delete(NewText,CursorPosition,1);
  Text:=NewText;
   CursorPosition:=CursorPosition-1;
end;

procedure tCalculatorScreen.Evaluate;
var
   command : string;
   newValue : String;
begin
  Command := './evaluate  '+ basecode + ' '''+Text+'''';
  //writeln('running: '+Command);
  NewValue := trim(RunProgram(Command));
  Text := NewValue;
  ScreenStart := 0;
  CursorPosition:=Min(screenwidth,Length(newValue));
end;

constructor tCharacterButton.Create(X, Y, nWidth, nheight: integer;
  clickEvent: tnotifyevent; C: string);
begin
  inherited create(X,Y,nWidth,nHeight,ClickEvent);
  Character := C;
end;


var
   calculator : tCalculator;

procedure tCalculator.SetHistoryPosition(AValue: integer);
begin
  if Avalue < 0 then AValue := 0;
  if Avalue > History.count then Avalue := History.count;
  if FHistoryPosition=AValue then exit;
  if fHistoryPosition<History.count then History[fHistoryPosition] := Screen.text;
  FHistoryPosition:=AValue;
  if fHistoryPosition >= History.count then Screen.text := '' else Screen.text := History[fHistoryPosition];
end;

constructor tCalculator.create;
begin
  inherited;
  History := tStringList.Create;
  History.add('top of history');
    InvertButton := tWidgetButton.create(10,94,36,26);
  Base2Button := tWidgetButton.create(49,94,36,26,@Base2ButtonClicked);
  Base8Button := tWidgetButton.create(86,94,36,26,@Base8ButtonClicked);
  Base10Button := tWidgetButton.create(124,94,36,26,@Base10ButtonClicked);
  Base16Button := tWidgetButton.create(162,94,36,26,@Base16ButtonClicked);
  SizeButton := tWidgetButton.create(201,94,36,26);
  InvertButton.group:=1;
  Base2Button.group:=2;
  Base8Button.group:=2;
  Base10Button.group:=2;
  Base16Button.group:=2;
  Base10Button.Down:=true;
  SizeButton.group := 3;
  InvertButton.CanToggle := true;
  SizeButton.CanToggle := true;

  Screen :=tCalculatorScreen.create(14,38,226,36);
  Screen.ShowCursor := true;


   Number1Button := tCharacterButton.create(14,271,40,32,@CharacterButtonClicked,'1');
   Number2Button := tCharacterButton.create(60,271,40,32,@CharacterButtonClicked,'2');
   Number3Button := tCharacterButton.create(106,271,40,32,@CharacterButtonClicked,'3');
   Number4Button := tCharacterButton.create(14,233,40,32,@CharacterButtonClicked,'4');
   Number5Button := tCharacterButton.create(60,233,40,32,@CharacterButtonClicked,'5');
   Number6Button := tCharacterButton.create(106,233,40,32,@CharacterButtonClicked,'6');
   Number7Button := tCharacterButton.create(14,194,40,32,@CharacterButtonClicked,'7');
   Number8Button := tCharacterButton.create(60,194,40,32,@CharacterButtonClicked,'8');
   Number9Button := tCharacterButton.create(106,194,40,32,@CharacterButtonClicked,'9');
   Number0Button := tCharacterButton.create(14,309,40,32,@CharacterButtonClicked,'0');
   PointButton := tCharacterButton.create(60,309,40,32,@CharacterButtonClicked,'.');
   PiButton := tCharacterButton.create(106,309,40,32,@CharacterButtonClicked,'PI');
   MultiplyButton := tCharacterButton.create(153,233,40,32,@CharacterButtonClicked,'*');;
   DivideButton := tCharacterButton.create(194,233,40,32,@CharacterButtonClicked,'/');;
   PlusButton := tCharacterButton.create(153,271,40,32,@CharacterButtonClicked,'+');
   MinusButton := tCharacterButton.create(194,271,40,32,@CharacterButtonClicked,'-');;

   ClearButton := tWidgetButton.create(153,194,40,32,@ClearButtonClicked);
   AllClearButton := tWidgetButton.create(194,194,40,32,@AllClearButtonClicked);


   OneOverButton := tFunctionButton.create(10,127,36,26,@functionButtonClicked,'1/');
   SqrtButton := tFunctionButton.create(49,127,36,26,@functionButtonClicked,'sqrt');
   LogButton := tFunctionButton.create(86,127,36,26,@functionButtonClicked,'log');
   SinButton := tFunctionButton.create(124,127,36,26,@functionButtonClicked,'sin');
   CosButton := tFunctionButton.create(162,127,36,26,@functionButtonClicked,'cos');
   TanButton := tFunctionButton.create(201,127,36,26,@functionButtonClicked,'tan');
   PowerButton := tCharacterButton.create(49,159,36,26,@CharacterButtonClicked,'^');
   OpenBracketButton := tCharacterButton.create(86,159,36,26,@CharacterButtonClicked,'(');
   CloseBracketButton := tCharacterButton.create(124,159,36,26,@CharacterButtonClicked,')');
   StoreButton := tWidgetButton.create(162,159,36,26,@StoreButtonClicked);
   RecallButton := tWidgetButton.create(201,159,36,26,@RecallButtonClicked);
   ModButton := tCharacterButton.create(199,306,42,34,@CharacterButtonClicked,'%');
   EqualsButton := tWidgetButton.create(153,306,42,34,@EqualsButtonClicked);

  ButtonSet.Buttons.add(Screen);
  ButtonSet.Buttons.add(InvertButton);
  ButtonSet.Buttons.add(Base2Button);
  ButtonSet.Buttons.add(Base8Button);
  ButtonSet.Buttons.add(Base10Button);
  ButtonSet.Buttons.add(Base16Button);
  ButtonSet.Buttons.add(SizeButton);

  ButtonSet.Buttons.add(Number0Button);
  ButtonSet.Buttons.add(Number1Button);
  ButtonSet.Buttons.add(Number2Button);
  ButtonSet.Buttons.add(Number3Button);
  ButtonSet.Buttons.add(Number4Button);
  ButtonSet.Buttons.add(Number5Button);
  ButtonSet.Buttons.add(Number6Button);
  ButtonSet.Buttons.add(Number7Button);
  ButtonSet.Buttons.add(Number8Button);
  ButtonSet.Buttons.add(Number9Button);
  ButtonSet.Buttons.add(PIButton);
  ButtonSet.Buttons.add(PointButton);
  ButtonSet.Buttons.add(MultiplyButton);
  ButtonSet.Buttons.add(DivideButton);
  ButtonSet.Buttons.add(PlusButton);
  ButtonSet.Buttons.add(MinusButton);

  ButtonSet.Buttons.add(ClearButton);
  ButtonSet.Buttons.add(AllClearButton);

  ButtonSet.Buttons.add(OneOverButton);
  ButtonSet.Buttons.add(sqrtButton);
  ButtonSet.Buttons.add(LogButton);
  ButtonSet.Buttons.add(SinButton);
  ButtonSet.Buttons.add(CosButton);
  ButtonSet.Buttons.add(TanButton);
  ButtonSet.Buttons.add(PowerButton);
  ButtonSet.Buttons.add(OpenBracketButton);
  ButtonSet.Buttons.add(CloseBracketButton);
  ButtonSet.Buttons.add(StoreButton);
  ButtonSet.Buttons.add(RecallButton);
  ButtonSet.Buttons.add(ModButton);
  ButtonSet.Buttons.add(EqualsButton);

end;

procedure tCalculator.Evaluate;
begin
  if (Screen.text<>'') and (History[History.count-1] <> screen.text) then History.add(Screen.text);
  Screen.Evaluate;
  if (Screen.text<>'') and (History[History.count-1] <> screen.text) then History.add(Screen.text);
  fHistoryPosition := History.count -1;
end;

procedure tCalculator.CharacterButtonClicked(Sender: tObject);
begin
  Screen.Insert(tCharacterButton(Sender).Character);
end;

procedure tCalculator.ClearButtonClicked(Sender: tObject);
begin
Screen.Clear;
end;

procedure tCalculator.AllClearButtonClicked(Sender: tObject);
begin
  Screen.Clear;
end;

procedure tCalculator.FunctionButtonClicked(Sender: tObject);
begin
  Screen.Wrap(tFunctionButton(Sender).functionName+'(',')');
end;

procedure tCalculator.StoreButtonClicked(Sender: tObject);
begin

end;

procedure tCalculator.RecallButtonClicked(Sender: tObject);
begin

end;

procedure tCalculator.EqualsButtonClicked(Sender: tObject);
begin
  Evaluate;
end;

procedure tCalculator.Base2ButtonClicked(Sender: tObject);
begin
  screen.Basecode := '-bin';
  screen.evaluate;
end;

procedure tCalculator.Base8ButtonClicked(Sender: tObject);
begin
  screen.Basecode := '-oct';
  screen.evaluate;
end;

procedure tCalculator.Base10ButtonClicked(Sender: tObject);
begin
  screen.Basecode := '-dec';
  screen.evaluate;
end;

procedure tCalculator.Base16ButtonClicked(Sender: tObject);
begin
  screen.Basecode := '-hex';
  screen.evaluate;
end;

procedure tCalculator.init;
begin
  Writeln(CommandPipe,'create_window bob 100 400 256 360');
  Writeln(CommandPipe,'load_image Base CalcBase.png');
  Writeln(CommandPipe,'load_image Down CalcButtonsDown.png');
  Writeln(CommandPipe,'set_image bob');
  Writeln(CommandPipe,'clear_color 0 255 0 0');
  Writeln(CommandPipe,'blend_image_onto_image Base 1 0 0 256 360 0 0 256 360');
  Writeln(CommandPipe,'set_window bob');
  Writeln(CommandPipe,'set_shape');
  Writeln(CommandPipe,'set_has_alpha false');
  Writeln(CommandPipe,'set_image bob');
  Writeln(CommandPipe,'set_color 0 64 0 255');
  Writeln(CommandPipe,'load_font screentext ScreenText/18');
  Writeln(CommandPipe,'set_font screentext');
  Writeln(CommandPipe,'text_draw 30 46 123456789.012');
  Write(CommandPipe,ButtonSet.GenerateMaskSequence);
  Writeln(CommandPipe,'start_events');

  Writeln(CommandPipe,'set_image bob');
  DrawAllButtons;
  Flush(CommandPipe);

  Screen.Clear;
end;

procedure tCalculator.NoEvents;
begin
  inherited NoEvents;
  if screen.UpdateNeeded then
  begin
     DrawButton(Screen);
     Write(CommandPipe,Screen.Draw);

     Screen.UpdateNeeded :=false;
     UpdateRequested:=true;
   end;
  if UpdateRequested then
  begin
     Writeln(CommandPipe,'update');
     UpdateRequested := false;
  end;
  flush(CommandPipe);
end;

procedure tCalculator.KeyPress(Code: integer; State: integer; keysym: integer; KeyAscii : integer);
begin
  //inherited KeyPress(Code, State, keysym);
  if keyascii>=32 then
  begin
     Screen.insert(chr(KeyAscii));
  end;
  case keysym of
    65361:
    begin
       Screen.CursorPosition:=Screen.CursorPosition-1;
    end;
    65363:
    begin
       Screen.CursorPosition:=Screen.CursorPosition+1;
    end;
    65288:
    begin
       Screen.BackSpace;
    end;
    65535:
    begin
       Screen.Delete;
    end;
    $ff54:    //down
    begin
       writeln('next:',HistoryPosition+1);
       HistoryPosition:=HistoryPosition+1;
    end;
    $ff52:    //up
    begin
       writeln('prev',HistoryPosition-1);
       HistoryPosition:=HistoryPosition-1;
    end;
    65421,65923:
    begin
       Evaluate;
    end;
   end;
end;

{
procedure update;
begin
  Writeln(CommandPipe,'set_image bob');
  Writeln(CommandPipe,'blend_image_onto_image Base 1 0 0 256 360 0 0 256 360');
  Flush(CommandPipe);
end;

procedure Eventloop;
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
  	    writeln( 'Event:' +Line);
  		  Line := '';
      end else
      begin
        Line+=chr(c);
      end;
    end;
  end;
end;
}

{$IFDEF WINDOWS}{$R calc.rc}{$ENDIF}

begin
  Calculator := tCalculator.Create;
  Calculator.init;
  Calculator.EventLoop;
  Calculator.Free;

end.

