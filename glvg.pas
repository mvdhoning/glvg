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
    procedure DrawArc( AFrom: TPolygonPoint; ARadius: TPolygonPoint; AXrot: single; ALargeArcFlag: boolean; ASweepFlag: boolean; ATo: TPolygonPoint);
    procedure AddPoint(AValue: TPolygonPoint);
    procedure SetPolygonPoint(I: integer; AValue: TPolygonPoint);
    function GetPolygonPoint(I: integer): TPolygonPoint;
  public
    constructor Create();
    destructor Destroy(); override;
    procedure Parse();
    property Points[I: integer]: TPolygonPoint read GetPolygonPoint write SetPolygonPoint;
    property Text: ansistring read fcommandtext write fcommandtext;
    property Count: integer read FCount;
  end;

  //https://www.w3.org/TR/SVG11/coords.html#TransformAttribute
  TglvgTransformType = (glvgMatrix, glvgTranslate, glvgScale, glvgRotate, glvgSkewX, glvgSkewY);

  TTransformStep = class
  private
    fa: single;
    fb: single;
    fc: single;
    fd: single;
    fe: single;
    ff: single;
    fangle: single;
    fx: single;
    fy: single;
    ftype: TglvgTransformType;
  public
    constructor Create();
    destructor Destroy(); override;
    procedure Apply();
    property x: single read fx write fx;
    property y: single read fy write fy;
    property angle: single read fangle write fangle;
    property a: single read fa write fa;
    property b: single read fb write fb;
    property c: single read fc write fc;
    property d: single read fd write fd;
    property e: single read fe write fe;
    property f: single read ff write ff;
    property transformType: TglvgTransformType read ftype write ftype;
  end;

  TTransform = class
  private
    FCommandText: ansistring;
    FTransformations: array of TTransformStep;
    procedure SetTransformStep(I: integer; AValue: TTransformStep);
    function GetTransformStep(I: integer): TTransformStep;
  public
    constructor Create(); overload;
    constructor Create(AValue: string); overload;
    destructor Destroy(); override;
    procedure Parse();
    procedure Apply();
    property Steps[I: integer]: TTransformStep read GetTransformStep write SetTransformStep;
    property Text: ansistring read fcommandtext write fcommandtext;
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
    Fx: Single;
    Fy: Single;
    FPolyShape: TPolygonShape;
    FName: string;
    FTransform: TTransform; //Transformations
    procedure SetStyle(AValue: TStyle);
    function GetStyle(): TStyle;
  public
    Constructor Create();
    Destructor Destroy(); override;
    procedure Init; virtual;
    procedure CleanUp; virtual;
    procedure Render; virtual;
    property X: single read Fx write Fx;
    property Y: single read Fy write Fy;
    property name: string read fname write fname;
    property Style: TStyle read GetStyle write SetStyle;
    property Polygon: TPolygonShape read FPolyshape write FPolyshape;
    property Transform: TTransform read FTransform write FTransform;
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
    //Fx: Single;
    //Fy: Single;
    Fwidth: Single;
    Fheight: Single;
    Frx: Single;
    Fry: Single;
  public
    Constructor Create();
    procedure Init; override;
    //property X: single read Fx write Fx;
    //property Y: single read Fy write Fy;
    property Width: single read Fwidth write Fwidth;
    property Height: single read Fheight write Fheight;
    property Rx: single read Frx write Frx;
    property Ry: single read Fry write Fry;
  end;

  TglvgElipse = class(TglvgObject)
  private
    //Fx: Single;
    //Fy: Single;
    Frx: Single;
    Fry: Single;
  public
    Constructor Create();
    procedure Init; override;
    //property X: single read Fx write Fx;
    //property Y: single read Fy write Fy;
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
    //Fx1: Single;
    //Fy1: Single;
    Fx2: Single;
    Fy2: Single;
  public
    Constructor Create();
    procedure Init; override;
    //property X1: single read Fx1 write Fx1;
    //property Y1: single read Fy1 write Fy1;
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
    //FX: single;
    //FY: single;
  public
    Constructor Create();
    Destructor Destroy(); override;
    procedure Render; override;
    //property X: single read Fx write Fx;
    //property Y: single read Fy write Fy;
    property Font: TPolygonFont read FFont write FFont;
    property Text: string read FText write FText;
    property Style: TStyle read FStyle write FStyle;
  end;

  TglvgGroup = class;

  TglvgGroup = class
  private
    Fid: integer;
    FTransform: TTransform;
  protected
    FClipPath: TglvgGroup;
    FElements: array of TglvgObject;
    FNumElements: integer;
    function  GetElement(Index: Integer): TglvgObject;
    procedure SetElement(Index: Integer; Value: TglvgObject);
  public
    Constructor Create();
    Destructor Destroy(); override;
    procedure AddElement(AElement: TglvgObject);
    procedure Render;
    property Id: integer read fid write fid;
    property Count: integer read FNumElements;
    property ClipPath: TglvgGroup read FClipPath write FClipPath;
    property Element[index: integer]: TglvgObject read GetElement write SetElement;
    property Transform: TTransform read FTransform write FTransform;
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
    //glEnable (GL_POLYGON_SMOOTH);
    glBegin(GL_LINES);
    for loop:=0 to fcpath.Count-1 do
    begin
      glVertex2f(fcpath.Points[loop].x, fcpath.Points[loop].y);
    end;
    glEnd();
    //glDisable (GL_POLYGON_SMOOTH);
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
  Fx:= 0.0;
  Fy:= 0.0;
  FTransform := nil;
end;

destructor TglvgObject.Destroy;
begin
  FreeAndNil(FTransform);
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
  if FTransform<>nil then
  begin
    glPushMatrix();
    FTransform.Apply();
  end;
  FPolyShape.Render;
  FPolyShape.RenderPath;
  if FTransform<>nil then
     glPopMatrix();
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
  //Fx1:= 0.0;
  //Fy1:= 0.0;
  Fx2:= 0.0;
  Fy2:= 0.0;
end;

procedure TglvgLine.Init;
begin
  //Ok Clean Up for a high speed gain ...
  self.CleanUp;

  FPolyShape.Path := 'M '+FloatToStr(Fx)+ ' '+FloatToStr(Fy)+
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

procedure TPath.DrawArc( AFrom: TPolygonPoint; ARadius: TPolygonPoint; AXrot: single; ALargeArcFlag: boolean; ASweepFlag: boolean; ATo: TPolygonPoint);
var
  FromPoint,ToPoint,ControlPoint, Center, Angles: TPolygonPoint;


  function VectorDot(const A, B : TPolygonPoint): Single;
  begin
    Result := 0;
    Result := Result + (A.x * B.x);
    Result := Result + (A.y * B.y);
  end;

  function VectorLength(const A: TPolygonPoint): double;
  begin
     Result:=0.0;
     Result:=Result + (A.x*A.x);
     Result:=Result + (A.y*A.y);
     Result:=sqrt(Result);
  end;

  //https://mortoray.com/2017/02/16/rendering-an-svg-elliptical-arc-as-bezier-curves/

  function svgAngle( ux, uy, vx, vy: single ): single;
  var
    u,v: TPolygonPoint;
    dot, len, ang: double;
  begin
      u.x:=ux;
      u.y:=uy;
      v.x:=vx;
      v.y:=vy;
      //(F.6.5.4)
      dot := VectorDot(u,v);
      len := VectorLength(u) * VectorLength(v);
      ang := ArcCos( EnsureRange(dot / len,-1,1) ); //floating point precision, slightly over values appear
      if ( ( (u.X*v.Y) - (u.Y*v.X) ) < 0) then
          ang := -ang;
      result := ang;
  end;

  (*
      Perform the endpoint to center arc parameter conversion as detailed in the SVG 1.1 spec.
      F.6.5 Conversion from endpoint to center parameterization

      @param r must be a ref in case it needs to be scaled up, as per the SVG spec
  *)
  procedure EndpointToCenterArcParams( p1: TPolygonPoint; p2:TPolygonPoint; radius: TPolygonPoint; xAngle: Single;
      flagA: boolean; flagS: boolean; out center: TPolygonPoint; out angles: TPolygonPoint ) ;
  var
    rx,ry, dx2, dy2, x1p, y1p, rxs, rys, x1ps, y1ps, cr, s, dq, pq, q, cxp, cyp, cx, cy, theta, delta: single;

    function RealMod(const a,b: single): single;
    begin
      result:= a-b * trunc(a/b);
    end;

  begin
      rX := Abs(radius.X);
      rY := Abs(radius.Y);

        writeln('xangle '+floattostr(xangle));
      //(F.6.5.1)
      dx2 := (p1.X - p2.X) / 2.0;
      dy2 := (p1.Y - p2.Y) / 2.0;
      x1p := Cos(xAngle)*dx2 + Sin(xAngle)*dy2;
      y1p := -Sin(xAngle)*dx2 + Cos(xAngle)*dy2;

      //(F.6.5.2)
      rxs := rX * rX;
      rys := rY * rY;
      x1ps := x1p * x1p;
      y1ps := y1p * y1p;
      // check if the radius is too small `pq < 0`, when `dq > rxs * rys` (see below)
      // cr is the ratio (dq : rxs * rys)
      cr := x1ps/rxs + y1ps/rys;
      if (cr > 1) then
        begin
          //scale up rX,rY equally so cr == 1
          s := Sqrt(cr);
          rX := s * rX;
          rY := s * rY;
          rxs := rX * rX;
          rys := rY * rY;
        end;
      dq := (rxs * y1ps + rys * x1ps);
      pq := (rxs*rys - dq) / dq;
      q := Sqrt( Max(0,pq) ); //use Max to account for float precision
      if (flagA = flagS) then
          q := -q;
      cxp := q * rX * y1p / rY;
      cyp := - q * rY * x1p / rX;

      //(F.6.5.3)
      cx := Cos(xAngle)*cxp - Sin(xAngle)*cyp + (p1.X + p2.X)/2;
      cy := Sin(xAngle)*cxp + Cos(xAngle)*cyp + (p1.Y + p2.Y)/2;

      //(F.6.5.5)
      theta := svgAngle( 1,0, (x1p-cxp) / rX, (y1p - cyp)/rY );

      //(F.6.5.6)
      delta := svgAngle(
          (x1p - cxp)/rX, (y1p - cyp)/rY,
          (-x1p - cxp)/rX, (-y1p-cyp)/rY);
             delta := delta+theta;
       //writeln('theta: '+floattostr(theta));
       //writeln('delta: '+floattostr(delta));
      //writeln('max: '+floattostr(degtorad(350)));
      //writeln('2*pi: '+floattostr(2*PI));

      delta := RealMod(delta, 2 * PI);
      //writeln('delta: '+floattostr(delta));
      //if (not flagS) then
      //   delta := (delta -  2 * PI);
      //      writeln('delta: '+floattostr(delta));

      radius.x := rX;
      radius.y := rY;
      center.x := cx;
      center.y := cy;
      angles.y := theta;
      angles.x := delta;
  end;

var da,hda,kappa: single;
   i,ndivs: integer;
   a,dx,dy, tanx,tany, px,py,ptany,ptanx: single;
   l,p,f,t: TPolygonPoint;
   txr: single;
begin
  //https://www.w3.org/TR/SVG/implnote.html#ArcImplementationNotes

  writeln('xrot '+floattostr(AXRot));
  txr:=AXRot;
  txr:=degtorad(AXRot);
  //Get Center
  EndpointToCenterArcParams( AFrom, ATo, Aradius, txr, ALargeArcFlag, ASweepFlag, center, angles);
  writeln('afrom '+floattostr(afrom.x)+', '+floattostr(afrom.y));
  //writeln('ato '+floattostr(ato.x)+', '+floattostr(ato.y));

  //center.x:=150;
  //center.y:=150;
  //writeln('center '+floattostr(center.x)+', '+floattostr(center.y));
  //writeln('radius '+floattostr(aradius.x)+', '+floattostr(aradius.y));
  //writeln('angles '+floattostr(angles.x)+', '+floattostr(angles.y));
  //writeln('angles '+floattostr(radtodeg(angles.x))+', '+floattostr(radtodeg(angles.y)));

  //angles.y := -0.004167;
  //angles.x := 1.051364;

  //angles.y := 1.043031;
  //angles.x := 2.098562;

  // Clamp Angles (do i need to take care of direction? yep ccw)
  //angles.y:=degtorad(-315);
  //angles.x:=15;
  //writeln('angles '+floattostr(angles.x)+', '+floattostr(angles.y));
  da := angles.y - angles.x;

  //TODO: use ASweepFlag
  if ASweepFlag then
  begin
    if (abs(da) >= pi*2) then
      da := -PI*2
    else
      while (da > 0.0) do da := da - PI*2;
  end
  else
  begin
    if (abs(da) >= PI*2) then
      da := PI*2
    else
      while (da < 0.0) do da := da +(PI*2);
  end;

  // Split arc into max 90 degree segments.
  ndivs := trunc( max(1, min((abs(da) / (pi*0.5) + 0.5), 5)));
  //constsegments = Math.max(Math.ceil(Math.abs(ang2) / (TAU / 4)), 1)
  hda := (da / ndivs) / 2.0;
  kappa := abs(4.0 / 3.0 * (1.0 - cos(hda)) / sin(hda) );
  if asweepflag then
     kappa:=-kappa;

  //writeln('ndivs '+floattostr(ndivs));
  //writeln('da '+floattostr(da));
  //writeln('da deg '+floattostr(radtodeg(da)));
  //writeln('hda '+floattostr(hda));
  //writeln('kappa '+floattostr(kappa));

  //NewStroke( AFrom, ATo); //from to debug line
  //NewStroke( ATo, Center); //to centern debug line

  for i := 0 to ndivs do
  begin
    a := angles.x + da * (i/ndivs);
    dx := cos(a);
    dy := sin(a);
    p.x := center.x + dx*ARadius.x;
    p.y := center.y + dy*ARadius.y;

    //if (p.x>ato.x) and (p.y>ato.y) then
    //  ato:=p;

    tanx := -dy*ARadius.x*kappa;
    tany := dx*ARadius.y*kappa;

    //writeln('tan '+floattostr(tanx)+', '+floattostr(tany));


    if (i = 0) then
    begin
       //AddPoint(p);
       //writeln('add point');
       px:=0;
       py:=0;
       l.x:=0;
       l.y:=0;
       ptanx := 0;
       ptany := 0;
    end
    else
    begin
        //writeln('p '+floattostr(p.x)+', '+floattostr(p.y));


        f.x:=px+ptanx;
        f.y:=py+ptany;

        t.x:=p.x-tanx;
        t.y:=p.y-tany;

        //writeln('f '+floattostr(f.x)+', '+floattostr(f.y));
        //writeln('t '+floattostr(t.x)+', '+floattostr(t.y));

        //NewStroke(l,p);

        //DrawQSpline(p,t,f);
        //DrawQSpline(l,p,t);

        //nvg__tesselateBezier(ctx, last->x,last->y, cp1[0],cp1[1], cp2[0],cp2[1], p[0],p[1], 0, NVG_PT_CORNER);
        DrawCspline(l,p,f,t);

        //NewStroke( l, p);
        // NewStroke( t, f);
        //DrawCSpline(l,p,f,t);

        //writeln('draw spline');
    end;

    l:=p;
    px := p.x;
    py := p.y;
    ptanx := tanx;
    ptany := tany;

  end;

  //DrawQSpline(FromPoint,ToPoint, ControlPoint);
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
  i:integer;
  newCommandText: string;
  flaga, flagb: boolean;
begin
  //clean up eventual old path
  self.FCount:=0;
  setLength(self.FPoints,0);

  //begin parsing the new path
  paramcount := 0;
  CurCommand := '-';

  //add spaces to commands to prevent parsing errors
  newCommandText:='';
  for i := 1 to Length(FCommandText) do
    if (UpperCase(FCommandText[i])[1] in ['M','L','H','V','C','S','Q','T','A','Z']) then
      newCommandText := newCommandText + ' ' + FCommandText[i] + ' '
    else
      newCommandText := newCommandText + FCommandText[i];

  //parse string (remove linebreaks etc
  newCommandText := WrapText(newCommandText, #13#10, [' '], 1); //TODO: find better way to break up large paths

  MS := TMemoryStream.Create;
  MS.Position := 0;
  MS.Write(newCommandText[1], Length(newCommandText));
  MS.Position := 0;
  MyParser := TParser.Create(MS);
  newCommandText:='';

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
    //TODO: add support for arc command A a
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
      // horizontal lineto
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
      // vertical lineto
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
      // smooth curveto
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
      'A':
      Begin
        if paramcount = 7 then
        Begin
          ParamsPoint[0].x:=params[0];
          ParamsPoint[0].y:=params[1];
          ParamsPoint[1].x:=params[5];
          ParamsPoint[1].y:=params[6];
          flaga:=false;
          flagb:=false;
          if params[3]>0 then flaga:=true;
          if params[4]>0 then flagb:=true;
          DrawArc(CurPoint, ParamsPoint[0], params[2], flaga, flagb, ParamsPoint[1]);
          paramcount := 0; //prevent drawing again
          CurPoint:=ParamsPoint[1];
          //Writeln('ARC');
        End;
      End;
      'a':
      Begin
        if paramcount = 7 then
        Begin
          ParamsPoint[0].x:=params[0];
          ParamsPoint[0].y:=params[1];
          ParamsPoint[1].x:=Curpoint.x+params[5];
          ParamsPoint[1].y:=CurPoint.y+params[6];
          flaga:=false;
          flagb:=false;
          if params[3]>0 then flaga:=true;
          if params[4]>0 then flagb:=true;
          DrawArc(CurPoint, ParamsPoint[0], params[2], flaga, flagb, ParamsPoint[1]);
          paramcount := 0; //prevent drawing again
          CurPoint:=ParamsPoint[1];
        End;
      End;
    end;

    PrevCommand:=CurCommand;
    curtoken := MyParser.NextToken;
  end;

  MyParser.Free();
  MS.Free();
end;

//TTransform

constructor TTransformStep.Create();
begin
 //
end;

destructor  TTransformStep.Destroy();
begin
 inherited Destroy;
end;

procedure  TTransformStep.Apply();
type
  GLMatrix= array[0..15] of GLfloat; // Matrix type
var
  matrix: GLMatrix;
begin
  case fType of
  glvgMatrix: begin
      gltranslatef(e,f,0);

      matrix[0] := a;
      matrix[1] := b;
      matrix[2] := 0;
      matrix[3] := 0;

      matrix[4] := c;
      matrix[5] := d;
      matrix[6] := 0;
      matrix[7] := 0;

      matrix[8] := 0;
      matrix[9] := 0;
      matrix[10] := 1;
      matrix[11] := 0;

      matrix[12] := 0;
      matrix[13] := 0;
      matrix[14] := 0;
      matrix[15] := 1;

      glMultMatrixf(matrix);
    end;
  glvgRotate: begin
      //should this use the x,y begin coord of the shape if no x,y supplied
      glTranslatef (x, y , 0);
      glRotatef (angle, 0, 0, 1);
      glTranslatef (-x, -y, 0);
    end;
  glvgTranslate: gltranslatef(x,y,0);
  glvgScale: glscalef(x,y,1);
  glvgSkewX: begin //skew also moves shape from left to right?

      matrix[0] := 1;
      matrix[1] := 0;
      matrix[2] := 0;
      matrix[3] := 0;

      matrix[4] := Tan(DegToRad(angle));
      matrix[5] := 1;
      matrix[6] := 0;
      matrix[7] := 0;

      matrix[8] := 0;
      matrix[9] := 0;
      matrix[10] := 1;
      matrix[11] := 0;

      matrix[12] := 0;
      matrix[13] := 0;
      matrix[14] := 0;
      matrix[15] := 1;

      glMultMatrixf(matrix);
    end;
  glvgSkewY: begin

      matrix[0] := 1;
      matrix[1] := Tan(DegToRad(angle));
      matrix[2] := 0;
      matrix[3] := 0;

      matrix[4] := 0;
      matrix[5] := 1;
      matrix[6] := 0;
      matrix[7] := 0;

      matrix[8] := 0;
      matrix[9] := 0;
      matrix[10] := 1;
      matrix[11] := 0;

      matrix[12] := 0;
      matrix[13] := 0;
      matrix[14] := 0;
      matrix[15] := 1;

      glMultMatrixf(matrix);

    end;
  end;
end;


constructor TTransform.Create();
begin
 inherited Create();
end;

constructor TTransform.Create(AValue: string);
begin
 inherited Create();
 self.Text:=AValue;
 self.Parse();
end;

destructor  TTransform.Destroy();
var
  i: integer;
begin
 for i:=0 to high(FTransformations)-1 do
     FreeAndNil(FTransformations[i]);
 FreeAndNil(FTransformations);
 inherited Destroy;
end;

procedure  TTransform.SetTransformStep(I: integer; AValue: TTransformStep);
begin
  FTransformations[I] := AValue;
end;

function  TTransform.GetTransformStep(I: integer): TTransformStep;
begin
  result := FTransformations[I];
end;

procedure  TTransform.Parse();
var
  MyParser: TParser; //https://www.freepascal.org/docs-html/rtl/classes/tparser.html
  MS: TMemoryStream;
  newCommandText: ansistring;
  str: ansistring;
  curcommand: ansistring;
  paramcount: byte;
  params: array[0..5] of single;
begin
  setLength(self.FTransformations,0); //clean up previous transforms

  //parse string (remove linebreaks etc
  newCommandText := WrapText(FCommandText, #13#10, [' '], 1); //TODO: find better way to break up large texts

  MS := TMemoryStream.Create;
  MS.Position := 0;
  MS.Write(newCommandText[1], Length(newCommandText));
  MS.Position := 0;
  MyParser := TParser.Create(MS);
  newCommandText:='';

  curcommand:='';
  while MyParser.Token <> toEOF do
  begin
    str := MyParser.TokenString;
    //WriteLn(str);

    case(MyParser.Token) of
      toSymbol:
      begin
        //writeln('Symbol: '+str);
        curcommand:=LowerCase(str);
        paramcount:=0;
      end;
      toInteger:
      begin
        //writeln('Integer: '+str);
        params[paramcount]:=StrToInt(str);
        paramcount:=paramcount+1;
      end;
      toFloat:
      begin
        //writeln('Float: '+str);
        params[paramcount]:=StrToFloat(str);
        paramcount:=paramcount+1;
      end;
    end;

    //writeln(paramcount);
    if str=')' then //on close of transform command add it
    begin

      //Add TransfromStep
      if High(FTransformations)<0 then
        setLength(FTransformations,1)
      else
        setLength(FTransformations,High(FTransformations)+1);

      if (curcommand='matrix') then
      begin
        FTransformations[High(FTransformations)] := TTransformStep.Create();
        FTransformations[High(FTransformations)].transformType:=glvgMatrix;
        FTransformations[High(FTransformations)].a:=params[0];
        FTransformations[High(FTransformations)].b:=params[1];
        FTransformations[High(FTransformations)].c:=params[2];
        FTransformations[High(FTransformations)].d:=params[3];
        FTransformations[High(FTransformations)].e:=params[4];
        FTransformations[High(FTransformations)].f:=params[5];
      end;

      if (curcommand='translate') then
      begin
        FTransformations[High(FTransformations)] := TTransformStep.Create();
        FTransformations[High(FTransformations)].transformType:=glvgTranslate;
        FTransformations[High(FTransformations)].x:=params[0];
        if paramcount>=2 then //y is optional
          FTransformations[High(FTransformations)].y:=params[1]
        else
          FTransformations[High(FTransformations)].y:=0;
      end;

      if (curcommand='scale') then
      begin
        FTransformations[High(FTransformations)] := TTransformStep.Create();
        FTransformations[High(FTransformations)].transformType:=glvgScale;
        FTransformations[High(FTransformations)].x:=params[0];
        if paramcount>=2 then //y is optional
          FTransformations[High(FTransformations)].y:=params[1]
        else
          FTransformations[High(FTransformations)].y:=1;
      end;

      if (curcommand='rotate') then
      begin
        FTransformations[High(FTransformations)] := TTransformStep.Create();
        FTransformations[High(FTransformations)].transformType:=glvgRotate;
        FTransformations[High(FTransformations)].angle:=params[0];
        if paramcount>=2 then //x is optional
          FTransformations[High(FTransformations)].x:=params[1]
        else
          FTransformations[High(FTransformations)].x:=0;
        if paramcount>=3 then //y is optional
          FTransformations[High(FTransformations)].y:=params[2]
        else
          FTransformations[High(FTransformations)].y:=0;
        writeln('rotate '+floattostr(FTransformations[High(FTransformations)].angle)+' '+floattostr(FTransformations[High(FTransformations)].x)+' '+floattostr(FTransformations[High(FTransformations)].y));
      end;

      if (curcommand='skewx') then
      begin
        FTransformations[High(FTransformations)] := TTransformStep.Create();
        FTransformations[High(FTransformations)].transformType:=glvgSkewX;
        FTransformations[High(FTransformations)].angle:=params[0];
      end;

      if (curcommand='skewy') then
      begin
        FTransformations[High(FTransformations)] := TTransformStep.Create();
        FTransformations[High(FTransformations)].transformType:=glvgSkewY;
        FTransformations[High(FTransformations)].angle:=params[0];
      end;

    end;

    MyParser.NextToken;
  end;

  MyParser.Free();
  MS.Free();
end;

procedure  TTransform.Apply();
var
  i: integer;
begin
  for i := 0 to High(FTransformations) do
      FTransformations[i].Apply();
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
  FClipPath:=nil;
  FNumElements:=0;
  FTransform:=nil;
end;

destructor TglvgGroup.Destroy;
var
    i: integer;
begin
  FreeAndNil(FTransform);
  FreeAndNil(FClipPath);
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
  parentmask: integer;
  childmask: integer;
  c,d: integer;
  pid,cid: integer;
begin
  if FTransform<>nil then
  begin
    glPushMatrix();
    FTransform.Apply();
  end;

  if FClipPath = nil then
  begin
    //Normal render
    for i:=0 to FNumElements-1 do
    begin
      FElements[i].Render;
    end;
  end
  else
  begin
    c:=fid;
    d:=0;
    pid := (C shl 4) + D;
    c:=15;//255;
    d:=0;
    parentmask := (C shl 4) + D;
    for i:=0 to FNumElements-1 do
      begin
        FClipPath.Element[i].Polygon.id:=pid;
        FClipPath.Element[i].Polygon.Mask:=parentmask;
      end;
    //FClipPath.Polygon.id:=pid;
    //FClipPath.Polygon.Mask:=parentmask;

    c:=15;//255;
    d:=15;//255;
    childmask := (C shl 4) + D;

    for i:=0 to FNumElements-1 do
      begin
        c:=fid;
        d:=i+1;
        cid := (C shl 4) + D;
        FElements[i].Polygon.Id:=cid;
        FElements[i].Polygon.Mask:=childmask;
      end;

    //Render with scissor clipping
    glColorMask(FALSE, FALSE, FALSE, FALSE);

    //enable stencil buffer
    glEnable(GL_STENCIL_TEST);

    //write a one to the stencil buffer everywhere we are about to draw
    glStencilFunc(GL_ALWAYS, pid, parentmask);

    //this is to always pass a one to the stencil buffer where we draw
    glStencilOp(GL_REPLACE, GL_REPLACE, GL_REPLACE);

    //render scissor
    for i:=0 to FNumElements-1 do
      begin
        FClipPath.Element[i].Polygon.Render(pid,parentmask);
        FClipPath.Element[i].Polygon.RenderPath();
      end;
    //FClipPath.Polygon.Render();

    //until stencil test is diabled, only write to areas where the
    //stencil buffer has a one. This fills the shape
    glStencilFunc(GL_EQUAL, pid, parentmask);

    // don't modify the contents of the stencil buffer
    glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);

    //draw colors again
    glColorMask(TRUE,TRUE, TRUE, TRUE);

    //draw contents
    //glPushMatrix();
      //glTranslateF(FClipPath.Y,FClipPath.X,0);
      for i:=0 to FNumElements-1 do
      begin
        FElements[i].Polygon.Render(pid,parentmask);
        FElements[i].Polygon.RenderPath();
      end;
    //glPopMatrix();

    //'default' rendering again
    glColorMask(TRUE,TRUE, TRUE, TRUE);
    glDisable(GL_STENCIL_TEST);
  end;

  if FTransform<>nil then
    glPopMatrix();
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
