program opengl_onewindow;

//compatibility for FPC
{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

//for logs
{$APPTYPE CONSOLE}

uses
  dglOpenGL, sysutils, SDL2, glvg, glvggui,classes;

const
  screenwidth: integer = 640;
  screenheight: integer = 480;

type
  TMyApplication = class(TglvgGuiWindow)
    public
      button1: TglvgGuiButton;
      connector1: TglvgGuiConnector;
      line1: TglvgGuiConnection;
      node1: TglvgGuiNode;
      constructor Create(aowner: TComponent); override;
      destructor Destroy(); override;
      procedure OnClick();
      procedure OnDrag(x: single; y: single);
  end;

var
  //needed for application itself
  window: PSDL_Window;
  context: TSDL_GLContext;
  running: Boolean;
  last_time,current_time, currentfps: integer;
  time_passed: glfloat;
  framecount: integer;

  //glvg
  node2: TglvgRect;
  circ2: TglvgCircle;
  text1: TglvgText;

  //glvggui

  //my application
  myapp: TMyApplication;

  click: boolean; //should be moved to TglvgGuiManager

constructor TMyApplication.Create();
begin
  inherited Create(nil);
  self.X:=0;
  self.Y:=0;
  self.Width:=screenwidth;
  self.Height:=screenheight;
  button1 := TglvgguiButton.Create(self);
  button1.Name:='button1';
  button1.Caption.Text:='Test';
  button1.X:=400;
  button1.Y:=400;
  button1.Width:=200;
  button1.Height:=25;
  button1.Init;
  button1.OnClick:=self.onclick;


  connector1 := TglvgGuiConnector.Create(self);
  connector1.Name:='connector1';
  connector1.X:=300;
  connector1.Y:=300;
  connector1.OnDrag:=self.ondrag;
  connector1.Init;

  node1 := TglvgGuiNode.Create(self);
  node1.X:=50;
  node1.Y:=250;
  node1.Width:=50+10;
  node1.Height:=50;
  node1.Init;

  line1 := TglvgGuiConnection.Create(self);
  line1.X:=50; //circ1.X;
  line1.Y:=50; //circ1.Y;
  line1.ToX:=circ2.X;
  line1.ToY:=circ2.Y;
  line1.Init;

end;

destructor TMyApplication.Destroy;
begin
  line1.Free;
  node1.Free;
  connector1.Free;
  button1.Free;
  inherited Destroy();
end;

procedure TMyApplication.OnClick();
begin
  writeln('Click!');
end;

procedure TMyApplication.OnDrag(x: single; y:single);
var
  linepath: string;
begin
  self.line1.ToX:=X;
  self.line1.ToY:=Y;
  self.line1.Init;
end;

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

  SDL_SetRelativeMouseMode(SDL_FALSE); //show the mouse cursor
end;

procedure InitializeOpenGL;
begin
  InitOpenGL;                   //core-functions
  ReadExtensions;               //Extensions
  ReadImplementationProperties; //Extension-Support-Bools
end;

procedure InitializeOpenGLVariables;
var
  linepath: string;
  i:integer;
begin

  glClearColor(0,0,0,0);
  //set current and last time correct just before rendering
  current_time := SDL_GetTicks();
  last_time:=current_time;

  //glvg

  //Node2
  node2 := TglvgRect.Create;
  node2.X:= 200.0;
  node2.Y:= 100.0;
  node2.Width:= 50.0;
  node2.Height:= 50.0;
  node2.Style.Color.SetColor(0,1,0,1);
  node2.Style.FillType:=glvgsolid;
  node2.Init;

  circ2 := TglvgCircle.Create();
  circ2.Radius:=5;
  circ2.X:=node2.X;
  circ2.Y:=node2.Y+(node2.Height/2);
  circ2.Style.Color.SetColor(0,0,0,1);
  circ2.Style.LineColor.SetColor(1,1,1,1);
  circ2.Style.FillType:=glvgsolid;
  circ2.Init;

  text1 := TglvgText.Create();
  text1.Font.LoadFromFile('font.txt');
  text1.Font.Size:=12;
  text1.Text:='Hello World';
  text1.X:=10;
  text1.Y:=10;
  text1.Style.Color.SetColor(1,1,1,1);
  text1.Style.FillType:=glvgsolid;
  text1.Style.LineType:=glvgnone;
  text1.Init;

  //glvggui
  myapp := TMyApplication.Create(nil);

  for i:=0 to myapp.ComponentCount-1 do
  begin
    writeln(myapp.Components[i].Name);
  end;

  //Add a font and some text on the buton
  myapp.button1.Caption.Font.LoadFromFile('font.txt');
  myapp.button1.Caption.Text:='This is an test button.';
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
  mouseX,mouseY,mouseMoveX,mouseMoveY: integer;

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
          mouseMoveX := event.motion.xrel; //relative
          mouseMoveY := event.motion.yrel;
          mouseX := event.motion.x; //absolute
          mouseY := event.motion.y;
          text1.Text:='mouseX '+inttostr(mouseMoveX)+' mouseY '+inttostr(mouseMoveY);
          GuiManager.HandleMouseEvent(mousex, mousey, mousemovex, mousemovey, false, click);
          //TODO: should be in glvggui windows class that passes mouse coords on the right object hierarchical
        end;

      SDL_MOUSEBUTTONDOWN:
        begin
          if( event.button.button = SDL_BUTTON_LEFT ) then
            begin
              click:=true;
              GuiManager.HandleMouseEvent(event.button.x, event.button.y,0,0, true, false);
            end;
        end;
      SDL_MOUSEBUTTONUP:
        begin
          if( event.button.button = SDL_BUTTON_LEFT ) then
            begin
              click:=false;
              GuiManager.HandleMouseEvent(event.button.x, event.button.y,0,0, false, false);
            end;
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

  // Alpha Blending
  glEnable (GL_BLEND);
  glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

  myapp.Render;

  circ2.Render;
  node2.Render;
  text1.Render;


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
  click := false;
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

  myapp.Free;

  circ2.Free;
  node2.Free;
  text1.Free;

  SDL_GL_DeleteContext(context);
  SDL_DestroyWindow(window);
  SDL_Quit;

end;

end.
