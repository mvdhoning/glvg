program opengl_onewindow;

//compatibility for FPC
{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

//for logs
{$APPTYPE CONSOLE}

uses
  dglOpenGL, sysutils, SDL2, glvg, earcut;

const
  screenwidth: integer = 640;
  screenheight: integer = 480;

var
  //needed for application itself
  window: PSDL_Window;
  context: TSDL_GLContext;
  running: Boolean;
  last_time,current_time, currentfps: integer;
  time_passed: glfloat;
  framecount: integer;
  //glvg
  polystar: TglvgPolygon; //TPolygonShape;
  polyrect,bg1: TglvgRect;
  polycirc: TglvgCircle;
  polytext: TglvgText;

procedure InitializeVariables;
begin
  //only for avoiding warnings
  window := nil;
  context := nil;
end;

//initializes SDL
function InitializeSDL: Boolean;
begin
  framecount:=0;
  time_passed:=0;
  current_time:=0;
  last_time:=0;
  Result := false;
  //only the video system is needed
  if SDL_Init(SDL_INIT_VIDEO) = 0 then
    Result := true;

  SDL_SetRelativeMouseMode(SDL_TRUE);
end;

procedure InitializeOpenGL;
begin
  InitOpenGL;                   //core-functions
  ReadExtensions;               //Extensions
  ReadImplementationProperties; //Extension-Support-Bools
end;

procedure InitializeOpenGLVariables;
var
  mypath: string;
begin

  glClearColor(0,0,0,0);
  //set current and last time correct just before rendering
  current_time := SDL_GetTicks();
  last_time:=current_time;

  //glvg
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
  TglvgRect(bg1.Style.Pattern.Element[0]).Style.Color.SetColor(1,1,1,0.9);
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

  //PATHPOLYGON TEST
  polystar := TglvgPolygon.Create();
  polystar.Style.Color.SetColor(1,1,0,1);     //first set color etc
  polystar.Style.LineWidth := 1.0;
  polystar.Style.LineColor.SetColor(1,0,1,1);
  polystar.Style.FillType:=glvgsolid;

  //mypath := 'M100,200 C100,100 250,100 250,200 S400,300 400,200';
  //mypath := 'M100,200 C100,100 400,100 400,200';

  //mypath := 'M365,563 L 183,-33 L 0,563 H 101 L 183, 296 L 270, 563 H365 Z';
  mypath := 'M35,1 H 18 V 564 H 355 V 420 H 125 V 144 H 248 V 211 H 156 V 355 H 355 V 1 Z';

  //mypath := 'M150 0 L75 200 L225 200 Z'; //Simple Triangle

  polystar.Polygon.Path := mypath;

  //polystar.Style.GradColorAngle:=90;
  //polystar.Style.NumGradColors := 2;
  //polystar.Style.GradColor[0].a :=1.0;
  //polystar.Style.GradColor[0].SetColor('#FF0000');
  //polystar.Style.GradColor[0].x:=10;
  //polystar.Style.GradColor[1].SetColor('#00FF00');
  //polystar.Style.GradColor[1].x:=200;
  //polystar.Style.FillType := glvgLinearGradient;

  polystar.Polygon.Id:=6;
  polystar.Init;



  //next shape
  polyrect := TglvgRect.Create;
  polyrect.X:= 10.0;
  polyrect.Y:= 10.0;
  polyrect.Width:=100.0;
  polyrect.Height:=200.0;
  polyrect.Rx:=20.0;
  polyrect.Ry:=20.0; //Optional
  polyrect.Style.Color.SetColor(1,1,0,0.6);
  writeln('Rectangle');
  polyrect.Init;
  polyrect.Polygon.Tesselate();

  polyrect.Style.GradColorAngle:=90;
  //polyrect.Style.GradColorAngleAlpha:=0;
  polyrect.Style.NumGradColors := 2;
  polyrect.Style.GradColor[0].a :=1.0;
  //polyrect.Style.GradColor[1].a :=1.0;

  polyrect.Style.GradColor[0].SetColor('#FF0000');
  polyrect.Style.GradColor[0].x:=10;
  polyrect.Style.GradColor[1].SetColor('#00FF00');
  polyrect.Style.GradColor[1].x:=100;

  polyrect.Style.FillType := glvgLinearGradient;
  polyrect.Style.LineType := glvgSolid;
  polyrect.Polygon.Id:=7;
  //polyrect.Style.Color.a:=0.5;
  polyrect.Init;

  polycirc := TglvgCircle.Create();
  polycirc.Radius:=25;
  polycirc.Style.Color.SetColor(1,0,0,0.5);
  polycirc.Style.FillType:=glvgsolid;
  polyrect.Style.LineType := glvgSolid;
  polycirc.Init;


  //vector font
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

  polytext.Style.FillType := glvgSolid; //glvgLinearGradient;
  polytext.Style.LineType := glvgNone; //glvgSolid;

  polytext.Font.Size := 32; //12; //12pt
  polytext.Font.LoadFromFile('font.txt');
  //polytext.Font.Scale := 0.05; //TODO: Should be related to font-size?
  polytext.Text := 'Hello World!';
  polytext.Style.LineWidth:=2.0;

end;

procedure ResizeOpenGL(w,h: Integer);
begin
  if (h=0) then
     h:=1;
  glViewport(0, 0, w, h);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  gluPerspective(45.0,w/h,0.1,10000.0);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
end;

//Event-Handler
procedure HandleEvents;
var
  event: TSDL_Event;
  dx,dy: integer;
begin
  while SDL_PollEvent(@event) > 0 do
  begin
    case event.type_ of
      SDL_QUITEV: //this only works with one window
        //stop main-loop
        running := false;
      
	  SDL_KEYDOWN:
        begin
        if (event.key.keysym.scancode = SDL_SCANCODE_ESCAPE) then
          begin
            running := false;
          end;
        end;

      SDL_KEYUP:
        begin
        end;

      SDL_MOUSEMOTION:
        begin
          dx := event.motion.xrel;
          dy := event.motion.yrel;
        end;

      SDL_MOUSEBUTTONDOWN:
        begin
        end;
		
    end;
  end;
end;

//update game logic pre render
procedure Update();
begin

  current_time := SDL_GetTicks();
  time_passed := (current_time - last_time) / 1000; //miliseconds to seconds

  if(time_passed >0) then
  begin
        //  calculate the number of frames per second
        currentfps := round(framecount / time_passed);

        //  Set time
         last_time := current_time;

        //  Reset frame count
        frameCount := 0;
  end;

  SDL_SetWindowTitle(window, pchar('OpenGL with SDL - '+inttostr(currentfps)+' fps'));

  //set current and last time correct just before rendering
  current_time := SDL_GetTicks();
  last_time:=current_time;
end;

//set 2d render mode
procedure Set2D();
begin
  glViewport(0, 0, screenwidth, screenheight);
  glMatrixMode (GL_PROJECTION);
  glLoadIdentity();
  glOrtho (0, 640, 480, 0,-100,100);
  glMatrixMode (GL_MODELVIEW);
  glLoadIdentity();
  glTranslatef (0.375, 0.375, 0.0);
end;

//set 3d render mode
procedure Set3D();
begin
  glEnable(GL_DEPTH_TEST);
  glViewport(0, 0, screenwidth, screenheight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  gluPerspective(65.0, screenwidth / screenheight, 0.1, 60.0);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();
end;

//Render
procedure Render;
begin
  framecount:=framecount+1;

  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT);

  glMatrixMode (GL_PROJECTION); glLoadIdentity(); glOrtho (0, 640, 480, 0,-100,100);
  glMatrixMode (GL_MODELVIEW); glLoadIdentity(); glTranslatef (0.375, 0.375, 0.0);

  glDisable(GL_DEPTH_TEST);

  //AntiAlias
  //glEnable (GL_BLEND);
  //glEnable (GL_POLYGON_SMOOTH); //makes triangle faces show up
  //glDisable (GL_DEPTH_TEST);

  // Alpha Blending
  glEnable (GL_BLEND);
  glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

  //bg1.Render;

  //polygon render
  polystar.Render;
  //polystar.RenderPath;

  polyrect.Render;
  polycirc.Render; //renders a square fill?

  //render text with vector font
  //AntiAlias
  glEnable (GL_POLYGON_SMOOTH);
  polytext.Render;
  glDisable (GL_POLYGON_SMOOTH);

  glFlush(); //for opengl to do its thing
end;



begin

  InitializeVariables;
  try
    //initialize SDL
    if not InitializeSDL then
    begin
      WriteLn('Couldn''t initialize SDL!');
      Exit;
    end;

  //set opengl screen buffer attributes
  SDL_GL_SetAttribute(SDL_GL_RED_SIZE, 8);
  SDL_GL_SetAttribute(SDL_GL_GREEN_SIZE, 8);
  SDL_GL_SetAttribute(SDL_GL_BLUE_SIZE, 8);
  SDL_GL_SetAttribute(SDL_GL_ALPHA_SIZE, 8);
  SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 16);
  SDL_GL_SetAttribute(SDL_GL_STENCIL_SIZE, 1);
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 2 ); //force opengl version
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 1 ); //force opengl version
  SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1); //doublebuffer

  //create the window,
  //caption - first parameter
  //position: 100,100
  //640x480
  //OpenGL-Support
  window := SDL_CreateWindow('OpenGL with SDL - One Window Test', 100+400, 100, screenwidth, screenheight, SDL_WINDOW_OPENGL);

  //the opengl-context
  context := SDL_GL_CreateContext(window);

  //initialize OpenGL
  InitializeOpenGL;

  //initialize resources
  InitializeOpenGLVariables;

  SDL_GL_SetSwapInterval(0); //no vsync

  //main-loop
  running := true;
  while running do
    begin
      //Event-Handling
      HandleEvents;
      //Updating
      Update;
      //Rendering
      Render;
      //Swap-Window
      SDL_GL_SwapWindow(window);
    end;

  finally

  polystar.Free;
  polyrect.Free;
  polycirc.Free;
  bg1.Free;
  polytext.Free;

  SDL_GL_DeleteContext(context);
  SDL_DestroyWindow(window);
  SDL_Quit;

end;

end.
