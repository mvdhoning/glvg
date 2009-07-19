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

//TODO: implement basic svg shapes using paths.
//http://www.w3.org/TR/SVG11/paths.html

TPath = class
private
  FCommandText: ansistring;
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
  property Text: ansistring read fcommandtext write fcommandtext;
  property Count: integer read FCount;
end;

TglvgFillType = (glvgNone, glvgSolid, glvgLinearGradient, glvgCircularGradient,glvgTexture);

TColor = class
private
  fx: single;
  fy: single;
  fz: single;
  fr: single;
  fg: single;
  fb: single;
  fa: single;
public
  constructor Create;
  procedure SetColor(aR: single; aG: single; aB: single;aA: single); overload;
  procedure SetColor(AName: string); overload;
  function  GetColorPoint: TPoint;
  property x: single read fx write fx;
  property y: single read fy write fy;
  property z: single read fz write fz;
  property r: single read fr write fr;
  property g: single read fg write fg;
  property b: single read fb write fb;
  property a: single read fa write fa;
end;

TStyle = class
private
  FColor: TColor;
  FLineColor: TColor;
  FGradColorAngle: single;  //TODO: consider gradient to be a seperate class
  FGradColorAngleAlpha: single;  //TODO: consider gradient to be a seperate class
  FGradColorPoint1: TColor; //TODO: should be dynamic array to support better gradients
  FGradColorPoint2: TColor; //TODO: should be dynamic array to support better gradients
  FLineWidth: single;
  FFillType: TglvgFillType;
  FAlphaFillType: TglvgFillType;
  FlineType: TglvgFillType;
  FAlphaLineType: TglvgFillType;
public
  constructor Create();
  destructor Destroy(); override;
  property GradColorAngle: single read FGradColorAngle write FGradColorAngle;
  property GradColorAngleAlpha: single read FGradColorAngleAlpha write FGradColorAngleAlpha;
  property GradColorPoint1: TColor read FGradColorPoint1 write FGradColorPoint1;
  property GradColorPoint2: TColor read FGradColorPoint2 write FGradColorPoint2;
  property Color: TColor read FColor write FColor;
  property LineColor: TColor read FLineColor write FLineColor;
  property LineWidth: single read FLineWidth  write FLineWidth;
  property FillType: TglvgFillType read FFillType write FFillType;
  property LineType: TglvgFillType read FLineType write FLineType;
  property AlphaFillType: TglvgFillType read FAlphaFillType write FAlphaFillType;
  property AlphaLineType: TglvgFillType read FAlphaLineType write FAlphaLineType;
  function TrigGLTriangle(value: single): single;
  function CalcGradColor(xpos: single; ypos: single; gradbegincolor: TPoint; gradendcolor: TPoint;gradx1: single; grady1: single; gradx2: single; grady2: single; gradangle: single): TPoint;
  function CalcGradAlpha(xpos: single; ypos: single; gradbeginalpha: single; gradendalpha: single;gradx1: single; grady1: single; gradx2: single; grady2: single; gradangle: single): single;

  //procedure SetLineColor(aR: single; aG: single; aB: single;aA: single);
end;

TPolygon = class(TComponent)
private
  FcPath: TPath;            //Outline
  FPoints: array of TPoint; //polygon point
  FVertex: array of TPoint; //triangulated data
  FExtrudeDepth: single;
  F3DVertex: array of TPoint; //3d extruded mesh
  F3DVertexCount: integer;

  FStyle: TStyle;

  FCount: integer;
  FVertexCount: integer;
  FTesselated: boolean;

  FBoundBoxMinPoint: TPoint;
  FBoundBoxMaxPoint: TPoint;

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

  procedure Add(X: single; Y: single); overload;
  procedure Add(X: single; Y: single; Z: single); overload;
  procedure Add(X: single; Y: single; Z: single; R: single; G: single; B: single; A: single); overload;
  procedure Render();
  procedure RenderPath();
  procedure RenderBoundingBox();
  procedure Tesselate();
  procedure Extrude();
  procedure RenderExtruded();
  procedure CalculateBoundBox();
  procedure ApplyGradFill();
  procedure ApplyAlphaGradFill();
  property Path: string read GetPathText write SetPathText;
  property Points[I: integer]: TPoint read GetPoint write SetPoint;
  property Count: integer read GetCount;
  property ExtrudeDepth: single read FExtrudeDepth write FExtrudeDepth;
  property Style: TStyle read FStyle write FStyle;
end;



TglvgObject = class
  private
    FPolyShape: TPolygon;
    FName: string;
    procedure SetStyle(AValue: TStyle);
    function GetStyle(): TStyle;
  public
    Constructor Create();
    Destructor Destroy(); override;
    procedure Init; virtual;
    procedure CleanUp; virtual;
    procedure Render; virtual;
    property name: string read fname write fname;
    //property LineWidth: single read GetLineWidth write SetLineWidth;
    property Style: TStyle read GetStyle write SetStyle;
    property Polygon: TPolygon read FPolyshape write FPolyshape;
end;

TPolygonFont = class
     private
        FCharGlyph: array[0..255] of TglvgObject;
        FCharWidth: array[0..255] of integer;
        FName: string;
        FScale: single;
        FFontHeight: single;
        FFontWidth: single;
        FStyle: TStyle;
     public
        procedure LoadFromFile(AValue: string);
        procedure RenderChar(AValue: char);
        procedure RenderString(AValue: string);
        property Name: string read FName write FName;
        property Scale: single read FScale write FScale;
        property Style: TStyle read FStyle write FStyle;
     end;

TglvgRect = class(TglvgObject)
  private
    Fx: Single;
    Fy: Single;
    Fwidth: Single;
    Fheight: Single;
    Frx: Single;
    Fry: Single;
  public
    Constructor Create();
    procedure Init; override;
    property X: single read Fx write Fx;
    property Y: single read Fy write Fy;
    property Width: single read Fwidth write Fwidth;
    property Height: single read Fheight write Fheight;
    property Rx: single read Frx write Frx;
    property Ry: single read Fry write Fry;
end;

TglvgElipse = class(TglvgObject)
  private
    Fx: Single;
    Fy: Single;
    Frx: Single;
    Fry: Single;
  public
    Constructor Create();
    procedure Init; override;
    property X: single read Fx write Fx;
    property Y: single read Fy write Fy;
    property Rx: single read Frx write Frx;
    property Ry: single read Fry write Fry;
end;

TglvgCircle = class(TglvgElipse)
  private
    procedure SetRadius(AValue: Single);
    function  GetRadius(): single;
  public
    property Radius: single read GetRadius write SetRadius;
end;

TglvgLine = class(TglvgObject)
  private
    Fx1: Single;
    Fy1: Single;
    Fx2: Single;
    Fy2: Single;
  public
    Constructor Create();
    procedure Init; override;
    property X1: single read Fx1 write Fx1;
    property Y1: single read Fy1 write Fy1;
    property X2: single read Fx2 write Fx2;
    property Y2: single read Fy2 write Fy2;
end;

TglvgPolyLine = class(TglvgObject) //TODO: implement or use TPolygon directly?
private
  points: array of TPoint;
public
//perform an absolute moveto operation to the first coordinate pair in the list of points
//for each subsequent coordinate pair, perform an absolute lineto operation to that coordinate pair
end;

TglvgPolygon = class(TglvgObject) //TODO: implement or use TPolygon directly?
private
  points: array of TPoint;
public
//perform an absolute moveto operation to the first coordinate pair in the list of points
//for each subsequent coordinate pair, perform an absolute lineto operation to that coordinate pair
//perform a closepath command
end;

TglvgText = class(TglvgObject)
private
  FFont: TPolygonFont;
  FText: string;
  FStyle: TStyle;
  FX: single;
  FY: single;
public
  Constructor Create();
  Destructor Destroy(); override;
  procedure Render; override;
  property X: single read Fx write Fx;
  property Y: single read Fy write Fy;
  property Font: TPolygonFont read FFont write FFont;
  property Text: string read FText write FText;
  property Style: TStyle read FStyle write FStyle;
end;

TglvgTextPath = class(TglvgText)
private
public
end;

//Experimental idea for making a vector gui ... (or group control)
TglvguiObject = class
private
  FElements: array of TglvgObject;
  FNumElements: integer;
  FMouseOver: boolean;
  FClicked: boolean;
  FX: single;
  FY: single;
public
  Constructor Create();
  Destructor Destroy(); override;
  procedure AddElement(AElement: TglvgObject);
  procedure Render;
  procedure RenderMouseOver;
  procedure RenderClicked;
  procedure GetState;
  property X: single read Fx write Fx;
  property Y: single read Fy write Fy;
end;

implementation

uses math, sysutils;

type
     TGLArrayd7 = array[0..6] of GLDouble;
     PGLArrayd7 = ^TGLArrayd7;
     TGLArrayvertex4 = array[0..3] of PGLArrayd7;
     PGLArrayvertex4 = ^TGLArrayvertex4;
     PGLArrayf4 = ^TGLArrayf4;

threadvar
  PolygonClass: TPolygon;

//TglvgObject
constructor TglvgObject.Create();
begin
  inherited create();
  FPolyShape:= TPolygon.Create(nil);
end;

destructor TglvgObject.Destroy;
begin
  FPolyShape.Free;
  inherited Destroy;
end;

procedure TglvgObject.Init;
begin
  FPolyShape.CalculateBoundBox();

    if FPolyShape.Style.FGradColorPoint1.x = -1.0 then
    FPolyShape.Style.FGradColorPoint1.x := FPolyShape.FBoundBoxMinPoint.x;
    if FPolyShape.Style.FGradColorPoint1.y = -1.0 then
    FPolyShape.Style.FGradColorPoint1.y := FPolyShape.FBoundBoxMinPoint.y;

    if FPolyShape.Style.FGradColorPoint2.x = -1.0 then
    FPolyShape.Style.FGradColorPoint2.x := FPolyShape.FBoundBoxMaxPoint.x;
        if FPolyShape.Style.FGradColorPoint2.y = -1.0 then
    FPolyShape.Style.FGradColorPoint2.y := FPolyShape.FBoundBoxMaxPoint.y;

  if FPolyShape.Style.FillType = glvgLinearGradient then
  begin
    FPolyShape.ApplyGradFill();
  end;

  if FPolyShape.Style.FAlphaFillType = glvgLinearGradient then
  begin
    FPolyShape.ApplyAlphaGradFill();
  end;
end;

procedure TglvgObject.CleanUp;
begin
  //Ok Clean Up for a high speed gain ...
  FPolyShape.FcPath.Free;
  FPolyShape.FcPath := TPath.Create;
  FPolyShape.FCount:= 0;
  FPolyShape.FVertexCount := 0;
  SetLength(FPolyShape.FPoints,0);
  SetLength(FPolyShape.FVertex,0);
end;

procedure TglvgObject.Render;
begin
  FPolyShape.Render;
  FPolyShape.RenderPath;
//  FPolyShape.RenderBoundingBox; //DEBUG
end;

procedure TglvgObject.SetStyle(AValue: TStyle);
begin
  FPolyShape.Style := AValue;
end;

function TglvgObject.GetStyle(): TStyle;
begin
  result := FPolyShape.Style;
end;

//TglvgRect
constructor TglvgRect.Create();
begin
  inherited create();

  Fx:= 0.0;
  Fy:= 0.0;
  Fwidth:= 0.0;
  Fheight:= 0.0;
  Frx:= 0.0;
  Fry:= 0.0;

end;

procedure TglvgRect.Init;
begin
  //Ok Clean Up for a high speed gain ...
  self.CleanUp;

  FPolyShape.Path :=

    'M '+FloatToStr(Fx+Frx)+' '+FloatToStr(Fy)+
    ' Q '+FloatToStr(Fx)+' '+FloatToStr(Fy)+
    ' '+FloatToStr(Fx)+' '+FloatToStr(Fy+Fry)+
    ' L '+FloatToStr(Fx)+' '+FloatToStr(Fy+FHeight-Fry)+

    ' Q '+FloatToStr(Fx)+' '+FloatToStr(Fy+FHeight)+
    ' '+FloatToStr(Fx+Frx)+' '+FloatToStr(Fy+FHeight)+

    ' L '+FloatToStr(Fx+FWidth-Frx)+' '+FloatToStr(Fy+FHeight)+

    ' Q '+FloatToStr(Fx+FWidth)+' '+FloatToStr(Fy+FHeight)+
    ' '+FloatToStr(Fx+FWidth)+' '+FloatToStr(Fy+FHeight-Fry)+

    ' L '+FloatToStr(Fx+FWidth)+' '+FloatToStr(Fy+Fry) +

    ' Q '+FloatToStr(Fx+FWidth)+' '+FloatToStr(Fy)+
    ' '+FloatToStr(Fx+FWidth-Frx)+' '+FloatToStr(Fy)+

    ' Z';

    inherited init;
end;

//TglvgElipse

constructor TglvgElipse.Create;
begin
  inherited Create;
  Fx:= 0.0;
  Fy:= 0.0;
  Frx:= 0.0;
  Fry:= 0.0;
end;

procedure TglvgElipse.Init;
var
  temppath: string;
  angle: single;
  vectorx: single;
  vectory: single;
  vectorx1: single;
  vectory1: single;
begin
  //Ok Clean Up for a high speed gain ...
  self.CleanUp;

  //FPolyShape.FcPath.FSplinePrecision := 1;

  // draw a circle from a bunch of short lines
  angle:=0.0*pi; //start point arc (0.0 for a complete circle)
  vectorX:=FX+(Frx*sin(angle));
  vectorY:=FY+(Fry*cos(angle));
  vectorY1:=vectorY;
  vectorX1:=vectorX;

  temppath:='M '+FloatToStr(VectorX1)+' '+FloatToStr(VectorY1);

  angle := angle + 0.1; //0.01;
  while angle < 2.0*pi do   //to endpoint arc (2.0 make a complete circle)
  begin
    vectorX:=FX+(Frx*sin(angle));
    vectorY:=FY+(Fry*cos(angle));
    temppath:=temppath+' L '+FloatToStr(VectorX1)+' '+FloatToStr(VectorY1);
    vectorY1:=vectorY;
    vectorX1:=vectorX;
    angle := angle + 0.1; //0.01;
  end;
  temppath:=temppath+' L '+FloatToStr(VectorX1)+' '+FloatToStr(VectorY1);
  temppath:=temppath + ' Z';

  FPolyShape.Path := temppath;

  inherited init;
end;

//TglvgCircle
procedure TglvgCircle.SetRadius(AValue: single);
begin
  Frx := AValue;
  Fry := AValue;
end;

function TglvgCircle.GetRadius;
begin
  result := Frx;
end;

//TglvgLine

constructor TglvgLine.Create;
begin
  inherited Create;
  Fx1:= 0.0;
  Fy1:= 0.0;
  Fx2:= 0.0;
  Fy2:= 0.0;
end;

procedure TglvgLine.Init;
begin
  //Ok Clean Up for a high speed gain ...
  self.CleanUp;

  FPolyShape.Path := 'M '+FloatToStr(Fx1)+ ' '+FloatToStr(Fy1)+
                     'L '+FloatToStr(Fx2)+ ' '+FloatToStr(Fy2);

  inherited init;
end;

//TglvgText

constructor TglvgText.Create;
begin
  inherited Create;
  FStyle := TStyle.Create;
  FFont := TPolygonFont.Create;
  FFont.Style := FStyle;
end;

destructor TglvgText.Destroy;
begin
  FFont.Free;
  FStyle.Free;
  inherited Destroy;
end;

procedure TglvgText.Render;
begin
  glpushmatrix();
    gltranslatef(Fx,Fy,0);
    ffont.RenderString(FText);
  glpopmatrix();
end;

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

//cubic bezier line ( (1-i)^3*pa+3*i(1-i)^2*pb+3*i^2*(1-i)*pc+i^3*pd  )
procedure TPath.DrawCSpline( AFrom, ATo, AFromControlPoint, AToControlPoint: TPoint );
var
  di, i : Double;
  p1, p2: TPoint;
begin
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
end;

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
  MyParser: TParser; //TODO: collect info on TParser!!!!
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

  //parse string (remove linebreaks etc

  //FCommandText := WrapText (FCommandText , 1023 );
  FCommandText := WrapText(FCommandText, #13#10, [' '], 1); //TODO: find better way to break up large paths

  MS := TMemoryStream.Create;
  MS.Position := 0;
  MS.Write(FCommandText[1], Length(FCommandText));
  MS.Position := 0;
  MyParser := TParser.Create(MS);

  prevcommand := '-';
  curtoken := ' ';
  while curtoken <> toEOF do
  begin
    //Get Token
    str := MyParser.TokenString();
    //Get token type
    case(MyParser.Token) of
      toSymbol:
      begin
        if length(str) = 1 then
        begin
          if UpperCase(str) <> 'Z' then //z Z does not have parameters...
          begin
            MyParser.NextToken;
            str := str+MyParser.TokenString;
          end;
        end;
        curCommand := str[1]; //first char of the string is the current command;
        Delete(str,1,1); //remove command from string
        paramcount:=1;
        if str <> '' then
        begin
          if UpperCase(curcommand) <> 'Z' then
            params[paramcount-1]:=StrToFloat(str);
        end;
      end;
      toInteger:
      begin
        if UpperCase(curcommand) <> 'Z' then
        begin
          params[paramcount]:=StrToFloat(str);
          paramcount := paramcount +1;
        end;
      end;
      toFloat:
      begin
        if UpperCase(curcommand) <> 'Z' then
        begin
          params[paramcount]:=StrToFloat(str);
          paramcount := paramcount +1;
        end;
      end;
//      toString:
    end;

    //detect command: (Uppercase is absolute coords vs Lowercase relative coords)
    Case CurCommand of
      // Move To (M m)
      'M':
      Begin
        if paramcount = 2 then
        begin
          ParamsPoint[0].x:=params[0];
          ParamsPoint[0].y:=params[1];
          paramcount := 0;
          CurPoint := ParamsPoint[0];
          FirstPoint := CurPoint;
        end;
      End;
      'm':
      Begin
        if paramcount = 2 then
        begin
          ParamsPoint[0].x:=CurPoint.x + params[0];
          ParamsPoint[0].y:=CurPoint.y + params[1];
          paramcount := 0;
          CurPoint := ParamsPoint[0];
          FirstPoint := CurPoint;
        end;
      End;
      // Line To (L l H h V v)
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
      'l':
      Begin
        if paramcount = 2 then
        begin
          ParamsPoint[0].x :=CurPoint.x + params[0];
          ParamsPoint[0].y :=CurPoint.y + params[1];
          NewStroke( CurPoint, ParamsPoint[0]);
          paramcount :=0;
          CurPoint := ParamsPoint[0];
        end;
      End;
      'H':
      Begin
        if paramcount = 1 then
        begin
          ParamsPoint[0].x := params[0];
          ParamsPoint[0].y := CurPoint.y;
          NewStroke( CurPoint, ParamsPoint[0]);
          paramcount :=0;
          CurPoint := ParamsPoint[0];
        end;
      End;
      'h':
      Begin
        if paramcount = 1 then
        begin
          ParamsPoint[0].x := CurPoint.x+params[0];
          ParamsPoint[0].y := CurPoint.y;
          NewStroke( CurPoint, ParamsPoint[0]);
          paramcount :=0;
          CurPoint := ParamsPoint[0];
        end;
      End;
      'V':
      Begin
        if paramcount = 1 then
        begin
          ParamsPoint[0].x := CurPoint.x;
          ParamsPoint[0].y := params[0];
          NewStroke( CurPoint, ParamsPoint[0]);
          paramcount :=0;
          CurPoint := ParamsPoint[0];
        end;
      End;
      'v':
      Begin
        if paramcount = 1 then
        begin
          ParamsPoint[0].x := CurPoint.x;
          ParamsPoint[0].y := CurPoint.y+params[0];
          NewStroke( CurPoint, ParamsPoint[0]);
          paramcount :=0;
          CurPoint := ParamsPoint[0];
        end;
      End;
      // Close Path  (Z z)
      'Z':
      Begin
        //line back to the first point
        NewStroke( CurPoint, FirstPoint);
        FirstPoint:=CurPoint; //optional?
      End;
      'z':
      Begin
        //line back to the first point
        NewStroke( CurPoint, FirstPoint);
        FirstPoint:=CurPoint; //optional?
      End;
      // Quadratic Bezier (Q q T t)
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
          PrevControlPoint := ParamsPoint[0];
          CurPoint := ParamsPoint[1];
        end;
      End;
      'q':
      Begin
        if paramcount = 4 then
        begin

          ParamsPoint[0].x := CurPoint.x+params[0];
          ParamsPoint[0].y := CurPoint.y+params[1];
          ParamsPoint[1].x := CurPoint.x+params[2];
          ParamsPoint[1].y := CurPoint.y+params[3];
          DrawQSpline(CurPoint, ParamsPoint[1], ParamsPoint[0]);
          paramcount := 0;
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
      't':
      Begin
        if paramcount = 2 then
        begin
          ParamsPoint[0].x:=CurPoint.x+CurPoint.x-PrevControlPoint.x;
          ParamsPoint[0].y:=CurPoint.y+CurPoint.y-PrevControlPoint.y;
          ParamsPoint[1].x :=CurPoint.x+ params[0];
          ParamsPoint[1].y :=CurPoint.y+ params[1];
          DrawQSpline(CurPoint, ParamsPoint[1], ParamsPoint[0]);
          paramcount:=0;
          PrevControlPoint := ParamsPoint[0];
          CurPoint := ParamsPoint[1];
        end;
      End;
      // Cubic Bezier (C c S s)
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
      'c':
      Begin
        if paramcount = 6 then
        Begin
          ParamsPoint[0].x:=CurPoint.x+params[0];
          ParamsPoint[0].y:=CurPoint.y+params[1];
          ParamsPoint[1].x:=CurPoint.x+params[2];
          ParamsPoint[1].y:=CurPoint.y+params[3];
          ParamsPoint[2].x:=CurPoint.x+params[4];
          ParamsPoint[2].y:=CurPoint.y+params[5];
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
      's':
      Begin
        if paramcount = 4 then
        Begin
          if prevcommand = ' ' then
          begin
            ParamsPoint[0].x:=CurPoint.x+params[0];
            ParamsPoint[0].y:=CurPoint.y+params[1];
          end
          else
          begin
            //mirrored 2nd ctrlpoint
            ParamsPoint[0].x:=CurPoint.x+CurPoint.x-PrevControlPoint.x;
            ParamsPoint[0].y:=CurPoint.y+CurPoint.y-PrevControlPoint.y;
          end;
          ParamsPoint[1].x:=CurPoint.x+params[0];
          ParamsPoint[1].y:=CurPoint.y+params[1];
          ParamsPoint[2].x:=CurPoint.x+params[2];
          ParamsPoint[2].y:=CurPoint.y+params[3];
          DrawCSpline( CurPoint, ParamsPoint[2], ParamsPoint[0], ParamsPoint[1]);
          paramcount := 0; //prevent drawing again
          CurPoint:=ParamsPoint[2];
          PrevControlPoint := ParamsPoint[1];
        End;
      End;

    end;

    PrevCommand:=CurCommand;
    curtoken := MyParser.NextToken;
  end;
end;

//TColor

constructor TColor.Create;
begin
  inherited Create;
  fx := -1;
  fy := -1;
  fz := -1;
  fr := 0;
  fg := 0;
  fb := 0;
  fa := 1;
end;

function TColor.GetColorPoint;
begin
  result.x := fx;
  result.y := fy;
  result.z := fz;
  result.r := fr;
  result.g := fg;
  result.b := fb;
  result.a := fa;
end;

procedure TColor.SetColor(aR: single; aG: single; aB: single;aA: single);
begin
    r := aR;
    g := aG;
    b := aB;
    a := aA;
end;

procedure TColor.SetColor(AName: string);

function HexToInt(HexStr: String): Int64;
var RetVar : Int64;
    i : byte;
begin
  HexStr := UpperCase(HexStr);
  if HexStr[length(HexStr)] = 'H' then
     Delete(HexStr,length(HexStr),1);
  RetVar := 0;

  for i := 1 to length(HexStr) do begin
      RetVar := RetVar shl 4;
      if HexStr[i] in ['0'..'9'] then
         RetVar := RetVar + (byte(HexStr[i]) - 48)
      else
         if HexStr[i] in ['A'..'F'] then
            RetVar := RetVar + (byte(HexStr[i]) - 55)
         else begin
            Retvar := 0;
            break;
         end;
  end;

  Result := RetVar;
end;


begin
  if Aname[1] = '#' then
  begin
     r := HexToInt(Copy(Aname, 2, 2) ) / 254;
     g := HexToInt(Copy(Aname, 4, 2) ) / 254;
     b := HexToInt(Copy(Aname, 6, 2) ) / 254;
     //a := HexToInt(Copy(Aname, 7, 8) ) /255;
 end;
end;

//TStyle

constructor TStyle.Create;
begin
  inherited Create;

  FColor := TColor.Create;
  FLineColor := TColor.Create;
  FGradColorPoint1 := TColor.Create;
  FGradColorPoint2 := TColor.Create;

  FFillType := glvgnone;
  FLineType := glvgsolid;

  FColor.SetColor(1,0,0,1.0);     //first set color etc
  FLineWidth := 1.0;
  FLineColor.SetColor(1,1,1,1);

  FGradColorAngle := 0;
  //FGradColorPoint1.x:=0.0; //min boundbox x
  //FGradColorPoint1.y:=0.0; //min boundbox y
  FGradColorPoint1.r:=0.0;
  FGradColorPoint1.g:=1.0;
  FGradColorPoint1.b:=0.0;
  FGradColorPoint1.a:=1.0;

  //point must make a square (e.g. bounding box of polygon)

  //FGradColorPoint2.x:=1.0; //max boundbox x;
  //FGradColorPoint2.y:=1.0; //max boundbox y;
  FGradColorPoint2.r:=1.0;
  FGradColorPoint2.g:=0.0;
  FGradColorPoint2.b:=0.0;
  FGradColorPoint2.a:=1.0;
end;

destructor TStyle.Destroy;
begin
  FColor.Free;
  FLineColor.Free;
  FGradColorPoint1.Free;
  FGradColorPoint2.Free;
end;

const
 TRIG_FUNCTABLE_SIZE: integer =	1024;

function TStyle.TrigGLTriangle(value: single): single;
var
  temp: integer;
begin
    temp := ROund(value * ( TRIG_FUNCTABLE_SIZE / 360 ) );

    if temp < TRIG_FUNCTABLE_SIZE /2 then
    begin
      result := temp / ( TRIG_FUNCTABLE_SIZE / 2 );
    end
    else
    begin
      result := 1.0 - ((temp - TRIG_FUNCTABLE_SIZE / 2) / ( TRIG_FUNCTABLE_SIZE / 2 ));
    end;

end;

function TStyle.CalcGradColor(xpos: single; ypos: single; gradbegincolor: TPoint; gradendcolor: TPoint;gradx1: single; grady1: single; gradx2: single; grady2: single; gradangle: single): TPoint;
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
  //result.A:=gradbeginColor.A *  (1.0 - CurPos) + GradEndColor.A * CurPos;

end;

function TStyle.CalcGradAlpha(xpos: single; ypos: single; gradbeginalpha: single; gradendalpha: single;gradx1: single; grady1: single; gradx2: single; grady2: single; gradangle: single): single;
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
if FStyle.LineType <> glvgNone then
begin
    glcolor4f(FStyle.LineColor.R,FStyle.LineColor.G,FStyle.LineColor.B, FStyle.LineColor.A);
    glLineWidth(FStyle.LineWidth);

    //Draw Path
    glBegin(GL_LINES);
    for loop:=0 to fcpath.Count-1 do
    begin
      glVertex2f(fcpath.Points[loop].x, fcpath.Points[loop].y);
    end;
    glEnd();
  end;
end;



procedure TPolygon.tessBegin(which: GLenum);
begin
//    glBegin(which);
end;

procedure TPolygon.tessEnd();
begin
//    glEnd();
end;

procedure TPolygon.tessVertex(x: single; y: single; z: single; r: single; g: single; b: single; a:single);
begin
//    glcolor4f(r,g,b,a);
//    glVertex3f(x,y,z);
end;


procedure TPolygon.AddVertex(x: single; y: single; z: single; r: single; g: single; b: single; a:single);
begin
  FVertexCount := FVertexCount + 1;
  SetLength(FVertex, FVertexCount);

  FVertex[FVertexCount-1].R := R;
  FVertex[FVertexCount-1].G := G;
  FVertex[FVertexCount-1].B := B;
  FVertex[FVertexCount-1].A := A;

  FVertex[FVertexCount-1].X := X;
  FVertex[FVertexCount-1].Y := Y;
  FVertex[FVertexCount-1].Z := Z;
end;

constructor TPolygon.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);

  FcPath := TPath.Create;
  FcPath.Text:='';
  FCount := 0;
  FVertexCount := 0;
  FTesselated := false;

  FStyle := TStyle.Create;

  FExtrudeDepth := 0.0;



end;

destructor TPolygon.Destroy();
begin
  FcPath.Free;
  FStyle.Free;
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

  CurColor:=FStyle.Color.GetColorPoint;

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
  FPoints[FCount-1].R := FStyle.Color.R;
  FPoints[FCount-1].G := FStyle.Color.G;
  FPoints[FCount-1].B := FStyle.Color.B;
  FPoints[FCount-1].A := FStyle.Color.A;
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
  for loop:=0 to FCount-1 do
  begin
    CurColor:=FStyle.CalcGradColor(FPoints[loop].x, FPoints[loop].y, FStyle.GradColorPoint1.GetColorPoint, FStyle.GradColorPoint2.GetColorPoint, FStyle.GradColorPoint1.x, FStyle.GradColorPoint1.y, FStyle.GradColorPoint2.x, FStyle.GradColorPoint2.y, FStyle.GradColorAngle);
    FPoints[loop].r := CurColor.r;
    FPoints[loop].g := CurColor.g;
    FPoints[loop].b := CurColor.b;
  end;

  for loop:=0 to FVertexCount-1 do
  begin

    CurColor:=FStyle.CalcGradColor(FVertex[loop].x, FVertex[loop].y, FStyle.GradColorPoint1.GetColorPoint, FStyle.GradColorPoint2.GetColorPoint, FStyle.GradColorPoint1.x, FStyle.GradColorPoint1.y, FStyle.GradColorPoint2.x, FStyle.GradColorPoint2.y, FStyle.GradColorAngle);
    FVertex[loop].r := CurColor.r;
    FVertex[loop].g := CurColor.g;
    FVertex[loop].b := CurColor.b;
  end;

end;

procedure TPolygon.ApplyAlphaGradFill();
var
  loop: integer;
begin
  for loop:=0 to FCount-1 do
  begin
    FPoints[loop].a := FStyle.CalcGradAlpha(FPoints[loop].x, FPoints[loop].y, FStyle.GradColorPoint1.a, FStyle.GradColorPoint2.a, FStyle.GradColorPoint1.x, FStyle.GradColorPoint1.y, FStyle.GradColorPoint2.x, FStyle.GradColorPoint2.y, FStyle.GradColorAngleAlpha);
  end;

  for loop:=0 to FVertexCount-1 do
  begin
    FVertex[loop].a := FStyle.CalcGradAlpha(FVertex[loop].x, FVertex[loop].y, FStyle.GradColorPoint1.a, FStyle.GradColorPoint2.a, FStyle.GradColorPoint1.x, FStyle.GradColorPoint1.y, FStyle.GradColorPoint2.x, FStyle.GradColorPoint2.y, FStyle.GradColorAngleAlpha);
  end;

end;

Procedure TPolygon.Render();
var
  loop: integer;
begin
if FStyle.FillType <> glvgNone then
begin
  if FTesselated = false then Tesselate;

  glbegin(GL_TRIANGLES);
  for loop:=0 to FVertexCount-1 do
  begin
//    glcolor4f(FVertex[loop].R,FVertex[loop].G,FVertex[loop].B,0.8);//FVertex[loop].A);
    glcolor4f(FVertex[loop].R,FVertex[loop].G,FVertex[loop].B,FVertex[loop].A);
    glvertex3f(FVertex[loop].X,FVertex[loop].Y,FVertex[loop].Z);
  end;
  glend;
end;
end;

procedure TPolygon.RenderBoundingBox;
var
  loop: integer;
begin
  glcolor4f(0,1,0,1);
  glLineWidth(1.0);
  glbegin(GL_LINES);
    glvertex3f(FBoundBoxMinPoint.X,FBoundBoxMinPoint.Y,0);
    glvertex3f(FBoundBoxMinPoint.X,FBoundBoxMaxPoint.Y,0);

    glvertex3f(FBoundBoxMinPoint.X,FBoundBoxMaxPoint.Y,0);
    glvertex3f(FBoundBoxMaxPoint.X,FBoundBoxMaxPoint.Y,0);

    glvertex3f(FBoundBoxMaxPoint.X,FBoundBoxMaxPoint.Y,0);
    glvertex3f(FBoundBoxMaxPoint.X,FBoundBoxMinPoint.Y,0);

    glvertex3f(FBoundBoxMaxPoint.X,FBoundBoxMinPoint.Y,0);
    glvertex3f(FBoundBoxMinPoint.X,FBoundBoxMinPoint.Y,0);
  glend;
end;

procedure TPolygon.Extrude();
var
  loop: integer;
//  newindex: integer;
//  outlineloop: integer;
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
  loop: integer;
  tess: pointer;
  test: TGLArrayd3;
  pol: PGLArrayd7;

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

procedure iTessVertexCB(data: PGLArrayd7); {$IFDEF Win32}stdcall; {$ELSE}cdecl; {$ENDIF}
begin
  //PolygonClass.tessVertex(data[0], data[1], data[2], data[3], data[4], data[5],0);
  PolygonClass.AddVertex(data[0], data[1], data[2], data[3], data[4], data[5], data[6]);
end;


procedure iTessCombineCB(newVertex : PGLArrayd7; neighborVertex : Pointer;
                      neighborWeight : Pointer; var outData : Pointer); {$IFDEF Win32}stdcall; {$ELSE}cdecl; {$ENDIF}
var
  vertex: PGLArrayd7;
  loop: integer;
  colorloop: integer;
begin
  new(vertex);

  vertex[0] := newVertex^[0];
  vertex[1] := newVertex^[1];
  vertex[2] := newVertex^[2];

  for colorloop := 3 to 6 do
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
      pol[6]:=FPoints[loop].A;

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

end;

//TPolygonFont

procedure TPolygonFont.RenderChar(AValue: char);
begin
  glpushmatrix();

    glscalef(FSCALE,-FSCALE,0);

    gltranslatef(0,-FFontHeight  ,0);

    FCharGlyph[ord(AValue)].Render;
    //FCharGlyph[ord(AValue)].RenderPath;

  glpopmatrix();

  glTranslatef((FCharWidth[ord(AValue)]*FSCALE), 0, 0);
  if AValue = ' ' then
  begin
    gltranslatef(20,0,0);
  end;

  end;

procedure TPolygonFont.RenderString(AValue: string);
var
  i: integer;
begin
  glpushmatrix();
  for i :=1 to length(AValue) do
  begin
    RenderChar(AValue[i]);
  end;
  glpopmatrix();
end;

procedure TPolygonFont.LoadFromFile(AValue: string);
var
  loop: integer;
  fs: TStringList;
begin

  FFontHeight := 0.0;

  fs := TStringList.Create;
  fs.NameValueSeparator := ':';
  fs.LoadFromFile(AValue);

  FName := fs[0];

  for loop := 0 to 255 do
  begin
    FCharGlyph[loop] := TglvgObject.Create;
    FCharGlyph[loop].Style:=FStyle;
    FCharGlyph[loop].FPolyShape.FcPath.FSplinePrecision := 3; //gpu/cpu friendly and nicely rounded

    // Get glyphs' strokes per char
    if ( (loop >= ord('A')) and (loop <= ord('Z')) ) or ( (loop >= ord('a')) and (loop <= ord('z')) ) or ( (loop >= ord('0')) and (loop <= ord('9')) )then
    begin
      FCharGlyph[loop].FPolyShape.Path := fs.Values[inttostr(loop)];
      FCharGlyph[loop].FPolyShape.CalculateBoundBox();
      FCharWidth[loop] := Round(FCharGlyph[loop].FPolyShape.FBoundBoxMaxPoint.x);

      if FFontHeight < FCharGlyph[loop].FPolyShape.FBoundBoxMaxPoint.y then
        FFontHeight := FCharGlyph[loop].FPolyShape.FBoundBoxMaxPoint.y;

      FCharGlyph[loop].Init;

      FCharGlyph[loop].Style.GradColorPoint1.x := FCharGlyph[loop].FPolyShape.FBoundBoxMinPoint.x;
      FCharGlyph[loop].Style.GradColorPoint1.y := FCharGlyph[loop].FPolyShape.FBoundBoxMinPoint.y;

      FCharGlyph[loop].Style.GradColorPoint2.x := FCharGlyph[loop].FPolyShape.FBoundBoxMaxPoint.x;
      FCharGlyph[loop].Style.GradColorPoint2.y := FCharGlyph[loop].FPolyShape.FBoundBoxMaxPoint.y;

      //if FCharGlyph[loop].Style.FillType = glvgLinearGradient then
      //  FCharGlyph[loop].ApplyGradFill();
    end;
  end;

end;

//TglvguiObject

  constructor TglvguiObject.Create;
  begin
    inherited Create();
    FNumElements:=0;

    AddElement(TglvgRect.Create);
    TglvgRect(FElements[0]).X := 0;
    TglvgRect(FElements[0]).Y := 0;

    TglvgRect(FElements[0]).Width := 100;
    TglvgRect(FElements[0]).Height := 30;

    TglvgRect(FElements[0]).Rx := 15;
    TglvgRect(FElements[0]).Ry := 15;

    TglvgRect(FElements[0]).Style.GradColorPoint1.SetColor('#00C0C0');
    TglvgRect(FElements[0]).Style.GradColorPoint2.SetColor('#0000C0');

    TglvgRect(FElements[0]).Style.FillType := glvgLinearGradient;
    TglvgRect(FElements[0]).Style.LineType := glvgNone;

    TglvgRect(FElements[0]).Init;

    //hl1
    AddElement(TglvgRect.Create);
    TglvgRect(FElements[1]).X := 2.5;
    TglvgRect(FElements[1]).Y := 2.5;

    TglvgRect(FElements[1]).Width := 95;
    TglvgRect(FElements[1]).Height := 20;

    TglvgRect(FElements[1]).Rx := 15;
    TglvgRect(FElements[1]).Ry := 15;

    TglvgRect(FElements[1]).Style.Color.SetColor('#FFFFFF');
    TglvgRect(FElements[1]).Style.GradColorPoint1.a:=1.0;
    TglvgRect(FElements[1]).Style.GradColorPoint1.y:=0.0;
    TglvgRect(FElements[1]).Style.GradColorPoint2.y:=10.0;
    TglvgRect(FElements[1]).Style.GradColorPoint2.a:=0.0;


    TglvgRect(FElements[1]).Style.FillType := glvgSolid;
    TglvgRect(FElements[1]).Style.AlphaFillType := glvgLinearGradient;
    TglvgRect(FElements[1]).Style.LineType := glvgNone;

    TglvgRect(FElements[1]).Init;

    //hl2

    AddElement(TglvgRect.Create);
    TglvgRect(FElements[2]).X := 2.5;
    TglvgRect(FElements[2]).Y := 30 - 2.5 - 20;

    TglvgRect(FElements[2]).Width := 95;
    TglvgRect(FElements[2]).Height := 20;

    TglvgRect(FElements[2]).Rx := 15;
    TglvgRect(FElements[2]).Ry := 15;

    TglvgRect(FElements[2]).Style.Color.SetColor('#000000');
    TglvgRect(FElements[2]).Style.GradColorPoint1.a:=0.0;
    TglvgRect(FElements[2]).Style.GradColorPoint1.y:=20.0;
    TglvgRect(FElements[2]).Style.GradColorPoint2.y:=30.0;
    TglvgRect(FElements[2]).Style.GradColorPoint2.a:=1.0;


    TglvgRect(FElements[2]).Style.FillType := glvgSolid;
    TglvgRect(FElements[2]).Style.AlphaFillType := glvgLinearGradient;
    TglvgRect(FElements[2]).Style.LineType := glvgNone;

    TglvgRect(FElements[2]).Init;


  end;

  destructor TglvguiObject.Destroy;
  var
    i: integer;
  begin
    if FElements <> nil then
    begin
      For i:=FNumElements-1 downto 0 do
      begin
        FElements[i].Free;
      end;
    end;

    SetLength(FElements,0);
    inherited Destroy;
  end;

  procedure TglvguiObject.AddElement(AElement: TglvgObject);
  begin
    FNumElements:=FNumElements+1;
    SetLength(FElements,FNumElements);
    FElements[FNumElements-1] := AElement;
  end;

  procedure TglvguiObject.Render;
  var
    i: integer;
  begin
    glpushmatrix();
      gltranslatef(Fx,Fy,0);
      //glscalef(5,5,1); //DEBUG scaling...
      for i:=0 to FNumElements-1 do
      begin
        FElements[i].Render;
      end;
    glpopmatrix();
  end;

  procedure TglvguiObject.RenderMouseOver;
  begin
  end;

  procedure TglvguiObject.RenderClicked;
  begin
  end;

  procedure TglvguiObject.GetState;
  begin
  end;


end.