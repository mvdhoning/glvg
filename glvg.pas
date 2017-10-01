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
 * Portions created by the Initial Developer are Copyright (C) 2002-2017
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 *  M van der Honing
 *
 *)

interface

uses DGLOpenGL, glBitmap, glPolygon, classes;

type

  //SVG path http://www.w3.org/TR/SVG11/paths.html
  TPath = class
  private
    FCommandText: ansistring;
    FCount: integer;
    FPoints: array of TPolygonPoint;
    FSplinePrecision: integer;
    procedure NewStroke( AFrom, ATo: TPolygonPoint );
    function EqualPoints( APoint1, APoint2: TPolygonPoint ): boolean;
    procedure DrawCSpline( AFrom, ATo, AFromControlPoint, AToControlPoint: TPolygonPoint );
    procedure DrawQSpline( AFrom, ATo, AControlPoint: TPolygonPoint );
    procedure AddPoint(AValue: TPolygonPoint);
    procedure SeTPolygonPoint(I: integer; AValue: TPolygonPoint);
    function GeTPolygonPoint(I: integer): TPolygonPoint;
  public
    constructor Create();
    destructor Destroy(); override;
    procedure Parse();
    property Points[I: integer]: TPolygonPoint read GeTPolygonPoint write SeTPolygonPoint;
    property Text: ansistring read fcommandtext write fcommandtext;
    property Count: integer read FCount;
  end;

  TglvgFillType = (glvgNone, glvgSolid, glvgLinearGradient, glvgCircularGradient,glvgTexture,glvgPattern);

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
    function  GetColorPoint: TPolygonPoint;
    property x: single read fx write fx;
    property y: single read fy write fy;
    property z: single read fz write fz;
    property r: single read fr write fr;
    property g: single read fg write fg;
    property b: single read fb write fb;
    property a: single read fa write fa;
  end;

  TglvgPattern= class;

  //Shape fill style
  TStyle = class
  private
    //TODO: bring back support for alpha gradients independend of color gradient
    FPattern: TglvgPattern;
    FColor: TColor;
    FLineColor: TColor;
    FGradColorAngle: single;
    FNumGradColors: integer;
    FGradColors: array of TColor;
    FLineWidth: single;
    FFillType: TglvgFillType;
    FlineType: TglvgFillType;
    FTextureFileName: string;
    FTexture: TglBitmap2D;
    FTextureId: GLuInt;
    FTextureAngle: single;
    procedure DrawBox(x: single; y: single; colorfrom: tcolor; colorto: tcolor);
    procedure DrawCircle(x: single;y: single; colorfrom: tcolor; colorto: tcolor);
    procedure DrawRing(x: single;y: single; colorfrom: tcolor; colorto: tcolor);
    procedure DrawFill(radius: single; aboundboxminpoint: TPolygonPoint; aboundboxmaxpoint: TPolygonPoint);
    procedure SetGradColor(Index: integer; AValue: TColor);
    function GetGradColor(Index: integer): TColor;
    procedure SetNumGradColors(AValue: integer);
  public
    constructor Create();
    destructor Destroy(); override;
    property GradColorAngle: single read FGradColorAngle write FGradColorAngle;
    property GradColor[i: integer]: TColor read GetGradColor write SetGradColor;
    property NumGradColors: integer read FNumGradColors write SetNumGradColors;
    property Color: TColor read FColor write FColor;
    property Pattern: TglvgPattern read FPattern write Fpattern;
    property LineColor: TColor read FLineColor write FLineColor;
    property LineWidth: single read FLineWidth  write FLineWidth;
    property FillType: TglvgFillType read FFillType write FFillType;
    property LineType: TglvgFillType read FLineType write FLineType;
    property TextureAngle: single read FTextureAngle write FTextureAngle;
    property TextureId: GluInt read FTextureId;
    property TextureFileName: string read FTextureFileName write FTextureFileName;
    function TrigGLTriangle(value: single): single;
    function CalcGradColor(xpos: single; ypos: single; gradbegincolor: TPolygonPoint; gradendcolor: TPolygonPoint;gradx1: single; grady1: single; gradx2: single; grady2: single; gradangle: single): TPolygonPoint;
    function CalcGradAlpha(xpos: single; ypos: single; gradbeginalpha: single; gradendalpha: single;gradx1: single; grady1: single; gradx2: single; grady2: single; gradangle: single): single;
    procedure Init(); //Loads and sets texture;
  end;

  TPolygonShape = class(TPolygon)
  private
    FcPath: TPath;  //SVG path of shape
    FStyle: TStyle; //Fill style
    function GetPathText: string;
    procedure SetPathText(AValue: string);
  public
    constructor Create();
    Destructor Destroy(); override;
    procedure Render(); overload;
    procedure Render(parentvalue, parentmask: integer); overload;
    procedure RenderPath();
    property Path: string read GetPathText write SetPathText;
    property Style: TStyle read FStyle write FStyle;
  end;

  //Base vector object
  TglvgObject = class
  private
    //TODO: add support for line widths and color style for line
    FPolyShape: TPolygonShape;
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
    property Style: TStyle read GetStyle write SetStyle;
    property Polygon: TPolygonShape read FPolyshape write FPolyshape;
  end;

  //Font
  TPolygonFont = class
  private
    FCharGlyph: array[0..255] of TglvgObject;
    FCharWidth: array[0..255] of integer;
    FName: string;
    FScale: single;
    FSize: single;
    FFontHeight: single;
    FStyle: TStyle;
    procedure SetSize(AValue: single);
  public
    procedure LoadFromFile(AValue: string);
    procedure RenderChar(AValue: char);
    procedure RenderString(AValue: string);
    function GetStringWidth(AValue: string): Single;
    property Name: string read FName write FName;
    property Scale: single read FScale write FScale;
    property Size: single read FSize write SetSize;
    property Style: TStyle read FStyle write FStyle;
  end;

  //Basic shapes
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

  TglvgPolyLine = class(TglvgObject)
  private
  public
    procedure Render; override;
  end;

  TglvgPolygon = class(TglvgObject)
  private
  public
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

  TglvgGroup = class
  private
  protected
    FClipShape: TglvgObject;
    FElements: array of TglvgObject;
    FNumElements: integer;
    function  GetElement(Index: Integer): TglvgObject;
    procedure SetElement(Index: Integer; Value: TglvgObject);
  public
    Constructor Create();
    Destructor Destroy(); override;
    procedure AddElement(AElement: TglvgObject);
    procedure Render;
    property Count: integer read FNumElements;
    property ClipShape: TglvgObject read FClipShape write FClipShape;
    property Element[index: integer]: TglvgObject read GetElement write SetElement;
  published
  end;

  TglvgPattern = class(TglvgGroup)
  private
  protected
    FWidth: single;
    FHeight: single;
  public
    procedure TileRender(bbmin: TPolygonPoint; bbmax: TPolygonPoint);
    property Width: single read FWidth write FWidth;
    property Height: single read FHeight write FHeight;
  end;

implementation

uses math, sysutils;


//TPolygonShape

constructor TPolygonShape.Create();
begin
  inherited Create();
  FcPath := TPath.Create;
  FcPath.Text:='';
  FStyle := TStyle.Create;
end;

destructor TPolygonShape.Destroy();
begin
  FcPath.Free;
  FStyle.Free;
  inherited Destroy();
end;

procedure TPolygonShape.RenderPath();
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

procedure TPolygonShape.Render();
begin

  if FStyle.FillType <> glvgNone then //no need to tesselate something that is not shown
  begin
    if (FStyle.FillType = glvgSolid) then //do not use stencil with flat fills
    begin
      glColor4f(self.FStyle.Color.r,self.FStyle.Color.g,self.FStyle.Color.b,self.FStyle.Color.a);
      inherited render;
    end
    else
    begin
      if fid=0 then fid := random(254); //quick hack to make stencil work
      //turning off writing to the color buffer and depth buffer so we only
      //write to stencil buffer
      glColorMask(FALSE, FALSE, FALSE, FALSE);
      //enable stencil buffer
      glEnable(GL_STENCIL_TEST);
      //write a one to the stencil buffer everywhere we are about to draw
      glStencilFunc(GL_ALWAYS, fid, 255);
      //this is to always pass a one to the stencil buffer where we draw
      glStencilOp(GL_REPLACE, GL_REPLACE, GL_REPLACE);
      Inherited Render();
      //until stencil test is diabled, only write to areas where the
      //stencil buffer has a one. This fills the shape
      glStencilFunc(GL_EQUAL, fid, 255);
      // don't modify the contents of the stencil buffer
      glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
      //draw colors again
      glColorMask(TRUE,TRUE, TRUE, TRUE);
      //draw fill
      fStyle.DrawFill(fBoundBoxRadius,fboundboxminpoint,fboundboxmaxpoint);
      //'default' rendering again
      glColorMask(TRUE,TRUE, TRUE, TRUE);
      glDisable(GL_STENCIL_TEST);
    end;
  end;
end;

procedure TPolygonShape.Render(parentvalue, parentmask: integer);
begin
  if FStyle.FillType <> glvgNone then //no need to tesselate something that is not shown
  begin
    if (FStyle.FillType = glvgSolid) then //do not use stencil with flat fills
    begin
      glColor4f(self.FStyle.Color.r,self.FStyle.Color.g,self.FStyle.Color.b,self.FStyle.Color.a);
      inherited render;
    end
    else
    begin
      //Set to update stencil-buffer with value, when test succeeds
      glStencilOp( gl_keep, gl_keep, gl_replace);
      //Constrain stencil rendering to be within parent, but "value" will be written
      glStencilFunc( gl_equal, fid, parentmask);
      inherited Render;
      //Limit further rendering to be within stenciled area...
      //including children!
      glStencilFunc( gl_equal, fid, fmask);
      //draw fill
      fStyle.DrawFill(fBoundBoxRadius,fboundboxminpoint,fboundboxmaxpoint);
      // Restore stencil state to that of parent
      glStencilFunc( gl_equal, parentvalue, parentmask);
    end;
  end;
end;

function TPolygonShape.GetPathText: string;
begin
  result := FcPath.Text;
end;

procedure TPolygonShape.SetPathText(AValue: string);
var
  i: integer;
begin
  FcPath.Text := AValue;
  if FcPath.Text <> '' then
  begin
    //clean up current content
    self.FCount:=0;
    setlength(self.FPoints,0);
    //determine new content
    FcPath.Parse;
    for i := 0 to FcPath.Count-1 do
    begin
      self.Add(FcPath.Points[i].x, FcPath.Points[i].y);
    end;
    //tesselate non convex shapes
    if not self.IsConvex() then
    begin
      Tesselate();
    end;
  end;
end;


//TglvgObject

constructor TglvgObject.Create();
begin
  inherited create();
  FPolyShape:= TPolygonShape.Create;
end;

destructor TglvgObject.Destroy;
begin
  FPolyShape.Free;
  inherited Destroy;
end;

procedure TglvgObject.Init;
begin
  FPolyShape.CalculateBoundBox();
  if FPolyShape.Style.NumGradColors >=2 then
  begin
    if FPolyShape.Style.FGradColors[0].x = -1.0 then
    FPolyShape.Style.FGradColors[0].x := FPolyShape.BoundBoxMinPoint.x;
    if FPolyShape.Style.FGradColors[1].x = -1.0 then
    FPolyShape.Style.FGradColors[1].x := FPolyShape.BoundBoxMaxPoint.x;
  end;
end;

procedure TglvgObject.CleanUp;
begin
  //Ok Clean Up for a high speed gain ...
  FPolyShape.FcPath.Free;
  FPolyShape.FcPath := TPath.Create;
  FpolyShape.CleanUp();
end;

procedure TglvgObject.Render;
begin
  FPolyShape.Render;
  FPolyShape.RenderPath;
end;

procedure TglvgObject.SetStyle(AValue: TStyle);
begin
  FPolyShape.Style := AValue;
end;

function TglvgObject.GetStyle(): TStyle;
begin
  result := self.FPolyShape.Style;
end;


//TglvgPolyLine

procedure TglvgPolyline.Render();
begin
  self.Polygon.RenderPath();
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
  if (Frx = 0) and (Fry = 0) then
    begin
      //simple rectangle with no rounded corners.
      FPolyShape.Path :=
      'M '+FloatToStr(Fx)+' '+FloatToStr(Fy)+
      ' L '+FloatToStr(Fx)+' '+FloatToStr(Fy+FHeight)+
      ' L '+FloatToStr(Fx+FWidth)+' '+FloatToStr(Fy+FHeight)+
      ' L '+FloatToStr(Fx+FWidth)+' '+FloatToStr(Fy) +
      ' Z';
    end
  else
    begin
      //rectangle with rounded corners
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
    end;

  with FPolyShape.Origin do
    begin
     x := Fx;
     y := Fy;
    end;

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
const
  KAPPA90: single = 0.5522847493; // Length proportional to radius of a cubic bezier handle for 90deg arcs.
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

  //draw circle as bezier
  //http://www.whizkidtech.redprince.net/bezier/circle/kappa/
        FPolyShape.Path := 'M ' +FloatToStr(fx-rx) + ' ' + FloatToStr(fy) +
		' C ' + FloatToStr(fx-rx) + ' ' + FloatToStr(fy+ry*KAPPA90) + ' ' + FloatToStr(fx-rx*KAPPA90) + ' ' + FloatToStr(fy+ry) + ' ' + FloatToStr(fx) + ' ' + FloatToStr(fy+ry) +
		' C ' + FloatToStr(fx+rx*KAPPA90) + ' ' + FloatToStr(fy+ry) + ' ' + FloatToStr(fx+rx) + ' ' + FloatToStr(fy+ry*KAPPA90) + ' ' + FloatToStr(fx+rx) + ' ' + FloatToStr(fy) +
		' C ' + FloatToStr(fx+rx) + ' ' + FloatToStr(fy-ry*KAPPA90) + ' ' + FloatToStr(fx+rx*KAPPA90) + ' ' + FloatToStr(fy-ry) + ' ' + FloatToStr(fx) + ' ' + FloatToStr(fy-ry) +
		' C ' + FloatToStr(fx-rx*KAPPA90) + ' ' + FloatToStr(fy-ry) + ' ' + FloatToStr(fx-rx) + ' ' + FloatToStr(fy-ry*KAPPA90) + ' ' + FloatToStr(fx-rx) + ' ' + FloatToStr(fy) +
		' Z';

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

procedure TPath.NewStroke( AFrom, ATo: TPolygonPoint );
begin
  AddPoint(AFrom);
  AddPoint(ATo);
end;

function TPath.EqualPoints( APoint1, APoint2: TPolygonPoint ): boolean;
begin
  Result := (APoint1.X = APoint2.X) and (APoint1.Y = APoint2.Y);
end;

procedure TPath.DrawCSpline( AFrom, ATo, AFromControlPoint, AToControlPoint: TPolygonPoint );
var
  di, i : Double;
  p1, p2: TPolygonPoint;
begin
  //cubic bezier line ( (1-i)^3*pa+3*i(1-i)^2*pb+3*i^2*(1-i)*pc+i^3*pd  )
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

procedure TPath.DrawQSpline( AFrom, ATo, AControlPoint: TPolygonPoint );
var
  di, i: double;
  p1,p2: TPolygonPoint;
begin
  //quadratic bezier line ( (1-i)^2*pa+2*i(1-i)*pb+i^2*pc )
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

procedure TPath.AddPoint(AValue: TPolygonPoint);
begin
  FCount := FCount + 1;
  SetLength(FPoints, FCount);
  FPoints[FCount-1].X := AValue.X;
  FPoints[FCount-1].Y := AValue.Y;
  FPoints[FCount-1].Z := AValue.Z;
end;

procedure TPath.SeTPolygonPoint(I: integer; AValue: TPolygonPoint);
begin
  FPoints[I] := AValue;
end;

function TPath.GeTPolygonPoint(I: integer): TPolygonPoint;
begin
  result := FPoints[I];
end;

constructor TPath.Create();
begin
  FCount:= 0;
  FSplinePrecision := 25; //the higher the value the more smoothnes
end;

destructor  TPath.Destroy();
begin
 inherited Destroy;
end;

procedure TPath.Parse();
var
  MyParser: TParser; //https://www.freepascal.org/docs-html/rtl/classes/tparser.html
  MS: TMemoryStream;
  str: string;
  CurToken: char;
  CurCommand: char;
  PrevCommand: char;
  Params: array[0..7] of single;
  ParamsPoint: array[0..2] of TPolygonPoint;
  ParamCount: byte;
  CurPoint: TPolygonPoint;
  PrevControlPoint: TPolygonPoint;
  FirsTPolygonPoint: TPolygonPoint;

begin
  //clean up eventual old path
  self.FCount:=0;
  setLength(self.FPoints,0);

  //begin parsing the new path
  paramcount := 0;
  CurCommand := '-';

  //parse string (remove linebreaks etc
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
          FirsTPolygonPoint := CurPoint;
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
          FirsTPolygonPoint := CurPoint;
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
        NewStroke( CurPoint, FirsTPolygonPoint);
        FirsTPolygonPoint:=CurPoint; //optional?
      End;
      'z':
      Begin
        //line back to the first point
        NewStroke( CurPoint, FirsTPolygonPoint);
        FirsTPolygonPoint:=CurPoint; //optional?
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
        end;
      end;
    end;

    PrevCommand:=CurCommand;
    curtoken := MyParser.NextToken;
  end;

  MyParser.Free();
  MS.Free();
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
  var
    RetVar : Int64;
    i : byte;
  begin
    HexStr := UpperCase(HexStr);
    if HexStr[length(HexStr)] = 'H' then
     Delete(HexStr,length(HexStr),1);
    RetVar := 0;

    for i := 1 to length(HexStr) do
      begin
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
  end;
end;


//TStyle

constructor TStyle.Create;
begin
  inherited Create;

  FPattern := TglvgPattern.Create;
  FColor := TColor.Create;
  FLineColor := TColor.Create;
  FFillType := glvgnone;
  FLineType := glvgsolid;
  FColor.SetColor(1.0,0,0,1.0);     //first set color etc
  FLineWidth := 1.0;
  FLineColor.SetColor(1,1,1,1);
  FGradColorAngle := 0;
  ftexture := TglBitmap2D.Create;
end;

destructor TStyle.Destroy;
begin
  FPattern.Free;
  FColor.Free;
  FLineColor.Free;
  FTexture.Free;
end;

function TStyle.TrigGLTriangle(value: single): single;
const
  TRIG_FUNCTABLE_SIZE: integer = 1024;
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

function TStyle.CalcGradColor(xpos: single; ypos: single; gradbegincolor: TPolygonPoint; gradendcolor: TPolygonPoint;gradx1: single; grady1: single; gradx2: single; grady2: single; gradangle: single): TPolygonPoint;
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

procedure TStyle.Init;
begin
  ftexture.LoadFromFile(ftexturefilename);
  ftexture.GenTexture; //upload to video card.
  ftextureid := ftexture.ID;
end;

procedure TStyle.DrawBox(x: Single; y: Single; colorfrom: TColor; colorto: TColor);
var
  range: TPolygonPoint;
  offset: TPolygonPoint;
  fx,fy,tx,ty,ts,tt,fs,ft: single;
begin
  //caclulate st coords
  range.x := (FTexture.Width);
  range.y := (FTexture.Height);
  offset.x := 0 + x;
  offset.y := 0 + y;
  fx:=colorfrom.x;
  fy:=colorfrom.y;
  tx:=colorto.x;
  ty:=colorto.y;
  fs := (fx-offset.x) / range.x;
  ft := (fy-offset.y) / range.y;
  ts := (tx-offset.x) / range.x;
  tt := (ty-offset.y) / range.y;
  //draw filled boundingbox using triangles
  glBegin(GL_TRIANGLES);
    glTexCoord2f(fs, ft);
    glcolor4f(colorfrom.r,colorfrom.g,colorfrom.b,colorfrom.a);
    glVertex3f(fx, fy, 0.0);
    glTexCoord2f(ts, ft);
    glcolor4f(colorto.r,colorto.g,colorto.b,colorto.a);
    glVertex3f(tx, fy, 0.0);
    glTexCoord2f(ts, tt);
    glcolor4f(colorto.r,colorto.g,colorto.b,colorto.a);
    glVertex3f(tx, ty, 0.0);
    glTexCoord2f(ts, tt);
    glcolor4f(colorto.r,colorto.g,colorto.b,colorto.a);
    glVertex3f(tx, ty, 0.0);
    glTexCoord2f(fs, tt);
    glcolor4f(colorfrom.r,colorfrom.g,colorfrom.b,colorfrom.a);
    glVertex3f(fx, ty, 0.0);
    glTexCoord2f(fs, ft);
    glcolor4f(colorfrom.r,colorfrom.g,colorfrom.b,colorfrom.a);
    glVertex3f(fx, fy, 0.0);
  glEnd();
end;

procedure TStyle.DrawCircle(x: single;y: single; colorfrom: tcolor; colorto: tcolor);
var
  y1: single;
  x1: single;
  y2: single;
  x2: single;
  angle: single;
  i: integer;
  radius: single;
  segments:integer;
begin
  segments:=80;
  radius := colorfrom.x - colorto.x;
  y1:=y;
  x1:=x;
  glBegin(GL_TRIANGLES);
    for i:=0 to Segments do
      begin
        angle:=i * 2* PI / Segments;
        x2:=x+(radius*sin(angle));
        y2:=y+(radius*cos(angle));
        glcolor4f(colorfrom.r,colorfrom.g,colorfrom.b,colorfrom.a); //inner
        glVertex2d(x,y);
        glcolor4f(colorto.r,colorto.g,colorto.b,colorto.a); //outer
        glVertex2d(x1,y1);
        glVertex2d(x2,y2);
        y1:=y2;
        x1:=x2;
      end;
  glEnd();
end;

procedure TStyle.DrawRing(x: single;y: single; colorfrom: tcolor; colorto: tcolor);
var
  p  : Integer;
  t  : Single;
  a  : Single;
  r2 : Single;
  r1 : Single;
  ex : Single;
  ey : Single;
  MinRadius: single;
  MaxRadius: single;
  Segments: integer;
begin
  MinRadius:= (x - colorfrom.x) * -1;
  MaxRadius:= (colorfrom.x - colorto.x) * -1;
  segments := 80;
  if Time < 0 then Exit;
  t := 1;//Time / TTL;
  r2 := MinRadius + MaxRadius * (1- t);
  r1 := r2 + MaxRadius;
  if r1 < 0 then r1 := 0;
  glPushMatrix;
    glTranslatef(x,y,0);
    glBegin(GL_TRIANGLE_STRIP);
      for p := 0 to Segments do
        begin
          a := p * 2* PI / Segments;
          ex := Cos(a);
          ey := Sin(a);
          // inner ring edge
          glcolor4f(colorfrom.r,colorfrom.g,colorfrom.b,colorfrom.a);
          glVertex3f(r2 * ex,r2 * ey,0);
          // outer ring edge
          glcolor4f(colorto.r,colorto.g,colorto.b,colorto.a);
          glVertex3f(r1 * ex,r1 * ey,0);
        end;
    glEnd;
  glPopMatrix;
end;

procedure TStyle.DrawFill(radius: single; aboundboxminpoint: TPolygonPoint; aboundboxmaxpoint: TPolygonPoint);
var
  i:integer;
  addcolor: TColor;
  cp: TPolygonPoint;
  mpmin,mpmax: TPolygonPoint;
  roTPolygonPoint: TPolygonPoint;
  curpoint: TPolygonPoint;
  temp: TPolygonPoint;
  //curpoint2: TPolygonPoint;
  colorfrom, colorto: tcolor;

  function RotatePoint(pPoint: TPolygonPoint; pOrigin: TPolygonPoint; Degrees: Single): TPolygonPoint;
  var
    cosAng : single;
    sinAng : single;
    x: single;
    y: single;
  begin
    x := ppoint.X - porigin.X;
    y := ppoint.Y - porigin.Y;
    cosAng := cos(DegToRad(Degrees));
    sinAng := sin(DegToRad(Degrees));
    RotatePoint.X := (x * cosAng) + (y * sinAng) + porigin.X;
    RotatePoint.Y := (x * sinAng) + (y * cosAng) + porigin.Y;
  end;

begin
  colorfrom := tcolor.Create;
  colorto := tcolor.Create;

  if FillType = glvgPattern then
  begin
    glPushAttrib(GL_STENCIL_BUFFER_BIT);
    FPattern.TileRender(aboundboxminpoint,aboundboxmaxpoint);
    glClear(GL_STENCIL_BUFFER_BIT);
    glPopAttrib();
  end;

  if FillType = glvgTexture then
  begin
    FTexture.Bind();
    //experimental texture matrix (rotating around center)
    glMatrixMode(GL_TEXTURE);
    glLoadIdentity();
    glTranslatef(0.5,0.5,0.0); //no need to know the size of the texture
    glRotatef(FTextureAngle,0.0,0.0,1.0);
    glTranslatef(-0.5,-0.5,0.0);
    glMatrixMode(GL_MODELVIEW);
    glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S,
                     GL_REPEAT  );
    glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T,
                     GL_REPEAT );
    FColor.x:=ABoundBoxMinPoint.x;
    FColor.y:=ABoundBoxMinPoint.y;
    AddColor:=TColor.Create;
    AddColor.x:=ABoundBoxMaxPoint.x;
    AddColor.y:=ABoundBoxMaxPoint.y;
    AddColor.r:=FColor.r;
    AddColor.g:=FColor.g;
    AddColor.b:=FColor.b;
    AddColor.a:=FColor.a;
    DrawBox(ABoundBoxMinPoint.x, ABoundBoxMinPoint.y, FColor, AddColor);
    AddColor.Free;
    FTexture.UnBind();
  end;

  if FFillType = glvgSolid then
  begin
    FColor.x:=ABoundBoxMinPoint.x;
    FColor.y:=ABoundBoxMinPoint.y;
    AddColor:=TColor.Create;
    AddColor.x:=ABoundBoxMaxPoint.x;
    AddColor.y:=ABoundBoxMaxPoint.y;
    AddColor.r:=FColor.r;
    AddColor.g:=FColor.g;
    AddColor.b:=FColor.b;
    AddColor.a:=FColor.a;
    DrawBox(FColor.x, FColor.y, FColor, AddColor);
    AddColor.Free;
  end;

  if FFillType = glvgLinearGradient then
  begin
    cp.x:=((ABoundBoxMaxPoint.x-ABoundBoxMinPoint.x)/2);
    cp.y:=((ABoundBoxMaxPoint.y-ABoundBoxMinPoint.y)/2);
    roTPolygonPoint:=cp;
    mpmin.x:=0;
    mpmin.y:=0;
    mpmin.z:=0;
    mpmin.r:=0;
    mpmin.g:=0;
    mpmin.b:=0;
    mpmin.a:=0;
    mpmax.x:=0;
    mpmax.y:=0;
    mpmax.z:=0;
    mpmax.r:=0;
    mpmax.g:=0;
    mpmax.b:=0;
    mpmax.a:=0;
    roTPolygonPoint.x:=0+(aboundboxminpoint.x+cp.x);
    roTPolygonPoint.y:=0+(aboundboxminpoint.y+cp.y);
    temp.x:=ABoundBoxMinPoint.x;
    temp.y:=ABoundBoxMinPoint.y;
    mpmin:=RotatePoint(temp, roTPolygonPoint, FGradColorAngle);
    temp.x:=ABoundBoxMaxPoint.x;
    temp.y:=ABoundBoxMaxPoint.y;
    mpmax:=RotatePoint(temp, roTPolygonPoint, FGradColorAngle);
    temp.x:=cp.x;
    temp.y:=cp.y;
    temp.x:=FGradColors[0].x;
    temp.y:=FGradColors[0].y;
    curpoint.x:=RotatePoint(temp, roTPolygonPoint, FGradColorAngle).x;
    curpoint.y:=RotatePoint(temp, roTPolygonPoint, FGradColorAngle).y;
    glpushmatrix;
      if FGradColorAngle > 0  then
      begin
        gltranslatef(+cp.x, +cp.y,0);
        gltranslatef(+ABoundBoxMinPoint.x,+ABoundBoxMinPoint.y,0);
        glrotatef(FGradColorAngle,0,0,1);
        gltranslatef(-ABoundBoxMinPoint.x,-ABoundBoxMinPoint.y,0);
        gltranslatef(-cp.x, -cp.y,0);
      end;
      //extend (clamping)
      addcolor := TColor.Create;
      addcolor.x := mpmin.x;
      addcolor.y := mpmin.y;
      addcolor.r := FGradColors[0].r;
      addcolor.g := FGradColors[0].g;
      addcolor.b := FGradColors[0].b;
      addcolor.a := FGradColors[0].a;
      temp.x:=FGradColors[0].x;
      temp.y:=ABoundBoxMaxPoint.y;
      curpoint.x:=RotatePoint(temp, roTPolygonPoint, FGradColorAngle).x;
      curpoint.y:=RotatePoint(temp, roTPolygonPoint, FGradColorAngle).y;
      //adjust only the 'first' x cooord (only a cosmetic fix)
      colorto.x:=mpmin.x+temp.x-ABoundBoxMinPoint.x;
      colorto.y:=mpmax.y;
      colorto.r:=FGradColors[0].r;
      colorto.g:=FGradColors[0].g;
      colorto.b:=FGradColors[0].b;
      colorto.a:=FGradColors[0].a;
      DrawBox(curpoint.x, curpoint.y, AddColor, colorto);
      AddColor.Free;
      //draw 2 color gradient fill
      if fNumGradColors >= 2 then
      begin
        temp.x:=FGradColors[0].x;
        temp.y:=ABoundBoxMinPoint.y;
        curpoint.x:=RotatePoint(temp, roTPolygonPoint, FGradColorAngle).x;
        curpoint.y:=RotatePoint(temp, roTPolygonPoint, FGradColorAngle).y;
        //adjust only the 'first' x cooord (only a cosmetic fix)
        colorfrom.x:=mpmin.x+temp.x-ABoundBoxMinPoint.x;
        colorfrom.y:=mpmin.y;
        colorfrom.r:=FGradColors[0].r;
        colorfrom.g:=FGradColors[0].g;
        colorfrom.b:=FGradColors[0].b;
        colorfrom.a:=FGradColors[0].a;
        temp.x:=FGradColors[1].x;
        temp.y:=ABoundBoxMaxPoint.y;
        curpoint.x:=RotatePoint(temp, roTPolygonPoint, FGradColorAngle).x;
        curpoint.y:=RotatePoint(temp, roTPolygonPoint, FGradColorAngle).y;
        colorto.x:=mpmin.x+temp.x-ABoundBoxMinPoint.x;
        colorto.y:=mpmax.y;
        colorto.r:=FGradColors[1].r;
        colorto.g:=FGradColors[1].g;
        colorto.b:=FGradColors[1].b;
        colorto.a:=FGradColors[1].a;
        temp.x:=FGradColors[0].x;
        temp.y:=FGradColors[0].y;
        curpoint.x:=RotatePoint(temp, roTPolygonPoint, FGradColorAngle).x;
        curpoint.y:=RotatePoint(temp, roTPolygonPoint, FGradColorAngle).y;
        DrawBox(curpoint.x, curpoint.y, colorfrom, colorto);
      end;
      //draw additional 2 color gradient fills
      if fNumGradColors >=3 then
      begin
        for i := 2 to fNumGradColors - 1 do
          begin
            temp.x:=FGradColors[i-1].x;
            temp.y:=ABoundBoxMinPoint.y;
            curpoint.x:=RotatePoint(temp, roTPolygonPoint, FGradColorAngle).x;
            curpoint.y:=RotatePoint(temp, roTPolygonPoint, FGradColorAngle).y;
            colorfrom.x:=mpmin.x+temp.x-ABoundBoxMinPoint.x;
            colorfrom.y:=mpmin.y;
            colorfrom.r:=FGradColors[i-1].r;
            colorfrom.g:=FGradColors[i-1].g;
            colorfrom.b:=FGradColors[i-1].b;
            colorfrom.a:=FGradColors[i-1].a;
            temp.x:=FGradColors[i].x;
            temp.y:=ABoundBoxMaxPoint.y;
            curpoint.x:=RotatePoint(temp, roTPolygonPoint, FGradColorAngle).x;
            curpoint.y:=RotatePoint(temp, roTPolygonPoint, FGradColorAngle).y;
            colorto.x:=mpmin.x+temp.x-ABoundBoxMinPoint.x;
            colorto.y:=mpmax.y;
            colorto.r:=FGradColors[i].r;
            colorto.g:=FGradColors[i].g;
            colorto.b:=FGradColors[i].b;
            colorto.a:=FGradColors[i].a;
            temp.x:=FGradColors[i-1].x;
            temp.y:=FGradColors[i-1].y;
            curpoint.x:=RotatePoint(temp, roTPolygonPoint, FGradColorAngle).x;
            curpoint.y:=RotatePoint(temp, roTPolygonPoint, FGradColorAngle).y;
            DrawBox(curpoint.x, curpoint.y, colorfrom, colorto);
          end;
      end;
      //extend (clamping)
      addcolor := TColor.Create;
      addcolor.x := mpmax.x;
      addcolor.y := mpmax.y;
      addcolor.r := FGradColors[fNumGradColors-1].r;
      addcolor.g := FGradColors[fNumGradColors-1].g;
      addcolor.b := FGradColors[fNumGradColors-1].b;
      addcolor.a := FGradColors[fNumGradColors-1].a;
      temp.x:=FGradColors[fNumGradColors-1].x;
      temp.y:=ABoundBoxMinPoint.y;
      curpoint.x:=RotatePoint(temp, roTPolygonPoint, FGradColorAngle).x;
      curpoint.y:=RotatePoint(temp, roTPolygonPoint, FGradColorAngle).y;
      colorfrom.x:=mpmin.x+temp.x-ABoundBoxMinPoint.x;
      colorfrom.y:=mpmin.y;
      colorfrom.r:=FGradColors[fNumGradColors-1].r;
      colorfrom.g:=FGradColors[fNumGradColors-1].g;
      colorfrom.b:=FGradColors[fNumGradColors-1].b;
      colorfrom.a:=FGradColors[fNumGradColors-1].a;
      DrawBox(curpoint.x, curpoint.y, colorfrom, AddColor);
      AddColor.Free;
    //go back to origin
    glpopmatrix;
  end;

  if FFillType = glvgCircularGradient then
  begin
    if fNumGradColors >= 2 then
      DrawCircle(FGradColors[0].x, FGradColors[0].y,FGradColors[0],FGradColors[1]);
    if fNumGradColors >=3 then
    begin
      for i := 2 to fNumGradColors - 1 do
        DrawRing(FGradColors[0].x, FGradColors[0].y,FGradColors[i-1],FGradColors[i]);
    end;
    //extend (clamping)
    if (FGradColors[fNumGradColors-1].x) < (radius*2) then
    begin
      addcolor := TColor.Create;
      addcolor.x := radius * 2; //just to be sure it is large enough
      addcolor.r := FGradColors[fNumGradColors-1].r;
      addcolor.g := FGradColors[fNumGradColors-1].g;
      addcolor.b := FGradColors[fNumGradColors-1].b;
      addcolor.a := FColor.a;
      DrawRing(FGradColors[0].x, FGradColors[0].y,FGradColors[fNumGradColors-1],AddColor);
      AddColor.Free;
    end;
  end;

  colorfrom.Free;
  colorto.Free;
end;

procedure TStyle.SetNumGradColors(AValue: integer);
var
  i: integer;
begin
  if AValue > FNumGradColors then
  begin
    SetLength(FGradColors, AValue);
    for i := FNumGradColors to AValue - 1 do
    begin
      FGradColors[i] := TColor.Create;
      FGradColors[i].r:=FColor.r;
      FGradColors[i].g:=FColor.g;
      FGradColors[i].b:=FColor.b;
      FGradColors[i].a:=FColor.a;
    end;
    FNumGradColors:=AValue;
  end;
end;

procedure TStyle.SetGradColor(Index: Integer; AValue: TColor);
begin
  self.FGradColors[Index] := AValue;
end;

function TStyle.GetGradColor(Index: Integer): TColor;
begin
  if FNumGradColors>=Index then
    result := self.FGradColors[Index];
end;


//TPolygonFont

procedure TPolygonFont.SetSize(AValue: Single);
var
  frs: single; //font render size
  upm: single; //units per em
begin
  //this calculation asumes 1 unit is 1px so glortho has to be setup alike
  fsize:=avalue;
  frs := (fsize/(72))*100; //assume dpi of 72
  upm := 1000; //units per em for the font
  scale := frs/upm;
end;

procedure TPolygonFont.RenderChar(AValue: char);
begin
  glpushmatrix();
    glscalef(FSCALE,-FSCALE,0);
    gltranslatef(0,-FFontHeight  ,0);
    FCharGlyph[ord(AValue)].Render;
  glpopmatrix();
  glTranslatef((FCharWidth[ord(AValue)]*FSCALE), 0, 0);
  if AValue = ' ' then
  begin
    gltranslatef(fsize/2,0,0); //TODO: properly detemine width of space character
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

function TPolygonFont.GetStringWidth(AValue: string): Single;
var
  i: integer;
begin
  result:=0;
  for i:=1 to length(AValue) do
  begin
    if avalue[i]=' ' then
      result:=result+fsize/2
    else
      result:=result+FCharWidth[ord(AValue[i])]*FSCALE;
  end;
end;

procedure TPolygonFont.LoadFromFile(AValue: string);
var
  loop: integer;
  fs: TStringList;
begin
  FFontHeight := 0.0;
  fs := TStringList.Create;
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
      FCharWidth[loop] := Round(FCharGlyph[loop].FPolyShape.BoundBoxMaxPoint.x);
      //determine highest character size.
      if FFontHeight < FCharGlyph[loop].FPolyShape.BoundBoxMaxPoint.y then
        FFontHeight := FCharGlyph[loop].FPolyShape.BoundBoxMaxPoint.y;
      FCharGlyph[loop].FPolyShape.Id:=10; //TODO: should not be set manually
      FCharGlyph[loop].Init;
    end;
  end;
  for loop := 0 to 255 do
  begin
    if ( (loop >= ord('A')) and (loop <= ord('Z')) ) or ( (loop >= ord('a')) and (loop <= ord('z')) ) or ( (loop >= ord('0')) and (loop <= ord('9')) )then
    begin
      with FCharGlyph[loop].FPolyShape.BoundBoxMaxPoint do
        y:=FFontHeight;
      FCharGlyph[loop].Init;
    end;
  end;
  fs.Free;
end;


//TglvgGroup

constructor TglvgGroup.Create;
begin
  inherited Create;
  FNumElements:=0;
end;

destructor TglvgGroup.Destroy;
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

procedure TglvgGroup.AddElement(AElement: TglvgObject);
begin
  FNumElements:=FNumElements+1;
  SetLength(FElements,FNumElements);
  FElements[FNumElements-1] := AElement;
  FElements[FNumElements-1].FPolyShape.Id :=FNumElements;
end;

function  TglvgGroup.GetElement(Index: Integer): TglvgObject;
begin
  result := fElements[Index];
end;

procedure TglvgGroup.SetElement(Index: Integer; Value: TglvgObject);
begin
  fElements[Index] := Value;
end;

procedure TglvgGroup.Render;
var
  i: integer;
begin
  for i:=0 to FNumElements-1 do
  begin
    FElements[i].Render;
  end;
end;


//TglvgPattern

procedure TglvgPattern.TileRender(bbmin: TPolygonPoint; bbmax: TPolygonPoint);
var
  xpos,ypos: single;
begin
  //TODO: bring back support for display lists
  if (width>0) or (height >0) then
  begin
    xpos:=bbmin.x;
    ypos:=bbmin.y;
    glpushmatrix();
    gltranslatef(xpos, ypos, 0);
    repeat
      glpushmatrix();
      repeat
        self.Render;
        xpos:=xpos+fwidth;
        gltranslatef(fwidth, 0, 0);
      until (xpos>=bbmax.x);
      glpopmatrix();
      xpos:=bbmin.x;
      ypos:=ypos+fheight;
      gltranslatef(0, fheight, 0);
    until (ypos>=bbmax.y);
    glpopmatrix();
  end;
end;

end.
