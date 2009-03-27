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

  // set viewing projection
  glMatrixMode (GL_PROJECTION);
  glLoadIdentity();
  //glFrustum(-0.1, 0.1, -0.1, 0.1, 0.2, 25.0);
  glOrtho (0, 320, 240, 0, -1, 1);
  glDisable(GL_DEPTH_TEST);
  glMatrixMode (GL_MODELVIEW);
  glLoadIdentity();
  // Displacement trick for exact pixelization
  glTranslatef(0.375, 0.375, 0);


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
  //polystar.Path := 'M100,200 C100,100 400,100 400,200'; //only then path
//  http://commons.wikimedia.org/wiki/File:Cat_drawing.svg
  mypath := 'M 380.76986,379.21038 C 380.76986,439.81681 324.84665,489.00463 255.94126,489.00463';
  mypath := mypath + ' C 187.03587,489.00463 131.11266,439.81681 131.11266,379.21038 C 131.11266';
  mypath := mypath + ',348.90716 118.81375,247.16173 141.40773,227.28897 C 152.70472,217.35259 192.4347';
  mypath := mypath + ',283.60703 207.36733,278.0487 C 222.29995,272.49036 238.71492,269.41612 255.94126,269.41612';
  mypath := mypath + ' C 273.16761,269.41612 289.58257,272.49036 304.51519,278.0487 C 319.44781,283.60703 357.30068';
  mypath := mypath + ',223.95676 368.59767,233.89313 C 391.19165,253.76589 380.76986,348.90716 380.76986,379.21038 z';
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
  // set viewing projection
  glMatrixMode (GL_PROJECTION);
  glLoadIdentity();
  //glFrustum(-0.1, 0.1, -0.1, 0.1, 0.2, 25.0);
  glOrtho (0, 322.22852, 262.73306, 0, 0, 1);
  glDisable(GL_DEPTH_TEST);
  glMatrixMode (GL_MODELVIEW);
  glLoadIdentity();


  angle:=angle+1;

  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glLoadIdentity;


//  glRotatef(angle, 0.0, 1.0, 0.0);

  //vector font

  glTranslatef(0.0, 100.0, 0.0); //why
  //glColor3f(1.0, 1.0, 1.0);
  glscalef(0.1,0.1,0.1);
  polyfont.RenderChar('R');
  //polyfont.RenderString(polyfont.Name);

  //glTranslatef(-10.0, 0.0, 0.0);

  glLoadIdentity();
  glTranslatef(-80.3122, -226.2716, 0.0);

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
