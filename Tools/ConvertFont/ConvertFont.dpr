program ConvertFont;

//compatibility for FPC
{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

//for logs
{$APPTYPE CONSOLE}

uses
  SysUtils, Classes, VectorFont, Graphics;

var
  fsl: TStringList;
  path: ansistring;
  loop: integer;
  TTF2Vector:  TTTFToVectorConverter;

begin

  DecimalSeparator:='.'; //always use . as decimal seperator

  Writeln('Convert Font to Svg Paths');
  TTF2Vector := TTTFToVectorConverter.Create(nil);
  TTF2Vector.Font := TFont.Create();
  TTF2Vector.Font.Name := 'Times New Roman';

  writeln(TTF2Vector.Font.Name);
  //writeln(IntToStr(TTF2Vector.Font.Handle)); //font handle is depracted

  // Setup spline precision (1 min, 100 max)
  TTF2Vector.Precision := 1;

  Writeln('Make a list for glyph paths');
  fsl := TStringList.Create();
  fsl.Add(TTF2Vector.Font.Name);

  Writeln('Loop trough glyphs in font');
  for loop := 0 to 255 do
  begin
    // Get glyphs' strokes per char
    if ( (loop >= ord('A')) and (loop <= ord('Z')) ) or ( (loop >= ord('a')) and (loop <= ord('z')) ) or ( (loop >= ord('0')) and (loop <= ord('9')) ) then
    begin
      Writeln('About to extract path from glyph');
      Path := TTF2Vector.GetCharacterPath( loop );
      Writeln('Add path to list');
      fsl.Add(IntToStr(loop)+'='+Path);
    end;
  end;
  writeln('Save list with paths to file');
  fsl.SaveToFile('font.txt');

  fsl.Free;
  TTF2Vector.Free;

  readln;
end.
