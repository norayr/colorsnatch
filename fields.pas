unit fields;

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

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils; 

{The game field is divided into squares, each having a 'color', this is the array
used to represent it}
type TField = array[1..20, 1..20] of integer;

{An array holding the coordinates of all tiles owned by a player}
type TTerritoryArray = array of TPoint;

{A player's territory}
type TTerritory = object
  Points:TTerritoryArray;
  Count:integer;
  PastCount:integer;
  procedure Initialize(Field: TField; initX,initY:integer);
  procedure Calculate(Field: TField; color:integer);
end;


function RandOneOfThree(Weight0,Weight1,Weight2:integer):integer; {returns 0 or 1 or 2}
function GenerateTile(field: TField; which, x, y:integer):integer; {returns tile color}
procedure GenerateField (var Field: TField; diversity: integer);

implementation

{Return a random number, 0, 1 or 2, each number having a relative probability
value set by the function parameters}
function RandOneOfThree(Weight0,Weight1,Weight2:integer):integer; {returns 0 or 1 or 2}
var
  r: integer;
begin
  r:=random(Weight0+Weight1+Weight2);

  if (0<r) and (r<Weight0) then RandOneOfThree:=0;
  if (Weight0+1<r) and (r<Weight0+Weight1) then  RandOneOfThree:=1;
  if (Weight0+Weight1+1<r) and (r<Weight0+Weight1+Weight2) then RandOneOfThree:=2;
end;

{When generatiog a tile, we either pick a random number, or assign it the same
number as the upper tile or the left tile. This procedure chooses which scenario to follow}
function HeedWhichTile(UpperPresent, LeftPresent: boolean; divers:integer):integer; {0 - none, randomize; 1 - upper; 2 - left}
begin
If UpperPresent then begin
                        If LeftPresent then begin
                                               HeedWhichTile:=RandOneOfThree(Divers, (100-divers) div 2, (100-divers) div 2);
                                            end{Upper AND Left}
                                       else begin
                                               HeedWhichTile:=RandOneOfThree(Divers, (100-divers),0);
                                            end;{Upper AND NOT Left}
                     end {Upper}
                else
                     begin
                        If LeftPresent then begin
                                               HeedWhichTile:=RandOneOfThree(Divers, 0, (100-divers));
                                            end{NOT Upper AND Left}
                                       else begin
                                               HeedWhichTile:=0;
                                            end;{NOT Upper AND NOT Left}
                     end; {Not Upper}

end;


{Generate one tile}
function GenerateTile(Field: TField; which, x, y:integer):integer; {returns tile color}
begin
  case which of
    0:GenerateTile:= random(8); {random 0..7}
    1:GenerateTile:=Field[x,y-1]; {use upper}
    2:GenerateTile:=Field[x-1,y]; {use left}
    else GenerateTile:=0; {just in case}
  end;{case}
end;

{Generate entire field}
procedure GenerateField (var Field: TField; diversity: integer);
var
  i,j:integer;
begin
{Here we try to make up the field. It must be randomized, but also must consist of randomly-shaped
groups of same color. There must also be a diversity factor governing the size of such groups}

{We generate the field, the left and the upper tile influencing the selection}
{i for x axis, j for y axis}
  for i:=1 to 20 do begin
    for j:=1 to 20 do begin
      If (i=1) then begin
                       If (j=1) then Field[i,j]:=GenerateTile(Field,HeedWhichTile(false,false,diversity),i,j) else Field[i,j]:=GenerateTile(field, HeedWhichTile(true,false,diversity),i,j);
                    end{i=1}
               else begin
                       If (j=1) then Field[i,j]:=GenerateTile(Field,HeedWhichTile(false,true,diversity),i,j) else Field[i,j]:=GenerateTile(field, HeedWhichTile(true,true,diversity),i,j);
                    end;{i<>1}
    end;{j}
  end;{i}

{ensure that players have different colours at start}
  If Field[1,20]=Field[20,1] then if (field[1,20]<7) then field[1,20]:=7 else field[1,20]:=0;
end;


Procedure TTerritory.Initialize(Field: TField; initX,initY:integer);
begin
  setlength(Points,1);
  count:=0;
  Points[0].x:=initX;
  Points[0].y:=initY;
  Calculate(Field, Field[Points[0].x,Points[0].y]);
end;


{Count the number of tiles in the player's [potential] territory, i.e. the
number of same-coloured tiles starting from the player's corner}
Procedure TTerritory.Calculate(Field: TField; color:integer);
var
   b:boolean;
   i,j:integer;
{   proved_ok: TTerritoryArray;
   working_on: TTerritoryArray;}

{Checks if a tile subject to analysis is already in the Points array}
function IsInArray(x,y:integer):boolean; {inner procedure, be careful}
var
   i:integer;
   b:boolean;
begin
  b:=false;
  for i:=0 to length(Points)-1 do if (Points[i].x=x) and (Points[i].y=y) then b:=true;
  IsInArray:=b;
end;

{Add a tile to the Points array}
procedure AddToArray(x,y:integer); {inner procedure, be careful}
begin
  Setlength(Points,length(Points)+1);
  Points[length(Points)-1].x:=x;
  Points[length(Points)-1].y:=y;
end;

begin
{Here we go through the Points array again and again, trying and adding all
tiles adjacent to the tiles in the Points array. When no points were added
during an iteration, we consider we're done.}
b:=false;
while not b do begin
b:=true;
for i:=0 to length(Points)-1 do begin
  {try to add upper tile, if available}
   if not (Points[i].y=1) then begin
     if (not IsInArray(Points[i].x,Points[i].y-1)) and (Field[Points[i].x,Points[i].y-1]=Color) then begin
        b:=false;
        AddToArray(Points[i].x, Points[i].y-1);
     end;{if, not added yet}
   end;{if, tile exists}

  {try to add lower tile, if available}
   if not (Points[i].y=20) then begin
     if (not IsInArray(Points[i].x,Points[i].y+1)) and (Field[Points[i].x,Points[i].y+1]=Color) then begin
        b:=false;
        AddToArray(Points[i].x, Points[i].y+1);
     end;{if, not added yet}
   end;{if, tile exists}

  {try to add left tile, if available}
   if not (Points[i].x=1) then begin
     if (not IsInArray(Points[i].x-1,Points[i].y)) and (Field[Points[i].x-1,Points[i].y]=Color) then begin
        b:=false;
        AddToArray(Points[i].x-1, Points[i].y);
     end;{if, not added yet}
   end;{if, tile exists}

  {try to add right tile, if available}
   if not (Points[i].x=20) then begin
     if (not IsInArray(Points[i].x+1,Points[i].y)) and (Field[Points[i].x+1,Points[i].y]=Color) then begin
        b:=false;
        AddToArray(Points[i].x+1, Points[i].y);
     end;{if, not added yet}
   end;{if, tile exists}

end;{for}

end;{while}

//Here we optionally conquer surrounded tiles.
{if surround then for i:=1 to 20 do for j:=1 to 20 do begin



end;}{for}

pastcount:=count;
count:=length(points);
end;


end.

