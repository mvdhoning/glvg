unit glvg;

(* Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is the glvg main unit.
 *
 * The Initial Developer of the Original Code is
 * M van der Honing.
 * Portions created by the Initial Developer are Copyright (C) 2002-2004
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 *  M van der Honing
 *
 *)

interface

uses DGLOpenGL, classes;

type
TPoint = packed record
  x: single;
  y: single;
  z: single;
  r: single;
  g: single;
  b: single;
  a: single;
end;

TContour= array of TPoint;

//TODO: use TPath inside svg group?
//TODO: implement basic svg shapes using paths.
//http://www.w3.org/TR/SVG11/paths.html

TPath = class
private
//  FCurrentCommand: char;
//  FCurrentPoint: TPoint;
  FCommandText: string;
  FCount: integer;
  FPoints: array of TPoint;
  FSplinePrecision: integer;
  procedure NewStroke( AFrom, ATo: TPoint );
  function EqualPoints( APoint1, APoint2: TPoint ): boolean;
  procedure DrawCSpline( AFrom, ATo, AFromControlPoint, AToControlPoint: TPoint );
  procedure DrawQSpline( AFrom, ATo, AControlPoint: TPoint );
  procedure AddPoint(AValue: TPoint);
  procedure SetPoint(I: integer; AValue: TPoint);
  function GetPoint(I: integer): TPoint;
public
  constructor Create();
  destructor Destroy(); override;
  procedure Parse();
  property Points[I: integer]: TPoint read GetPoint write SetPoint;
  property Text: string read fcommandtext write fcommandtext;
  property Count: integer read FCount;
end;

TPolygon = class(TComponent)
private
  FOutline: boolean;
  FcPath: TPath;
  FPoints: array of TPoint; //polygon point
  FVertex: array of TPoint; //triangulated data
//  FContour: array of TPoint; //outline
  FContour : array of TContour;
  FContourCount: array of integer;
//FExtrudePath: array of TPoint; //extruding path  //TODO
//  FExtrudePathCount: integer;                      //TODO
  FExtrudeDepth: single;
  F3DVertex: array of TPoint; //3d extruded mesh
  F3DVertexCount: integer;
  FColor: TPoint;
  FLineColor: TPoint;
  FCount: integer;
  FVertexCount: integer;
  FTesselated: boolean;

  FGradColorAngle: single;
  FGradColorPoint1: TPoint; //moet eigenlijk dynamic array zijn
  FGradColorPoint2: TPoint; //moet eigenlijk dynamic array zijn
  //FGradColorBar: array of TPoint;

  FNewContour : integer;

  FBoundBoxMinPoint: TPoint;
  FBoundBoxMaxPoint: TPoint;

  FLineWidth: single;

  procedure SetPoint(I: integer; Value: TPoint);
  procedure AddVertex(x: single; y: single; z: single; r: single; g: single; b: single; a:single);
  function GetPoint(I: integer): TPoint;
  function GetCount(): integer;
  procedure tessBegin(which: GLenum);
  procedure tessEnd();
  procedure tessVertex(x: single; y: single; z: single; r: single; g: single; b: single; a:single);
  function GetPathText: string;
  procedure SetPathText(AValue: string);
public
  constructor Create(AOwner: TComponent); reintroduce; overload;
  destructor Destroy(); reintroduce; overload;
  procedure SetColor(R: single; G: single; B: single;A: single);
  procedure Add(X: single; Y: single); overload;
  procedure Add(X: single; Y: single; Z: single); overload;
  procedure Add(X: single; Y: single; Z: single; R: single; G: single; B: single; A: single); overload;
  procedure Render();
//  procedure RenderOutline();
  procedure RenderPath();
  procedure Tesselate();
  procedure Extrude();
  procedure RenderExtruded();
  procedure CalculateBoundBox();
  procedure ApplyGradFill();
  property Path: string read GetPathText write SetPathText;
  property Points[I: integer]: TPoint read GetPoint write SetPoint;
  property Count: integer read GetCount;
  property ExtrudeDepth: single read FExtrudeDepth write FExtrudeDepth;
  property GradColorAngle: single read FGradColorAngle write FGradColorAngle;
  property GradColorPoint1: TPoint read FGradColorPoint1 write FGradColorPoint1;
  property GradColorPoint2: TPoint read FGradColorPoint2 write FGradColorPoint2;
  property LineWidth: single read FLineWidth  write FLineWidth;
  procedure SetLineColor(R: single; G: single; B: single;A: single);
end;

TPolygonFont = class
     private
        FCharGlyph: array[0..255] of TPolygon;
        FCharWidth: array[0..255] of integer;
        FName: string;
        //FScale: single;
     public
        procedure LoadFromFile(AValue: string);
        procedure RenderChar(AValue: char);
        procedure RenderString(AValue: string);
        property Name: string read FName write FName;
        //property Scale: single read FScale write FScale;
     end;

implementation

uses math, sysutils;

type
     TGLArrayd6 = array[0..5] of GLDouble;
     PGLArrayd6 = ^TGLArrayd6;
     TGLArrayvertex4 = array[0..3] of PGLArrayd6;
     PGLArrayvertex4 = ^TGLArrayvertex4;
     PGLArrayf4 = ^TGLArrayf4;

threadvar
  PolygonClass: TPolygon;

//Color gradient temp hack

const
 TRIG_FUNCTABLE_SIZE: integer =	1024;
 TRIG_FUNCTABLE_MASK: integer =	1023;

var
  glTriangleTable: array[0..1023] of single;		//special table in ranges 0..1

procedure init(); //prepare trig table...
var
  i: integer;
begin
   for i := 0 to TRIG_FUNCTABLE_SIZE-1 do
   begin
    		if ( i < TRIG_FUNCTABLE_SIZE / 2 ) then
    		begin
    			glTriangleTable[i] := i / ( TRIG_FUNCTABLE_SIZE / 2 );
    		end
    		else
   		begin
    			glTriangleTable[i] := 1.0 - glTriangleTable[i - TRIG_FUNCTABLE_SIZE div 2];
    		end;
   end;
end;

function TrigGLTriangle(value: single): single;
var
  temp: integer;
begin
    temp := ROund(value * ( TRIG_FUNCTABLE_SIZE / 360 ) );
  	result:= glTriangleTable[ temp    ];
end;

function CalcGradColor(xpos: single; ypos: single; gradbegincolor: TPoint; gradendcolor: TPoint;gradx1: single; grady1: single; gradx2: single; grady2: single; gradangle: single): TPoint;
var
  HeightDistance: single;
  WidthDistance: single;
  CurPos: single;
  CurPosH: single;
  CurPosW: single;
begin
 CurPos := 0.0;
    GradAngle := GradAngle * 2.0; //the gltriangle size is 2PI
    HeightDistance:= GradY2 - GradY1; //absolute?
    WidthDistance:= GradX2 - GradX1; //absolute?
    CurPosH := (ypos - GradY1) / HeightDistance;
    CurPosW := (xpos - GradX1) / WidthDistance;
    if (gradangle >=0) and (gradangle < 180) then
      CurPos := CurPosH * TrigGLTriangle( gradangle + 180) + CurPosW * TrigGLTriangle(gradangle)
    else
    if (gradangle >=180) and (gradangle < 360) then
      CurPos := (1.0 - CurPosH) * TrigGLTriangle( gradangle + 180) + CurPosW * TrigGLTriangle(gradangle)
    else
    if (gradangle >=360) and (gradangle < 540) then
      CurPos := (1.0-CurPosH) * TrigGLTriangle( gradangle + 180) + (1.0-CurPosW) * TrigGLTriangle(gradangle)
    else
    if (gradangle >=540) then
      CurPos := CurPosH * TrigGLTriangle( gradangle + 180) + (1.0-CurPosW) * TrigGLTriangle(gradangle);

  result.R:=gradbeginColor.R *  (1.0 - CurPos) + GradEndColor.R * CurPos;
  result.G:=gradbeginColor.G *  (1.0 - CurPos) + GradEndColor.G * CurPos;
  result.B:=gradbeginColor.B *  (1.0 - CurPos) + GradEndColor.B * CurPos;

end;

function CalcGradAlpha(xpos: single; ypos: single; gradbeginalpha: single; gradendalpha: single;gradx1: single; grady1: single; gradx2: single; grady2: single; gradangle: single): single;
var
  HeightDistance: single;
  WidthDistance: single;
  CurPos: single;
  CurPosH: single;
  CurPosW: single;
begin
CurPos:=0.0;
    GradAngle := GradAngle * 2.0; //the gltriangle size is 2PI
    HeightDistance:= GradY2 - GradY1; //absolute?
    WidthDistance:= GradX2 - GradX1; //absolute?
    CurPosH := (ypos - GradY1) / HeightDistance;
    CurPosW := (xpos - GradX1) / WidthDistance;
    if (gradangle >=0) and (gradangle < 180) then
      CurPos := CurPosH * TrigGLTriangle( gradangle + 180) + CurPosW * TrigGLTriangle(gradangle)
    else
    if (gradangle >=180) and (gradangle < 360) then
      CurPos := (1.0 - CurPosH) * TrigGLTriangle( gradangle + 180) + CurPosW * TrigGLTriangle(gradangle)
    else
    if (gradangle >=360) and (gradangle < 540) then
      CurPos := (1.0-CurPosH) * TrigGLTriangle( gradangle + 180) + (1.0-CurPosW) * TrigGLTriangle(gradangle)
    else
    if (gradangle >=540) then
      CurPos := CurPosH * TrigGLTriangle( gradangle + 180) + (1.0-CurPosW) * TrigGLTriangle(gradangle);

  result:=gradbeginAlpha *  (1.0 - CurPos) + GradEndAlpha * CurPos;
end;

//End Color gradient temp hack


//TPath

//http://www.w3.org/TR/2008/WD-SVGMobile12-20080915/paths.html#PathData

procedure TPath.NewStroke( AFrom, ATo: TPoint );
begin
  AddPoint(AFrom);
  AddPoint(ATo);
end;

function TPath.EqualPoints( APoint1, APoint2: TPoint ): boolean;
begin
  Result := (APoint1.X = APoint2.X) and (APoint1.Y = APoint2.Y);
end;

//http://en.wikipedia.org/wiki/B%C3%A9zier_curve

//TODO: Parameters hernoemen
//cubic bezier line ( (1-i)^3*pa+3*i(1-i)^2*pb+3*i^2*(1-i)*pc+i^3*pd  )
procedure TPath.DrawCSpline( AFrom, ATo, AFromControlPoint, AToControlPoint: TPoint );
var
  di, i : Double;
  p1, p2: TPoint;
begin
  //as quadratic with additional points?

  //quadratic degree n =2 ?

  //cubic degree n = 3

//  http://ibiblio.org/e-notes/Splines/Intro.htm
//generic bezier spline N control points. ? (http://ibiblio.org/e-notes/Splines/Bezier.htm)
//  for (j = N-1; j > 0; j--) //control points
//    for (i = 0; i < j; i++){ //i=abcd
//     Px[i] = (1-t)*Px[i] + t*Px[i+1];
//     Py[i] = (1-t)*Py[i] + t*Py[i+1];
//    }

//OK dit is de manier om uit te werken!!! zie url
//http://www.paultondeur.com/2008/03/09/drawing-a-cubic-bezier-curve-using-actionscript-3/
// posx = Math.pow(u,3)*(anchor2.x+3*(control1.x-control2.x)-anchor1.x)
//           +3*Math.pow(u,2)*(anchor1.x-2*control1.x+control2.x)
//           +3*u*(control1.x-anchor1.x)+anchor1.x;

//pa = control1;
//pb = control2;
//pc = anchor1;  x1,y1
//pd = anchor2;  x2,y2

    di := 1.0 / FSplinePrecision;
    i := di;
    p2 := AFrom;
    while i <=1.0 do
    begin
      if i-di/2 > 1.0-di then
        i := 1.0;
      p1 := p2;
      p2.x := power(i,3)*(ATo.x+3*(AFromControlPoint.x-AToControlPoint.x)-AFrom.x)
              + 3* power(i,2)*(AFrom.x-2*AFromControlPoint.x+AToControlPoint.x)
              + 3* i*(AFromControlPoint.x-AFrom.x)+AFrom.x;
      p2.y := power(i,3)*(ATo.y+3*(AFromControlPoint.y-AToControlPoint.y)-AFrom.y)
              + 3* power(i,2)*(AFrom.y-2*AFromControlPoint.y+AToControlPoint.y)
              + 3* i*(AFromControlPoint.y-AFrom.y)+AFrom.y;
      if not EqualPoints( p1, p2 ) then
        NewStroke( p1, p2 );  //line
      i := i + di;
    end;

    NewStroke( p2, ATo);

    //TODO: werkt moet alleen nog params hernoemen voor leesbaarheid
end;

                                                    (*
//quadratic bezier line ( (1-i)^2*pa+2*i(1-i)*pb+i^2*pc )
procedure TPath.DrawQSpline( AFrom, AControlPoint, A: TPoint );
  var di, i: double;
      p1,p2: TPoint;
  begin
   // AddPoint(AFrom);

    di := 1.0 / FSplinePrecision;
    i := di;
    p2 := AFrom;
    while i<=1.0 do
    begin
      if i-di/2 > 1.0-di then
        i := 1.0;
      p1 := p2;
      //p2.x := power(1-i,2)*AFrom.x+2*i*(1-i)*ATo.x+power(i,2)*AControlPoint.x;
      //p2.y := power(1-i,2)*AFrom.y+2*i*(1-i)*ATo.y+power(i,2)*AControlPoint.y;
      p2.X := (AFrom.X-2*ATo.X+AControlPoint.X)*sqr(i) + (2*ATo.X-2*AFrom.X)*i + AFrom.X;
      p2.Y := (AFrom.Y-2*ATo.Y+AControlPoint.Y)*sqr(i) + (2*ATo.Y-2*AFrom.Y)*i + AFrom.Y;
      if not EqualPoints( p1, p2 ) then
        NewStroke( p1, p2 );  //line
      i := i + di;
    end;
    //pc := p2; ?

    NewStroke( p2, ATo);
  end;
     *)
//quadratic bezier line ( (1-i)^2*pa+2*i(1-i)*pb+i^2*pc )
procedure TPath.DrawQSpline( AFrom, ATo, AControlPoint: TPoint );
  var di, i: double;
      p1,p2: TPoint;
  begin
    di := 1.0 / FSplinePrecision;
    i := di;
    p2 := AFrom;
    while i<=1.0 do
    begin
      if i-di/2 > 1.0-di then
        i := 1.0;
      p1 := p2;
      p2.X := (AFrom.X-2*AControlPoint.X+ATo.X)*sqr(i) + (2*AControlPoint.X-2*AFrom.X)*i + AFrom.X;
      p2.Y := (AFrom.Y-2*AControlPoint.Y+ATo.Y)*sqr(i) + (2*AControlPoint.Y-2*AFrom.Y)*i + AFrom.Y;
      if not EqualPoints( p1, p2 ) then
        NewStroke( p1, p2 );  //line
      i := i + di;
    end;
    //pc := p2; ?

    NewStroke( p2, ATo);
  end;


procedure TPath.AddPoint(AValue: TPoint);
begin
  FCount := FCount + 1;
  SetLength(FPoints, FCount);
  FPoints[FCount-1].X := AValue.X;
  FPoints[FCount-1].Y := AValue.Y;
  FPoints[FCount-1].Z := AValue.Z;
end;

procedure TPath.SetPoint(I: integer; AValue: TPoint);
begin
  FPoints[I] := AValue;
end;

function TPath.GetPoint(I: integer): TPoint;
begin
  result := FPoints[I];
end;

constructor TPath.Create();
begin
  FCount:= 0;
  FSplinePrecision := 25; //
end;

destructor  TPath.Destroy();
begin
 inherited Destroy;
end;

procedure TPath.Parse();
var
  MyParser: TParser; //moet hier eigenlijk wat documentatie over verzamelen!!!!
  MS: TMemoryStream;
  str: string;
  CurToken: char;
  CurCommand: char;
  PrevCommand: char;
  Params: array[0..7] of single;
  ParamsPoint: array[0..2] of TPoint;
  ParamCount: byte;
  CurPoint: TPoint;
  PrevControlPoint: TPoint;
  FirstPoint: TPoint;

begin
  paramcount := 0;
  CurCommand := '-';

  MS := TMemoryStream.Create;
  MS.Position := 0;
  MS.Write(FCommandText[1], Length(FCommandText));
  MS.Position := 0;
  MyParser := TParser.Create(MS);
  //MyStr := MyParser.TokenString;
  //ShowMessage(MyStr);

  prevcommand := '-';
//  prevtoken := ' ';
  curtoken := ' ';
  while curtoken <> toEOF do
  begin
    //MyParser.NextToken; //

    //Get Token
    str := MyParser.TokenString();


    //PrevToken:= CurToken;
    //Get the position in the stream
//    Pos := MyParser.SourcePos();
    //Get the line number
//    Line := MyParser.SourceLine;
    //Get token type
    case(MyParser.Token) of
      toSymbol:
      begin
        if length(str) = 1 then
        begin
          MyParser.NextToken;
          str := str+MyParser.TokenString;

        end;

        curCommand := str[1]; //Huidig commando is eerste teken string;
        Delete(str,1,1); //verwijder commando uit string
        paramcount:=1;
        if str <> '' then
        begin
          params[paramcount-1]:=StrToFloat(str);
        end;
        //ShowMessage(str+' is a symbol at line : '+IntToStr(Line)+'   position : '+IntToStr(Pos)+ '  curenttoken: '+prevtoken );
        //ShowMessage(curCommand);
      end;
      toInteger:
      begin
        //ShowMessage(str+' is an integer at line : '+IntToStr(Line)+' position : '+IntToStr(Pos)+ '  curenttoken: '+prevtoken );
        params[paramcount]:=StrToFloat(str);
        paramcount := paramcount +1;
      end;
      toFloat:
      begin
        //ShowMessage(str+' is a float at line : '+IntToStr(Line)+' position : '+IntToStr(Pos)+ '  curenttoken: '+prevtoken );
        params[paramcount]:=StrToFloat(str);
        paramcount := paramcount +1;
      end;
      toString:
      //note: TParser is designed for DFM's so that toString only works with
      //'single quoted' strings
        //ShowMessage(str+' is a string at line : '+IntToStr(Line)+' position : '+IntToStr(Pos)+ '  curenttoken: '+prevtoken );
    //else
    //  PrevToken:=CurToken; //
    end;

    //How to detect if i have enough data?
    Case CurCommand of
      'M':
      Begin
        if paramcount = 2 then
        begin
          CurPoint.x:=params[0];
          CurPoint.y:=params[1];
          paramcount := 0;
          FirstPoint := CurPoint;
//        AddPoint(CurPoint);
        end;
      End;
      'L':
      Begin
        if paramcount = 2 then
        begin
          ParamsPoint[0].x := params[0];
          ParamsPoint[0].y := params[1];
          NewStroke( CurPoint, ParamsPoint[0]);
          paramcount :=0;
          CurPoint := ParamsPoint[0];
        end;
      End;
      'z':
      Begin
        //lijn terug naar eerste punt
        NewStroke( CurPoint, FirstPoint);
        FirstPoint:=CurPoint; //optioneel?
      End;
      'Q':
      Begin
        if paramcount = 4 then
        begin

          ParamsPoint[0].x := params[0];
          ParamsPoint[0].y := params[1];
          ParamsPoint[1].x := params[2];
          ParamsPoint[1].y := params[3];
          DrawQSpline(CurPoint, ParamsPoint[1], ParamsPoint[0]);
          paramcount := 0;

        (*  if prevcommand = curcommand then
          begin
            DrawQSpline(ParamsPoint[1], CurPoint, CurPoint);
            DrawQSpline(CurPoint, ParamsPoint[1], ParamsPoint[0]);
          end
          else
          begin
            DrawQSpline(CurPoint, ParamsPoint[1], ParamsPoint[0]);
          end; *)


          PrevControlPoint := ParamsPoint[0];
          CurPoint := ParamsPoint[1];
        end;
      End;
      'T':
      Begin
        if paramcount = 2 then
        begin
          ParamsPoint[0].x:=CurPoint.x+CurPoint.x-PrevControlPoint.x;
          ParamsPoint[0].y:=CurPoint.y+CurPoint.y-PrevControlPoint.y;
          ParamsPoint[1].x := params[0];
          ParamsPoint[1].y := params[1];
          DrawQSpline(CurPoint, ParamsPoint[1], ParamsPoint[0]);
          paramcount:=0;
          PrevControlPoint := ParamsPoint[0];
          CurPoint := ParamsPoint[1];
        end;
      End;
      'C':
      Begin
        if paramcount = 6 then
        Begin
          ParamsPoint[0].x:=params[0];
          ParamsPoint[0].y:=params[1];
          ParamsPoint[1].x:=params[2];
          ParamsPoint[1].y:=params[3];
          ParamsPoint[2].x:=params[4];
          ParamsPoint[2].y:=params[5];
          DrawCSpline( CurPoint, ParamsPoint[2], ParamsPoint[0], ParamsPoint[1]);
          paramcount := 0; //prevent drawing again
          CurPoint:=ParamsPoint[2];
          PrevControlPoint := ParamsPoint[1];
        End;
      End;
      'S':
      Begin
        if paramcount = 4 then
        Begin
          if prevcommand = ' ' then
          begin
            ParamsPoint[0].x:=params[0];
            ParamsPoint[0].y:=params[1];
          end
          else
          begin
            //mirrored 2nd ctrlpoint
            ParamsPoint[0].x:=CurPoint.x+CurPoint.x-PrevControlPoint.x;
            ParamsPoint[0].y:=CurPoint.y+CurPoint.y-PrevControlPoint.y;
          end;
          ParamsPoint[1].x:=params[0];
          ParamsPoint[1].y:=params[1];
          ParamsPoint[2].x:=params[2];
          ParamsPoint[2].y:=params[3];
          DrawCSpline( CurPoint, ParamsPoint[2], ParamsPoint[0], ParamsPoint[1]);
          paramcount := 0; //prevent drawing again
          CurPoint:=ParamsPoint[2];
          PrevControlPoint := ParamsPoint[1];
        End;
      End;
    end;

    PrevCommand:=CurCommand;
//    PrevToken:=CurToken; //save the previous token to detect ,
    curtoken := MyParser.NextToken;



  //parse string (remove linebreaks etc

  //detect command: (Uppercase is absolute coords vs Lowercase relative coords)

  // Move To (M m)

  // Close Path  (Z z)

  // Line To (L l H h V v)

  // Curves

  // Cubic Bezier (C c S s)

  // Quadratic Bezier (Q q T t)

  //values
  end;
end;

//TPolygon

  function TPolygon.GetPathText: string;
  begin
    result := FcPath.Text;
  end;

  procedure TPolygon.SetPathText(AValue: string);
  var
    i: integer;
  begin
    FcPath.Text := AValue;
    if FcPath.Text <> '' then
    begin
      FcPath.Parse;
      for i := 0 to FcPath.Count-1 do
      begin
        self.Add(FcPath.Points[i].x, FcPath.Points[i].y);
      end;
    end;
  end;

  procedure TPolygon.RenderPath;
  var
    loop: integer;
  begin
    glcolor3f(FLineColor.R,FLineColor.G,FLineColor.B);
    glLineWidth(FLineWidth);

    //Draw Path
    glBegin(GL_LINES);
    for loop:=0 to fcpath.Count-1 do
    begin
      glVertex2f(fcpath.Points[loop].x, fcpath.Points[loop].y);
    end;
    glEnd();
  end;

procedure TPolygon.SetColor(R: single; G: single; B: single;A: single);
begin
  FColor.r := R;
  FColor.g := G;
  FColor.b := B;
  FColor.a := A;
end;

procedure TPolygon.SetLineColor(R: single; G: single; B: single;A: single);
begin
  FLineColor.r := R;
  FLineColor.g := G;
  FLineColor.b := B;
  FLineColor.a := A;
end;


procedure TPolygon.tessBegin(which: GLenum);
begin
//    glBegin(which);

    //add new outline
    FNewContour := FNewContour +1;
end;

procedure TPolygon.tessEnd();
begin
//    glEnd();
end;

procedure TPolygon.tessVertex(x: single; y: single; z: single; r: single; g: single; b: single; a:single);
begin
    glcolor3f(r,g,b);
    glVertex3f(x,y,z);
end;


procedure TPolygon.AddVertex(x: single; y: single; z: single; r: single; g: single; b: single; a:single);
begin
    if (FOutline) then
    begin

//      if (FNewContour = 1) then
//      begin

      SetLength(FContourCount, FNewContour);
      SetLength(FContour, FNewContour);

      FContourCount[FNewContour-1] := FContourCount[FNewContour-1] + 1;

      SetLength(FContour[FNewContour-1], FContourCount[FNewContour-1]);



      FContour[FNewContour-1][FContourCount[FNewContour-1]-1].R := R;
      FContour[FNewContour-1][FContourCount[FNewContour-1]-1].G := G;
      FContour[FNewContour-1][FContourCount[FNewContour-1]-1].B := B;

      FContour[FNewContour-1][FContourCount[FNewContour-1]-1].X := X;
      FContour[FNewContour-1][FContourCount[FNewContour-1]-1].Y := Y;
      FContour[FNewContour-1][FContourCount[FNewContour-1]-1].Z := Z;
//      end;

    end
    else
    begin
      FVertexCount := FVertexCount + 1;
      SetLength(FVertex, FVertexCount);

      FVertex[FVertexCount-1].R := R;
      FVertex[FVertexCount-1].G := G;
      FVertex[FVertexCount-1].B := B;

      FVertex[FVertexCount-1].X := X;
      FVertex[FVertexCount-1].Y := Y;
      FVertex[FVertexCount-1].Z := Z;
    end;
end;

constructor TPolygon.Create(AOwner: TComponent);
begin



  Init; //Grad Color Hack

  Inherited Create(AOwner);

  FcPath := TPath.Create;
  FcPath.Text:='';
  FCount := 0;
  FVertexCount := 0;
  FTesselated := false;
  FColor.R := 0.0;
  FColor.G := 0.0;
  FColor.B := 0.0;
  FColor.A := 0.0;
//  FOutline := false;
  FExtrudeDepth := 1.0;
  FNewContour := 0;

  FGradColorAngle := 1; //1..89
  FGradColorPoint1.x:=0.0; //min boundbox x
  FGradColorPoint1.y:=0.0; //min boundbox y
  FGradColorPoint1.r:=0.0;
  FGradColorPoint1.g:=1.0;
  FGradColorPoint1.b:=0.0;

  //point must make a square (e.g. bounding box of polygon)

  FGradColorPoint2.x:=1.0; //max boundbox x;
  FGradColorPoint2.y:=1.0; //max boundbox y;
  FGradColorPoint2.r:=1.0;
  FGradColorPoint2.g:=0.0;
  FGradColorPoint2.b:=0.0;

end;

destructor TPolygon.Destroy();
begin
  FcPath.Free;
  FTesselated := false;
  FCount := 0;
  FVertexCount := 0;
  SetLength(FPoints, FCount);
  SetLength(FVertex, FVertexCount);
  inherited Destroy;
end;

procedure TPolygon.SetPoint(I: integer; Value: TPoint);
begin
  FTesselated := false; //check first on changed values
  FPoints[I] := Value;
end;

function TPolygon.GetPoint(I: integer): TPoint;
begin
  result := FPoints[I];
end;

function TPolygon.GetCount(): integer;
begin
  result := FCount;
end;

procedure TPolygon.Add(X: single; Y: single);
var
  CurColor: TPoint;
begin
  FTesselated := false;
  FCount := FCount + 1;
  SetLength(FPoints, FCount);
  FPoints[FCount-1].X := X;
  FPoints[FCount-1].Y := Y;
  FPoints[FCount-1].Z := 0.0;

  CurColor:=FColor;
  //CurColor:=CalcGradColor(X, Y, FGradColorPoint1, FGradColorPoint2, FGradColorPoint1.x, FGradColorPoint1.y, FGradColorPoint2.x, FGradColorPoint2.y, FGradColorAngle);

  FPoints[FCount-1].R := CurColor.R;
  FPoints[FCount-1].G := CurColor.G;
  FPoints[FCount-1].B := CurColor.B;
  FPoints[FCount-1].A := CurColor.A;
end;

procedure TPolygon.Add(X: single; Y: single; Z: single);
begin
  FTesselated := false;
  FCount := FCount + 1;
  SetLength(FPoints, FCount);
  FPoints[FCount-1].X := X;
  FPoints[FCount-1].Y := Y;
  FPoints[FCount-1].Z := Z;
  FPoints[FCount-1].R := FColor.R;
  FPoints[FCount-1].G := FColor.G;
  FPoints[FCount-1].B := FColor.B;
  FPoints[FCount-1].A := FColor.A;
end;

procedure TPolygon.Add(X: single; Y: single; Z: single; R: single; G: single; B: single; A: single);
begin
  FTesselated := false;
  FCount := FCount + 1;
  SetLength(FPoints, FCount);
  FPoints[FCount-1].X := X;
  FPoints[FCount-1].Y := Y;
  FPoints[FCount-1].Z := Z;
  FPoints[FCount-1].R := R;
  FPoints[FCount-1].G := G;
  FPoints[FCount-1].B := B;
  FPoints[FCount-1].A := A;
end;

Procedure TPolygon.CalculateBoundBox();
var
  loop: integer;
begin
  if FCount>0 then
  begin
    FBoundBoxMinPoint.x := FPoints[0].x;
    FBoundBoxMinPoint.y := FPoints[0].y;
    FBoundBoxMaxPoint.x := FPoints[0].x;
    FBoundBoxMaxPoint.y := FPoints[0].y;
  end;
  //TODO: optimize (see TMesh);
  for loop:=0 to FCount-1  do
  begin
    if (FPoints[loop].x < FBoundBoxMinPoint.x) then
    begin
      FBoundBoxMinPoint.x := FPoints[loop].x;
    end;
    if (FPoints[loop].y < FBoundBoxMinPoint.y) then
    begin
      FBoundBoxMinPoint.y := FPoints[loop].y;
    end;

    if (FPoints[loop].x > FBoundBoxMaxPoint.x) then
    begin
      FBoundBoxMaxPoint.x := FPoints[loop].x;
    end;
    if (FPoints[loop].y > FBoundBoxMaxPoint.y) then
    begin
      FBoundBoxMaxPoint.y := FPoints[loop].y;
    end;
  end;
end;

procedure TPolygon.ApplyGradFill();
var
  loop: integer;
  CurColor: TPoint;
begin
  FGradColorPoint1.x := FBoundBoxMinPoint.x;
  FGradColorPoint1.y := FBoundBoxMinPoint.y;
  FGradColorPoint2.x := FBoundBoxMaxPoint.x;
  FGradColorPoint2.y := FBoundBoxMaxPoint.y;

  for loop:=0 to FCount-1 do
  begin
    CurColor:=CalcGradColor(FPoints[loop].x, FPoints[loop].y, FGradColorPoint1, FGradColorPoint2, FGradColorPoint1.x, FGradColorPoint1.y, FGradColorPoint2.x, FGradColorPoint2.y, FGradColorAngle);
    FPoints[loop].r := CurColor.r;
    FPoints[loop].g := CurColor.g;
    FPoints[loop].b := CurColor.b;
  end;
end;

Procedure TPolygon.Render();
var
  loop: integer;
begin
  if FTesselated = false then Tesselate;

  glbegin(GL_TRIANGLES);
  for loop:=0 to FVertexCount-1 do
  begin
    glcolor3f(FVertex[loop].R,FVertex[loop].G,FVertex[loop].B);
    glvertex3f(FVertex[loop].X,FVertex[loop].Y,FVertex[loop].Z);
  end;
  glend;
end;

(*
Procedure TPolygon.RenderOutline();
var
  loop: integer;
  temppoint: TPoint;
  outlineloop: integer;
begin
  if FTesselated = false then Tesselate;

  temppoint.x := 0.0;
  temppoint.y := 0.0;
  temppoint.z := 0.0;

  for outlineloop := 0 to FNewContour-1 do
  begin

//  loop :=0;

  glbegin(GL_LINE_LOOP);

  for loop:=0 to FContourCount[outlineloop]-1 do
  begin

//  while loop < FContourCount[outlineloop]-1 do
//  begin
//
//      if
//        (temppoint.X <> FContour[outlineloop][loop].X)
//      and
//        (temppoint.Y <> FContour[outlineloop][loop].Y)
//      and
//        (temppoint.Z <> FContour[outlineloop][loop].Z)
//      then
//      begin
//        glend;
//        glbegin(GL_LINE_LOOP);
//      end;

 //   glbegin(GL_LINE_LOOP);
    glcolor3f(FContour[outlineloop][loop].R,FContour[outlineloop][loop].G,FContour[outlineloop][loop].B);
    glvertex3f(FContour[outlineloop][loop].X,FContour[outlineloop][loop].Y,FContour[outlineloop][loop].Z);


//    glcolor3f(FContour[outlineloop][loop+1].R,FContour[outlineloop][loop+1].G,FContour[outlineloop][loop+1].B);
//    glvertex3f(FContour[outlineloop][loop+1].X,FContour[outlineloop][loop+1].Y,FContour[outlineloop][loop+1].Z);

//    temppoint.x := FContour[outlineloop][loop+1].X;
//    temppoint.y := FContour[outlineloop][loop+1].y;
//    temppoint.z := FContour[outlineloop][loop+1].z;

//glend;
//    loop := loop +2;
  end;



  glend;

  end;

end;
*)

procedure TPolygon.Extrude();
var
  loop: integer;
  newindex: integer;
  outlineloop: integer;
begin
  if FTesselated = false then Tesselate;

  F3DVertexCount := FVertexCount*2;

  //copy front faces
  setlength(F3DVertex, F3DVertexCount);
  for loop:=0 to FVertexCount-1 do
  begin
    F3DVertex[loop]:=FVertex[loop];
  end;

  //copy back faces
  for loop:=0 to FVertexCount-1 do
  begin
    F3DVertex[loop+(FVertexCount)]:=FVertex[FVertexCount-loop-1];
    F3DVertex[loop+(FVertexCount)].Z:=F3DVertex[loop+(FVertexCount)].Z-FExtrudeDepth;
  end;

  newindex:=(FVertexCount*2);

  //add side faces  (for each contour)
  for outlineloop := 0 to FNewContour-1 do
  begin

  F3DVertexCount:=F3DVertexCount+(FContourCount[outlineloop]*6);
  SetLength(F3DVertex, F3DVertexCount);


  for loop:=0 to FContourCount[outlineloop]-1 do
  begin
    //1st triangle
    F3DVertex[newindex]:=FContour[outlineloop][loop];
    F3DVertex[newindex+1]:=FContour[outlineloop][loop];
    F3DVertex[newindex+1].Z:=F3DVertex[newindex+1].Z-FExtrudeDepth;
    if (loop) < FContourCount[outlineloop]-1 then
    begin
      //2nd triangle
      F3DVertex[newindex+2]:=FContour[outlineloop][loop+1];

      F3DVertex[newindex+5]:=FContour[outlineloop][loop+1];

      F3DVertex[newindex+4]:=FContour[outlineloop][loop+1];
      F3DVertex[newindex+4].Z:=F3DVertex[newindex+4].Z-FExtrudeDepth;

      F3DVertex[newindex+3]:=FContour[outlineloop][loop];
      F3DVertex[newindex+3].Z:=F3DVertex[newindex+3].Z-FExtrudeDepth;
    end
    else
    begin
      //last triangle
      F3DVertex[newindex+2]:=FContour[outlineloop][0];

      F3DVertex[newindex+5]:=FContour[outlineloop][0];

      F3DVertex[newindex+4]:=FContour[outlineloop][0];
      F3DVertex[newindex+4].Z:=F3DVertex[newindex+4].Z-FExtrudeDepth;

      F3DVertex[newindex+3]:=FContour[outlineloop][loop];
      F3DVertex[newindex+3].Z:=F3DVertex[newindex+3].Z-FExtrudeDepth;
    end;
    newindex := newindex + 6;
  end;

  end;

end;

Procedure TPolygon.RenderExtruded();
var
  loop: integer;
begin
//  if FTesselated = false then Tesselate;

  glbegin(GL_TRIANGLES);
  for loop:=0 to F3DVertexCount-1 do
  begin
    glcolor3f(F3DVertex[loop].R,F3DVertex[loop].G,F3DVertex[loop].B);
    glvertex3f(F3DVertex[loop].X,F3DVertex[loop].Y,F3DVertex[loop].Z);
  end;
  glend;
end;

procedure TPolygon.Tesselate();
var
  i,loop: integer;
  tess: pointer;
  test: TGLArrayd3;
  pol: PGLArrayd6;

procedure iTessBeginCB(which: GLenum); {$IFDEF Win32}stdcall; {$ELSE}cdecl; {$ENDIF}
begin
  PolygonClass.tessBegin(which);
end;

procedure iTessEndCB(); {$IFDEF Win32}stdcall; {$ELSE}cdecl; {$ENDIF}
begin
  //PolygonClass.tessEnd();
end;

procedure iTessEdgeCB(flag: GLboolean; lpContext: pointer); {$IFDEF Win32}stdcall; {$ELSE}cdecl; {$ENDIF}
begin
      //just do nothing to force GL_TRIANGLES !!!
end;

procedure iTessVertexCB(data: PGLArrayd6); {$IFDEF Win32}stdcall; {$ELSE}cdecl; {$ENDIF}
begin
  //PolygonClass.tessVertex(data[0], data[1], data[2], data[3], data[4], data[5],0);
  PolygonClass.AddVertex(data[0], data[1], data[2], data[3], data[4], data[5],0);
end;


procedure iTessCombineCB(newVertex : PGLArrayd6; neighborVertex : Pointer;
                      neighborWeight : Pointer; var outData : Pointer); {$IFDEF Win32}stdcall; {$ELSE}cdecl; {$ENDIF}
var
  vertex: PGLArrayd6;
  loop: integer;
  colorloop: integer;
//  color: double;
begin
  new(vertex);

  vertex[0] := newVertex^[0];
  vertex[1] := newVertex^[1];
  vertex[2] := newVertex^[2];

  for colorloop := 3 to 5 do
  begin
    vertex[colorloop] := 0.0;
    for loop:=0 to 3 do
    begin
      if PGLArrayf4(neighborWeight)^[loop] <> 0 then
      begin
        vertex[colorloop] := vertex[colorloop] +
             PGLArrayf4(neighborWeight)^[loop] *
             PGLArrayvertex4(neighborVertex)^[loop][colorloop]
      end;
    end;
  end;

  // return output data (vertex coords and others)
  outData:= vertex;
end;

begin
  PolygonClass := Self;

  tess := gluNewTess();

  gluTessCallback(tess, GLU_TESS_BEGIN, @iTessBeginCB );
  gluTessCallback(tess, GLU_TESS_END, @iTessEndCB);
  gluTessCallback(tess, GLU_TESS_VERTEX, @iTessVertexCB);
  gluTessCallback(tess, GLU_TESS_COMBINE, @iTessCombineCB);  //does not work for font?
  gluTessCallback(tess, GLU_TESS_EDGE_FLAG_DATA, @iTessEdgeCB); //force triangles

  gluTessProperty(tess, GLU_TESS_WINDING_RULE, GLU_TESS_WINDING_NONZERO );

  gluTessBeginPolygon(tess, nil);                   // with NULL data
  gluTessBeginContour(tess);

  for loop := 0 to FCount-1 do
  begin
      new(pol);
      pol[3]:=FPoints[loop].R; //color
      pol[4]:=FPoints[loop].G;
      pol[5]:=FPoints[loop].B;

      pol[0]:=FPoints[loop].X;
      pol[1]:=FPoints[loop].Y;
      pol[2]:=0;

      test[0] := pol[0];
      test[1] := pol[1];
      test[2] := pol[2];
      gluTessVertex(tess, test, pol);
  end;

  gluTessEndContour(tess);
  gluTessEndPolygon(tess);
  gluDeleteTess(tess);        // delete after tessellation

  FNewContour:=0;

  //outline
  FOutline:=true;

  tess := gluNewTess();

  gluTessCallback(tess, GLU_TESS_BEGIN, @iTessBeginCB );
  gluTessCallback(tess, GLU_TESS_END, @iTessEndCB);
  gluTessCallback(tess, GLU_TESS_VERTEX, @iTessVertexCB);
  gluTessCallback(tess, GLU_TESS_COMBINE, @iTessCombineCB);  //does not work for font?
  gluTessCallback(tess, GLU_TESS_EDGE_FLAG_DATA, @iTessEdgeCB); //force triangles

  gluTessProperty(tess, GLU_TESS_BOUNDARY_ONLY, GL_TRUE);

  gluTessProperty(tess, GLU_TESS_WINDING_RULE, GLU_TESS_WINDING_NONZERO );

  gluTessBeginPolygon(tess, nil);                   // with NULL data
  gluTessBeginContour(tess);

  for loop := 0 to FCount-1 do
  begin
      new(pol);
      pol[3]:=FPoints[loop].R; //color
      pol[4]:=FPoints[loop].G;
      pol[5]:=FPoints[loop].B;

      pol[0]:=FPoints[loop].X;
      pol[1]:=FPoints[loop].Y;
      pol[2]:=0;

      test[0] := pol[0];
      test[1] := pol[1];
      test[2] := pol[2];
      gluTessVertex(tess, test, pol);
  end;

  gluTessEndContour(tess);
  gluTessEndPolygon(tess);
  gluDeleteTess(tess);        // delete after tessellation

  PolygonClass := nil;
  FTesselated := true;

  FOutline := false;
end;

//TPolygonFont

procedure TPolygonFont.RenderChar(AValue: char);
begin
  FCharGlyph[ord(AValue)].Render;
  FCharGlyph[ord(AValue)].RenderPath;
end;

procedure TPolygonFont.RenderString(AValue: string);
var
  i: integer;
begin
  for i :=1 to length(AValue) do
  begin
    RenderChar(AValue[i]);
    glTranslatef((FCharWidth[ord(AValue[i])]), 0, 0);
  end;
end;

procedure TPolygonFont.LoadFromFile(AValue: string);
var
  loop: integer;
  fs: TStringList;
begin

  fs := TStringList.Create;
  fs.NameValueSeparator := ':';
  fs.LoadFromFile(AValue);

  FName := fs[0];

  for loop := 0 to 255 do
  begin
    FCharGlyph[loop] := TPolygon.Create(nil);
    FCharGlyph[loop].SetColor(0.0,0.0,1.0,0.0);
    FCharGlyph[loop].SetLineColor(1.0,1.0,1.0,1.0);
    FCharGlyph[loop].LineWidth:= 1.0;

    // Get glyphs' strokes per char
    if ( (loop >= ord('A')) and (loop <= ord('Z')) ) or ( (loop >= ord('a')) and (loop <= ord('z')) ) then
    begin
      FCharGlyph[loop].Path := fs.Values[inttostr(loop)];
      FCharGlyph[loop].CalculateBoundBox();
      FCharWidth[loop] := Round(FCharGlyph[loop].FBoundBoxMaxPoint.x);
      FCharGlyph[loop].ApplyGradFill();
      //FCharGlyph[loop].Tesselate; //Do automatic tesselate...
      //FCharGlyph[loop].Extrude(); //Only flat font by default
    end;
  end;

end;

end.
