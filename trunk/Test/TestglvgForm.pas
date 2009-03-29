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

uses glvg;

var
  polystar: TPolygon;
  polyfont: TPolygonFont;

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
  ambient:  TGLArrayf4=( 0.3, 0.3, 0.3, 0.3);
var
  mypath: string;
begin

  InitOpenGL;

  DC := GetDC(fHandle);
  // Create RenderContext (32 Bit PixelDepth, 24 Bit DepthBuffer, Doublebuffering)
  RC := CreateRenderingContext(DC, fOptions, fPixelDepth, fDepthBuffer, 0, 0, 0, 0);
  // Activate RenderContext
  ActivateRenderingContext(DC, RC);

  glMatrixMode (GL_PROJECTION); glLoadIdentity(); gluOrtho2D (0, 6400, 0, 4800);
  glMatrixMode (GL_MODELVIEW); glLoadIdentity(); glTranslatef (0.375, 0.375, 0.0);

  // track material ambient and diffuse from surface color, call it before glEnable(GL_COLOR_MATERIAL)
  glColorMaterial(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE);
  glEnable(GL_COLOR_MATERIAL);

  // Set lighting
  glEnable(GL_LIGHTING);
  glLightfv(GL_LIGHT0, GL_POSITION, @light0_position);
  glLightfv(GL_LIGHT0, GL_AMBIENT, @ambient);
  glEnable(GL_LIGHT0);

  // Set clear background color
  glClearColor(0,0,0,0);

  //PATHPOLYGON TEST
  polystar := TPolygon.Create(nil);
  polystar.SetColor(1,0,0,1);     //first set color etc
  polystar.LineWidth := 1.0;
  polystar.SetLineColor(1,1,1,1);

//  polystar.Path := 'M100,200 C100,100 400,100 400,200'; //only then path

  //  http://commons.wikimedia.org/wiki/File:Cat_drawing.svg
  mypath := 'M 380.76986,379.21038 C 380.76986,439.81681 324.84665,489.00463 255.94126,489.00463';
  mypath := mypath + ' C 187.03587,489.00463 131.11266,439.81681 131.11266,379.21038 C 131.11266';
  mypath := mypath + ',348.90716 118.81375,247.16173 141.40773,227.28897 C 152.70472,217.35259 192.4347';
  mypath := mypath + ',283.60703 207.36733,278.0487 C 222.29995,272.49036 238.71492,269.41612 255.94126,269.41612';
  mypath := mypath + ' C 273.16761,269.41612 289.58257,272.49036 304.51519,278.0487 C 319.44781,283.60703 357.30068';
  mypath := mypath + ',223.95676 368.59767,233.89313 C 391.19165,253.76589 380.76986,348.90716 380.76986,379.21038 z';
//  polystar.Path := mypath;

  mypath := 'M371,1 H 29 V144 H264 Q 264,151 264,166 Q265,180 265, 188 Q 265,212 249,212 H 132 Q 83,212 55,247 Q 29,279 29,329 V 566 H 335 V 422 H 136 V 375 Q 136,360 144,356 Q 148,355 168,355 H 279 Q 327,355 352,309 Q 371,273 371,221 V 1 Z';
//  mypath := 'M365,563 L 183,-33 L 0,563 H 101 L 183, 296 L 270, 563 H365 Z';
//  mypath := 'M35,1 H 18 V 564 H 355 V 420 H 125 V 144 H 248 V 211 H 156 V 355 H 355 V 1 Z';

mypath := 'M100,200 C100,100 250,100 250,200 S400,300 400,200';
//mypath := 'M 95 712 c 41 0 66 -28 66 -67 c 0 -7 -1 -12 -2 -19 c -19 -117 -44 -249 -47 -327 c -1 -28 -2 -57 -2 -93 h -29 c 0 127 -8 177 -29 295 c -24 132 -26 135 -26 143 c 0 40 30 68 69 68 z ';
//mypath := mypath + ' M 97 138 c 36 0 62 -32 62 -68 c 0 -37 -26 -70 -62 -70 s -63 33 -63 70 c 0 36 27 68 63 68 z';

  polystar.Path := mypath;

  //cubic spline curve example
//  polystar.Path := 'M100,200 C100,100 250,100 250,200 S400,300 400,200';

  //quadratic Bezier curve example
  //polystar.Path := 'M200,300 Q400,50 600,300 T1000,300';


  polyfont := TPolygonfont.Create();
  polyfont.LoadFromFile('font.txt');


end;

procedure TOpenGLRender.Draw;
begin
  glMatrixMode (GL_PROJECTION); glLoadIdentity(); gluOrtho2D (0, 6400, 4800, 0);
  glMatrixMode (GL_MODELVIEW); glLoadIdentity(); glTranslatef (0.375, 0.375, 0.0);

  angle:=angle+1;

  glpushmatrix();
  //vector font
    gltranslatef(0,100,0);
    glscalef(0.1,-0.1,0);

  //  polyfont.RenderChar('R');
  polyfont.RenderString(polyfont.Name);
  glpopmatrix();

//  glTranslatef(-80.3122, -226.2716, 0.0); //for cat drawing

    gltranslatef(100,100,0);
//    glscalef(0.1,0.1,0);

  //polygon render
  polystar.Render;
  polystar.RenderPath;

  //swap buffer (aka draw)
  SwapBuffers(DC);
end;

procedure TOpenGLRender.Stop;
begin
  polyfont.Free;
  polystar.Free;
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
