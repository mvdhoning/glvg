unit TestglvgForm;

interface

uses
 Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, DglOpenGL, Menus;

type
  TDGLForm = class(TForm)
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TOpenGLRender = class(TThread)
  private
    DC:HDC;
    RC:HGLRC;
    angle: integer;
    fHandle: cardinal;
    fOptions: TRCOptions;
    fPixelDepth: byte;
    fDepthBuffer: byte;

    fStartTick : Cardinal;
    fFrames    : Integer;
    fFPS       : Single;
  public
    destructor Destroy; override;
    procedure Init;
    procedure Draw;
    procedure Stop;
    procedure Execute; override;
    property Handle: cardinal read fHandle write fHandle;
    property Options: TRCOptions read fOptions write fOptions;
    property PixelDepth: byte read fPixelDepth write fPixelDepth;
    property DepthBuffer: byte read fDepthBuffer write fDepthBuffer;
  end;

var
  DGLForm: TDGLForm;
  OpenGLRender: TOpenGLRender;

implementation

{$R *.DFM}

uses glvg, glvggui;

var
  polystar: TPolygon;
  polyrect: TglvgRect;
  polyelipse: TglvgCircle;
  polyline: TglvgLine;
  polytext: TglvgText;
  pt2: TglvgText;
  texturepoly: TglvgRect;
  circfillpoly: TglvgRect;
  bg1: TglvgRect;

  polyuitest: TglvgGuiObject;

type
  TVSyncMode = (vsmSync, vsmNoSync);

var
  VSync: TVSyncMode;

{-------------------------------------------------------------------}
{ V-Sync
{ Ok for all system windows 32                                      }
{-------------------------------------------------------------------}
procedure VBL2(vsync : TVSyncMode);
var
   i : Integer;
begin
   if WGL_EXT_swap_control then
   begin
      i := wglGetSwapIntervalEXT;
      case VSync of
         vsmSync    : if i<>1 then wglSwapIntervalEXT(1);
         vsmNoSync  : if i<>0 then wglSwapIntervalEXT(0);
      else
         Assert(False);
      end;
   end;

end;

//TOpenGLRender
destructor TOpenGLRender.Destroy;
begin
  inherited;
end;

procedure TOpenGLRender.Execute;
begin
  Init;
  while not terminated do
  begin
    Draw;
    sleep(1);
  end;
  Stop;
end;

procedure TOpenGLRender.Init;
const
  light0_position:TGLArrayf4=( -8.0, 8.0, -16.0, 0.0);
  //ambient:  TGLArrayf4=( 0.3, 0.3, 0.3, 0.3);
  ambient:  TGLArrayf4=( 1, 1, 1, 0);
var
  mypath: string;
  temppath: string;
  angle2: single;
  vectorx: single;
  vectory: single;
  vectorx1: single;
  vectory1: single;
  fx: single;
  fy: single;
  frx: single;
  fry: single;
begin

  InitOpenGL;

  DC := GetDC(fHandle);
  // Create RenderContext (32 Bit PixelDepth, 24 Bit DepthBuffer, Doublebuffering)
  RC := CreateRenderingContext(DC, fOptions, fPixelDepth, fDepthBuffer, 0, 0, 0, 0);
  // Activate RenderContext
  ActivateRenderingContext(DC, RC);

  fStartTick := GetTickCount; //Init FPS.

  glMatrixMode (GL_PROJECTION); glLoadIdentity(); gluOrtho2D (0, 6400, 0, 6400);
  glMatrixMode (GL_MODELVIEW); glLoadIdentity(); glTranslatef (0.375, 0.375, 0.0);

  // track material ambient and diffuse from surface color, call it before glEnable(GL_COLOR_MATERIAL)
//  glColorMaterial(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE);
//  glEnable(GL_COLOR_MATERIAL);

  // Set lighting
//  glEnable(GL_LIGHTING);
//  glLightfv(GL_LIGHT0, GL_POSITION, @light0_position);
//  glLightfv(GL_LIGHT0, GL_AMBIENT, @ambient);
//  glEnable(GL_LIGHT0);

  // Set clear background color
  glClearColor(0,0,0,0);

  //PATHPOLYGON TEST
  polystar := TPolygon.Create();
  polystar.Style.Color.SetColor(1,0,0,1);     //first set color etc
  polystar.Style.LineWidth := 1.0;
  polystar.Style.LineColor.SetColor(1,1,1,1);

  //polystar.Path := 'M100,200 C100,100 400,100 400,200'; //only then path

  //http://commons.wikimedia.org/wiki/File:Cat_drawing.svg
  mypath := 'M 380.76986,379.21038 C 380.76986,439.81681 324.84665,489.00463 255.94126,489.00463';
  mypath := mypath + ' C 187.03587,489.00463 131.11266,439.81681 131.11266,379.21038 C 131.11266';
  mypath := mypath + ',348.90716 118.81375,247.16173 141.40773,227.28897 C 152.70472,217.35259 192.4347';
  mypath := mypath + ',283.60703 207.36733,278.0487 C 222.29995,272.49036 238.71492,269.41612 255.94126,269.41612';
  mypath := mypath + ' C 273.16761,269.41612 289.58257,272.49036 304.51519,278.0487 C 319.44781,283.60703 357.30068';
  mypath := mypath + ',223.95676 368.59767,233.89313 C 391.19165,253.76589 380.76986,348.90716 380.76986,379.21038 z';
  //polystar.Path := mypath;

  mypath := 'M371,1 H 29 V144 H264 Q 264,151 264,166 Q265,180 265, 188 Q 265,212 249,212 H 132 Q 83,212 55,247 Q 29,279 29,329 V 566 H 335 V 422 H 136 V 375 Q 136,360 144,356 Q 148,355 168,355 H 279 Q 327,355 352,309 Q 371,273 371,221 V 1 Z';
  //mypath := 'M365,563 L 183,-33 L 0,563 H 101 L 183, 296 L 270, 563 H365 Z';
  //mypath := 'M35,1 H 18 V 564 H 355 V 420 H 125 V 144 H 248 V 211 H 156 V 355 H 355 V 1 Z';

  mypath := 'M100,200 C100,100 250,100 250,200 S400,300 400,200';
  //mypath := 'M 95 712 c 41 0 66 -28 66 -67 c 0 -7 -1 -12 -2 -19 c -19 -117 -44 -249 -47 -327 c -1 -28 -2 -57 -2 -93 h -29 c 0 127 -8 177 -29 295 c -24 132 -26 135 -26 143 c 0 40 30 68 69 68 z ';
  //mypath := mypath + ' M 97 138 c 36 0 62 -32 62 -68 c 0 -37 -26 -70 -62 -70 s -63 33 -63 70 c 0 36 27 68 63 68 z';

  //mypath := 'M 420 -75 L 420 -75 L 420 0 L 420 0 L 34 0 L 34 0 L 34 25 L 34 25 L 65.921875 25 C 65.921875 25 121.765625';
  //mypath := mypath + ' 25 147.046875 57.59375 C 147.046875 57.59375 163 78.859375 163 160 L 163 160 L 163 744 C 163 744 163';
  //mypath := mypath + ' 812.5 154.359375 834.4375 C 154.359375 834.4375 147.703125 851.0625 127.09375 863.046875 C 127.09375 863.046875';
  //mypath := mypath + ' 97.828125 879 65.921875 879 L 65.921875 879 L 34 879 L 34 879 L 34 904 L 34 904 L 420 904 L 420 904 L 420 879 L 420';
  //mypath := mypath + ' 879 L 387.578125 879 C 387.578125 879 332.671875 879 307.53125 846.40625 C 307.53125 846.40625 291 825.140625 291 744';
  //mypath := mypath + ' L 291 744 L 291 160 C 291 160 291 91.5 299.59375 69.5625 C 299.59375 69.5625 306.21875 52.9375 327.390625 40.953125 C 327.390625 40.953125 355.828125 25 387.578125 25 L 387.578125 25 Z';

  polystar.Path := mypath;

  //cubic spline curve example
  //polystar.Path := 'M100,200 C100,100 250,100 250,200 S400,300 400,200';

  //quadratic Bezier curve example
  //polystar.Path := 'M200,300 Q400,50 600,300 T1000,300';

  //polyfont := TPolygonfont.Create();
  //polyfont.LoadFromFile('font.txt');
  //polyfont.Scale := 0.05; //TODO: Should be related to font-size?

  polyrect := TglvgRect.Create;
  polyrect.X:= 10.0;
  polyrect.Y:= 10.0;
  polyrect.Width:=100.0;
  polyrect.Height:=200.0;
  polyrect.Rx:=20.0;
  polyrect.Ry:=20.0; //Optional
  polyrect.Style.Color.SetColor(1,0,0,1);
  polyrect.Style.Color.a:=0.8;

  polyrect.Style.GradColorAngle:=90;
  //polyrect.Style.GradColorAngleAlpha:=0;
  polyrect.Style.NumGradColors := 2;
  polyrect.Style.GradColor[0].a :=1.0;
  //polyrect.Style.GradColor[1].a :=1.0;

  polyrect.Style.GradColor[0].SetColor('#FF0000');
  polyrect.Style.GradColor[0].x:=0;
  polyrect.Style.GradColor[1].SetColor('#00FF00');
  polyrect.Style.GradColor[1].x:=100;

  polyrect.Style.FillType := glvgLinearGradient;
  polyrect.Style.LineType := glvgSolid;
  polyrect.Polygon.Id:=7;
  polyrect.Init;

  polyelipse := TglvgCircle.Create();
  polyelipse.X := 400;
  polyelipse.Y := 200;
  polyelipse.Radius := 100;
  polyelipse.Style.GradColorAngle:= 45;
  polyelipse.Style.NumGradColors:=3;
  //TODO: 3 color fill is realy broken now
  polyelipse.Style.GradColor[0].SetColor('#FF0000');
  polyelipse.Style.GradColor[0].x:=400-100+25;

  polyelipse.Style.GradColor[1].SetColor('#0000FF');
  polyelipse.Style.GradColor[1].x:=400+100-45;

  polyelipse.Style.GradColor[2].SetColor('#00FF00');
  polyelipse.Style.GradColor[2].x:=400+100-25;


  polyelipse.Style.FillType := glvgLinearGradient;
  polyelipse.Style.LineType := glvgNone;
  polyelipse.Polygon.Id := 3;
  polyelipse.Init;


  polyline := TglvgLine.Create;
  polyline.X1 := 100;
  polyline.Y1 := 300;
  polyline.X2 := 300;
  polyline.Y2 := 100;
  polyline.Init;

  polytext := TglvgText.Create;
  polytext.X := 100;
  polytext.Y := 100;
  polytext.Style.Color.SetColor(1,0,0,1);
  polytext.Style.LineColor.SetColor(1,0,1,1);

  polytext.Style.NumGradColors:=2;
  with polytext.Style.GradColor[0] do
  begin
    r:=1.0; //yellow
    g:=1.0;
    b:=0.0;
    x:=0;
  end;


  with polytext.Style.GradColor[1] do
  begin
    r:=0.0; //blue
    g:=0.0;
    b:=1.0;
    x:=1000;
  end;


  polytext.Style.GradColorAngle:=90; //90

  polytext.Style.FillType := glvgLinearGradient;
  polytext.Style.LineType := glvgNone; //glvgSolid;

  polytext.Font.LoadFromFile('font.txt');
  polytext.Font.Scale := 0.05; //TODO: Should be related to font-size?
  polytext.Text := 'Hello World';
  polytext.Style.LineWidth:=2.0;

  pt2 := TglvgText.Create;
  pt2.X:=10;
  pt2.Y:=10;
  pt2.Style.Color.SetColor(1,1,1,0.5);
  pt2.Style.Color.SetColor('#00C4EE');
  pt2.Style.FillType := glvgSolid;
  pt2.Style.LineType := glvgSolid;

  pt2.Font.LoadFromFile('times.txt');
  pt2.Font.Scale := 0.2; //TODO: Should be related to font-size?
  pt2.Text:=FloatTostr(fFPS)+ ' fps';

  polyuitest := TglvgGuiObject.Create;
  polyuitest.X := 100;
  polyuitest.Y := 300;

  //textured poly rectangle
  //TODO: a texture is drawn at real pixel size?
  //as it seems only a size 200 x 200 the full texture is shown
  //but even then the bottom part is not shown
  //also making it larger the texture does not repeat
  //better fix the texture settings
  //TODO2: investigate on modifying texture using a matrix
  texturepoly := TglvgRect.Create;
  texturepoly.X:= 100.0;
  texturepoly.Y:= 100.0;
  texturepoly.Width:=300.0; //128 is texture width
  texturepoly.Height:=128.0;
  texturepoly.Rx:=20.0;
  texturepoly.Ry:=20.0; //Optional
  texturepoly.Style.TextureFileName := 'test.bmp';
  texturepoly.Style.TextureAngle := 45;
  texturepoly.Style.Color.SetColor(1,1,1,0.5);
  texturepoly.Style.FillType := glvgTexture;
  texturepoly.Style.Init; //load texture
  texturepoly.Polygon.id:=9;
  texturepoly.Init;
  texturepoly.Polygon.Tesselate;
//  texturepoly.Polygon.ApplyTextureFill;

  circfillpoly := TglvgRect.Create;
  circfillpoly.X:= 100.0;
  circfillpoly.Y:= 250.0;
  circfillpoly.Width:=300.0; //128 is texture width
  circfillpoly.Height:=128.0;
  circfillpoly.Rx:=20.0;
  circfillpoly.Ry:=20.0; //Optional
  circfillpoly.Style.Color.SetColor(1,1,1,0.5);
  circfillpoly.Style.NumGradColors := 4;


  with circfillpoly.Style.GradColor[0] do
  begin
    x:=200; //use x pos from figure should autocalc center but be overideable
    y:=400; //use y pos from figure should autocalc center but be overideable
    z:=1;
    r:=0.0;
    g:=1.0;
    b:=0.0;
//    a:=0.5;
  end;

  with circfillpoly.Style.GradColor[1] do
  begin
    x:=250; //the x coord is used for gradient color position on the radius
    z:=1;
    r:=0.0;
    g:=0.0;
    b:=1.0;
//    a:=0.5;
  end;

  with circfillpoly.Style.GradColor[2] do
  begin
    x:=300;
    z:=1;
    r:=1.0;
    g:=0.0;
    b:=0.0;
//    a:=0.5;
  end;

  with circfillpoly.Style.GradColor[3] do
  begin
    x:=400;
    z:=1;
    r:=1.0;
    g:=0.0;
    b:=1.0;
    a:=0.9;
  end;

  circfillpoly.Style.FillType := glvgCircularGradient;
  circfillpoly.Init;
  circfillpoly.Polygon.Tesselate;
  circfillpoly.Polygon.Id:=2;

  bg1 := TglvgRect.Create;
  bg1.X:=100;
  bg1.Y:=300;
  bg1.Width:=300;
  bg1.Height:=100;
  bg1.Style.Color.SetColor(0,1,0,1);
  bg1.Style.Pattern.Width:=10;
  bg1.Style.Pattern.Height:=10;

  bg1.Style.Pattern.AddElement(TglvgRect.Create);
  TglvgRect(bg1.Style.Pattern.Element[0]).Polygon.id := 3;
  TglvgRect(bg1.Style.Pattern.Element[0]).x := 0;
  TglvgRect(bg1.Style.Pattern.Element[0]).y := 0;
  TglvgRect(bg1.Style.Pattern.Element[0]).width := 10;
  TglvgRect(bg1.Style.Pattern.Element[0]).height := 10;
  TglvgRect(bg1.Style.Pattern.Element[0]).Style.Color.SetColor(1,1,1,1);
  TglvgRect(bg1.Style.Pattern.Element[0]).Style.FillType := glvgSolid;
  TglvgRect(bg1.Style.Pattern.Element[0]).Style.LineType := glvgNone;
  TglvgRect(bg1.Style.Pattern.Element[0]).Init;
  TglvgRect(bg1.Style.Pattern.Element[0]).Polygon.Tesselate;

  bg1.Style.Pattern.AddElement(TglvgRect.Create);
  TglvgRect(bg1.Style.Pattern.Element[1]).Polygon.id := 1;
  TglvgRect(bg1.Style.Pattern.Element[1]).x := 0;
  TglvgRect(bg1.Style.Pattern.Element[1]).y := 0;
  TglvgRect(bg1.Style.Pattern.Element[1]).width := 5;
  TglvgRect(bg1.Style.Pattern.Element[1]).height := 5;
  TglvgRect(bg1.Style.Pattern.Element[1]).Style.Color.SetColor('#add8e6');
  TglvgRect(bg1.Style.Pattern.Element[1]).Style.FillType := glvgSolid;
  TglvgRect(bg1.Style.Pattern.Element[1]).Style.LineType := glvgNone;
  TglvgRect(bg1.Style.Pattern.Element[1]).Init;
  TglvgRect(bg1.Style.Pattern.Element[1]).Polygon.Tesselate;

  bg1.Style.Pattern.AddElement(TglvgRect.Create);
  TglvgRect(bg1.Style.Pattern.Element[2]).Polygon.id := 2;
  TglvgRect(bg1.Style.Pattern.Element[2]).x := 5;
  TglvgRect(bg1.Style.Pattern.Element[2]).y := 5;
  TglvgRect(bg1.Style.Pattern.Element[2]).width := 5;
  TglvgRect(bg1.Style.Pattern.Element[2]).height := 5;
  TglvgRect(bg1.Style.Pattern.Element[2]).Style.Color.SetColor('#add8e6');
  TglvgRect(bg1.Style.Pattern.Element[2]).Style.FillType := glvgSolid;
  TglvgRect(bg1.Style.Pattern.Element[2]).Style.LineType := glvgNone;
  TglvgRect(bg1.Style.Pattern.Element[2]).Init;
  TglvgRect(bg1.Style.Pattern.Element[2]).Polygon.Tesselate;

  bg1.Style.FillType := glvgpattern;
  bg1.Style.LineType := glvgNone;
  bg1.Polygon.Id := 10;
  bg1.Init;

  // Enable or Disable V-Sync
  VSync := vsmSync;
  //VSync := vsmNoSync;
  VBL2(VSync);

end;

procedure TOpenGLRender.Draw;
begin
  glMatrixMode (GL_PROJECTION); glLoadIdentity(); glOrtho (0, 640, 480, 0,-100,100);
  glMatrixMode (GL_MODELVIEW); glLoadIdentity(); glTranslatef (0.375, 0.375, 0.0);

  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT OR GL_STENCIL_BUFFER_BIT);

  //AntiAlias (may or may not work)
  //glEnable (GL_BLEND);
  //glEnable (GL_POLYGON_SMOOTH);
  //glDisable (GL_DEPTH_TEST);

  // Alpha Blending
  glEnable (GL_BLEND);
  glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

  angle:=angle+1;

  //gui test
  //glpushmatrix();
  //  glscalef(10,10,1);
  //  polyuitest.Render;
  //glpopmatrix();
  //end gui test

  bg1.Render;

  //polygon render
  polystar.Render;
  polystar.RenderPath;

  polyelipse.Render;

  polyline.Render;

  pt2.Text:=FloatTostr(Round(fFPS))+ ' fps';
  pt2.Render;
  polytext.Render;

  texturepoly.Render;

  circfillpoly.Render;

  //rotate rounded rectangle
  glrotatef(angle,0,0,1);
  polyrect.Render;


  //swap buffer (aka draw)
  SwapBuffers(DC);

  //fps calculation ...
  inc(fFrames);

  if GetTickCount - fStartTick >= 500 then
  begin
    fFPS       := fFrames/(GetTickCount-fStartTick)*1000;
    fFrames    := 0;
    fStartTick := GetTickCount
  end;

end;

procedure TOpenGLRender.Stop;
begin

  polystar.Free;
  polyrect.Free;
  polyelipse.Free;
  polyline.Free;
  polytext.Free;
  pt2.Free;

  DeactivateRenderingContext; // Deactivate RenderContext
  wglDeleteContext(RC); //Delete RenderContext
  ReleaseDC(Handle, DC);
end;

//TDGLForm

procedure TDGLForm.FormCreate(Sender: TObject);
begin
  DecimalSeparator:='.'; //always use . as decimal seperator
  OpenGLRender := TOpenGLRender.Create(true);
  OpenGLRender.Handle := Handle;
  OpenGLRender.Options := [opDoubleBuffered];
  OpenGLRender.PixelDepth := 32;
  OpenGLRender.DepthBuffer := 24;
  OpenGLRender.Resume;
end;

procedure TDGLForm.FormDestroy(Sender: TObject);
begin
  OpenGLRender.Suspend;
  OpenGLRender.Free;
end;

procedure TDGLForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  case Key of
    #27 : Close;
  end;
end;

end.
