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

begin

  InitOpenGL;

  DC := GetDC(fHandle);
  // Create RenderContext (32 Bit PixelDepth, 24 Bit DepthBuffer, Doublebuffering)
  RC := CreateRenderingContext(DC, fOptions, fPixelDepth, fDepthBuffer, 0, 0, 0, 0);
  // Activate RenderContext
  ActivateRenderingContext(DC, RC);

  // set viewing projection
  glMatrixMode(GL_PROJECTION);
  glFrustum(-0.1, 0.1, -0.1, 0.1, 0.2, 25.0);

  // position viewer
  glMatrixMode(GL_MODELVIEW);

  // Active DepthBuffer
  glEnable(GL_DEPTH_TEST);
  glDepthFunc(GL_LESS);

  glShadeModel(GL_SMOOTH);                    // shading mathod: GL_SMOOTH or GL_FLAT

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


  (*
  //POLYGON TEST
  polystar := TPolygon.Create(nil);
  polystar.Add(0.0, 3.0, 0.0, 1.0, 0.0, 0.0, 0.0 );
  polystar.Add(-1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0);
  polystar.Add(1.6, 1.9, 0.0, 1.0, 0.0, 1.0, 0.0);
  polystar.Add(-1.6, 1.9, 0.0, 1.0, 1.0, 0.0, 0.0);
  polystar.Add(1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0);
  polystar.Tesselate;
  polystar.ExtrudeDepth := 0.2;
  polystar.Extrude();
  *)

  //PATHPOLYGON TEST
  polystar := TPolygon.Create(nil);
//  polystar.Path := 'M100,200 C100,100 400,100 400,200';

  //cubic spline curve example
  polystar.Path := 'M100,200 C100,100 250,100 250,200 S400,300 400,200';

  //quadratic Bezier curve example
  //polystar.Path := 'M200,300 Q400,50 600,300 T1000,300';


  polyfont := TPolygonfont.Create();
  //polyfont.Name := 'Times New Roman';
  polyfont.Precision := 25;
  polyfont.Scale := 4;
  polyfont.Generate();


end;

//tesselation result should be saved in tmesh!!!! gl3ds compatible!!!

procedure TOpenGLRender.Draw;
begin

// Idee voor circular elips fill

// Teken een circular triangulated mesh maar beperk naar buiten toe
// met de omtrek van de te vormen figuur. Eerst met een vierkant.

// ( simpeler eerst met stencil of clipmap )

// Lees ook dit: http://www.devmaster.net/forums/showthread.php?t=7183

//http://davis.wpi.edu/~matt/courses/clipping/

//hmmm beide polygons dus door tess halen en dan dus overlappend deel bepalen
//op het plaatje zie je het maar in code?





  angle:=angle+1;


  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glLoadIdentity;

  glTranslatef(0.0, 0.0, -12.0);

  glRotatef(angle, 0.0, 1.0, 0.0);

  //vector font

  glTranslatef(0.0, 0.0, -12.0);
  glColor3f(1.0, 1.0, 1.0);
  //RenderChar('a');
  //RenderChar('b');

  //polyfont.RenderChar('A');
  polyfont.RenderString('misc.');

  //polyfont.RenderString(text); //tijdelijk uit;
  //RenderString('misc.'); //ook testen met polygon render method.

  //polygon render
  //polystar.Render;
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
