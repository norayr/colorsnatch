unit langfiles;

{
    LangFiles, internationalization unit for ColorSnatch game.
    http://colorsnatch.sourceforge.net/
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


{Used to store key/value pairs from the localization file}
type
  TKeyValue = record
    key:   string;
    value: string;
  end;

{Array of key/value pairs in which we store the entire language file and search through it.}
type
  TLangFile = array of TKeyValue;

{Loads a file into a TLangFile array}
procedure lfLoad(filename: TFileName; var LangFile: TLangFile);

{Returns a translated key string or the key string itself if no translation was found.
Usage example:
lfGetText('Hello world!') will return 'Hello world!' if langfile has no
translation for the string or if the file is empty; it will return the translated
string if it was found}
function lfGetText(LangFile:TLangfile; key: string):string;

{Empties the Language File, simply by setting its length to zero.
If the file is empty, lfGetText's output will mirror its input}
procedure lfFree(var LangFile: TLangFile);

implementation


procedure lfLoad(filename: TFileName; var LangFile: TLangFile);
var
  f:TextFile;
  s:string;
  keyread:boolean;
begin
  If FileExists (filename) then begin
    AssignFile(f,filename);
    Reset(f);
    keyread:=false;
    while not eof(f) do begin
      readln(f,s);
      if (not (length(s)=0)) and (not (s[1]='#')) and (not (s[1]=' ')) then
        begin
          if not keyread then begin
            setlength(LangFile, length(LangFile)+1);
            LangFile[length(LangFile)-1].key:=s;
            keyread:=true;
          end
          else begin
            LangFile[length(LangFile)-1].value:=s;
            keyread:=false;
          end;
        end;
    end;
    CloseFile(f);
  end
  else lfFree(LangFile);
end;

procedure lfFree(var LangFile: TLangFile);
begin
setlength(LangFile,0);
end;

function lfGetText(LangFile:TLangfile; key: string):string;
var
  i: integer;
  s: string;
begin
  s:=key;
  for i:=0 to length(LangFile)-1 do if LangFile[i].key = key then s:=LangFile[i].value;
  lfGetText:=s;
end;

end.

