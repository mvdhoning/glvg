program ConvertFont;

{$APPTYPE CONSOLE}

uses
  SysUtils, Classes, VectorFont, Graphics;

var
  fsl: TStringList;
  path: ansistring;
  loop: integer;
  TTF2Vector:  TTTFToVectorConverter;

begin
  { TODO -oUser -cConsole Main : Insert code here }

    DecimalSeparator:='.'; //always use . as decimal seperator

  TTF2Vector := TTTFToVectorConverter.Create(nil);
  TTF2Vector.Font := TFont.Create();
  TTF2Vector.Font.Name := 'Times New Roman';
  //TTF2Vector.Font.Name := 'Euphorigenic-Regular';
  // Setup spline precision (1 min, 100 max)
  TTF2Vector.Precision := 1;


  fsl := TStringList.Create();
  fsl.Add(TTF2Vector.Font.Name);


  for loop := 0 to 255 do
  begin
    // Get glyphs' strokes per char
    if ( (loop >= ord('A')) and (loop <= ord('Z')) ) or ( (loop >= ord('a')) and (loop <= ord('z')) ) or ( (loop >= ord('0')) and (loop <= ord('9')) ) then
    begin
      //glyphs := TTF2Vector.GetCharacterGlyphs( loop );
      Path := TTF2Vector.GetCharacterPath( loop );
      fsl.Add(IntToStr(loop)+':'+Path);
    end;
  end;
  fsl.SaveToFile('font.txt');
  fsl.Free;

  TTF2Vector.Free;
end.
