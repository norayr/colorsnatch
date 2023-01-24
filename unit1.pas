unit unit1; 

{
    ColorSnatch, the game. http://colorsnatch.sourceforge.net/
    Copyright (C) 2004, Denis Lianda

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License version 2 as
    published by the Free Software Foundation.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
}

{I tried to comment the code as well as I can, but since you've got an IDE and all,
you don't need that much code documetation. I keep trying to convince myself that's
true, anyways.}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Buttons, StdCtrls, Menus, ComCtrls, EditBtn, LMessages, LCLType, laz2_XMLCfg,
  Unit2, fields, langfiles, Process;

type

  { TForm1 }

  TForm1 = class(TForm)
    HugeImage: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    MainMenu1: TMainMenu;
    FileMenu: TMenuItem;
    DivMenu: TMenuItem;
    LangMenu: TMenuItem;
    EnglishMenu: TMenuItem;
    EndGame: TMenuItem;
    GermanMenu: TMenuItem;
    BasqueMenu: TMenuItem;
    ArmenianMenu: TMenuItem;
    Russian_UTF8Menu: TMenuItem;
    Theme11: TMenuItem;
    Russian_cp1251Menu: TMenuItem;
    PolishMenu: TMenuItem;
    pl1_7: TSpeedButton;
    pl2_1: TSpeedButton;
    pl2_2: TSpeedButton;
    pl2_7: TSpeedButton;
    pl2_3: TSpeedButton;
    pl2_4: TSpeedButton;
    pl2_5: TSpeedButton;
    pl2_6: TSpeedButton;
    pl1_6: TSpeedButton;
    pl1_5: TSpeedButton;
    pl1_4: TSpeedButton;
    pl1_3: TSpeedButton;
    pl1_2: TSpeedButton;
    pl1_1: TSpeedButton;
    pl1_0: TSpeedButton;
    pl2_0: TSpeedButton;
    Theme10: TMenuItem;
    Theme9: TMenuItem;
    SpanishMenu: TMenuItem;
    RussianMenu: TMenuItem;
    Theme8: TMenuItem;
    Theme7: TMenuItem;
    Theme6: TMenuItem;
    Theme0: TMenuItem;
    Theme1: TMenuItem;
    Theme2: TMenuItem;
    Theme3: TMenuItem;
    Theme4: TMenuItem;
    Theme5: TMenuItem;
    ThemeSelect: TMenuItem;
    Time5: TMenuItem;
    Time10: TMenuItem;
    Time15: TMenuItem;
    TimeLimit: TMenuItem;
    About: TMenuItem;
    Div30: TMenuItem;
    Div50: TMenuItem;
    Div95: TMenuItem;
    Quit: TMenuItem;
    NewGame1: TMenuItem;
    NewGame2: TMenuItem;
    Options: TMenuItem;
    HelpMenu: TMenuItem;
    PaintBox1: TPaintBox;
    Shape1: TShape;
    Shape2: TShape;
    Timer1: TTimer;
    Timer2: TTimer;
    procedure AboutClick(Sender: TObject);
    procedure ArmenianMenuClick(Sender: TObject);
    procedure BasqueMenuClick(Sender: TObject);
    procedure DivClick(Sender: TObject);
    procedure DrawSelectionMarks(Sender: TObject);
    procedure EndGameClick(Sender: TObject);
    procedure EnglishMenuClick(Sender: TObject);
    procedure Form1Close(Sender: TObject; var CloseAction: TCloseAction);
    procedure Form1Create(Sender: TObject);
    procedure Form1Destroy(Sender: TObject);
    procedure Form1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Form1Paint(Sender: TObject);
    procedure GermanMenuClick(Sender: TObject);
    procedure LangMenuClick(Sender: TObject);
    procedure NewGame1Click(Sender: TObject);
    procedure NewGame2Click(Sender: TObject);
    procedure Player1Click(Sender: TObject);
    procedure Player2Click(Sender: TObject);
    procedure PolishMenuClick(Sender: TObject);
    procedure QuitClick(Sender: TObject);
    procedure RussianMenuClick(Sender: TObject);
    procedure Russian_cp1251MenuClick(Sender: TObject);
    procedure Russian_UTF8MenuClick(Sender: TObject);
    procedure SpanishMenuClick(Sender: TObject);
    procedure ThemeClick(Sender: TObject);
    procedure TimeClick(Sender: TObject);
    procedure Timer1StartTimer(Sender: TObject);
    procedure Timer1StopTimer(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2StartTimer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
  private
    { private declarations }
    procedure WMGetDlgCode(var msg: TLMNoParams); message LM_GETDLGCODE;
  public
    { public declarations }
  end; 

var
  Form1: TForm1; 

var
  Config: TXMLConfig;

{The game field}
var Field: TField;

{The file and directory where we shall store a simple configuration file.}

{Files' location. See also: GetConfigDir procedure}
const ConfigFile = 'colorsnatch.cfg';
var ConfigDir, ConfigDirAndFile:string;
const LangPath = 'lang'+PathDelim;

{Territories used for Player1, Player2 and for AI calculations}
var Player1Territory, Player2Territory, FictiveTerritory: TTerritory;

{Theme number, used in slicing the huge image; Maximum themenumber (amount of themes - 1}
var ThemeNumber, MaxThemeNumber: integer;

{Specifies the size of same color groups in the field. The larger, the smaller
the groups are. Should be within 1..100. Think of it as percentage. Specifies the
weight the random tile receives in the generation process}
var Diversity: integer;

{0..7, the colors players have chosen}
var Player1Selection, Player2Selection: integer;
var Player1Frame, Player2Frame: integer;

{1 or 2, or 0 when the game hasn't started.}
var PlayerActive:integer;

{True if playing against computer}
var VsComputer:boolean;

{The language file to use}
var LangFile:TLangFile;
var CurrentLanguage: integer;
var CurrentLanguageFileName: string;

{Draw one tile, RelX and RelY specify its position in the Field array}
procedure DrawFieldItem(RelX,RelY:integer);
{Draw the field}
procedure DrawEntireField;
{Handle everyting when a player makes his move}
procedure MakeMove;
{Endgame cleanup}
procedure EndTheGame(WipeField:boolean);

{Translate the captions of UI elements}
procedure TranslateUI;

implementation


procedure GetConfigDir;
begin
{$IFDEF WIN32}
  ConfigDir:='';
  ConfigDirAndFile:=ConfigDir+ConfigFile;
{$ELSE}
  ConfigDir:=GetEnvironmentVariable('HOME') + PathDelim + '.colorsnatch';
  ConfigDirAndFile:=ConfigDir+PathDelim+ConfigFile;
{$ENDIF}
end;

{Load the initial config from the config file if it exists or initialize with
default values}
procedure LoadConfig;
begin
  ThemeNumber:=Config.GetValue('Options/Theme/Themenumber',0);
  Diversity:=Config.GetValue('Options/Diversity/Diversity',50);
  Form1.Timer1.Interval:=Config.GetValue('Options/Timer1/Interval',10*1000);
  CurrentLanguage:=Config.GetValue('Options/Language/CurrentLanguage',0);
  CurrentLanguageFileName:=Config.GetValue('Options/Language/CurrentLanguageFileName','');
  if (CurrentLanguageFileName <> '') and fileexists(LangPath+CurrentLanguageFileName) then lfload(LangPath+CurrentLanguageFileName, LangFile) else lfFree(LangFile);
  
{Initialize the menus}

  Form1.LangMenu.Items[CurrentLanguage].Checked:=true;

  Form1.ThemeSelect.Items[ThemeNumber].Checked:=true;

  case Form1.Timer1.Interval of
    5000: Form1.Time5.Checked:=true;
    10000: Form1.Time10.Checked:=true;
    15000: Form1.Time15.Checked:=true;
  end;

  case Diversity of
    35: Form1.Div30.Checked:=true;
    50: Form1.Div50.Checked:=true;
    95: Form1.Div95.Checked:=true;
  end;

end;

{Save the configuration file, creating it if necessary}
procedure SaveConfig;
begin
  If not DirectoryExists(ConfigDir) then CreateDir(ConfigDir);
  Config.SetValue('Options/Theme/Themenumber',ThemeNumber);
  Config.SetValue('Options/Diversity/Diversity',Diversity);
  Config.SetValue('Options/Timer1/Interval', Form1.Timer1.Interval);
  Config.SetValue('Options/Language/CurrentLanguage',CurrentLanguage);
  Config.SetValue('Options/Language/CurrentLanguageFileName',CurrentLanguageFileName);
  Config.Flush;
end;

procedure DrawFieldItem(RelX,RelY:integer);
var
  RectSrc,RectDest: TRect;
begin
{The tile is 20x20 by design, so we just draw the picture we want.}

{The tile images are stored in a 160xN*20 image, where N is the number of tiles
available to the game. This procedure copies the required tile picture from the
huge image and pastes it onto the paintbox}
  RectDest.Left:=(RelX-1)*20;
  RectDest.Top:=(RelY-1)*20;
  RectDest.Right:=RectDest.Left+20;
  RectDest.Bottom:=RectDest.Top+20;

  RectSrc.Left:=themenumber*20;
  RectSrc.Top:=Field[RelX,RelY]*20;
  RectSrc.Right:=RectSrc.Left+20;
  RectSrc.Bottom:=RectSrc.Top+20;

  Form1.PaintBox1.Canvas.Copyrect(RectDest, Form1.HugeImage.Picture.Bitmap.Canvas, RectSrc);

{The RelX and RelY parameters specify the tile position in the relative field coordinates. They
are turned into absolute for the purpose of drawing}
end;


procedure DrawEntireField;
var i,j:integer;
begin
for i:=1 to 20 do begin
   for j:=1 to 20 do begin
      DrawFieldItem(i,j);
   end;
end;
end;

{New game initialization routine}
procedure InitGame;
begin
  Form1.Options.Enabled:=false;
  GenerateField(Field, Diversity);
  Player1Selection:=Field[1,20];
  Player1Frame:=Player1Selection;
  Player2Selection:=Field[20,1];
  Player2Frame:=Player2Selection;
  Player1Territory.Initialize (Field,1,20);
  Player2Territory.Initialize (Field,20,1);
  PlayerActive:=1;
  Form1.Label2.Caption:='0%, +0%';
  Form1.Label3.Caption:='0%, +0%';
  Form1.Timer1.Enabled:=true;
  Form1.EndGame.Enabled:=true;
end;

{ TForm1 }

//This function checks if the config file is in XML (not in the old format).
//If the config file does not exist, it is considerd XML (sic!)
function IsXML(filename: string):boolean;
var
  tf: TextFile;
  s: string;
begin
  If not FileExists(filename) then IsXML:=true else begin
    AssignFile(tf, filename);
    Reset(tf);
    readln(tf,s);
    CloseFile(tf);
    if s='<?xml version="1.0"?>' then IsXML:=true else IsXML:=false;
  end;
end;

procedure TForm1.Form1Create(Sender: TObject);
begin
  Randomize;
  GetConfigDir;
  If not IsXML(ConfigDirAndFile) then DeleteFile(ConfigDirAndFile);
  Config:=TXMLConfig.Create(ConfigDirAndFile);
  LoadConfig;
  MaxThemeNumber:=Form1.ThemeSelect.Count-1;
end;

procedure TForm1.Form1Destroy(Sender: TObject);
begin
end;

procedure TForm1.Form1Close(Sender: TObject; var CloseAction: TCloseAction);
begin
  SaveConfig;
  Config.Flush;
  Config.Free;
end;

procedure TForm1.AboutClick(Sender: TObject);
begin
  Form2.Show;
end;

procedure TForm1.ArmenianMenuClick(Sender: TObject);
begin
{Load the Armenian language file}
  CurrentLanguage:=Form1.ArmenianMenu.MenuIndex;
  CurrentLanguageFileName:='armenian.lng';
  lfLoad(LangPath+CurrentLanguageFileName, LangFile);
  TranslateUI;
end;

procedure TForm1.BasqueMenuClick(Sender: TObject);
begin
{Load the German language file}
  CurrentLanguage:=Form1.BasqueMenu.MenuIndex;
  CurrentLanguageFileName:='basque.lng';
  lfLoad(LangPath+CurrentLanguageFileName, LangFile);
  TranslateUI;
end;


procedure TForm1.DivClick(Sender: TObject);
begin
  If      TComponent(Sender).Name='Div30' then Diversity:=30
  else if TComponent(Sender).Name='Div50' then Diversity:=50
  else if TComponent(Sender).Name='Div95' then Diversity:=95;
end;

procedure TForm1.DrawSelectionMarks(Sender: TObject);
var
   i,p: integer;
   s:string;
   RectSrc, RectDest: TRect;
begin
  if TSpeedButton(Sender).Tag=0 then begin
    //Prevent further repaint
    TSpeedButton(Sender).Tag:=1;
    //Find out who is calling
    s:=TSpeedButton(Sender).Name;
    //Is it player1 or player2?
//    p:=strtoint(s[3]);
    //Determine index by removing first four characters ('plX_') from sender's name
    Delete(s,1,4);
    i:=strtoint(s);
    //same for all buttons
    RectDest.Top:=0;
    RectDest.Left:=0;
    RectDest.Right:=RectDest.Left+20;
    RectDest.Bottom:=RectDest.Top+20;

    RectSrc.Left:=themenumber*20;
    RectSrc.Top:=i*20;
    RectSrc.Right:=RectSrc.Left+20;
    RectSrc.Bottom:=RectSrc.Top+20;

    TSpeedButton(Sender).Glyph.Canvas.Copyrect(RectDest, Form1.HugeImage.Picture.Bitmap.Canvas, RectSrc);
    TSpeedButton(Sender).Glyph.Canvas.Copyrect(RectDest, Form1.HugeImage.Picture.Bitmap.Canvas, RectSrc);
  end;
end;

procedure TForm1.EndGameClick(Sender: TObject);
begin
  If Application.Messagebox(pansichar(lfGetText(Langfile,'Sure?')),pansichar(lfGetText(LangFile,'End Game')),1) = 1 then EndTheGame(true);
end;

procedure TForm1.EnglishMenuClick(Sender: TObject);
begin
{English is default, so we don't need no language file}
CurrentLanguage:=Form1.EnglishMenu.MenuIndex;
CurrentLanguageFileName:='english.lng';
lfFree(LangFile);
TranslateUI;
end;

{Here we receive the input from the player and either move the selector if the
player hits the arrow keys or hurry the move if the player hits the spacebar or
return}
procedure TForm1.Form1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
Case PlayerActive of
1:begin
    Case Key of
      40:if not (player2selection=player1frame-1) then
                                                            begin
                                                              if not (player1frame=0) then dec(player1frame);
                                                              player1selection:=player1frame;
                                                            end{p2s<>p1s}
                                                           else
                                                            begin
                                                              if not (player1frame=0) then dec(player1frame);
                                                            end;{p2s=p1s}
      38:if not (player2selection=player1frame+1) then
                                                            begin
                                                              if not (player1frame=7) then inc(player1frame);
                                                              player1selection:=player1frame;
                                                            end{p2s<>p1s}
                                                           else
                                                            begin
                                                              if not (player1frame=7) then inc(player1frame);
                                                            end;{p2s=p1s}
      32,13:if player1frame=player1selection then  MakeMove;

    end;
  end;
  2:begin if not vsComputer then begin
        Case Key of
          38:if not (player1selection=player2frame-1) then
                                                                begin
                                                                  if not (player2frame=0) then dec(player2frame);
                                                                  player2selection:=player2frame;
                                                                  end{p2s<>p1s}
                                                               else
                                                                begin
                                                                  if not (player2frame=0) then dec(player2frame);
                                                                end;{p2s=p1s}
          40:if not (player1selection=player2frame+1) then
                                                                begin
                                                                  if not (player2frame=7) then inc(player2frame);
                                                                  player2selection:=player2frame;
                                                                end{p2s<>p1s}
                                                               else
                                                                begin
                                                                  if not (player2frame=7) then inc(player2frame);
                                                                end;{p2s=p1s}
          32,13:if player2frame=player2selection then MakeMove;

        end;
      end;
    end{not vsComputer}
  end;
  Form1.Paint;
end;


{The AI procedure}
Procedure ComputerThink;
type
  TChoice = record
    Count, Color: integer;
  end;
var
  Choices : array [0..6] of TChoice;
  i,i2,equal:integer;
  c:TChoice;
  done:boolean;
begin
{The AI, picks a color option and ponders over it, i.e. applies various criteria
- such as immediate annexion quotient or opponent obstacle quotient.
In future versions - a difficulty level system with more or less criteria
selection and elements of random thinking for lower levels}
  i:=0;
  for i2:=0 to 7 do begin
    if not (i2 = Player1Selection) then begin {exclude the Player1Selection option}
     FictiveTerritory.Points:=Player2Territory.Points;
     FictiveTerritory.Calculate(Field,i2);
     Choices[i].count:=FictiveTerritory.Count-Player2Territory.Count; {The substraction is performed for convenience only, it is not required, since we treat Player2Territory.Count as constant for the purposes of this procedure}
     Choices[i].color:=i2;
     inc(i);
    end;
  end;
{So, we have an array of eight integers, each integer denoting the size of territory }
{Now we have to sort the array and find out which option to choose}
  done:=false;

  while not done do begin
    done:=true;
    for i:=0 to 5 do begin
                       if Choices[i].count<Choices[i+1].count then begin
                                                         done:=false;
                                                         c:=Choices[i];
                                                         Choices[i]:=Choices[i+1];
                                                         Choices[i+1]:=c;
                                                       end;
                     end;
  end;
{The array is sorted, now we have to pick the random number out of the largest available, picking one single greatest number being a subset of this general operation}
  equal:=0;
  for i:=0 to 6 do if Choices[i].count=Choices[0].count then inc(equal);

{Final step: pick the selection!}
  Player2Selection:=Choices[random(equal)].color;
  MakeMove;
end;

Procedure MakeMove;
{Handles everything for a move - i.e. field management, active player switching, timer restart
Basically, when a timer event is up, the timer stops and calls this function. The function stops the timer again [if called from someplace else]
and restarts it when the move is done and everything is settled for the next thinking session. So, this function is called in three cases:
timer pops up, human player has decided, or computer player has decided}
var i:integer;
begin
  Form1.Timer1.Enabled:=false;
{Now, when we already have the player active and the player selection, we may
proceed with the field management routines. This procedure is where most of the game occurs}

//we sync playerXframe and playerXselection
player1Frame:=player1Selection;
player2Frame:=player2Selection;

{We change the territory's colour}
{We Calculate, thus adding annexed territory to the count}

  Case PlayerActive of
  1:begin
      for i:=0 to Player1Territory.Count-1 do Field[Player1Territory.Points[i].x,Player1Territory.Points[i].y]:=Player1Selection;
      Player1Territory.Calculate(Field, Field[Player1Territory.Points[0].x,Player1Territory.Points[0].y]);
      If not (Player1Territory.Count>=20*20 div 2) then begin
                                                         PlayerActive:=2;
                                                         if vsComputer then ComputerThink else Form1.Timer1.Enabled:=true;
                                                       end {no victory}
                                                       else begin
                                                         {Display a congratulations/loser/draw message}
                                                         Application.Messagebox(pansichar(lfGetText(LangFile,'Victory of Player 1')),pansichar(lfGetText(LangFile,'Victory')),1);
                                                         EndTheGame(false);
                                                       end;{victory or draw}
    end;
  2:begin
      for i:=0 to Player2Territory.Count-1 do Field[Player2Territory.Points[i].x,Player2Territory.Points[i].y]:=Player2Selection;
      Player2Territory.Calculate(Field, Field[Player2Territory.Points[0].x,Player2Territory.Points[0].y]);
      If not (Player2Territory.Count>=20*20 div 2) then begin
                                                         PlayerActive:=1;
                                                         Form1.Timer1.Enabled:=true;
                                                       end {no victory}
                                                       else begin
                                                         {Display a congratulations/loser/draw message}
                                                         Application.Messagebox(pansichar(lfGetText(LangFile,'Victory of Player 2')),pansichar(lfGetText(LangFile,'Victory')),1);
                                                         EndTheGame(false);
                                                       end;{victory or draw}

  end;
end;


{Update players' scores}
Form1.Label2.Caption:= floattostrf(player1territory.count/(20*20)*100,ffFixed,2,2) + '%, +' + floattostrf((player1territory.count-player1territory.pastcount)/(20*20)*100,ffFixed,2,2) + '%';
Form1.Label3.Caption:= floattostrf(player2territory.count/(20*20)*100,ffFixed,2,2) + '%, +' + floattostrf((player2territory.count-player2territory.pastcount)/(20*20)*100,ffFixed,2,2) + '%';

{On exit, we check if one of the players has won the game.
Then, if it was player2's round, we switch the player active, enable the timer and neatly exit.
If it was player1's round, we switch the player/exit if it is a vsPlayer game or call ComputerThink routine and exit anyway if it is a vsComputer game. ComputerThink will modify the selection and call MakeMove again}
end;

procedure DrawFrames;
begin
  if player1frame <> player2selection then begin
    Form1.Shape1.Pen.Style:=psSolid;
    Form1.Shape1.Pen.Width:=3;
  end
  else begin
    Form1.Shape1.Pen.Style:=psDash;
    Form1.Shape1.Pen.Width:=1;
  end;
  Form1.Shape1.Left:=TSpeedButton(Form1.FindComponent('pl1_'+inttostr(player1frame))).left-3;
  Form1.Shape1.Top:=TSpeedButton(Form1.FindComponent('pl1_'+inttostr(player1frame))).top-4;
  Form1.Shape1.Repaint;

  if player2frame <> player1selection then begin
    Form1.Shape2.Pen.Style:=psSolid;
    Form1.Shape2.Pen.Width:=3;
  end
  else begin
    Form1.Shape2.Pen.Style:=psDash;
    Form1.Shape2.Pen.Width:=1;
  end;
  Form1.Shape2.Left:=TSpeedButton(Form1.FindComponent('pl2_'+inttostr(player2frame))).left-3;
  Form1.Shape2.Top:=TSpeedButton(Form1.FindComponent('pl2_'+inttostr(player2frame))).top-4;
  Form1.Shape2.Repaint;
end;

procedure TForm1.Form1Paint(Sender: TObject);
begin
  TranslateUI;
  DrawEntireField;
  DrawFrames;
end;

procedure TForm1.GermanMenuClick(Sender: TObject);
begin
{Load the German language file}
  CurrentLanguage:=Form1.GermanMenu.MenuIndex;
  CurrentLanguageFileName:='german.lng';
  lfLoad(LangPath+CurrentLanguageFileName, LangFile);
  TranslateUI;
end;

procedure TForm1.LangMenuClick(Sender: TObject);
begin

end;

{Play versus computer}
procedure TForm1.NewGame1Click(Sender: TObject);
begin
  vsComputer:=true;
  InitGame;
  Form1.Label1.Tag:=Form1.Timer1.Interval div 1000;
  Form1.Label1.Caption:= lfGetText(LangFile, 'Time Left:')+' '+inttostr(Form1.Label1.Tag);
  Invalidate;
end;

{Play versus human}
procedure TForm1.NewGame2Click(Sender: TObject);
begin
  vsComputer:=false;
  InitGame;
  Form1.Label1.Tag:=Form1.Timer1.Interval div 1000;
  Form1.Label1.Caption:= lfGetText(LangFile, 'Time Left:')+' '+inttostr(Form1.Label1.Tag);
  Invalidate;
end;

procedure TForm1.Player1Click(Sender: TObject);
var
  i:integer;
  s:string;
begin
  If PlayerActive=1 then begin
    s:=TSpeedButton(Sender).Name;
    //Determine index by removing first four characters ('plX_') from sender's name
    Delete(s,1,4);
    i:=strtoint(s);
    player1frame:=i;
    if i <> player2selection then begin
      player1Selection:=i;
      MakeMove;
    end else DrawFrames;
  end;
end;

procedure TForm1.Player2Click(Sender: TObject);
var
  i:integer;
  s:string;
begin
  If (PlayerActive=2) and not vsComputer then begin
    s:=TSpeedButton(Sender).Name;
    //Determine index by removing first four characters ('plX_') from sender's name
    Delete(s,1,4);
    i:=strtoint(s);
    player2frame:=i;
    if i <> player1selection then begin
      player2Selection:=i;
      MakeMove;
    end else DrawFrames;
  end;
end;

procedure TForm1.PolishMenuClick(Sender: TObject);
begin
{Load the Polish language file}
  CurrentLanguage:=Form1.PolishMenu.MenuIndex;
  CurrentLanguageFileName:='polish.lng';
  lfLoad(LangPath+CurrentLanguageFileName, LangFile);
  TranslateUI;
end;

procedure TForm1.QuitClick(Sender: TObject);
begin
  Form1.Close;
end;

procedure TForm1.RussianMenuClick(Sender: TObject);
begin
{Load the Russian language file}
  CurrentLanguage:=Form1.RussianMenu.MenuIndex;
  CurrentLanguageFileName:='russian.lng';
  lfLoad(LangPath+CurrentLanguageFileName, LangFile);
  TranslateUI;
end;

procedure TForm1.Russian_cp1251MenuClick(Sender: TObject);
begin
{Load the Russian_cp1251 language file}
  CurrentLanguage:=Form1.Russian_cp1251Menu.MenuIndex;
  CurrentLanguageFileName:='russian_cp1251.lng';
  lfLoad(LangPath+CurrentLanguageFileName, LangFile);
  TranslateUI;
end;

procedure TForm1.Russian_UTF8MenuClick(Sender: TObject);
begin
{Load the Russian_cp1251 language file}
  CurrentLanguage:=Form1.Russian_UTF8Menu.MenuIndex;
  CurrentLanguageFileName:='russian_utf8.lng';
  lfLoad(LangPath+CurrentLanguageFileName, LangFile);
  TranslateUI;
end;

procedure TForm1.SpanishMenuClick(Sender: TObject);
begin
{Load the Spanish language file}
  CurrentLanguage:=Form1.SpanishMenu.MenuIndex;
  CurrentLanguageFileName:='spanish.lng';
  lfLoad(LangPath+CurrentLanguageFileName, LangFile);
  TranslateUI;
end;

procedure ScheduleRepaint;
var
  i:integer;
begin
  for i:=0 to 7 do begin
    TSpeedButton(Form1.FindComponent('pl1_'+inttostr(i))).Tag:=0;
    TSpeedButton(Form1.FindComponent('pl2_'+inttostr(i))).Tag:=0;
  end;
end;

procedure TForm1.ThemeClick(Sender: TObject);
begin
{Set the theme number according to the number of menu item that was clicked.
Since the menu captions are assigned by TranslateUI, the menu items don't have
to specify anything, they simply have to be there and specify this procedure
as their event handler}
  Themenumber:=TmenuItem(Sender).MenuIndex;
  DrawEntireField;
  ScheduleRepaint;
  Form1.Paint;
end;

procedure TForm1.TimeClick(Sender: TObject);
begin
  If      TComponent(Sender).Name='Time5' then Timer1.Interval:=5*1000
  else if TComponent(Sender).Name='Time10' then Timer1.Interval:=10*1000
  else if TComponent(Sender).Name='Time15' then Timer1.Interval:=15*1000;
end;

procedure TForm1.Timer1StartTimer(Sender: TObject);
begin
  Timer2.Enabled:=True;
end;

procedure TForm1.Timer1StopTimer(Sender: TObject);
begin
  Timer2.Enabled:=False;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Form1.Timer1.Enabled:=false;{just in case a major slowdown occurs and timer somehow manages to make another tick before MakeMove stops it again. Doesn't do much harm anyway}
  MakeMove;
end;

{The second timer is for the time counter. The whole thing could be
done with one timer, of course, but I failed to do so out of sheer laziness.
All blame goes to me here.}

procedure TForm1.Timer2StartTimer(Sender: TObject);
begin
  Form1.Label1.Tag:=Form1.Timer1.Interval div 1000;
  Form1.Label1.Caption:=lfGetText(LangFile, 'Time Left:')+' '+inttostr(Form1.Label1.Tag);
end;

procedure TForm1.Timer2Timer(Sender: TObject);
begin
  Form1.Label1.Tag:=Form1.Label1.Tag-1;
  Form1.Label1.Caption:=lfGetText(LangFile, 'Time Left:')+' '+inttostr(Form1.Label1.Tag);
end;

procedure TForm1.WMGetDlgCode(var msg: TLMNoParams);
begin
  Msg.Result := DLGC_WANTALLKEYS;
end;

procedure EndTheGame(WipeField:boolean);
var i,j:integer;
begin
  PlayerActive :=0;
  Form1.Timer1.Enabled:=false;
  Form1.Timer2.Enabled:=false;
  if WipeField then begin
    for i:=1 to 20 do for j:=1 to 20 do field[i,j]:=0;
    form1.label2.caption:='0%, +0%';
    form1.label3.caption:='0%, +0%';
    DrawEntireField;
  end;
  Form1.Options.Enabled:=true;
  Form1.EndGame.Enabled:=false;
end;

procedure TranslateUI;
var
  i:integer;
begin
  Form2.Caption:=lfGetText(LangFile,'About ColorSnatch');
  With Form1 do begin
{strings introduced in 1.0.0}
    Caption:=lfGetText(LangFile,'ColorSnatch');
    FileMenu.Caption:=lfGetText(LangFile,'Game');
    NewGame1.Caption:=lfGetText(LangFile,'Single Player Game');
    NewGame2.Caption:=lfGetText(LangFile,'Two Player Game');
    Quit.Caption:=lfGetText(LangFile,'Quit');
    Options.Caption:=lfGetText(LangFile,'Options');
    DivMenu.Caption:=lfGetText(LangFile,'Diversity');
    Div30.Caption:=lfGetText(LangFile,'Small');
    Div50.Caption:=lfGetText(LangFile,'Medium');
    Div95.Caption:=lfGetText(LangFile,'Great');
    TimeLimit.Caption:=lfGetText(LangFile,'Time Limit');
    Time5.Caption:='5 '+lfGetText(LangFile,'seconds');
    Time10.Caption:='10 '+lfGetText(LangFile,'seconds');
    Time15.Caption:='15 '+lfGetText(LangFile,'seconds');
    ThemeSelect.Caption:=lfGetText(LangFile,'Theme');
    for i:=0 to MaxThemeNumber do ThemeSelect.Items[i].Caption:=lfGetText(LangFile,'Theme')+' '+inttostr(i);
    LangMenu.Caption:=lfGetText(LangFile,'Language');
    HelpMenu.Caption:=lfGetText(LangFile,'Help');
    About.Caption:=lfGetText(LangFile,'About');
    If PlayerActive=0 then Label1.Caption:=lfGetText(LangFile,'Time Left:')+' 0';
{strings introduced in 1.0.1}
    EndGame.Caption:=lfGetText(LangFile,'End Game');
  end;
end;


initialization
  {$I unit1.lrs}

end.

